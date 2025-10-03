# 빠른 시작 가이드

## 🎯 로컬 개발 환경 구축 (5분)

### 1. 저장소 클론

```bash
git clone https://github.com/SeanKimMel/bibleai.git
cd bibleai
```

### 2. 환경 변수 설정

```bash
# .env 파일 생성
cp .env.example .env

# .env 파일 수정 (DB 비밀번호 변경)
vi .env
```

**`.env` 파일 예시**:
```env
DB_HOST=localhost
DB_PORT=5432
DB_USER=bibleai
DB_PASSWORD=your_password_here  # 여기를 변경!
DB_NAME=bibleai
DB_SSLMODE=disable
PORT=8080
ENVIRONMENT=development
```

### 3. PostgreSQL 설정

```bash
# PostgreSQL 시작
# macOS: brew services start postgresql
# Ubuntu: sudo systemctl start postgresql

# 데이터베이스 초기화
./init-db.sh
```

### 4. 애플리케이션 실행

```bash
# 서버 시작
./server.sh start

# 또는 개발 모드 (자동 재시작)
./dev.sh
```

### 5. 접속 확인

브라우저에서 http://localhost:8080 접속

---

## 🚀 EC2 배포 (30분)

### 1. EC2 인스턴스 SSH 접속

```bash
ssh -i your-key.pem ec2-user@your-ec2-ip
```

### 2. 초기 환경 구축

```bash
# 설치 스크립트 다운로드 및 실행
curl -o setup-ec2.sh https://raw.githubusercontent.com/SeanKimMel/bibleai/main/development-only/setup-ec2.sh
chmod +x setup-ec2.sh
./setup-ec2.sh
```

### 3. 환경 변수 설정

```bash
# .env 파일 수정
vi /opt/bibleai/.env

# DB_PASSWORD 변경 필수!
```

### 4. PostgreSQL 설정

**옵션 A: 로컬 PostgreSQL**
```bash
sudo dnf install -y postgresql16-server
sudo postgresql-setup --initdb
sudo systemctl enable postgresql
sudo systemctl start postgresql
cd /opt/bibleai
./init-db.sh
```

**옵션 B: AWS RDS (권장)**
```bash
# RDS 엔드포인트로 .env 파일 수정
vi /opt/bibleai/.env
# DB_HOST=your-rds-endpoint.rds.amazonaws.com
# DB_SSLMODE=require
```

### 5. 애플리케이션 시작

```bash
sudo systemctl start bibleai
sudo systemctl status bibleai

# 로그 확인
sudo journalctl -u bibleai -f
```

### 6. 접속 확인

```bash
curl http://localhost/health
```

---

## 🔄 일상 배포 (3분)

### 로컬에서 개발 완료 후

```bash
# 커밋 및 푸시
git add .
git commit -m "Add new feature"
git push origin main
```

### EC2에서 배포

```bash
# SSH 접속
ssh ec2-user@your-ec2-ip

# 업데이트 스크립트 실행
cd /opt/bibleai
./development-only/update-app.sh
```

**또는 원라이너**:
```bash
ssh ec2-user@your-ip "cd /opt/bibleai && git pull && go build -o bibleai ./cmd/server && sudo systemctl restart bibleai"
```

---

## 📚 더 자세한 가이드

- **로컬 개발**: [DEVELOPMENT.md](DEVELOPMENT.md)
- **EC2 배포**: [SIMPLE_DEPLOYMENT.md](SIMPLE_DEPLOYMENT.md)
- **RDS 마이그레이션**: [RDS_MIGRATION.md](RDS_MIGRATION.md)
- **AWS 전체 배포**: [EC2_DEPLOYMENT.md](EC2_DEPLOYMENT.md)

---

## 🛠️ 관리 명령어

### 로컬 개발

```bash
# 서버 관리
./server.sh start      # 시작
./server.sh stop       # 중지
./server.sh restart    # 재시작
./server.sh status     # 상태 확인
./server.sh logs       # 로그 보기
./server.sh test       # API 테스트

# 개발 모드 (자동 재시작)
./dev.sh
```

### EC2 프로덕션

```bash
# 서비스 관리
sudo systemctl start bibleai
sudo systemctl stop bibleai
sudo systemctl restart bibleai
sudo systemctl status bibleai

# 로그 확인
sudo journalctl -u bibleai -f
sudo journalctl -u bibleai -n 100

# 애플리케이션 업데이트
cd /opt/bibleai
./development-only/update-app.sh
```

---

## 🚨 문제 해결

### 서버가 시작되지 않을 때

```bash
# 로그 확인
tail -f server.log  # 로컬
sudo journalctl -u bibleai -n 50  # EC2

# 일반적인 원인:
# 1. DB 비밀번호 오류 → .env 파일 확인
# 2. PostgreSQL 미실행 → systemctl start postgresql
# 3. 포트 충돌 → lsof -i :8080
```

### DB 연결 실패

```bash
# PostgreSQL 상태 확인
systemctl status postgresql  # Linux
brew services list  # macOS

# .env 파일 확인
cat .env | grep DB_

# 수동 연결 테스트
psql -h localhost -U bibleai -d bibleai
```

### EC2 접속 실패

```bash
# Security Group 확인 (포트 22, 80, 443 열려있는지)
# SSH 키 권한 확인
chmod 600 your-key.pem
```

---

**작성일**: 2025년 10월 3일
**업데이트**: 2025년 10월 3일
