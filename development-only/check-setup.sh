#!/bin/bash
# 현재 설정 확인 스크립트

echo "========================================="
echo "BibleAI 설정 확인"
echo "========================================="
echo ""

echo "1️⃣  애플리케이션 상태"
sudo systemctl status bibleai --no-pager | head -5
echo ""

echo "2️⃣  포트 8080 리스닝 확인"
sudo netstat -tlnp | grep 8080 || ss -tlnp | grep 8080
echo ""

echo "3️⃣  Health 체크 (로컬)"
curl -s http://localhost:8080/health || echo "❌ Health check 실패"
echo ""

echo "4️⃣  Public IP 확인"
PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)
echo "Public IP: $PUBLIC_IP"
echo ""

echo "5️⃣  Health 체크 (Public IP)"
curl -s http://$PUBLIC_IP:8080/health || echo "❌ Public IP 접근 실패"
echo ""

echo "========================================="
echo "✅ 설정 확인 완료!"
echo "========================================="
echo ""
echo "📋 다음 단계:"
echo "1. Cloudflare에서 A 레코드 설정: @ → $PUBLIC_IP"
echo "2. Proxy 활성화 (주황색 구름)"
echo "3. SSL/TLS → Flexible 모드"
echo "4. 5분 후 테스트: curl https://haruinfo.net/health"
echo ""
