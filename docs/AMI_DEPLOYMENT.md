# AWS AMI 골든 이미지 배포 전략

## 🎯 개요

Docker 대신 AWS AMI(Amazon Machine Image) 골든 이미지를 사용한 네이티브 배포 전략입니다.

## 💡 왜 AMI 방식인가?

### Docker vs AMI 비교

| 항목 | Docker | AMI 골든 이미지 | 우위 |
|-----|--------|----------------|------|
| **배포 속도** | 2-3분 | 30초 | AMI |
| **메모리 오버헤드** | ~100MB | 0MB | AMI |
| **복잡도** | 높음 | 낮음 | AMI |
| **AWS 통합** | 보통 | 완벽 | AMI |
| **환경 격리** | 높음 | 중간 | Docker |
| **롤백** | 이미지 전환 | 이미지 전환 | 동일 |
| **확장** | 좋음 | 매우 좋음 | AMI |
| **비용** | t3.small 필요 | t3.micro 충분 | AMI |

### 🏆 AMI 방식이 우수한 이유

1. **AWS 네이티브**: EC2, Auto Scaling과 완벽 통합
2. **제로 오버헤드**: Docker 런타임 불필요
3. **빠른 배포**: 인스턴스 시작 = 배포 완료
4. **간단한 관리**: AWS Console에서 클릭 몇 번
5. **비용 효율**: 작은 인스턴스 사용 가능

---

## 📋 골든 이미지 배포 전략

### Phase 1: 기본 AMI 생성 (1회)

#### 1. EC2 인스턴스 초기 설정

```bash
#!/bin/bash
# setup-base-ami.sh

# 시스템 업데이트
sudo yum update -y

# Go 설치
wget https://go.dev/dl/go1.23.0.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go1.23.0.linux-amd64.tar.gz
echo 'export PATH=$PATH:/usr/local/go/bin' | sudo tee -a /etc/profile
source /etc/profile

# PostgreSQL 설치
sudo yum install -y postgresql16 postgresql16-server
sudo postgresql-setup --initdb
sudo systemctl enable postgresql
sudo systemctl start postgresql

# Git 설치
sudo yum install -y git

# 필요한 디렉토리 생성
sudo mkdir -p /opt/bibleai
sudo chown ec2-user:ec2-user /opt/bibleai

echo "✅ 기본 환경 설정 완료"
```

#### 2. 애플리케이션 설치

```bash
#!/bin/bash
# install-app.sh

cd /opt/bibleai

# 저장소 클론
git clone https://github.com/SeanKimMel/bibleai.git .

# 의존성 다운로드
go mod download

# 바이너리 빌드
go build -o bibleai ./cmd/server

# 실행 권한
chmod +x bibleai server.sh

# DB 초기화 (Parameter Store에서 자동으로 비밀번호 가져옴)
./development-only/init-db.sh

echo "✅ 애플리케이션 설치 완료"
```

#### 3. Systemd 서비스 생성

```bash
# /etc/systemd/system/bibleai.service
[Unit]
Description=BibleAI Web Application
After=network.target postgresql.service
Wants=postgresql.service

[Service]
Type=simple
User=ec2-user
WorkingDirectory=/opt/bibleai
Environment="USE_AWS_PARAMS=true"
Environment="PATH=/usr/local/go/bin:/usr/bin:/bin"
ExecStart=/opt/bibleai/bibleai
Restart=on-failure
RestartSec=5s

[Install]
WantedBy=multi-user.target
```

```bash
# 서비스 활성화
sudo systemctl daemon-reload
sudo systemctl enable bibleai
sudo systemctl start bibleai

# 상태 확인
sudo systemctl status bibleai
```

#### 4. AMI 생성

**AWS Console:**
1. EC2 → Instances → 인스턴스 선택
2. Actions → Image and templates → Create image
3. Image name: `bibleai-golden-v1.0`
4. Description: `BibleAI production-ready image with Go, PostgreSQL, and app`
5. Create image

**AWS CLI:**
```bash
aws ec2 create-image \
  --instance-id i-1234567890abcdef0 \
  --name "bibleai-golden-v1.0" \
  --description "BibleAI production-ready image" \
  --no-reboot
```

