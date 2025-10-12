-- 신찬송가 번호 매핑 업데이트
-- 기존 통합찬송가 번호를 신찬송가 번호로 매핑

UPDATE hymns SET new_hymn_number = 1 WHERE number = 1;     -- 만복의 근원 하나님
UPDATE hymns SET new_hymn_number = 2 WHERE number = 2;     -- 찬양 성부 성자 성령
UPDATE hymns SET new_hymn_number = 3 WHERE number = 3;     -- 성부 성자와 성령
UPDATE hymns SET new_hymn_number = 4 WHERE number = 4;     -- 성부 성자와 성령
UPDATE hymns SET new_hymn_number = 5 WHERE number = 5;     -- 이 천지간 만물들아
UPDATE hymns SET new_hymn_number = 6 WHERE number = 6;     -- 목소리 높여서
UPDATE hymns SET new_hymn_number = 7 WHERE number = 7;     -- 성부 성자 성령
UPDATE hymns SET new_hymn_number = 8 WHERE number = 8;     -- 거룩 거룩 거룩 전능하신 주님
UPDATE hymns SET new_hymn_number = 30 WHERE number = 23;   -- 만세반석 열리니
UPDATE hymns SET new_hymn_number = 32 WHERE number = 25;   -- 면류관을 벗어서
UPDATE hymns SET new_hymn_number = 40 WHERE number = 31;   -- 찬송하는 소리 있어
UPDATE hymns SET new_hymn_number = 50 WHERE number = 40;   -- 이 몸의 소망 무엇인가
UPDATE hymns SET new_hymn_number = 65 WHERE number = 52;   -- 구주여 광풍이 일어
UPDATE hymns SET new_hymn_number = 75 WHERE number = 60;   -- 지금까지 지내온 것
UPDATE hymns SET new_hymn_number = 120 WHERE number = 95;  -- 나의 기도하는 그 시간
UPDATE hymns SET new_hymn_number = 140 WHERE number = 111; -- 값비싼 향유를 주께 드린
UPDATE hymns SET new_hymn_number = 109 WHERE number = 123; -- 고요한 밤 거룩한 밤
UPDATE hymns SET new_hymn_number = 165 WHERE number = 132; -- 모든 족속이
UPDATE hymns SET new_hymn_number = 150 WHERE number = 150; -- 갈보리 산 위에
UPDATE hymns SET new_hymn_number = 200 WHERE number = 167; -- 주 품에 품으소서
UPDATE hymns SET new_hymn_number = 220 WHERE number = 190; -- 주를 앙모하는 자
UPDATE hymns SET new_hymn_number = 234 WHERE number = 234; -- 나의 사랑하는 책
UPDATE hymns SET new_hymn_number = 280 WHERE number = 246; -- 나 가나안 땅 귀한 성에
UPDATE hymns SET new_hymn_number = 320 WHERE number = 289; -- 예수가 우리를 부르는 소리
UPDATE hymns SET new_hymn_number = 305 WHERE number = 305; -- 나 같은 죄인 살리신
UPDATE hymns SET new_hymn_number = 310 WHERE number = 310; -- 아 하나님의 은혜로
UPDATE hymns SET new_hymn_number = 420 WHERE number = 447; -- 오 신실하신 주
UPDATE hymns SET new_hymn_number = 480 WHERE number = 488; -- 주님의 뜻을 이루소서
UPDATE hymns SET new_hymn_number = 500 WHERE number = 505; -- 온 천하 만물 우러러

-- 신찬송가 번호에 인덱스 추가
CREATE INDEX idx_hymns_new_number ON hymns(new_hymn_number);