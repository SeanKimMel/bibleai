# Claude AI 참조 문서 (CLAUDE.md)

이 문서는 Claude AI가 주님말씀AI 웹앱 프로젝트를 이해하고 지속적으로 개발할 수 있도록 작성된 종합 참조 자료입니다.

## 🚨 세션 시작 시 필수 확인사항

**모든 Claude 세션 시작 시 반드시 다음을 확인하세요:**

1. **최근 작업 일지 확인**: `/workspace/bibleai/docs/` 폴더에서 가장 최근 날짜의 작업 일지 파일을 찾아 읽으세요
   - 파일 패턴: `YYYY-MM-DD-*.md` (예: `2025-10-13-keyword-array-implementation.md`)
   - 최근 작업 내역, 완료된 사항, 남은 작업(TODO)을 확인
   - 작업 일지가 없다면 이 파일(CLAUDE.md)의 "현재 개발 상태" 섹션 참조

2. **작업 연속성 유지**: 작업 일지의 "남은 작업" 섹션에서 다음 우선순위 작업을 확인하고 이어서 진행

3. **새 작업 시작 전**: 중복 작업을 방지하기 위해 기존 작업 일지를 먼저 확인

### 작업 일지 찾기 명령
```bash
# 가장 최근 작업 일지 찾기
ls -t /workspace/bibleai/docs/2*.md | head -1

# 모든 작업 일지 목록 (최신순)
ls -t /workspace/bibleai/docs/2*.md
```

## 🎯 프로젝트 컨텍스트

### 프로젝트 정체성
- **프로젝트명**: 주님말씀AI 웹앱
- **목적**: 모바일 최적화된 바이블 웹앱
- **핵심 기능**: 키워드 기반 콘텐츠 검색, 성경 검색, 찬송가, 기도문 찾기
- **타겟 사용자**: 기독교 신자, 모바일 사용자
- **개발 철학**: 직관적, 접근성 우선, 모바일 퍼스트, API 우선 설계

### 현재 개발 상태 (2025년 9월 29일 기준)
```
✅ 1단계: 기본 프로젝트 설정 (완료)
✅ 2단계: 기본 웹 서버 구현 (완료)
✅ 3단계: 키워드 중심 UI 구현 (완료)
✅ 4단계: 성경 검색 기능 완성 (완료)
✅ 5단계: 찬송가 시스템 완성 (완료)
✅ 5.5단계: 키워드 탭 완전 일관성 구현 (완료)
✅ 5.7단계: UI 일관성 및 기술적 최적화 (완료)
🔄 6단계: 태그/기도문 API 시스템 (다음 단계)
⏳ 7단계: 실제 데이터 확장 및 완성 (향후)
```

### 기술 스택 요약
- **Backend**: Go 1.23+ + Gin Framework
- **Database**: PostgreSQL 16 (로컬 설치)
- **Frontend**: Go HTML Templates + Tailwind CSS + Vanilla JS
- **개발 도구**: Air (hot reload), Docker (애플리케이션)

## 📁 프로젝트 구조 이해

### 핵심 디렉토리
```
bibleai/
├── cmd/server/main.go          # 애플리케이션 진입점 ⭐
├── internal/
│   ├── handlers/pages.go       # 웹 페이지 핸들러 ⭐
│   ├── database/db.go          # DB 연결 ⭐
│   └── models/                 # 데이터 모델 (향후)
├── web/
│   ├── templates/layout/base.html    # 기본 레이아웃 ⭐
│   ├── templates/pages/*.html        # 페이지 템플릿들 ⭐
│   └── static/js/main.js            # 메인 JavaScript ⭐
├── migrations/001_initial.sql  # 기존 DB 스키마
├── init.sql                    # 로컬 PostgreSQL 초기화 스크립트 ⭐
├── init-db.sh                  # 데이터베이스 초기화 실행 스크립트 ⭐
├── Dockerfile                  # 애플리케이션 Docker 이미지 ⭐
├── docker-compose.yml          # 애플리케이션 Docker 설정 ⭐
├── *.sh                        # 실행 스크립트들 ⭐
└── *.md                        # 문서들
```

### 현재 활성화된 파일 목록 (v0.5.0-stable)

#### 🚀 핵심 애플리케이션 파일
**서버 & 핸들러**
- `cmd/server/main.go` - 메인 서버, 라우팅, 템플릿 로딩
- `internal/database/db.go` - PostgreSQL 연결 관리
- `internal/handlers/pages.go` - 5개 웹페이지 핸들러
- `internal/handlers/bible_import.go` - 성경 검색/장별 보기 API (24KB)
- `internal/handlers/hymns.go` - 찬송가 검색 API (10KB)
- `internal/handlers/prayers.go` - 기도문 관련 API (미완성)

**프론트엔드 템플릿**
- `web/templates/layout/base.html` - 공통 레이아웃 (13KB)
- `web/templates/pages/bible-analysis.html` - 키워드 홈페이지 (24KB) ⭐
- `web/templates/pages/bible-search.html` - 성경 검색 + 장별 보기 (31KB) ⭐
- `web/templates/pages/a-prayers.html` - 기도문 찾기 페이지 (28KB)
- `web/templates/pages/hymns.html` - 찬송가 검색 + 상세 보기 페이지 (14KB) ⭐

**JavaScript & 정적 파일**
- `web/static/js/main.js` - 공통 유틸리티, PWA 준비 (12KB)
- `web/static/sw.js` - Service Worker (PWA 지원)

#### 🛠️ 개발/배포 스크립트
**주요 관리 스크립트**
- `server.sh` - 서버 관리 (start/stop/status/logs/test) ⭐
- `init-db.sh` - 데이터베이스 초기화 ⭐
- `start.sh` - 일반 실행 (로컬 PostgreSQL + Go 서버)
- `dev.sh` - 개발모드 (Air 자동 재시작)
- `stop.sh` - 애플리케이션 종료

**테스트 스크립트**
- `test_api.sh` - API 테스트
- `bible_search_test.sh` - 성경 검색 테스트
- `final_api_test.sh` - 통합 테스트

#### 🗄️ 데이터베이스 관련
**스키마 & 마이그레이션**
- `init.sql` - 로컬 PostgreSQL 초기화 ⭐
- `migrations/001_initial.sql` - 기본 DB 스키마
- `migrations/002_bible_schema_update.sql` - 성경 스키마 업데이트
- `migrations/002_hymns_data.sql` - 찬송가 데이터

