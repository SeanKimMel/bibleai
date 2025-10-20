#!/bin/bash
set -e

# ============================================
# 배포 설정 파일 로드
# ============================================
CONFIG_FILE="./deploy.config"

if [ ! -f "$CONFIG_FILE" ]; then
    echo "❌ 에러: 배포 설정 파일이 없습니다: $CONFIG_FILE"
    echo ""
    echo "📝 설정 파일 생성 방법:"
    echo "   1. cp deploy.config.example deploy.config"
    echo "   2. deploy.config 파일을 편집하여 실제 값 입력"
    echo "      - SERVER_HOST: EC2 IP 주소"
    echo "      - SSH_KEY: SSH 키 파일 경로"
    echo ""
    exit 1
fi

# 설정 파일 로드
source "$CONFIG_FILE"

# 필수 변수 확인
if [ -z "$SERVER_USER" ] || [ -z "$SERVER_HOST" ] || [ -z "$SSH_KEY" ] || [ -z "$SERVER_PATH" ]; then
    echo "❌ 에러: deploy.config 파일에 필수 변수가 누락되었습니다"
    echo "   필수 변수: SERVER_USER, SERVER_HOST, SSH_KEY, SERVER_PATH"
    exit 1
fi

# 기본값 설정
SSH_PORT=${SSH_PORT:-22}
BACKOFFICE_PORT=${BACKOFFICE_PORT:-9090}

# 로그 파일 설정
LOG_DIR="./logs"
LOG_FILE="$LOG_DIR/deploy_backoffice_$(date +%Y%m%d_%H%M%S).log"
mkdir -p "$LOG_DIR"

# 로그 함수
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log "========================================="
log "백오피스 배포 시작"
log "서버: $SERVER_HOST"
log "경로: $SERVER_PATH"
log "포트: $BACKOFFICE_PORT"
log "========================================="

# ============================================
# 설정 검증
# ============================================
# SSH 키 파일 존재 확인
SSH_KEY_EXPANDED="${SSH_KEY/#\~/$HOME}"
if [ ! -f "$SSH_KEY_EXPANDED" ]; then
    log "❌ 에러: SSH 키 파일을 찾을 수 없습니다: $SSH_KEY_EXPANDED"
    exit 1
fi

# ============================================
# 1단계: SSH 연결 테스트
# ============================================
log ""
log "🔍 1단계: SSH 포트($SSH_PORT) 연결 테스트 중..."
if ! nc -zv -w 5 $SERVER_HOST $SSH_PORT 2>&1 | grep -q "succeeded"; then
    log "❌ SSH 포트 연결 실패: $SERVER_HOST:$SSH_PORT"
    log "   - OpenVPN 연결 확인"
    log "   - EC2 보안그룹 22번 포트 확인"
    log "   - 서버 IP 확인"
    exit 1
fi
log "✅ SSH 포트 연결 성공"

log ""
log "🔐 SSH 인증 테스트 중..."
if ! ssh -i "$SSH_KEY_EXPANDED" -p $SSH_PORT -o ConnectTimeout=10 -o StrictHostKeyChecking=no ${SERVER_USER}@${SERVER_HOST} "echo '연결 성공'" >> "$LOG_FILE" 2>&1; then
    log "❌ SSH 인증 실패"
    log "   - SSH 키 권한 확인: chmod 400 $SSH_KEY_EXPANDED"
    log "   - 사용자명 확인 (Amazon Linux: ec2-user)"
    exit 1
fi
log "✅ SSH 인증 성공"

# ============================================
# 2단계: 빌드 및 배포
# ============================================
log ""
log "🎨 2단계: Tailwind CSS 빌드 중..."
if [ ! -f "node_modules/.bin/tailwindcss" ]; then
    log "⚠️  Tailwind CSS가 설치되지 않았습니다. npm install 실행 중..."
    npm install >> "$LOG_FILE" 2>&1
fi

npm run build:css >> "$LOG_FILE" 2>&1

if [ ! -f "web/static/css/output.css" ]; then
    log "❌ CSS 빌드 실패: output.css가 생성되지 않았습니다"
    exit 1
fi

CSS_SIZE=$(du -h web/static/css/output.css | cut -f1)
log "✅ CSS 빌드 완료 (크기: $CSS_SIZE)"

log ""
log "🔨 3단계: ARM64 백오피스 바이너리 빌드 중..."
GOOS=linux GOARCH=arm64 CGO_ENABLED=0 go build -ldflags="-s -w" -o backoffice cmd/backoffice/main.go >> "$LOG_FILE" 2>&1

if [ ! -f "backoffice" ]; then
    log "❌ 빌드 실패: backoffice 바이너리가 생성되지 않았습니다"
    exit 1
fi

