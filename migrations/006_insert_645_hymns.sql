-- Migration: 새찬송가 645장 전체 삽입
-- 작성일: 2025-10-08
-- 기존 데이터: 상세 정보 유지, 제목만 업데이트
-- 신규 데이터: 번호와 제목만 삽입

BEGIN;

-- 작업 전 데이터 개수
SELECT '=== 작업 전 ===' as status, COUNT(*) as count FROM hymns;

INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (1, '만복의 근원 하나님', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (2, '찬양 성부 성자 성령', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (3, '성부 성자와 성령', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (4, '성부 성자와 성령', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (5, '이 천지간 만물들아', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (6, '목소리 높여서', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (7, '성부 성자 성령', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (8, '거룩 거룩 거룩 전능하신 주님', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (9, '하늘에 가득 찬 영광의 하나님', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (10, '전능왕 오셔서', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (11, '홀로 한 분 하나님께', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (12, '다 함께 주를 경배하세', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (13, '영원한 하늘나라', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (14, '주 우리 하나님', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (15, '하나님의 크신 사랑', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (16, '은혜로신 하나님 우리 주 하나님', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (17, '사랑의 하나님', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (18, '성도들아 찬양하자', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (19, '찬송하는 소리 있어', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (20, '큰 영광 중에 계신 주', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (21, '다 찬양하여라', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (22, '만유의 주 앞에', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (23, '만 입이 내게 있으면', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (24, '왕 되신 주', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (25, '면류관 벗어서', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (26, '구세주를 아는 이들', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (27, '빛나고 높은 보좌와', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (28, '복의 근원 강림하사', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (29, '성도여 다 함께', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (30, '전능하고 놀라우신', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (31, '찬양하라 복되신 구세주 예수', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (32, '만유의 주재', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (33, '영광스런 주를 보라', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (34, '참 놀랍도다 주 크신 이름', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (35, '큰 영화로신 주', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (36, '주 예수 이름 높이어', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (37, '주 예수 이름 높이어', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (38, '예수 우리 왕이여', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (39, '주 은혜를 받으려', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (40, '찬송으로 보답할 수 없는', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (41, '내 영혼아 주 찬양하여라', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (42, '거룩한 주님께', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (43, '즐겁게 안식할 날', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (44, '지난 이레 동안에', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (45, '거룩한 주의 날', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (46, '이 날은 주님 정하신', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (47, '하늘이 푸르고', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (48, '거룩하신 주 하나님', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (49, '하나님이 언약하신 그대로', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (50, '내게 있는 모든 것을', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (51, '주님 주신 거룩한 날', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (52, '거룩하신 나의 하나님', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (53, '성전을 떠나가기 전', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (54, '주여 복을 구하오니', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (55, '주 이름으로 모였던', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (56, '우리의 주여', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (57, '오늘 주신 말씀에', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (58, '지난 밤에 보호하사', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (59, '하나님 아버지 어둔 밤이 지나', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (60, '영혼의 햇빛 예수님', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (61, '우리가 기다리던', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (62, '고요히 머리숙여', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (63, '주가 세상을 다스리니', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (64, '기뻐하며 경배하세', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (65, '내 영혼아 찬양하라', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (66, '다 감사드리세', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (67, '영광의 왕께 다 경배하며', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (68, '오 하나님 우리의 창조주시니', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (69, '온 천하 만물 우러러', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (70, '피난처 있으니', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (71, '예부터 도움 되시고', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (72, '만왕의 왕 앞에 나오라', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (73, '내 눈을 들어 두루 살피니', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (74, '오 만세 반석이신', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (75, '주여 우리 무리를', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (76, '창조의 주 아버지께', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (77, '거룩하신 하나님', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (78, '저 높고 푸른 하늘과', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (79, '주 하나님 지으신 모든 세계', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (80, '천지에 있는 이름 중', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (81, '주는 귀한 보배', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (82, '성부의 어린 양이', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (83, '나의 맘에 근심 구름', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (84, '온 세상이 캄캄하여서', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (85, '구주를 생각만 해도', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (86, '내가 늘 의지하는 예수', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (87, '내 주님 입으신 그 옷은', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (88, '내 진정 사모하는', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (89, '샤론의 꽃 예수', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (90, '주 예수 내가 알기 전', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (91, '슬픈 마음 있는 사람', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (92, '위에 계신 나의 친구', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (93, '예수는 나의 힘이요', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (94, '주 예수보다 더 귀한 것은 없네', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (95, '나의 기쁨 나의 소망되시며', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (96, '예수님은 누구신가', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (97, '정혼한 처녀에세', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (98, '예수님 오소서', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (99, '주님 앞에 떨며 서서', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (100, '미리암과 여인들이', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (101, '이 새의 뿌리에서', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (102, '영원한 문아 열려라', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (103, '우리 주님 예수께', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (104, '곧 오소서 임마누엘', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (105, '오랫동안 기다리던', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (106, '아기 예수 나셨네', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (107, '거룩한 밤 복된 이밤', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (108, '그 어린 주 예수', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (109, '고요한 밤 거룩한 밤', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (110, '고요하고 거룩한 밤', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (111, '귀중한 보배합을', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (112, '그 맑고 환한 밤중에', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (113, '저 아기 잠이 들었네', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (114, '그 어린 주 예수', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (115, '기쁘다 구주 오셨네', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (116, '동방에서 박사들', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (117, '만백성 기뻐하여라', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (118, '영광 나라 천사들아', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (119, '옛날 임금 다윗성에', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (120, '오 베들레헴 작은 골', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (121, '우리 구주 나신 날', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (122, '참 반가운 성도여', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (123, '저 들 밖에 한 밤중에', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (124, '양 지키는 목자여', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (125, '천사들의 노래가', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (126, '천사 찬송하기를', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (127, '그 고요하고 쓸쓸한', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (128, '거룩하신 우리 주님', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (129, '마리아는 아기를', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (130, '찬란한 주의 영광은', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (131, '다 나와 찬송 부르세', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (132, '주의 영광 빛나니', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (133, '하나님의 말씀으로', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (134, '나 어느 날 꿈속을 헤매며', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (135, '어저께나 오늘이나', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (136, '가나의 혼인 잔치', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (137, '하나님의 아들이', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (138, '햇빛을 받는 곳마다', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (139, '오 영원하신 내 주 예수', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (140, '왕 되신 우리 주께', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (141, '호산나 호산나', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (142, '시온에 오신 주 (시온에 오시는 주)', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (143, '웬말인가 날 위하여', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (144, '예수 나를 위하여', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (145, '오 거룩하신 주님', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (146, '저 멀리 푸른 언덕에', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (147, '거기 너 있었는가', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (148, '영화로운 주 예수의', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (149, '주 달려 죽은 십자가', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (150, '갈보리산 위에', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (151, '만왕의 왕 내 주께서', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (152, '귀하신 예수', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (153, '가시 면류관', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (154, '생명의 주여 면류관', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (155, '십자가 지고', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (156, '머리에 가시관 붉은 피 흐르는', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (157, '겟세마네 동산에서 취후기도', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (158, '서쪽 하늘 붉은 노을', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (159, '기뻐 찬송하세', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (160, '무덤에 머물러', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (161, '할렐루야 우리 예수', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (162, '부활하신 구세주', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (163, '할렐루야 할렐루야', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (164, '예수 부활했으니', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (165, '주님께 영광', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (166, '싸움은 모두 끝나고', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (167, '즐겁도다 이 날', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (168, '하늘에 찬송이 들리던 그 날', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (169, '사망의 권세가', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (170, '내 주님은 살아계시며', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (171, '하나님의 독생자', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (172, '사망을 이긴 주', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (173, '다 함께 찬송 부르자', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (174, '대속하신 구주께서', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (175, '신랑 되신 예수께서', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (176, '주 어느 때 다시 오실는지', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (177, '오랫동안 고대하던', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (178, '주 예수 믿는 자여', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (179, '주 예수의 강림이', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (180, '하나님의 나팔 소리', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (181, '부활 승천하신 주께서', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (182, '강물같이 흐르는 기쁨', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (183, '빈 들에 마른 풀같이', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (184, '불길 같은 주 성령', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (185, '이 기쁜 소식을', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (186, '영화로신 주 성령', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (187, '비둘기 같이 온유한', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (188, '무한하신 주 성령', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (189, '진실하신 주 성령', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (190, '성령이여 강림하사', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (191, '내가 매일 기쁘게', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (192, '임하소서 임하소서', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (193, '성령의 봄바람 불어오니', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (194, '저 하늘 거룩하신 주여', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (195, '성령이여 우리 찬송 부를 때', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (196, '성령의 은사를', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (197, '은혜가 풍성한 하나님은', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (198, '주 예수 해변서', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (199, '나의 사랑하는 책', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (200, '달고 오묘한 그 말씀', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (201, '참 사람 되신 말씀', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (202, '하나님 아버지 주신 책은', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (203, '하나님의 말씀은', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (204, '주의 말씀 듣고서', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (205, '주 예수 크신 사랑', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (206, '주 예수 귀한 말씀은', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (207, '귀하신 주님 계신 곳', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (208, '내 주의 나라와', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (209, '이 세상 풍파 심하고', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (210, '시온성과 같은 교회', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (211, '값비싼 향유를 주께 드린', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (212, '겸손히 주를 섬길 때', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (213, '나의 생명 드리니', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (214, '나 주의 도움 받고자', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (215, '내 죄 속해 주신 주께', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (216, '성자의 귀한 몸', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (217, '하나님이 말씀하시기를', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (218, '네 맘과 정성을 다하여서', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (219, '주 하나님의 사랑은', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (220, '사랑하는 주님 앞에', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (221, '주 믿는 형제들', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (222, '우리 다시 만날 때까지', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (223, '하나님은 우리들의', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (224, '정한 물로 우리 죄를', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (225, '실로암 샘물가에 핀', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (226, '성령으로 세례 받아', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (227, '주 앞에 성찬 받기 위하여', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (228, '오 나의 주님 친히 뵈오니', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (229, '아무 흠도 없고', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (230, '우리의 참되신 구주시니', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (231, '우리 다 같이 무릎 꿇고', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (232, '유월절 때가 이르러', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (233, '자비로 그 몸 찢기시고', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (234, '구주 예수 그리스도', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (235, '보아라 즐거운 우리 집', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (236, '우리 모든 수고 끝나', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (237, '저 건너편 강 언덕에', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (238, '해 지는 저편', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (239, '저 뵈는 본향 집', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (240, '주가 맡긴 모든 역사', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (241, '아름다운 본향', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (242, '황무지가 장미꽃같이', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (243, '저 요단강 건너편에', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (244, '구원 받은 천국의 성도들', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (245, '저 좋은 낙원 이르니', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (246, '나 가나안 땅 귀한 성에', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (247, '보아라 저 하늘에', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (248, '언약의 주 하나님', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (249, '주 사랑하는 자 다 찬송할 때에', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (250, '구주의 십자가 보혈로', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (251, '놀랍다 주님의 큰 은혜', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (252, '나의 죄를 씻기는', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (253, '그 자비하신 주님', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (254, '내 주의 보혈은', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (255, '너희 죄 흉악하나', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (256, '나의 죄 모두 지신 주님', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (257, '마음에 가득한 의심을 깨치고', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (258, '샘물과 같은 보혈은', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (259, '예수 십자가에 흘린 피로써', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (260, '우리를 죄에서 구하시려', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (261, '이 세상의 모든 죄를', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (262, '날 구원하신 예수님', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (263, '이 세상 험하고', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (264, '정결하게 하는 샘이', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (265, '주 십자가를 지심으로', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (266, '주의 피로 이룬 샘물', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (267, '주의 확실한 약속의 말씀 듣고', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (268, '죄에서 자유를 얻게 함은', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (269, '그 참혹한 십자가에', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (270, '변찮는 주님의 사랑과', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (271, '나와 같은 죄인 위해', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (272, '고통의 멍에 벗으려고', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (273, '나 주를 멀리 떠났다', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (274, '나 행한 것 죄뿐이니', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (275, '날마다 주와 멀어져', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (276, '아버지여 이 죄인을', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (277, '양떼를 떠나서', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (278, '여러 해 동안 주 떠나', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (279, '인애하신 구세주여', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (280, '천부여 의지 없어서', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (281, '요나처럼 순종않고', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (282, '큰 죄에 빠진 날 위해', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (283, '나 속죄함을 받은 후', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (284, '오랫동안 모든 죄 가운데 빠져', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (285, '주의 말씀 받은 그날', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (286, '주 예수님 내 맘에 오사', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (287, '예수 앞에 나오면', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (288, '예수를 나의 구주 삼고', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (289, '주 예수 내 맘에 들어와', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (290, '우리는 주님을 늘 배반하나', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (291, '외롭게 사는 이 그 누군가', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (292, '주 없이 살 수 없네', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (293, '주의 사랑 비칠 때에', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (294, '하나님은 외아들을', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (295, '큰 죄에 빠진 나를', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (296, '죄인 구하시려고', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (297, '양 아흔 아홉 마리는', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (298, '속죄하신 구세주를', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (299, '하나님 사랑은', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (300, '내 맘이 낙심되며', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (301, '지금까지 지내온 것', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (302, '내 주 하나님 넓고 큰 은혜는', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (303, '날 위하여 십자가의', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (304, '그 크신 하나님의 사랑', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (305, '나 같은 죄인 살리신', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (306, '죽을 죄인 살려주신', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (307, '소리 없이 보슬보슬', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (308, '내 평생 살아온 길', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (309, '목마른 내 영혼', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (310, '아 하나님의 은혜로', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (311, '내 너를 위하여', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (312, '너 하나님께 이끌리어', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (313, '내 임금 예수 내 주여', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (314, '내 구주 예수를 더욱 사랑', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (315, '내 주 되신 주를 참 사랑하고', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (316, '주여 나의 생명', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (317, '내 주 예수 주신 은혜', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (318, '순교자의 흘린 피가', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (319, '말씀으로 이 세상을', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (320, '나의 죄를 정케 하사', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (321, '날 대속하신 예수께', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (322, '세상의 헛된 신을 버리고', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (323, '부름 받아 나선 이 몸', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (324, '예수 나를 오라 하네', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (325, '예수가 함께 계시니', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (326, '내 죄를 회개하고', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (327, '주님 주실 화평', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (328, '너 주의 사람아', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (329, '주 날 불러 이르소서', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (330, '어둔 밤 쉬 되리니', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (331, '영광을 받으신 만유의 주여', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (332, '우리는 부지런한', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (333, '충성하라 죽도록', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (334, '위대하신 주를', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (335, '크고 놀라운 평화가', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (336, '환난과 핍박 중에도', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (337, '내 모든 시험 무거운 짐을', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (338, '내 주를 가까이 하게 함은', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (339, '내 주님 지신 십자가', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (340, '어지러운 세상 중에', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (341, '십자가를 내가 지고', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (342, '너 시험을 당해', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (343, '시험 받을 때에', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (344, '믿음으로 가리라', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (345, '캄캄한 밤 사나운 바람 불 때', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (346, '주 예수 우리 구하려', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (347, '허락하신 새 땅에', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (348, '마귀들과 싸울지라', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (349, '나는 예수 따라가는', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (350, '우리들이 싸울 것은', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (351, '믿는 사람들은 주의 군사니', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (352, '십자가 군병들아', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (353, '십자가 군병 되어서', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (354, '주를 앙모하는 자', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (355, '다같이 일어나', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (356, '주예수이름소리높여', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (357, '주 믿는 사람 일어나', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (358, '주의 진리 위해 십자가 군기', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (359, '천성을 향해 가는 성도들아', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (360, '행군 나팔 소리에', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (361, '기도하는 이 시간', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (362, '주여 복을 주시기를', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (363, '내가 깊은 곳에서', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (364, '내 기도하는 그 시간', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (365, '마음속에 근심 있는 사람', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (366, '어두운 내 눈 밝히사', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (367, '인내하게 하소서 주여 우리를', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (368, '주 예수여 은혜를', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (369, '죄짐 맡은 우리 구주', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (370, '주 안에 있는 나에게', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (371, '구주여 광풍이 불어', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (372, '그 누가 나의 괴롬 알며', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (373, '고요한 바다로', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (374, '나의 믿음 약할 때', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (375, '나는 갈 길 모르니', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (376, '나그네와같은내가', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (377, '전능하신 주 하나님', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (378, '내 선한 목자', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (379, '내 갈 길 멀고 밤은 깊은데', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (380, '나의 생명 되신 주', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (381, '나 캄캄한 밤 죄의 길에', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (382, '너 근심 걱정 말아라', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (383, '눈을 들어 산을 보니', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (384, '나의 갈 길 다 가도록', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (385, '못박혀죽으신', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (386, '만세반석 열린곳에', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (387, '멀리 멀리 갔더니', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (388, '비바람이 칠 때와', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (389, '내게로 오라 하신 주님의', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (390, '예수가 거느리시니', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (391, '오 놀라운 구세주', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (392, '주여 어린 사슴이', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (393, '오 신실하신 주', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (394, '이 세상의 친구들', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (395, '자비하신 예수여', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (396, '우리 주님 밤새워', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (397, '주 사랑 안에 살면', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (398, '어둠의 권세에서', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (399, '어린 양들아 두려워 말아라', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (400, '험한 시험 물 속에서', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (401, '주의 곁에 있을 때', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (402, '나의반석 나의 방패', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (403, '영원하신 주님의', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (404, '바다에 놀이 일 때에', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (405, '주의 친절한 팔에 안기세', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (406, '곤한 내 영혼 편히 쉴 곳과', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (407, '구주와 함께 나 죽었으니', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (408, '나 어느 곳에 있든지', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (409, '나의 기쁨은 사람의 주님께', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (410, '내 맘에 한 노래 있어', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (411, '아 내 맘속에', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (412, '내 영혼의 그윽히 깊은 데서', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (413, '내 평생에 가는 길', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (414, '이 세상은 요란하나', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (415, '십자가 그늘 아래', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (416, '너희 근심 걱정을', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (417, '주 예수 넓은 품에', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (418, '기쁠때나 슬플때나', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (419, '주 날개 밑 내가 편안히 쉬네', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (420, '너 성결키 위해', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (421, '내가 예수 믿고서', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (422, '거룩하게 하소서', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (423, '먹보다도 더 검은', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (424, '아버지여 나의 맘을', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (425, '주님의 뜻을 이루소서', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (426, '이 죄인을 완전케 하시옵고', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (427, '맘 가난한 사람', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (428, '내 영혼에 햇빛 비치니', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (429, '세상 모든 풍파 너를 흔들어', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (430, '주와 같이 길 가는 것', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (431, '주 안에 기쁨있네', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (432, '큰 물결이 설레는 어둔 바다', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (433, '귀하신 주여 날 붙드사', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (434, '귀하신 친구 내게 계시니', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (435, '나의 영원하신 기업', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (436, '나 이제 주님의 새 생명 얻은 몸', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (437, '하늘 보좌 떠나서', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (438, '내 영혼이 은총 입어', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (439, '십자가로 가까이', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (440, '어디든지 예수 나를 이끌면', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (441, '은혜 구한 내게 은혜의 주님', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (442, '저 장미꽃 위에 이슬', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (443, '아침 햇살 비칠때', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (444, '겟세마네 동산에서', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (445, '태산을 넘어 험곡에 가도', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (446, '주 음성 외에는', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (447, '이 세상 끝날까지', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (448, '주님 가신 길을 따라', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (449, '예수 따라가며', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (450, '내 평생 소원 이것뿐', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (451, '예수 영광 버리사', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (452, '내 모든 소원 기도의 제목', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (453, '예수 더 알기 원하네', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (454, '주와 같이 되기를', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (455, '주님의 마음을 본받는 자', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (456, '거친 세상에서 실패하거든', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (457, '겟세마네 동산의', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (458, '너의 마음에 슬픔이 가득할 때', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (459, '누가 주를 따라', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (460, '뜻 없이 무릎 꿇는', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (461, '십자가를 질 수 있나', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (462, '생명 진리 은혜되신', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (463, '신자 되기 원합니다', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (464, '믿음의 새 빛을', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (465, '주 믿는 나 남 위해', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (466, '죽기까지 사랑하신 주', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (467, '높으신 주께서 낮아지심은', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (468, '큰 사랑의 새 계명을', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (469, '내 주 하나님', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (470, '나의 몸이 상하여', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (471, '주여 나의 병든 몸을', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (472, '네 병든 손 내밀리고', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (473, '괴로움과 고통을', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (474, '의원되신 예수님의', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (475, '인류는 하나 되게', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (476, '꽃이피고 새가 우는', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (477, '하나님이 창조하신', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (478, '참 아름다워라', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (479, '괴로운 인생길 가는 몸이', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (480, '천국에서 만나보자', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (481, '때 저물어서 날이 어두니', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (482, '참 즐거운 노래를', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (483, '구름 같은 이 세상', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (484, '내 맘의 주여 소망되소서', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (485, '세월이 흘러가는데', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (486, '이 세상에 근심된 일이 많고', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (487, '어두움 후에 빛이 오며', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (488, '이 몸의 소망 무언가', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (489, '저 요단강 건너편에', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (490, '주여 지난 밤 내 꿈에', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (491, '저 높은 곳을 향하여', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (492, '잠시 세상에 내가 살면서', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (493, '하늘 가는 밝은 길이', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (494, '만세반석 열리니', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (495, '익은 곡식 거둘 자가', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (496, '새벽부터 우리', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (497, '주 예수 넓은 사랑', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (498, '저 죽어가는 자 다 구원하고', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (499, '흑암에 사는 백성들을 보라', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (500, '물 위에 생명줄 던지어라', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (501, '너 시온아 이 소식 전파하라', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (502, '빛의 사자들이여', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (503, '세상 모두 사랑 없어', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (504, '주님의 명령 전할 사자여', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (505, '온 세상 위하여', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (506, '땅 끝까지 복음을', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (507, '저 북방 얼음 산과', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (508, '우리가 지금은 나그네 되어도', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (509, '기쁜 일이 있어 천국 종 치네', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (510, '하나님의 진리 등대', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (511, '예수 말씀하시기를', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (512, '천성길을 버리고', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (513, '헛된 욕망길을 가며', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (514, '먼동 튼다 일어나라', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (515, '눈을 들어 하늘 보라', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (516, '옳은 길 따르라 의의 길을', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (517, '가난한 자 돌봐주며', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (518, '기쁜 소리 들리니', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (519, '구주께서 부르되', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (520, '듣는 사람마다 복음 전하여', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (521, '구원으로 인도하는', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (522, '웬일인가 내 형제여', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (523, '어둔 죄악 길에서', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (524, '갈 길을 밝히 보이시니', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (525, '돌아와 돌아와', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (526, '목마른 자들아', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (527, '어서 돌아오오', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (528, '예수가 우리를 부르는 소리', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (529, '온유한 주님의 음성', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (530, '주께서 문에 오셔서', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (531, '자비한 주께서 부르시네', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (532, '주께로 한 걸음씩', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (533, '우리 주 십자가', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (534, '주님 찾아 오셨네', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (535, '주 예수 대문 밖에', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (536, '죄짐에 눌린 사람은', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (537, '형제여 지체 말라', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (538, '죄짐을 지고서 곤하거든', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (539, '너 예수께 조용히 나가', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (540, '주의 음성을 내가 들으니', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (541, '꽃이 피는 봄날에만', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (542, '구주 예수 의지함이', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (543, '어려운 일 당할 때', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (544, '울어도 못하네', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (545, '이 눈에 아무 증거 아니 뵈어도', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (546, '주님 약속하신 말씀 위에서', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (547, '나같은 죄인까지도', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (548, '날 구속하신', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (549, '내 주여 뜻대로', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (550, '시온의 영광이 빛나는 아침', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (551, '오늘까지 복과 은혜', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (552, '아침 해가 돋을 때', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (553, '새해 아침 환히 밝았네', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (554, '종소리 크게 울려라', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (555, '우리 주님 모신 가정', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (556, '날마다 주님을 의지하는', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (557, '에덴의 동산처럼', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (558, '미더워라 주의 가정', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (559, '사철에 봄바람 불어 잇고', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (560, '주의 발자취를 따름이', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (561, '예수님의 사랑은', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (562, '예루살렘 아이들', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (563, '예수 사랑하심을', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (564, '예수께서 오실 때에', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (565, '예수께로 가면', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (566, '사랑의 하나님', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (567, '다정하신 목자 예수', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (568, '하나님은 나의 목자시니', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (569, '선한 목자 되신 우리 주', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (570, '주는 나를 기르시는 목자', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (571, '역사속에 보냄받아', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (572, '바다같이 넓은 은혜', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (573, '말씀에 순종하여', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (574, '가슴마다 파도친다', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (575, '주님께 귀한 것 드려', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (576, '하나님의 뜻을따라', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (577, '낳으시고 길러주신', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (578, '언제나 바라봐도', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (579, '어머니의 넓은 사랑', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (580, '삼천리 반도 금수강산', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (581, '주하나님 이 나라를 지켜주시고', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (582, '어둔 밤 마음에 잠겨', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (583, '이 민족에 복음을', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (584, '우리나라 지켜주신', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (585, '내 주는 강한 성이요', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (586, '어느 민족 누구게나', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (587, '감사하는 성도여', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (588, '공중 나는 새를 보라', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (589, '넓은 들에 익은 곡식', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (590, '논밭에 오곡백과', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (591, '저 밭에 농부 나가', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (592, '산마다 불이 탄다 고운 단풍에', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (593, '아름다운 하늘과', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (594, '감사하세 찬양하세', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (595, '나 맡은 본분은', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (596, '영광은 주님 홀로', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (597, '이전에 주님을 내가 몰라', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (598, '천지 주관하는 주님', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (599, '우리의 기도 들어주시옵소서', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (600, '교회의 참된 터는', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (601, '하나님이 정하시고', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (602, '성부님께 빕니다', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (603, '태초에 하나님이', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (604, '완전한 사랑', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (605, '오늘 모여 찬송함은', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (606, '해보다 더 밝은 저 천국', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (607, '내 본향 가는 길', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (608, '후일에 생명 그칠 때', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (609, '이 세상 살때에', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (610, '고생과 수고가 다 지난 후', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (611, '주님오라 부르시어', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (612, '이땅에서 주를 위해', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (613, '사랑의 주 하나님', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (614, '얼마나 아프셨나', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (615, '그 큰일을 행하신', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (616, '주를 경배하리', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (617, '주님을 찬양합니다', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (618, '나 주님을 사랑합니다', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (619, '놀라운 그 이름', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (620, '여기에 모인 우리', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (621, '찬양하라 내 영혼아', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (622, '거룩한 밤', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (623, '주님의 시간에', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (624, '우리 모두 찬양해', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (625, '거룩 거룩 거룩한 하나님', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (626, '만민들아 다 경배하라', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (627, '할렐루야 할렐루야 다 함께', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (628, '아멘아멘아멘 영광과 존귀를', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (629, '거룩 거룩 거룩', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (630, '진리와 생명 되신 주', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (631, '진리와 생명 되신 주', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (632, '우리 기도를', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (633, '나의 하나님 받으소서', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (634, '모든것이 주께로 부터', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (635, '하늘에 계신(주기도문)', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (636, '하늘에 계신(주기도문)', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (637, '주님 우리의 마음을 여시어', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (638, '모든 것이 주께로부터', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (639, '주 너를 지키시고', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (640, '아멘', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (641, '아멘', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (642, '아멘', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (643, '아멘', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (644, '아멘', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
INSERT INTO hymns (number, title, created_at, updated_at)
VALUES (645, '아멘', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();

-- 작업 후 데이터 개수 및 샘플
SELECT '=== 작업 후 ===' as status, COUNT(*) as count FROM hymns;
SELECT '=== 샘플 데이터 ===' as status;
SELECT number, title FROM hymns WHERE number IN (1, 100, 200, 300, 400, 500, 645) ORDER BY number;

COMMIT;

-- 최종 통계
SELECT
    COUNT(*) as total_hymns,
    COUNT(lyrics) as with_lyrics,
    COUNT(composer) as with_composer,
    COUNT(author) as with_author
FROM hymns;
