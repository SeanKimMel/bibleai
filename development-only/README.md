# 개발 전용 파일 (Development Only)

이 디렉토리는 **개발 및 테스트 용도**의 파일들을 포함합니다.
프로덕션 배포에는 사용되지 않습니다.

## 📋 파일 목록

### 🚀 EC2 배포 스크립트
```
setup-ec2.sh                  - EC2 초기 환경 구축 (Go, PostgreSQL 설치)
setup-nginx-letsencrypt.sh    - Nginx + Let's Encrypt SSL (Cloudflare 미사용시)
update-app.sh                 - 애플리케이션 업데이트 (3분)
check-setup.sh                - 설정 상태 확인
```

### 🌐 HTTPS 설정 방식
**권장: Cloudflare Proxy (무료, 간편)** ⭐
- Cloudflare 대시보드에서 DNS 설정만으로 완료
- Nginx 설정 불필요
- ✅ 무료 SSL/TLS 인증서
- ✅ DDoS 보호 및 CDN
- ✅ 8080 포트만 개방
- ✅ 자동 인증서 갱신

**상세 가이드**: [CLOUDFLARE_SETUP.md](../docs/CLOUDFLARE_SETUP.md)

**대안: Nginx + Let's Encrypt** (Cloudflare 미사용시)
```bash
./setup-nginx-letsencrypt.sh your-domain.com
```
- 전통적인 SSL 인증서 방식
- Nginx 설치 및 설정 필요
- 80/443 포트 개방 필요

**상세 가이드**: [HTTPS_SETUP.md](../docs/HTTPS_SETUP.md)

### 🧪 테스트 스크립트
```
test-aws-params.sh     - AWS Parameter Store 테스트
test_api.sh            - API 엔드포인트 테스트
*_bible_test.sh        - 성경 API 테스트
```

### 🔧 개발 스크립트
```
dev.sh                 - 개발 모드 (Air hot reload)
start.sh               - 일반 실행
stop.sh                - 애플리케이션 종료
```

## 🎯 배포 전략

현재 프로젝트는 **네이티브 Go 바이너리 + Cloudflare Tunnel** 방식을 사용합니다.

### 아키텍처
```
사용자 → Cloudflare CDN → Cloudflare Tunnel → EC2 (8080) → PostgreSQL
        (HTTPS, DDoS 보호)     (암호화된 연결)    (내부 포트)
```

### 왜 이 방식인가?

**프로젝트 특성**:
- ✅ 규모가 작음 (Go 파일 10개 미만)
- ✅ 의존성 단순함 (PostgreSQL만)
- ✅ 단일 서버 배포
- ✅ 네이티브가 더 빠르고 효율적

**기술 선택**:
- 네이티브 Go 바이너리 (Docker보다 빠름)
- .env 파일 설정 (간단함)
- Systemd 서비스 관리 (AWS EC2 네이티브)
- Cloudflare Proxy (무료 HTTPS + CDN + DDoS 보호)

**비용 및 보안**:
- EC2: t4g.micro (ARM64) 충분 ($6/월)
- Cloudflare: 무료 플랜으로 충분
- 방화벽: SSH(22)만 개방, 웹 포트 차단
- **안전하고 경제적**

## 📚 참고 문서

- [QUICK_START.md](../docs/QUICK_START.md) - 5분 시작 가이드
- [CLOUDFLARE_SETUP.md](../docs/CLOUDFLARE_SETUP.md) - Cloudflare Tunnel 설정 ⭐
- [HTTPS_SETUP.md](../docs/HTTPS_SETUP.md) - Let's Encrypt 설정 (대안)
- [SIMPLE_DEPLOYMENT.md](../docs/SIMPLE_DEPLOYMENT.md) - 심플 배포
- [EC2_DEPLOYMENT.md](../docs/EC2_DEPLOYMENT.md) - 전체 AWS 배포

## 🚀 빠른 시작

### 1단계: EC2 환경 구축
```bash
./development-only/setup-ec2.sh
```

### 2단계: HTTPS 설정 (Cloudflare 권장)
```bash
./development-only/setup-cloudflare.sh
```

### 3단계: 접속 확인
```bash
curl https://your-domain.com/health
```

---

**작성일**: 2025년 10월 3일
**업데이트**: 2025년 10월 4일 (Cloudflare Tunnel 추가, Docker 제거)