**데이터 파일**
- `prayer_data.sql` - 기도문 샘플 데이터
- `prayer_tags_data.sql` - 기도문-태그 연결 데이터

#### 🐳 Docker 설정
- `Dockerfile` - 애플리케이션 Docker 이미지 ⭐
- `docker-compose.yml` - Docker 환경 설정 ⭐

#### 📚 문서 파일
**핵심 문서**
- `CLAUDE.md` - Claude AI 참조 문서 (이 파일) ⭐
- `README.md` - 프로젝트 개요
- `API.md` - API 문서
- `DEVELOPMENT.md` - 개발 가이드

### 📊 파일 중요도 분류

#### ⭐ 필수 핵심 파일 (삭제 시 앱 동작 불가)
1. `cmd/server/main.go` - 서버 진입점
2. `internal/database/db.go` - DB 연결
3. `internal/handlers/pages.go` - 페이지 라우팅
4. `internal/handlers/bible_import.go` - 성경 API
5. `web/templates/layout/base.html` - 레이아웃
6. `web/templates/pages/bible-analysis.html` - 홈페이지
7. `web/templates/pages/bible-search.html` - 성경 검색
8. `init.sql` - 데이터베이스 초기화
9. `server.sh` - 서버 관리 스크립트

#### 🔧 중요 파일 (기능 저하 발생)
1. `internal/handlers/hymns.go` - 찬송가 검색/상세보기 기능
2. `web/templates/pages/hymns.html` - 찬송가 페이지 (모달 포함)
3. `web/templates/pages/a-prayers.html` - 기도문 페이지
4. `web/static/js/main.js` - 공통 JavaScript
5. `init-db.sh` - DB 설치 스크립트

#### 📝 보조 파일 (개발/관리용)
1. 테스트 스크립트들 (`*_test.sh`)
2. 개발 스크립트들 (`dev.sh`, `start.sh`, `stop.sh`)
3. 문서 파일들 (`*.md`)
4. Docker 설정 파일들

### 🗑️ 사용되지 않는 파일들 (레거시)
```
web/templates/pages/z-home.html              # 이전 홈페이지 (미사용)
web/templates/pages/bible-search-standalone.html  # 이전 독립 페이지
web/templates/pages/hymns-new.html           # 개발 중 템플릿
test_bible_search.html                       # 테스트용 HTML
```

### 🔗 페이지별 템플릿 매핑 (현재 활성)
| URL 경로 | 핸들러 함수 | 템플릿 파일 | 용도 |
|---------|------------|------------|------|
| `/` | `HomePage()` | `bible-analysis.html` | 키워드 홈페이지 ⭐ |
| `/bible/search` | `BibleSearchPage()` | `bible-search.html` | 성경 검색 + 장별 보기 ⭐ |
| `/bible/analysis` | `BibleAnalysisPage()` | `bible-analysis.html` | 키워드 분석 (홈과 동일) |
| `/hymns` | `HymnsPage()` | `hymns.html` | 찬송가 검색 |
| `/prayers` | `PrayersPage()` | `a-prayers.html` | 기도문 찾기 |

### 🌐 API 엔드포인트별 핸들러 매핑
| API 경로 | 핸들러 함수 | 파일 위치 | 상태 |
|---------|------------|----------|------|
| `GET /api/bible/search` | `SearchBible()` | `bible_import.go` | ✅ 완전 동작 |
| `GET /api/bible/books` | `GetBibleBooks()` | `bible_import.go` | ✅ 완전 동작 |
| `GET /api/bible/chapters/:book/:chapter` | `GetBibleChapter()` | `bible_import.go` | ✅ 완전 동작 |
| `GET /api/hymns/search` | `SearchHymns()` | `hymns.go` | ✅ 완전 동작 |
| `GET /api/hymns/:number` | `GetHymnByNumber()` | `hymns.go` | ✅ 완전 동작 |
| `GET /api/hymns/theme/:theme` | `GetHymnsByTheme()` | `hymns.go` | ✅ 완전 동작 |
| `POST /api/admin/import/hymns` | `ImportHymnsData()` | `hymns.go` | ✅ 완전 동작 |
| `GET /api/prayers/by-tags` | `GetPrayersByTags()` | `prayers.go` | ⏳ 미완성 |

### 💾 현재 버전 파일 통계
- **총 파일 수**: 45개
- **핵심 코드 파일**: 9개 (Go: 5개, HTML: 4개)
- **스크립트 파일**: 13개
- **문서 파일**: 9개
- **설정 파일**: 4개
- **레거시 파일**: 4개 (정리 가능)
- **총 코드 크기**: ~200KB
- **데이터베이스**: 30,929 성경구절 + 29개 실제 찬송가 + 기본 태그

## 🗄️ 데이터베이스 스키마

### 핵심 테이블 관계
```
prayers (기도문)
    ↓ 1:N
prayer_tags (연결테이블)
    ↓ N:1
tags (태그)

별도 테이블:
- bible_verses (성경구절)
- hymns (찬송가)
```

### 기본 태그 (10개)
감사, 위로, 용기, 회개, 치유, 지혜, 평강, 가족, 직장, 건강

### 테이블별 주요 컬럼
```sql
prayers: id, title, content, created_at, updated_at
tags: id, name(unique), description, created_at
prayer_tags: prayer_id(FK), tag_id(FK) -- 복합 PK
bible_verses: id, book, chapter, verse, content, version, book_id, testament, book_name_korean,
              chapter_title, chapter_summary, chapter_themes, chapter_context, chapter_application
hymns: id, number(unique), new_hymn_number, title, lyrics, theme, composer, author, tempo, key_signature, bible_reference, external_link
```

### 📖 찬송가 데이터 현황 (2025-10-11 업데이트)

**총 찬송가**: 645개 (통합찬송가)

**메타데이터 완성도**:
- ✅ **기본 정보**: 645개 (100%) - 번호, 제목, 가사
- ✅ **성경구절**: 569개 (88.2%) - hbible.co.kr 스크레이핑 + 인기 찬송가 수작업
- ❌ **작곡가**: 0개 (0%) - 온라인 소스 없음
- ❌ **작사가**: 0개 (0%) - 온라인 소스 없음
- ✅ **외부링크**: 645개 (100%) - hymnkorea.org

