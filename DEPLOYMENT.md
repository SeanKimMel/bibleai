# AWS EC2 배포 가이드

## 현재 환경 분석

### 로컬 개발 환경
- **실행 방식**: `go run` (개발 모드)
- **PostgreSQL**: 로컬 설치 (포트 5432)
- **Go 버전**: 1.24.7
- **Docker**: Dockerfile 존재하나 현재 미사용

### EC2 배포 전략

## 배포 옵션

### 옵션 1: Docker 기반 배포 (권장 ⭐)
**장점:**
- 환경 독립성 (로컬과 동일한 환경 보장)
- 간편한 배포 및 롤백
- 리소스 격리
- 확장 용이

**단점:**
- Docker 오버헤드 (약간의 성능 저하)
- 메모리 사용량 증가

### 옵션 2: 네이티브 Go 바이너리 배포
**장점:**
- 최고의 성능
- 낮은 메모리 사용량
- 단순한 구조

**단점:**
- Amazon Linux 2에 Go 및 의존성 설치 필요
- 환경 차이로 인한 잠재적 문제

---

## 📋 배포 전 체크리스트

### 1. GitHub 보안 설정

#### ✅ 이미 완료된 사항
- [x] `.gitignore` 작성
- [x] `.env.example` 템플릿 생성
- [x] `SECURITY.md` 가이드 작성
- [x] 실제 비밀번호 파일 제외 (`.env`, `*.log`)

#### 🔒 추가 보안 설정
- [ ] GitHub Secrets에 환경 변수 저장
- [ ] `.env` 파일이 커밋되지 않았는지 재확인
- [ ] API 키, 데이터베이스 비밀번호 하드코딩 여부 확인
- [ ] Public/Private 저장소 선택

### 2. EC2 준비 사항

#### 인스턴스 스펙 권장사항
- **타입**: t3.micro (무료 티어) 또는 t3.small
- **OS**: Amazon Linux 2 (선택하신 대로)
- **스토리지**: 20GB 이상
- **메모리**: 최소 1GB (PostgreSQL + Go 앱)

#### 보안 그룹 설정
```
인바운드 규칙:
- SSH (22): 내 IP만 허용
- HTTP (80): 0.0.0.0/0 (선택사항)
- HTTPS (443): 0.0.0.0/0 (선택사항)
- Custom (8080): 0.0.0.0/0 (애플리케이션 포트)
```

### 3. 데이터베이스 전략

#### 옵션 A: EC2 내부 PostgreSQL (간단, 소규모)
- PostgreSQL을 EC2 인스턴스에 직접 설치
- 데이터 백업 스크립트 필요
- 비용 절감

#### 옵션 B: AWS RDS PostgreSQL (권장, 확장성)
- 관리형 데이터베이스
- 자동 백업 및 복구
- 고가용성
- 추가 비용 발생

---

## 🚀 배포 방법

## 방법 1: Docker 배포 (권장)

### EC2 초기 설정 스크립트

다음 스크립트를 EC2에서 실행:

```bash
#!/bin/bash
# setup-ec2-docker.sh

set -e

echo "🚀 EC2 인스턴스 초기 설정 시작..."

# 1. 시스템 업데이트
echo "📦 시스템 패키지 업데이트..."
sudo yum update -y

# 2. Docker 설치
echo "🐳 Docker 설치..."
sudo yum install -y docker
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -a -G docker ec2-user

# 3. Docker Compose 설치
echo "📦 Docker Compose 설치..."
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# 4. Git 설치
echo "📥 Git 설치..."
sudo yum install -y git

# 5. 방화벽 설정
echo "🔥 방화벽 설정..."
sudo firewall-cmd --permanent --add-port=8080/tcp 2>/dev/null || echo "방화벽 미사용"
sudo firewall-cmd --reload 2>/dev/null || echo "방화벽 미사용"

echo "✅ 초기 설정 완료!"
echo "⚠️  로그아웃 후 다시 로그인하여 Docker 그룹 권한 적용"
```

### 배포 스크립트

```bash
#!/bin/bash
# deploy.sh

set -e

APP_DIR="/home/ec2-user/bibleai"
REPO_URL="https://github.com/{사용자명}/{저장소명}.git"

echo "🚀 애플리케이션 배포 시작..."

# 1. 코드 클론 또는 업데이트
if [ -d "$APP_DIR" ]; then
    echo "📥 기존 코드 업데이트..."
    cd $APP_DIR
    git pull origin main
else
    echo "📥 저장소 클론..."
    git clone $REPO_URL $APP_DIR
    cd $APP_DIR
fi

# 2. 환경 변수 설정 확인
if [ ! -f ".env" ]; then
    echo "❌ .env 파일이 없습니다!"
    echo "📝 .env.example을 참고하여 .env 파일을 생성하세요:"
    echo "   cp .env.example .env"
    echo "   nano .env"
    exit 1
fi

# 3. Docker 이미지 빌드
echo "🏗️  Docker 이미지 빌드..."
docker build -t bibleai:latest .

# 4. 기존 컨테이너 중지 및 제거
echo "🛑 기존 컨테이너 중지..."
docker stop bibleai 2>/dev/null || true
docker rm bibleai 2>/dev/null || true

# 5. 새 컨테이너 실행
echo "▶️  새 컨테이너 실행..."
docker run -d \
  --name bibleai \
  --restart unless-stopped \
  -p 8080:8080 \
  --env-file .env \
  bibleai:latest

# 6. 로그 확인
echo "📋 컨테이너 로그 (Ctrl+C로 종료):"
sleep 3
docker logs -f bibleai
```

---

## 방법 2: 네이티브 바이너리 배포

### EC2 초기 설정 스크립트

