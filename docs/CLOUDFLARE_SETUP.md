# Cloudflare Proxy 설정 가이드 (Flexible Mode)

## 🎯 개요

**현재 구성**: Cloudflare Proxy + Flexible Mode + EC2 직접 8080 포트

Cloudflare를 사용하면 **무료**로 다음을 얻을 수 있습니다:
- ✅ SSL/TLS 인증서 (자동 발급, 갱신)
- ✅ CDN (전 세계 빠른 속도)
- ✅ DDoS 방어
- ✅ 방화벽 규칙
- ✅ 캐싱

**장점**:
- Nginx SSL 설정 불필요
- Let's Encrypt 설정 불필요
- 자체 서명 인증서 불필요
- **가장 간단한 HTTPS 설정**

**아키텍처**:
```
사용자 → Cloudflare (HTTPS) → EC2:8080 (HTTP)
        (SSL 종료)              (애플리케이션)
```

---

## 📋 1단계: Cloudflare 계정 및 도메인 등록

### 1.1 Cloudflare 가입

1. https://dash.cloudflare.com/sign-up 접속
2. 이메일, 비밀번호 입력
3. 이메일 인증

### 1.2 도메인 추가

1. **Add a Site** 클릭
2. 도메인 입력 (예: `haruinfo.net`)
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

**예시** (haruinfo.net 기준):
```
Type: A
Name: @  (루트 도메인용)
Content: 13.209.47.72  (EC2 Public IP)
Proxy status: Proxied (주황색 구름 ☁️) ⭐
TTL: Auto
```

**서브도메인 추가 (선택사항)**:
```
Type: A
Name: www
Content: 13.209.47.72
Proxy status: Proxied ☁️
TTL: Auto
```

**중요**:
- ✅ **Proxied (주황색 구름)**: Cloudflare를 통해 트래픽 라우팅 (SSL, CDN 활성화) ⭐
- ❌ **DNS Only (회색 구름)**: 직접 연결 (SSL, CDN 미사용)

### 2.2 확인

```bash
# DNS 전파 확인
nslookup haruinfo.net

# Cloudflare IP로 반환되면 정상
# 예: 104.21.x.x 또는 172.67.x.x
```

---

## 📋 3단계: SSL/TLS 설정 (Flexible Mode)

### 3.1 SSL/TLS 암호화 모드 선택

**Cloudflare 대시보드 → SSL/TLS → Overview**

#### 모드 선택: Flexible ⭐

**Flexible Mode**:
- 사용자 → Cloudflare: **HTTPS** (암호화됨)
- Cloudflare → EC2: **HTTP** (평문)
- EC2에서 SSL 설정 불필요
- **가장 간단하고 빠른 설정**

**설정**:
1. SSL/TLS → Overview
2. **Flexible** 선택

#### 다른 모드 (참고용)

| 모드 | 사용자↔CF | CF↔Origin | EC2 설정 필요 | 복잡도 |
|------|-----------|-----------|--------------|--------|
| **Flexible** | HTTPS | HTTP | ❌ 불필요 | ⭐ 간단 |
| Full | HTTPS | HTTPS | 자체 서명 인증서 | ⭐⭐ 중간 |
| Full (Strict) | HTTPS | HTTPS | 유효한 인증서 | ⭐⭐⭐ 복잡 |

---

## 📋 4단계: EC2 Security Group 설정

### AWS Console에서 설정

**EC2 → Security Groups → 인스턴스의 SG 선택 → Inbound Rules**

#### 옵션 1: 전체 개방 (간단)

| Type | Protocol | Port | Source | Description |
|------|----------|------|--------|-------------|
| Custom TCP | TCP | 8080 | 0.0.0.0/0 | BibleAI HTTP |
| SSH | TCP | 22 | My IP | SSH access |

#### 옵션 2: Cloudflare IP만 허용 (보안 강화)

| Type | Protocol | Port | Source | Description |
|------|----------|------|--------|-------------|
| Custom TCP | TCP | 8080 | 173.245.48.0/20 | Cloudflare IP 1 |
| Custom TCP | TCP | 8080 | 103.21.244.0/22 | Cloudflare IP 2 |
| Custom TCP | TCP | 8080 | 103.22.200.0/22 | Cloudflare IP 3 |
| ... | ... | ... | ... | (전체 목록은 아래 참조) |
| SSH | TCP | 22 | My IP | SSH access |

