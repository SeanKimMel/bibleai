# 주님말씀AI 웹앱

**Go + PostgreSQL + Cloudflare**로 구현된 모바일 우선 성경 웹앱입니다.

**라이브**: https://haruinfo.net ⭐

## ✨ 주요 기능

- ✅ **성경 검색**: 30,929개 구절 전체 텍스트 검색
- ✅ **찬송가**: 29개 통합찬송가 (가사, 작곡가, 성경 참조)
- ✅ **키워드 기반 UI**: 사랑, 믿음, 소망 등 8개 주제별 콘텐츠
- ✅ **모바일 최적화**: 반응형 디자인, PWA 준비
- ✅ **무료 HTTPS**: Cloudflare CDN + DDoS 보호

## 🛠️ 기술 스택

- **Backend**: Go 1.23 (Gin 프레임워크)
- **Database**: PostgreSQL 16
- **Frontend**: HTML Templates + Tailwind CSS + Vanilla JS
- **배포**: AWS EC2 (t4g.micro ARM64) + Cloudflare Proxy
- **비용**: $6/월 (Cloudflare 무료)

## 🚀 빠른 시작

### 로컬 개발 (5분)

```bash
# 1. 저장소 클론
git clone https://github.com/SeanKimMel/bibleai.git
cd bibleai

# 2. 환경 변수 설정
cp .env.example .env
vi .env  # DB_PASSWORD 변경

# 3. PostgreSQL 시작 및 초기화
# macOS: brew services start postgresql
# Ubuntu: sudo systemctl start postgresql
./init-db.sh

# 4. 애플리케이션 실행
./server.sh start

# 5. 접속
open http://localhost:8080
```

**상세 가이드**: [QUICK_START.md](docs/QUICK_START.md)

### EC2 배포 (30분)

```bash
# EC2 SSH 접속
ssh ec2-user@your-ec2-ip

# 초기 환경 구축 (Go, PostgreSQL, Nginx 설치)
curl -o setup-ec2.sh https://raw.githubusercontent.com/SeanKimMel/bibleai/main/development-only/setup-ec2.sh
chmod +x setup-ec2.sh
./setup-ec2.sh

# .env 파일 수정 (DB 비밀번호)
vi /opt/bibleai/.env

# 애플리케이션 시작
sudo systemctl start bibleai
```

**HTTPS 설정 (Cloudflare 권장)**:
1. Cloudflare 계정 생성 및 도메인 등록
2. DNS A 레코드: @ → EC2 Public IP (Proxied ☁️)
3. SSL/TLS: Flexible 모드
4. Security Group: 8080 포트 개방

**상세 가이드**: [CLOUDFLARE_SETUP.md](docs/CLOUDFLARE_SETUP.md)

## 📁 프로젝트 구조

```
bibleai/
├── cmd/server/main.go           # 애플리케이션 진입점
├── internal/
│   ├── handlers/                # API 및 페이지 핸들러
│   │   ├── pages.go            # 웹 페이지 라우팅
│   │   ├── bible_import.go     # 성경 검색 API
│   │   ├── hymns.go            # 찬송가 API
│   │   └── prayers.go          # 기도문 API (진행중)
│   ├── database/db.go          # PostgreSQL 연결
│   └── models/                 # 데이터 모델
├── web/
│   ├── templates/
│   │   ├── layout/base.html    # 공통 레이아웃
│   │   └── pages/*.html        # 페이지 템플릿
│   └── static/
│       ├── js/main.js          # JavaScript 유틸리티
│       └── sw.js               # Service Worker (PWA)
├── migrations/                  # DB 스키마 및 데이터
├── development-only/            # 배포 스크립트
│   ├── setup-ec2.sh            # EC2 초기 설정
│   ├── setup-https.sh          # Let's Encrypt SSL
│   └── check-setup.sh          # 설정 확인
└── docs/                        # 문서
```

## 🌐 아키텍처

### 프로덕션 (haruinfo.net)

