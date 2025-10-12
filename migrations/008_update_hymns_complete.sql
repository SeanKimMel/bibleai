-- Migration: 찬송가 작사가, 작곡가 정보 업데이트
-- 데이터 소스: wiki.michaelhan.net
-- 생성일: 2025-10-09 11:25:39

BEGIN;

UPDATE hymns SET
    title = '만복의 근원 하나님',
    composer = 'Genevan PsalterLoys "Louis" Bourgeois',
    author = 'Thomas Ken',
    theme = '예배/송영',
    tempo = '보통으로, 92',
    updated_at = NOW()
WHERE number = 1;

UPDATE hymns SET
    title = '찬양 성부 성자 성령',
    composer = 'Thomas Hastings',
    author = 'Tate and Brady',
    theme = '예배/송영',
    tempo = '조금 느리게, 66',
    updated_at = NOW()
WHERE number = 2;

UPDATE hymns SET
    title = '성부 성자와 성령',
    composer = 'Christopher Meineke',
    author = NULL,
    theme = '예배/송영',
    tempo = '보통으로, 112',
    updated_at = NOW()
WHERE number = 3;

UPDATE hymns SET
    title = '성부 성자와 성령',
    composer = 'Henry Wellington Greatorex',
    author = NULL,
    theme = '예배/송영',
    tempo = '보통으로, 108',
    updated_at = NOW()
WHERE number = 4;

UPDATE hymns SET
    title = '이 천지간 만물들아',
    composer = 'Luther Orlando Emerson',
    author = NULL,
    theme = '예배/송영',
    tempo = '보통으로, 88',
    updated_at = NOW()
WHERE number = 5;

UPDATE hymns SET
    title = '목소리 높여서',
    composer = 'The Parish ChoirCanon Havergal',
    author = 'Isaac WattsPhilip Doddridge',
    theme = '예배/송영',
    tempo = '조금 빠르게, 108',
    updated_at = NOW()
WHERE number = 6;

UPDATE hymns SET
    title = '성부 성자 성령',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 7;

UPDATE hymns SET
    title = '거룩 거룩 거룩 전능하신 주님',
    composer = 'John Bacchus Dykes',
    author = 'Reginald Heber',
    theme = '예배/찬양과 경배',
    tempo = '96, 보통으로',
    updated_at = NOW()
WHERE number = 8;

UPDATE hymns SET
    title = '하늘에 가득 찬 영광의 하나님',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 9;

UPDATE hymns SET
    title = '전능왕 오셔서',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 10;

UPDATE hymns SET
    title = '홀로 한 분 하나님께',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 11;

UPDATE hymns SET
    title = '다 함께 주를 경배하세',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 12;

UPDATE hymns SET
    title = '영원한 하늘나라',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 13;

UPDATE hymns SET
    title = '주 우리 하나님',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 14;

UPDATE hymns SET
    title = '하나님의 크신 사랑',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 15;

UPDATE hymns SET
    title = '은혜로신 하나님 우리 주 하나님',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 16;

UPDATE hymns SET
    title = '사랑의 하나님',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 17;

UPDATE hymns SET
    title = '성도들아 찬양하자',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 18;

UPDATE hymns SET
    title = '찬송하는 소리 있어',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 19;

UPDATE hymns SET
    title = '큰 영광 중에 계신 주',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 20;

UPDATE hymns SET
    title = '다 찬양하여라',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 21;

UPDATE hymns SET
    title = '만유의 주 앞에',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 22;

UPDATE hymns SET
    title = '만 입이 내게 있으면',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 23;

UPDATE hymns SET
    title = '왕 되신 주',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 24;

UPDATE hymns SET
    title = '면류관 벗어서',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 25;

UPDATE hymns SET
    title = '구세주를 아는 이들',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 26;

UPDATE hymns SET
    title = '빛나고 높은 보좌와',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 27;

UPDATE hymns SET
    title = '복의 근원 강림하사',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 28;

UPDATE hymns SET
    title = '성도여 다 함께',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 29;

UPDATE hymns SET
    title = '전능하고 놀라우신',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 30;

UPDATE hymns SET
    title = '찬양하라 복되신 구세주 예수',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 31;

UPDATE hymns SET
    title = '만유의 주재',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 32;

UPDATE hymns SET
    title = '영광스런 주를 보라',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 33;

UPDATE hymns SET
    title = '참 놀랍도다 주 크신 이름',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 34;

UPDATE hymns SET
    title = '큰 영화로신 주',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 35;

UPDATE hymns SET
    title = '주 예수 이름 높이어',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 36;

UPDATE hymns SET
    title = '주 예수 이름 높이어',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 37;

UPDATE hymns SET
    title = '예수 우리 왕이여',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 38;

UPDATE hymns SET
    title = '주 은혜를 받으려',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 39;

UPDATE hymns SET
    title = '찬송으로 보답할 수 없는',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 40;

UPDATE hymns SET
    title = '내 영혼아 주 찬양하여라',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 41;

UPDATE hymns SET
    title = '거룩한 주님께',
    composer = 'William Fisk Sherwin',
    author = 'John Samuel Bewley Monsell',
    theme = '예배/찬양과 경배',
    tempo = '104, 조금 빠르게',
    updated_at = NOW()
WHERE number = 42;

UPDATE hymns SET
    title = '즐겁게 안식할 날',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 43;

UPDATE hymns SET
    title = '지난 이레 동안에',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 44;

UPDATE hymns SET
    title = '거룩한 주의 날',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 45;

UPDATE hymns SET
    title = '이 날은 주님 정하신',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 46;

UPDATE hymns SET
    title = '하늘이 푸르고',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 47;

UPDATE hymns SET
    title = '거룩하신 주 하나님',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 48;

UPDATE hymns SET
    title = '하나님이 언약하신 그대로',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 49;

UPDATE hymns SET
    title = '내게 있는 모든 것을',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 50;

UPDATE hymns SET
    title = '주님 주신 거룩한 날',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 51;

UPDATE hymns SET
    title = '거룩하신 나의 하나님',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 52;

UPDATE hymns SET
    title = '성전을 떠나가기 전',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 53;

UPDATE hymns SET
    title = '주여 복을 구하오니',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 54;

UPDATE hymns SET
    title = '주 이름으로 모였던',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 55;

UPDATE hymns SET
    title = '우리의 주여',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 56;

UPDATE hymns SET
    title = '오늘 주신 말씀에',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 57;

UPDATE hymns SET
    title = '지난 밤에 보호하사',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 58;

UPDATE hymns SET
    title = '하나님 아버지 어둔 밤이 지나',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 59;

UPDATE hymns SET
    title = '영혼의 햇빛 예수님',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 60;

UPDATE hymns SET
    title = '우리가 기다리던',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 61;

UPDATE hymns SET
    title = '고요히 머리숙여',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 62;

