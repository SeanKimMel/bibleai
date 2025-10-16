# 키워드 배열 기반 검색 시스템 구현

**작업일**: 2025-10-13
**목표**: 키워드 테이블의 배열 데이터를 활용한 듀얼 검색 전략 구현

## 구현 완료 사항

### 1. 찬송가 API 수정 (`SearchHymns`)

**파일**: `/workspace/bibleai/internal/handlers/hymns.go`

**변경 내용**:
- 키워드 테이블의 `hymn_numbers` 배열 우선 조회
- 배열이 없으면 ILIKE 기반 자유 검색으로 폴백
- `pq.Int64Array` 사용하여 PostgreSQL integer[] 배열 처리
- int64 → int 변환 후 `pq.Array()` 사용

**검색 로직**:
```
1. keywords 테이블에서 hymn_numbers 배열 조회
2. 배열이 있으면 → WHERE number = ANY($1) 정확한 매칭
3. 배열이 없으면 → ILIKE 기반 제목/가사 검색
```

**테스트 결과**:
- ✅ "사랑" 키워드: 30개 찬송가 (키워드 배열 기반)
- ✅ "찬양하라" (비키워드): 13개 찬송가 (ILIKE 기반)

### 2. 기도문 API 수정 (`SearchPrayers`)

**파일**: `/workspace/bibleai/internal/handlers/prayers.go`

**변경 내용**:
- 키워드 테이블의 `prayer_ids` 배열 우선 조회
- 배열이 없으면 ILIKE 기반 자유 검색으로 폴백
- 찬송가 API와 동일한 패턴 적용

**검색 로직**:
```
1. keywords 테이블에서 prayer_ids 배열 조회
2. 배열이 있으면 → WHERE id = ANY($1) 정확한 매칭
3. 배열이 없으면 → ILIKE 기반 제목/내용/태그 검색
```

**테스트 상태**:
- ⚠️ 개발 환경에 prayers 테이블 없음 (테스트 불가)
- 구현은 완료, 운영 환경에서 테스트 필요

### 3. 성경 API 수정 (`SearchBibleByChapter`)

**파일**: `/workspace/bibleai/internal/handlers/bible_import.go`

**변경 내용**:
- 키워드 테이블의 `bible_chapters` JSONB 배열 우선 조회
- **한글 축약형 → 영문 코드 매핑 추가** (중요!)
- 배열이 없으면 ILIKE 기반 자유 검색으로 폴백

**검색 로직**:
```
1. keywords 테이블에서 bible_chapters JSONB 배열 조회
2. JSONB 파싱: [{"book":"고전","chapter":13},...]
3. 한글 코드를 영문 코드로 변환 (고전→1co, 요일→1jo 등)
4. 변환된 JSONB로 bible_chapter_themes 테이블 조회
5. 배열이 없으면 → ILIKE 기반 주제(theme) 검색
```

**한글-영문 매핑** (lines 939-954):
```go
koreanToCodeMap := map[string]string{
    "창": "gn", "출": "ex", "레": "lv", "민": "nm", "신": "dt",
    "고전": "1co", "고후": "2co", "요일": "1jo", "요이": "2jo",
    "요삼": "3jo", "롬": "rm", "엡": "eph", ...
}
```

**테스트 결과**:
- ✅ "사랑" 키워드: 5개 고유 챕터 (키워드 배열 기반)
  - 고전:13 → 1co:13 ✅
  - 요일:4 → 1jo:4 ✅
  - 요:3 → jo:3 ✅
  - 롬:8 → rm:8 ✅
  - 엡:5 → eph:5 ✅
- ✅ "회개" (비키워드): 4개 챕터 (ILIKE 기반)

### 4. 키워드 카운트 동기화

**파일**: `/workspace/bibleai/migrations/014_fix_keyword_counts_function.sql`

**변경 내용**:
- `update_keyword_counts()` 함수를 배열 길이 기반으로 수정
- ILIKE 검색 방식에서 배열 길이 카운트 방식으로 변경
- 서버 시작 시 자동 실행 (`cmd/server/main.go` line 65)

**함수 로직**:
```sql
UPDATE keywords
SET
    hymn_count = COALESCE(array_length(hymn_numbers, 1), 0),
    bible_count = COALESCE(jsonb_array_length(bible_chapters), 0),
    prayer_count = COALESCE(array_length(prayer_ids, 1), 0),
    updated_at = CURRENT_TIMESTAMP;
```

