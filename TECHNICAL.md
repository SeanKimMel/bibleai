# 기술 사양 문서 (Technical Specifications)

## 🏗️ 시스템 아키텍처

### 전체 구조
```
┌─────────────────┐    HTTP/HTTPS     ┌─────────────────┐
│   Web Browser   │ ◄────────────────► │   Go Gin Server │
│   (Frontend)    │                   │   (Backend)     │
└─────────────────┘                   └─────────────────┘
                                              │ SQL
                                              ▼
                                    ┌─────────────────┐
                                    │   PostgreSQL    │
                                    │   (Database)    │
                                    └─────────────────┘
                                              │ Docker
                                              ▼
                                    ┌─────────────────┐
                                    │ Docker Container│
                                    └─────────────────┘
```

### 컴포넌트 구조
```
bibleai/
├── cmd/server/           # 애플리케이션 엔트리포인트
├── internal/
│   ├── handlers/         # HTTP 요청 처리
│   ├── models/           # 데이터 모델
│   ├── database/         # DB 연결 및 쿼리
│   └── middleware/       # 인증, 로깅 등
├── web/
│   ├── templates/        # HTML 템플릿
│   └── static/           # 정적 파일
└── migrations/           # DB 스키마 마이그레이션
```

## 💾 데이터베이스 설계

### ERD (Entity Relationship Diagram)
```
┌─────────────┐       ┌─────────────┐       ┌─────────────┐
│   prayers   │       │prayer_tags  │       │    tags     │
├─────────────┤       ├─────────────┤       ├─────────────┤
│ id (PK)     │◄─────►│prayer_id(FK)│◄─────►│ id (PK)     │
│ title       │       │ tag_id (FK) │       │ name        │
│ content     │       └─────────────┘       │ description │
│ created_at  │                             │ created_at  │
│ updated_at  │                             └─────────────┘
└─────────────┘

┌─────────────┐                             ┌─────────────┐
│bible_verses │                             │    hymns    │
├─────────────┤                             ├─────────────┤
│ id (PK)     │                             │ id (PK)     │
│ book        │                             │ number      │
│ chapter     │                             │ title       │
│ verse       │                             │ lyrics      │
│ content     │                             │ theme       │
│ version     │                             └─────────────┘
└─────────────┘
```

### 테이블 상세 스펙

#### prayers 테이블
```sql
CREATE TABLE prayers (
    id SERIAL PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    content TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);
```

#### tags 테이블
```sql
CREATE TABLE tags (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);
```

#### prayer_tags 테이블 (다대다 관계)
```sql
CREATE TABLE prayer_tags (
    prayer_id INTEGER REFERENCES prayers(id) ON DELETE CASCADE,
    tag_id INTEGER REFERENCES tags(id) ON DELETE CASCADE,
    PRIMARY KEY (prayer_id, tag_id)
);
```

#### bible_verses 테이블
```sql
CREATE TABLE bible_verses (
    id SERIAL PRIMARY KEY,
    book VARCHAR(50) NOT NULL,
    chapter INTEGER NOT NULL,
    verse INTEGER NOT NULL,
    content TEXT NOT NULL,
    version VARCHAR(20) DEFAULT 'KOR'
);
```

#### hymns 테이블
```sql
CREATE TABLE hymns (
    id SERIAL PRIMARY KEY,
    number INTEGER UNIQUE NOT NULL,
    title VARCHAR(200) NOT NULL,
    lyrics TEXT,
    theme VARCHAR(100)
);
```

### 인덱스 전략
```sql
-- 성능 최적화를 위한 인덱스
CREATE INDEX idx_tags_name ON tags(name);
CREATE INDEX idx_bible_verses_book ON bible_verses(book);
CREATE INDEX idx_bible_verses_content ON bible_verses USING gin(to_tsvector('korean', content));
CREATE INDEX idx_hymns_number ON hymns(number);
CREATE INDEX idx_hymns_title ON hymns USING gin(to_tsvector('korean', title));
CREATE INDEX idx_prayers_content ON prayers USING gin(to_tsvector('korean', content));
```

