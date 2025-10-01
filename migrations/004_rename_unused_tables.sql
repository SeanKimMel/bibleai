-- 004_rename_unused_tables.sql
-- 사용되지 않는 테이블들을 _bak 접미사로 이름 변경
-- 목적: 삭제 대신 백업으로 보관하여 나중에 필요시 복구 가능

-- 1. data_import_logs -> data_import_logs_bak (있는 경우만)
DO $$
BEGIN
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'data_import_logs') THEN
        ALTER TABLE data_import_logs RENAME TO data_import_logs_bak;
        RAISE NOTICE 'data_import_logs -> data_import_logs_bak 완료';
    ELSE
        RAISE NOTICE 'data_import_logs 테이블이 존재하지 않음';
    END IF;
END
$$;

-- 2. user_favorites -> user_favorites_bak (있는 경우만)
DO $$
BEGIN
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'user_favorites') THEN
        ALTER TABLE user_favorites RENAME TO user_favorites_bak;
        RAISE NOTICE 'user_favorites -> user_favorites_bak 완료';
    ELSE
        RAISE NOTICE 'user_favorites 테이블이 존재하지 않음';
    END IF;
END
$$;

-- 3. search_stats -> search_stats_bak (있는 경우만)
DO $$
BEGIN
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'search_stats') THEN
        ALTER TABLE search_stats RENAME TO search_stats_bak;
        RAISE NOTICE 'search_stats -> search_stats_bak 완료';
    ELSE
        RAISE NOTICE 'search_stats 테이블이 존재하지 않음';
    END IF;
END
$$;

-- 4. prayer_keywords -> prayer_keywords_bak (있는 경우만)
DO $$
BEGIN
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'prayer_keywords') THEN
        ALTER TABLE prayer_keywords RENAME TO prayer_keywords_bak;
        RAISE NOTICE 'prayer_keywords -> prayer_keywords_bak 완료';
    ELSE
        RAISE NOTICE 'prayer_keywords 테이블이 존재하지 않음';
    END IF;
END
$$;

-- 5. bible_keywords -> bible_keywords_bak (있는 경우만)
DO $$
BEGIN
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'bible_keywords') THEN
        ALTER TABLE bible_keywords RENAME TO bible_keywords_bak;
        RAISE NOTICE 'bible_keywords -> bible_keywords_bak 완료';
    ELSE
        RAISE NOTICE 'bible_keywords 테이블이 존재하지 않음';
    END IF;
END
$$;

-- 6. hymn_keywords -> hymn_keywords_bak (있는 경우만)
DO $$
BEGIN
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'hymn_keywords') THEN
        ALTER TABLE hymn_keywords RENAME TO hymn_keywords_bak;
        RAISE NOTICE 'hymn_keywords -> hymn_keywords_bak 완료';
    ELSE
        RAISE NOTICE 'hymn_keywords 테이블이 존재하지 않음';
    END IF;
END
$$;

-- 작업 완료 메시지
SELECT '✅ 사용되지 않는 테이블 이름 변경 작업이 완료되었습니다.' as result;