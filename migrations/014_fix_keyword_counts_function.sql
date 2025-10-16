-- update_keyword_counts 함수를 배열 길이 기반으로 수정
-- 목표: 카운트 컬럼과 배열 데이터 동기화
-- 실행일: 2025-10-13

-- 기존 함수 삭제 (ILIKE 검색 기반)
DROP FUNCTION IF EXISTS update_keyword_counts();

-- 새로운 함수 생성 (배열 길이 기반)
CREATE OR REPLACE FUNCTION update_keyword_counts()
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
    -- 배열 길이 기반으로 카운트 업데이트
    -- hymn_numbers[], bible_chapters, prayer_ids[] 배열의 실제 길이를 카운트로 사용
    UPDATE keywords
    SET
        hymn_count = COALESCE(array_length(hymn_numbers, 1), 0),
        bible_count = COALESCE(jsonb_array_length(bible_chapters), 0),
        prayer_count = COALESCE(array_length(prayer_ids, 1), 0),
        updated_at = CURRENT_TIMESTAMP;

    RAISE NOTICE 'Keyword counts updated from array lengths';
END;
$$;

-- 즉시 실행해서 카운트 동기화
SELECT update_keyword_counts();

-- 결과 확인 쿼리
SELECT
    name,
    hymn_count,
    array_length(hymn_numbers, 1) as actual_hymn_count,
    bible_count,
    jsonb_array_length(bible_chapters) as actual_bible_count,
    prayer_count,
    array_length(prayer_ids, 1) as actual_prayer_count
FROM keywords
WHERE hymn_count > 0 OR bible_count > 0 OR prayer_count > 0
ORDER BY name;
