# 키워드 시스템 재설계 - 확장성 고려

## 🎯 핵심 설계 원칙

### 1. 단일 키워드 테이블
- 모든 콘텐츠(성경/찬송가/기도문)가 하나의 `keywords` 테이블 참조
- tags와 keywords 통합

### 2. 유사도 기반 매핑
- 각 콘텐츠별 키워드 유사도 점수 저장
- 배치 프로세스로 주기적 업데이트

### 3. 역방향 인덱싱
- 키워드 → 콘텐츠 방향으로 데이터 저장
- JOIN 최소화로 성능 최적화

## 📊 테이블 설계

### Option 1: keywords 테이블 확장 (JSONB 활용)
```sql
CREATE TABLE keywords (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL,
    category VARCHAR(20),

    -- JSONB로 유사도 포함한 매핑 저장
    hymn_mappings JSONB DEFAULT '[]',
    /* 예시:
    [
        {"number": 1, "score": 0.95, "rank": 1},
        {"number": 5, "score": 0.87, "rank": 2},
        {"number": 22, "score": 0.76, "rank": 3}
    ]
    */

    bible_mappings JSONB DEFAULT '[]',
    /* 예시:
    [
        {"book": "창", "chapter": 1, "score": 0.92, "rank": 1},
        {"book": "시", "chapter": 23, "score": 0.88, "rank": 2}
    ]
    */

    prayer_mappings JSONB DEFAULT '[]',

    -- 카운트는 자동 계산
    total_mappings INTEGER GENERATED ALWAYS AS (
        jsonb_array_length(hymn_mappings) +
        jsonb_array_length(bible_mappings) +
        jsonb_array_length(prayer_mappings)
    ) STORED,

    updated_at TIMESTAMP DEFAULT NOW()
);

-- 인덱싱
CREATE INDEX idx_keywords_hymn_mappings ON keywords USING GIN(hymn_mappings);
CREATE INDEX idx_keywords_bible_mappings ON keywords USING GIN(bible_mappings);
```

### Option 2: 별도 매핑 테이블 (정규화)
```sql
-- 키워드 메인 테이블
CREATE TABLE keywords (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL,
    category VARCHAR(20),
    created_at TIMESTAMP DEFAULT NOW()
);

-- 콘텐츠별 매핑 테이블 (유사도 포함)
CREATE TABLE keyword_content_mappings (
    id SERIAL PRIMARY KEY,
    keyword_id INTEGER REFERENCES keywords(id),
    content_type VARCHAR(10), -- 'hymn', 'bible', 'prayer'
    content_id INTEGER,       -- hymn number 또는 prayer id
    bible_book VARCHAR(10),   -- 성경인 경우
    bible_chapter INTEGER,     -- 성경인 경우
    similarity_score DECIMAL(3,2), -- 0.00 ~ 1.00
    rank INTEGER,              -- 해당 콘텐츠 내 순위

    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),

    -- 복합 인덱스
    UNIQUE(keyword_id, content_type, content_id, bible_book, bible_chapter)
);

CREATE INDEX idx_kcm_keyword ON keyword_content_mappings(keyword_id);
CREATE INDEX idx_kcm_content ON keyword_content_mappings(content_type, content_id);
CREATE INDEX idx_kcm_bible ON keyword_content_mappings(bible_book, bible_chapter);
CREATE INDEX idx_kcm_score ON keyword_content_mappings(similarity_score DESC);
```

### Option 3: 하이브리드 (권장) 🌟
```sql
-- 메인 키워드 테이블 (자주 조회되는 상위 N개만 배열로)
CREATE TABLE keywords (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL,
    category VARCHAR(20),

    -- 상위 10개만 배열로 (빠른 조회용)
    top_hymn_numbers INTEGER[] DEFAULT '{}',
    top_bible_chapters JSONB DEFAULT '[]', -- [{"book":"창","chapter":1}]
    top_prayer_ids INTEGER[] DEFAULT '{}',

    -- 전체 매핑은 JSONB (상세 조회용)
    full_mappings JSONB DEFAULT '{}',
    /* 구조:
    {
        "hymns": [{"number": 1, "score": 0.95}, ...],
        "bible": [{"book": "창", "chapter": 1, "score": 0.92}, ...],
        "prayers": [{"id": 1, "score": 0.88}, ...]
    }
    */

    last_updated TIMESTAMP DEFAULT NOW()
);
```

