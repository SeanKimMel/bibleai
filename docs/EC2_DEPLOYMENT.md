# AWS EC2 배포 전체 절차

## 🎯 개요

주님말씀AI 웹앱을 AWS EC2 + RDS 환경에 배포하는 전체 절차를 단계별로 설명합니다.

### 배포 아키텍처

```
[사용자]
   ↓
[Internet Gateway]
   ↓
[EC2 인스턴스] ← Elastic IP
   ↓
[RDS PostgreSQL] (Private Subnet)
   ↓
[AWS Parameter Store] (보안 설정)
```

### 전체 타임라인

- **1일차**: AWS 인프라 구축 (EC2, RDS, Security Groups)
- **2일차**: 애플리케이션 배포 및 설정
- **3일차**: 데이터 마이그레이션 및 테스트
- **총 소요 시간**: 2-3일

---

## 📋 Phase 0: 사전 준비

### 0.1 AWS 계정 준비

#### AWS 계정 생성
1. https://aws.amazon.com 에서 계정 생성
2. 신용카드 등록 (Free Tier 사용 가능)
3. MFA(다중 인증) 설정 권장

#### IAM 사용자 생성 (보안 강화)

**Root 계정 직접 사용 금지!**

1. **AWS Console → IAM → Users → Create user**
2. **User name**: `bibleai-admin`
3. **Access type**:
   - AWS Management Console access
   - Programmatic access
4. **Permissions**: `AdministratorAccess` (개발 단계)
5. **Access Key 저장** (나중에 CLI 사용)

### 0.2 로컬 환경 준비

```bash
# AWS CLI 설치
# macOS
brew install awscli

# Ubuntu
sudo apt install awscli

# AWS CLI 구성
aws configure
# Access Key ID: [IAM 사용자 Access Key]
# Secret Access Key: [IAM 사용자 Secret Key]
# Region: ap-northeast-2 (서울)
# Output format: json

# SSH 키페어 생성 (로컬)
ssh-keygen -t rsa -b 4096 -f ~/.ssh/bibleai-ec2-key
# 비밀번호는 선택사항
```

### 0.3 프로젝트 GitHub 준비

```bash
# 로컬에서 최신 코드 커밋
cd /workspace/bibleai
git add .
git commit -m "Prepare for EC2 deployment"
git push origin main
```

---

## 📋 Phase 1: EC2 인스턴스 생성

### 1.1 EC2 키페어 등록

```bash
# 로컬 공개키를 AWS에 등록
aws ec2 import-key-pair \
  --key-name "bibleai-ec2-key" \
  --public-key-material fileb://~/.ssh/bibleai-ec2-key.pub \
  --region ap-northeast-2
```

**또는 AWS Console에서**:
1. EC2 → Key Pairs → Import key pair
2. Name: `bibleai-ec2-key`
3. Public key 내용 붙여넣기 (`cat ~/.ssh/bibleai-ec2-key.pub`)

### 1.2 Security Group 생성

```bash
# VPC ID 확인
VPC_ID=$(aws ec2 describe-vpcs --filters "Name=isDefault,Values=true" \
  --query "Vpcs[0].VpcId" --output text)

# EC2 Security Group 생성
EC2_SG_ID=$(aws ec2 create-security-group \
  --group-name bibleai-ec2-sg \
  --description "Security group for BibleAI EC2 instance" \
  --vpc-id $VPC_ID \
  --query 'GroupId' --output text)

echo "EC2 Security Group ID: $EC2_SG_ID"

# SSH 접근 허용 (내 IP만)
MY_IP=$(curl -s https://checkip.amazonaws.com)
aws ec2 authorize-security-group-ingress \
  --group-id $EC2_SG_ID \
  --protocol tcp \
  --port 22 \
  --cidr $MY_IP/32

# HTTP 접근 허용 (모든 IP)
aws ec2 authorize-security-group-ingress \
  --group-id $EC2_SG_ID \
  --protocol tcp \
  --port 80 \
  --cidr 0.0.0.0/0

# HTTPS 접근 허용 (모든 IP, 향후 사용)
aws ec2 authorize-security-group-ingress \
  --group-id $EC2_SG_ID \
  --protocol tcp \
  --port 443 \
  --cidr 0.0.0.0/0

# 애플리케이션 포트 (8080, 테스트용)
aws ec2 authorize-security-group-ingress \
  --group-id $EC2_SG_ID \
  --protocol tcp \
  --port 8080 \
  --cidr $MY_IP/32
```