**성경구절 데이터 예시**:
- 1장: 시편 100:5
- 8장: 요한계시록 4:6-8
- 153장: 요한복음 19:2 (가시 면류관)
- 252장: 요한1서 1:7 (나의 죄를 씻기는)
- 371장: 마가복음 4:39 (구주여 광풍이 불어)

**데이터 수집 방법**:
- **1차**: Python 스크레이핑 537개 (`scripts/scrape_hymn_bible_references.py`)
- **2차**: 인기 찬송가 30개 수작업 (`scripts/generate_popular_30_refs.py`)
- **마이그레이션**: `migrations/008_update_hymn_bible_references.sql`, `migrations/009_popular_hymns_bible_references.sql`
- **수집일**: 2025-10-11

### 📖 성경 해석 시스템 (Bible Commentary)

**구현 방식**: 별도 테이블 대신 `bible_verses` 테이블에 컬럼 추가 방식 채택

**해석 데이터 컬럼들**:
- `chapter_title` (VARCHAR 200): 장의 핵심 주제 제목
- `chapter_summary` (TEXT): 장 전체 흐름과 내용 요약 (200-400자)
- `chapter_themes` (TEXT): 주요 주제들 JSON 배열 형태
- `chapter_context` (TEXT): 역사적, 신학적 배경 설명
- `chapter_application` (TEXT): 현대적 적용과 영적 교훈

**🔑 핵심 저장 방식**:
- **각 장의 첫 번째 구절(verse=1)에만** 해석 데이터 저장
- 같은 장의 나머지 구절들(verse>1)은 해석 컬럼이 NULL
- API 호출 시 해당 장의 1절에서 해석 데이터를 가져와 전체 장에 적용

**데이터 조회 예시**:
```sql
-- 창세기 22장 해석 조회
SELECT chapter_title, chapter_summary, chapter_themes
FROM bible_verses
WHERE book_id = 'gn' AND chapter = 22 AND verse = 1;

-- 모든 창세기 장 해석 목록
SELECT chapter, chapter_title
FROM bible_verses
WHERE book_id = 'gn' AND verse = 1 AND chapter_title IS NOT NULL
ORDER BY chapter;
```

**API 응답 구조**:
```json
{
  "book": "gn", "chapter": 22,
  "commentary": {
    "title": "아브라함의 최고 시험",
    "summary": "하나님께서 아브라함에게 독자 이삭을...",
    "themes": "[\"최고의 시험\", \"이삭 제사\", \"절대 순종\"]",
    "context": "구약에서 가장 감동적인 믿음의 시험으로...",
    "application": "하나님에 대한 절대적 신뢰와 순종의 의미..."
  },
  "verses": [...]
}
```

## 🎨 UI/UX 가이드라인

### 디자인 시스템
```css
/* 컬러 팔레트 */
Primary: Blue-600 (#2563EB)     // 기본
Success: Green-600 (#059669)    // 기도문
Hymns: Purple-600 (#9333EA)     // 찬송가  
Analysis: Orange-600 (#EA580C)  // 감정분석
Warning: Yellow-500 (#EAB308)
Error: Red-600 (#DC2626)

/* 재사용 컴포넌트 클래스 */
.btn-primary    // 파란색 기본 버튼
.btn-secondary  // 회색 보조 버튼
.card           // 흰색 카드 컨테이너
```

### 모바일 최적화 원칙
- 최대 너비: 28rem (448px)
- 터치 친화적 버튼 크기
- 큰 텍스트, 명확한 아이콘
- 하단 네비게이션 (ShowNavigation: true)
- 뒤로가기 버튼 (ShowBackButton: true)

### 페이지별 색상 체계
- 키워드(홈): Orange (주요 기능)
- 성경검색: Blue
- 기도문: Green
- 찬송가: Purple
- 오늘의 키워드: Orange

## 📄 템플릿 시스템 이해

### 템플릿 구조
```go
// 모든 페이지는 base.html을 확장
{{template "base.html" .}}
{{define "content"}}
    <!-- 페이지별 내용 -->
{{end}}
```

### 핸들러에서 템플릿 데이터 전달
```go
c.HTML(http.StatusOK, "page-name.html", gin.H{
    "Title": "페이지 제목",
    "ShowBackButton": true,     // 뒤로가기 표시
    "ShowNavigation": true,     // 하단 네비 표시
    "Tags": tagData,           // 페이지별 데이터
})
```

### 중요한 템플릿 변수들
- `Title`: 페이지 제목 (브라우저 탭)
- `ShowBackButton`: 상단 뒤로가기 버튼 표시 여부
- `ShowNavigation`: 하단 네비게이션 바 표시 여부
- 페이지별 커스텀 데이터 (Tags, Prayers 등)

## 🎯 API 우선 개발 규칙

### 핵심 원칙
**모든 동작은 API로 진행되어야 하고, 프론트엔드에서는 API를 호출하여 페이지를 구성하여야 한다.**

### 필수 준수사항
1. **데이터 로딩**: 모든 데이터는 API 엔드포인트를 통해서만 가져온다
2. **하드코딩 금지**: JavaScript에 데이터를 직접 하드코딩하지 않는다
3. **API 우선 설계**: 새 기능 개발시 API부터 먼저 구현한다
4. **일관된 응답 형식**: 모든 API는 JSON 형식으로 응답한다

### API 응답 표준 형식
```json
// 표준 형식 (권장)
{
    "success": true,
    "data": {},
    "message": "성공 메시지",
    "total": 100,
    "query": "검색어"
}

// 실제 성경 검색 API 응답 (현재 구현)
{
    "query": "사랑",
    "results": [...],
    "total": 100
}
```

### 현재 API 엔드포인트 현황 (검증됨)
```
✅ GET /api/bible/search?q={keyword}     # 성경구절 검색 - 완전 동작
✅ GET /api/hymns/search?q={keyword}     # 찬송가 검색 - 완전 동작
✅ GET /api/hymns/{number}               # 특정 찬송가 조회 - 완전 동작
✅ GET /api/hymns/theme/{theme}          # 주제별 찬송가 - 완전 동작
⏳ GET /api/prayers/search?q={keyword}   # 기도문 검색 (구현 필요)
⏳ GET /api/tags                         # 태그 목록 (구현 필요)
⏳ GET /api/prayers/by-tags?tags={ids}   # 태그별 기도문 (구현 필요)
```