UPDATE hymns SET
    title = '주가 세상을 다스리니',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 63;

UPDATE hymns SET
    title = '기뻐하며 경배하세',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 64;

UPDATE hymns SET
    title = '내 영혼아 찬양하라',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 65;

UPDATE hymns SET
    title = '다 감사드리세',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 66;

UPDATE hymns SET
    title = '영광의 왕께 다 경배하며',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 67;

UPDATE hymns SET
    title = '오 하나님 우리의 창조주시니',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 68;

UPDATE hymns SET
    title = '온 천하 만물 우러러',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 69;

UPDATE hymns SET
    title = '피난처 있으니',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 70;

UPDATE hymns SET
    title = '예부터 도움 되시고',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 71;

UPDATE hymns SET
    title = '만왕의 왕 앞에 나오라',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 72;

UPDATE hymns SET
    title = '내 눈을 들어 두루 살피니',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 73;

UPDATE hymns SET
    title = '오 만세 반석이신',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 74;

UPDATE hymns SET
    title = '주여 우리 무리를',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 75;

UPDATE hymns SET
    title = '창조의 주 아버지께',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 76;

UPDATE hymns SET
    title = '거룩하신 하나님',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 77;

UPDATE hymns SET
    title = '저 높고 푸른 하늘과',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 78;

UPDATE hymns SET
    title = '주 하나님 지으신 모든 세계',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 79;

UPDATE hymns SET
    title = '천지에 있는 이름 중',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 80;

UPDATE hymns SET
    title = '주는 귀한 보배',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 81;

UPDATE hymns SET
    title = '성부의 어린 양이',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 82;

UPDATE hymns SET
    title = '나의 맘에 근심 구름',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 83;

UPDATE hymns SET
    title = '온 세상이 캄캄하여서',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 84;

UPDATE hymns SET
    title = '구주를 생각만 해도',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 85;

UPDATE hymns SET
    title = '내가 늘 의지하는 예수',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 86;

UPDATE hymns SET
    title = '내 주님 입으신 그 옷은',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 87;

UPDATE hymns SET
    title = '내 진정 사모하는',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 88;

UPDATE hymns SET
    title = '샤론의 꽃 예수',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 89;

UPDATE hymns SET
    title = '주 예수 내가 알기 전',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 90;

UPDATE hymns SET
    title = '슬픈 마음 있는 사람',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 91;

UPDATE hymns SET
    title = '위에 계신 나의 친구',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 92;

UPDATE hymns SET
    title = '예수는 나의 힘이요',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 93;

UPDATE hymns SET
    title = '주 예수보다 더 귀한 것은 없네',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 94;

UPDATE hymns SET
    title = '나의 기쁨 나의 소망되시며',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 95;

UPDATE hymns SET
    title = '예수님은 누구신가',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 96;

UPDATE hymns SET
    title = '정혼한 처녀에세',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 97;

UPDATE hymns SET
    title = '예수님 오소서',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 98;

UPDATE hymns SET
    title = '주님 앞에 떨며 서서',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 99;

UPDATE hymns SET
    title = '미리암과 여인들이',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 100;

UPDATE hymns SET
    title = '이 새의 뿌리에서',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 101;

UPDATE hymns SET
    title = '영원한 문아 열려라',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 102;

UPDATE hymns SET
    title = '우리 주님 예수께',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 103;

UPDATE hymns SET
    title = '곧 오소서 임마누엘',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 104;

UPDATE hymns SET
    title = '오랫동안 기다리던',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 105;

UPDATE hymns SET
    title = '아기 예수 나셨네',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 106;

UPDATE hymns SET
    title = '거룩한 밤 복된 이밤',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 107;

UPDATE hymns SET
    title = '그 어린 주 예수',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 108;

UPDATE hymns SET
    title = '고요한 밤 거룩한 밤',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 109;

UPDATE hymns SET
    title = '고요하고 거룩한 밤',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 110;

UPDATE hymns SET
    title = '귀중한 보배합을',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 111;

UPDATE hymns SET
    title = '그 맑고 환한 밤중에',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 112;

UPDATE hymns SET
    title = '저 아기 잠이 들었네',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 113;

UPDATE hymns SET
    title = '그 어린 주 예수',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 114;

UPDATE hymns SET
    title = '기쁘다 구주 오셨네',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 115;

UPDATE hymns SET
    title = '동방에서 박사들',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 116;

UPDATE hymns SET
    title = '만백성 기뻐하여라',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 117;

UPDATE hymns SET
    title = '영광 나라 천사들아',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 118;

UPDATE hymns SET
    title = '옛날 임금 다윗성에',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 119;

UPDATE hymns SET
    title = '오 베들레헴 작은 골',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 120;

UPDATE hymns SET
    title = '우리 구주 나신 날',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 121;

UPDATE hymns SET
    title = '참 반가운 성도여',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 122;

UPDATE hymns SET
    title = '저 들 밖에 한 밤중에',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 123;

UPDATE hymns SET
    title = '양 지키는 목자여',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 124;

UPDATE hymns SET
    title = '천사들의 노래가',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 125;

UPDATE hymns SET
    title = '천사 찬송하기를',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 126;

UPDATE hymns SET
    title = '그 고요하고 쓸쓸한',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 127;

UPDATE hymns SET
    title = '거룩하신 우리 주님',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 128;

UPDATE hymns SET
    title = '마리아는 아기를',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 129;

UPDATE hymns SET
    title = '찬란한 주의 영광은',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 130;

UPDATE hymns SET
    title = '다 나와 찬송 부르세',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 131;

UPDATE hymns SET
    title = '주의 영광 빛나니',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 132;

UPDATE hymns SET
    title = '하나님의 말씀으로',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 133;

UPDATE hymns SET
    title = '나 어느 날 꿈속을 헤매며',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 134;

UPDATE hymns SET
    title = '어저께나 오늘이나',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 135;

UPDATE hymns SET
    title = '가나의 혼인 잔치',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 136;

UPDATE hymns SET
    title = '하나님의 아들이',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 137;

UPDATE hymns SET
    title = '햇빛을 받는 곳마다',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 138;

UPDATE hymns SET
    title = '오 영원하신 내 주 예수',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 139;

UPDATE hymns SET
    title = '왕 되신 우리 주께',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 140;

UPDATE hymns SET
    title = '웬말인가 날 위하여',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 141;

UPDATE hymns SET
    title = '시온에 오신 주',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 142;

UPDATE hymns SET
    title = '호산나 호산나',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 143;

UPDATE hymns SET
    title = '예수 나를 위하여',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 144;

UPDATE hymns SET
    title = '오 거룩하신 주님',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 145;

UPDATE hymns SET
    title = '저 멀리 푸른 언덕에',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 146;

UPDATE hymns SET
    title = '거기 너 있었는가',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 147;

