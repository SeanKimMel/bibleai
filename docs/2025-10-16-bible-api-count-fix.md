# 성경 API 카운트 불일치 문제 해결

**날짜**: 2025-10-16
**작업자**: Claude
**관련 이슈**: 성경 API 응답 개수와 홈 탭 표시 개수 불일치

## 📋 작업 요약

성경 검색 API(`/api/bible/search/chapters`)가 키워드당 5개 장을 반환해야 하는데 37개의 테마 레코드를 반환하던 문제를 해결했습니다.

## 🔍 문제 발견

### 증상
```bash
# 홈 탭 표시: 사랑 키워드 5개 장
# 실제 API 응답: 37개 레코드

curl "http://localhost:8080/api/bible/search/chapters?q=사랑" | jq '.total'
# 출력: 37 (기대값: 5)
```

### 근본 원인
1. **keywords 테이블**: `bible_count = 5` (고유 장 개수)
   - 사랑 키워드: 고전:13, 요일:4, 요:3, 롬:8, 엡:5 (5개 장)

2. **bible_chapter_themes 테이블**: 각 장마다 여러 테마 보유
   - 로마서 8장 → 11개 테마 (의, 하나님, 일, 성령, 예수, 죄, 사랑, 영광, 자녀, 고난, 형제)
   - 요한일서 4장 → 6개 테마
   - 에베소서 5장 → 8개 테마
   - 요한복음 3장 → 8개 테마
   - 고린도전서 13장 → 4개 테마
   - **합계**: 37개 테마 레코드

3. **API 로직**: 5개 장의 모든 테마를 반환하여 37개 레코드 발생

## 🛠️ 해결 방법

### 수정 파일
- `internal/handlers/bible_import.go` (라인 1006-1032)

### 변경 내용
**변경 전**: 각 장의 모든 테마를 반환
```sql
SELECT DISTINCT
    bct.book,
    bct.book_name,
    bct.chapter,
    bct.theme,
    bct.relevance_score,
    bct.keyword_count
FROM bible_chapter_themes bct
CROSS JOIN jsonb_array_elements($1::jsonb) AS chapter_elem
WHERE bct.book = (chapter_elem->>'book')
  AND bct.chapter = (chapter_elem->>'chapter')::int
ORDER BY ...
```

**변경 후**: 각 장마다 가장 관련성 높은 테마 1개만 선택
```sql
WITH ranked_themes AS (
    SELECT DISTINCT
        bct.book,
        bct.book_name,
        bct.chapter,
        bct.theme,
        bct.relevance_score,
        bct.keyword_count,
        ROW_NUMBER() OVER (
            PARTITION BY bct.book, bct.chapter
            ORDER BY bct.relevance_score DESC, bct.keyword_count DESC
        ) AS rn
    FROM bible_chapter_themes bct
    CROSS JOIN jsonb_array_elements($1::jsonb) AS chapter_elem
    WHERE bct.book = (chapter_elem->>'book')
      AND bct.chapter = (chapter_elem->>'chapter')::int
)
SELECT book, book_name, chapter, theme, relevance_score, keyword_count
FROM ranked_themes
WHERE rn = 1
ORDER BY
    relevance_score DESC,
    keyword_count DESC,
    book,
    chapter
```

### 핵심 개선 사항
1. **윈도우 함수 적용**: `ROW_NUMBER() OVER (PARTITION BY book, chapter ...)`
2. **장별 최고 테마 선택**: `WHERE rn = 1`로 각 장당 1개만 선택
3. **정렬 기준**: `relevance_score DESC, keyword_count DESC`로 가장 관련성 높은 테마 우선

## 📊 테스트 결과

### 수정 전 (불일치)
```
키워드   | 홈 탭 | 실제 API | 상태
---------|-------|----------|------
사랑     | 5개   | 37개     | ❌
믿음     | 5개   | 41개     | ❌
소망     | 4개   | 32개     | ❌
...
```

### 수정 후 (완전 일치)
```
키워드   | 성경   | 찬송가  | 기도문  | 상태
---------|--------|---------|---------|------
사랑     | 5=5    | 30=30   | 8=8     | ✅
믿음     | 5=5    | 20=20   | 3=3     | ✅
소망     | 4=4    | 10=10   | 1=1     | ✅
기쁨     | 4=4    | 20=20   | 5=5     | ✅
감사     | 5=5    | 20=20   | 3=3     | ✅
용서     | 4=4    | 20=20   | 1=1     | ✅
평안     | 4=4    | 18=18   | 7=7     | ✅
지혜     | 4=4    | 20=20   | 4=4     | ✅
구원     | 5=5    | 30=30   | 4=4     | ✅
은혜     | 5=5    | 20=20   | 2=2     | ✅
```

**검증 결과**: 10개 키워드 모두 100% 일치 ✅

