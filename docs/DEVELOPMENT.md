# 개발 가이드 (Development Guide)

## 🚀 빠른 시작

### 환경 요구사항
- **Go**: 1.23 이상
- **Docker**: 20.10 이상
- **Docker Compose**: 2.0 이상
- **Git**: 최신 버전

### 프로젝트 클론 및 실행
```bash
# 1. 프로젝트 클론
git clone <repository-url> bibleai
cd bibleai

# 2. 의존성 설치
go mod tidy

# 3. 개발 모드로 실행 (권장)
./dev.sh

# 또는 일반 실행
./start.sh
```

### 웹 브라우저 확인
- **홈페이지**: http://localhost:8080
- **헬스체크**: http://localhost:8080/health
- **API 상태**: http://localhost:8080/api/status

## 📁 프로젝트 구조 상세

```
bibleai/
├── cmd/
│   └── server/
│       └── main.go                 # 애플리케이션 진입점
├── internal/                       # 내부 패키지 (외부에서 import 불가)
│   ├── handlers/
│   │   ├── pages.go               # 웹 페이지 핸들러
│   │   ├── bible.go               # 성경 관련 API (예정)
│   │   ├── hymn.go                # 찬송가 관련 API (예정)
│   │   ├── prayer.go              # 기도문 관련 API (예정)
│   │   └── admin.go               # 관리자 API (예정)
│   ├── models/                     # 데이터 모델
│   │   ├── bible.go               # 성경 모델 (예정)
│   │   ├── hymn.go                # 찬송가 모델 (예정)
│   │   └── prayer.go              # 기도문 모델 (예정)
│   ├── database/
│   │   └── db.go                  # DB 연결 및 설정
│   └── middleware/                 # 미들웨어
│       └── auth.go                # 인증 미들웨어 (예정)
├── web/                           # 웹 자원
│   ├── templates/
│   │   ├── layout/
│   │   │   └── base.html          # 기본 레이아웃
│   │   ├── pages/                 # 페이지 템플릿들
│   │   │   ├── home.html          # 홈페이지
│   │   │   ├── bible-search.html  # 성경 검색
│   │   │   ├── bible-analysis.html # 감정 분석
│   │   │   ├── hymns.html         # 찬송가
│   │   │   └── prayers.html       # 기도문
│   │   └── components/            # 재사용 컴포넌트 (예정)
│   └── static/
│       ├── css/                   # 커스텀 CSS (현재 미사용)
│       └── js/
│           ├── main.js            # 메인 JavaScript
│           └── sw.js              # Service Worker
├── migrations/
│   └── 001_initial.sql           # 초기 DB 스키마
├── docker-compose.yml             # PostgreSQL 컨테이너 설정
├── go.mod                        # Go 모듈 정의
├── go.sum                        # 의존성 체크섬
├── README.md                     # 프로젝트 개요
├── PROJECT.md                    # 상세 프로젝트 문서
├── TECHNICAL.md                  # 기술 사양서
├── DEVELOPMENT.md                # 개발 가이드 (현재 문서)
├── start.sh                      # 서버 시작 스크립트
├── stop.sh                       # 서버 종료 스크립트
└── dev.sh                        # 개발 모드 스크립트
```

## 🔧 개발 환경 설정

### 1. Air 설치 (자동 재시작)
```bash
# Go 1.16+
go install github.com/cosmtrek/air@latest

# 또는 스크립트가 자동으로 설치
./dev.sh  # Air가 없으면 자동 설치
```

### 2. 환경 변수 설정
```bash
# 개발용 환경 변수 (.env 파일 생성 가능)
export DB_HOST=localhost
export DB_PORT=5432
export DB_USER=bibleai
export DB_PASSWORD=<실제_비밀번호>
export DB_NAME=bibleai
export DB_SSLMODE=disable
```

### 3. PostgreSQL 컨테이너 관리
```bash
# 시작
docker-compose up -d

# 상태 확인
docker-compose ps

# 로그 보기
docker-compose logs postgres

# 중지
docker-compose down

# 데이터까지 삭제
docker-compose down -v
```

## 🧪 개발 워크플로우