UPDATE hymns SET
    title = '영화로운 주 예수의',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 148;

UPDATE hymns SET
    title = '주 달려 죽은 십자가',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 149;

UPDATE hymns SET
    title = '갈보리산 위에',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 150;

UPDATE hymns SET
    title = '만왕의 왕 내 주께서',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 151;

UPDATE hymns SET
    title = '귀하신 예수',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 152;

UPDATE hymns SET
    title = '가시 면류관',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 153;

UPDATE hymns SET
    title = '생명의 주여 면류관',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 154;

UPDATE hymns SET
    title = '십자가 지고',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 155;

UPDATE hymns SET
    title = '머리에 가시관 붉은 피 흐르는',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 156;

UPDATE hymns SET
    title = '겟세마네 동산에서 취후기도',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 157;

UPDATE hymns SET
    title = '서쪽 하늘 붉은 노을',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 158;

UPDATE hymns SET
    title = '기뻐 찬송하세',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 159;

UPDATE hymns SET
    title = '무덤에 머물러',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 160;

UPDATE hymns SET
    title = '할렐루야 우리 예수',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 161;

UPDATE hymns SET
    title = '부활하신 구세주',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 162;

UPDATE hymns SET
    title = '할렐루야 할렐루야',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 163;

UPDATE hymns SET
    title = '예수 부활했으니',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 164;

UPDATE hymns SET
    title = '주님께 영광',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 165;

UPDATE hymns SET
    title = '싸움은 모두 끝나고',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 166;

UPDATE hymns SET
    title = '즐겁도다 이 날',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 167;

UPDATE hymns SET
    title = '하늘에 찬송이 들리던 그 날',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 168;

UPDATE hymns SET
    title = '사망의 권세가',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 169;

UPDATE hymns SET
    title = '내 주님은 살아계시며',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 170;

UPDATE hymns SET
    title = '하나님의 독생자',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 171;

UPDATE hymns SET
    title = '사망을 이긴 주',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 172;

UPDATE hymns SET
    title = '다 함께 찬송 부르자',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 173;

UPDATE hymns SET
    title = '대속하신 구주께서',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 174;

UPDATE hymns SET
    title = '신랑 되신 예수께서',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 175;

UPDATE hymns SET
    title = '주 어느 때 다시 오실는지',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 176;

UPDATE hymns SET
    title = '오랫동안 고대하던',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 177;

UPDATE hymns SET
    title = '주 예수 믿는 자여',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 178;

UPDATE hymns SET
    title = '주 예수의 강림이',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 179;

UPDATE hymns SET
    title = '하나님의 나팔 소리',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 180;

UPDATE hymns SET
    title = '부활 승천하신 주께서',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 181;

UPDATE hymns SET
    title = '강물같이 흐르는 기쁨',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 182;

UPDATE hymns SET
    title = '빈 들에 마른 풀같이',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 183;

UPDATE hymns SET
    title = '불길 같은 주 성령',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 184;

UPDATE hymns SET
    title = '이 기쁜 소식을',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 185;

UPDATE hymns SET
    title = '영화로신 주 성령',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 186;

UPDATE hymns SET
    title = '비둘기 같이 온유한',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 187;

UPDATE hymns SET
    title = '무한하신 주 성령',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 188;

UPDATE hymns SET
    title = '진실하신 주 성령',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 189;

UPDATE hymns SET
    title = '성령이여 강림하사',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 190;

UPDATE hymns SET
    title = '내가 매일 기쁘게',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 191;

UPDATE hymns SET
    title = '임하소서 임하소서',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 192;

UPDATE hymns SET
    title = '성령의 봄바람 불어오니',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 193;

UPDATE hymns SET
    title = '저 하늘 거룩하신 주여',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 194;

UPDATE hymns SET
    title = '성령이여 우리 찬송 부를 때',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 195;

UPDATE hymns SET
    title = '성령의 은사를',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 196;

UPDATE hymns SET
    title = '은혜가 풍성한 하나님은',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 197;

UPDATE hymns SET
    title = '주 예수 해변서',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 198;

UPDATE hymns SET
    title = '나의 사랑하는 책',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 199;

UPDATE hymns SET
    title = '달고 오묘한 그 말씀',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 200;

UPDATE hymns SET
    title = '참 사람 되신 말씀',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 201;

UPDATE hymns SET
    title = '하나님 아버지 주신 책은',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 202;

UPDATE hymns SET
    title = '하나님의 말씀은',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 203;

UPDATE hymns SET
    title = '주의 말씀 듣고서',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 204;

UPDATE hymns SET
    title = '주 예수 크신 사랑',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 205;

UPDATE hymns SET
    title = '주 예수 귀한 말씀은',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 206;

UPDATE hymns SET
    title = '귀하신 주님 계신 곳',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 207;

UPDATE hymns SET
    title = '내 주의 나라와',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 208;

UPDATE hymns SET
    title = '이 세상 풍파 심하고',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 209;

UPDATE hymns SET
    title = '시온성과 같은 교회',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 210;

UPDATE hymns SET
    title = '값비싼 향유를 주께 드린',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 211;

UPDATE hymns SET
    title = '겸손히 주를 섬길 때',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 212;

UPDATE hymns SET
    title = '나의 생명 드리니',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 213;

UPDATE hymns SET
    title = '나 주의 도움 받고자',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 214;

UPDATE hymns SET
    title = '내 죄 속해 주신 주께',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 215;

UPDATE hymns SET
    title = '성자의 귀한 몸',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 216;

UPDATE hymns SET
    title = '하나님이 말씀하시기를',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 217;

UPDATE hymns SET
    title = '네 맘과 정성을 다하여서',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 218;

UPDATE hymns SET
    title = '주 하나님의 사랑은',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 219;

UPDATE hymns SET
    title = '사랑하는 주님 앞에',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 220;

UPDATE hymns SET
    title = '주 믿는 형제들',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 221;

UPDATE hymns SET
    title = '우리 다시 만날 때까지',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 222;

UPDATE hymns SET
    title = '하나님은 우리들의',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 223;

UPDATE hymns SET
    title = '정한 물로 우리 죄를',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 224;

UPDATE hymns SET
    title = '실로암 샘물가에 핀',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 225;

UPDATE hymns SET
    title = '성령으로 세례 받아',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 226;

UPDATE hymns SET
    title = '주 앞에 성찬 받기 위하여',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 227;

UPDATE hymns SET
    title = '오 나의 주님 친히 뵈오니',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 228;

UPDATE hymns SET
    title = '아무 흠도 없고',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 229;

UPDATE hymns SET
    title = '우리의 참되신 구주시니',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 230;

UPDATE hymns SET
    title = '우리 다 같이 무릎 꿇고',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 231;

UPDATE hymns SET
    title = '유월절 때가 이르러',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 232;

