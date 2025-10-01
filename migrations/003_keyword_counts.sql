-- 키워드별 콘텐츠 카운트 업데이트 함수
CREATE OR REPLACE FUNCTION update_keyword_counts() RETURNS void AS $$
DECLARE
    keyword_rec RECORD;
BEGIN
    -- 모든 키워드에 대해 카운트 업데이트
    FOR keyword_rec IN SELECT id, name FROM keywords LOOP
        -- 성경 구절 카운트
        UPDATE keywords
        SET bible_count = (
            SELECT COUNT(*)
            FROM bible_verses
            WHERE content ILIKE '%' || keyword_rec.name || '%'
        )
        WHERE id = keyword_rec.id;

        -- 찬송가 카운트
        UPDATE keywords
        SET hymn_count = (
            SELECT COUNT(*)
            FROM hymns
            WHERE lyrics ILIKE '%' || keyword_rec.name || '%'
               OR title ILIKE '%' || keyword_rec.name || '%'
        )
        WHERE id = keyword_rec.id;

        -- 기도문 카운트 (나중에 구현될 때를 위해)
        UPDATE keywords
        SET prayer_count = (
            SELECT COALESCE(COUNT(*), 0)
            FROM prayers
            WHERE content ILIKE '%' || keyword_rec.name || '%'
               OR title ILIKE '%' || keyword_rec.name || '%'
        )
        WHERE id = keyword_rec.id;

    END LOOP;

    -- 업데이트 시간 갱신
    UPDATE keywords SET updated_at = CURRENT_TIMESTAMP;

    RAISE NOTICE 'Keyword counts updated successfully';
END;
$$ LANGUAGE plpgsql;

-- 함수 실행
SELECT update_keyword_counts();