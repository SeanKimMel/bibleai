# AWS EC2 배포 가이드 (네이티브 바이너리 방식)

## 🎯 배포 전략

**선택: 네이티브 Go 바이너리 + AMI 골든 이미지**

### 왜 Docker를 사용하지 않는가?

**당신 프로젝트는 Docker가 필요 없습니다:**
- ✅ 프로젝트 규모가 작음 (Go 파일 8개)
- ✅ 의존성이 단순함 (AWS SDK만)
- ✅ 단일 서버 배포
- ✅ 네이티브가 더 빠르고 효율적

**Docker 대신 AMI 골든 이미지 사용:**
- 더 빠른 배포 (30초 vs 2-3분)
- 메모리 절약 (0MB vs 100MB 오버헤드)
- 비용 절감 (t3.micro vs t3.small 필요)
- AWS 완벽 통합

**Docker 파일 위치:** `development-only/` (백업용, 미사용)

**상세 가이드:** `docs/AMI_DEPLOYMENT.md` 참조

---

## 📋 빠른 시작

### 1. EC2 인스턴스 설정

```bash
# Go 설치
wget https://go.dev/dl/go1.23.0.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go1.23.0.linux-amd64.tar.gz
echo 'export PATH=$PATH:/usr/local/go/bin' | sudo tee -a /etc/profile

# PostgreSQL 설치
sudo yum install -y postgresql16 postgresql16-server
sudo postgresql-setup --initdb
sudo systemctl enable postgresql
sudo systemctl start postgresql

# Git 설치
sudo yum install -y git
```

### 2. 애플리케이션 배포

```bash
# 저장소 클론
git clone https://github.com/SeanKimMel/bibleai.git
cd bibleai

# 빌드
go build -o bibleai ./cmd/server

# 실행
./server.sh start
```

### 3. Systemd 서비스 설정

```bash
sudo tee /etc/systemd/system/bibleai.service << 'SERVICE'
[Unit]
Description=BibleAI Web Application
After=network.target postgresql.service

[Service]
Type=simple
User=ec2-user
WorkingDirectory=/home/ec2-user/bibleai
Environment="USE_AWS_PARAMS=true"
ExecStart=/home/ec2-user/bibleai/bibleai
Restart=on-failure

[Install]
WantedBy=multi-user.target
SERVICE

sudo systemctl daemon-reload
sudo systemctl enable bibleai
sudo systemctl start bibleai
```

---

## 🔄 배포 및 업데이트

### 간단 배포

```bash
#!/bin/bash
cd /home/ec2-user/bibleai
git pull origin main
go build -o bibleai ./cmd/server
sudo systemctl restart bibleai
```

### AMI 골든 이미지 생성

1. EC2 인스턴스 설정 완료
2. AWS Console → EC2 → Create Image
3. Image name: `bibleai-golden-v1.0`

**상세한 AMI 전략:** `docs/AMI_DEPLOYMENT.md` 참조

---

## 🔐 보안 설정

### AWS Parameter Store 사용

```bash
# 파라미터 생성
aws ssm put-parameter --name "/bibleai/db/password" \
  --value "your-password" --type "SecureString"

# EC2 IAM 역할 필요
# 상세: docs/PARAMETER_STORE_SETUP.md
```

### 환경 변수

```bash
export USE_AWS_PARAMS=true  # Parameter Store 사용
```

---

## ✅ 배포 체크리스트

- [ ] EC2 인스턴스 생성 (t3.micro 충분)
- [ ] Go, PostgreSQL 설치
- [ ] GitHub에서 코드 클론
- [ ] Parameter Store 설정
- [ ] 빌드 및 실행 테스트
- [ ] Systemd 서비스 설정
- [ ] AMI 생성 (선택사항)

---

**더 자세한 내용:**
- AMI 골든 이미지 전략: `docs/AMI_DEPLOYMENT.md`
- Parameter Store 설정: `docs/PARAMETER_STORE_SETUP.md`
- 보안 가이드: `docs/SECURITY.md`