UPDATE hymns SET
    title = '자비로 그 몸 찢기시고',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 233;

UPDATE hymns SET
    title = '구주 예수 그리스도',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 234;

UPDATE hymns SET
    title = '보아라 즐거운 우리 집',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 235;

UPDATE hymns SET
    title = '우리 모든 수고 끝나',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 236;

UPDATE hymns SET
    title = '저 건너편 강 언덕에',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 237;

UPDATE hymns SET
    title = '해 지는 저편',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 238;

UPDATE hymns SET
    title = '저 뵈는 본향 집',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 239;

UPDATE hymns SET
    title = '주가 맡긴 모든 역사',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 240;

UPDATE hymns SET
    title = '아름다운 본향',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 241;

UPDATE hymns SET
    title = '황무지가 장미꽃같이',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 242;

UPDATE hymns SET
    title = '저 요단강 건너편에',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 243;

UPDATE hymns SET
    title = '구원 받은 천국의 성도들',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 244;

UPDATE hymns SET
    title = '저 좋은 낙원 이르니',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 245;

UPDATE hymns SET
    title = '나 가나안 땅 귀한 성에',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 246;

UPDATE hymns SET
    title = '보아라 저 하늘에',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 247;

UPDATE hymns SET
    title = '언약의 주 하나님',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 248;

UPDATE hymns SET
    title = '주 사랑하는 자 다 찬송할 때에',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 249;

UPDATE hymns SET
    title = '구주의 십자가 보혈로',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 250;

UPDATE hymns SET
    title = '놀랍다 주님의 큰 은혜',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 251;

UPDATE hymns SET
    title = '나의 죄를 씻기는',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 252;

UPDATE hymns SET
    title = '그 자비하신 주님',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 253;

UPDATE hymns SET
    title = '내 주의 보혈은',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 254;

UPDATE hymns SET
    title = '너희 죄 흉악하나',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 255;

UPDATE hymns SET
    title = '나의 죄 모두 지신 주님',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 256;

UPDATE hymns SET
    title = '마음에 가득한 의심을 깨치고',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 257;

UPDATE hymns SET
    title = '샘물과 같은 보혈은',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 258;

UPDATE hymns SET
    title = '예수 십자가에 흘린 피로써',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 259;

UPDATE hymns SET
    title = '우리를 죄에서 구하시려',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 260;

UPDATE hymns SET
    title = '이 세상의 모든 죄를',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 261;

UPDATE hymns SET
    title = '날 구원하신 예수님',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 262;

UPDATE hymns SET
    title = '이 세상 험하고',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 263;

UPDATE hymns SET
    title = '정결하게 하는 샘이',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 264;

UPDATE hymns SET
    title = '주 십자가를 지심으로',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 265;

UPDATE hymns SET
    title = '주의 피로 이룬 샘물',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 266;

UPDATE hymns SET
    title = '주의 확실한 약속의 말씀 듣고',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 267;

UPDATE hymns SET
    title = '죄에서 자유를 얻게 함은',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 268;

UPDATE hymns SET
    title = '그 참혹한 십자가에',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 269;

UPDATE hymns SET
    title = '변찮는 주님의 사랑과',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 270;

UPDATE hymns SET
    title = '나와 같은 죄인 위해',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 271;

UPDATE hymns SET
    title = '고통의 멍에 벗으려고',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 272;

UPDATE hymns SET
    title = '나 주를 멀리 떠났다',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 273;

UPDATE hymns SET
    title = '나 행한 것 죄뿐이니',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 274;

UPDATE hymns SET
    title = '날마다 주와 멀어져',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 275;

UPDATE hymns SET
    title = '아버지여 이 죄인을',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 276;

UPDATE hymns SET
    title = '양떼를 떠나서',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 277;

UPDATE hymns SET
    title = '여러 해 동안 주 떠나',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 278;

UPDATE hymns SET
    title = '인애하신 구세주여',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 279;

UPDATE hymns SET
    title = '천부여 의지 없어서',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 280;

UPDATE hymns SET
    title = '요나처럼 순종않고',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 281;

UPDATE hymns SET
    title = '큰 죄에 빠진 날 위해',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 282;

UPDATE hymns SET
    title = '나 속죄함을 받은 후',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 283;

UPDATE hymns SET
    title = '오랫동안 모든 죄 가운데 빠져',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 284;

UPDATE hymns SET
    title = '주의 말씀 받은 그날',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 285;

UPDATE hymns SET
    title = '주 예수님 내 맘에 오사',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 286;

UPDATE hymns SET
    title = '예수 앞에 나오면',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 287;

UPDATE hymns SET
    title = '예수를 나의 구주 삼고',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 288;

UPDATE hymns SET
    title = '주 예수 내 맘에 들어와',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 289;

UPDATE hymns SET
    title = '우리는 주님을 늘 배반하나',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 290;

UPDATE hymns SET
    title = '외롭게 사는 이 그 누군가',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 291;

UPDATE hymns SET
    title = '주 없이 살 수 없네',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 292;

UPDATE hymns SET
    title = '주의 사랑 비칠 때에',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 293;

UPDATE hymns SET
    title = '하나님은 외아들을',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 294;

UPDATE hymns SET
    title = '큰 죄에 빠진 나를',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 295;

UPDATE hymns SET
    title = '죄인 구하시려고',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 296;

UPDATE hymns SET
    title = '양 아흔 아홉 마리는',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 297;

UPDATE hymns SET
    title = '속죄하신 구세주를',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 298;

UPDATE hymns SET
    title = '하나님 사랑은',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 299;

UPDATE hymns SET
    title = '내 맘이 낙심되며',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 300;

UPDATE hymns SET
    title = '지금까지 지내온 것',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 301;

UPDATE hymns SET
    title = '내 주 하나님 넓고 큰 은혜는',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 302;

UPDATE hymns SET
    title = '날 위하여 십자가의',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 303;

UPDATE hymns SET
    title = '그 크신 하나님의 사랑',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 304;

UPDATE hymns SET
    title = '나 같은 죄인 살리신',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 305;

UPDATE hymns SET
    title = '죽을 죄인 살려주신',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 306;

UPDATE hymns SET
    title = '소리 없이 보슬보슬',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 307;

UPDATE hymns SET
    title = '내 평생 살아온 길',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 308;

UPDATE hymns SET
    title = '목마른 내 영혼',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 309;

UPDATE hymns SET
    title = '아 하나님의 은혜로',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 310;

UPDATE hymns SET
    title = '내 너를 위하여',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 311;

UPDATE hymns SET
    title = '너 하나님께 이끌리어',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 312;

UPDATE hymns SET
    title = '내 임금 예수 내 주여',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 313;

UPDATE hymns SET
    title = '내 구주 예수를 더욱 사랑',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 314;