### 1.3 IAM 역할 생성 (Parameter Store 접근)

#### Trust Policy 파일 생성

```bash
cat > ec2-trust-policy.json <<'EOF'
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
```

#### IAM 역할 생성

```bash
# IAM 역할 생성
aws iam create-role \
  --role-name BibleAI-EC2-Role \
  --assume-role-policy-document file://ec2-trust-policy.json

# Parameter Store 접근 정책 생성
cat > parameter-store-policy.json <<'EOF'
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ssm:GetParameter",
        "ssm:GetParameters",
        "ssm:GetParametersByPath"
      ],
      "Resource": "arn:aws:ssm:ap-northeast-2:*:parameter/bibleai/*"
    }
  ]
}
EOF

# 정책을 역할에 연결
aws iam put-role-policy \
  --role-name BibleAI-EC2-Role \
  --policy-name BibleAI-ParameterStore-Policy \
  --policy-document file://parameter-store-policy.json

# Instance Profile 생성 (EC2에 역할 부여용)
aws iam create-instance-profile \
  --instance-profile-name BibleAI-EC2-InstanceProfile

# 역할을 Instance Profile에 추가
aws iam add-role-to-instance-profile \
  --instance-profile-name BibleAI-EC2-InstanceProfile \
  --role-name BibleAI-EC2-Role
```

### 1.4 EC2 인스턴스 생성

```bash
# Amazon Linux 2023 최신 AMI 찾기
AMI_ID=$(aws ec2 describe-images \
  --owners amazon \
  --filters "Name=name,Values=al2023-ami-*-x86_64" "Name=state,Values=available" \
  --query "sort_by(Images, &CreationDate)[-1].ImageId" \
  --output text)

echo "AMI ID: $AMI_ID"

# EC2 인스턴스 생성
INSTANCE_ID=$(aws ec2 run-instances \
  --image-id $AMI_ID \
  --instance-type t3.micro \
  --key-name bibleai-ec2-key \
  --security-group-ids $EC2_SG_ID \
  --iam-instance-profile Name=BibleAI-EC2-InstanceProfile \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=bibleai-server}]' \
  --block-device-mappings '[{"DeviceName":"/dev/xvda","Ebs":{"VolumeSize":20,"VolumeType":"gp3"}}]' \
  --query 'Instances[0].InstanceId' \
  --output text)

echo "Instance ID: $INSTANCE_ID"

# 인스턴스 시작 대기
aws ec2 wait instance-running --instance-ids $INSTANCE_ID
echo "✅ EC2 인스턴스 시작 완료"
```

### 1.5 Elastic IP 할당

```bash
# Elastic IP 생성
ALLOCATION_ID=$(aws ec2 allocate-address \
  --domain vpc \
  --query 'AllocationId' \
  --output text)

# EC2 인스턴스에 연결
aws ec2 associate-address \
  --instance-id $INSTANCE_ID \
  --allocation-id $ALLOCATION_ID

# 공인 IP 확인
PUBLIC_IP=$(aws ec2 describe-addresses \
  --allocation-ids $ALLOCATION_ID \
  --query 'Addresses[0].PublicIp' \
  --output text)

echo "✅ Elastic IP: $PUBLIC_IP"
```

### 1.6 SSH 접속 테스트

```bash
# SSH 접속
ssh -i ~/.ssh/bibleai-ec2-key ec2-user@$PUBLIC_IP

# 접속 성공 시:
# [ec2-user@ip-xxx-xxx-xxx-xxx ~]$

# 시스템 정보 확인
uname -a
cat /etc/os-release
```