### 최근 해결된 API 이슈
- **성경 검색 API**: 2025년 1월 27일 프론트엔드 연동 완료
- **응답 파싱 오류**: `data.success` 필드 체크 제거로 해결
- **검증 결과**: 100개 검색 결과 정상 표시
- **찬송가 상세 보기**: 2025년 1월 28일 ID/Number 매개변수 오류 수정
- **찬송가 데이터베이스**: 29개 실제 통합찬송가 데이터로 교체 완료

### 위반 사례 및 해결 방법
❌ **잘못된 예시** (하드코딩):
```javascript
const prayers = {
    '사랑': [{ title: '사랑의 기도', content: '...' }]
};
```

✅ **올바른 예시** (API 호출):
```javascript
async function loadPrayersByKeyword(keyword) {
    const response = await fetch(`/api/prayers/search?q=${keyword}`);
    const data = await response.json();
    return data.prayers || [];
}
```

### 개발 우선순위
1. **API 엔드포인트 구현** → 2. **프론트엔드 연동** → 3. **UI/UX 개선**

## 🛠️ 개발 워크플로우

### 🚀 최초 설정 (한 번만 실행)
```bash
# 1. 로컬 PostgreSQL 서비스 시작
# macOS: brew services start postgresql
# Ubuntu: sudo systemctl start postgresql
# Windows: PostgreSQL 서비스 시작

# 2. 데이터베이스 초기화 (최초 1회만)
./init-db.sh
```

### 📋 스크립트 사용법 (검증됨)
```bash
# 🚀 서버 관리 스크립트 (권장) ⭐⭐⭐
./server.sh start     # 서버 시작
./server.sh stop      # 서버 중지
./server.sh restart   # 서버 재시작
./server.sh status    # 서버 상태 확인 (Health, DB, 성경 데이터 통계)
./server.sh logs      # 서버 로그 실시간 보기
./server.sh test      # API 테스트 (Health, 성경검색, 기도문)

# ✅ 2025년 1월 27일 검증 완료
# - 성경 검색 API: 100개 결과 정상 반환
# - 페이지 로딩: HTTP 200 정상
# - 프론트엔드 연동: 완전 동작

# 기존 스크립트들
./init-db.sh  # 데이터베이스 초기화 (최초 1회만) ⭐
./start.sh    # 일반 실행 (로컬 PostgreSQL + Go 서버)
./dev.sh      # 개발모드 (자동 재시작, Air 사용)
./stop.sh     # 애플리케이션 종료 (로컬 PostgreSQL은 유지)

# Docker 실행
docker-compose up --build  # 애플리케이션을 Docker로 실행
```

### 🔧 환경별 PostgreSQL 시작 방법
```bash
# macOS (Homebrew)
brew services start postgresql
brew services stop postgresql

# Ubuntu/Debian
sudo systemctl start postgresql
sudo systemctl stop postgresql

# Windows
# 서비스 관리자에서 PostgreSQL 서비스 시작/중지
```

### 새 페이지 추가 순서
1. `web/templates/pages/new-page.html` 생성
2. `internal/handlers/pages.go`에 핸들러 함수 추가
3. `cmd/server/main.go`에 라우트 등록
4. `r.LoadHTMLFiles()`에 템플릿 파일 추가

### 새 API 추가 순서
1. `internal/handlers/`에 새 핸들러 파일 생성
2. `cmd/server/main.go`에 API 라우트 등록
3. 필요시 `internal/models/`에 데이터 모델 추가
4. 데이터베이스 변경시 `migrations/`에 SQL 파일 추가

## 🎯 키워드 기반 콘텐츠 시스템 구현 현황

### 핵심 로직
1. 홈페이지에서 키워드 선택 (8개 고정 키워드)
2. 선택된 키워드로 기도문, 성경구절, 찬송가 동시 검색
3. 탭 기반으로 카테고리별 결과 표시
4. 각 콘텐츠를 카드 형태로 표시

### 현재 상태 (5단계 완료)
- **키워드 UI**: ✅ 완전 구현됨 (컴팩트한 디자인)
- **콘텐츠 표시**: ✅ 탭 기반 통합 UI 완료
- **API 연동**: ✅ 성경, 찬송가 API 연결 완료
- **찬송가 시스템**: ✅ 검색, 상세보기, 데이터베이스 완성
- **기도문 API**: ⏳ 하드코딩 상태 (다음 단계)

### 구현 우선순위 (6단계)
1. 기도문 API 구현 (`GET /api/prayers/search?q=keyword`)
2. 태그 시스템과 키워드 매핑 구현
3. 기도문 실제 데이터 추가
4. 관리자 기능 (선택사항)

## 💻 JavaScript 아키텍처

### 전역 객체 `BibleAI`
```javascript
window.BibleAI = {
    api: { get(), post() },        // API 헬퍼
    storage: { get(), set() },     // localStorage 헬퍼
    showNotification(),            // 알림 표시
    formatDate(),                  // 날짜 포맷
    truncate()                     // 문자열 자르기
};
```

### PWA 준비사항
- Service Worker 등록됨 (`sw.js`)
- 기본 캐싱 전략 구현됨
- 오프라인 감지 기능

### 각 페이지별 JavaScript 특징
- **키워드(홈)**: 키워드 선택, 탭 기반 콘텐츠 표시, API 통합
- **성경검색**: 검색 폼, 빠른 검색, API 통합 완료
- **기도문**: 태그 선택 로직, 모달 시스템
- **찬송가**: 검색, 카테고리, 가사 모달, API 통합 완료
- **오늘의 키워드**: 키워드별 관련 콘텐츠 통합 표시

## 🗃️ 더미 데이터 현황

### 기본 태그 (DB에 삽입됨)
감사, 위로, 용기, 회개, 치유, 지혜, 평강, 가족, 직장, 건강

### 기본 성경구절 (DB에 삽입됨)
- 요한복음 3:16
- 시편 23:1  
- 빌립보서 4:13
- 로마서 8:28

### 더미 기도문 (JavaScript에 하드코딩)
- 감사 기도
- 위로의 기도
- 치유의 기도

