# 2025-10-23 타임존 및 날짜/시간 표시 개선

## 작업 개요
블로그 포스트에 날짜뿐만 아니라 시간도 표시하고, 전체 시스템의 타임존을 한국 시간(Asia/Seoul)으로 통일하여 해외에서도 일관된 시간 표시가 되도록 개선했습니다.

## 문제점
1. 블로그에 날짜만 표시되고 시간이 표시되지 않음
2. DB에서 timezone 정보가 없는 `TIMESTAMP` 타입 사용
3. 백엔드, 프론트엔드, 백오피스 간 시간대 처리가 일관되지 않음
4. 해외에서 접속 시 현지 시간으로 표시될 가능성

## 해결 방안

### 1. 데이터베이스 타임존 설정

#### 마이그레이션 파일 생성
`migrations/017_add_timezone_support.sql`:
```sql
-- 1. DB timezone을 한국 시간으로 설정
SET timezone = 'Asia/Seoul';

-- 2. blog_posts 테이블의 timestamp 컬럼들을 TIMESTAMPTZ로 변경
ALTER TABLE blog_posts
    ALTER COLUMN published_at TYPE TIMESTAMPTZ USING published_at AT TIME ZONE 'Asia/Seoul',
    ALTER COLUMN created_at TYPE TIMESTAMPTZ USING created_at AT TIME ZONE 'Asia/Seoul',
    ALTER COLUMN updated_at TYPE TIMESTAMPTZ USING updated_at AT TIME ZONE 'Asia/Seoul';

-- 3. evaluation_date도 변경
ALTER TABLE blog_posts
    ALTER COLUMN evaluation_date TYPE TIMESTAMPTZ USING evaluation_date AT TIME ZONE 'Asia/Seoul';

-- 4. 기본값 업데이트
ALTER TABLE blog_posts
    ALTER COLUMN published_at SET DEFAULT NOW(),
    ALTER COLUMN created_at SET DEFAULT NOW(),
    ALTER COLUMN updated_at SET DEFAULT NOW();

-- 5. blog_quality_history 테이블도 변경
ALTER TABLE blog_quality_history
    ALTER COLUMN evaluated_at TYPE TIMESTAMPTZ USING evaluated_at AT TIME ZONE 'Asia/Seoul';
```

**주요 변경사항:**
- `TIMESTAMP` → `TIMESTAMPTZ` (timezone aware)
- 기존 데이터는 Asia/Seoul 기준으로 자동 변환
- 이후 저장되는 모든 데이터는 timezone 정보 포함

### 2. 백엔드 타임존 처리

#### DB 연결 설정 수정
`internal/database/db.go`:
```go
func buildConnStrFromEnv() string {
    // ... 기존 코드 ...

    return fmt.Sprintf("host=%s port=%s user=%s password=%s dbname=%s sslmode=%s timezone=Asia/Seoul",
        host, port, user, password, dbname, sslmode)
}
```

**효과:**
- DB 연결 시 자동으로 Asia/Seoul 타임존 설정
- 모든 쿼리가 한국 시간 기준으로 처리됨

#### 블로그 상세 페이지 시간 포맷팅
`internal/handlers/pages.go`:
```go
// 한국 시간대로 변환하여 날짜와 시간 포맷팅
loc, _ := time.LoadLocation("Asia/Seoul")
publishedKST := post.PublishedAt.In(loc)
formattedDate := publishedKST.Format("2006년 1월 2일 15:04")
```

**표시 형식:** `2025년 10월 23일 17:24`

### 3. 프론트엔드 시간 표시

#### 블로그 목록 페이지 (SSR)
`cmd/server/main.go`:
```go
"formatDate": func(dateStr string) string {
    t, err := time.Parse(time.RFC3339, dateStr)
    if err != nil {
        return dateStr
    }
    // 한국 시간대로 변환하여 날짜와 시간 표시
    loc, _ := time.LoadLocation("Asia/Seoul")
    return t.In(loc).Format("2006년 1월 2일 15:04")
}
```

#### 블로그 목록 페이지 (CSR - JavaScript)
`web/templates/pages/blog.html`:
```javascript
// 날짜 포맷팅 (시간 포함)
function formatDate(dateString) {
    const date = new Date(dateString);
    return date.toLocaleDateString('ko-KR', {
        year: 'numeric',
        month: 'long',
        day: 'numeric',
        hour: '2-digit',
        minute: '2-digit'
    });
}
```

**표시 형식:** `2025년 10월 23일 오후 5:24`

### 4. 백오피스

백오피스는 이미 JavaScript에서 다음과 같이 시간을 표시하고 있습니다:
```javascript
const createdAt = new Date(blog.created_at).toLocaleString('ko-KR', {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
    hour: '2-digit',
    minute: '2-digit'
});
```

백엔드에서 한국 시간대로 전송되므로 추가 수정 불필요.

## 배포 과정