---

### Phase 2: 배포 전략

#### A. 새 버전 배포 (Rolling Update)

```bash
#!/bin/bash
# deploy-new-version.sh

VERSION="v1.1"
AMI_ID="ami-xyz123"  # 현재 골든 이미지

# 1. 새 인스턴스 시작
NEW_INSTANCE=$(aws ec2 run-instances \
  --image-id $AMI_ID \
  --instance-type t3.micro \
  --key-name your-key \
  --security-group-ids sg-xxx \
  --user-data '#!/bin/bash
cd /opt/bibleai
git pull origin main
go build -o bibleai ./cmd/server
sudo systemctl restart bibleai' \
  --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=bibleai-$VERSION}]" \
  --query 'Instances[0].InstanceId' \
  --output text)

echo "새 인스턴스 시작: $NEW_INSTANCE"

# 2. 인스턴스 준비 대기
aws ec2 wait instance-running --instance-ids $NEW_INSTANCE

# 3. Health check
sleep 30
PUBLIC_IP=$(aws ec2 describe-instances --instance-ids $NEW_INSTANCE --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)
curl -f http://$PUBLIC_IP:8080/health

if [ $? -eq 0 ]; then
  echo "✅ 새 인스턴스 정상 작동"
  # 4. Load Balancer에 추가 (선택사항)
  # aws elbv2 register-targets ...

  # 5. 기존 인스턴스 종료 (선택사항)
  # aws ec2 terminate-instances --instance-ids $OLD_INSTANCE
else
  echo "❌ Health check 실패, 롤백"
  aws ec2 terminate-instances --instance-ids $NEW_INSTANCE
  exit 1
fi
```

#### B. 즉시 배포 (In-place Update)

```bash
#!/bin/bash
# update-existing.sh

# 기존 인스턴스에서 실행
cd /opt/bibleai
git pull origin main
go build -o bibleai ./cmd/server
sudo systemctl restart bibleai

# Health check
sleep 5
curl -f http://localhost:8080/health && echo "✅ 배포 성공" || echo "❌ 배포 실패"
```

#### C. 롤백

```bash
# 방법 1: 이전 AMI로 새 인스턴스 시작
aws ec2 run-instances \
  --image-id ami-old-version \
  --instance-type t3.micro \
  ...

# 방법 2: Git 커밋 롤백
cd /opt/bibleai
git checkout v1.0
go build -o bibleai ./cmd/server
sudo systemctl restart bibleai
```

---

### Phase 3: Auto Scaling (확장성)

#### Launch Template 생성

```bash
aws ec2 create-launch-template \
  --launch-template-name bibleai-template \
  --version-description "BibleAI v1.0" \
  --launch-template-data '{
    "ImageId": "ami-golden-v1.0",
    "InstanceType": "t3.micro",
    "KeyName": "your-key",
    "SecurityGroupIds": ["sg-xxx"],
    "UserData": "IyEvYmluL2Jhc2gKc3VkbyBzeXN0ZW1jdGwgc3RhcnQgYmlibGVhaQ==",
    "TagSpecifications": [{
      "ResourceType": "instance",
      "Tags": [{"Key": "Name", "Value": "bibleai-auto"}]
    }]
  }'
```

#### Auto Scaling Group 생성

```bash
aws autoscaling create-auto-scaling-group \
  --auto-scaling-group-name bibleai-asg \
  --launch-template LaunchTemplateName=bibleai-template \
  --min-size 1 \
  --max-size 5 \
  --desired-capacity 1 \
  --availability-zones ap-northeast-2a ap-northeast-2c \
  --health-check-type ELB \
  --health-check-grace-period 300
```

---

## 🔄 버전 관리 전략

### AMI 버전 네이밍

```
bibleai-golden-v1.0  (초기)
bibleai-golden-v1.1  (기능 추가)
bibleai-golden-v1.2  (버그 수정)
bibleai-golden-v2.0  (메이저 업데이트)
```

### 태그 전략

