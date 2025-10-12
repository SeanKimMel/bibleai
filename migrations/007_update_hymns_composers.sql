-- Migration: 찬송가 작곡가/작사가 정보 업데이트
-- 작성일: 2025-10-08
-- 목적: 29개 찬송가의 정확한 작곡가/작사가 정보로 업데이트

BEGIN;

-- 업데이트 전 현황
SELECT '=== 업데이트 전 ===' as status;
SELECT number, title, composer, author FROM hymns WHERE number IN (1,2,3,4,5,6,7,8,30,32,40,50,65,75,109,120,140,150,165,199,200,220,280,305,310,320,420,480,500) ORDER BY number;

-- 작곡가/작사가 정보 업데이트
UPDATE hymns SET 
    composer = 'Louis Bourgeois',
    author = 'Thomas Ken',
    updated_at = NOW()
WHERE number = 1;

UPDATE hymns SET 
    composer = 'Thomas Hastings',
    author = 'Tate and Brady',
    updated_at = NOW()
WHERE number = 2;

UPDATE hymns SET 
    composer = 'Charles Meineke',
    author = 'Gloria Patri (2nd Century)',
    updated_at = NOW()
WHERE number = 3;

UPDATE hymns SET 
    composer = 'Henry W. Greatorex',
    author = 'Gloria Patri (2nd Century)',
    updated_at = NOW()
WHERE number = 4;

UPDATE hymns SET 
    composer = 'Louis Bourgeois (arr. Edwin O. Excell)',
    author = 'William Kethe',
    updated_at = NOW()
WHERE number = 5;

UPDATE hymns SET 
    composer = 'The Parish Choir',
    author = 'Isaac Watts and Philip Doddridge',
    updated_at = NOW()
WHERE number = 6;

UPDATE hymns SET 
    composer = 'J. F. Erickson',
    author = 'Gloria Patri (2nd Century)',
    updated_at = NOW()
WHERE number = 7;

UPDATE hymns SET 
    composer = 'John B. Dykes',
    author = 'Reginald Heber',
    updated_at = NOW()
WHERE number = 8;

UPDATE hymns SET 
    composer = 'Baylus Benjamin McKinney',
    author = 'Baylus Benjamin McKinney',
    updated_at = NOW()
WHERE number = 30;

UPDATE hymns SET 
    composer = 'Richard Storrs Willis (arr.)',
    author = 'Traditional (Silesian Folk Song)',
    updated_at = NOW()
WHERE number = 32;

UPDATE hymns SET 
    composer = 'William J. Kirkpatrick',
    author = 'Fanny Crosby',
    updated_at = NOW()
WHERE number = 40;

UPDATE hymns SET 
    composer = 'Winfield S. Weeden',
    author = 'Judson W. Van DeVenter',
    updated_at = NOW()
WHERE number = 50;

UPDATE hymns SET 
    composer = 'John Goss',
    author = 'Henry Francis Lyte',
    updated_at = NOW()
WHERE number = 65;

UPDATE hymns SET 
    composer = 'William B. Bradbury',
    author = 'Alexander Albert Pieters',
    updated_at = NOW()
WHERE number = 75;

UPDATE hymns SET 
    composer = 'Franz Xaver Gruber',
    author = 'Joseph Mohr',
    updated_at = NOW()
WHERE number = 109;

UPDATE hymns SET 
    composer = 'Lewis H. Redner',
    author = 'Phillips Brooks',
    updated_at = NOW()
WHERE number = 120;

UPDATE hymns SET 
    composer = 'Melchior Teschner',
    author = 'Theodulph of Orleans',
    updated_at = NOW()
WHERE number = 140;

UPDATE hymns SET 
    composer = 'George Bennard',
    author = 'George Bennard',
    updated_at = NOW()
WHERE number = 150;

UPDATE hymns SET 
    composer = 'George Frideric Handel',
    author = 'Edmond L. Budry',
    updated_at = NOW()
WHERE number = 165;

UPDATE hymns SET 
    composer = 'M. B. Williams and Charles D. Tillman',
    author = 'M. B. Williams',
    updated_at = NOW()
WHERE number = 199;

UPDATE hymns SET 
    composer = 'Philip P. Bliss',
    author = 'Philip P. Bliss',
    updated_at = NOW()
WHERE number = 200;

UPDATE hymns SET 
    composer = 'Daniel B. Towner',
    author = 'Masatsuna Okuno',
    updated_at = NOW()
WHERE number = 220;

UPDATE hymns SET 
    composer = 'William Shield',
    author = 'Charles Wesley',
    updated_at = NOW()
WHERE number = 280;

UPDATE hymns SET 
    composer = 'Traditional (American Folk)',
    author = 'John Newton',
    updated_at = NOW()
WHERE number = 305;

UPDATE hymns SET 
    composer = 'James McGranahan',
    author = 'Daniel Webster Whittle',
    updated_at = NOW()
WHERE number = 310;

UPDATE hymns SET 
    composer = 'A. R. Gibbs',
    author = 'Mary E. Maxwell',
    updated_at = NOW()
WHERE number = 320;

UPDATE hymns SET 
    composer = 'George C. Stebbins',
    author = 'William D. Longstaff',
    updated_at = NOW()
WHERE number = 420;

UPDATE hymns SET 
    composer = 'I. G. Martin',
    author = 'I. G. Martin',
    updated_at = NOW()
WHERE number = 480;

UPDATE hymns SET 
    composer = 'Edwin Smith Ufford',
    author = 'Edwin Smith Ufford',
    updated_at = NOW()
WHERE number = 500;

-- 업데이트 후 확인
SELECT '=== 업데이트 후 ===' as status;
SELECT number, title, composer, author FROM hymns WHERE number IN (1,2,3,4,5,6,7,8,30,32,40,50,65,75,109,120,140,150,165,199,200,220,280,305,310,320,420,480,500) ORDER BY number;

COMMIT;

-- 최종 통계
SELECT '=== 통계 ===' as status, COUNT(*) as updated_count FROM hymns WHERE number IN (1,2,3,4,5,6,7,8,30,32,40,50,65,75,109,120,140,150,165,199,200,220,280,305,310,320,420,480,500);