UPDATE hymns SET
    title = '내 주 되신 주를 참 사랑하고',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 315;

UPDATE hymns SET
    title = '주여 나의 생명',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 316;

UPDATE hymns SET
    title = '내 주 예수 주신 은혜',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 317;

UPDATE hymns SET
    title = '순교자의 흘린 피가',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 318;

UPDATE hymns SET
    title = '말씀으로 이 세상을',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 319;

UPDATE hymns SET
    title = '나의 죄를 정케 하사',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 320;

UPDATE hymns SET
    title = '날 대속하신 예수께',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 321;

UPDATE hymns SET
    title = '세상의 헛된 신을 버리고',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 322;

UPDATE hymns SET
    title = '부름 받아 나선 이 몸',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 323;

UPDATE hymns SET
    title = '예수 나를 오라 하네',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 324;

UPDATE hymns SET
    title = '예수가 함께 계시니',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 325;

UPDATE hymns SET
    title = '내 죄를 회개하고',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 326;

UPDATE hymns SET
    title = '주님 주실 화평',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 327;

UPDATE hymns SET
    title = '너 주의 사람아',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 328;

UPDATE hymns SET
    title = '주 날 불러 이르소서',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 329;

UPDATE hymns SET
    title = '어둔 밤 쉬 되리니',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 330;

UPDATE hymns SET
    title = '영광을 받으신 만유의 주여',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 331;

UPDATE hymns SET
    title = '우리는 부지런한',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 332;

UPDATE hymns SET
    title = '충성하라 죽도록',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 333;

UPDATE hymns SET
    title = '위대하신 주를',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 334;

UPDATE hymns SET
    title = '크고 놀라운 평화가',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 335;

UPDATE hymns SET
    title = '환난과 핍박 중에도',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 336;

UPDATE hymns SET
    title = '내 모든 시험 무거운 짐을',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 337;

UPDATE hymns SET
    title = '내 주를 가까이 하게 함은',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 338;

UPDATE hymns SET
    title = '내 주님 지신 십자가',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 339;

UPDATE hymns SET
    title = '어지러운 세상 중에',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 340;

UPDATE hymns SET
    title = '십자가를 내가 지고',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 341;

UPDATE hymns SET
    title = '너 시험을 당해',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 342;

UPDATE hymns SET
    title = '시험 받을 때에',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 343;

UPDATE hymns SET
    title = '믿음으로 가리라',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 344;

UPDATE hymns SET
    title = '캄캄한 밤 사나운 바람 불 때',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 345;

UPDATE hymns SET
    title = '주 예수 우리 구하려',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 346;

UPDATE hymns SET
    title = '허락하신 새 땅에',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 347;

UPDATE hymns SET
    title = '마귀들과 싸울지라',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 348;

UPDATE hymns SET
    title = '나는예수따라가는',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 349;

UPDATE hymns SET
    title = '우리들이 싸울 것은',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 350;

UPDATE hymns SET
    title = '믿는 사람들은 주의 군사니',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 351;

UPDATE hymns SET
    title = '십자가 군병들아',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 352;

UPDATE hymns SET
    title = '십자가 군병 되어서',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 353;

UPDATE hymns SET
    title = '주를 앙모하는 자',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 354;

UPDATE hymns SET
    title = '다같이 일어나',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 355;

UPDATE hymns SET
    title = '주예수이름소리높여',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 356;

UPDATE hymns SET
    title = '주 믿는 사람 일어나',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 357;

UPDATE hymns SET
    title = '주의 진리 위해 십자가 군기',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 358;

UPDATE hymns SET
    title = '천성을 향해 가는 성도들아',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 359;

UPDATE hymns SET
    title = '행군 나팔 소리에',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 360;

UPDATE hymns SET
    title = '기도하는 이 시간',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 361;

UPDATE hymns SET
    title = '주여복을주시기를',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 362;

UPDATE hymns SET
    title = '내가깊은곳에서',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 363;

UPDATE hymns SET
    title = '내 기도하는 그 시간',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 364;

UPDATE hymns SET
    title = '마음속에 근심 있는 사람',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 365;

UPDATE hymns SET
    title = '어두운 내 눈 밝히사',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 366;

UPDATE hymns SET
    title = '인내하게 하소서 주여 우리를',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 367;

UPDATE hymns SET
    title = '주 예수여 은혜를',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 368;

UPDATE hymns SET
    title = '죄짐 맡은 우리 구주',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 369;

UPDATE hymns SET
    title = '주 안에 있는 나에게',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 370;

UPDATE hymns SET
    title = '구주여 광풍이 불어',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 371;

UPDATE hymns SET
    title = '그 누가 나의 괴롬 알며',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 372;

UPDATE hymns SET
    title = '고요한 바다로',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 373;

UPDATE hymns SET
    title = '나의 믿음 약할 때',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 374;

UPDATE hymns SET
    title = '나는 갈 길 모르니',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 375;

UPDATE hymns SET
    title = '나그네와같은내가',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 376;

UPDATE hymns SET
    title = '전능하신 주 하나님',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 377;

UPDATE hymns SET
    title = '내 선한 목자',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 378;

UPDATE hymns SET
    title = '내 갈 길 멀고 밤은 깊은데',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 379;

UPDATE hymns SET
    title = '나의 생명 되신 주',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 380;

UPDATE hymns SET
    title = '나 캄캄한 밤 죄의 길에',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 381;

UPDATE hymns SET
    title = '너 근심 걱정 말아라',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 382;

UPDATE hymns SET
    title = '눈을 들어 산을 보니',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 383;

UPDATE hymns SET
    title = '나의 갈 길 다 가도록',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 384;

UPDATE hymns SET
    title = '못박혀죽으신',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 385;

UPDATE hymns SET
    title = '만세반석 열린곳에',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 386;

UPDATE hymns SET
    title = '멀리 멀리 갔더니',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 387;

UPDATE hymns SET
    title = '비바람이 칠 때와',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 388;

UPDATE hymns SET
    title = '내게로 오라 하신 주님의',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 389;

UPDATE hymns SET
    title = '예수가 거느리시니',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 390;

UPDATE hymns SET
    title = '오 놀라운 구세주',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 391;

UPDATE hymns SET
    title = '주여 어린 사슴이',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 392;

UPDATE hymns SET
    title = '오 신실하신 주',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 393;

UPDATE hymns SET
    title = '이 세상의 친구들',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 394;

UPDATE hymns SET
    title = '자비하신 예수여',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 395;

UPDATE hymns SET
    title = '우리 주님 밤새워',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 396;

UPDATE hymns SET
    title = '주 사랑 안에 살면',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 397;

UPDATE hymns SET
    title = '어둠의 권세에서',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 398;

UPDATE hymns SET
    title = '어린 양들아 두려워 말아라',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 399;

