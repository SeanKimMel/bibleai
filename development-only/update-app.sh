#!/bin/bash
# EC2에서 애플리케이션 업데이트 (배포) 스크립트
# 사용법: ssh ec2-user@your-ip "./update-app.sh"

set -e

echo "========================================="
echo "BibleAI 애플리케이션 업데이트"
echo "========================================="
echo ""

cd /opt/bibleai

# 1. Git pull
echo "1️⃣  최신 코드 가져오기 (git pull)..."
git pull origin main

# 2. 빌드
echo ""
echo "2️⃣  애플리케이션 빌드 중..."
go build -o bibleai ./cmd/server

# 3. 재시작
echo ""
echo "3️⃣  애플리케이션 재시작 중..."
sudo systemctl restart bibleai

# 4. 상태 확인
echo ""
echo "4️⃣  상태 확인 중..."
sleep 2
sudo systemctl status bibleai --no-pager

# 5. Health check
echo ""
echo "5️⃣  Health check..."
sleep 1
curl -f http://localhost:8080/health

echo ""
echo ""
echo "========================================="
echo "✅ 업데이트 완료!"
echo "========================================="
echo ""
echo "📋 로그 확인:"
echo "   sudo journalctl -u bibleai -f"
echo ""
