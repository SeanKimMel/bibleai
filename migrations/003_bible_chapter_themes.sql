-- 성경 챕터별 주제/키워드 테이블
-- 각 성경 장별로 주요 주제와 키워드를 저장하여 장 단위 검색을 지원

CREATE TABLE IF NOT EXISTS bible_chapter_themes (
    id SERIAL PRIMARY KEY,
    book VARCHAR(10) NOT NULL,           -- 성경책 약어 (예: "gn", "mt", "1co")
    book_name VARCHAR(50) NOT NULL,      -- 성경책 이름 (예: "창세기", "마태복음")
    chapter INTEGER NOT NULL,            -- 장 번호
    theme VARCHAR(100) NOT NULL,         -- 주제/키워드 (예: "사랑", "믿음", "구원")
    relevance_score INTEGER DEFAULT 1,   -- 연관도 점수 (1-10, 높을수록 중요)
    keyword_count INTEGER DEFAULT 0,     -- 해당 키워드가 그 장에서 등장하는 횟수
    summary TEXT,                        -- 해당 장의 주제 요약 (선택사항)
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 성능 향상을 위한 인덱스
CREATE INDEX IF NOT EXISTS idx_chapter_themes_theme ON bible_chapter_themes(theme);
CREATE INDEX IF NOT EXISTS idx_chapter_themes_book_chapter ON bible_chapter_themes(book, chapter);
CREATE INDEX IF NOT EXISTS idx_chapter_themes_relevance ON bible_chapter_themes(relevance_score DESC);
CREATE INDEX IF NOT EXISTS idx_chapter_themes_compound ON bible_chapter_themes(theme, relevance_score DESC);

-- 중복 방지를 위한 유니크 제약조건
ALTER TABLE bible_chapter_themes
ADD CONSTRAINT unique_book_chapter_theme
UNIQUE (book, chapter, theme);

-- 업데이트 시간 자동 갱신을 위한 트리거 함수
CREATE OR REPLACE FUNCTION update_chapter_themes_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 트리거 생성
DROP TRIGGER IF EXISTS trigger_update_chapter_themes_updated_at ON bible_chapter_themes;
CREATE TRIGGER trigger_update_chapter_themes_updated_at
    BEFORE UPDATE ON bible_chapter_themes
    FOR EACH ROW
    EXECUTE FUNCTION update_chapter_themes_updated_at();

-- 테이블 코멘트
COMMENT ON TABLE bible_chapter_themes IS '성경 챕터별 주제 및 키워드 매핑 테이블';
COMMENT ON COLUMN bible_chapter_themes.relevance_score IS '1-10 점수, 해당 주제가 그 챕터에서 얼마나 중요한지 표시';
COMMENT ON COLUMN bible_chapter_themes.keyword_count IS '해당 키워드가 그 챕터에서 등장하는 실제 횟수';