```
사용자 (브라우저)
    ↓ HTTPS
Cloudflare CDN (SSL 종료, DDoS 보호)
    ↓ HTTP
EC2 t4g.micro (ARM64)
    ├── BibleAI App (8080 포트)
    └── PostgreSQL 16 (로컬)
```

**Security Group**:
- SSH: 22 (관리자 IP만)
- HTTP: 8080 (0.0.0.0/0 또는 Cloudflare IP만)

## 📊 데이터베이스

- **성경**: 30,929 구절 (개역개정)
- **찬송가**: 29개 통합찬송가 (신찬송가 체계)
- **태그**: 10개 기본 태그 (감사, 위로, 용기 등)
- **기도문**: 진행 예정

## 🛠️ 개발 명령어

### 로컬 개발

```bash
# 서버 관리
./server.sh start      # 시작
./server.sh stop       # 중지
./server.sh restart    # 재시작
./server.sh status     # 상태 확인
./server.sh logs       # 로그 보기
./server.sh test       # API 테스트

# 개발 모드 (자동 재시작)
./dev.sh

# 데이터베이스 초기화
./init-db.sh
```

### EC2 프로덕션

```bash
# 서비스 관리
sudo systemctl start bibleai
sudo systemctl stop bibleai
sudo systemctl restart bibleai
sudo systemctl status bibleai

# 로그 확인
sudo journalctl -u bibleai -f

# 애플리케이션 업데이트
cd /opt/bibleai
./development-only/update-app.sh
```

## 📡 API 엔드포인트

### 성경 API
- `GET /api/bible/search?q={검색어}` - 성경 구절 검색
- `GET /api/bible/books` - 성경책 목록
- `GET /api/bible/chapters/{book}/{chapter}` - 장별 조회

### 찬송가 API
- `GET /api/hymns/search?q={검색어}` - 찬송가 검색
- `GET /api/hymns/{number}` - 특정 찬송가 조회
- `GET /api/hymns/theme/{theme}` - 주제별 찬송가

### 기도문 API (진행중)
- `GET /api/prayers/search?q={검색어}` - 기도문 검색
- `GET /api/tags` - 태그 목록
- `GET /api/prayers/by-tags?tags={ids}` - 태그별 기도문

**API 문서**: [API.md](docs/API.md)

## 🔐 환경 변수

`.env` 파일:
```env
# 데이터베이스
DB_HOST=localhost
DB_PORT=5432
DB_USER=bibleai
DB_PASSWORD=your_secure_password  # 필수!
DB_NAME=bibleai
DB_SSLMODE=disable

# 서버
PORT=8080
ENVIRONMENT=production
```

## 📚 문서

- [빠른 시작 가이드](docs/QUICK_START.md) - 5분 시작
- [Cloudflare 설정](docs/CLOUDFLARE_SETUP.md) - 무료 HTTPS ⭐
- [개발 가이드](docs/DEVELOPMENT.md) - 로컬 개발
- [API 레퍼런스](docs/API.md) - API 상세
- [Claude AI 참조](docs/CLAUDE.md) - AI 개발 컨텍스트

## 🚨 문제 해결

### 서버가 시작되지 않을 때

```bash
# 로그 확인
tail -f server.log  # 로컬
sudo journalctl -u bibleai -n 50  # EC2

# DB_PASSWORD 환경 변수 누락
# → .env 파일에 DB_PASSWORD 설정 필수
```

### DB 연결 실패

```bash
# PostgreSQL 상태 확인
systemctl status postgresql  # Linux
brew services list  # macOS

# 연결 테스트
psql -h localhost -U bibleai -d bibleai
```

### HTTPS 접속 안됨

```bash
# Cloudflare 설정 확인
# 1. DNS A 레코드 Proxied ☁️ 상태
# 2. SSL/TLS Flexible 모드
# 3. EC2 Security Group 8080 포트 개방
# 4. 애플리케이션 8080 포트 리스닝
```

## 🤝 기여

이슈 및 PR 환영합니다!

## 📄 라이선스

MIT License

---

**개발**: 2024-2025
**프로덕션**: https://haruinfo.net
**저장소**: https://github.com/SeanKimMel/bibleai
**업데이트**: 2025년 10월 4일
