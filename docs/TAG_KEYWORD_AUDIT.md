# Tag/Keyword 시스템 전수조사 결과

## 📊 현재 테이블 현황

### 1. **tags 테이블**
- **레코드 수**: 10개
- **구조**: id, name, description
- **실제 사용**:
  - `/api/tags` - 태그 목록 조회
  - `/api/prayers/by-tags` - 태그별 기도문 조회
  - `/api/prayers/:id/tags` - 기도문에 태그 추가
  - `/api/verses/by-tag/:tag` - 태그별 성경구절 (하드코딩!)

### 2. **keywords 테이블**
- **레코드 수**: 43개
- **구조**: id, name, category, hymn_count, verse_count, prayer_count, icon, description, is_featured
- **실제 사용**:
  - `/api/keywords` - 모든 키워드 조회
  - `/api/keywords/featured` - 추천 키워드 조회
  - `/api/keywords/:keyword/counts` - 키워드별 카운트 (더미 데이터!)

### 3. **prayer_tags 테이블**
- **레코드 수**: 0개 (비어있음!)
- **구조**: prayer_id, tag_id
- **실제 사용**: 없음 (데이터가 없어서)

## 🔴 발견된 문제점

### 1. **중복된 시스템**
- `tags` (10개) vs `keywords` (43개) - 두 개가 비슷한 역할
- 태그는 기도문용, 키워드는 전체용으로 분리됨
- 실제로는 둘 다 제대로 사용 안 됨

### 2. **하드코딩된 데이터**
```go
// GetVersesByTag - 성경구절이 하드코딩됨!
verseMapping := map[string][]map[string]interface{}{
    "감사": {
        {"book": "ps", "chapter": 100, "verse": 4, ...},
    },
    "위로": {...},
    "용기": {...},
}
```

### 3. **더미 데이터 반환**
```go
// GetKeywordContentCounts - 실제 매핑 없이 더미 반환
counts["verses"] = 3 + len(keywordName)%5  // 더미
counts["hymns"] = 2 + len(keywordName)%4   // 더미
```

### 4. **사용 안 되는 테이블**
- `prayer_tags`: 비어있음 (0개)
- 매핑 테이블들 전부 삭제됨

## 📈 실제 API 사용 패턴

### 사용 중인 API:
1. `/api/tags` - 태그 목록 (10개 반환)
2. `/api/keywords/featured` - 메인 페이지 키워드
3. `/api/hymns/theme/:theme` - 찬송가 테마 검색

### 실제로 안 쓰이는 API:
1. `/api/prayers/by-tags` - prayer_tags가 비어있음
2. `/api/verses/by-tag/:tag` - 하드코딩된 데이터만
3. `/api/keywords/:keyword/counts` - 더미 데이터

## 💡 최적화 제안

### 통합 키워드 시스템 (역방향)
```sql
-- 기존 keywords 테이블 확장
ALTER TABLE keywords
ADD COLUMN hymn_numbers INTEGER[],  -- [1,5,9,15,22]
ADD COLUMN bible_refs JSONB,        -- [{"book":"ps","chapter":100},...]
ADD COLUMN prayer_ids INTEGER[];    -- [1,3,5]

-- 예시 데이터
UPDATE keywords SET
    hymn_numbers = ARRAY[1,5,9,15,22,45,89],
    bible_refs = '[
        {"book":"ps","chapter":100,"verses":[1,2,3,4]},
        {"book":"mt","chapter":5,"verses":[3,4,5,6,7]}
    ]'::jsonb,
    prayer_ids = ARRAY[1,3,5]
WHERE name = '감사';
```

### 장점:
1. **단일 테이블**로 모든 매핑 관리
2. **JOIN 없이** 바로 데이터 획득
3. **하드코딩 제거** 가능
4. **실제 데이터 사용**

### 구현 예시:
```go
// 심플해진 API
func GetKeywordContent(keyword string) {
    var hymnNumbers []int
    var bibleRefs json.RawMessage
    var prayerIDs []int

    db.QueryRow(`
        SELECT hymn_numbers, bible_refs, prayer_ids
        FROM keywords WHERE name = $1
    `, keyword).Scan(&hymnNumbers, &bibleRefs, &prayerIDs)

    // 바로 반환 (JOIN 없음!)
}
```

## 🎯 액션 플랜

### Phase 1: 정리
1. `tags` 테이블과 `keywords` 테이블 통합
2. `prayer_tags` 테이블 제거 (사용 안 됨)
3. 하드코딩된 성경구절 DB로 이동

### Phase 2: 역방향 구조 구현
1. `keywords` 테이블에 배열 필드 추가
2. 찬송가 번호, 성경 장, 기도문 ID 매핑
3. API 수정하여 실제 데이터 반환

### Phase 3: 최적화
1. GIN 인덱스로 배열 검색 최적화
2. 캐싱 레이어 추가 (필요시)
3. 프론트엔드 API 통합

## 📉 삭제 가능한 것들
- `prayer_tags` 테이블 (비어있음)
- `tags` 테이블 (keywords로 통합)
- 하드코딩된 verseMapping
- 더미 데이터 반환 로직