### 1. 새 기능 개발
```bash
# 1. 새 브랜치 생성
git checkout -b feature/new-feature

# 2. 개발 모드로 실행
./dev.sh

# 3. 코드 수정 (자동 재시작됨)
# 4. 테스트
# 5. 커밋 및 푸시
```

### 2. 코드 수정시 확인 사항
- 브라우저에서 즉시 확인 가능 (자동 재시작)
- 콘솔에서 컴파일 에러 확인
- 브라우저 개발자 도구에서 JavaScript 에러 확인

### 3. 데이터베이스 변경
```bash
# 1. migrations/ 폴더에 새 SQL 파일 생성
# 2. 컨테이너 재시작으로 반영
docker-compose down
docker-compose up -d

# 또는 직접 SQL 실행
docker-compose exec postgres psql -U bibleai -d bibleai -f /docker-entrypoint-initdb.d/002_new_migration.sql
```

## 📝 코딩 컨벤션

### Go 코딩 스타일
```go
// 패키지명: 소문자, 간결하게
package handlers

// 함수명: CamelCase, 공개 함수는 대문자로 시작
func HomePage(c *gin.Context) { ... }

// 변수명: camelCase
var userName string

// 상수명: CamelCase
const MaxRetryCount = 3

// 구조체: CamelCase
type UserProfile struct {
    ID   int    `json:"id"`
    Name string `json:"name"`
}
```

### HTML 템플릿 스타일
```html
<!-- 들여쓰기: 4칸 -->
{{template "base.html" .}}
{{define "content"}}
    <div class="card">
        <h2 class="text-xl font-bold">{{.Title}}</h2>
        <p>{{.Description}}</p>
    </div>
{{end}}
```

### CSS 클래스 명명 규칙
```css
/* Tailwind 기본 사용, 필요시 커스텀 클래스 */
.btn-primary { ... }        /* 기본 버튼 */
.btn-secondary { ... }      /* 보조 버튼 */
.card { ... }               /* 카드 컴포넌트 */
.modal { ... }              # 모달 컴포넌트 */
```

### JavaScript 스타일
```javascript
// ES6+ 사용
const BibleAI = {
    // 메서드명: camelCase
    showNotification: function(message, type) { ... },
    
    // API 호출
    api: {
        get: async function(url) { ... },
        post: async function(url, data) { ... }
    }
};

// 이벤트 리스너
document.addEventListener('DOMContentLoaded', function() {
    // 초기화 코드
});
```

## 🏗️ 새 기능 추가 가이드

### 1. 새 웹 페이지 추가
```bash
# 1. 템플릿 파일 생성
touch web/templates/pages/new-page.html

# 2. 핸들러 추가 (internal/handlers/pages.go)
func NewPage(c *gin.Context) {
    c.HTML(http.StatusOK, "new-page.html", gin.H{
        "Title": "새 페이지",
        "ShowBackButton": true,
    })
}

# 3. 라우트 등록 (cmd/server/main.go)
r.GET("/new-page", handlers.NewPage)

# 4. 템플릿 로딩에 추가
r.LoadHTMLFiles(
    // ... 기존 파일들
    "web/templates/pages/new-page.html",
)
```

### 2. 새 API 엔드포인트 추가
```go
// internal/handlers/api.go 파일 생성
package handlers

import (
    "net/http"
    "github.com/gin-gonic/gin"
)

func GetItems(c *gin.Context) {
    // 비즈니스 로직
    items := []string{"item1", "item2"}
    
    c.JSON(http.StatusOK, gin.H{
        "success": true,
        "data": items,
    })
}

// 라우트 등록 (main.go)
r.GET("/api/items", handlers.GetItems)
```

### 3. 새 데이터베이스 테이블 추가
```sql
-- migrations/002_add_new_table.sql
CREATE TABLE new_table (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);

INSERT INTO new_table (name, description) VALUES 
('샘플1', '샘플 데이터 1'),
('샘플2', '샘플 데이터 2');
```

## 🐛 디버깅 가이드

### 1. 로그 확인
```bash
# 개발 모드 실행시 콘솔에서 로그 확인
./dev.sh

# 컨테이너 로그
docker-compose logs postgres
```