## 🔧 Backend 기술 스택

### Go 언어 사양
- **버전**: Go 1.23+
- **모듈 관리**: Go Modules
- **코딩 표준**: Go 공식 스타일 가이드

### 주요 의존성
```go
// go.mod
module bibleai

go 1.23

require (
    github.com/gin-gonic/gin v1.11.0
    github.com/lib/pq v1.10.9
)
```

### Gin 웹 프레임워크 설정
```go
// 미들웨어 체인
r.Use(gin.Logger())
r.Use(gin.Recovery())
r.Use(cors.Default()) // 향후 CORS 설정

// 템플릿 로딩
r.LoadHTMLFiles(
    "web/templates/layout/base.html",
    "web/templates/pages/*.html",
)

// 정적 파일 서빙
r.Static("/static", "./web/static")
```

### 데이터베이스 연결
```go
// 연결 풀 설정
db.SetMaxOpenConns(25)
db.SetMaxIdleConns(25)
db.SetConnMaxLifetime(5 * time.Minute)

// 연결 문자열 예시
connStr := "host=localhost port=5432 user=bibleai password=bibleai123 dbname=bibleai sslmode=disable"
```

## 🎨 Frontend 기술 스택

### HTML 템플릿 시스템
```go
// 템플릿 구조
base.html          // 기본 레이아웃
├── home.html      // 홈페이지
├── bible-search.html
├── bible-analysis.html
├── hymns.html
└── prayers.html
```

### CSS 프레임워크 (Tailwind)
```html
<!-- CDN 방식 사용 -->
<script src="https://cdn.tailwindcss.com"></script>

<!-- 커스텀 CSS 클래스 -->
.btn-primary { @apply bg-blue-600 text-white ... }
.btn-secondary { @apply bg-gray-200 text-gray-800 ... }
.card { @apply bg-white rounded-xl shadow-lg ... }
```

### JavaScript 아키텍처
```javascript
// 전역 네임스페이스
window.BibleAI = {
    api: { get(), post() },
    storage: { get(), set(), remove() },
    showNotification(),
    formatDate(),
    truncate()
};
```

### PWA 구성 요소
```javascript
// Service Worker (sw.js)
const CACHE_NAME = 'bibleai-v1';
const urlsToCache = ['/', '/static/js/main.js', ...];

// 캐시 전략: Cache First
```

## 📡 API 설계

### RESTful API 엔드포인트

#### 웹 페이지 라우트
```
GET  /                    # 홈페이지
GET  /bible/search        # 성경 검색 페이지
GET  /bible/analysis      # 감정 분석 페이지
GET  /hymns               # 찬송가 페이지
GET  /prayers             # 기도문 페이지
```

#### API 라우트 (현재)
```
GET  /api/status          # 시스템 상태
GET  /api/tags            # 태그 목록
GET  /health              # 헬스 체크
```

#### API 라우트 (계획)
```
# 태그 관리
GET    /api/tags          # 태그 목록 조회
POST   /api/tags          # 태그 생성
PUT    /api/tags/:id      # 태그 수정
DELETE /api/tags/:id      # 태그 삭제

# 기도문 관리
GET    /api/prayers       # 기도문 목록 조회
POST   /api/prayers       # 기도문 생성
PUT    /api/prayers/:id   # 기도문 수정
DELETE /api/prayers/:id   # 기도문 삭제
GET    /api/prayers/by-tags # 태그별 기도문 조회

# 성경 검색
GET    /api/bible/search  # 성경 구절 검색
GET    /api/bible/verse/:id # 특정 구절 조회

# 찬송가
GET    /api/hymns         # 찬송가 목록/검색
GET    /api/hymns/:number # 특정 찬송가 조회
```

### HTTP 응답 형식
```json
{
    "success": true,
    "data": {...},
    "message": "Success message",
    "timestamp": "2025-01-15T10:30:00Z"
}

// 에러 응답
{
    "success": false,
    "error": "Error message",
    "code": "ERROR_CODE",
    "timestamp": "2025-01-15T10:30:00Z"
}
```