## 기술적 주요 포인트

### PostgreSQL 배열 처리

**Integer 배열**:
```go
// ❌ 잘못된 방식
var numbers []int
db.QueryRow("...").Scan(pq.Array(&numbers))

// ✅ 올바른 방식
var numbers pq.Int64Array
db.QueryRow("...").Scan(&numbers)

// int64 → int 변환
numbersInt := make([]int, len(numbers))
for i, n := range numbers {
    numbersInt[i] = int(n)
}
```

**JSONB 배열**:
```go
// JSONB 바이트 배열로 스캔
var jsonData []byte
db.QueryRow("...").Scan(&jsonData)

// JSON 파싱
type Item struct {
    Book    string `json:"book"`
    Chapter int    `json:"chapter"`
}
var items []Item
json.Unmarshal(jsonData, &items)
```

### 듀얼 검색 전략 패턴

```go
// 1. 키워드 배열 조회 시도
var arrayData pq.Int64Array
err := db.QueryRow("SELECT array_col FROM keywords WHERE name = $1", keyword).Scan(&arrayData)

if err == nil && len(arrayData) > 0 {
    // 배열 기반 정확한 매칭
    rows, err = db.Query("SELECT ... WHERE id = ANY($1)", pq.Array(convertedData))
    if err == nil {
        goto processResults
    }
}

// 2. ILIKE 기반 자유 검색 (폴백)
rows, err = db.Query("SELECT ... WHERE title ILIKE $1 OR content ILIKE $1", "%"+keyword+"%")

processResults:
// 결과 처리
```

## 남은 작업 (TODO)

### 1. 기도문 테이블 생성 및 데이터 준비
- [ ] 개발 환경에 `prayers` 테이블 생성
- [ ] 기도문 샘플 데이터 삽입
- [ ] `SearchPrayers` API 테스트

### 2. 성경 구절 검색 API (`SearchBible`)
- [ ] `/api/bible/search` 엔드포인트 수정
- [ ] 키워드 테이블에 `bible_verses` 배열 컬럼 추가 검토
- [ ] 구절 단위 검색에도 듀얼 전략 적용 여부 결정

### 3. 키워드 관리 기능
- [ ] 키워드 추가/수정/삭제 API
- [ ] 배열 데이터 수동 관리 인터페이스
- [ ] 키워드-콘텐츠 매핑 자동 업데이트 시스템

### 4. 성능 최적화
- [ ] 키워드 테이블 인덱스 최적화
- [ ] JSONB GIN 인덱스 추가 검토
- [ ] 배열 조회 성능 측정 및 튜닝

### 5. 검색 품질 개선
- [ ] 키워드 우선순위 시스템
- [ ] 동의어/유의어 처리
- [ ] 검색 결과 관련도 점수 개선

### 6. 프론트엔드 연동
- [ ] 키워드 추천 UI 구현
- [ ] 검색 결과 유형 구분 표시 (키워드 기반 vs 자유 검색)
- [ ] 추천 키워드 자동완성

### 7. 모니터링 및 분석
- [ ] 검색 쿼리 로깅
- [ ] 키워드 사용 빈도 추적
- [ ] 검색 성능 메트릭 수집

## 배포 체크리스트

### 운영 배포 전 확인사항
- [ ] 모든 API 테스트 완료
- [ ] 키워드 카운트 동기화 확인
- [ ] 한글-영문 매핑 완전성 검증
- [ ] 성능 벤치마크 수행
- [ ] 롤백 계획 준비

### 배포 순서
1. 데이터베이스 마이그레이션 실행
2. `update_keyword_counts()` 함수 실행
3. 서버 재시작
4. 각 API 엔드포인트 테스트
5. 로그 모니터링

## UI 일관성 개선 작업 (2025-10-13 후반)

### 블로그 페이지 기준 UI 통일

**목표**: 모든 페이지의 UI 스타일을 블로그 페이지 기준으로 통일하여 일관성 확보

#### 변경된 파일
1. `/workspace/bibleai/web/templates/pages/bible-search.html`
2. `/workspace/bibleai/web/templates/pages/hymns-new.html`
3. `/workspace/bibleai/web/templates/pages/z-home.html`
4. `/workspace/bibleai/web/templates/pages/a-prayers.html`
5. `/workspace/bibleai/web/templates/pages/bible-analysis.html`
6. `/workspace/bibleai/web/templates/layout/base.html`