UPDATE hymns SET
    title = '험한 시험 물 속에서',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 400;

UPDATE hymns SET
    title = '주의 곁에 있을 때',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 401;

UPDATE hymns SET
    title = '나의반석 나의 방패',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 402;

UPDATE hymns SET
    title = '영원하신 주님의',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 403;

UPDATE hymns SET
    title = '바다에 놀이 일 때에',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 404;

UPDATE hymns SET
    title = '주의 친절한 팔에 안기세',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 405;

UPDATE hymns SET
    title = '곤한 내 영혼 편히 쉴 곳과',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 406;

UPDATE hymns SET
    title = '구주와 함께 나 죽었으니',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 407;

UPDATE hymns SET
    title = '나 어느 곳에 있든지',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 408;

UPDATE hymns SET
    title = '나의 기쁨은 사람의 주님께',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 409;

UPDATE hymns SET
    title = '내 맘에 한 노래 있어',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 410;

UPDATE hymns SET
    title = '아 내 맘속에',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 411;

UPDATE hymns SET
    title = '내 영혼의 그윽히 깊은 데서',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 412;

UPDATE hymns SET
    title = '내 평생에 가는 길',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 413;

UPDATE hymns SET
    title = '이세상은요란하나',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 414;

UPDATE hymns SET
    title = '십자가 그늘 아래',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 415;

UPDATE hymns SET
    title = '너희 근심 걱정을',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 416;

UPDATE hymns SET
    title = '주 예수 넓은 품에',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 417;

UPDATE hymns SET
    title = '기쁠때나 슬플때나',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 418;

UPDATE hymns SET
    title = '주 날개 밑 내가 편안히 쉬네',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 419;

UPDATE hymns SET
    title = '너 성결키 위해',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 420;

UPDATE hymns SET
    title = '내가 예수 믿고서',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 421;

UPDATE hymns SET
    title = '거룩하게 하소서',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 422;

UPDATE hymns SET
    title = '먹보다도 더 검은',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 423;

UPDATE hymns SET
    title = '아버지여 나의 맘을',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 424;

UPDATE hymns SET
    title = '주님의 뜻을 이루소서',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 425;

UPDATE hymns SET
    title = '이 죄인을 완전케 하시옵고',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 426;

UPDATE hymns SET
    title = '맘 가난한 사람',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 427;

UPDATE hymns SET
    title = '내 영혼에 햇빛 비치니',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 428;

UPDATE hymns SET
    title = '세상 모든 풍파 너를 흔들어',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 429;

UPDATE hymns SET
    title = '주와 같이 길 가는 것',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 430;

UPDATE hymns SET
    title = '주 안에 기쁨있네',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 431;

UPDATE hymns SET
    title = '큰 물결이 설레는 어둔 바다',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 432;

UPDATE hymns SET
    title = '귀하신 주여 날 붙드사',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 433;

UPDATE hymns SET
    title = '귀하신 친구 내게 계시니',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 434;

UPDATE hymns SET
    title = '나의 영원하신 기업',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 435;

UPDATE hymns SET
    title = '나 이제 주님의 새 생명 얻은 몸',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 436;

UPDATE hymns SET
    title = '하늘 보좌 떠나서',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 437;

UPDATE hymns SET
    title = '내 영혼이 은총 입어',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 438;

UPDATE hymns SET
    title = '십자가로 가까이',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 439;

UPDATE hymns SET
    title = '어디든지 예수 나를 이끌면',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 440;

UPDATE hymns SET
    title = '은혜 구한 내게 은혜의 주님',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 441;

UPDATE hymns SET
    title = '저 장미꼿 위에 이슬',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 442;

UPDATE hymns SET
    title = '아침 햇살 비칠때',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 443;

UPDATE hymns SET
    title = '겟세마네 동산에서',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 444;

UPDATE hymns SET
    title = '태산을 넘어 험곡에 가도',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 445;

UPDATE hymns SET
    title = '주 음성 외에는',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 446;

UPDATE hymns SET
    title = '이 세상 끝날까지',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 447;

UPDATE hymns SET
    title = '주님 가신 길을 따라',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 448;

UPDATE hymns SET
    title = '예수 따라가며',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 449;

UPDATE hymns SET
    title = '내 평생 소원 이것뿐',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 450;

UPDATE hymns SET
    title = '예수 영광 버리사',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 451;

UPDATE hymns SET
    title = '내 모든 소원 기도의 제목',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 452;

UPDATE hymns SET
    title = '예수 더 알기 원하네',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 453;

UPDATE hymns SET
    title = '주와 같이 되기를',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 454;

UPDATE hymns SET
    title = '주님의 마음을 본받는 자',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 455;

UPDATE hymns SET
    title = '거친 세상에서 실패하거든',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 456;

UPDATE hymns SET
    title = '겟세마네 동산의',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 457;

UPDATE hymns SET
    title = '너의 마음에 슬픔이 가득할 때',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 458;

UPDATE hymns SET
    title = '누가 주를 따라',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 459;

UPDATE hymns SET
    title = '뜻 없이 무릎 꿇는',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 460;

UPDATE hymns SET
    title = '십자가를 질 수 있나',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 461;

UPDATE hymns SET
    title = '생명 진리 은혜되신',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 462;

UPDATE hymns SET
    title = '신자 되기 원합니다',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 463;

UPDATE hymns SET
    title = '믿음의 새 빛을',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 464;

UPDATE hymns SET
    title = '주 믿는 나 남 위해',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 465;

UPDATE hymns SET
    title = '죽기까지 사랑하신 주',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 466;

UPDATE hymns SET
    title = '높으신 주께서 낮아지심은',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 467;

UPDATE hymns SET
    title = '큰 사랑의 새 계명을',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 468;

UPDATE hymns SET
    title = '내 주 하나님',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 469;

UPDATE hymns SET
    title = '나의 몸이 상하여',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 470;

UPDATE hymns SET
    title = '주여 나의 병든 몸을',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 471;

UPDATE hymns SET
    title = '네 병든 손 내밀리고',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 472;

UPDATE hymns SET
    title = '괴로움과 고통을',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 473;

UPDATE hymns SET
    title = '의원되신 예수님의',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 474;

UPDATE hymns SET
    title = '인류는 하나 되게',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 475;

UPDATE hymns SET
    title = '꽃이피고 새가 우는',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 476;

UPDATE hymns SET
    title = '하나님이 창조하신',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 477;

UPDATE hymns SET
    title = '참 아름다워라',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 478;

UPDATE hymns SET
    title = '괴로운 인생길 가는 몸이',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 479;

UPDATE hymns SET
    title = '천국에서 만나보자',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 480;

UPDATE hymns SET
    title = '때 저물어서 날이 어두니',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 481;

UPDATE hymns SET
    title = '참즐거운노래를',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 482;