---

## 📋 Phase 2: RDS PostgreSQL 생성

### 2.1 RDS Security Group 생성

```bash
# RDS Security Group 생성
RDS_SG_ID=$(aws ec2 create-security-group \
  --group-name bibleai-rds-sg \
  --description "Security group for BibleAI RDS instance" \
  --vpc-id $VPC_ID \
  --query 'GroupId' --output text)

echo "RDS Security Group ID: $RDS_SG_ID"

# EC2에서 RDS 접근 허용
aws ec2 authorize-security-group-ingress \
  --group-id $RDS_SG_ID \
  --protocol tcp \
  --port 5432 \
  --source-group $EC2_SG_ID

# 로컬에서 RDS 접근 허용 (관리용)
aws ec2 authorize-security-group-ingress \
  --group-id $RDS_SG_ID \
  --protocol tcp \
  --port 5432 \
  --cidr $MY_IP/32
```

### 2.2 RDS 인스턴스 생성

```bash
# RDS 마스터 비밀번호 생성 (안전한 비밀번호)
RDS_PASSWORD=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-25)
echo "RDS Master Password: $RDS_PASSWORD"
echo "⚠️  이 비밀번호를 안전하게 저장하세요!"

# RDS 인스턴스 생성
aws rds create-db-instance \
  --db-instance-identifier bibleai-db \
  --db-instance-class db.t4g.micro \
  --engine postgres \
  --engine-version 16.4 \
  --master-username bibleai \
  --master-user-password "$RDS_PASSWORD" \
  --allocated-storage 20 \
  --storage-type gp2 \
  --storage-encrypted \
  --vpc-security-group-ids $RDS_SG_ID \
  --db-name bibleai \
  --backup-retention-period 7 \
  --preferred-backup-window "03:00-04:00" \
  --preferred-maintenance-window "sun:04:00-sun:05:00" \
  --enable-cloudwatch-logs-exports '["postgresql","upgrade"]' \
  --auto-minor-version-upgrade \
  --publicly-accessible \
  --no-multi-az \
  --tags Key=Name,Value=bibleai-db

echo "✅ RDS 인스턴스 생성 중... (10-15분 소요)"

# RDS 생성 완료 대기
aws rds wait db-instance-available --db-instance-identifier bibleai-db
echo "✅ RDS 인스턴스 생성 완료"
```

### 2.3 RDS 엔드포인트 확인

```bash
# RDS 엔드포인트 조회
RDS_ENDPOINT=$(aws rds describe-db-instances \
  --db-instance-identifier bibleai-db \
  --query "DBInstances[0].Endpoint.Address" \
  --output text)

echo "✅ RDS Endpoint: $RDS_ENDPOINT"
```

### 2.4 로컬에서 RDS 연결 테스트

```bash
# PostgreSQL 클라이언트로 연결
psql -h $RDS_ENDPOINT -U bibleai -d bibleai

# 비밀번호 입력: $RDS_PASSWORD

# 연결 성공 시:
# SSL connection (protocol: TLSv1.3, cipher: TLS_AES_256_GCM_SHA384, compression: off)
# Type "help" for help.
# bibleai=>

# 테이블 생성 테스트
CREATE TABLE test (id SERIAL PRIMARY KEY, name VARCHAR(100));
INSERT INTO test (name) VALUES ('Hello RDS');
SELECT * FROM test;
DROP TABLE test;

# 종료
\q
```

---

## 📋 Phase 3: Parameter Store 설정

### 3.1 데이터베이스 설정 파라미터 생성