### 1. 로컬 환경
```bash
# 마이그레이션 실행
PGPASSWORD=bibleai psql -h localhost -U bibleai -d bibleai -f migrations/017_add_timezone_support.sql

# 확인
PGPASSWORD=bibleai psql -h localhost -U bibleai -d bibleai -c "SHOW timezone;"
# 결과: Asia/Seoul
```

### 2. 운영 환경
```bash
# 운영 DB 마이그레이션
PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -U $DB_USER -d $DB_NAME -f migrations/017_add_timezone_support.sql

# 백엔드 배포
./deploy.sh

# 백오피스 배포
./deploy_backoffice.sh
```

## 검증 결과

### DB 타임존 확인
```sql
SHOW timezone;
-- 결과: Asia/Seoul

SELECT id, title, created_at, published_at
FROM blog_posts
ORDER BY id DESC LIMIT 3;
-- 결과: 모든 timestamp에 +09 timezone 정보 포함
-- 예: 2025-10-23 16:47:55.208535+09
```

### 프론트엔드 확인
```bash
curl -s https://haruinfo.net/blog/2025-10-23-찬양-3958 | grep "2025년 10월 23일"
# 결과: <span>2025년 10월 23일 17:24</span>

curl -s https://haruinfo.net/blog | grep "text-gray-500" | grep "2025"
# 결과: <span class="text-gray-500">2025년 10월 23일 16:47</span>
```

## 주요 개선 사항

### 1. 일관된 타임존 처리
- **DB:** TIMESTAMPTZ with Asia/Seoul
- **백엔드:** 연결 시 timezone=Asia/Seoul 설정
- **프론트엔드:** 한국 시간대로 명시적 변환
- **결과:** 전 세계 어디서든 한국 시간 기준으로 표시

### 2. 날짜와 시간 모두 표시
- **이전:** 2025년 10월 23일
- **이후:** 2025년 10월 23일 17:24
- **위치:** 블로그 목록, 블로그 상세, 백오피스

### 3. 기존 데이터 보존
- 마이그레이션 시 `USING published_at AT TIME ZONE 'Asia/Seoul'`로 안전하게 변환
- 모든 기존 데이터는 Asia/Seoul 기준으로 해석되어 변환됨
- 데이터 손실 없음

## 관련 파일

### 신규 생성
- `migrations/017_add_timezone_support.sql` - 타임존 마이그레이션 SQL
- `.claude/rules.md` - 프로젝트 개발 규칙 (배포 규칙 포함)

### 수정
- `internal/database/db.go` - DB 연결 시 timezone 설정
- `internal/handlers/pages.go` - 블로그 상세 페이지 시간 포맷팅
- `cmd/server/main.go` - 템플릿 헬퍼 함수에 시간 포맷 추가
- `web/templates/pages/blog.html` - JavaScript 날짜 포맷팅에 시간 추가

## 배포 규칙 추가

### `.claude/rules.md` 생성
앞으로의 개발을 위해 다음 규칙을 문서화했습니다:

1. **배포 순서:**
   - 로컬 개발환경 먼저 배포 (기본)
   - 로컬에서 테스트 및 확인
   - 운영 배포는 명시적 요청 시에만

2. **운영 배포 조건:**
   - 사용자가 명시적으로 "운영 배포", "프로덕션 배포" 등을 요청한 경우에만
   - 단순히 "배포해줘"라고 하면 로컬 개발환경 배포로 간주
   - 운영 배포 전에 반드시 사용자에게 확인 요청

3. **DB 마이그레이션:**
   - 로컬 DB에 먼저 마이그레이션 실행
   - 로컬에서 테스트 및 확인
   - 운영 DB 마이그레이션은 명시적 요청 시에만

## 향후 고려사항

### 1. 사용자 타임존 지원 (선택사항)
현재는 모든 사용자에게 한국 시간을 표시하지만, 향후 다음과 같은 개선이 가능합니다:
```javascript
// 사용자 브라우저의 타임존으로 표시
function formatDateUserTimezone(dateString) {
    const date = new Date(dateString);
    return date.toLocaleDateString(undefined, {
        year: 'numeric',
        month: 'long',
        day: 'numeric',
        hour: '2-digit',
        minute: '2-digit'
    });
}
```

### 2. 상대 시간 표시 (선택사항)
```javascript
// "방금 전", "3시간 전", "2일 전" 등
function formatRelativeTime(dateString) {
    const date = new Date(dateString);
    const now = new Date();
    const diff = now - date;
    // ... 상대 시간 계산 로직
}
```

## 참고 자료

- PostgreSQL TIMESTAMPTZ: https://www.postgresql.org/docs/current/datatype-datetime.html
- Go time 패키지: https://pkg.go.dev/time
- JavaScript Date API: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Date

## 작업 일시
- 날짜: 2025-10-23
- 작업자: Claude Code
- 소요 시간: 약 1시간
