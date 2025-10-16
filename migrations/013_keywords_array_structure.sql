-- keywords 테이블 배열 구조로 확장
-- 목표: 현재 API 최소 영향으로 배열 기반 구조 도입
-- 실행일: 2025-10-13

-- 1. keywords 테이블에 배열 컬럼 추가
ALTER TABLE keywords
ADD COLUMN IF NOT EXISTS hymn_numbers INTEGER[] DEFAULT '{}',
ADD COLUMN IF NOT EXISTS bible_chapters JSONB DEFAULT '[]',
-- 형식: [{"book": "창", "chapter": 1}, {"book": "시", "chapter": 23}]
ADD COLUMN IF NOT EXISTS prayer_ids INTEGER[] DEFAULT '{}';

-- 2. 배열 검색용 GIN 인덱스 추가 (성능 최적화)
CREATE INDEX IF NOT EXISTS idx_keywords_hymn_numbers ON keywords USING GIN(hymn_numbers);
CREATE INDEX IF NOT EXISTS idx_keywords_bible_chapters ON keywords USING GIN(bible_chapters);
CREATE INDEX IF NOT EXISTS idx_keywords_prayer_ids ON keywords USING GIN(prayer_ids);

-- 3. 기존 카운트 컬럼과 동기화 (임시)
-- 나중에 카운트 컬럼을 제거하고 배열 길이로 대체 가능
UPDATE keywords SET
    hymn_count = COALESCE(array_length(hymn_numbers, 1), 0),
    prayer_count = COALESCE(array_length(prayer_ids, 1), 0);

-- 4. 테스트용 샘플 데이터 (찬양 키워드)
UPDATE keywords
SET
    hymn_numbers = ARRAY[6, 8, 42, 54, 67, 80, 92, 108, 125, 150],
    bible_chapters = '[
        {"book": "시", "chapter": 150},
        {"book": "시", "chapter": 100},
        {"book": "대상", "chapter": 16},
        {"book": "계", "chapter": 5}
    ]'::jsonb,
    prayer_ids = ARRAY[1, 5, 9]
WHERE name = '찬양';

-- 5. 테스트용 샘플 데이터 (감사 키워드)
UPDATE keywords
SET
    hymn_numbers = ARRAY[15, 23, 45, 78, 89, 102, 200, 301, 428, 589],
    bible_chapters = '[
        {"book": "시", "chapter": 100},
        {"book": "살전", "chapter": 5},
        {"book": "엡", "chapter": 5},
        {"book": "골", "chapter": 3}
    ]'::jsonb,
    prayer_ids = ARRAY[2, 7, 12, 15]
WHERE name = '감사';

-- 6. 테스트용 샘플 데이터 (사랑 키워드)
UPDATE keywords
SET
    hymn_numbers = ARRAY[9, 15, 22, 45, 93, 199, 204, 310, 412, 545],
    bible_chapters = '[
        {"book": "고전", "chapter": 13},
        {"book": "요일", "chapter": 4},
        {"book": "요", "chapter": 3},
        {"book": "롬", "chapter": 8}
    ]'::jsonb,
    prayer_ids = ARRAY[3, 8, 11]
WHERE name = '사랑';

-- 확인 쿼리
SELECT
    name,
    category,
    array_length(hymn_numbers, 1) as hymn_count_new,
    hymn_count as hymn_count_old,
    array_length(prayer_ids, 1) as prayer_count_new,
    prayer_count as prayer_count_old,
    jsonb_array_length(bible_chapters) as bible_chapter_count
FROM keywords
WHERE name IN ('찬양', '감사', '사랑');

-- 사용 예시:
-- 찬양과 관련된 찬송가 번호들 조회
-- SELECT hymn_numbers FROM keywords WHERE name = '찬양';

-- 특정 찬송가가 어떤 키워드에 속하는지 조회
-- SELECT name FROM keywords WHERE 15 = ANY(hymn_numbers);