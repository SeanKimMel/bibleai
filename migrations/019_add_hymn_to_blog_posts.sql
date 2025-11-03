-- 블로그 포스트에 찬송가 참조 추가
-- 블로그 작성 시 선택된 찬송가를 기록

DO $$
BEGIN
    -- hymn_number 컬럼 추가 (찬송가 번호 참조)
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='blog_posts' AND column_name='hymn_number') THEN
        ALTER TABLE blog_posts ADD COLUMN hymn_number INTEGER;

        -- 외래키 제약조건 추가 (찬송가 number 참조)
        ALTER TABLE blog_posts
        ADD CONSTRAINT fk_blog_posts_hymn
        FOREIGN KEY (hymn_number)
        REFERENCES hymns(number)
        ON DELETE SET NULL;  -- 찬송가가 삭제되면 NULL로 설정

        -- 인덱스 추가 (조회 성능 향상)
        CREATE INDEX idx_blog_posts_hymn_number ON blog_posts(hymn_number);
    END IF;
END $$;

-- 참고: hymn_number는 1-645 사이의 찬송가 번호
-- 예: hymn_number=1 -> "만복의 근원 하나님"
