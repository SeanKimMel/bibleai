-- 한국 시간대(Asia/Seoul) 지원 추가
-- 기존 데이터 유지하면서 timezone aware로 변경

-- 1. DB timezone을 한국 시간으로 설정
SET timezone = 'Asia/Seoul';

-- 2. blog_posts 테이블의 timestamp 컬럼들을 TIMESTAMPTZ로 변경
-- 기존 데이터는 현재 timezone(Asia/Seoul)을 기준으로 변환됨
ALTER TABLE blog_posts
    ALTER COLUMN published_at TYPE TIMESTAMPTZ USING published_at AT TIME ZONE 'Asia/Seoul',
    ALTER COLUMN created_at TYPE TIMESTAMPTZ USING created_at AT TIME ZONE 'Asia/Seoul',
    ALTER COLUMN updated_at TYPE TIMESTAMPTZ USING updated_at AT TIME ZONE 'Asia/Seoul';

-- 3. evaluation_date도 있다면 변경
ALTER TABLE blog_posts
    ALTER COLUMN evaluation_date TYPE TIMESTAMPTZ USING evaluation_date AT TIME ZONE 'Asia/Seoul';

-- 4. 기본값 업데이트 (NOW()는 자동으로 현재 timezone 사용)
ALTER TABLE blog_posts
    ALTER COLUMN published_at SET DEFAULT NOW(),
    ALTER COLUMN created_at SET DEFAULT NOW(),
    ALTER COLUMN updated_at SET DEFAULT NOW();

-- 5. blog_quality_history 테이블도 있다면 변경
ALTER TABLE blog_quality_history
    ALTER COLUMN evaluated_at TYPE TIMESTAMPTZ USING evaluated_at AT TIME ZONE 'Asia/Seoul';

-- 참고: 이제 모든 timestamp는 timezone 정보를 포함하며
-- 어디서 접속하든 Asia/Seoul 기준으로 저장되고 표시됩니다