BINARY_SIZE=$(du -h backoffice | cut -f1)
log "✅ 빌드 완료 (크기: $BINARY_SIZE)"

log ""
log "📦 4단계: 전송할 파일 확인 중..."
log "   [필수] backoffice (바이너리)"
log "   [필수] web/backoffice/templates/ (HTML 템플릿)"
log "   [필수] web/backoffice/static/ (정적 파일)"
log "   [필수] web/static/css/output.css (Tailwind CSS)"

log ""
log "📤 5단계: EC2로 파일 전송 중 (rsync 사용, 포트: $SSH_PORT)..."

# 바이너리 전송
rsync -avz --progress \
  -e "ssh -i $SSH_KEY_EXPANDED -p $SSH_PORT -o StrictHostKeyChecking=no" \
  backoffice \
  ${SERVER_USER}@${SERVER_HOST}:${SERVER_PATH}/ 2>&1 | tee -a "$LOG_FILE"

# web/backoffice 디렉토리 전송 (구조 유지)
rsync -avz --progress --delete \
  -e "ssh -i $SSH_KEY_EXPANDED -p $SSH_PORT -o StrictHostKeyChecking=no" \
  --exclude='.git' \
  --exclude='*.log' \
  --exclude='node_modules' \
  --exclude='bak' \
  --exclude='*.md' \
  web/backoffice/ \
  ${SERVER_USER}@${SERVER_HOST}:${SERVER_PATH}/web/backoffice/ 2>&1 | tee -a "$LOG_FILE"

# Tailwind CSS 전송 (백오피스도 output.css 사용)
rsync -avz --progress \
  -e "ssh -i $SSH_KEY_EXPANDED -p $SSH_PORT -o StrictHostKeyChecking=no" \
  web/static/css/output.css \
  ${SERVER_USER}@${SERVER_HOST}:${SERVER_PATH}/web/static/css/ 2>&1 | tee -a "$LOG_FILE"

log ""
log "📋 6단계: systemd 서비스 파일 전송 중..."
rsync -avz --progress \
  -e "ssh -i $SSH_KEY_EXPANDED -p $SSH_PORT -o StrictHostKeyChecking=no" \
  bibleai-backoffice.service \
  ${SERVER_USER}@${SERVER_HOST}:${SERVER_PATH}/ 2>&1 | tee -a "$LOG_FILE"

log ""
log "🔄 7단계: 백오피스 서버 재시작 중 (systemd 사용)..."
ssh -i "$SSH_KEY_EXPANDED" -p $SSH_PORT -o StrictHostKeyChecking=no ${SERVER_USER}@${SERVER_HOST} << EOF 2>&1 | tee -a "$LOG_FILE"
  cd ${SERVER_PATH}

  # 바이너리 실행 권한 부여
  chmod +x ./backoffice

  # systemd 서비스 파일 복사 및 활성화
  sudo cp bibleai-backoffice.service /etc/systemd/system/
  sudo systemctl daemon-reload
  sudo systemctl enable bibleai-backoffice.service

  # 서비스 재시작
  sudo systemctl restart bibleai-backoffice.service
  sleep 2

  # 서비스 상태 확인
  if sudo systemctl is-active --quiet bibleai-backoffice.service; then
    echo "✅ 백오피스 서비스 시작 성공"
    sudo systemctl status bibleai-backoffice.service --no-pager
  else
    echo "❌ 백오피스 서비스 시작 실패"
    sudo journalctl -u bibleai-backoffice.service -n 50 --no-pager
    exit 1
  fi
EOF

log ""
log "✅ 백오피스 배포 완료!"
log "📄 로그 파일: $LOG_FILE"
log ""
log "📊 유용한 명령어:"
log "   서비스 상태: ssh -i $SSH_KEY_EXPANDED ${SERVER_USER}@${SERVER_HOST} 'sudo systemctl status bibleai-backoffice'"
log "   서비스 재시작: ssh -i $SSH_KEY_EXPANDED ${SERVER_USER}@${SERVER_HOST} 'sudo systemctl restart bibleai-backoffice'"
log "   로그 확인: ssh -i $SSH_KEY_EXPANDED ${SERVER_USER}@${SERVER_HOST} 'sudo journalctl -u bibleai-backoffice -f'"
log "   로그 확인(파일): ssh -i $SSH_KEY_EXPANDED ${SERVER_USER}@${SERVER_HOST} 'tail -f ${SERVER_PATH}/backoffice.log'"
log "   서버 접속: ssh -i $SSH_KEY_EXPANDED ${SERVER_USER}@${SERVER_HOST}"
log "   백오피스 접속: http://${SERVER_HOST}:${BACKOFFICE_PORT}"
log ""
log "========================================="
log "백오피스 배포 종료"
log "========================================="