#### 주요 변경사항

**1. 헤더 스타일 통일**
- 패딩: `p-8` → `p-6` (더 컴팩트하게)
- 제목 크기: `text-4xl` → `text-2xl`
- 부제목 크기: `text-lg` → `text-sm`
- 아이콘 크기: `w-20 h-20` → `w-12 h-12`, `rounded-2xl` → `rounded-xl`
- 레이아웃: 중앙 정렬 → 좌측 정렬 (`flex items-center space-x-4`)
- 불필요한 장식 요소 제거 (절대 위치 원형 배경 등)

**2. 텍스트 색상 통일**
- 제목: 페이지별 색상(blue-900, teal-900, purple-900) → `text-gray-900` (모든 페이지 통일)
- 부제목: 페이지별 색상(blue-600, teal-600 등) → `text-gray-600` (모든 페이지 통일)

**3. 카드 스타일 통일**
- 라운드: `rounded-3xl` → `rounded-2xl`
- 여백: `mb-8` → `mb-6`, `p-8` → `p-6`
- 그림자: 과도한 그림자 제거

**4. 기도문/키워드 페이지 헤더 추가**
- 기존: 카드 내부에만 제목 존재
- 변경: 다른 페이지와 동일한 상단 헤더 추가
  - 기도문: Green 아이콘
  - 키워드: Orange 아이콘

**5. 헤더 뒤로가기 버튼 제거**
```html
<!-- 제거된 코드 -->
{{if .ShowBackButton}}
<button onclick="history.back()">...</button>
{{end}}
```
- 이유: 하단 네비게이션이 있어 불필요
- 효과: 모든 페이지에서 헤더가 일관되게 표시

**6. 스크롤 위치 초기화**
```javascript
// 브라우저의 자동 스크롤 복원 비활성화
if ('scrollRestoration' in history) {
    history.scrollRestoration = 'manual';
}

// 페이지 로드 시 최상단으로 스크롤
document.addEventListener('DOMContentLoaded', function() {
    window.scrollTo(0, 0);
    setTimeout(() => window.scrollTo(0, 0), 10);
});

// 네비게이션 클릭 시 스크롤 초기화
navBtns.forEach(btn => {
    btn.addEventListener('click', () => window.scrollTo(0, 0));
});
```
- 문제: 탭 전환 시 페이지가 중간으로 스크롤되는 현상
- 해결: 페이지 로드 및 탭 클릭 시 강제로 최상단 이동

**7. 하단 네비게이션 공백 최적화**
```css
/* 변경 전 */
main: pb-28 (112px)
nav: py-2 (16px)
추가 공간: h-20 (80px)

/* 변경 후 */
main: pb-20 (80px)
nav: py-3 (24px)
버튼: py-3 (24px)
추가 공간: 제거
```
- 목적: 불필요한 하단 여백 줄이기
- 효과: 화면 공간 효율 증대

**8. 홈 페이지 중복 코드 제거**
- `z-home.html`에 중복된 네비게이션, `</main>`, `</body>`, `</html>` 태그 제거
- base.html의 통합 레이아웃 사용으로 통일

#### 적용된 디자인 원칙
1. **미니멀리즘**: 불필요한 장식 제거, 깔끔한 UI
2. **일관성**: 모든 페이지 동일한 구조와 스타일
3. **접근성**: 명확한 계층 구조, 읽기 쉬운 폰트 크기
4. **효율성**: 공백 최적화, 화면 공간 효율적 사용

#### 효과
- ✅ 모든 페이지에서 헤더 위치와 크기 완전히 동일
- ✅ 탭 전환 시 페이지 크기 변화 없음
- ✅ 항상 최상단에서 시작하는 일관된 사용자 경험
- ✅ 더 깔끔하고 전문적인 UI

## 참고사항

### 개발 환경 제약
- 개발 환경에는 prayers 테이블이 없어 기도문 API 테스트 불가
- 운영 환경에만 존재하는 데이터는 코드 리뷰로만 검증

### 데이터 일관성
- 키워드 테이블의 배열 데이터는 수동 관리
- 카운트는 서버 시작 시 자동 동기화
- 배열 데이터와 실제 데이터 간 일관성은 수동 확인 필요

### 에러 처리
- 키워드 배열 조회 실패 시 자동으로 ILIKE 검색으로 폴백
- 사용자는 검색 방식 전환을 인지하지 못함 (투명한 폴백)