```bash
# DB 호스트
aws ssm put-parameter \
  --name "/bibleai/db/host" \
  --value "$RDS_ENDPOINT" \
  --type "String" \
  --description "RDS PostgreSQL endpoint"

# DB 포트
aws ssm put-parameter \
  --name "/bibleai/db/port" \
  --value "5432" \
  --type "String" \
  --description "PostgreSQL port"

# DB 사용자명
aws ssm put-parameter \
  --name "/bibleai/db/username" \
  --value "bibleai" \
  --type "String" \
  --description "Database username"

# DB 비밀번호 (SecureString)
aws ssm put-parameter \
  --name "/bibleai/db/password" \
  --value "$RDS_PASSWORD" \
  --type "SecureString" \
  --description "Database password (encrypted)"

# DB 이름
aws ssm put-parameter \
  --name "/bibleai/db/name" \
  --value "bibleai" \
  --type "String" \
  --description "Database name"

# SSL 모드
aws ssm put-parameter \
  --name "/bibleai/db/sslmode" \
  --value "require" \
  --type "String" \
  --description "PostgreSQL SSL mode"

echo "✅ Parameter Store 설정 완료"
```

### 3.2 파라미터 확인

```bash
# 모든 파라미터 조회 (비밀번호 제외)
aws ssm get-parameters-by-path \
  --path "/bibleai" \
  --query "Parameters[?Name!='/bibleai/db/password'].[Name,Value]" \
  --output table

# 비밀번호 확인 (복호화)
aws ssm get-parameter \
  --name "/bibleai/db/password" \
  --with-decryption \
  --query "Parameter.Value" \
  --output text
```

---

## 📋 Phase 4: EC2 환경 설정

### 4.1 EC2 SSH 접속

```bash
ssh -i ~/.ssh/bibleai-ec2-key ec2-user@$PUBLIC_IP
```

### 4.2 시스템 업데이트

```bash
# 시스템 패키지 업데이트
sudo dnf update -y

# 개발 도구 설치
sudo dnf install -y git wget tar gzip
```

### 4.3 Go 설치

```bash
# Go 1.23.0 다운로드
cd /tmp
wget https://go.dev/dl/go1.23.0.linux-amd64.tar.gz

# 설치
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf go1.23.0.linux-amd64.tar.gz

# 환경 변수 설정
echo 'export PATH=$PATH:/usr/local/go/bin' | sudo tee -a /etc/profile
echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc
source ~/.bashrc

# 버전 확인
go version
# go version go1.23.0 linux/amd64
```

### 4.4 PostgreSQL 클라이언트 설치

```bash
# PostgreSQL 16 클라이언트 설치
sudo dnf install -y postgresql16

# 버전 확인
psql --version
# psql (PostgreSQL) 16.x
```

### 4.5 애플리케이션 디렉토리 생성

```bash
# 애플리케이션 디렉토리 생성
sudo mkdir -p /opt/bibleai
sudo chown ec2-user:ec2-user /opt/bibleai
cd /opt/bibleai
```

---

## 📋 Phase 5: 애플리케이션 배포

### 5.1 GitHub에서 코드 클론

```bash
# Git 사용자 설정 (선택사항)
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"

# 저장소 클론
cd /opt/bibleai
git clone https://github.com/SeanKimMel/bibleai.git .

# 브랜치 확인
git branch
git log --oneline -5
```

### 5.2 Go 의존성 다운로드

```bash
# 의존성 다운로드
go mod download

# 의존성 확인
go mod verify
```

### 5.3 애플리케이션 빌드

```bash
# 빌드
go build -o bibleai ./cmd/server

# 실행 권한 부여
chmod +x bibleai

# 빌드 결과 확인
ls -lh bibleai
# -rwxr-xr-x 1 ec2-user ec2-user 25M Oct  2 10:30 bibleai
```

### 5.4 환경 변수 설정

```bash
# /opt/bibleai/.env 파일 생성 (폴백용)
cat > /opt/bibleai/.env <<'EOF'
# AWS Parameter Store 사용
USE_AWS_PARAMS=true

# 폴백 환경 변수 (Parameter Store 실패 시 사용)
DB_HOST=localhost
DB_PORT=5432
DB_USER=bibleai
DB_PASSWORD=fallback-password
DB_NAME=bibleai
DB_SSLMODE=disable
EOF

# 파일 권한 설정 (보안)
chmod 600 /opt/bibleai/.env
```

