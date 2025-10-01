-- 키워드 테이블 생성
CREATE TABLE IF NOT EXISTS keywords (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    category VARCHAR(20) DEFAULT 'general', -- 'prayer', 'bible', 'hymn', 'general'
    usage_count INTEGER DEFAULT 0, -- 해당 키워드가 사용된 총 횟수
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 키워드 매핑 테이블들 (각 콘텐츠 타입별)
CREATE TABLE IF NOT EXISTS prayer_keywords (
    prayer_id INTEGER REFERENCES prayers(id) ON DELETE CASCADE,
    keyword_id INTEGER REFERENCES keywords(id) ON DELETE CASCADE,
    PRIMARY KEY (prayer_id, keyword_id)
);

CREATE TABLE IF NOT EXISTS bible_keywords (
    verse_id INTEGER REFERENCES bible_verses(id) ON DELETE CASCADE,
    keyword_id INTEGER REFERENCES keywords(id) ON DELETE CASCADE,
    PRIMARY KEY (verse_id, keyword_id)
);

CREATE TABLE IF NOT EXISTS hymn_keywords (
    hymn_id INTEGER REFERENCES hymns(id) ON DELETE CASCADE,
    keyword_id INTEGER REFERENCES keywords(id) ON DELETE CASCADE,
    PRIMARY KEY (hymn_id, keyword_id)
);

-- 인덱스 생성
CREATE INDEX idx_keywords_name ON keywords(name);
CREATE INDEX idx_keywords_usage_count ON keywords(usage_count DESC);
CREATE INDEX idx_prayer_keywords_keyword ON prayer_keywords(keyword_id);
CREATE INDEX idx_bible_keywords_keyword ON bible_keywords(keyword_id);
CREATE INDEX idx_hymn_keywords_keyword ON hymn_keywords(keyword_id);

-- 키워드 사용량 업데이트 함수
CREATE OR REPLACE FUNCTION update_keyword_usage_count()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE keywords
        SET usage_count = usage_count + 1,
            updated_at = CURRENT_TIMESTAMP
        WHERE id = NEW.keyword_id;
        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE keywords
        SET usage_count = GREATEST(usage_count - 1, 0),
            updated_at = CURRENT_TIMESTAMP
        WHERE id = OLD.keyword_id;
        RETURN OLD;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- 트리거 생성
CREATE TRIGGER trigger_prayer_keywords_usage
    AFTER INSERT OR DELETE ON prayer_keywords
    FOR EACH ROW EXECUTE FUNCTION update_keyword_usage_count();

CREATE TRIGGER trigger_bible_keywords_usage
    AFTER INSERT OR DELETE ON bible_keywords
    FOR EACH ROW EXECUTE FUNCTION update_keyword_usage_count();

CREATE TRIGGER trigger_hymn_keywords_usage
    AFTER INSERT OR DELETE ON hymn_keywords
    FOR EACH ROW EXECUTE FUNCTION update_keyword_usage_count();