### API 응답 예시 (사랑 키워드)
```json
{
  "query": "사랑",
  "total": 5,
  "search_type": "chapter_based",
  "results": [
    {
      "book": "rm",
      "book_name": "로마서",
      "chapter": 8,
      "theme": "의",
      "relevance_score": 10,
      "keyword_count": 24
    },
    {
      "book": "1jo",
      "book_name": "요한일서",
      "chapter": 4,
      "theme": "하나님",
      "relevance_score": 10,
      "keyword_count": 15
    },
    {
      "book": "eph",
      "book_name": "에베소서",
      "chapter": 5,
      "theme": "의",
      "relevance_score": 10,
      "keyword_count": 15
    },
    {
      "book": "jo",
      "book_name": "요한복음",
      "chapter": 3,
      "theme": "의",
      "relevance_score": 10,
      "keyword_count": 13
    },
    {
      "book": "1co",
      "book_name": "고린도전서",
      "chapter": 13,
      "theme": "사랑",
      "relevance_score": 6,
      "keyword_count": 6
    }
  ]
}
```

## 🎯 개선 효과

### 1. 데이터 일관성 확보
- ✅ 홈 탭 표시 개수와 API 응답 개수 100% 일치
- ✅ 사용자가 보는 숫자와 실제 결과가 동일

### 2. API 응답 품질 향상
- ✅ 각 장마다 가장 관련성 높은 테마만 표시
- ✅ 중복 제거로 깔끔한 결과

### 3. 성능 개선
- ✅ 응답 크기 감소 (37개 → 5개)
- ✅ 프론트엔드 렌더링 부하 감소

### 4. 사용자 경험 개선
- ✅ 예상 결과 개수와 실제 결과 일치
- ✅ 불필요한 중복 정보 제거

## 📁 영향받는 파일

### 수정된 파일
```
internal/handlers/bible_import.go  # SearchBibleByChapter 함수 수정
```

### 영향받는 API
- `GET /api/bible/search/chapters?q={keyword}` - 성경 장 검색 API

### 영향받는 페이지
- `/` (홈 페이지) - 키워드 탭
- `/bible/search` (성경 검색 페이지)

## 🔗 관련 작업

### 이전 작업 (2025-10-13, 2025-10-14)
- 찬송가 API: 키워드 배열 기반 검색 구현 ✅
- 기도문 API: 키워드 배열 기반 검색 구현 ✅
- 성경 API: 키워드 배열 기반 검색 구현 (하지만 카운트 불일치)

### 이번 작업 (2025-10-16)
- 성경 API: 중복 제거 및 카운트 일치 ✅

### 완료된 시스템
**키워드 배열 기반 통합 검색 시스템** 완전 구현 ✅
- ✅ 찬송가: `hymn_numbers` 배열 → 정확한 매칭
- ✅ 기도문: `prayer_ids` 배열 → 정확한 매칭
- ✅ 성경: `bible_chapters` JSONB 배열 → 정확한 매칭 (고유 장만)

## 💡 기술적 인사이트

### SQL 윈도우 함수 활용
- `ROW_NUMBER()`: 각 파티션 내에서 순위 부여
- `PARTITION BY`: 그룹별 독립적 순위 계산
- `ORDER BY`: 순위 정렬 기준 지정

### 키워드 배열 시스템의 장점
1. **정확성**: 수작업으로 큐레이션된 정확한 매칭
2. **일관성**: 동일한 키워드는 항상 동일한 결과
3. **성능**: 인덱스 기반 빠른 조회
4. **관리**: 배열 데이터만 업데이트하면 즉시 반영

### 듀얼 검색 전략
1. **우선**: keywords 테이블 배열 기반 정확한 매칭
2. **폴백**: ILIKE 기반 자유 검색 (비키워드)

## 📚 참고 자료

### 관련 문서
- [2025-10-13 키워드 배열 구현](/workspace/bibleai/docs/2025-10-13-keyword-array-implementation.md)
- [2025-10-14 기도문 데이터 완성](/workspace/bibleai/docs/2025-10-14-prayer-data-completion.md)
- [2025-10-15 블로그 API 통합](/workspace/bibleai/docs/2025-10-15-blog-api-integration.md)

### 데이터베이스 구조
```sql
-- keywords 테이블
CREATE TABLE keywords (
    name VARCHAR(50) PRIMARY KEY,
    hymn_numbers INTEGER[],              -- 찬송가 번호 배열
    bible_chapters JSONB,                -- 성경 장 JSONB 배열
    prayer_ids INTEGER[],                -- 기도문 ID 배열
    hymn_count INTEGER DEFAULT 0,
    bible_count INTEGER DEFAULT 0,
    prayer_count INTEGER DEFAULT 0
);

-- bible_chapter_themes 테이블
CREATE TABLE bible_chapter_themes (
    book VARCHAR(10),
    chapter INTEGER,
    theme VARCHAR(50),
    relevance_score INTEGER,
    keyword_count INTEGER,
    book_name VARCHAR(50)
);
```

## 🚀 다음 단계

### 즉시 가능
- [x] 성경 API 카운트 불일치 해결
- [x] 전체 키워드 검증 완료

### 추가 개선 사항 (선택)
- [ ] 테마 선택 로직 개선 (키워드와 테마 매칭 점수 고려)
- [ ] 성경 장 모달에 선택된 테마 하이라이트
- [ ] 키워드별 추천 테마 시스템
- [ ] 사용자 피드백 기반 테마 순위 조정

## ✅ 작업 완료

**상태**: 완료 ✅
**배포**: 로컬 서버 재시작 완료
**검증**: 10개 키워드 모두 100% 일치 확인
**문서화**: 완료

---

**작업 시작**: 2025-10-16 13:00
**작업 완료**: 2025-10-16 13:45
**총 소요 시간**: 약 45분