### 5.5 수동 실행 테스트

```bash
# 환경 변수 로드 및 실행
export USE_AWS_PARAMS=true
./bibleai

# 예상 로그:
# 🔐 AWS Parameter Store 모드 활성화
# 🔐 AWS Parameter Store에서 DB 설정 로드 중...
# ✅ AWS Parameter Store에서 DB 설정 로드 완료
# 연결 문자열: host=bibleai-db.xxx.rds.amazonaws.com port=5432 ...
# 데이터베이스에 성공적으로 연결되었습니다.
# ...
# 서버가 :8080 포트에서 시작됩니다...

# Ctrl+C로 중지
```

### 5.6 Systemd 서비스 생성

```bash
# Systemd 서비스 파일 생성
sudo tee /etc/systemd/system/bibleai.service > /dev/null <<'EOF'
[Unit]
Description=BibleAI Web Application
After=network.target
Wants=network-online.target

[Service]
Type=simple
User=ec2-user
WorkingDirectory=/opt/bibleai
Environment="USE_AWS_PARAMS=true"
Environment="PATH=/usr/local/go/bin:/usr/bin:/bin"
ExecStart=/opt/bibleai/bibleai
Restart=on-failure
RestartSec=5s

# 로그 설정
StandardOutput=journal
StandardError=journal
SyslogIdentifier=bibleai

# 보안 설정
NoNewPrivileges=true
PrivateTmp=true

[Install]
WantedBy=multi-user.target
EOF

# Systemd 리로드
sudo systemctl daemon-reload

# 서비스 활성화 (부팅 시 자동 시작)
sudo systemctl enable bibleai

# 서비스 시작
sudo systemctl start bibleai

# 상태 확인
sudo systemctl status bibleai

# 로그 확인
sudo journalctl -u bibleai -f
```

### 5.7 애플리케이션 테스트

```bash
# Health check
curl http://localhost:8080/health

# 외부에서 접근 테스트 (로컬 터미널에서)
curl http://$PUBLIC_IP:8080/health

# API 테스트
curl "http://localhost:8080/api/bible/search?q=사랑" | jq '.total'
```

---

## 📋 Phase 6: 데이터 마이그레이션

### 6.1 로컬에서 데이터베이스 백업

```bash
# 로컬 터미널에서 실행
cd /workspace/bibleai

# 전체 데이터 백업
pg_dump -h localhost -U bibleai -d bibleai \
  --no-owner --no-acl \
  -F c -f bibleai_production_backup.dump

# 백업 파일 확인
ls -lh bibleai_production_backup.dump
```

### 6.2 백업 파일을 EC2로 전송

```bash
# SCP로 백업 파일 전송
scp -i ~/.ssh/bibleai-ec2-key \
  bibleai_production_backup.dump \
  ec2-user@$PUBLIC_IP:/tmp/

# 전송 확인
ssh -i ~/.ssh/bibleai-ec2-key ec2-user@$PUBLIC_IP \
  "ls -lh /tmp/bibleai_production_backup.dump"
```

### 6.3 EC2에서 RDS로 복원

```bash
# EC2 SSH 접속
ssh -i ~/.ssh/bibleai-ec2-key ec2-user@$PUBLIC_IP

# RDS 엔드포인트 확인
RDS_ENDPOINT=$(aws ssm get-parameter --name "/bibleai/db/host" --query "Parameter.Value" --output text)
RDS_PASSWORD=$(aws ssm get-parameter --name "/bibleai/db/password" --with-decryption --query "Parameter.Value" --output text)

echo "RDS Endpoint: $RDS_ENDPOINT"

# 복원 실행
export PGPASSWORD=$RDS_PASSWORD
pg_restore -h $RDS_ENDPOINT -U bibleai -d bibleai \
  --no-owner --no-acl \
  -j 4 \
  /tmp/bibleai_production_backup.dump

# 복원 완료 확인
psql -h $RDS_ENDPOINT -U bibleai -d bibleai -c "\dt"

# 데이터 개수 확인
psql -h $RDS_ENDPOINT -U bibleai -d bibleai -c "
SELECT
  'bible_verses' AS table_name, COUNT(*) AS count FROM bible_verses
UNION ALL
SELECT 'hymns', COUNT(*) FROM hymns
UNION ALL
SELECT 'tags', COUNT(*) FROM tags;
"

# 임시 파일 삭제
rm /tmp/bibleai_production_backup.dump
unset PGPASSWORD
```

