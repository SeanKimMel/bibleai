-- 블로그 포스트 제목 최적화를 위한 A/B 테스트 필드 추가

-- blog_posts 테이블에 제목 변형 및 성능 메트릭 필드 추가
ALTER TABLE blog_posts
ADD COLUMN IF NOT EXISTS title_variant VARCHAR(10) DEFAULT 'A',
ADD COLUMN IF NOT EXISTS title_category VARCHAR(50),
ADD COLUMN IF NOT EXISTS click_through_rate DECIMAL(5,2),
ADD COLUMN IF NOT EXISTS avg_read_time INTEGER, -- 초 단위
ADD COLUMN IF NOT EXISTS bounce_rate DECIMAL(5,2);

-- 제목 A/B 테스트 기록 테이블
CREATE TABLE IF NOT EXISTS blog_title_tests (
    id SERIAL PRIMARY KEY,
    blog_post_id INTEGER REFERENCES blog_posts(id) ON DELETE CASCADE,
    title_a VARCHAR(200) NOT NULL,
    title_b VARCHAR(200),
    title_c VARCHAR(200),
    views_a INTEGER DEFAULT 0,
    views_b INTEGER DEFAULT 0,
    views_c INTEGER DEFAULT 0,
    clicks_a INTEGER DEFAULT 0,
    clicks_b INTEGER DEFAULT 0,
    clicks_c INTEGER DEFAULT 0,
    winner VARCHAR(10),
    test_started_at TIMESTAMP DEFAULT NOW(),
    test_ended_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT NOW()
);

-- 블로그 조회 상세 기록 테이블 (리텐션 분석용)
CREATE TABLE IF NOT EXISTS blog_view_details (
    id SERIAL PRIMARY KEY,
    blog_post_id INTEGER REFERENCES blog_posts(id) ON DELETE CASCADE,
    session_id VARCHAR(100),
    ip_address VARCHAR(45),
    user_agent TEXT,
    referrer TEXT,
    time_on_page INTEGER, -- 초 단위
    scroll_depth DECIMAL(5,2), -- 페이지 스크롤 퍼센트
    title_variant VARCHAR(10),
    viewed_at TIMESTAMP DEFAULT NOW()
);

-- 인덱스 생성 (별도로)
CREATE INDEX IF NOT EXISTS idx_blog_views_post_id ON blog_view_details(blog_post_id);
CREATE INDEX IF NOT EXISTS idx_blog_views_session ON blog_view_details(session_id);
CREATE INDEX IF NOT EXISTS idx_blog_views_date ON blog_view_details(viewed_at);

-- 인기 키워드 테이블 (제목 생성 최적화용)
CREATE TABLE IF NOT EXISTS popular_keywords (
    id SERIAL PRIMARY KEY,
    keyword VARCHAR(100) UNIQUE NOT NULL,
    search_count INTEGER DEFAULT 0,
    click_count INTEGER DEFAULT 0,
    avg_time_on_page INTEGER DEFAULT 0,
    performance_score DECIMAL(5,2),
    last_used TIMESTAMP,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- 자동으로 인기 키워드 성능 점수 업데이트하는 함수
CREATE OR REPLACE FUNCTION update_keyword_performance()
RETURNS TRIGGER AS $$
BEGIN
    -- 성능 점수 계산: (클릭수 * 0.3) + (평균체류시간 * 0.5) + (검색수 * 0.2)
    NEW.performance_score :=
        (NEW.click_count * 0.3) +
        (NEW.avg_time_on_page * 0.5 / 60) + -- 분 단위로 변환
        (NEW.search_count * 0.2);
    NEW.updated_at := NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 트리거 생성
DROP TRIGGER IF EXISTS update_keyword_performance_trigger ON popular_keywords;
CREATE TRIGGER update_keyword_performance_trigger
    BEFORE UPDATE ON popular_keywords
    FOR EACH ROW
    EXECUTE FUNCTION update_keyword_performance();

-- 초기 인기 키워드 데이터 삽입
INSERT INTO popular_keywords (keyword, search_count, click_count, avg_time_on_page) VALUES
    ('사랑', 150, 120, 180),
    ('평안', 130, 100, 200),
    ('기도', 200, 180, 240),
    ('감사', 170, 140, 210),
    ('소망', 110, 90, 190),
    ('믿음', 140, 110, 220),
    ('은혜', 160, 130, 230),
    ('위로', 120, 95, 250),
    ('용서', 100, 80, 200),
    ('축복', 145, 115, 195)
ON CONFLICT (keyword) DO NOTHING;

COMMENT ON COLUMN blog_posts.title_variant IS 'A/B 테스트 변형 (A, B, C)';
COMMENT ON COLUMN blog_posts.title_category IS '제목 카테고리 (emotional, question, numbered 등)';
COMMENT ON COLUMN blog_posts.click_through_rate IS '클릭률 (%)';
COMMENT ON COLUMN blog_posts.avg_read_time IS '평균 읽기 시간 (초)';
COMMENT ON COLUMN blog_posts.bounce_rate IS '이탈률 (%)';
COMMENT ON TABLE blog_title_tests IS '블로그 제목 A/B 테스트 기록';
COMMENT ON TABLE blog_view_details IS '블로그 조회 상세 기록 (리텐션 분석용)';
COMMENT ON TABLE popular_keywords IS '인기 키워드 및 성능 메트릭';