## 🔒 보안 사양

### 현재 보안 조치
1. **SQL 인젝션 방지**: Prepared Statements 사용
2. **XSS 방지**: Go HTML 템플릿 자동 이스케이핑
3. **CSRF 방지**: Gin의 기본 보안 헤더 (향후 강화 예정)

### 향후 보안 강화
1. **인증**: JWT 기반 관리자 인증
2. **인가**: 역할 기반 접근 제어
3. **Rate Limiting**: 요청 속도 제한
4. **HTTPS**: TLS 인증서 적용
5. **입력 검증**: 모든 사용자 입력 검증

### 환경 변수 관리
```bash
# 개발 환경
DB_HOST=localhost
DB_PORT=5432
DB_USER=bibleai
DB_PASSWORD=bibleai123
DB_NAME=bibleai
DB_SSLMODE=disable

# 프로덕션 환경 (예시)
DB_HOST=prod-db.example.com
DB_PORT=5432
DB_USER=prod_user
DB_PASSWORD=${SECRET_DB_PASSWORD}
DB_NAME=bibleai_prod
DB_SSLMODE=require
JWT_SECRET=${SECRET_JWT_KEY}
```

## 🚀 성능 사양

### 응답 시간 목표
- 홈페이지: < 200ms
- 검색 결과: < 500ms
- 데이터베이스 쿼리: < 100ms

### 동시 접속자 목표
- 개발 단계: 10명
- 베타 단계: 100명
- 프로덕션: 1,000명

### 리소스 사용량
- 메모리: < 128MB (기본)
- CPU: < 50% (일반 부하)
- 디스크: < 1GB (데이터베이스 포함)

## 🐳 Docker 설정

### docker-compose.yml
```yaml
version: '3.8'
services:
  postgres:
    image: postgres:15-alpine
    environment:
      POSTGRES_USER: bibleai
      POSTGRES_PASSWORD: bibleai123
      POSTGRES_DB: bibleai
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U bibleai"]
      interval: 30s
      timeout: 10s
      retries: 3
```

### 프로덕션 Dockerfile (계획)
```dockerfile
# 멀티스테이지 빌드
FROM golang:1.23-alpine AS builder
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN go build -o main cmd/server/main.go

FROM alpine:latest
RUN apk --no-cache add ca-certificates
WORKDIR /root/
COPY --from=builder /app/main .
COPY --from=builder /app/web ./web
EXPOSE 8080
CMD ["./main"]
```

## 📊 모니터링 및 로깅

### 로깅 전략 (계획)
```go
// 구조화된 로깅
log.WithFields(log.Fields{
    "method": c.Request.Method,
    "path": c.Request.URL.Path,
    "status": c.Writer.Status(),
    "duration": duration,
}).Info("Request processed")
```

### 메트릭 수집 (계획)
- 요청 수 및 응답 시간
- 데이터베이스 연결 상태
- 메모리 및 CPU 사용량
- 에러 발생 빈도

### 헬스 체크
```go
// /health 엔드포인트
{
    "status": "healthy",
    "database": "connected",
    "timestamp": "2025-01-15T10:30:00Z",
    "uptime": "2h30m15s"
}
```

## 🔧 개발 도구

### Hot Reload (Air)
```toml
# .air.toml
[build]
  cmd = "go build -o ./tmp/main ./cmd/server"
  bin = "./tmp/main"
  include_ext = ["go", "html", "sql"]
  exclude_dir = ["tmp", "vendor"]
```

### 테스트 전략 (계획)
```go
// 단위 테스트
func TestGetTags(t *testing.T) { ... }

// 통합 테스트
func TestPrayersByTags(t *testing.T) { ... }

// 엔드투엔드 테스트
func TestWebPages(t *testing.T) { ... }
```

---

**문서 버전**: v1.0
**최종 수정**: 2025년 1월 15일
**기술 검토**: 필요시 업데이트