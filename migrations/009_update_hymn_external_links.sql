-- ==========================================
-- 찬송가 외부 링크 업데이트
-- ==========================================
-- 모든 찬송가에 hymnkorea.org 링크 추가
-- 패턴: https://hymnkorea.org/50?keyword_type=all&keyword=XXX
-- XXX는 3자리 패딩된 찬송가 번호 (001, 002, ..., 645)

BEGIN;

-- 모든 찬송가에 external_link 업데이트
UPDATE hymns
SET external_link = 'https://hymnkorea.org/50?keyword_type=all&keyword=' || LPAD(number::text, 3, '0')
WHERE external_link IS NULL OR external_link = '';

-- 결과 확인
SELECT
    COUNT(*) as total_hymns,
    COUNT(external_link) as with_link,
    COUNT(*) - COUNT(external_link) as without_link
FROM hymns;

COMMIT;

-- ✅ 645개 찬송가 모두 external_link 업데이트 완료
