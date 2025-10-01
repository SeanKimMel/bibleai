#!/bin/bash
# EC2 인스턴스 Docker 환경 초기 설정 스크립트
# Amazon Linux 2 전용

set -e

echo "🚀 EC2 인스턴스 Docker 환경 설정 시작..."

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
DOCKER_COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')
sudo curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# 4. Git 설치
echo "📥 Git 설치..."
sudo yum install -y git

# 5. 기타 유틸리티 설치
echo "🔧 유틸리티 설치..."
sudo yum install -y htop curl wget nano

# 6. 방화벽 설정 (firewalld가 있는 경우)
echo "🔥 방화벽 설정..."
if command -v firewall-cmd &> /dev/null; then
    sudo firewall-cmd --permanent --add-port=8080/tcp
    sudo firewall-cmd --reload
    echo "✅ 방화벽에 8080 포트 추가됨"
else
    echo "ℹ️  firewalld가 설치되어 있지 않음 (AWS 보안 그룹으로 관리)"
fi

# 7. 스왑 파일 생성 (t3.micro 같은 소형 인스턴스용)
echo "💾 스왑 파일 생성 (2GB)..."
if [ ! -f /swapfile ]; then
    sudo dd if=/dev/zero of=/swapfile bs=1M count=2048
    sudo chmod 600 /swapfile
    sudo mkswap /swapfile
    sudo swapon /swapfile
    echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
    echo "✅ 스왑 파일 생성 완료"
else
    echo "ℹ️  스왑 파일이 이미 존재함"
fi

echo ""
echo "✅ EC2 초기 설정 완료!"
echo ""
echo "⚠️  중요: 다음 명령어로 로그아웃 후 다시 로그인하세요:"
echo "   exit"
echo ""
echo "재로그인 후 Docker 권한 확인:"
echo "   docker ps"
echo ""
echo "다음 단계: 애플리케이션 배포"
echo "   ./deploy.sh"