### 6.4 애플리케이션 재시작 및 확인

```bash
# 서비스 재시작
sudo systemctl restart bibleai

# 로그 확인
sudo journalctl -u bibleai -n 50

# API 테스트
curl "http://localhost:8080/api/bible/search?q=사랑" | jq '.total'
curl "http://localhost:8080/api/hymns/search?q=주님" | jq 'length'
```

---

## 📋 Phase 7: 포트 포워딩 (선택사항)

### 7.1 Nginx 설치 및 설정

```bash
# Nginx 설치
sudo dnf install -y nginx

# Nginx 설정 파일 생성
sudo tee /etc/nginx/conf.d/bibleai.conf > /dev/null <<'EOF'
server {
    listen 80;
    server_name _;

    location / {
        proxy_pass http://localhost:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
EOF

# Nginx 시작
sudo systemctl enable nginx
sudo systemctl start nginx

# 상태 확인
sudo systemctl status nginx
```

### 7.2 외부 접근 테스트

```bash
# 로컬 터미널에서 HTTP(80번 포트) 접근
curl http://$PUBLIC_IP/health

# 브라우저에서 접속
# http://YOUR_PUBLIC_IP
```

---

## 📋 Phase 8: 도메인 및 HTTPS 설정 (향후)

### 8.1 Route 53 도메인 설정

```bash
# Route 53에서 도메인 구입 또는 기존 도메인 연결
# A 레코드 생성: bibleai.yourdomain.com → EC2 Elastic IP
```

### 8.2 Let's Encrypt SSL 인증서

```bash
# Certbot 설치
sudo dnf install -y certbot python3-certbot-nginx

# SSL 인증서 발급
sudo certbot --nginx -d bibleai.yourdomain.com

# 자동 갱신 테스트
sudo certbot renew --dry-run
```

---

## 🔍 모니터링 및 관리

### CloudWatch Logs 에이전트 설치 (선택사항)

```bash
# CloudWatch Agent 설치
sudo dnf install -y amazon-cloudwatch-agent

# 설정 파일 생성
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-config-wizard

# 에이전트 시작
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a fetch-config \
  -m ec2 \
  -s \
  -c file:/opt/aws/amazon-cloudwatch-agent/bin/config.json
```

### 정기 백업 스크립트

```bash
# 백업 스크립트 생성
cat > /opt/bibleai/backup.sh <<'EOF'
#!/bin/bash
BACKUP_DIR=/home/ec2-user/backups
mkdir -p $BACKUP_DIR

RDS_ENDPOINT=$(aws ssm get-parameter --name "/bibleai/db/host" --query "Parameter.Value" --output text)
RDS_PASSWORD=$(aws ssm get-parameter --name "/bibleai/db/password" --with-decryption --query "Parameter.Value" --output text)

export PGPASSWORD=$RDS_PASSWORD
pg_dump -h $RDS_ENDPOINT -U bibleai -d bibleai \
  --no-owner --no-acl \
  -F c -f $BACKUP_DIR/bibleai_$(date +%Y%m%d_%H%M%S).dump

# 7일 이상 된 백업 삭제
find $BACKUP_DIR -name "bibleai_*.dump" -mtime +7 -delete
EOF

chmod +x /opt/bibleai/backup.sh

# Cron 작업 추가 (매일 새벽 3시)
(crontab -l 2>/dev/null; echo "0 3 * * * /opt/bibleai/backup.sh") | crontab -
```

