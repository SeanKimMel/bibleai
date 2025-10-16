# 역방향 키워드 시스템 설계 (키워드 중심)

## 💡 핵심 인사이트
- **데이터 추가**: 거의 없음 (찬송가 645개 고정)
- **접근 패턴**: 키워드 → 콘텐츠들 (역방향)
- **주요 유스케이스**: "찬양" 클릭 → 관련된 모든 콘텐츠 표시

## 🔄 기존 접근 vs 역방향 접근

### 기존 (정규화된 접근)
```sql
-- 찬송가 → 키워드들
SELECT k.name FROM hymns h
JOIN hymn_keywords hk ON h.id = hk.hymn_id
JOIN keywords k ON k.id = hk.keyword_id
WHERE h.id = 1;
```

### 역방향 (키워드 중심)
```sql
-- keywords 테이블 확장
ALTER TABLE keywords ADD COLUMN hymn_ids INTEGER[];
ALTER TABLE keywords ADD COLUMN verse_ids INTEGER[];
ALTER TABLE keywords ADD COLUMN prayer_ids INTEGER[];

-- 데이터 예시
UPDATE keywords SET
    hymn_ids = ARRAY[1, 5, 9, 15, 22, 45, 89],
    verse_ids = ARRAY[101, 102, 345],
    prayer_ids = ARRAY[1, 3, 5]
WHERE name = '찬양';
```

## 📊 구조 설계 옵션

### 옵션 1: PostgreSQL 배열 타입
```sql
CREATE TABLE keywords (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) UNIQUE,
    category VARCHAR(20),
    hymn_ids INTEGER[],      -- 찬송가 ID 배열
    verse_ids INTEGER[],      -- 성경구절 ID 배열
    prayer_ids INTEGER[],     -- 기도문 ID 배열
    hymn_count INTEGER GENERATED ALWAYS AS (cardinality(hymn_ids)) STORED,
    verse_count INTEGER GENERATED ALWAYS AS (cardinality(verse_ids)) STORED,
    prayer_count INTEGER GENERATED ALWAYS AS (cardinality(prayer_ids)) STORED
);

-- 검색 쿼리 (매우 간단!)
SELECT * FROM keywords WHERE name = '찬양';
-- 결과: 바로 모든 ID들을 얻음

-- 찬송가 가져오기
SELECT * FROM hymns WHERE id = ANY(
    SELECT hymn_ids FROM keywords WHERE name = '찬양'
);
```

### 옵션 2: JSONB 구조
```sql
CREATE TABLE keywords (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) UNIQUE,
    category VARCHAR(20),
    content_refs JSONB
);

-- 데이터 예시
{
    "hymns": [1, 5, 9, 15, 22],
    "verses": [101, 102, 345],
    "prayers": [1, 3, 5],
    "hymn_count": 5,
    "verse_count": 3,
    "prayer_count": 3
}
```

### 옵션 3: 하이브리드 (캐시 테이블)
```sql
-- 메인 데이터는 정규화 유지
CREATE TABLE hymn_keywords (...);

-- 캐시 테이블 추가 (읽기 최적화)
CREATE TABLE keyword_cache (
    keyword_id INTEGER PRIMARY KEY,
    keyword_name VARCHAR(50),
    hymn_ids INTEGER[],
    verse_ids INTEGER[],
    prayer_ids INTEGER[],
    last_updated TIMESTAMP
);

-- 주기적으로 또는 트리거로 업데이트
CREATE OR REPLACE FUNCTION refresh_keyword_cache() ...
```

## 🚀 역방향 접근의 장점

1. **초고속 조회**
   - 단일 쿼리로 모든 관련 ID 획득
   - JOIN 불필요
   - 인덱스만으로 처리

2. **메모리 효율적**
   - 키워드 수 < 100개
   - 각 배열 평균 10-50개 ID
   - 전체 캐시 가능

3. **API 심플해짐**
```go
// 단순한 구현
func GetContentsByKeyword(keyword string) {
    row := db.QueryRow("SELECT hymn_ids, verse_ids, prayer_ids FROM keywords WHERE name = $1", keyword)
    // 바로 사용
}
```

4. **통계 즉시 조회**
   - COUNT 쿼리 불필요
   - 배열 길이가 곧 카운트

## 📉 트레이드오프

### 단점:
- 역방향 업데이트 필요 (찬송가 추가 시)
- 정규화 원칙 위배
- 데이터 중복 가능성

### 하지만:
- **데이터 변경 거의 없음** ✅
- **읽기 99.9%** ✅
- **키워드 수 적음** (< 100개) ✅
- **전체 데이터 작음** (찬송가 645개) ✅

## 🎯 구현 전략

### Phase 1: 키워드 테이블 수정
```sql
-- 1. 컬럼 추가
ALTER TABLE keywords
ADD COLUMN hymn_ids INTEGER[] DEFAULT '{}',
ADD COLUMN verse_ids INTEGER[] DEFAULT '{}',
ADD COLUMN prayer_ids INTEGER[] DEFAULT '{}';

-- 2. 인덱스 추가 (GIN 인덱스로 배열 검색 최적화)
CREATE INDEX idx_keywords_hymn_ids ON keywords USING GIN(hymn_ids);
```

### Phase 2: 데이터 마이그레이션
```python
# Python 스크립트로 일괄 업데이트
for keyword in keywords:
    hymn_ids = analyze_hymns_for_keyword(keyword)
    update_keyword_arrays(keyword, hymn_ids)
```

### Phase 3: API 수정
```go
// 심플해진 API
func (h *Handlers) GetKeywordContent(c *gin.Context) {
    keyword := c.Param("keyword")

    var hymnIDs, verseIDs, prayerIDs []int
    db.QueryRow(`
        SELECT hymn_ids, verse_ids, prayer_ids
        FROM keywords WHERE name = $1
    `, keyword).Scan(&hymnIDs, &verseIDs, &prayerIDs)

    // 바로 응답
    c.JSON(200, gin.H{
        "hymns": hymnIDs,
        "verses": verseIDs,
        "prayers": prayerIDs,
    })
}
```

## 🔍 성능 비교

| 작업 | 정규화(JOIN) | 역방향(배열) |
|-----|------------|------------|
| 키워드별 찬송가 조회 | 3-way JOIN | 단일 SELECT |
| 카운트 조회 | COUNT + JOIN | 배열 길이 |
| 찬송가의 키워드들 | 간단 | 전체 스캔 필요 |
| 메모리 사용 | 낮음 | 약간 높음 |
| 쿼리 복잡도 | 높음 | 매우 낮음 |

## 📝 결론

**역방향 접근이 이 프로젝트에 최적인 이유:**
1. 데이터가 정적 (변경 거의 없음)
2. 키워드 → 콘텐츠 접근이 주요 패턴
3. 전체 데이터셋이 작음
4. 읽기 성능이 중요

**Redis 필요 없음!** PostgreSQL 배열로 충분한 성능