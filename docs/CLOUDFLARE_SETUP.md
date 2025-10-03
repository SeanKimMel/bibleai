# Cloudflare 설정 가이드

## 🎯 개요

Cloudflare를 사용하면 **무료**로 다음을 얻을 수 있습니다:
- ✅ SSL 인증서 (자동 발급, 갱신)
- ✅ CDN (전 세계 빠른 속도)
- ✅ DDoS 방어
- ✅ 방화벽 규칙
- ✅ 캐싱

**Let's Encrypt 설정 불필요!**

---

## 📋 1단계: Cloudflare 계정 및 도메인 등록

### 1.1 Cloudflare 가입

1. https://dash.cloudflare.com/sign-up 접속
2. 이메일, 비밀번호 입력
3. 이메일 인증

### 1.2 도메인 추가

1. **Add a Site** 클릭
2. 도메인 입력 (예: `bibleai.example.com` → `example.com` 입력)
3. **Free Plan** 선택
4. Cloudflare가 DNS 레코드 스캔

### 1.3 네임서버 변경

**기존 도메인 등록업체에서** 네임서버를 Cloudflare로 변경:

**Cloudflare 네임서버 예시** (실제 값은 대시보드에서 확인):
```
ns1.cloudflare.com
ns2.cloudflare.com
```

**주요 도메인 등록업체별 설정 방법**:

#### Route 53 (AWS)
1. Route 53 콘솔 → Hosted Zones
2. 도메인 선택 → NS 레코드 수정
3. Cloudflare 네임서버로 변경

#### Namecheap
1. Domain List → Manage
2. Nameservers → Custom DNS
3. Cloudflare 네임서버 입력

#### GoDaddy
1. My Products → Domains
2. DNS → Nameservers
3. Change → Custom → Cloudflare 네임서버 입력

**전파 시간**: 2-24시간 (보통 1-2시간)

---

## 📋 2단계: DNS 레코드 설정

### 2.1 A 레코드 추가

**Cloudflare 대시보드 → DNS → Records**

| Type | Name | Content | Proxy | TTL |
|------|------|---------|-------|-----|
| A | @ | EC2_PUBLIC_IP | ✅ Proxied | Auto |
| A | www | EC2_PUBLIC_IP | ✅ Proxied | Auto |

**예시**:
```
Type: A
Name: @  (또는 루트 도메인)
Content: 54.180.123.456  (EC2 Public IP)
Proxy status: Proxied (주황색 구름 ☁️)
TTL: Auto
```

**중요**:
- ✅ **Proxied (주황색 구름)**: Cloudflare를 통해 트래픽 라우팅 (SSL, CDN 활성화)
- ❌ **DNS Only (회색 구름)**: 직접 연결 (SSL, CDN 미사용)

### 2.2 확인

```bash
# DNS 전파 확인
nslookup your-domain.com

# Cloudflare IP로 반환되면 정상
# 예: 104.21.x.x 또는 172.67.x.x
```

---

## 📋 3단계: SSL/TLS 설정

### 3.1 SSL/TLS 암호화 모드 선택

**Cloudflare 대시보드 → SSL/TLS → Overview**

#### 옵션 비교

| 모드 | 사용자↔CF | CF↔Origin | EC2 설정 | 추천 |
|------|-----------|-----------|----------|------|
| **Flexible** | ✅ HTTPS | ❌ HTTP | Nginx HTTP만 | ⚠️ 비권장 |
| **Full** | ✅ HTTPS | ✅ HTTPS | 자체 서명 인증서 OK | ✅ 권장 |
| **Full (Strict)** | ✅ HTTPS | ✅ HTTPS | 유효한 인증서 필요 | 🔒 최고 |

#### 권장: Full 모드

**이유**:
- EC2에서 자체 서명 인증서만 있어도 OK
- Cloudflare가 사용자에게 유효한 인증서 제공
- 간단한 설정

**설정**:
1. SSL/TLS → Overview
2. **Full** 선택

---

## 📋 4단계: EC2 Nginx 설정

### 4.1 자체 서명 SSL 인증서 생성 (Full 모드용)

```bash
# EC2 SSH 접속
ssh ec2-user@your-ec2-ip

# 자체 서명 인증서 생성
sudo mkdir -p /etc/nginx/ssl
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /etc/nginx/ssl/selfsigned.key \
  -out /etc/nginx/ssl/selfsigned.crt \
  -subj "/C=KR/ST=Seoul/L=Seoul/O=BibleAI/CN=your-domain.com"
```

### 4.2 Nginx 설정 (Cloudflare Full 모드용)

