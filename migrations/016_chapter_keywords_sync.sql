-- 장별 키워드 매핑 시스템 및 자동 동기화
--
-- 목적:
-- 1. chapter_primary_keywords 테이블이 마스터 데이터
-- 2. keywords.bible_chapters는 자동으로 동기화됨
-- 3. 데이터 변경은 chapter_primary_keywords만 수정하면 됨

-- ============================================
-- 1. chapter_primary_keywords 테이블 생성
-- ============================================
CREATE TABLE IF NOT EXISTS chapter_primary_keywords (
    book VARCHAR(10),
    chapter INTEGER,
    keywords TEXT[],                          -- 관련 키워드들 (최대 5개)
    primary_keyword VARCHAR(50),              -- 가장 주요한 키워드
    confidence_score INTEGER DEFAULT 5,       -- 1-10: 매칭 신뢰도
    source VARCHAR(20) DEFAULT 'manual',      -- 'auto_analysis' or 'manual'
    notes TEXT,                               -- 선정 이유/맥락
    reviewed_by VARCHAR(100),                 -- 검토자 (Claude, 목회자 등)
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    PRIMARY KEY (book, chapter)
);

-- 인덱스 생성
CREATE INDEX IF NOT EXISTS idx_chapter_keywords_gin ON chapter_primary_keywords USING GIN(keywords);
CREATE INDEX IF NOT EXISTS idx_chapter_primary_keyword ON chapter_primary_keywords(primary_keyword);
CREATE INDEX IF NOT EXISTS idx_chapter_confidence ON chapter_primary_keywords(confidence_score DESC);

-- ============================================
-- 2. keywords.bible_chapters 자동 동기화 함수
-- ============================================
CREATE OR REPLACE FUNCTION sync_keywords_bible_chapters()
RETURNS void AS $$
DECLARE
    keyword_name TEXT;
    chapters_array JSONB;
BEGIN
    -- 각 키워드별로 처리
    FOR keyword_name IN SELECT name FROM keywords LOOP
        -- 해당 키워드가 포함된 모든 장을 JSONB 배열로 생성
        SELECT COALESCE(
            jsonb_agg(
                jsonb_build_object(
                    'book', book,
                    'chapter', chapter
                )
                ORDER BY book, chapter
            ),
            '[]'::jsonb
        ) INTO chapters_array
        FROM chapter_primary_keywords
        WHERE keyword_name = ANY(keywords);  -- 키워드 배열에 포함되어 있는지 확인

        -- keywords 테이블 업데이트
        UPDATE keywords
        SET
            bible_chapters = chapters_array,
            bible_count = jsonb_array_length(chapters_array),
            updated_at = NOW()
        WHERE name = keyword_name;

        RAISE NOTICE '키워드 [%] 동기화 완료: %개 장', keyword_name, jsonb_array_length(chapters_array);
    END LOOP;

    RAISE NOTICE '전체 동기화 완료';
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- 3. 자동 트리거: chapter_primary_keywords 변경 시 동기화
-- ============================================
CREATE OR REPLACE FUNCTION trigger_sync_keywords()
RETURNS TRIGGER AS $$
BEGIN
    -- 비동기 알림 (실제 동기화는 별도 실행)
    RAISE NOTICE 'chapter_primary_keywords 변경됨: %:%',
                 COALESCE(NEW.book, OLD.book),
                 COALESCE(NEW.chapter, OLD.chapter);

    -- 즉시 동기화 실행
    PERFORM sync_keywords_bible_chapters();

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 트리거 생성 (INSERT, UPDATE, DELETE 모두 감지)
DROP TRIGGER IF EXISTS trg_chapter_keywords_sync ON chapter_primary_keywords;
CREATE TRIGGER trg_chapter_keywords_sync
    AFTER INSERT OR UPDATE OR DELETE ON chapter_primary_keywords
    FOR EACH STATEMENT  -- 문장 단위로 한 번만 실행 (성능 최적화)
    EXECUTE FUNCTION trigger_sync_keywords();

