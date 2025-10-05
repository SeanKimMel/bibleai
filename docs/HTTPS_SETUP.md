# HTTPS 설정 가이드 (Nginx + Let's Encrypt)

⚠️ **주의**: Cloudflare를 사용하지 않는 경우에만 사용하세요

⭐ **권장**: [Cloudflare Proxy 방식](CLOUDFLARE_SETUP.md) 사용 (더 간단, Nginx 불필요)

## 🎯 개요

EC2에서 Nginx와 Let's Encrypt를 사용하여 무료 SSL 인증서를 설정하고 HTTPS를 활성화합니다.

**이 방식을 사용하는 경우**:
- Cloudflare를 사용할 수 없을 때
- 자체 서버에서 완전한 제어가 필요할 때
- Nginx의 추가 기능이 필요할 때

## 📋 사전 준비

### 1. 도메인 필요
- 도메인 구입 (Route 53, Namecheap, GoDaddy 등)
- 또는 무료 도메인 (Freenom - 비권장)

### 2. DNS 설정
- A 레코드: `your-domain.com` → EC2 Public IP
- 예시: `bibleai.example.com` → `54.180.123.456`

### 3. 확인
```bash
# DNS 전파 확인 (1-24시간 소요)
nslookup your-domain.com

# 또는
dig your-domain.com
```

---

## 🚀 빠른 설정 (5분)

### 자동 스크립트 사용

```bash
# EC2 SSH 접속
ssh ec2-user@your-ec2-ip

# HTTPS 설정 스크립트 실행 (Nginx + Let's Encrypt)
cd /opt/bibleai
sudo ./development-only/setup-nginx-letsencrypt.sh your-domain.com
```

**스크립트가 자동으로 수행**:
1. Certbot 설치
2. Nginx 설정 업데이트
3. SSL 인증서 발급
4. HTTPS 리다이렉트 설정
5. 자동 갱신 설정

---

## 🔧 수동 설정 (상세)

### 1단계: Certbot 설치

```bash
# Amazon Linux 2023
sudo dnf install -y certbot python3-certbot-nginx
```

### 2단계: Nginx 설정 업데이트

```bash
# 백업 생성
sudo cp /etc/nginx/conf.d/bibleai.conf /etc/nginx/conf.d/bibleai.conf.backup

# 설정 파일 수정
sudo vi /etc/nginx/conf.d/bibleai.conf
```

**설정 내용**:
```nginx
server {
    listen 80;
    server_name your-domain.com;

    # Certbot 검증을 위한 경로
    location /.well-known/acme-challenge/ {
        root /var/www/html;
    }

    # 나머지 요청은 애플리케이션으로
    location / {
        proxy_pass http://localhost:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

```bash
# 설정 테스트
sudo nginx -t

# Nginx 재시작
sudo systemctl restart nginx
```

### 3단계: SSL 인증서 발급

```bash
# Let's Encrypt 인증서 발급
sudo certbot --nginx -d your-domain.com

# 이메일 입력 (인증서 만료 알림용)
# 약관 동의 (Y)
# 뉴스레터 수신 여부 (N)
```

**Certbot이 자동으로**:
- SSL 인증서 발급
- Nginx 설정 업데이트 (443 포트 추가)
- HTTP → HTTPS 리다이렉트 설정

### 4단계: 자동 갱신 확인

```bash
# 자동 갱신 테스트 (실제 갱신 안 함)
sudo certbot renew --dry-run

# 자동 갱신 타이머 상태
sudo systemctl status certbot.timer
```

---

## 📝 최종 Nginx 설정 (Certbot 적용 후)

```nginx
server {
    listen 80;
    server_name your-domain.com;

    # HTTP → HTTPS 리다이렉트
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name your-domain.com;

    # SSL 인증서 (Certbot이 자동 추가)
    ssl_certificate /etc/letsencrypt/live/your-domain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/your-domain.com/privkey.pem;
    ssl_trusted_certificate /etc/letsencrypt/live/your-domain.com/chain.pem;

    # SSL 설정 (Certbot이 자동 추가)
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;

    # 애플리케이션 프록시
    location / {
        proxy_pass http://localhost:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;

        # WebSocket 지원 (선택사항)
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }

    # 정적 파일 캐싱
    location /static/ {
        alias /opt/bibleai/web/static/;
        expires 30d;
        add_header Cache-Control "public, immutable";
    }
}
```

---

## 🔐 보안 강화 (선택사항)

### SSL Labs A+ 등급 받기

```bash
# Nginx 설정에 추가
sudo vi /etc/nginx/conf.d/bibleai.conf
```

**추가 설정**:
```nginx
server {
    listen 443 ssl http2;
    server_name your-domain.com;

    # ... 기존 SSL 설정 ...

    # HSTS (HTTP Strict Transport Security)
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;

    # 클릭재킹 방지
    add_header X-Frame-Options "SAMEORIGIN" always;

    # XSS 보호
    add_header X-Content-Type-Options "nosniff" always;

    # CSP (Content Security Policy)
    add_header Content-Security-Policy "default-src 'self'; script-src 'self' 'unsafe-inline'; style-src 'self' 'unsafe-inline';" always;

    # Referrer Policy
    add_header Referrer-Policy "no-referrer-when-downgrade" always;

    # ...
}
```

```bash
# 설정 테스트 및 재시작
sudo nginx -t
sudo systemctl reload nginx
```

### SSL 테스트

**SSL Labs**: https://www.ssllabs.com/ssltest/
- 도메인 입력하여 A+ 등급 확인

---

## 🔄 인증서 갱신

### 자동 갱신 (기본 설정됨)

Let's Encrypt 인증서는 **90일** 유효합니다.
Certbot이 자동으로 갱신합니다 (30일 전).

```bash
# 자동 갱신 타이머 확인
sudo systemctl status certbot.timer