```bash
sudo tee /etc/nginx/conf.d/bibleai.conf > /dev/null <<'EOF'
# HTTP (80) - Cloudflare에서 온 요청
server {
    listen 80;
    server_name your-domain.com www.your-domain.com;

    location / {
        proxy_pass http://localhost:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;

        # Cloudflare Real IP 복원
        real_ip_header CF-Connecting-IP;
    }
}

# HTTPS (443) - Cloudflare에서 온 요청 (Full 모드)
server {
    listen 443 ssl http2;
    server_name your-domain.com www.your-domain.com;

    # 자체 서명 SSL 인증서 (Cloudflare Full 모드용)
    ssl_certificate /etc/nginx/ssl/selfsigned.crt;
    ssl_certificate_key /etc/nginx/ssl/selfsigned.key;

    # SSL 설정
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;

    location / {
        proxy_pass http://localhost:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto https;

        # Cloudflare Real IP 복원
        real_ip_header CF-Connecting-IP;
    }

    # 정적 파일 캐싱
    location /static/ {
        alias /opt/bibleai/web/static/;
        expires 30d;
        add_header Cache-Control "public, immutable";
    }
}
EOF
```

**중요**: `your-domain.com`을 실제 도메인으로 변경!

```bash
# Nginx 설정 테스트
sudo nginx -t

# Nginx 재시작
sudo systemctl restart nginx
```

---

## 📋 5단계: EC2 Security Group 설정

### AWS Console에서 설정

**EC2 → Security Groups → 인스턴스의 SG 선택 → Inbound Rules**

| Type | Protocol | Port Range | Source | Description |
|------|----------|------------|--------|-------------|
| HTTP | TCP | 80 | 0.0.0.0/0 | HTTP from Cloudflare |
| HTTPS | TCP | 443 | 0.0.0.0/0 | HTTPS from Cloudflare |
| SSH | TCP | 22 | My IP | SSH access |

**또는 AWS CLI**:
```bash
# Security Group ID 확인
aws ec2 describe-instances --filters "Name=tag:Name,Values=bibleai-server" \
  --query "Reservations[0].Instances[0].SecurityGroups[0].GroupId" --output text

# 규칙 추가
aws ec2 authorize-security-group-ingress --group-id sg-xxx \
  --protocol tcp --port 80 --cidr 0.0.0.0/0

aws ec2 authorize-security-group-ingress --group-id sg-xxx \
  --protocol tcp --port 443 --cidr 0.0.0.0/0
```

---

## 📋 6단계: Cloudflare 추가 설정 (선택사항)

### 6.1 Always Use HTTPS

**SSL/TLS → Edge Certificates**

- ✅ **Always Use HTTPS**: ON
  - HTTP 요청을 자동으로 HTTPS로 리다이렉트

### 6.2 Automatic HTTPS Rewrites

- ✅ **Automatic HTTPS Rewrites**: ON
  - HTTP 링크를 자동으로 HTTPS로 변환

### 6.3 Minimum TLS Version

- **TLS 1.2** 선택 (권장)

### 6.4 캐싱 규칙

**Caching → Configuration**

- **Browser Cache TTL**: 4 hours
- **Caching Level**: Standard

**Page Rules 추가** (3개 무료):

| URL | 설정 | 값 |
|-----|------|-----|
| `*.your-domain.com/static/*` | Cache Level | Cache Everything |
| `*.your-domain.com/api/*` | Cache Level | Bypass |
| `*.your-domain.com/*` | Cache Level | Standard |

### 6.5 Cloudflare IP 허용 (보안 강화)

EC2에서 Cloudflare IP만 허용:

```bash
# /etc/nginx/conf.d/cloudflare-ips.conf
sudo tee /etc/nginx/conf.d/cloudflare-ips.conf > /dev/null <<'EOF'
# Cloudflare IP 범위
set_real_ip_from 173.245.48.0/20;
set_real_ip_from 103.21.244.0/22;
set_real_ip_from 103.22.200.0/22;
set_real_ip_from 103.31.4.0/22;
set_real_ip_from 141.101.64.0/18;
set_real_ip_from 108.162.192.0/18;
set_real_ip_from 190.93.240.0/20;
set_real_ip_from 188.114.96.0/20;
set_real_ip_from 197.234.240.0/22;
set_real_ip_from 198.41.128.0/17;
set_real_ip_from 162.158.0.0/15;
set_real_ip_from 104.16.0.0/13;
set_real_ip_from 104.24.0.0/14;
set_real_ip_from 172.64.0.0/13;
set_real_ip_from 131.0.72.0/22;

# IPv6
set_real_ip_from 2400:cb00::/32;
set_real_ip_from 2606:4700::/32;
set_real_ip_from 2803:f800::/32;
set_real_ip_from 2405:b500::/32;
set_real_ip_from 2405:8100::/32;
set_real_ip_from 2c0f:f248::/32;
set_real_ip_from 2a06:98c0::/29;

real_ip_header CF-Connecting-IP;
EOF

sudo nginx -t
sudo systemctl reload nginx
```

---

## 🧪 테스트

