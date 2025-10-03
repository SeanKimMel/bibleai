# 심플 배포 가이드 (EC2 1대 + RDS 1대)

## 🎯 철학: Keep It Simple

**복잡한 것은 나중에, 지금은 단순하게!**

```
불필요한 것들:
❌ 개발/스테이징/프로덕션 환경 분리
❌ 개발 DB / 운영 DB 분리
❌ Load Balancer, Auto Scaling
❌ Docker, Kubernetes
❌ CI/CD 파이프라인

필요한 것들:
✅ EC2 1대 (애플리케이션)
✅ RDS 1대 (데이터베이스)
✅ Git (배포 도구)
✅ Systemd (프로세스 관리)
```

---

## 🏗️ 최종 아키텍처

```
[사용자]
   ↓ HTTP/HTTPS
[EC2 인스턴스 1대]
├── Nginx (80/443 포트)
├── Go 애플리케이션 (8080 포트)
└── Parameter Store 연결
   ↓
[RDS PostgreSQL 1대]
└── 운영 데이터 (백업 자동)

비용: $22/월
유지보수: 주 1회, 10분
```

---

## 📋 1단계: AWS 인프라 구축 (1시간)

### 1.1 사전 준비

```bash
# AWS CLI 설치
brew install awscli  # macOS

# AWS 설정
aws configure
# Access Key ID: [입력]
# Secret Access Key: [입력]
# Region: ap-northeast-2
# Output: json

# 환경 변수 저장
export AWS_REGION=ap-northeast-2
export MY_IP=$(curl -s https://checkip.amazonaws.com)
echo "My IP: $MY_IP"
```

### 1.2 EC2 + RDS 한 번에 생성 스크립트

**`setup-aws.sh` 스크립트 생성**:

