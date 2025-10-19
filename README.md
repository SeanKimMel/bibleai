# 주님말씀AI 웹앱

**Go + PostgreSQL + Cloudflare**로 구현된 모바일 우선 성경 웹앱입니다.

**라이브**: https://haruinfo.net ⭐

## ✨ 주요 기능

### 사용자 기능
- ✅ **성경 검색**: 30,929개 구절 전체 텍스트 검색
- ✅ **찬송가**: 645개 새찬송가 (가사, 작곡가, 성경 참조)
- ✅ **키워드 기반 UI**: 사랑, 믿음, 소망 등 8개 주제별 콘텐츠
- ✅ **블로그**: 성경 말씀 기반 묵상 글 (SNS 공유 기능 포함)
- ✅ **모바일 최적화**: 반응형 디자인, PWA 준비
- ✅ **성능 최적화**: Critical CSS 인라인, 리소스 비차단 로딩
- ✅ **무료 HTTPS**: Cloudflare CDN + DDoS 보호

### 관리자 기능 (백오피스)
- ✅ **AI 블로그 생성**: Gemini API 기반 자동 블로그 작성
- ✅ **랜덤 키워드 지원**: 키워드 자동 선택으로 간편한 콘텐츠 생성
- ✅ **품질 자동 평가**: 5가지 지표로 콘텐츠 품질 평가 (신학적 정확성, 구조, 참여도, 기술, SEO)
- ✅ **찬송가 검증 강화**: 본문 찬송가 번호와 YouTube 임베딩 일치 자동 검증
- ✅ **재생성 시스템**: 평가 피드백 기반 자동 개선
- ✅ **YouTube 임베딩**: 찬송가 영상 자동 검색 및 임베딩
- ✅ **발행 관리**: 자동/수동 발행 제어
- ✅ **자동 스케줄링**: Cron/systemd를 통한 정기적 자동 발행

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

# 초기 환경 구축 (Go, PostgreSQL 설치)
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
4. **Origin Rules: 8080 포트 설정** ⭐
5. Security Group: 8080 포트 개방 (80 포트 불필요)

**상세 가이드**: [CLOUDFLARE_SETUP.md](docs/CLOUDFLARE_SETUP.md)

## 📁 프로젝트 구조

```
bibleai/
├── cmd/
│   ├── server/main.go           # 메인 서버 (포트 8080)
│   └── backoffice/main.go       # 백오피스 서버 (포트 9090)
├── internal/
│   ├── handlers/                # 메인 서버 핸들러
│   │   ├── pages.go            # 웹 페이지 라우팅
│   │   ├── bible_import.go     # 성경 검색 API
│   │   ├── hymns.go            # 찬송가 API
│   │   ├── prayers.go          # 기도문 API
│   │   └── blog.go             # 블로그 공개 API
│   ├── backoffice/              # 백오피스 핸들러
│   │   └── handlers.go         # 블로그 관리 API
│   ├── gemini/                  # Gemini API 클라이언트
│   │   └── client.go           # AI 블로그 생성/평가
│   ├── youtube/                 # YouTube 스크레이퍼
│   │   └── scraper.go          # 비디오 ID 검색
│   └── database/db.go          # PostgreSQL 연결
├── web/
│   ├── templates/pages/         # 메인 서버 템플릿
│   ├── backoffice/templates/    # 백오피스 템플릿
│   └── static/
│       ├── js/main.js          # JavaScript 유틸리티
│       └── sw.js               # Service Worker (PWA)
├── migrations/                  # DB 스키마 및 데이터
├── deploy.sh                    # 메인 서버 배포
├── deploy_backoffice.sh         # 백오피스 배포
├── start_backoffice.sh          # 백오피스 로컬 실행
└── development-only/            # 개발 스크립트
│   ├── setup-ec2.sh                  # EC2 초기 설정
│   ├── setup-nginx-letsencrypt.sh    # Nginx + Let's Encrypt (대안)
│   └── check-setup.sh                # 설정 확인
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
    ├── BibleAI App (8080 포트)          # 메인 서버
    ├── Backoffice App (9090 포트)       # 백오피스 서버
    └── PostgreSQL 16 (로컬)
```

**Security Group**:
- SSH: 22 (관리자 IP만)
- HTTP: 8080 (0.0.0.0/0 또는 Cloudflare IP만)
- HTTP: 9090 (관리자 IP만) - 백오피스 전용

### 백오피스 시스템

**접속**: http://localhost:9090 (로컬) 또는 http://SERVER:9090 (운영)

**주요 기능**:
- AI 블로그 자동 생성 (Gemini API, 랜덤 키워드 지원)
- 5가지 지표 품질 평가 (신학적 정확성, 구조, 참여도, 기술, SEO)
- 찬송가 제목 일치 검증 (본문 ↔ YouTube 임베딩)
- 평가 피드백 기반 재생성 (항상 가능)
- YouTube 찬송가 영상 자동 임베딩
- 발행 관리 (자동/수동)
- 자동 스케줄링 (Cron/systemd 지원)

**기술 스택**:
- Gemini API (google.golang.org/genai)
- YouTube 스크레이퍼
- Tailwind CSS 반응형 UI
- Cron/systemd (자동 발행)

## 📊 데이터베이스

- **성경**: 30,929 구절 (개역개정)
- **찬송가**: 29개 통합찬송가 (신찬송가 체계)
- **태그**: 10개 기본 태그 (감사, 위로, 용기 등)
- **기도문**: 진행 예정
- **블로그**: AI 생성 묵상 글 (품질 평가 포함)

## 🛠️ 개발 명령어

### 메인 서버

```bash
# 서버 관리
./server.sh start      # 시작 (포트 8080)
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

### 백오피스 서버

```bash
# 로컬 실행
./start_backoffice.sh  # 시작 (포트 9090)

# 운영 배포
./deploy_backoffice.sh # EC2 배포

# 환경변수 설정 필수
echo "GEMINI_API_KEY=your_key" >> .env

# 자동 스케줄링 설정 (선택)
# 매일 오전 6시 자동 블로그 생성
crontab -e
# 추가: 0 6 * * * /workspace/bibleai/scripts/auto_blog_generate.sh
# 상세 가이드: docs/AUTO_SCHEDULING.md
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

### 사용자 가이드
- [빠른 시작 가이드](docs/QUICK_START.md) - 5분 시작
- [Cloudflare 설정](docs/CLOUDFLARE_SETUP.md) - 무료 HTTPS ⭐
- [개발 가이드](docs/DEVELOPMENT.md) - 로컬 개발
- [API 레퍼런스](docs/API.md) - API 상세

### 백오피스 문서
- [자동 스케줄링 가이드](docs/AUTO_SCHEDULING.md) - Cron/systemd 설정 ⭐ NEW
- [Claude AI 참조](docs/CLAUDE.md) - AI 개발 컨텍스트

### 작업 일지
- [2025-10-19: 찬송가 검증 강화 & 자동 스케줄링](docs/2025-10-19-hymn-title-validation-and-scheduling.md)
- [2025-10-18: 백오피스 개선](docs/2025-10-18-backoffice-improvements.md)
- [2025-10-16: Gemini 평가 시스템](docs/2025-10-16-gemini-blog-evaluation.md)

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
