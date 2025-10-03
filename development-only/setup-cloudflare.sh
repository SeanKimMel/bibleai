#!/bin/bash
# Cloudflare Tunnel 설정 스크립트
# EC2에서 실행하여 Cloudflare Zero Trust를 통한 HTTPS 설정

set -e

echo "========================================="
echo "Cloudflare Tunnel 설정"
echo "========================================="
echo ""

# 1. cloudflared 설치 확인
echo "1️⃣  cloudflared 설치 확인 중..."
if ! command -v cloudflared &> /dev/null; then
    echo "   📥 cloudflared 다운로드 중..."

    # CPU 아키텍처 감지
    ARCH=$(uname -m)
    if [ "$ARCH" = "aarch64" ] || [ "$ARCH" = "arm64" ]; then
        echo "   ℹ️  ARM64 아키텍처 감지됨"
        CLOUDFLARED_URL="https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm64"
    elif [ "$ARCH" = "x86_64" ]; then
        echo "   ℹ️  x86_64 아키텍처 감지됨"
        CLOUDFLARED_URL="https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64"
    else
        echo "   ❌ 지원하지 않는 아키텍처: $ARCH"
        exit 1
    fi

    wget -q $CLOUDFLARED_URL -O cloudflared
    sudo chmod +x cloudflared
    sudo mv cloudflared /usr/local/bin/
    echo "   ✅ cloudflared 설치 완료"
else
    echo "   ✅ cloudflared가 이미 설치되어 있습니다"
fi

cloudflared --version

# 2. Cloudflare 로그인
echo ""
echo "2️⃣  Cloudflare 인증"
echo "   ℹ️  브라우저가 열리면 Cloudflare 계정으로 로그인하세요"
echo ""
cloudflared tunnel login

# 3. Tunnel 생성
echo ""
echo "3️⃣  Tunnel 생성"
read -p "   Tunnel 이름을 입력하세요 (예: bibleai-tunnel): " TUNNEL_NAME

if [ -z "$TUNNEL_NAME" ]; then
    TUNNEL_NAME="bibleai-tunnel"
    echo "   ℹ️  기본 이름 사용: $TUNNEL_NAME"
fi

cloudflared tunnel create $TUNNEL_NAME

# Tunnel UUID 가져오기
TUNNEL_UUID=$(cloudflared tunnel list | grep $TUNNEL_NAME | awk '{print $1}')
echo "   ✅ Tunnel 생성 완료: $TUNNEL_UUID"

# 4. 설정 파일 생성
echo ""
echo "4️⃣  Cloudflare Tunnel 설정 파일 생성"
read -p "   도메인을 입력하세요 (예: bibleai.example.com): " DOMAIN

if [ -z "$DOMAIN" ]; then
    echo "   ❌ 도메인을 입력해야 합니다"
    exit 1
fi

sudo mkdir -p /etc/cloudflared
sudo tee /etc/cloudflared/config.yml > /dev/null <<EOF
tunnel: $TUNNEL_UUID
credentials-file: /root/.cloudflared/$TUNNEL_UUID.json

ingress:
  - hostname: $DOMAIN
    service: http://localhost:8080
  - service: http_status:404
EOF

echo "   ✅ 설정 파일 생성 완료: /etc/cloudflared/config.yml"

# 5. DNS 레코드 생성
echo ""
echo "5️⃣  DNS 레코드 생성"
cloudflared tunnel route dns $TUNNEL_NAME $DOMAIN
echo "   ✅ DNS 레코드 생성 완료: $DOMAIN"

# 6. Tunnel을 systemd 서비스로 등록
echo ""
echo "6️⃣  Systemd 서비스 등록"
sudo cloudflared service install
sudo systemctl enable cloudflared
sudo systemctl start cloudflared

echo "   ✅ Cloudflare Tunnel 서비스 시작 완료"

# 7. 상태 확인
echo ""
echo "========================================="
echo "✅ Cloudflare Tunnel 설정 완료!"
echo "========================================="
echo ""
echo "📋 설정 정보:"
echo "   Tunnel 이름: $TUNNEL_NAME"
echo "   Tunnel UUID: $TUNNEL_UUID"
echo "   도메인: $DOMAIN"
echo "   로컬 서비스: http://localhost:8080"
echo ""
echo "🔍 상태 확인:"
echo "   sudo systemctl status cloudflared"
echo ""
echo "📝 로그 확인:"
echo "   sudo journalctl -u cloudflared -f"
echo ""
echo "🌐 접속 테스트:"
echo "   curl https://$DOMAIN/health"
echo ""
echo "⚠️  주의사항:"
echo "   1. BibleAI 애플리케이션이 8080 포트에서 실행 중이어야 합니다"
echo "   2. DNS 전파까지 최대 5분 소요될 수 있습니다"
echo "   3. Cloudflare Zero Trust 대시보드에서 Tunnel 상태를 확인하세요"
echo "      https://one.dash.cloudflare.com/"
echo ""