-- ============================================
-- 4. 편의 함수: 특정 장의 키워드 조회
-- ============================================
CREATE OR REPLACE FUNCTION get_chapter_keywords(p_book VARCHAR, p_chapter INTEGER)
RETURNS TABLE(
    keyword TEXT,
    is_primary BOOLEAN,
    confidence INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        unnest(cpk.keywords) as keyword,
        unnest(cpk.keywords) = cpk.primary_keyword as is_primary,
        cpk.confidence_score as confidence
    FROM chapter_primary_keywords cpk
    WHERE cpk.book = p_book AND cpk.chapter = p_chapter;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- 5. 편의 함수: 키워드로 연관 장 검색
-- ============================================
CREATE OR REPLACE FUNCTION get_chapters_by_keyword(p_keyword VARCHAR)
RETURNS TABLE(
    book VARCHAR,
    chapter INTEGER,
    is_primary BOOLEAN,
    confidence INTEGER,
    all_keywords TEXT[]
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        cpk.book,
        cpk.chapter,
        cpk.primary_keyword = p_keyword as is_primary,
        cpk.confidence_score as confidence,
        cpk.keywords as all_keywords
    FROM chapter_primary_keywords cpk
    WHERE p_keyword = ANY(cpk.keywords)
    ORDER BY
        (cpk.primary_keyword = p_keyword) DESC,  -- 주요 키워드 우선
        cpk.confidence_score DESC,
        cpk.book,
        cpk.chapter;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- 6. 사용 예시 및 테스트
-- ============================================

-- 예시 1: 에베소서 2장의 키워드 확인
-- SELECT * FROM get_chapter_keywords('eph', 2);

-- 예시 2: '믿음' 키워드로 장 검색
-- SELECT * FROM get_chapters_by_keyword('믿음');

-- 예시 3: 수동으로 동기화 실행
-- SELECT sync_keywords_bible_chapters();

-- 예시 4: 특정 장의 키워드 업데이트
-- INSERT INTO chapter_primary_keywords (book, chapter, keywords, primary_keyword, confidence_score, source, reviewed_by)
-- VALUES ('eph', 2, ARRAY['구원', '은혜', '믿음'], '구원', 10, 'manual', 'Claude')
-- ON CONFLICT (book, chapter)
-- DO UPDATE SET
--     keywords = EXCLUDED.keywords,
--     primary_keyword = EXCLUDED.primary_keyword,
--     confidence_score = EXCLUDED.confidence_score,
--     updated_at = NOW();
-- (자동으로 keywords.bible_chapters 동기화됨)

-- ============================================
-- 7. 통계 및 검증 쿼리
-- ============================================

-- 키워드별 매칭된 장 개수
-- SELECT primary_keyword, COUNT(*) as chapter_count
-- FROM chapter_primary_keywords
-- GROUP BY primary_keyword
-- ORDER BY chapter_count DESC;

-- 신뢰도별 분포
-- SELECT confidence_score, COUNT(*) as count
-- FROM chapter_primary_keywords
-- GROUP BY confidence_score
-- ORDER BY confidence_score DESC;

-- 키워드 배열 길이별 분포
-- SELECT array_length(keywords, 1) as keyword_count, COUNT(*) as chapter_count
-- FROM chapter_primary_keywords
-- GROUP BY array_length(keywords, 1)
-- ORDER BY keyword_count;

-- ============================================
-- 8. 권한 설정
-- ============================================
GRANT SELECT ON chapter_primary_keywords TO PUBLIC;
GRANT SELECT, INSERT, UPDATE, DELETE ON chapter_primary_keywords TO bibleai;

COMMENT ON TABLE chapter_primary_keywords IS '성경 장별 연관 키워드 매핑 (마스터 테이블)';
COMMENT ON COLUMN chapter_primary_keywords.keywords IS '관련 키워드 배열 (최대 5개)';
COMMENT ON COLUMN chapter_primary_keywords.primary_keyword IS '가장 주요한 키워드 1개';
COMMENT ON COLUMN chapter_primary_keywords.confidence_score IS '매칭 신뢰도 (1-10)';
COMMENT ON COLUMN chapter_primary_keywords.source IS '데이터 출처: auto_analysis(자동) or manual(수동)';
COMMENT ON COLUMN chapter_primary_keywords.reviewed_by IS '검토자: Claude, 목회자명 등';

COMMENT ON FUNCTION sync_keywords_bible_chapters() IS 'chapter_primary_keywords → keywords.bible_chapters 자동 동기화';
COMMENT ON FUNCTION get_chapter_keywords(VARCHAR, INTEGER) IS '특정 장의 키워드 조회';
COMMENT ON FUNCTION get_chapters_by_keyword(VARCHAR) IS '키워드로 연관 장 검색';
