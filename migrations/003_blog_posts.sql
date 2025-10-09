-- 블로그 포스트 테이블
CREATE TABLE IF NOT EXISTS blog_posts (
    id SERIAL PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    slug VARCHAR(200) UNIQUE NOT NULL,        -- URL용 (예: 2025-10-07-love)
    content TEXT NOT NULL,                     -- 마크다운 콘텐츠
    excerpt VARCHAR(300),                      -- 요약 (목록용)
    keywords VARCHAR(200),                     -- SEO 키워드 (쉼표 구분)
    published_at TIMESTAMP DEFAULT NOW(),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    view_count INT DEFAULT 0,
    is_published BOOLEAN DEFAULT true
);

-- 인덱스
CREATE INDEX idx_blog_posts_published ON blog_posts(published_at DESC) WHERE is_published = true;
CREATE INDEX idx_blog_posts_slug ON blog_posts(slug);

-- 샘플 데이터는 API로 삽입
-- POST /api/admin/blog/posts 사용