**Cloudflare IPv4 범위** (2025년 기준):
```
173.245.48.0/20
103.21.244.0/22
103.22.200.0/22
103.31.4.0/22
141.101.64.0/18
108.162.192.0/18
190.93.240.0/20
188.114.96.0/20
197.234.240.0/22
198.41.128.0/17
162.158.0.0/15
104.16.0.0/13
104.24.0.0/14
172.64.0.0/13
131.0.72.0/22
```

**최신 IP 목록**: https://www.cloudflare.com/ips/

---

## 📋 5단계: 애플리케이션 확인

### EC2에서 확인

```bash
# 애플리케이션 상태 확인
sudo systemctl status bibleai

# 8080 포트 리스닝 확인
sudo netstat -tlnp | grep 8080

# Health 체크
curl http://localhost:8080/health
```

### 외부 접속 테스트

**5분 후** (DNS 전파 대기):

```bash
# HTTPS 접속 테스트
curl https://haruinfo.net/health

# 브라우저 접속
https://haruinfo.net
```

---

## 📋 6단계: Cloudflare 추가 설정 (권장)

### 6.1 Always Use HTTPS

**SSL/TLS → Edge Certificates**

- ✅ **Always Use HTTPS**: ON
  - HTTP 요청을 자동으로 HTTPS로 리다이렉트

### 6.2 Automatic HTTPS Rewrites

- ✅ **Automatic HTTPS Rewrites**: ON
  - HTTP 링크를 자동으로 HTTPS로 변환

### 6.3 Minimum TLS Version

- **Minimum TLS Version**: TLS 1.2 이상

### 6.4 Caching 설정

**Caching → Configuration**

- **Browser Cache TTL**: 4 hours
- **Caching Level**: Standard

**정적 파일 캐싱 규칙**:
1. Rules → Page Rules → Create Page Rule
2. URL: `haruinfo.net/static/*`
3. Settings:
   - Cache Level: Cache Everything
   - Edge Cache TTL: 1 month

---

## 🔍 문제 해결

### 1. "Too Many Redirects" 오류

**원인**: SSL/TLS 모드가 잘못 설정됨

**해결**:
1. Cloudflare → SSL/TLS → Overview
2. **Flexible** 모드로 변경
3. 브라우저 캐시 삭제 후 재접속

### 2. 502 Bad Gateway

**원인**: EC2 애플리케이션이 8080 포트에서 실행되지 않음

**해결**:
```bash
# 애플리케이션 재시작
sudo systemctl restart bibleai
sudo systemctl status bibleai

# 포트 확인
sudo netstat -tlnp | grep 8080
```

### 3. DNS가 전파되지 않음

**확인**:
```bash
# Cloudflare 네임서버 확인
dig haruinfo.net NS

# DNS 전파 확인 (글로벌)
https://www.whatsmydns.net/#NS/haruinfo.net
```

**대기**: 최대 24시간 (보통 1-2시간)

### 4. Security Group 차단

**확인**:
```bash
# 로컬에서 8080 포트 접근 테스트
curl http://13.209.47.72:8080/health
```

**해결**: AWS Console → Security Group → 8080 포트 규칙 추가

---

## 📊 현재 구성 요약

**성공한 구성** (haruinfo.net):

```
사용자 (브라우저)
    ↓ HTTPS
Cloudflare CDN (SSL 종료)
    ↓ HTTP
EC2:8080 (BibleAI 애플리케이션)
    ↓
PostgreSQL (로컬)
```

**설정 완료 항목**:
- ✅ Cloudflare DNS: A 레코드 (Proxied)
- ✅ SSL/TLS: Flexible Mode
- ✅ EC2 Security Group: 8080 포트 개방
- ✅ 애플리케이션: 8080 포트 리스닝

**비용**:
- Cloudflare: 무료 플랜
- EC2: t4g.micro ($6/월)
- **총 $6/월**

---

## 🔗 참고 자료

- [Cloudflare SSL Modes](https://developers.cloudflare.com/ssl/origin-configuration/ssl-modes/)
- [Cloudflare IP Ranges](https://www.cloudflare.com/ips/)
- [Cloudflare Free Plan Features](https://www.cloudflare.com/plans/free/)

---

**작성일**: 2025년 10월 4일
**테스트 완료**: haruinfo.net (Flexible Mode + 8080)
**상태**: ✅ 프로덕션 검증 완료
