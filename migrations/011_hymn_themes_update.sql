-- 찬송가 테마 업데이트 마이그레이션
-- 기존 매핑 테이블 대신 theme 필드 직접 사용

-- 백업 테이블 정리
DROP TABLE IF EXISTS hymn_keywords_bak CASCADE;
DROP TABLE IF EXISTS prayer_keywords_bak CASCADE;
DROP TABLE IF EXISTS bible_keywords_bak CASCADE;

-- theme 인덱스 최적화
DROP INDEX IF EXISTS idx_hymns_theme;
CREATE INDEX idx_hymns_theme ON hymns(theme);

-- theme별 뷰 생성 (자주 사용되는 쿼리 최적화)
CREATE OR REPLACE VIEW hymn_themes_summary AS
SELECT
    theme,
    COUNT(*) as hymn_count,
    STRING_AGG(CAST(number AS TEXT), ', ' ORDER BY number) AS hymn_numbers
FROM hymns
WHERE theme IS NOT NULL AND theme != ''
GROUP BY theme
ORDER BY hymn_count DESC;

-- theme 통계 함수
CREATE OR REPLACE FUNCTION get_theme_statistics()
RETURNS TABLE(
    theme VARCHAR,
    count INTEGER,
    percentage NUMERIC(5,2)
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        h.theme::VARCHAR,
        COUNT(*)::INTEGER as count,
        ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM hymns), 2) as percentage
    FROM hymns h
    WHERE h.theme IS NOT NULL AND h.theme != ''
    GROUP BY h.theme
    ORDER BY count DESC;
END;
$$ LANGUAGE plpgsql;

-- 주요 테마별 대표 찬송가
CREATE OR REPLACE FUNCTION get_featured_hymns_by_theme(theme_pattern VARCHAR)
RETURNS TABLE(
    number INTEGER,
    title VARCHAR,
    theme VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT h.number, h.title::VARCHAR, h.theme::VARCHAR
    FROM hymns h
    WHERE h.theme LIKE theme_pattern
    ORDER BY h.number
    LIMIT 5;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION get_theme_statistics() IS '찬송가 테마별 통계 조회';
COMMENT ON FUNCTION get_featured_hymns_by_theme(VARCHAR) IS '특정 테마의 대표 찬송가 5개 조회';
COMMENT ON VIEW hymn_themes_summary IS '찬송가 테마별 요약 뷰';