-- 005_add_hymn_external_links.sql
-- 찬송가 테이블에 외부 링크 컬럼 추가
-- hymnkorea.org 링크 지원

-- 1. external_link 컬럼 추가 (없는 경우만)
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'hymns' AND column_name = 'external_link'
    ) THEN
        ALTER TABLE hymns ADD COLUMN external_link TEXT;
        RAISE NOTICE 'external_link 컬럼이 hymns 테이블에 추가되었습니다.';
    ELSE
        RAISE NOTICE 'external_link 컬럼이 이미 존재합니다.';
    END IF;
END
$$;

-- 2. 기존 데이터에 hymnkorea.org 링크 업데이트
UPDATE hymns
SET external_link = 'https://hymnkorea.org/50?keyword_type=all&keyword=' || number
WHERE external_link IS NULL OR external_link = '';

-- 3. 업데이트된 행 수 확인
SELECT
    COUNT(*) as total_hymns,
    COUNT(CASE WHEN external_link IS NOT NULL AND external_link != '' THEN 1 END) as hymns_with_links
FROM hymns;

-- 4. 샘플 결과 확인
SELECT number, title, external_link
FROM hymns
WHERE number IN (1, 8, 234, 305, 447)
ORDER BY number
LIMIT 5;

SELECT '✅ 찬송가 외부 링크 추가 작업이 완료되었습니다.' as result;