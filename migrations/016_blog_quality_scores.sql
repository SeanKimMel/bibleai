-- 블로그 품질 평가 시스템
-- 작성일: 2025-10-16
-- 설명: 블로그 포스트별 품질 점수 컬럼 추가 및 기본값 설정

-- 1. blog_posts 테이블에 품질 평가 컬럼 추가
ALTER TABLE blog_posts
ADD COLUMN IF NOT EXISTS theological_accuracy DECIMAL(3,1) DEFAULT NULL,
ADD COLUMN IF NOT EXISTS content_structure DECIMAL(3,1) DEFAULT NULL,
ADD COLUMN IF NOT EXISTS engagement DECIMAL(3,1) DEFAULT NULL,
ADD COLUMN IF NOT EXISTS technical_quality DECIMAL(3,1) DEFAULT NULL,
ADD COLUMN IF NOT EXISTS seo_optimization DECIMAL(3,1) DEFAULT NULL,
ADD COLUMN IF NOT EXISTS total_score DECIMAL(3,1) DEFAULT NULL,
ADD COLUMN IF NOT EXISTS quality_feedback JSONB DEFAULT NULL,
ADD COLUMN IF NOT EXISTS evaluation_date TIMESTAMP DEFAULT NULL,
ADD COLUMN IF NOT EXISTS evaluator VARCHAR(50) DEFAULT 'gemini-api';

-- 컬럼 코멘트 추가
COMMENT ON COLUMN blog_posts.theological_accuracy IS '신학적 정확성 (0-10점)';
COMMENT ON COLUMN blog_posts.content_structure IS '콘텐츠 구조 (0-10점)';
COMMENT ON COLUMN blog_posts.engagement IS '독자 참여도 (0-10점)';
COMMENT ON COLUMN blog_posts.technical_quality IS '기술적 품질 (0-10점)';
COMMENT ON COLUMN blog_posts.seo_optimization IS 'SEO 최적화 (0-10점)';
COMMENT ON COLUMN blog_posts.total_score IS '총점 (0-10점, 가중치 적용)';
COMMENT ON COLUMN blog_posts.quality_feedback IS '품질 평가 피드백 (장점, 개선사항, 치명적 문제)';
COMMENT ON COLUMN blog_posts.evaluation_date IS '평가 실행 일시';
COMMENT ON COLUMN blog_posts.evaluator IS '평가자 (gemini-api, manual 등)';

-- 2. is_published 기본값을 false로 변경 (새 글은 평가 후 발행)
ALTER TABLE blog_posts
ALTER COLUMN is_published SET DEFAULT false;

-- 3. 품질 점수 조회를 위한 인덱스 추가
CREATE INDEX IF NOT EXISTS idx_blog_posts_total_score
ON blog_posts(total_score DESC)
WHERE total_score IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_blog_posts_is_published_score
ON blog_posts(is_published, total_score DESC);

-- 4. 품질 평가 이력 테이블 생성 (선택사항 - 평가 히스토리 추적용)
CREATE TABLE IF NOT EXISTS blog_quality_history (
    id SERIAL PRIMARY KEY,
    blog_post_id INTEGER NOT NULL REFERENCES blog_posts(id) ON DELETE CASCADE,
    theological_accuracy DECIMAL(3,1),
    content_structure DECIMAL(3,1),
    engagement DECIMAL(3,1),
    technical_quality DECIMAL(3,1),
    seo_optimization DECIMAL(3,1),
    total_score DECIMAL(3,1),
    quality_feedback JSONB,
    evaluator VARCHAR(50) DEFAULT 'gemini-api',
    evaluated_at TIMESTAMP DEFAULT NOW(),
    CONSTRAINT check_scores_range CHECK (
        theological_accuracy BETWEEN 0 AND 10 AND
        content_structure BETWEEN 0 AND 10 AND
        engagement BETWEEN 0 AND 10 AND
        technical_quality BETWEEN 0 AND 10 AND
        seo_optimization BETWEEN 0 AND 10 AND
        total_score BETWEEN 0 AND 10
    )
);

CREATE INDEX IF NOT EXISTS idx_blog_quality_history_post_id
ON blog_quality_history(blog_post_id, evaluated_at DESC);

-- 5. 점수 범위 체크 제약조건 추가
ALTER TABLE blog_posts
ADD CONSTRAINT check_blog_quality_scores CHECK (
    (theological_accuracy IS NULL OR theological_accuracy BETWEEN 0 AND 10) AND
    (content_structure IS NULL OR content_structure BETWEEN 0 AND 10) AND
    (engagement IS NULL OR engagement BETWEEN 0 AND 10) AND
    (technical_quality IS NULL OR technical_quality BETWEEN 0 AND 10) AND
    (seo_optimization IS NULL OR seo_optimization BETWEEN 0 AND 10) AND
    (total_score IS NULL OR total_score BETWEEN 0 AND 10)
);

-- 6. 자동 발행 함수 (총점 7.0 이상이고 신학적 정확성 6.0 이상이면 자동 발행)
CREATE OR REPLACE FUNCTION auto_publish_blog_post()
RETURNS TRIGGER AS $$
BEGIN
    -- 품질 점수가 업데이트되었고, 아직 발행되지 않은 경우
    IF NEW.total_score IS NOT NULL AND
       NEW.theological_accuracy IS NOT NULL AND
       NEW.technical_quality IS NOT NULL AND
       NEW.is_published = false THEN

        -- 자동 발행 기준 체크
        IF NEW.total_score >= 7.0 AND
           NEW.theological_accuracy >= 6.0 AND
           NEW.technical_quality >= 7.0 THEN
            NEW.is_published := true;
            NEW.published_at := NOW();
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 7. 자동 발행 트리거 생성
DROP TRIGGER IF EXISTS trigger_auto_publish_blog ON blog_posts;
CREATE TRIGGER trigger_auto_publish_blog
    BEFORE UPDATE ON blog_posts
    FOR EACH ROW
    EXECUTE FUNCTION auto_publish_blog_post();

-- 8. 품질 평가 이력 자동 저장 트리거
CREATE OR REPLACE FUNCTION save_quality_history()
RETURNS TRIGGER AS $$
BEGIN
    -- 품질 점수가 업데이트된 경우에만 히스토리 저장
    IF NEW.total_score IS NOT NULL AND
       (OLD.total_score IS NULL OR NEW.total_score != OLD.total_score) THEN

        INSERT INTO blog_quality_history (
            blog_post_id,
            theological_accuracy,
            content_structure,
            engagement,
            technical_quality,
            seo_optimization,
            total_score,
            quality_feedback,
            evaluator,
            evaluated_at
        ) VALUES (
            NEW.id,
            NEW.theological_accuracy,
            NEW.content_structure,
            NEW.engagement,
            NEW.technical_quality,
            NEW.seo_optimization,
            NEW.total_score,
            NEW.quality_feedback,
            NEW.evaluator,
            NOW()
        );
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_save_quality_history ON blog_posts;
CREATE TRIGGER trigger_save_quality_history
    AFTER UPDATE ON blog_posts
    FOR EACH ROW
    EXECUTE FUNCTION save_quality_history();

COMMENT ON TABLE blog_quality_history IS '블로그 품질 평가 이력 테이블 - 평가 변경 추적용';