# 자동 갱신 활성화 (기본 활성화됨)
sudo systemctl enable certbot.timer
```

### 수동 갱신

```bash
# 인증서 갱신 (30일 이내 만료 시에만)
sudo certbot renew

# 강제 갱신 (테스트용)
sudo certbot renew --force-renewal

# 갱신 후 Nginx 재시작
sudo systemctl reload nginx
```

### 인증서 정보 확인

```bash
# 인증서 목록 및 만료일
sudo certbot certificates

# 출력 예시:
# Certificate Name: your-domain.com
#   Domains: your-domain.com
#   Expiry Date: 2026-01-01 12:00:00+00:00 (VALID: 89 days)
#   Certificate Path: /etc/letsencrypt/live/your-domain.com/fullchain.pem
#   Private Key Path: /etc/letsencrypt/live/your-domain.com/privkey.pem
```

---

## 🧪 테스트

### 1. HTTPS 접속 테스트

```bash
# 명령어로 테스트
curl -I https://your-domain.com/health

# 출력 확인:
# HTTP/2 200
# server: nginx
# ...
```

### 2. HTTP 리다이렉트 테스트

```bash
# HTTP 접속 시 HTTPS로 리다이렉트되는지 확인
curl -I http://your-domain.com

# 출력 확인:
# HTTP/1.1 301 Moved Permanently
# Location: https://your-domain.com/
```

### 3. 브라우저 테스트

- https://your-domain.com 접속
- 주소창에 🔒 자물쇠 아이콘 확인
- 인증서 정보 확인 (클릭)

---

## 🚨 문제 해결

### 1. "Connection refused" 오류

```bash
# Nginx 상태 확인
sudo systemctl status nginx

# Nginx 로그 확인
sudo tail -f /var/log/nginx/error.log

# 방화벽 확인 (EC2 Security Group)
# 443 포트가 열려있는지 확인
```

### 2. "Certificate verification failed"

```bash
# 인증서 갱신
sudo certbot renew --force-renewal

# Nginx 재시작
sudo systemctl restart nginx
```

### 3. DNS가 제대로 설정되지 않음

```bash
# DNS 전파 확인
nslookup your-domain.com

# 또는
dig your-domain.com

# DNS 전파는 최대 24-48시간 소요
```

### 4. Certbot 실패

```bash
# 로그 확인
sudo tail -f /var/log/letsencrypt/letsencrypt.log

# 일반적인 원인:
# - DNS가 EC2 IP를 가리키지 않음
# - 80번 포트가 닫혀있음 (Security Group 확인)
# - Nginx가 실행되지 않음
```

---

## 💰 비용

### Let's Encrypt (무료)
- **SSL 인증서**: $0/월
- **자동 갱신**: 무료
- **제한**: 도메인당 주당 50개 인증서 발급

### 도메인 비용
- **Route 53**: $12/년 (.com)
- **Namecheap**: $8-12/년
- **GoDaddy**: $10-15/년

---

## 📋 체크리스트

### HTTPS 설정 전
- [ ] 도메인 구입 완료
- [ ] DNS A 레코드 설정 (도메인 → EC2 IP)
- [ ] DNS 전파 확인 (nslookup)
- [ ] EC2 Security Group 80/443 포트 열림
- [ ] Nginx 실행 중

### HTTPS 설정 중
- [ ] Certbot 설치 완료
- [ ] Nginx 설정 업데이트
- [ ] SSL 인증서 발급 성공
- [ ] HTTPS 접속 테스트 통과
- [ ] HTTP → HTTPS 리다이렉트 확인

### HTTPS 설정 후
- [ ] 자동 갱신 타이머 활성화 확인
- [ ] SSL Labs A 등급 이상 (선택사항)
- [ ] 브라우저에서 🔒 아이콘 확인
- [ ] 모든 페이지 HTTPS 동작 확인

---

## 🔗 참고 자료

- [Let's Encrypt 공식 문서](https://letsencrypt.org/docs/)
- [Certbot 사용법](https://certbot.eff.org/)
- [Nginx SSL 설정](https://nginx.org/en/docs/http/configuring_https_servers.html)
- [SSL Labs 테스트](https://www.ssllabs.com/ssltest/)

---

**작성일**: 2025년 10월 3일
**업데이트**: 2025년 10월 3일
