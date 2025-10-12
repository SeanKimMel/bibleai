-- 기도문과 태그 연결 데이터
-- 각 기도문을 적절한 태그들과 연결 (일부는 2개 태그 조합)

BEGIN;

-- 기존 prayer_tags 데이터 삭제
DELETE FROM prayer_tags;

-- 기도문 ID와 태그 연결 (prayer_data.sql 실행 후 사용)
-- 감사 태그 기도문들 (1-3번)
INSERT INTO prayer_tags (prayer_id, tag_id) VALUES 
(1, 1),   -- 오늘 하루를 감사하는 기도 - 감사
(2, 1),   -- 가족에게 감사하는 기도 - 감사  
(2, 8),   -- 가족에게 감사하는 기도 - 가족
(3, 1);   -- 모든 것에 감사하는 기도 - 감사

-- 위로 태그 기도문들 (4-7번)
INSERT INTO prayer_tags (prayer_id, tag_id) VALUES 
(4, 2),   -- 슬픔 중에 위로를 구하는 기도 - 위로
(5, 2),   -- 상처받은 마음을 위한 기도 - 위로
(5, 5),   -- 상처받은 마음을 위한 기도 - 치유
(6, 2),   -- 외로움 중에 위로받는 기도 - 위로
(7, 2),   -- 실망과 좌절 중의 위로기도 - 위로
(7, 3);   -- 실망과 좌절 중의 위로기도 - 용기

-- 용기 태그 기도문들 (8-10번)
INSERT INTO prayer_tags (prayer_id, tag_id) VALUES 
(8, 3),   -- 새로운 시작을 위한 용기의 기도 - 용기
(9, 3),   -- 어려운 결정을 위한 용기의 기도 - 용기
(9, 6),   -- 어려운 결정을 위한 용기의 기도 - 지혜
(10, 3);  -- 두려움을 이기는 용기의 기도 - 용기

-- 회개 태그 기도문들 (11-13번)
INSERT INTO prayer_tags (prayer_id, tag_id) VALUES 
(11, 4),  -- 죄를 회개하는 기도 - 회개
(12, 4),  -- 교만을 회개하는 기도 - 회개
(13, 4);  -- 용서를 구하는 회개의 기도 - 회개

-- 치유 태그 기도문들 (14-17번)
INSERT INTO prayer_tags (prayer_id, tag_id) VALUES 
(14, 5),  -- 몸의 치유를 위한 기도 - 치유
(14, 10), -- 몸의 치유를 위한 기도 - 건강
(15, 5),  -- 마음의 치유를 위한 기도 - 치유
(15, 2),  -- 마음의 치유를 위한 기도 - 위로
(16, 5),  -- 관계의 치유를 위한 기도 - 치유
(17, 5);  -- 영혼의 치유를 위한 기도 - 치유

-- 지혜 태그 기도문들 (18-20번)
INSERT INTO prayer_tags (prayer_id, tag_id) VALUES 
(18, 6),  -- 인생의 지혜를 구하는 기도 - 지혜
(19, 6),  -- 일과 학업의 지혜를 구하는 기도 - 지혜
(19, 9),  -- 일과 학업의 지혜를 구하는 기도 - 직장
(20, 6);  -- 관계에서의 지혜를 구하는 기도 - 지혜

-- 평강 태그 기도문들 (21-23번)
INSERT INTO prayer_tags (prayer_id, tag_id) VALUES 
(21, 7),  -- 마음의 평안을 구하는 기도 - 평강
(22, 7),  -- 갈등 중에 평화를 구하는 기도 - 평강
(23, 7);  -- 내적 평안을 위한 기도 - 평강

-- 가족 태그 기도문들 (24-27번)
INSERT INTO prayer_tags (prayer_id, tag_id) VALUES 
(24, 8),  -- 가족의 화목을 위한 기도 - 가족
(25, 8),  -- 부모님을 위한 기도 - 가족
(25, 1),  -- 부모님을 위한 기도 - 감사
(26, 8),  -- 자녀들을 위한 기도 - 가족
(27, 8),  -- 가족의 건강을 위한 기도 - 가족
(27, 10); -- 가족의 건강을 위한 기도 - 건강

-- 직장 태그 기도문들 (28-30번)
INSERT INTO prayer_tags (prayer_id, tag_id) VALUES 
(28, 9),  -- 직장에서의 성실함을 위한 기도 - 직장
(29, 9),  -- 직장 동료와의 관계를 위한 기도 - 직장
(30, 9),  -- 직장에서의 지혜를 위한 기도 - 직장
(30, 6);  -- 직장에서의 지혜를 위한 기도 - 지혜

-- 건강 태그 기도문들 (31-33번)
INSERT INTO prayer_tags (prayer_id, tag_id) VALUES 
(31, 10), -- 몸의 건강을 위한 기도 - 건강
(32, 10), -- 마음의 건강을 위한 기도 - 건강
(32, 7),  -- 마음의 건강을 위한 기도 - 평강
(33, 10); -- 영적 건강을 위한 기도 - 건강

COMMIT;

-- 생성된 데이터 확인
SELECT 
    p.id,
    p.title,
    STRING_AGG(t.name, ', ' ORDER BY t.name) as tags
FROM prayers p
JOIN prayer_tags pt ON p.id = pt.prayer_id
JOIN tags t ON pt.tag_id = t.id
GROUP BY p.id, p.title
ORDER BY p.id;