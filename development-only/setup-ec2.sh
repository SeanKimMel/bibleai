#!/bin/bash
# EC2 초기 환경 구축 스크립트
# 사용법: EC2 인스턴스 첫 배포 시 실행

set -e

echo "========================================="
echo "BibleAI EC2 환경 초기 구축"
echo "========================================="
echo ""

# 1. 시스템 업데이트
echo "1️⃣  시스템 업데이트 중..."
sudo dnf update -y

# 2. 필요한 패키지 설치
echo ""
echo "2️⃣  필수 패키지 설치 중..."
sudo dnf install -y git wget postgresql16 nginx

# 3. Go 설치
echo ""
echo "3️⃣  Go 1.23.0 설치 중..."
if [ ! -d "/usr/local/go" ]; then
    cd /tmp

    # CPU 아키텍처 감지
    ARCH=$(uname -m)
    if [ "$ARCH" = "aarch64" ] || [ "$ARCH" = "arm64" ]; then
        echo "   ℹ️  ARM64 아키텍처 감지됨"
        GO_ARCH="arm64"
    elif [ "$ARCH" = "x86_64" ]; then
        echo "   ℹ️  x86_64 아키텍처 감지됨"
        GO_ARCH="amd64"
    else
        echo "   ❌ 지원하지 않는 아키텍처: $ARCH"
        exit 1
    fi

    echo "   📥 go1.23.0.linux-${GO_ARCH}.tar.gz 다운로드 중..."
    wget -q https://go.dev/dl/go1.23.0.linux-${GO_ARCH}.tar.gz
    sudo tar -C /usr/local -xzf go1.23.0.linux-${GO_ARCH}.tar.gz
    echo 'export PATH=$PATH:/usr/local/go/bin' | sudo tee -a /etc/profile
    echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc
    source ~/.bashrc
fi

export PATH=$PATH:/usr/local/go/bin
go version

# 4. 애플리케이션 디렉토리 생성
echo ""
echo "4️⃣  애플리케이션 디렉토리 생성 중..."
sudo mkdir -p /opt/bibleai
sudo chown ec2-user:ec2-user /opt/bibleai

# 5. GitHub에서 코드 클론
echo ""
echo "5️⃣  GitHub에서 코드 클론 중..."
cd /opt/bibleai

if [ -d ".git" ]; then
    echo "   ℹ️  이미 Git 저장소가 존재합니다. git pull 실행..."
    git pull origin main
else
    git clone https://github.com/SeanKimMel/bibleai.git .
fi

# 6. .env 파일 생성 (템플릿)
echo ""
echo "6️⃣  .env 파일 생성 중..."
cat > /opt/bibleai/.env <<'EOF'
# BibleAI 환경 변수 설정 (EC2 프로덕션)

# 데이터베이스 설정
DB_HOST=localhost
DB_PORT=5432
DB_USER=bibleai
DB_PASSWORD=CHANGE_ME_PLEASE
DB_NAME=bibleai
DB_SSLMODE=disable

# 서버 설정
PORT=8080

# 환경
ENVIRONMENT=production
EOF

echo "   ⚠️  /opt/bibleai/.env 파일이 생성되었습니다."
echo "   ⚠️  DB_PASSWORD를 반드시 변경하세요!"

# 7. 의존성 다운로드 및 빌드
echo ""
echo "7️⃣  의존성 다운로드 및 빌드 중..."
go mod download
go build -o bibleai ./cmd/server
chmod +x bibleai

# 8. Systemd 서비스 생성
echo ""
echo "8️⃣  Systemd 서비스 생성 중..."
sudo tee /etc/systemd/system/bibleai.service > /dev/null <<'SYSTEMD'
[Unit]
Description=BibleAI Web Application
After=network.target postgresql.service
Wants=postgresql.service

[Service]
Type=simple
User=ec2-user
WorkingDirectory=/opt/bibleai
ExecStart=/opt/bibleai/bibleai
Restart=on-failure
RestartSec=5s
StandardOutput=journal
StandardError=journal
SyslogIdentifier=bibleai

# 보안 설정
NoNewPrivileges=true
PrivateTmp=true

[Install]
WantedBy=multi-user.target
SYSTEMD

sudo systemctl daemon-reload
sudo systemctl enable bibleai

echo "   ✅ Systemd 서비스 생성 완료"

# 9. Nginx 설정
echo ""
echo "9️⃣  Nginx 설정 중..."
sudo tee /etc/nginx/conf.d/bibleai.conf > /dev/null <<'NGINX'
server {
    listen 80;
    server_name _;

    # 클라이언트 최대 업로드 크기
    client_max_body_size 10M;

    location / {
        proxy_pass http://localhost:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;

        # 타임아웃 설정
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }

    # 정적 파일 직접 서빙 (선택사항)
    location /static/ {
        alias /opt/bibleai/web/static/;
        expires 30d;
        add_header Cache-Control "public, immutable";
    }
}
NGINX

sudo systemctl enable nginx
sudo systemctl restart nginx

echo "   ✅ Nginx 설정 완료"

# 10. PostgreSQL 설정 안내
echo ""
echo "🔟 PostgreSQL 설정 안내"
echo "   ℹ️  PostgreSQL을 사용하려면 다음 중 하나를 선택하세요:"
echo ""
echo "   옵션 1: 로컬 PostgreSQL 설치"
echo "     sudo dnf install -y postgresql16-server"
echo "     sudo postgresql-setup --initdb"
echo "     sudo systemctl enable postgresql"
echo "     sudo systemctl start postgresql"
echo "     ./init-db.sh  # 초기 DB 설정"
echo ""
echo "   옵션 2: AWS RDS 사용 (권장)"
echo "     1. RDS PostgreSQL 인스턴스 생성"
echo "     2. .env 파일에서 DB_HOST를 RDS 엔드포인트로 변경"
echo "     3. DB_SSLMODE=require로 변경"
echo ""

echo "========================================="
echo "✅ EC2 환경 구축 완료!"
echo "========================================="
echo ""
echo "📋 다음 단계:"
echo "   1. .env 파일 수정: vi /opt/bibleai/.env"
echo "   2. DB_PASSWORD 변경 (필수!)"
echo "   3. PostgreSQL 설정 (위 안내 참조)"
echo "   4. 애플리케이션 시작: sudo systemctl start bibleai"
echo "   5. 상태 확인: sudo systemctl status bibleai"
echo "   6. 로그 확인: sudo journalctl -u bibleai -f"
echo ""
echo "🌐 접속 테스트:"
echo "   curl http://localhost:8080/health"
echo "   curl http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)/health"
echo ""
