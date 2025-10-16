-- 안 쓰이는 테이블 정리 (rename으로 백업)
-- 실행일: 2025-10-13
-- 목적: 사용하지 않는 테이블을 _archived 접미사로 rename하여 백업

-- 1. prayer_tags 테이블 (레코드 0개, 실제 사용 없음)
ALTER TABLE IF EXISTS prayer_tags RENAME TO prayer_tags_archived_20251013;

-- 2. tags 테이블 (keywords로 통합 예정)
-- 현재 10개 레코드 있지만 실제 prayer_tags가 비어있어 사용 안됨
ALTER TABLE IF EXISTS tags RENAME TO tags_archived_20251013;

-- 3. 기존 백업 테이블들도 정리
ALTER TABLE IF EXISTS data_import_logs_bak RENAME TO data_import_logs_archived_20251013;
ALTER TABLE IF EXISTS search_stats_bak RENAME TO search_stats_archived_20251013;
ALTER TABLE IF EXISTS user_favorites_bak RENAME TO user_favorites_archived_20251013;

-- rename 확인
SELECT
    schemaname,
    tablename,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) as size
FROM pg_tables
WHERE tablename LIKE '%archived%'
ORDER BY tablename;

-- 추후 완전히 삭제하려면:
-- DROP TABLE IF EXISTS prayer_tags_archived_20251013;
-- DROP TABLE IF EXISTS tags_archived_20251013;
-- DROP TABLE IF EXISTS data_import_logs_archived_20251013;
-- DROP TABLE IF EXISTS search_stats_archived_20251013;
-- DROP TABLE IF EXISTS user_favorites_archived_20251013;