### 실제 찬송가 데이터 (29개, DB에 저장됨)
- 1장: 만복의 근원 하나님
- 8장: 거룩 거룩 거룩 전능하신 주님
- 199장: 나의 사랑하는 책 ⭐ (구찬송가 234번)
- 305장: 나 같은 죄인 살리신
- 420장: 오 신실하신 주 (구찬송가 447번)
- 등 총 29개 통합찬송가 (저작권 안내 포함)

## 🔧 환경 설정

### 환경 변수 (기본값)
```bash
DB_HOST=localhost                    # 로컬 PostgreSQL 호스트
DB_PORT=5432                        # PostgreSQL 포트
DB_USER=bibleai                     # 애플리케이션 전용 사용자
DB_PASSWORD=<실제_비밀번호>         # 애플리케이션 사용자 암호
DB_NAME=bibleai                     # 데이터베이스 명
DB_SSLMODE=disable                  # 로컬 환경에서는 SSL 비활성화
```

### 🚨 배포 규칙 (절대 준수)

**절대 규칙**: 사용자가 **명시적으로 배포를 요청하지 않는 한 절대 배포하지 않습니다.**

- ❌ **금지**: `./deploy.sh` 스크립트를 임의로 실행하지 않음
- ❌ **금지**: EC2 서버로 코드를 자동으로 배포하지 않음
- ✅ **허용**: 로컬 서버 재시작 (`./server.sh restart`)
- ✅ **허용**: 로컬 개발 및 테스트

**배포가 필요한 경우**: 반드시 사용자에게 배포 여부를 먼저 확인하고 승인을 받아야 합니다.

### 🚨 데이터베이스 접근 규칙 (필수)

**중요**: 데이터베이스에 접근할 때는 **반드시 .env 파일의 정보**를 사용해야 합니다.

#### CLI에서 psql 접속 시 필수 형식
```bash
# .env 파일의 정보를 환경변수로 사용
source .env
PGPASSWORD=${DB_PASSWORD} psql -h ${DB_HOST} -U ${DB_USER} -d ${DB_NAME}

# 또는 직접 .env 파일에서 읽어서 사용
PGPASSWORD=$(grep DB_PASSWORD .env | cut -d '=' -f2) psql -h localhost -U bibleai -d bibleai
```

#### .env 파일 확인 방법
```bash
# 프로젝트 루트의 .env 파일 내용 확인
cat .env | grep DB_

# 또는 개별 변수 확인
grep DB_PASSWORD .env
grep DB_USER .env
```

#### Go 코드에서 환경 변수 사용
```go
// 코드에서는 os.Getenv()로 .env 파일 정보 자동 로드
dbHost := os.Getenv("DB_HOST")
dbUser := os.Getenv("DB_USER")
dbPassword := os.Getenv("DB_PASSWORD")
dbName := os.Getenv("DB_NAME")
```

### 데이터베이스 구조 (로컬 PostgreSQL)
- **슈퍼유저**: postgres (로컬 설치시 기본)
- **애플리케이션 DB**: bibleai
- **애플리케이션 사용자**: bibleai (암호: 환경변수로 관리)
- **권한**: bibleai 사용자는 bibleai DB에 대한 모든 권한
- **초기화**: init.sql + init-db.sh로 자동 설정

### Docker 설정
- **애플리케이션**: Docker 컨테이너로 실행
- **데이터베이스**: 로컬 PostgreSQL 직접 연결
- **호스트 네트워킹**: host.docker.internal로 로컬 DB 접근

## 🚨 알려진 이슈 및 제한사항

### 현재 알려진 문제점
1. **🚨 API 우선 규칙 위반**: 기도문 데이터가 JavaScript에 하드코딩됨
   - 파일: `bible-analysis.html` 164-179라인
   - 해결: `/api/prayers/search` API 구현 필요
2. 템플릿 로딩 방식이 비효율적 (모든 파일 개별 로딩)
3. 관리자 기능 완전 미구현
4. 테스트 코드 부재
5. 데이터베이스 인덱스 최적화 필요

### 성능 최적화 필요사항
1. 데이터베이스 인덱스 추가 
2. 템플릿 캐싱
3. CSS/JS 압축
4. 이미지 최적화

## 📋 현재 기능 상태 점검 (2025년 1월 29일)

### ✅ 완전 구현된 기능

#### 1. 성경 검색 기능
- **페이지**: `/bible/search` (bible-search.html)
- **API**: `GET /api/bible/search?q={검색어}`
- **상태**: 완전 동작
- **검증 결과**:
  - ✅ API 응답: 100개 결과 정상 반환
  - ✅ 프론트엔드: 검색 결과 정상 표시
  - ✅ 인코딩: 한글 검색어 정상 처리
  - ✅ UI/UX: 모바일 최적화 완료

#### 2. 키워드 기반 홈페이지
- **페이지**: `/` (bible-analysis.html을 홈으로 사용)
- **기능**: 8개 키워드 카드 표시
- **상태**: 완전 동작
- **키워드**: 사랑, 믿음, 소망, 기쁨, 평화, 용서, 감사, 지혜

#### 3. 찬송가 시스템
- **페이지**: `/hymns` (hymns.html)
- **API**:
  - `GET /api/hymns/search?q={검색어}` - 검색
  - `GET /api/hymns/{number}` - 상세 조회
  - `GET /api/hymns/theme/{theme}` - 주제별 조회
- **상태**: 완전 동작
- **기능**: 검색, 상세보기 모달, 저작권 안내
- **데이터**: 29개 실제 통합찬송가 (신찬송가 번호 체계)
- **매핑**: 구찬송가 → 신찬송가 번호 자동 변환
- **외부링크**: 신찬송가 번호 기반 URL

#### 4. 네비게이션 시스템
- **디자인**: 하단 고정 네비게이션
- **페이지**: 키워드, 성경, 기도문, 찬송가
- **상태**: 완전 동작, 활성 탭 표시 정상

### 🔄 부분 구현된 기능

#### 1. 기도문 찾기
- **페이지**: `/prayers` (a-prayers.html)
- **UI**: 태그 선택 인터페이스 완성
- **데이터**: 하드코딩된 더미 데이터
- **API**: 미구현 (다음 단계)

