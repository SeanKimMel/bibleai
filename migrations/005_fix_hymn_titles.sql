-- Migration: 찬송가 제목 수정
-- 목적: 실제 신찬송가 제목으로 잘못된 데이터 수정
-- 작성일: 2025-10-08
-- 수정 대상: 20개 찬송가 제목

BEGIN;

-- 수정 전 현황 확인
SELECT '=== 수정 전 데이터 ===' as status;
SELECT number, title FROM hymns WHERE number IN (30, 32, 40, 50, 65, 75, 109, 120, 140, 150, 165, 200, 220, 280, 320, 420, 480, 500) ORDER BY number;

-- 제목 수정
UPDATE hymns SET title = '전능하고 놀라우신', updated_at = NOW() WHERE number = 30;
UPDATE hymns SET title = '만유의 주재', updated_at = NOW() WHERE number = 32;
UPDATE hymns SET title = '찬송으로 보답할 수 없는', updated_at = NOW() WHERE number = 40;
UPDATE hymns SET title = '내게 있는 모든 것을', updated_at = NOW() WHERE number = 50;
UPDATE hymns SET title = '내 영혼아 찬양하라', updated_at = NOW() WHERE number = 65;
UPDATE hymns SET title = '주여 우리 무리를', updated_at = NOW() WHERE number = 75;
UPDATE hymns SET title = '고요하고 거룩한 밤', updated_at = NOW() WHERE number = 109;
UPDATE hymns SET title = '오 베들레헴 작은 골', updated_at = NOW() WHERE number = 120;
UPDATE hymns SET title = '왕 되신 우리 주께', updated_at = NOW() WHERE number = 140;
UPDATE hymns SET title = '갈보리산 위에', updated_at = NOW() WHERE number = 150;
UPDATE hymns SET title = '주님께 영광', updated_at = NOW() WHERE number = 165;
UPDATE hymns SET title = '달고 오묘한 그 말씀', updated_at = NOW() WHERE number = 200;
UPDATE hymns SET title = '사랑하는 주님 앞에', updated_at = NOW() WHERE number = 220;
UPDATE hymns SET title = '천부여 의지 없어서', updated_at = NOW() WHERE number = 280;
UPDATE hymns SET title = '나의 죄를 정케 하사', updated_at = NOW() WHERE number = 320;
UPDATE hymns SET title = '너 성결키 위해', updated_at = NOW() WHERE number = 420;
UPDATE hymns SET title = '천국에서 만나보자', updated_at = NOW() WHERE number = 480;
UPDATE hymns SET title = '물위에 생명줄 던지어라', updated_at = NOW() WHERE number = 500;

-- 수정 후 확인
SELECT '=== 수정 후 데이터 ===' as status;
SELECT number, title FROM hymns WHERE number IN (30, 32, 40, 50, 65, 75, 109, 120, 140, 150, 165, 200, 220, 280, 320, 420, 480, 500) ORDER BY number;

-- 수정된 개수 확인
SELECT '=== 총 수정 개수 ===' as status, COUNT(*) as updated_count
FROM hymns
WHERE number IN (30, 32, 40, 50, 65, 75, 109, 120, 140, 150, 165, 200, 220, 280, 320, 420, 480, 500);

COMMIT;