```json
{
  "Name": "bibleai-golden-v1.0",
  "Version": "1.0.0",
  "Environment": "production",
  "Created": "2025-10-02",
  "Go": "1.23.0",
  "PostgreSQL": "16"
}
```

---

## 📊 비용 비교

### 시나리오: 사용자 1,000명/일

**Docker 방식:**
```
EC2: t3.small ($14/월)
메모리: 2GB 필요 (Docker 오버헤드)
총 비용: $14/월
```

**AMI 방식:**
```
EC2: t3.micro ($7/월)
메모리: 1GB 충분
총 비용: $7/월
```

**절감: 50%** 💰

---

## 🛠️ 유지보수

### 정기 AMI 업데이트 (월 1회)

```bash
#!/bin/bash
# monthly-ami-update.sh

# 1. 새 인스턴스 시작 (최신 골든 이미지)
# 2. 시스템 업데이트
sudo yum update -y

# 3. 애플리케이션 업데이트
cd /opt/bibleai
git pull
go build -o bibleai ./cmd/server

# 4. 테스트
sudo systemctl restart bibleai
curl -f http://localhost:8080/health

# 5. 새 AMI 생성
aws ec2 create-image \
  --instance-id $(ec2-metadata --instance-id | cut -d ' ' -f 2) \
  --name "bibleai-golden-v1.$(date +%Y%m)" \
  --description "Monthly update $(date +%Y-%m-%d)"

# 6. 기존 인스턴스 종료
```

---

## 🚨 장애 대응

### 1. 인스턴스 장애

```bash
# Auto Scaling이 자동으로 새 인스턴스 시작
# 또는 수동으로:
aws ec2 run-instances --image-id ami-golden-latest ...
```

### 2. 배포 실패

```bash
# 이전 버전 AMI로 롤백
aws ec2 run-instances --image-id ami-golden-v1.0 ...
```

### 3. DB 문제

```bash
# RDS로 전환 (권장)
# 또는 DB 백업 복구
pg_restore -U bibleai -d bibleai backup.sql
```

---

## ✅ 배포 체크리스트

### 골든 AMI 생성 시
- [ ] 시스템 패키지 최신화
- [ ] Go 버전 확인
- [ ] PostgreSQL 설정 확인
- [ ] 애플리케이션 빌드 성공
- [ ] Systemd 서비스 활성화
- [ ] Health check 통과
- [ ] Parameter Store 연동 확인
- [ ] AMI 태그 추가
- [ ] 문서 업데이트

### 배포 시
- [ ] 새 AMI에서 테스트 인스턴스 시작
- [ ] Health check 통과
- [ ] 트래픽 일부 전환 (Canary)
- [ ] 로그 모니터링 (5분)
- [ ] 전체 트래픽 전환
- [ ] 기존 인스턴스 종료

---

## 📚 참고 명령어

### AMI 관리

```bash
# AMI 목록 조회
aws ec2 describe-images --owners self --filters "Name=name,Values=bibleai-*"

# 특정 AMI로 인스턴스 시작
aws ec2 run-instances --image-id ami-xxx --instance-type t3.micro

# AMI 삭제 (오래된 버전)
aws ec2 deregister-image --image-id ami-old
```

### 인스턴스 관리

```bash
# 인스턴스 목록
aws ec2 describe-instances --filters "Name=tag:Name,Values=bibleai-*"

# 인스턴스 종료
aws ec2 terminate-instances --instance-ids i-xxx

# SSH 접속
ssh -i your-key.pem ec2-user@public-ip
```

---

## 🎯 결론

**AMI 골든 이미지 방식이 최적인 이유:**

1. ✅ **간단함**: Docker 없이 네이티브 실행
2. ✅ **빠름**: 인스턴스 시작 = 배포 완료
3. ✅ **저렴함**: 작은 인스턴스로 충분
4. ✅ **AWS 네이티브**: 완벽한 통합
5. ✅ **확장 용이**: Auto Scaling 간단

**Docker는 필요 없습니다!** 🚀

---

**작성일**: 2025-10-02
**프로젝트**: 주님말씀AI 웹앱
**배포 전략**: AMI 골든 이미지