### 2. 데이터베이스 직접 접속
```bash
# PostgreSQL 컨테이너 접속
docker-compose exec postgres psql -U bibleai -d bibleai

# SQL 쿼리 실행
bibleai=# SELECT * FROM tags;
bibleai=# \dt  -- 테이블 목록
bibleai=# \q   -- 종료
```

### 3. 일반적인 문제 해결

#### 포트 충돌 (8080 포트 사용중)
```bash
# 프로세스 확인
lsof -i :8080

# 프로세스 종료
kill -9 <PID>

# 또는 다른 포트 사용
export PORT=8080
go run cmd/server/main.go
```

#### PostgreSQL 연결 실패
```bash
# 컨테이너 상태 확인
docker-compose ps

# 컨테이너 재시작
docker-compose restart postgres

# 네트워크 확인
docker-compose exec postgres pg_isready -U bibleai
```

#### 템플릿 렌더링 오류
```bash
# 템플릿 파일 경로 확인
ls -la web/templates/pages/

# 문법 오류 확인 (Go 템플릿 구문)
# {{template "base.html" .}}
# {{define "content"}} ... {{end}}
```

## 🧪 테스트 가이드 (향후 계획)

### 1. 단위 테스트
```go
// internal/handlers/pages_test.go
package handlers

import (
    "testing"
    "github.com/gin-gonic/gin"
)

func TestHomePage(t *testing.T) {
    // 테스트 코드
}
```

### 2. 통합 테스트
```go
// tests/integration_test.go
func TestAPIEndpoints(t *testing.T) {
    // API 엔드포인트 테스트
}
```

### 3. 테스트 실행
```bash
# 모든 테스트 실행
go test ./...

# 특정 패키지 테스트
go test ./internal/handlers

# 커버리지 확인
go test -cover ./...
```

## 📦 배포 준비 (향후 계획)

### 1. 프로덕션 빌드
```bash
# 정적 바이너리 생성
CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o main cmd/server/main.go

# Docker 이미지 빌드
docker build -t bibleai:latest .
```

### 2. 환경별 설정
```bash
# 개발 환경
cp .env.example .env.dev

# 프로덕션 환경
cp .env.example .env.prod
# 실제 값으로 수정
```

### 3. 데이터베이스 마이그레이션
```bash
# 마이그레이션 도구 (향후 추가)
./migrate up
./migrate down
```

## 🤝 기여 가이드

### 1. 이슈 리포팅
- 버그 리포트시 재현 단계 포함
- 기능 요청시 사용 사례 설명

### 2. Pull Request
```bash
# 1. Fork 후 클론
git clone <your-fork>

# 2. 기능 브랜치 생성
git checkout -b feature/awesome-feature

# 3. 개발 및 테스트
./dev.sh

# 4. 커밋 (커밋 메시지 규칙 준수)
git commit -m "feat: 새로운 기능 추가"

# 5. Push 및 PR 생성
git push origin feature/awesome-feature
```

### 3. 커밋 메시지 규칙
```
feat: 새 기능 추가
fix: 버그 수정
docs: 문서 수정
style: 스타일 변경 (코드 동작에 영향 없음)
refactor: 리팩토링
test: 테스트 추가/수정
chore: 기타 작업 (빌드, 도구 설정 등)
```

## 📚 유용한 자료

### 공식 문서
- [Go 공식 문서](https://golang.org/doc/)
- [Gin 프레임워크](https://gin-gonic.com/)
- [PostgreSQL 문서](https://www.postgresql.org/docs/)
- [Tailwind CSS](https://tailwindcss.com/docs)

### 도구
- [Go Playground](https://play.golang.org/)
- [Regex101](https://regex101.com/)
- [JSON Formatter](https://jsonformatter.curiousconcept.com/)

### VS Code 확장
- Go (Google)
- PostgreSQL (Microsoft)
- Tailwind CSS IntelliSense
- Thunder Client (API 테스트)

---

**문서 버전**: v1.0
**최종 수정**: 2025년 1월 15일
**작성자**: Development Team