### 1. DNS 전파 확인

```bash
# Cloudflare IP로 반환되는지 확인
nslookup your-domain.com

# 예상 결과: 104.21.x.x 또는 172.67.x.x
```

### 2. HTTPS 접속 테스트

```bash
# 명령어 테스트
curl -I https://your-domain.com/health

# 예상 출력:
# HTTP/2 200
# server: cloudflare
# cf-ray: ...
```

### 3. HTTP → HTTPS 리다이렉트 테스트

```bash
curl -I http://your-domain.com

# 예상 출력:
# HTTP/1.1 301 Moved Permanently
# Location: https://your-domain.com/
```

### 4. 브라우저 테스트

1. https://your-domain.com 접속
2. 🔒 자물쇠 아이콘 확인
3. 인증서 확인: **Cloudflare** 발급

### 5. SSL 등급 확인

**SSL Labs**: https://www.ssllabs.com/ssltest/
- A+ 등급 예상

---

## 📊 포트 흐름 요약

```
사용자 (브라우저)
    ↓ https://your-domain.com (443 포트)
Cloudflare (SSL 인증서: Cloudflare 자동)
    ↓ HTTP (80) 또는 HTTPS (443) - Full 모드
EC2 Nginx (자체 서명 인증서)
    ↓ HTTP (8080 포트, 내부)
Go 애플리케이션 (.env의 PORT=8080)
```

**핵심**:
- 사용자는 **443 포트** (HTTPS)만 사용
- Go 앱은 **8080 포트**에서 실행 (내부 통신)
- Nginx가 **80, 443 포트**를 Listen
- **포트 충돌 없음!**

---

## 💰 비용

| 항목 | 비용 |
|------|------|
| **Cloudflare Free** | $0/월 |
| - SSL 인증서 | 무료 |
| - CDN | 무료 |
| - DDoS 방어 (기본) | 무료 |
| - Page Rules (3개) | 무료 |
| **도메인** | $8-12/년 |
| **EC2 + RDS** | $22/월 |
| **총 비용** | **$22/월 + 도메인** |

---

## 🚨 문제 해결

### 1. "Too many redirects" 오류

**원인**: Cloudflare Flexible 모드 + Nginx HTTPS 리다이렉트

**해결**:
1. Cloudflare SSL/TLS 모드를 **Full**로 변경
2. Nginx에서 HTTPS 리다이렉트 제거

### 2. "526 Invalid SSL certificate"

**원인**: Cloudflare Full (Strict) 모드 + 자체 서명 인증서

**해결**:
- Cloudflare SSL/TLS 모드를 **Full**로 변경 (Strict 아님)

### 3. "502 Bad Gateway"

**원인**: Go 앱이 실행되지 않음

**해결**:
```bash
# 앱 상태 확인
sudo systemctl status bibleai

# 로그 확인
sudo journalctl -u bibleai -n 50

# 재시작
sudo systemctl restart bibleai
```

### 4. Cloudflare IP 대신 EC2 IP로 응답

**원인**: DNS가 **Proxied** 모드가 아님

**해결**:
- Cloudflare DNS 레코드에서 주황색 구름 ☁️ 활성화

---

## 📋 체크리스트

### Cloudflare 설정
- [ ] Cloudflare 계정 생성
- [ ] 도메인 추가 및 네임서버 변경
- [ ] DNS 전파 확인 (1-24시간)
- [ ] A 레코드 추가 (Proxied 모드)
- [ ] SSL/TLS Full 모드 선택
- [ ] Always Use HTTPS 활성화

### EC2 설정
- [ ] 자체 서명 SSL 인증서 생성
- [ ] Nginx 설정 (80, 443 포트)
- [ ] Security Group (80, 443 열기)
- [ ] Nginx 재시작 성공
- [ ] Go 앱 실행 중

### 테스트
- [ ] DNS 전파 확인 (Cloudflare IP)
- [ ] HTTPS 접속 성공
- [ ] HTTP → HTTPS 리다이렉트 확인
- [ ] 브라우저 🔒 아이콘 확인
- [ ] SSL Labs A+ 등급

---

## 🎯 Cloudflare vs Let's Encrypt

| 항목 | Cloudflare | Let's Encrypt |
|------|-----------|---------------|
| **설정 복잡도** | ⭐ (매우 쉬움) | ⭐⭐⭐ (복잡) |
| **SSL 인증서** | 자동 (무료) | 수동 발급 필요 |
| **갱신** | 자동 | 자동 (90일마다) |
| **CDN** | ✅ 포함 | ❌ 없음 |
| **DDoS 방어** | ✅ 기본 제공 | ❌ 없음 |
| **비용** | $0 | $0 |
| **추천** | ✅ **강력 추천** | 일반적 |

---

**작성일**: 2025년 10월 3일
**추천 방식**: Cloudflare (가장 간단하고 강력)