---

## 📋 배포 체크리스트

### 인프라 구축
- [ ] AWS 계정 생성 및 IAM 사용자 설정
- [ ] SSH 키페어 생성 및 등록
- [ ] EC2 Security Group 생성
- [ ] EC2 인스턴스 생성 (t3.micro)
- [ ] Elastic IP 할당
- [ ] IAM 역할 생성 (Parameter Store 접근)
- [ ] RDS Security Group 생성
- [ ] RDS 인스턴스 생성 (db.t4g.micro)
- [ ] Parameter Store 설정 (6개 파라미터)

### 애플리케이션 배포
- [ ] EC2 시스템 업데이트
- [ ] Go 1.23.0 설치
- [ ] PostgreSQL 클라이언트 설치
- [ ] GitHub에서 코드 클론
- [ ] 의존성 다운로드 및 빌드
- [ ] Systemd 서비스 생성
- [ ] 서비스 시작 및 자동 시작 설정
- [ ] Health check 성공

### 데이터 마이그레이션
- [ ] 로컬 DB 백업 생성
- [ ] 백업 파일 EC2로 전송
- [ ] RDS로 데이터 복원
- [ ] 데이터 개수 검증
- [ ] API 테스트 성공

### 보안 및 모니터링
- [ ] Security Group 최소 권한 원칙 적용
- [ ] Parameter Store 비밀번호 암호화 확인
- [ ] RDS 자동 백업 활성화 확인
- [ ] CloudWatch 알림 설정 (선택사항)
- [ ] 정기 백업 스크립트 설정

### 최종 검증
- [ ] 외부에서 HTTP 접근 성공
- [ ] API 전체 테스트 통과
- [ ] 24시간 안정성 모니터링 완료

---

## 💰 예상 비용 (월별)

| 항목 | 사양 | 비용 |
|------|------|------|
| **EC2** | t3.micro (1 vCPU, 1GB RAM) | $7/월 |
| **EBS** | 20GB gp3 | $2/월 |
| **Elastic IP** | 1개 (사용 중) | $0 |
| **RDS** | db.t4g.micro (1GB RAM, 20GB) | $13/월 |
| **데이터 전송** | 1GB/월 (Free Tier) | $0 |
| **Parameter Store** | 표준 파라미터 | $0 |
| **CloudWatch** | 기본 모니터링 | $0 |
| **총 비용** | | **$22/월** |

---

## 🚨 문제 해결

### EC2 SSH 접속 실패

```bash
# Security Group에 내 IP 추가 확인
MY_IP=$(curl -s https://checkip.amazonaws.com)
aws ec2 authorize-security-group-ingress \
  --group-id $EC2_SG_ID \
  --protocol tcp \
  --port 22 \
  --cidr $MY_IP/32

# SSH 키 권한 확인
chmod 600 ~/.ssh/bibleai-ec2-key
```

### RDS 연결 실패

```bash
# Security Group 규칙 확인
aws ec2 describe-security-groups --group-ids $RDS_SG_ID

# RDS 엔드포인트 Ping 테스트
ping bibleai-db.xxx.rds.amazonaws.com

# PostgreSQL 연결 테스트
psql -h $RDS_ENDPOINT -U bibleai -d bibleai
```

### Parameter Store 접근 실패

```bash
# IAM 역할 확인
aws iam get-role --role-name BibleAI-EC2-Role

# EC2 인스턴스에 역할이 연결되었는지 확인
aws ec2 describe-instances --instance-ids $INSTANCE_ID \
  --query "Reservations[0].Instances[0].IamInstanceProfile"

# Parameter Store 접근 테스트
aws ssm get-parameter --name "/bibleai/db/host"
```

---

**작성일**: 2025년 10월 2일
**프로젝트**: 주님말씀AI 웹앱
**목표**: AWS EC2 + RDS 완전 배포
**예상 비용**: $22/월
**예상 소요 시간**: 2-3일