```bash
#!/bin/bash
set -e

echo "========================================="
echo "BibleAI AWS 인프라 구축"
echo "========================================="
echo ""

# 변수 설정
REGION="ap-northeast-2"
KEY_NAME="bibleai-key"
EC2_SG_NAME="bibleai-ec2-sg"
RDS_SG_NAME="bibleai-rds-sg"
EC2_INSTANCE_TYPE="t3.micro"
RDS_INSTANCE_TYPE="db.t4g.micro"
RDS_PASSWORD=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-25)

# VPC ID 가져오기
echo "1️⃣  Default VPC 확인 중..."
VPC_ID=$(aws ec2 describe-vpcs --filters "Name=isDefault,Values=true" \
  --query "Vpcs[0].VpcId" --output text --region $REGION)
echo "   VPC ID: $VPC_ID"

# SSH 키페어 생성
echo ""
echo "2️⃣  SSH 키페어 생성 중..."
if [ ! -f ~/.ssh/${KEY_NAME} ]; then
    ssh-keygen -t rsa -b 4096 -f ~/.ssh/${KEY_NAME} -N ""
    aws ec2 import-key-pair \
      --key-name "$KEY_NAME" \
      --public-key-material fileb://~/.ssh/${KEY_NAME}.pub \
      --region $REGION
    echo "   ✅ SSH 키페어 생성 완료"
else
    echo "   ℹ️  SSH 키페어 이미 존재"
fi

# EC2 Security Group 생성
echo ""
echo "3️⃣  EC2 Security Group 생성 중..."
EC2_SG_ID=$(aws ec2 create-security-group \
  --group-name $EC2_SG_NAME \
  --description "BibleAI EC2 Security Group" \
  --vpc-id $VPC_ID \
  --query 'GroupId' --output text --region $REGION)

# EC2 인바운드 규칙
MY_IP=$(curl -s https://checkip.amazonaws.com)
aws ec2 authorize-security-group-ingress --group-id $EC2_SG_ID --protocol tcp --port 22 --cidr $MY_IP/32 --region $REGION
aws ec2 authorize-security-group-ingress --group-id $EC2_SG_ID --protocol tcp --port 80 --cidr 0.0.0.0/0 --region $REGION
aws ec2 authorize-security-group-ingress --group-id $EC2_SG_ID --protocol tcp --port 443 --cidr 0.0.0.0/0 --region $REGION
aws ec2 authorize-security-group-ingress --group-id $EC2_SG_ID --protocol tcp --port 8080 --cidr $MY_IP/32 --region $REGION
echo "   EC2 Security Group ID: $EC2_SG_ID"

# IAM 역할 생성
echo ""
echo "4️⃣  IAM 역할 생성 중..."
cat > /tmp/ec2-trust-policy.json <<'EOF'
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Principal": {"Service": "ec2.amazonaws.com"},
    "Action": "sts:AssumeRole"
  }]
}
EOF

aws iam create-role \
  --role-name BibleAI-EC2-Role \
  --assume-role-policy-document file:///tmp/ec2-trust-policy.json 2>/dev/null || true

cat > /tmp/parameter-store-policy.json <<EOF
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Action": ["ssm:GetParameter", "ssm:GetParameters", "ssm:GetParametersByPath"],
    "Resource": "arn:aws:ssm:${REGION}:*:parameter/bibleai/*"
  }]
}
EOF

aws iam put-role-policy \
  --role-name BibleAI-EC2-Role \
  --policy-name BibleAI-ParameterStore-Policy \
  --policy-document file:///tmp/parameter-store-policy.json

aws iam create-instance-profile \
  --instance-profile-name BibleAI-EC2-InstanceProfile 2>/dev/null || true

aws iam add-role-to-instance-profile \
  --instance-profile-name BibleAI-EC2-InstanceProfile \
  --role-name BibleAI-EC2-Role 2>/dev/null || true

echo "   ✅ IAM 역할 생성 완료"
sleep 10  # IAM 역할 전파 대기

# EC2 인스턴스 생성
echo ""
echo "5️⃣  EC2 인스턴스 생성 중..."
AMI_ID=$(aws ec2 describe-images \
  --owners amazon \
  --filters "Name=name,Values=al2023-ami-*-x86_64" "Name=state,Values=available" \
  --query "sort_by(Images, &CreationDate)[-1].ImageId" \
  --output text --region $REGION)

INSTANCE_ID=$(aws ec2 run-instances \
  --image-id $AMI_ID \
  --instance-type $EC2_INSTANCE_TYPE \
  --key-name $KEY_NAME \
  --security-group-ids $EC2_SG_ID \
  --iam-instance-profile Name=BibleAI-EC2-InstanceProfile \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=bibleai-server}]' \
  --block-device-mappings '[{"DeviceName":"/dev/xvda","Ebs":{"VolumeSize":20,"VolumeType":"gp3"}}]' \
  --query 'Instances[0].InstanceId' \
  --output text --region $REGION)

echo "   Instance ID: $INSTANCE_ID"
echo "   ⏳ EC2 인스턴스 시작 대기 중..."
aws ec2 wait instance-running --instance-ids $INSTANCE_ID --region $REGION
echo "   ✅ EC2 인스턴스 시작 완료"

# Elastic IP 할당
echo ""
echo "6️⃣  Elastic IP 할당 중..."
ALLOCATION_ID=$(aws ec2 allocate-address --domain vpc --query 'AllocationId' --output text --region $REGION)
aws ec2 associate-address --instance-id $INSTANCE_ID --allocation-id $ALLOCATION_ID --region $REGION
PUBLIC_IP=$(aws ec2 describe-addresses --allocation-ids $ALLOCATION_ID --query 'Addresses[0].PublicIp' --output text --region $REGION)
echo "   ✅ Elastic IP: $PUBLIC_IP"

# RDS Security Group 생성
echo ""
echo "7️⃣  RDS Security Group 생성 중..."
RDS_SG_ID=$(aws ec2 create-security-group \
  --group-name $RDS_SG_NAME \
  --description "BibleAI RDS Security Group" \
  --vpc-id $VPC_ID \
  --query 'GroupId' --output text --region $REGION)

aws ec2 authorize-security-group-ingress --group-id $RDS_SG_ID --protocol tcp --port 5432 --source-group $EC2_SG_ID --region $REGION
aws ec2 authorize-security-group-ingress --group-id $RDS_SG_ID --protocol tcp --port 5432 --cidr $MY_IP/32 --region $REGION
echo "   RDS Security Group ID: $RDS_SG_ID"

# RDS 인스턴스 생성
echo ""
echo "8️⃣  RDS 인스턴스 생성 중..."
echo "   RDS Master Password: $RDS_PASSWORD"
echo "   ⚠️  이 비밀번호를 안전하게 저장하세요!"

aws rds create-db-instance \
  --db-instance-identifier bibleai-db \
  --db-instance-class $RDS_INSTANCE_TYPE \
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
  --publicly-accessible \
  --no-multi-az \
  --region $REGION \
  --tags Key=Name,Value=bibleai-db

echo "   ⏳ RDS 인스턴스 생성 대기 중... (10-15분 소요)"
aws rds wait db-instance-available --db-instance-identifier bibleai-db --region $REGION
echo "   ✅ RDS 인스턴스 생성 완료"

# RDS 엔드포인트 확인
RDS_ENDPOINT=$(aws rds describe-db-instances \
  --db-instance-identifier bibleai-db \
  --query "DBInstances[0].Endpoint.Address" \
  --output text --region $REGION)
echo "   RDS Endpoint: $RDS_ENDPOINT"

# Parameter Store 설정
echo ""
echo "9️⃣  Parameter Store 설정 중..."
aws ssm put-parameter --name "/bibleai/db/host" --value "$RDS_ENDPOINT" --type "String" --region $REGION --overwrite 2>/dev/null || \
  aws ssm put-parameter --name "/bibleai/db/host" --value "$RDS_ENDPOINT" --type "String" --region $REGION
aws ssm put-parameter --name "/bibleai/db/port" --value "5432" --type "String" --region $REGION --overwrite 2>/dev/null || \
  aws ssm put-parameter --name "/bibleai/db/port" --value "5432" --type "String" --region $REGION
aws ssm put-parameter --name "/bibleai/db/username" --value "bibleai" --type "String" --region $REGION --overwrite 2>/dev/null || \
  aws ssm put-parameter --name "/bibleai/db/username" --value "bibleai" --type "String" --region $REGION
aws ssm put-parameter --name "/bibleai/db/password" --value "$RDS_PASSWORD" --type "SecureString" --region $REGION --overwrite 2>/dev/null || \
  aws ssm put-parameter --name "/bibleai/db/password" --value "$RDS_PASSWORD" --type "SecureString" --region $REGION
aws ssm put-parameter --name "/bibleai/db/name" --value "bibleai" --type "String" --region $REGION --overwrite 2>/dev/null || \
  aws ssm put-parameter --name "/bibleai/db/name" --value "bibleai" --type "String" --region $REGION
aws ssm put-parameter --name "/bibleai/db/sslmode" --value "require" --type "String" --region $REGION --overwrite 2>/dev/null || \
  aws ssm put-parameter --name "/bibleai/db/sslmode" --value "require" --type "String" --region $REGION
echo "   ✅ Parameter Store 설정 완료"

# 결과 출력
echo ""
echo "========================================="
echo "✅ AWS 인프라 구축 완료!"
echo "========================================="
echo ""
echo "📋 접속 정보:"
echo "   EC2 Public IP: $PUBLIC_IP"
echo "   RDS Endpoint: $RDS_ENDPOINT"
echo "   SSH 키: ~/.ssh/$KEY_NAME"
echo ""
echo "📝 다음 단계:"
echo "   1. SSH 접속: ssh -i ~/.ssh/$KEY_NAME ec2-user@$PUBLIC_IP"
echo "   2. 애플리케이션 설치 스크립트 실행"
echo ""
echo "💰 예상 비용: 약 $22/월"
echo "   - EC2 t3.micro: $7/월"
echo "   - EBS 20GB: $2/월"
echo "   - RDS db.t4g.micro: $13/월"
echo ""

# 접속 정보 파일로 저장
cat > ~/.bibleai-aws-info <<EOF
EC2_PUBLIC_IP=$PUBLIC_IP
RDS_ENDPOINT=$RDS_ENDPOINT
RDS_PASSWORD=$RDS_PASSWORD
SSH_KEY=~/.ssh/$KEY_NAME
INSTANCE_ID=$INSTANCE_ID
EOF

echo "✅ 접속 정보가 ~/.bibleai-aws-info 에 저장되었습니다."
echo ""
```

