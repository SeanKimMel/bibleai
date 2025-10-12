-- PostgreSQL 초기화 스크립트
-- 로컬 PostgreSQL에서 postgres 사용자로 실행

-- bibleai 데이터베이스 생성
DROP DATABASE IF EXISTS bibleai;
CREATE DATABASE bibleai;

-- bibleai 사용자 생성 (애플리케이션 연결용)
-- 비밀번호는 .env 파일의 DB_PASSWORD 값과 동일하게 설정해야 함
-- 실행 방법: PGPASSWORD를 .env에서 읽어서 실행
-- source .env && psql -h localhost -U postgres -v db_password="'${DB_PASSWORD}'" -f init.sql
DROP USER IF EXISTS bibleai;
CREATE USER bibleai WITH ENCRYPTED PASSWORD :'db_password';

-- bibleai 데이터베이스에 대한 권한 부여
GRANT ALL PRIVILEGES ON DATABASE bibleai TO bibleai;

-- bibleai 데이터베이스로 연결 (psql에서 \c bibleai 실행 후 아래 스키마 적용)
\c bibleai

-- bibleai 사용자에게 스키마 권한 부여
GRANT ALL ON SCHEMA public TO bibleai;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO bibleai;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO bibleai;

-- 기도문 테이블
CREATE TABLE IF NOT EXISTS prayers (
    id SERIAL PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    content TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- 태그 테이블  
CREATE TABLE IF NOT EXISTS tags (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);

-- 기도문-태그 연결 테이블
CREATE TABLE IF NOT EXISTS prayer_tags (
    prayer_id INTEGER REFERENCES prayers(id) ON DELETE CASCADE,
    tag_id INTEGER REFERENCES tags(id) ON DELETE CASCADE,
    PRIMARY KEY (prayer_id, tag_id)
);

-- 성경 구절 테이블 (기본)
CREATE TABLE IF NOT EXISTS bible_verses (
    id SERIAL PRIMARY KEY,
    book VARCHAR(50) NOT NULL,
    chapter INTEGER NOT NULL,
    verse INTEGER NOT NULL,
    content TEXT NOT NULL,
    version VARCHAR(20) DEFAULT 'KOR'
);

-- 찬송가 테이블 (기본)
CREATE TABLE IF NOT EXISTS hymns (
    id SERIAL PRIMARY KEY,
    number INTEGER UNIQUE NOT NULL,
    title VARCHAR(200) NOT NULL,
    lyrics TEXT,
    theme VARCHAR(100)
);

-- bibleai 사용자에게 새로 생성된 테이블들에 대한 권한 부여
ALTER TABLE prayers OWNER TO bibleai;
ALTER TABLE tags OWNER TO bibleai;
ALTER TABLE prayer_tags OWNER TO bibleai;
ALTER TABLE bible_verses OWNER TO bibleai;
ALTER TABLE hymns OWNER TO bibleai;

-- 시퀀스 소유권도 변경
ALTER SEQUENCE prayers_id_seq OWNER TO bibleai;
ALTER SEQUENCE tags_id_seq OWNER TO bibleai;
ALTER SEQUENCE bible_verses_id_seq OWNER TO bibleai;
ALTER SEQUENCE hymns_id_seq OWNER TO bibleai;

-- 기본 태그 데이터 삽입
INSERT INTO tags (name, description) VALUES 
('감사', '감사와 찬양에 관한 기도'),
('위로', '슬픔과 아픔 중에 위로를 구하는 기도'),
('용기', '용기와 힘을 구하는 기도'),
('회개', '죄를 회개하고 용서를 구하는 기도'),
('치유', '몸과 마음의 치유를 위한 기도'),
('지혜', '지혜와 분별력을 구하는 기도'),
('평강', '마음의 평안을 구하는 기도'),
('가족', '가족을 위한 기도'),
('직장', '직장과 일터에 관한 기도'),
('건강', '건강을 위한 기도')
ON CONFLICT (name) DO NOTHING;

-- 기본 성경 구절 데이터 삽입
INSERT INTO bible_verses (book, chapter, verse, content, version) VALUES 
('요한복음', 3, 16, '하나님이 세상을 이처럼 사랑하사 독생자를 주셨으니 이는 그를 믿는 자마다 멸망하지 않고 영생을 얻게 하려 하심이라', 'KOR'),
('시편', 23, 1, '여호와는 나의 목자시니 내게 부족함이 없으리로다', 'KOR'),
('빌립보서', 4, 13, '내게 능력 주시는 자 안에서 내가 모든 것을 할 수 있느니라', 'KOR'),
('로마서', 8, 28, '우리가 알거니와 하나님을 사랑하는 자 곧 그의 뜻대로 부르심을 입은 자들에게는 모든 것이 합력하여 선을 이루느니라', 'KOR')
ON CONFLICT DO NOTHING;

-- 샘플 기도문 데이터 삽입
INSERT INTO prayers (title, content) VALUES 
('감사의 기도', '하나님 아버지, 오늘도 새로운 하루를 주셔서 감사합니다. 건강과 생명을 주시고, 가족과 함께할 수 있는 시간을 허락하심을 감사드립니다.'),
('위로의 기도', '주님, 지금 마음이 아프고 힘든 시간을 보내고 있습니다. 주님의 사랑과 위로로 이 아픔을 치유해 주시고, 희망을 잃지 않게 도와주소서.'),
('용기의 기도', '하나님, 앞으로 나아가야 할 길이 어렵고 두렵습니다. 주님께서 함께 하심을 믿고 담대히 나아갈 수 있는 용기를 주소서.'),
('회개의 기도', '하나님 아버지, 죄로 인해 주님께 상처를 드린 것을 회개합니다. 저의 잘못을 용서해 주시고, 새로운 마음으로 살아가게 도와주소서.'),
('치유의 기도', '치유의 하나님, 아픈 몸과 마음을 온전히 치유해 주소서. 주님의 능력으로 건강을 회복하게 하시고, 고통에서 벗어나게 해주소서.'),
('지혜의 기도', '지혜의 근원이신 하나님, 올바른 판단과 분별력을 주소서. 주님의 뜻을 깨닫고 그 길로 행할 수 있는 지혜를 허락해 주소서.'),
('평강의 기도', '평강의 왕 예수님, 불안하고 염려되는 마음에 주님의 평안을 부어주소서. 세상이 줄 수 없는 참된 평안을 주시옵소서.'),
('가족을 위한 기도', '하나님, 저희 가족을 지켜주시고 보호해 주소서. 가족 모두가 건강하고 화목하며, 주님 안에서 하나 되게 해주소서.'),
('직장을 위한 기도', '일터의 주인이신 하나님, 오늘도 맡겨주신 일을 성실히 감당할 수 있게 도와주소서. 동료들과의 관계도 좋게 하여 주소서.'),
('건강을 위한 기도', '생명의 주관자이신 하나님, 몸과 마음이 건강하게 하시고, 질병으로부터 보호해 주소서. 건강한 삶으로 주님께 영광 돌리게 하소서.')
ON CONFLICT DO NOTHING;

-- 기도문과 태그 연결 (샘플)
INSERT INTO prayer_tags (prayer_id, tag_id) VALUES 
(1, 1), -- 감사의 기도 - 감사 태그
(2, 2), -- 위로의 기도 - 위로 태그
(3, 3), -- 용기의 기도 - 용기 태그
(4, 4), -- 회개의 기도 - 회개 태그
(5, 5), -- 치유의 기도 - 치유 태그
(6, 6), -- 지혜의 기도 - 지혜 태그
(7, 7), -- 평강의 기도 - 평강 태그
(8, 8), -- 가족을 위한 기도 - 가족 태그
(9, 9), -- 직장을 위한 기도 - 직장 태그
(10, 10) -- 건강을 위한 기도 - 건강 태그
ON CONFLICT DO NOTHING;

-- 최종 권한 확인
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO bibleai;

SELECT 'Database initialization completed successfully!' as status;