UPDATE hymns SET
    title = '구름 같은 이 세상',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 483;

UPDATE hymns SET
    title = '내 맘의 주여 소망되소서',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 484;

UPDATE hymns SET
    title = '세월이 흘러가는데',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 485;

UPDATE hymns SET
    title = '이 세상에 근심된 일이 많고',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 486;

UPDATE hymns SET
    title = '어두움 후에 빛이 오며',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 487;

UPDATE hymns SET
    title = '이 몸의 소망 무언가',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 488;

UPDATE hymns SET
    title = '저 요단강 건너편에',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 489;

UPDATE hymns SET
    title = '주여 지난 밤 내 꿈에',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 490;

UPDATE hymns SET
    title = '저 높은 곳을 향하여',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 491;

UPDATE hymns SET
    title = '잠시 세상에 내가 살면서',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 492;

UPDATE hymns SET
    title = '하늘 가는 밝은 길이',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 493;

UPDATE hymns SET
    title = '만세반석 열리니',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 494;

UPDATE hymns SET
    title = '익은 곡식 거둘 자가',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 495;

UPDATE hymns SET
    title = '새벽부터 우리',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 496;

UPDATE hymns SET
    title = '주 예수 넓은 사랑',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 497;

UPDATE hymns SET
    title = '저 죽어가는 자 다 구원하고',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 498;

UPDATE hymns SET
    title = '흑암에 사는 백성들을 보라',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 499;

UPDATE hymns SET
    title = '물 위에 생명줄 던지어라',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 500;

UPDATE hymns SET
    title = '너 시온아 이 소식 전파하라',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 501;

UPDATE hymns SET
    title = '빛의 사자들이여',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 502;

UPDATE hymns SET
    title = '세상 모두 사랑 없어',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 503;

UPDATE hymns SET
    title = '주님의 명령 전할 사자여',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 504;

UPDATE hymns SET
    title = '온 세상 위하여',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 505;

UPDATE hymns SET
    title = '땅 끝까지 복음을',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 506;

UPDATE hymns SET
    title = '저 북방 얼음 산과',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 507;

UPDATE hymns SET
    title = '우리가 지금은 나그네 되어도',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 508;

UPDATE hymns SET
    title = '기쁜 일이 있어 천국 종 치네',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 509;

UPDATE hymns SET
    title = '하나님의 진리 등대',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 510;

UPDATE hymns SET
    title = '예수 말씀하시기를',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 511;

UPDATE hymns SET
    title = '천성길을 버리고',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 512;

UPDATE hymns SET
    title = '헛된 욕망길을 가며',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 513;

UPDATE hymns SET
    title = '먼동 튼다 일어나라',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 514;

UPDATE hymns SET
    title = '눈을 들어 하늘 보라',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 515;

UPDATE hymns SET
    title = '옳은 길 따르라 의의 길을',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 516;

UPDATE hymns SET
    title = '가난한 자 돌봐주며',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 517;

UPDATE hymns SET
    title = '기쁜 소리 들리니',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 518;

UPDATE hymns SET
    title = '구주께서 부르되',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 519;

UPDATE hymns SET
    title = '듣는 사람마다 복음 전하여',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 520;

UPDATE hymns SET
    title = '구원으로 인도하는',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 521;

UPDATE hymns SET
    title = '웬일인가 내 형제여',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 522;

UPDATE hymns SET
    title = '어둔 죄악 길에서',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 523;

UPDATE hymns SET
    title = '갈 길을 밝히 보이시니',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 524;

UPDATE hymns SET
    title = '돌아와 돌아와',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 525;

UPDATE hymns SET
    title = '목마른 자들아',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 526;

UPDATE hymns SET
    title = '어서 돌아오오',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 527;

UPDATE hymns SET
    title = '예수가 우리를 부르는 소리',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 528;

UPDATE hymns SET
    title = '온유한 주님의 음성',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 529;

UPDATE hymns SET
    title = '주께서 문에 오셔서',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 530;

UPDATE hymns SET
    title = '자비한 주께서 부르시네',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 531;

UPDATE hymns SET
    title = '주께로 한 걸음씩',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 532;

UPDATE hymns SET
    title = '우리 주 십자가',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 533;

UPDATE hymns SET
    title = '주님 찾아 오셨네',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 534;

UPDATE hymns SET
    title = '주 예수 대문 밖에',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 535;

UPDATE hymns SET
    title = '죄짐에 눌린 사람은',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 536;

UPDATE hymns SET
    title = '형제여 지체 말라',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 537;

UPDATE hymns SET
    title = '죄짐을 지고서 곤하거든',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 538;

UPDATE hymns SET
    title = '너 예수께 조용히 나가',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 539;

UPDATE hymns SET
    title = '주의 음성을 내가 들으니',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 540;

UPDATE hymns SET
    title = '꽃이 피는 봄날에만',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 541;

UPDATE hymns SET
    title = '구주 예수 의지함이',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 542;

UPDATE hymns SET
    title = '어려운 일 당할 때',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 543;

UPDATE hymns SET
    title = '울어도 못하네',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 544;

UPDATE hymns SET
    title = '이 눈에 아무 증거 아니 뵈어도',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 545;

UPDATE hymns SET
    title = '주님 약속하신 말씀 위에서',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 546;

UPDATE hymns SET
    title = '나같은 죄인까지도',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 547;

UPDATE hymns SET
    title = '날 구속하신',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 548;

UPDATE hymns SET
    title = '내 주여 뜻대로',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 549;

UPDATE hymns SET
    title = '시온의 영광이 빛나는 아침',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 550;

UPDATE hymns SET
    title = '오늘까지 복과 은혜',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 551;

UPDATE hymns SET
    title = '아침 해가 돋을 때',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 552;

UPDATE hymns SET
    title = '새해 아침 환히 밝았네',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 553;

UPDATE hymns SET
    title = '종소리 크게 울려라',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 554;

UPDATE hymns SET
    title = '우리 주님 모신 가정',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 555;

UPDATE hymns SET
    title = '날마다 주님을 의지하는',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 556;

UPDATE hymns SET
    title = '에덴의 동산처럼',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 557;

UPDATE hymns SET
    title = '미더워라 주의 가정',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 558;

UPDATE hymns SET
    title = '사철에 봄바람 불어 잇고',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 559;

UPDATE hymns SET
    title = '주의 발자취를 따름이',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 560;

UPDATE hymns SET
    title = '예수님의 사랑은',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 561;

UPDATE hymns SET
    title = '예루살렘 아이들',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 562;

UPDATE hymns SET
    title = '예수 사랑하심을',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 563;

UPDATE hymns SET
    title = '예수께서 오실 때에',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 564;

UPDATE hymns SET
    title = '예수께로 가면',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 565;

UPDATE hymns SET
    title = '사랑의 하나님',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 566;