**스크립트 실행**:

```bash
# 스크립트 실행 권한 부여
chmod +x setup-aws.sh

# 실행
./setup-aws.sh

# 완료 후 접속 정보 확인
cat ~/.bibleai-aws-info
```

---

## 📋 2단계: 애플리케이션 설치 (30분)

### 2.1 EC2 SSH 접속

```bash
# 저장된 정보 로드
source ~/.bibleai-aws-info

# SSH 접속
ssh -i $SSH_KEY ec2-user@$EC2_PUBLIC_IP
```

### 2.2 자동 설치 스크립트 (EC2에서 실행)

```bash
# 설치 스크립트 생성
cat > /tmp/install-app.sh <<'SCRIPT'
#!/bin/bash
set -e

echo "========================================="
echo "BibleAI 애플리케이션 설치"
echo "========================================="

# 1. 시스템 업데이트
echo ""
echo "1️⃣  시스템 업데이트 중..."
sudo dnf update -y
sudo dnf install -y git wget postgresql16

# 2. Go 설치
echo ""
echo "2️⃣  Go 설치 중..."
cd /tmp
wget -q https://go.dev/dl/go1.23.0.linux-amd64.tar.gz
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf go1.23.0.linux-amd64.tar.gz
echo 'export PATH=$PATH:/usr/local/go/bin' | sudo tee -a /etc/profile
echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc
source ~/.bashrc
export PATH=$PATH:/usr/local/go/bin
go version

# 3. 애플리케이션 디렉토리 생성
echo ""
echo "3️⃣  애플리케이션 디렉토리 생성 중..."
sudo mkdir -p /opt/bibleai
sudo chown ec2-user:ec2-user /opt/bibleai

# 4. GitHub에서 코드 클론
echo ""
echo "4️⃣  GitHub에서 코드 클론 중..."
cd /opt/bibleai
git clone https://github.com/SeanKimMel/bibleai.git .

# 5. 빌드
echo ""
echo "5️⃣  애플리케이션 빌드 중..."
go mod download
go build -o bibleai ./cmd/server
chmod +x bibleai

# 6. Systemd 서비스 생성
echo ""
echo "6️⃣  Systemd 서비스 생성 중..."
sudo tee /etc/systemd/system/bibleai.service > /dev/null <<'EOF'
[Unit]
Description=BibleAI Web Application
After=network.target

[Service]
Type=simple
User=ec2-user
WorkingDirectory=/opt/bibleai
Environment="USE_AWS_PARAMS=true"
Environment="PATH=/usr/local/go/bin:/usr/bin:/bin"
ExecStart=/opt/bibleai/bibleai
Restart=on-failure
RestartSec=5s
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable bibleai
sudo systemctl start bibleai

# 7. Nginx 설치 및 설정
echo ""
echo "7️⃣  Nginx 설치 및 설정 중..."
sudo dnf install -y nginx

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

sudo systemctl enable nginx
sudo systemctl start nginx

echo ""
echo "========================================="
echo "✅ 애플리케이션 설치 완료!"
echo "========================================="
echo ""
echo "📋 상태 확인:"
sudo systemctl status bibleai --no-pager
echo ""
echo "🌐 접속 테스트:"
echo "   curl http://localhost:8080/health"
echo ""

SCRIPT

# 실행
bash /tmp/install-app.sh
```

