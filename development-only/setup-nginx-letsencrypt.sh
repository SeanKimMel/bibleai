#!/bin/bash
# HTTPS 설정 스크립트 (Nginx + Let's Encrypt)
# ⚠️  주의: Cloudflare를 사용하지 않는 경우에만 사용
# ⚠️  권장: Cloudflare Proxy 사용 (무료, 간편, Nginx 불필요)
# 사용법: sudo ./setup-nginx-letsencrypt.sh your-domain.com

set -e

# 도메인 확인
if [ -z "$1" ]; then
    echo "❌ 사용법: sudo ./setup-nginx-letsencrypt.sh your-domain.com"
    echo ""
    echo "⚠️  주의: 이 스크립트는 Nginx + Let's Encrypt 방식입니다"
    echo "⚠️  권장: Cloudflare Proxy 사용 (더 간단, Nginx 불필요)"
    echo ""
    echo "예시:"
    echo "  sudo ./setup-nginx-letsencrypt.sh bibleai.example.com"
    echo ""
    exit 1
fi

DOMAIN=$1

echo "========================================="
echo "HTTPS 설정 (Nginx + Let's Encrypt)"
echo "========================================="
echo ""
echo "⚠️  이 방식은 Cloudflare를 사용하지 않는 경우에만 사용하세요"
echo "⚠️  Cloudflare Proxy를 사용하면 Nginx 설정이 불필요합니다"
echo ""
echo "도메인: $DOMAIN"
echo ""

# 1. Certbot 설치
echo "1️⃣  Certbot 설치 중..."
sudo dnf install -y certbot python3-certbot-nginx

# 2. 현재 Nginx 설정 백업
echo ""
echo "2️⃣  Nginx 설정 백업 중..."
sudo cp /etc/nginx/conf.d/bibleai.conf /etc/nginx/conf.d/bibleai.conf.backup.$(date +%Y%m%d_%H%M%S)

# 3. Nginx 설정 업데이트 (도메인 추가)
echo ""
echo "3️⃣  Nginx 설정 업데이트 중..."
sudo tee /etc/nginx/conf.d/bibleai.conf > /dev/null <<EOF
server {
    listen 80;
    server_name $DOMAIN;

    # Certbot 검증을 위한 경로
    location /.well-known/acme-challenge/ {
        root /var/www/html;
    }

    # 나머지 요청은 애플리케이션으로
    location / {
        proxy_pass http://localhost:8080;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF

# 4. Nginx 설정 테스트
echo ""
echo "4️⃣  Nginx 설정 테스트 중..."
sudo nginx -t

# 5. Nginx 재시작
echo ""
echo "5️⃣  Nginx 재시작 중..."
sudo systemctl restart nginx

# 6. Let's Encrypt SSL 인증서 발급
echo ""
echo "6️⃣  Let's Encrypt SSL 인증서 발급 중..."
echo "   ⚠️  이메일 주소를 입력해야 합니다 (인증서 만료 알림용)"
echo ""

sudo certbot --nginx -d $DOMAIN

# 7. 자동 갱신 테스트
echo ""
echo "7️⃣  인증서 자동 갱신 테스트 중..."
sudo certbot renew --dry-run

# 8. 최종 Nginx 설정 확인
echo ""
echo "8️⃣  최종 Nginx 설정 확인 중..."
sudo nginx -t
sudo systemctl reload nginx

echo ""
echo "========================================="
echo "✅ HTTPS 설정 완료!"
echo "========================================="
echo ""
echo "📋 접속 정보:"
echo "   HTTP:  http://$DOMAIN  (자동 리다이렉트)"
echo "   HTTPS: https://$DOMAIN"
echo ""
echo "🔒 SSL 인증서 정보:"
sudo certbot certificates
echo ""
echo "🔄 자동 갱신:"
echo "   Certbot이 90일마다 자동으로 인증서를 갱신합니다."
echo "   확인: sudo systemctl status certbot.timer"
echo ""
echo "📝 Nginx 설정 파일:"
echo "   /etc/nginx/conf.d/bibleai.conf"
echo ""
echo "🧪 접속 테스트:"
echo "   curl https://$DOMAIN/health"
echo ""