```bash
#!/bin/bash
# setup-ec2-native.sh

set -e

echo "🚀 EC2 인스턴스 초기 설정 시작..."

# 1. 시스템 업데이트
sudo yum update -y

# 2. PostgreSQL 16 설치
sudo yum install -y postgresql16 postgresql16-server postgresql16-contrib
sudo postgresql-setup --initdb
sudo systemctl start postgresql-16
sudo systemctl enable postgresql-16

# 3. Go 설치
echo "📦 Go 설치..."
GO_VERSION="1.23.0"
wget https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go${GO_VERSION}.linux-amd64.tar.gz
echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc
source ~/.bashrc

# 4. Git 설치
sudo yum install -y git

# 5. PostgreSQL 설정
sudo -u postgres psql -c "CREATE DATABASE bibleai;"
sudo -u postgres psql -c "CREATE USER bibleai WITH ENCRYPTED PASSWORD 'your_secure_password';"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE bibleai TO bibleai;"

echo "✅ 초기 설정 완료!"
```

### 배포 스크립트

```bash
#!/bin/bash
# deploy-native.sh

set -e

APP_DIR="/home/ec2-user/bibleai"
REPO_URL="https://github.com/{사용자명}/{저장소명}.git"

echo "🚀 애플리케이션 배포 시작..."

# 1. 코드 클론 또는 업데이트
if [ -d "$APP_DIR" ]; then
    cd $APP_DIR
    git pull origin main
else
    git clone $REPO_URL $APP_DIR
    cd $APP_DIR
fi

# 2. 의존성 다운로드
echo "📦 Go 의존성 다운로드..."
go mod download

# 3. 빌드
echo "🏗️  애플리케이션 빌드..."
go build -o bibleai ./cmd/server

# 4. 기존 프로세스 중지
echo "🛑 기존 프로세스 중지..."
pkill -f "./bibleai" || true

# 5. 데이터베이스 마이그레이션
echo "🗄️  데이터베이스 초기화..."
./init-db.sh

# 6. 애플리케이션 실행
echo "▶️  애플리케이션 시작..."
nohup ./bibleai > app.log 2>&1 &

echo "✅ 배포 완료!"
echo "📋 로그 확인: tail -f app.log"
```

---

## 🔐 환경 변수 관리

### GitHub Secrets 설정 (CI/CD용)

GitHub 저장소 → Settings → Secrets and variables → Actions

```
DB_HOST=your_rds_endpoint 또는 localhost
DB_PORT=5432
DB_USER=bibleai
DB_PASSWORD=your_secure_password
DB_NAME=bibleai
```

### EC2에서 .env 파일 생성

```bash
# EC2 인스턴스에서 실행
cd /home/ec2-user/bibleai
cp .env.example .env
nano .env

# 실제 값으로 수정:
LOCAL_DB_HOST=localhost
LOCAL_DB_PORT=5432
LOCAL_DB_USER=bibleai
LOCAL_DB_PASSWORD=실제_안전한_비밀번호
LOCAL_DB_SSLMODE=disable
```

---

## 🔄 CI/CD 자동화 (선택사항)

### GitHub Actions 워크플로우

`.github/workflows/deploy.yml`:

```yaml
name: Deploy to EC2

on:
  push:
    branches: [ main ]

jobs:
  deploy:
    runs-on: ubuntu-latest

    steps:
    - name: Deploy to EC2
      uses: appleboy/ssh-action@master
      with:
        host: ${{ secrets.EC2_HOST }}
        username: ec2-user
        key: ${{ secrets.EC2_SSH_KEY }}
        script: |
          cd /home/ec2-user/bibleai
          git pull origin main
          docker build -t bibleai:latest .
          docker stop bibleai || true
          docker rm bibleai || true
          docker run -d --name bibleai --restart unless-stopped -p 8080:8080 --env-file .env bibleai:latest
```

---

## 📊 모니터링 및 유지보수

### 로그 확인

```bash
# Docker
docker logs -f bibleai

# 네이티브
tail -f app.log
```

### 헬스 체크

```bash
curl http://localhost:8080/api/health
```

### 데이터베이스 백업

```bash
# 정기 백업 스크립트
pg_dump -U bibleai bibleai > backup_$(date +%Y%m%d_%H%M%S).sql
```

---

## ⚠️ 주의사항

1. **프로덕션 비밀번호**: 반드시 강력한 비밀번호 사용
2. **방화벽**: 불필요한 포트 차단
3. **백업**: 정기적인 데이터베이스 백업 설정
4. **모니터링**: CloudWatch 또는 외부 모니터링 도구 연동
5. **HTTPS**: Let's Encrypt로 SSL 인증서 발급 권장
6. **도메인**: Route 53 또는 다른 DNS 서비스로 도메인 연결

---

## 🆘 트러블슈팅

### PostgreSQL 연결 실패
```bash
# PostgreSQL 서비스 확인
sudo systemctl status postgresql-16

# 연결 테스트
psql -h localhost -U bibleai -d bibleai
```

### 포트 8080 사용 중
```bash
# 프로세스 확인
sudo lsof -i :8080

# 프로세스 종료
sudo kill -9 <PID>
```

### 메모리 부족
```bash
# 스왑 파일 생성 (t3.micro용)
sudo dd if=/dev/zero of=/swapfile bs=1G count=2
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
```

---

## 📚 참고 자료

- [AWS EC2 사용 설명서](https://docs.aws.amazon.com/ec2/)
- [Docker 공식 문서](https://docs.docker.com/)
- [PostgreSQL 문서](https://www.postgresql.org/docs/)
- [Go 빌드 가이드](https://golang.org/doc/install)

---

**작성일**: 2025-10-01
**프로젝트**: 주님말씀AI 웹앱
**버전**: v0.5.8