### 2.3 상태 확인

```bash
# 서비스 상태
sudo systemctl status bibleai

# 로그 확인
sudo journalctl -u bibleai -f

# Health check
curl http://localhost:8080/health

# 외부 접속 테스트 (로컬 터미널에서)
curl http://$EC2_PUBLIC_IP/health
```

---

## 📋 3단계: 데이터 마이그레이션 (30분)

### 3.1 로컬에서 백업

```bash
# 로컬 터미널에서
cd /workspace/bibleai
pg_dump -h localhost -U bibleai -d bibleai \
  --no-owner --no-acl \
  -F c -f bibleai_backup.dump
```

### 3.2 EC2로 전송 및 복원

```bash
# 백업 파일 전송
source ~/.bibleai-aws-info
scp -i $SSH_KEY bibleai_backup.dump ec2-user@$EC2_PUBLIC_IP:/tmp/

# EC2에서 복원
ssh -i $SSH_KEY ec2-user@$EC2_PUBLIC_IP << 'ENDSSH'
RDS_ENDPOINT=$(aws ssm get-parameter --name "/bibleai/db/host" --query "Parameter.Value" --output text --region ap-northeast-2)
RDS_PASSWORD=$(aws ssm get-parameter --name "/bibleai/db/password" --with-decryption --query "Parameter.Value" --output text --region ap-northeast-2)

export PGPASSWORD=$RDS_PASSWORD
pg_restore -h $RDS_ENDPOINT -U bibleai -d bibleai \
  --no-owner --no-acl -j 4 \
  /tmp/bibleai_backup.dump

# 데이터 확인
psql -h $RDS_ENDPOINT -U bibleai -d bibleai -c "
SELECT
  'bible_verses' AS table_name, COUNT(*) AS count FROM bible_verses
UNION ALL
SELECT 'hymns', COUNT(*) FROM hymns;
"

rm /tmp/bibleai_backup.dump
ENDSSH

# 애플리케이션 재시작
ssh -i $SSH_KEY ec2-user@$EC2_PUBLIC_IP "sudo systemctl restart bibleai"
```

---

## 🚀 일상 배포 (3분 컷)

### 로컬에서 개발 완료 후

