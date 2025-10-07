# SEO 최적화 및 배포 가이드

## 📋 목차
1. [SEO 최적화](#seo-최적화)
2. [배포 시스템](#배포-시스템)
3. [Google/Naver 등록](#구글네이버-검색엔진-등록)

---

## 🎯 SEO 최적화

### 구현 완료 항목 (2025년 10월 7일)

#### 1. robots.txt
- **위치**: `web/static/robots.txt`
- **기능**: 검색엔진 크롤러 허용/차단 규칙
- **지원**: Google, Naver, Bing
- **접근**: https://bibleai.wiki/robots.txt

```txt
User-agent: *
Allow: /

User-agent: Googlebot
Allow: /

User-agent: Yeti        # Naver Bot
Allow: /

Disallow: /api/admin/
Disallow: /static/

Sitemap: https://bibleai.wiki/sitemap.xml
```

#### 2. sitemap.xml (동적 생성)
- **핸들러**: `internal/handlers/pages.go:110` - `GenerateSitemap()`
- **특징**: 코드 수정 시 자동 반영
- **접근**: https://bibleai.wiki/sitemap.xml

**등록된 페이지**:
- `/` (홈페이지, priority: 1.0, changefreq: daily)
- `/bible/search` (성경 검색, priority: 0.9)
- `/bible/analysis` (키워드 분석, priority: 0.8)
- `/hymns` (찬송가, priority: 0.8)
- `/prayers` (기도문, priority: 0.8)

**구조**:
```xml
<url>
  <loc>https://bibleai.wiki/</loc>
  <lastmod>2025-10-07</lastmod>
  <changefreq>daily</changefreq>
  <priority>1.0</priority>
</url>
```

#### 3. SEO 메타 태그
- **위치**: `web/templates/layout/base.html:8-42`
- **적용**: 모든 페이지 공통

**포함된 메타 태그**:
```html
<!-- 기본 SEO -->
<meta name="description" content="성경, 찬송가, 기도문을 한 곳에서...">
<meta name="keywords" content="성경, 찬송가, 기도문, 성경검색...">
<meta name="author" content="주님말씀AI">
<meta name="robots" content="index, follow">
<link rel="canonical" href="https://bibleai.wiki{{.CurrentPath}}">

<!-- Geo 타겟팅 (서울/한국) -->
<meta name="geo.region" content="KR-11">
<meta name="geo.placename" content="Seoul, South Korea">
<meta name="geo.position" content="37.5665;126.9780">

<!-- Open Graph (소셜 공유) -->
<meta property="og:type" content="website">
<meta property="og:title" content="{{.Title}} - 주님말씀AI">
<meta property="og:description" content="{{.Description}}">
<meta property="og:url" content="https://bibleai.wiki{{.CurrentPath}}">
<meta property="og:locale" content="ko_KR">

<!-- Twitter Card -->
<meta name="twitter:card" content="summary_large_image">
<meta name="twitter:title" content="{{.Title}} - 주님말씀AI">
```

#### 4. 페이지별 동적 메타 태그
- **위치**: `internal/handlers/pages.go`
- **전달 변수**: `Description`, `CurrentPath`

**페이지별 설명**:
```go
// 홈페이지
"Description": "성경, 찬송가, 기도문을 키워드로 통합 검색하세요..."

// 성경 검색
"Description": "키워드로 성경 구절을 빠르게 검색하세요. 66권 성경 전체..."

// 찬송가
"Description": "새찬송가 645곡 전체를 검색하고 감상하세요..."

// 기도문
"Description": "상황과 주제에 맞는 기도문을 태그로 찾아보세요..."
```

#### 5. 구조화된 데이터 (JSON-LD)
- **위치**: `web/templates/layout/base.html:44-69`
- **타입**: Schema.org WebSite

```json
{
  "@context": "https://schema.org",
  "@type": "WebSite",
  "name": "주님말씀AI",
  "url": "https://bibleai.wiki",
  "description": "성경, 찬송가, 기도문을 한 곳에서...",
  "potentialAction": {
    "@type": "SearchAction",
    "target": "https://bibleai.wiki/bible/search?q={search_term_string}"
  },
  "inLanguage": "ko-KR",
  "geo": {
    "@type": "GeoCoordinates",
    "latitude": "37.5665",
    "longitude": "126.9780"
  }
}
```

---

## 🚀 배포 시스템

### 배포 스크립트: `deploy.sh`

#### 특징
- ✅ ARM64 바이너리 빌드 (EC2 Graviton 최적화)
- ✅ rsync 기반 빠른 전송
- ✅ SSH 연결 자동 테스트
- ✅ 배포 로그 자동 저장
- ✅ 설정 파일 분리 (보안)

#### 설정 파일

**`deploy.config.example`** (Git에 커밋):
```bash
# 배포 설정 파일 예시
SERVER_USER="ec2-user"
SERVER_HOST="your-ec2-ip-here"
SSH_KEY="/path/to/your/key.pem"
SSH_PORT="22"
SERVER_PATH="/home/ec2-user/bibleai"
```

**`deploy.config`** (Git에서 제외):
```bash
# 실제 배포 설정
SERVER_USER="ec2-user"
SERVER_HOST="13.209.47.72"        # 실제 IP
SSH_KEY="/workspace/bibleai-ec2-key.pem"
SSH_PORT="22"
SERVER_PATH="/home/ec2-user/bibleai"
```

#### 초기 설정

```bash
# 1. 설정 파일 생성
cp deploy.config.example deploy.config

# 2. 실제 값 입력
nano deploy.config
# SERVER_HOST: EC2 Public IP
# SSH_KEY: SSH 키 파일 경로

# 3. SSH 키 권한 설정
chmod 400 /path/to/your-key.pem
```

#### 배포 실행

```bash
# 배포 시작
./deploy.sh
```

#### 배포 프로세스

**1단계: SSH 연결 테스트**
- SSH 포트(22) 접근 확인
- SSH 키 인증 테스트
- 실패 시 상세 에러 메시지

**2단계: 빌드 및 전송**
```bash
# ARM64 바이너리 빌드
GOOS=linux GOARCH=arm64 CGO_ENABLED=0 go build -ldflags="-s -w" -o bibleai

# 전송되는 파일
bibleai                  # 바이너리 (~20MB)
web/templates/           # HTML 템플릿
web/static/              # CSS, JS, robots.txt 등

# 제외되는 파일
.git/                    # Git 정보
*.log                    # 로그 파일
cmd/, internal/          # Go 소스코드
migrations/              # 마이그레이션
*.sh                     # 스크립트
```

**3단계: 서버 재시작**
- 기존 프로세스 종료 (`pkill bibleai`)
- 바이너리 실행 권한 부여
- 새 프로세스 시작 (백그라운드)
- 프로세스 상태 확인

#### 배포 로그

**자동 저장**:
```bash
logs/deploy_20251007_150151.log
```

**로그 형식**:
```
[2025-10-07 15:01:51] =========================================
[2025-10-07 15:01:51] 배포 시작
[2025-10-07 15:01:51] 서버: 13.209.47.72
[2025-10-07 15:01:51] 경로: /home/ec2-user/bibleai
[2025-10-07 15:01:51] =========================================
[2025-10-07 15:01:51] ✅ SSH 포트 연결 성공
[2025-10-07 15:01:53] ✅ SSH 인증 성공
[2025-10-07 15:01:53] ✅ 빌드 완료 (크기: 20M)
[2025-10-07 15:02:01] ✅ 배포 완료!
```

**로그 확인**:
```bash
# 최신 로그
ls -lt logs/

# 특정 로그 보기
cat logs/deploy_20251007_150151.log

# 서버 로그 실시간 확인
ssh -i /path/to/key.pem ec2-user@13.209.47.72 'tail -f /home/ec2-user/bibleai/server.log'
```

#### 배포 성능

| 항목 | 수치 |
|------|------|
| **바이너리 크기** | ~20MB |
| **전송 속도** | ~1.8MB/s |
| **총 소요 시간** | ~10초 |
| **파일 개수** | 14개 (HTML) + 정적 파일 |

#### Git 보안 설정

**`.gitignore` 추가 항목**:
```bash
# 배포 관련
deploy_*.log        # 배포 로그
deploy.config       # 실제 배포 설정 (민감 정보)
*.pem               # SSH 키 파일
*.key               # 기타 키 파일
logs/               # 로그 디렉토리
```

**Git에 커밋되는 파일**:
- ✅ `deploy.sh` (배포 스크립트)
- ✅ `deploy.config.example` (설정 템플릿)

**Git에서 제외되는 파일**:
- ❌ `deploy.config` (실제 설정)
- ❌ `*.pem` (SSH 키)
- ❌ `logs/` (배포 로그)

---

## 🌐 구글/네이버 검색엔진 등록

### Google Search Console

#### 1. 사이트 등록
1. https://search.google.com/search-console 접속
2. **속성 추가** 클릭
3. **URL 접두어** 선택: `https://bibleai.wiki`
4. 소유권 확인 (HTML 태그 방식 권장)

#### 2. 소유권 확인
**메타 태그 추가**:
```html
<!-- base.html:42 -->
<meta name="google-site-verification" content="YOUR_VERIFICATION_CODE">
```

배포 후 "확인" 버튼 클릭

#### 3. Sitemap 제출
1. Search Console → **Sitemaps** 메뉴
2. 새 사이트맵 추가: `https://bibleai.wiki/sitemap.xml`
3. 제출 완료

#### 4. 색인 요청
- URL 검사 도구로 주요 페이지 색인 요청
- 일반적으로 2-7일 후 검색 결과 노출 시작

---

### Naver 웹마스터 도구

#### 1. 사이트 등록
1. https://searchadvisor.naver.com 접속
2. **사이트 등록** 클릭
3. URL 입력: `https://bibleai.wiki`

#### 2. 소유권 확인
**메타 태그 추가**:
```html
<!-- base.html:39 -->
<meta name="naver-site-verification" content="YOUR_VERIFICATION_CODE">
```

배포 후 "소유확인" 버튼 클릭

#### 3. 사이트맵 제출
1. 웹마스터 도구 → **요청** → **사이트맵 제출**
2. URL 입력: `https://bibleai.wiki/sitemap.xml`
3. 제출 완료

#### 4. RSS 제출 (선택사항)
- 블로그/뉴스 콘텐츠가 있을 경우
- 현재 프로젝트는 해당 없음

---

## 📊 SEO 체크리스트

### 배포 후 확인 사항

#### 필수 항목
- [ ] robots.txt 접근 확인: https://bibleai.wiki/robots.txt
- [ ] sitemap.xml 접근 확인: https://bibleai.wiki/sitemap.xml
- [ ] 메타 태그 확인 (페이지 소스 보기)
- [ ] Open Graph 미리보기 (소셜 공유 시)
- [ ] 모바일 반응형 확인
- [ ] 페이지 로딩 속도 (<3초)

#### Google Search Console
- [ ] 사이트 등록
- [ ] 소유권 확인 메타 태그 추가
- [ ] Sitemap 제출
- [ ] 주요 페이지 색인 요청

#### Naver 웹마스터
- [ ] 사이트 등록
- [ ] 소유권 확인 메타 태그 추가
- [ ] Sitemap 제출

#### 성능 최적화
- [ ] 이미지 최적화
- [ ] CSS/JS 압축 (향후)
- [ ] 캐싱 헤더 설정 (향후)
- [ ] CDN 적용 (Cloudflare 사용 중)

---

## 🔧 문제 해결

### 배포 실패 시

**SSH 연결 실패**:
```bash
# OpenVPN 연결 확인
# EC2 보안그룹 22번 포트 확인
# SSH 키 권한 확인
chmod 400 /path/to/key.pem
```

**빌드 실패**:
```bash
# Go 버전 확인
go version  # 1.21 이상 필요

# 의존성 업데이트
go mod tidy
go mod download
```

**서버 시작 실패**:
```bash
# 서버 로그 확인
ssh -i /path/to/key.pem ec2-user@13.209.47.72 'tail -50 /home/ec2-user/bibleai/server.log'

# 프로세스 확인
ssh -i /path/to/key.pem ec2-user@13.209.47.72 'ps aux | grep bibleai'

# 수동 실행
ssh -i /path/to/key.pem ec2-user@13.209.47.72
cd /home/ec2-user/bibleai
./bibleai
```

### SEO 문제 해결

**검색 노출 안됨**:
- Google/Naver 등록 완료 후 2-7일 대기
- robots.txt에서 크롤러 차단 여부 확인
- sitemap.xml에 페이지 포함 여부 확인

**메타 태그 미적용**:
- 배포 후 브라우저 캐시 삭제 (Ctrl+Shift+R)
- 페이지 소스 보기로 실제 HTML 확인
- Go 핸들러에서 변수 전달 확인

**Sitemap 오류**:
- XML 문법 확인
- URL이 https로 시작하는지 확인
- 실제 접근 가능한 URL인지 확인

---

## 📈 예상 결과

### 검색 노출 타임라인

| 기간 | 예상 결과 |
|------|-----------|
| **1-3일** | Google/Naver 크롤러 첫 방문 |
| **3-7일** | 주요 페이지 색인 시작 |
| **1-2주** | 브랜드 검색 노출 ("주님말씀AI") |
| **2-4주** | 롱테일 키워드 노출 시작 |
| **1-3개월** | 주요 키워드 순위 안정화 |

### 타겟 키워드

**1차 타겟** (브랜드):
- 주님말씀AI
- 주님말씀 AI
- bibleai

**2차 타겟** (핵심 기능):
- 성경 검색
- 찬송가 검색
- 기도문 찾기
- 성경 키워드 검색

**3차 타겟** (롱테일):
- 새찬송가 가사
- 상황별 기도문
- 성경구절 키워드
- 모바일 성경 앱

---

## 📝 추가 최적화 (향후)

### 콘텐츠 SEO
- [ ] 페이지별 고유한 제목 최적화
- [ ] 메타 설명 길이 최적화 (150-160자)
- [ ] 헤딩 태그 구조화 (H1, H2, H3)
- [ ] 내부 링크 구조 개선
- [ ] 이미지 alt 텍스트 추가

### 기술 SEO
- [ ] 페이지 로딩 속도 최적화 (<2초)
- [ ] Core Web Vitals 개선
- [ ] 모바일 사용성 개선
- [ ] 구조화된 데이터 확장 (BreadcrumbList 등)
- [ ] AMP 적용 검토

### 로컬 SEO
- [ ] Google My Business 등록 검토
- [ ] 지역 키워드 최적화
- [ ] 로컬 백링크 구축

---

**작성일**: 2025년 10월 7일
**최근 업데이트**: 2025년 10월 7일
**작성자**: Claude AI
**프로젝트**: 주님말씀AI 웹앱
**버전**: v1.0