UPDATE hymns SET
    title = '다정하신 목자 예수',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 567;

UPDATE hymns SET
    title = '하나님은 나의 목자시니',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 568;

UPDATE hymns SET
    title = '선한 목자 되신 우리 주',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 569;

UPDATE hymns SET
    title = '주는 나를 기르시는 목자',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 570;

UPDATE hymns SET
    title = '역사속에 보냄받아',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 571;

UPDATE hymns SET
    title = '바다같이 넓은 은혜',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 572;

UPDATE hymns SET
    title = '말씀에 순종하여',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 573;

UPDATE hymns SET
    title = '가슴마다 파도친다',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 574;

UPDATE hymns SET
    title = '주님께 귀한 것 드려',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 575;

UPDATE hymns SET
    title = '하나님의 뜻을따라',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 576;

UPDATE hymns SET
    title = '낳으시고 길러주신',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 577;

UPDATE hymns SET
    title = '언제나 바라봐도',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 578;

UPDATE hymns SET
    title = '어머니의 넓은 사랑',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 579;

UPDATE hymns SET
    title = '삼천리 반도 금수강산',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 580;

UPDATE hymns SET
    title = '주하나님 이 나라를 지켜주시고',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 581;

UPDATE hymns SET
    title = '어둔 밤 마음에 잠겨',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 582;

UPDATE hymns SET
    title = '이 민족에 복음을',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 583;

UPDATE hymns SET
    title = '우리나라 지켜주신',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 584;

UPDATE hymns SET
    title = '내 주는 강한 성이요',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 585;

UPDATE hymns SET
    title = '어느 민족 누구게나',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 586;

UPDATE hymns SET
    title = '감사하는 성도여',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 587;

UPDATE hymns SET
    title = '공중 나는 새를 보라',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 588;

UPDATE hymns SET
    title = '넓은 들에 익은 곡식',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 589;

UPDATE hymns SET
    title = '논밭에 오곡백과',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 590;

UPDATE hymns SET
    title = '저 밭에 농부 나가',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 591;

UPDATE hymns SET
    title = '산마다 불이 탄다 고운 단풍에',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 592;

UPDATE hymns SET
    title = '아름다운 하늘과',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 593;

UPDATE hymns SET
    title = '감사하세 찬양하세',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 594;

UPDATE hymns SET
    title = '나 맡은 본분은',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 595;

UPDATE hymns SET
    title = '영광은 주님 홀로',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 596;

UPDATE hymns SET
    title = '이전에 주님을 내가 몰라',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 597;

UPDATE hymns SET
    title = '천지 주관하는 주님',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 598;

UPDATE hymns SET
    title = '우리의 기도 들어주시옵소서',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 599;

UPDATE hymns SET
    title = '교회의참된터는',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 600;

UPDATE hymns SET
    title = '하나님이 정하시고',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 601;

UPDATE hymns SET
    title = '성부님께 빕니다',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 602;

UPDATE hymns SET
    title = '태초에 하나님이',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 603;

UPDATE hymns SET
    title = '완전한 사랑',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 604;

UPDATE hymns SET
    title = '오늘 모여 찬송함은',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 605;

UPDATE hymns SET
    title = '해보다 더 밝은 저 천국',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 606;

UPDATE hymns SET
    title = '내 본향 가는 길',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 607;

UPDATE hymns SET
    title = '후일에 생명 그칠 때',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 608;

UPDATE hymns SET
    title = '이 세상 살때에',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 609;

UPDATE hymns SET
    title = '고생과 수고가 다 지난 후',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 610;

UPDATE hymns SET
    title = '주님오라 부르시어',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 611;

UPDATE hymns SET
    title = '이땅에서 주를 위해',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 612;

UPDATE hymns SET
    title = '사랑의 주 하나님',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 613;

UPDATE hymns SET
    title = '얼마나 아프셨나',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 614;

UPDATE hymns SET
    title = '그 큰일을 행하신',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 615;

UPDATE hymns SET
    title = '주를 경배하리',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 616;

UPDATE hymns SET
    title = '주님을 찬양합니다',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 617;

UPDATE hymns SET
    title = '나 주님을 사랑합니다',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 618;

UPDATE hymns SET
    title = '놀라운 그 이름',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 619;

UPDATE hymns SET
    title = '여기에 모인 우리',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 620;

UPDATE hymns SET
    title = '찬양하라 내 영혼아',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 621;

UPDATE hymns SET
    title = '거룩한 밤',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 622;

UPDATE hymns SET
    title = '주님의 시간에',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 623;

UPDATE hymns SET
    title = '우리 모두 찬양해',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 624;

UPDATE hymns SET
    title = '거룩 거룩 거룩한 하나님',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 625;

UPDATE hymns SET
    title = '만민들아 다 경배하라',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 626;

UPDATE hymns SET
    title = '할렐루야 할렐루야 다 함께',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 627;

UPDATE hymns SET
    title = '아멘아멘아멘 영광과 존귀를',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 628;

UPDATE hymns SET
    title = '거룩 거룩 거룩',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 629;

UPDATE hymns SET
    title = '진리와 생명 되신 주',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 630;

UPDATE hymns SET
    title = '진리와 생명 되신 주',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 631;

UPDATE hymns SET
    title = '우리 기도를',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 632;

UPDATE hymns SET
    title = '나의 하나님 받으소서',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 633;

UPDATE hymns SET
    title = '모든것이 주께로 부터',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 634;

UPDATE hymns SET
    title = '하늘에 계신(주기도문)',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 635;

UPDATE hymns SET
    title = '하늘에 계신(주기도문)',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 636;

UPDATE hymns SET
    title = '주님 우리의 마음을 여시어',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 637;

UPDATE hymns SET
    title = '모든 것이 주께로부터',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 638;

UPDATE hymns SET
    title = '주 너를 지키시고',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 639;

UPDATE hymns SET
    title = '아멘',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 640;

UPDATE hymns SET
    title = '아멘',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 641;

UPDATE hymns SET
    title = '아멘',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 642;

UPDATE hymns SET
    title = '아멘',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 643;

UPDATE hymns SET
    title = '아멘',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 644;

UPDATE hymns SET
    title = '아멘',
    composer = NULL,
    author = NULL,
    theme = NULL,
    tempo = NULL,
    updated_at = NOW()
WHERE number = 645;

COMMIT;

-- 업데이트 결과 확인
SELECT
    COUNT(*) as total_hymns,
    COUNT(composer) as has_composer,
    COUNT(author) as has_author,
    COUNT(theme) as has_theme,
    COUNT(tempo) as has_tempo
FROM hymns;

-- 샘플 데이터 확인
SELECT number, title, composer, author, theme, tempo
FROM hymns
WHERE number IN (1, 50, 100, 200, 300, 400, 500, 645)
ORDER BY number;