### 🚨 최근 수정된 중요 이슈

#### Issue 1: 성경 검색 결과 표시 안됨 (해결됨)
- **증상**: "실제 거맥은 아되는것같은데?"
- **원인**: `bible-search.html:153`에서 잘못된 API 응답 파싱
- **기존 코드**: `if (data.success && data.results && data.results.length > 0)`
- **수정 코드**: `if (data.results && data.results.length > 0)`
- **해결 일시**: 2025년 1월 27일
- **검증**: 100개 검색 결과 정상 표시 확인

#### Issue 2: 찬송가 번호 매핑 오류 (해결됨)
- **증상**: "나의 사랑하는 책"이 신찬송가 234번으로 잘못 표시
- **원인**: 구찬송가 234번이 신찬송가 234번으로 잘못 매핑됨
- **수정**: 구찬송가 234번 → 신찬송가 199번으로 수정
- **추가 수정**: 모든 external_link를 신찬송가 번호 기반으로 업데이트
- **해결 일시**: 2025년 1월 29일
- **검증**: API 및 웹페이지에서 신찬송가 번호 정상 표시 확인

### 🗄️ 데이터베이스 상태
```sql
-- 성경 데이터: 30,929 구절 (완전)
-- 성경 해석: 창세기 전체 50장 해석 완료 (각 장의 1절에 저장)
-- 찬송가 데이터: 29개 실제 통합찬송가 (신찬송가 체계, 완전)
-- 기도문 데이터: 미구현 (스키마만 존재)
-- 태그 데이터: 10개 기본 태그 (완전)
```

### 🧪 테스트 상태
- **API 테스트**: 성경 검색, 찬송가 검색/상세보기 API 완전 검증
- **프론트엔드 테스트**: 페이지 로딩 및 검색 기능 검증
- **통합 테스트**: 프론트엔드-백엔드 연동 완전 검증
- **모바일 테스트**: 반응형 디자인 확인됨
- **찬송가 시스템**: 검색, 상세보기, 모달, 저작권 안내, 신찬송가 매핑 검증 완료

## 🔮 다음 단계 구현 가이드

### ✅ 5단계: 찬송가 시스템 완성 (2025년 1월 28일)
- 찬송가 데이터베이스 완전 교체 (29개 실제 통합찬송가)
- 찬송가 상세보기 모달 구현 (가사, 작곡가, 성경참조 등)
- 구찬송가/신찬송가 번호 매핑 시스템 구현
- 신찬송가 번호 우선 표시 (new_hymn_number 컬럼)
- 외부 링크 신찬송가 번호로 통일
- 저작권 안내 및 교육용 서비스 명시
- 찬송가 Import API 구현 (관리자용)
- 오늘의 추천 찬송가 제거 (사용자 피드백 반영)

### 🔄 6단계: 기도문 API 시스템 구현 (다음 단계)

**API 우선 개발 규칙에 따라 하드코딩된 기도문 데이터를 API로 마이그레이션**

#### 🚨 현재 위반 사항 해결
현재 `bible-analysis.html`에 하드코딩된 기도문 데이터를 API로 변경 필요:
```javascript
// ❌ 현재 위반 사례 (bible-analysis.html 164라인)
const prayerData = {
    '사랑': [{ title: '사랑의 기도', content: '...' }],
    '평안': [{ title: '평안의 기도', content: '...' }]
};
```

#### 우선순위 1: 기도문 검색 API 구현
```go
// internal/handlers/prayers.go 생성
func SearchPrayers(c *gin.Context) {
    keyword := c.Query("q")

    // API 응답 표준 형식 준수
    c.JSON(http.StatusOK, gin.H{
        "success": true,
        "query": keyword,
        "prayers": searchResults,
        "total": len(searchResults),
    })
}
```

#### 우선순위 2: 하드코딩 제거 및 API 연동
```javascript
// ✅ 올바른 구현으로 수정
async function loadPrayersByKeyword(keyword) {
    try {
        const response = await fetch(`/api/prayers/search?q=${keyword}`);
        const data = await response.json();
        if (data.success) {
            return data.prayers || [];
        }
        return [];
    } catch (error) {
        console.error('기도문 API 호출 실패:', error);
        return [];
    }
}
```

#### 우선순위 3: 기도문 데이터베이스 확장
```sql
-- migrations/002_prayer_data.sql
INSERT INTO prayers (title, content, created_at) VALUES
('사랑의 기도', '하나님의 무한한 사랑에 감사드립니다...', NOW()),
('평안의 기도', '평강의 하나님, 저희 마음에 참된 평안을...', NOW()),
('위로의 기도', '위로의 하나님, 고난 중에 있는...', NOW());
-- 키워드별 최소 5-10개 기도문 추가
```

### 4단계: 실제 데이터 추가

#### 기도문 데이터 추가
- 각 태그별로 최소 5-10개 기도문 작성
- `migrations/002_prayer_data.sql` 파일로 관리

#### 성경 데이터 확장  
- 주요 성경 구절 100개 이상 추가
- 검색을 위한 인덱스 생성

#### 찬송가 데이터
- 인기 찬송가 50-100곡 데이터 추가

## 🎨 UI 확장 가이드

### 새 컴포넌트 추가시
1. `web/templates/components/` 폴더 생성 (향후)
2. 재사용 가능한 템플릿 조각 작성
3. `base.html`에서 include 패턴 사용

### 새 페이지 스타일 추가시
1. Tailwind CSS 우선 사용
2. 필요시 `web/static/css/custom.css` 생성
3. 컬러 시스템 준수 (Blue, Green, Purple, Orange)

### 모바일 최적화 체크리스트
- [ ] 터치 버튼 최소 44px
- [ ] 텍스트 최소 16px
- [ ] 호버 대신 터치 이벤트
- [ ] 세로 스크롤 우선
- [ ] 빠른 로딩 (<3초)

## 🛡️ 보안 고려사항

### 🚨 민감 정보 보호 규칙 (최우선)

**절대 규칙**: 민감 정보는 절대 문서, 커밋 메시지, 코드에 포함하지 않습니다.

#### 민감 정보 목록
1. **API 키**:
   - Gemini API Key (`GEMINI_API_KEY`)
   - 기타 외부 서비스 API 키