## 🔄 배치 업데이트 프로세스

### 1. 키워드 추출 및 유사도 계산
```python
# Python 스크립트 예시
def calculate_keyword_similarity(content_text, keyword):
    """
    TF-IDF, 코사인 유사도, 또는 단순 빈도 기반 점수 계산
    """
    score = 0.0

    # 1. 키워드 빈도
    frequency = content_text.lower().count(keyword.lower())

    # 2. 위치 가중치 (제목에 있으면 가산점)
    if keyword in title:
        score += 0.3

    # 3. 정규화
    score = min(1.0, frequency * 0.1 + score)

    return score

def batch_update_keyword_mappings():
    """
    모든 콘텐츠에 대해 키워드 매핑 업데이트
    """
    for keyword in all_keywords:
        hymn_scores = []
        bible_scores = []

        # 찬송가 분석
        for hymn in all_hymns:
            score = calculate_keyword_similarity(
                hymn.title + hymn.lyrics,
                keyword.name
            )
            if score > 0.1:  # threshold
                hymn_scores.append({
                    'number': hymn.number,
                    'score': score
                })

        # 성경 장별 분석
        for chapter in all_bible_chapters:
            score = calculate_keyword_similarity(
                chapter.content,
                keyword.name
            )
            if score > 0.1:
                bible_scores.append({
                    'book': chapter.book,
                    'chapter': chapter.number,
                    'score': score
                })

        # 정렬 및 저장
        hymn_scores.sort(key=lambda x: x['score'], reverse=True)
        bible_scores.sort(key=lambda x: x['score'], reverse=True)

        # DB 업데이트
        update_keyword_mappings(keyword.id, hymn_scores, bible_scores)
```

### 2. 배치 실행 전략
- **주기**: 주 1회 또는 콘텐츠 변경 시
- **시간**: 새벽 시간대 (트래픽 최소)
- **방식**:
  - 전체 재계산 (작은 데이터셋이므로 가능)
  - 또는 변경된 콘텐츠만 증분 업데이트

## 🚀 구현 로드맵

### Phase 1: 스키마 변경
1. keywords 테이블 확장
2. 매핑 데이터 마이그레이션
3. 인덱스 생성

### Phase 2: 배치 프로세스
1. 유사도 계산 스크립트 작성
2. 초기 데이터 생성
3. 크론잡 설정

### Phase 3: API 수정
1. 키워드 조회 API 수정
2. 유사도 기반 정렬 추가
3. 필터링 옵션 추가

## 🎯 최종 추천: Option 3 (하이브리드)

### 이유:
1. **성능**: 상위 N개는 배열로 빠른 조회
2. **유연성**: 전체 데이터는 JSONB로 저장
3. **확장성**: 유사도 점수 포함 가능
4. **단순성**: 단일 테이블로 관리

### 예상 데이터 크기:
- 키워드: 50개
- 찬송가 매핑: 50 × 30개 = 1,500개
- 성경 매핑: 50 × 50장 = 2,500개
- 전체: 약 4,000개 매핑 (JSONB로 ~200KB)

## 📝 변경 체크리스트 추가 사항

### 데이터베이스
- [ ] keywords 테이블 스키마 확장
- [ ] 유사도 계산 함수 생성
- [ ] 배치 업데이트 프로시저 작성

### 백엔드
- [ ] 유사도 기반 정렬 API 추가
- [ ] 필터링 옵션 (score threshold)
- [ ] 캐싱 레이어 검토

### 배치 프로세스
- [ ] Python 유사도 계산 스크립트
- [ ] 크론잡 설정
- [ ] 모니터링 및 로깅

### 프론트엔드
- [ ] 유사도 점수 표시 (선택적)
- [ ] 관련도 순 정렬 옵션