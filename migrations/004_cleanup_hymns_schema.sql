-- Migration: 찬송가 테이블 구조 정리
-- 목적: 구찬송가 번호 제거, 신찬송가 번호를 기본 번호로 변경, 미사용 컬럼 삭제
-- 작성일: 2025-10-08

-- 1단계: 현재 데이터 백업 (확인용)
-- COPY hymns TO '/tmp/hymns_backup_20251008.csv' WITH CSV HEADER;

BEGIN;

-- 2단계: new_hymn_number를 number로 교체 준비
-- 임시 컬럼 생성하여 신찬송가 번호 저장
ALTER TABLE hymns ADD COLUMN number_new INTEGER;
UPDATE hymns SET number_new = new_hymn_number;

-- 3단계: 기존 number 관련 제약조건 및 인덱스 삭제
DROP INDEX IF EXISTS idx_hymns_number;
ALTER TABLE hymns DROP CONSTRAINT IF EXISTS hymns_number_key;

-- 4단계: 기존 number 컬럼 삭제
ALTER TABLE hymns DROP COLUMN number;

-- 5단계: number_new를 number로 변경
ALTER TABLE hymns RENAME COLUMN number_new TO number;

-- 6단계: new_hymn_number 컬럼 삭제
DROP INDEX IF EXISTS idx_hymns_new_number;
ALTER TABLE hymns DROP COLUMN new_hymn_number;

-- 7단계: number에 NOT NULL 및 UNIQUE 제약조건 추가
ALTER TABLE hymns ALTER COLUMN number SET NOT NULL;
ALTER TABLE hymns ADD CONSTRAINT hymns_number_key UNIQUE (number);
CREATE INDEX idx_hymns_number ON hymns(number);

-- 8단계: 미사용 컬럼 삭제
ALTER TABLE hymns DROP COLUMN IF EXISTS year;
ALTER TABLE hymns DROP COLUMN IF EXISTS tune_name;
ALTER TABLE hymns DROP COLUMN IF EXISTS category;
ALTER TABLE hymns DROP COLUMN IF EXISTS tags;

-- 9단계: 결과 확인
SELECT COUNT(*) as total_hymns,
       MIN(number) as min_number,
       MAX(number) as max_number
FROM hymns;

COMMIT;

-- 최종 테이블 구조 확인
\d hymns;