2. **인프라 정보**:
   - EC2 IP 주소
   - RDS 엔드포인트
   - SSH 키 경로 (절대 경로)

3. **데이터베이스 정보**:
   - 비밀번호 (실제 값)
   - 연결 문자열 (비밀번호 포함)

4. **기타 비밀값**:
   - JWT Secret
   - 암호화 키
   - OAuth Client Secret

#### 안전한 관리 방법

**✅ 올바른 방법**:
```bash
# 환경변수 사용 (문서에서)
GEMINI_API_KEY=your_actual_api_key_here
DB_PASSWORD=your_password_here
SERVER_HOST=YOUR_EC2_IP

# .env 파일 사용 (코드에서)
source .env
PGPASSWORD=${DB_PASSWORD} psql -h ${DB_HOST} -U ${DB_USER} -d ${DB_NAME}
```

**❌ 잘못된 방법**:
```bash
# 실제 값 노출 (절대 금지)
GEMINI_API_KEY=AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  # 실제 키 노출 금지!
SERVER_HOST=13.209.47.72  # 실제 IP 노출 금지!
PGPASSWORD=actual_password psql -h localhost -U bibleai -d bibleai  # 실제 비밀번호 노출 금지!
```

#### Git 보호 설정

**.gitignore 필수 항목**:
```gitignore
# 환경 변수
.env
.env.local
.env.production

# 설정 파일
deploy.config

# 빌드 산출물
bibleai
backoffice
server
*.pid

# 로그
*.log
logs/
```

#### 문서 작성 가이드

1. **예시 코드**: 실제 값 대신 플레이스홀더 사용
   - `YOUR_API_KEY`, `YOUR_EC2_IP`, `your_password_here`

2. **커밋 메시지**: 민감 정보 절대 포함 금지

3. **작업 문서**: 환경변수 참조만 표시
   - `${DB_PASSWORD}` ✅
   - `bibleai` ❌ (실제 비밀번호인 경우)

4. **스크린샷**: 민감 정보 마스킹 필수

#### 노출 시 대응

만약 실수로 민감 정보가 커밋된 경우:

1. **즉시 교체**: API 키, 비밀번호 등을 새 값으로 변경
2. **커밋 정리**: `git commit --amend` 또는 `git rebase`로 이력 제거
3. **강제 푸시**: `git push --force` (신중하게)
4. **문서화**: 사고 보고서 작성

### 현재 보안 조치
- SQL 인젝션 방지: Prepared Statements
- XSS 방지: Go 템플릿 자동 이스케이핑
- 기본 CORS 설정
- .env 파일 gitignore 처리
- 민감 정보 플레이스홀더 사용

### 향후 보안 강화 필요사항
- JWT 기반 관리자 인증
- CSRF 토큰
- Rate Limiting
- 입력 검증 강화
- HTTPS 인증서
- 정기적 보안 감사

## 🧪 테스트 전략 (향후)

### 테스트 우선순위
1. 핸들러 단위 테스트
2. 데이터베이스 쿼리 테스트
3. API 통합 테스트
4. 웹 페이지 E2E 테스트

### 테스트 도구 계획
- Go 기본 testing 패키지
- testify/assert (assertion)
- Gin 테스트 헬퍼
- 브라우저 자동화 도구 (선택사항)

## 📊 성능 모니터링 (향후)

### 주요 메트릭
- 응답 시간 (목표: <500ms)
- 동시 접속자 수
- 데이터베이스 쿼리 성능
- 메모리/CPU 사용량

### 모니터링 도구 계획
- 구조화된 로깅 (logrus)
- 메트릭 수집 (Prometheus, 선택사항)
- 헬스체크 확장

## 💡 개발 팁 및 트릭

### API 우선 개발 체크리스트
- [ ] 새 기능 개발 전 API 엔드포인트부터 설계
- [ ] JavaScript에 데이터 하드코딩 금지
- [ ] API 응답 표준 형식 준수
- [ ] 에러 처리 및 로딩 상태 관리
- [ ] API 문서화 (엔드포인트, 파라미터, 응답 형식)

### Gin 프레임워크 활용
```go
// 미들웨어 체이닝
r.Use(gin.Logger())
r.Use(gin.Recovery())

// 그룹 라우팅 
api := r.Group("/api")
api.GET("/tags", handlers.GetTags)
```

### PostgreSQL 최적화
```sql
-- 검색용 인덱스
CREATE INDEX idx_prayers_content_gin 
ON prayers USING gin(to_tsvector('korean', content));

-- 복합 인덱스
CREATE INDEX idx_prayer_tags_lookup 
ON prayer_tags(tag_id, prayer_id);
```

### 템플릿 개발시 주의사항
- 템플릿 변수명 일관성 유지
- XSS 방지를 위한 적절한 이스케이핑
- 조건문/반복문 최소화

### JavaScript 개발시 주의사항  
- ES6+ 문법 사용 (IE 지원 불필요)
- async/await 적극 활용
- DOM 조작 최소화
- 이벤트 위임 패턴 활용

## 📚 참조 링크 및 자료