```bash
# 1. 커밋 & 푸시
git add .
git commit -m "Add new feature"
git push origin main

# 2. EC2 SSH 접속
source ~/.bibleai-aws-info
ssh -i $SSH_KEY ec2-user@$EC2_PUBLIC_IP

# 3. 배포 (EC2에서)
cd /opt/bibleai
git pull origin main
go build -o bibleai ./cmd/server
sudo systemctl restart bibleai

# 4. 확인
sudo journalctl -u bibleai -n 20
curl http://localhost:8080/health

# 끝!
```

### 원라이너 배포 스크립트

```bash
# 로컬에서 한 줄로 배포
source ~/.bibleai-aws-info && \
  ssh -i $SSH_KEY ec2-user@$EC2_PUBLIC_IP \
  "cd /opt/bibleai && git pull && go build -o bibleai ./cmd/server && sudo systemctl restart bibleai && sleep 2 && curl http://localhost:8080/health"
```

---

## 🛠️ 관리 명령어

### 서비스 관리

```bash
# 시작
sudo systemctl start bibleai

# 중지
sudo systemctl stop bibleai

# 재시작
sudo systemctl restart bibleai

# 상태 확인
sudo systemctl status bibleai

# 로그 실시간 보기
sudo journalctl -u bibleai -f

# 최근 로그 100줄
sudo journalctl -u bibleai -n 100
```

### DB 관리

```bash
# RDS 접속
RDS_ENDPOINT=$(aws ssm get-parameter --name "/bibleai/db/host" --query "Parameter.Value" --output text --region ap-northeast-2)
RDS_PASSWORD=$(aws ssm get-parameter --name "/bibleai/db/password" --with-decryption --query "Parameter.Value" --output text --region ap-northeast-2)

export PGPASSWORD=$RDS_PASSWORD
psql -h $RDS_ENDPOINT -U bibleai -d bibleai

# 백업
pg_dump -h $RDS_ENDPOINT -U bibleai -d bibleai -F c -f ~/backup_$(date +%Y%m%d).dump
```

---

## 💰 비용 요약

| 항목 | 사양 | 월 비용 |
|------|------|---------|
| EC2 | t3.micro | $7 |
| EBS | 20GB gp3 | $2 |
| Elastic IP | 사용 중 | $0 |
| RDS | db.t4g.micro | $13 |
| **합계** | | **$22/월** |

---

## 🔥 인프라 삭제 (프로젝트 종료 시)

```bash
#!/bin/bash

echo "⚠️  모든 AWS 리소스를 삭제합니다!"
read -p "계속하시겠습니까? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
  echo "취소되었습니다."
  exit 1
fi

REGION="ap-northeast-2"

# RDS 삭제
aws rds delete-db-instance \
  --db-instance-identifier bibleai-db \
  --skip-final-snapshot \
  --region $REGION

# EC2 인스턴스 삭제
source ~/.bibleai-aws-info
aws ec2 terminate-instances --instance-ids $INSTANCE_ID --region $REGION

# Elastic IP 해제
ALLOCATION_ID=$(aws ec2 describe-addresses \
  --filters "Name=public-ip,Values=$EC2_PUBLIC_IP" \
  --query "Addresses[0].AllocationId" --output text --region $REGION)
aws ec2 release-address --allocation-id $ALLOCATION_ID --region $REGION

# Security Groups 삭제 (EC2/RDS 종료 후)
sleep 60
aws ec2 delete-security-group --group-name bibleai-rds-sg --region $REGION
aws ec2 delete-security-group --group-name bibleai-ec2-sg --region $REGION

# IAM 역할 삭제
aws iam remove-role-from-instance-profile \
  --instance-profile-name BibleAI-EC2-InstanceProfile \
  --role-name BibleAI-EC2-Role
aws iam delete-instance-profile --instance-profile-name BibleAI-EC2-InstanceProfile
aws iam delete-role-policy --role-name BibleAI-EC2-Role --policy-name BibleAI-ParameterStore-Policy
aws iam delete-role --role-name BibleAI-EC2-Role

# Parameter Store 삭제
aws ssm delete-parameter --name "/bibleai/db/host" --region $REGION
aws ssm delete-parameter --name "/bibleai/db/port" --region $REGION
aws ssm delete-parameter --name "/bibleai/db/username" --region $REGION
aws ssm delete-parameter --name "/bibleai/db/password" --region $REGION
aws ssm delete-parameter --name "/bibleai/db/name" --region $REGION
aws ssm delete-parameter --name "/bibleai/db/sslmode" --region $REGION

echo "✅ 모든 리소스가 삭제되었습니다."
```

---

**작성일**: 2025년 10월 3일
**철학**: Keep It Simple
**비용**: $22/월
**배포 시간**: 3분