### 공식 문서
- [Go 언어](https://golang.org/doc/)
- [Gin 웹 프레임워크](https://gin-gonic.com/)
- [PostgreSQL](https://www.postgresql.org/docs/)
- [Tailwind CSS](https://tailwindcss.com/docs)

### 개발 도구
- [Air (Hot Reload)](https://github.com/cosmtrek/air)
- [Docker Compose](https://docs.docker.com/compose/)

### 한국어 리소스
- [개역개정 성경](http://kcm.co.kr/bible/)
- [통합찬송가](https://www.21ccm.com/)

## 📈 주요 성과 요약 (v0.5.7 기준)

### ✅ 완전 구현된 핵심 기능
1. **성경 검색 시스템** - 30,929구절 데이터베이스, 키워드 검색, 장 기반 결과, 완전 통일된 모달 UI
2. **찬송가 시스템** - 29개 실제 통합찬송가, 상세보기 모달, 3자리 패딩 외부 링크, 저작권 안내
3. **키워드 기반 홈페이지** - 8개 키워드, 탭 기반 통합 콘텐츠 표시
4. **완전한 UI 일관성** - 모든 성경 장 보기가 동일한 모달 스타일과 기능 제공
5. **모바일 최적화 UI** - 하단 네비게이션, 터치 친화적 디자인
6. **API 우선 아키텍처** - RESTful API, JSON 응답 표준화

### 🎯 기술적 성취
- **API 엔드포인트**: 10개 이상 완전 동작
- **데이터베이스**: PostgreSQL 기반 안정적 운영, LPAD 함수 활용 최적화
- **프론트엔드**: Tailwind CSS + Vanilla JS 모바일 최적화
- **개발 도구**: 완전 자동화된 서버 관리 스크립트
- **코드 품질**: Go + Gin 프레임워크 모범 사례 적용, 중복 코드 제거

### 📊 사용자 경험 개선
- **검색 성능**: 즉시 응답, 100개 결과 표시
- **모바일 지원**: 완전한 반응형 디자인
- **접근성**: 큰 버튼, 명확한 아이콘, 고대비 텍스트
- **모달 일관성**: ESC 키, 배경 클릭, 구절 복사 등 모든 페이지에서 동일한 인터랙션
- **저작권 준수**: 교육용 명시, 공식 자료 안내, 정확한 외부 링크 제공

## 🔄 버전 히스토리

### v0.1.0 (1단계 완료)
- Go 프로젝트 기본 설정
- PostgreSQL Docker 설정
- 기본 웹 서버 구동

### v0.2.0 (2단계 완료)
- 5개 웹 페이지 구현 완료
- 모바일 최적화 UI/UX
- PWA 기본 준비
- 태그 기반 기도문 UI (더미)

### v0.3.0 (3단계 완료)
- 키워드 중심 UI 시스템 구현
- 홈페이지를 키워드 선택으로 변경
- 성경/찬송가 API 연동 완료
- 통합 콘텐츠 표시 시스템
- 네비게이션 일관성 개선

### v0.5.0 (5단계 완료)
- 찬송가 시스템 완전 구현
- 29개 실제 통합찬송가 데이터 추가
- 찬송가 상세보기 모달 완성
- ID/Number 매개변수 오류 수정
- 저작권 안내 시스템 구현
- 찬송가 Import API 구현

### v0.5.5 (5.5단계 완료) - (2025년 1월 27일)
- **키워드 탭 완전 일관성 구현**: 키워드 탭과 개별 탭(성경, 기도문, 찬송가)의 100% 동일한 동작 보장
- **성경 장 모달 시스템**: 키워드 탭에서 성경 장 클릭 시 페이지 리다이렉트 대신 모달로 상세보기
- **API 통합**: 키워드 탭에서 `/api/bible/search/chapters` 사용하여 성경 탭과 동일한 장 기준 결과 표시
- **주제 표시 수정**: `[object Object]` 오류 해결, 성경 탭과 동일한 주제 태그 형식 적용
- **모달 기능 완성**: ESC 키, 배경 클릭으로 모달 닫기, 구절 복사 기능 등 완전한 사용자 경험
- **콘텐츠 일관성 문서화**: `CONTENT_CONSISTENCY_RULES.md`에 키워드 탭 일관성 원칙 명문화
- **브라우저 캐시 관리**: 캐시 버전 업데이트로 변경사항 즉시 반영

### v0.5.6 (찬송가 매핑 수정) - (2025년 1월 29일)
- **구찬송가/신찬송가 매핑 시스템**: `new_hymn_number` 커럼으로 신찬송가 번호 자동 변환
- **찬송가 번호 오류 수정**: "나의 사랑하는 책" 구찬송가 234번 → 신찬송가 199번
- **외부 링크 통일**: 모든 external_link를 신찬송가 번호로 업데이트
- **API 응답 검증**: `/api/hymns/{number}`가 신찬송가 번호로 조회 가능
- **UI 표시 일관성**: 모든 페이지에서 "신찬송가 XXX장" 형식으로 통일

### v0.5.7 (UI 일관성 및 기술적 최적화) - (2025년 9월 29일)
- **찬송가 링크 3자리 패딩 시스템**: hymnkorea.org 링크에 001, 008, 199 형식 적용 (PostgreSQL LPAD 함수 사용)
- **성경 검색 모달 완전 통일**: 키워드 검색과 장별 보기 모두 키워드 페이지와 동일한 모달 스타일 적용
- **모달 UI 완전 일관성**: 4xl 최대 너비, 90vh 높이, 고정 헤더, 스크롤 가능 콘텐츠 등 동일한 디자인
- **사용자 경험 향상**: ESC 키, 배경 클릭으로 모달 닫기, 구절별 복사 버튼(📋) 등 일관된 인터랙션
- **코드 품질 개선**: 중복 코드 제거, `viewChapter` 함수 모달 방식 통일, 키워드 페이지 스타일 완전 적용

### v0.5.8 (성경 해석 시스템 구축) - 현재 (2025년 9월 29일)
- **성경 해석 데이터베이스 설계**: `bible_verses` 테이블에 5개 해석 컬럼 추가 (각 장 1절에만 저장)
- **창세기 전체 해석 완성**: 창세기 1-50장 모든 장의 상세 해석 데이터 구축
- **해석 API 통합**: 기존 `/api/bible/chapters/{book}/{chapter}` API에 commentary 객체 추가
- **종합적 해석 내용**: 장 제목, 요약, 주요 주제, 역사적 배경, 현대적 적용 포함
- **효율적 데이터 구조**: 별도 테이블 대신 기존 구조 확장으로 성능 최적화
- **완전한 신학적 해석**: 구원사적 관점, 메시아 예언, 실용적 적용을 포괄하는 균형잡힌 해석

### v0.6.0 (6단계 계획) - 다음
- 기도문 검색 API 구현
- 실제 기도문 데이터 추가
- 키워드-태그 매핑 시스템

### v0.7.0 (7단계 계획)
- 성능 최적화
- 관리자 기능
- 추가 콘텐츠 확장

---

**문서 작성일**: 2025년 1월 15일
**최근 업데이트**: 2025년 9월 29일 (성경 해석 시스템 구축)
**프로젝트 버전**: v0.5.8-stable
**다음 업데이트**: 6단계 완료 후

> **중요**: 이 문서는 Claude AI가 프로젝트 컨텍스트를 유지하고 일관된 개발을 진행하기 위한 핵심 참조 자료입니다. 새로운 기능 개발이나 변경사항이 있을 때마다 반드시 업데이트해야 합니다.