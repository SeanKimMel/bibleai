-- PostgreSQL 수동 초기화 스크립트
-- 사용법: sudo -u postgres psql -f manual-init.sql

-- 현재 사용자를 PostgreSQL 사용자로 생성
CREATE USER dosro SUPERUSER;

-- bibleai 데이터베이스 및 사용자 생성
DROP DATABASE IF EXISTS bibleai;
DROP USER IF EXISTS bibleai;

CREATE DATABASE bibleai;
CREATE USER bibleai WITH ENCRYPTED PASSWORD 'bibleai123';
GRANT ALL PRIVILEGES ON DATABASE bibleai TO bibleai;

-- bibleai 데이터베이스로 전환하여 테이블 생성
\c bibleai

-- 스키마 권한 부여
GRANT ALL ON SCHEMA public TO bibleai;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO bibleai;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO bibleai;

-- 테이블 생성
CREATE TABLE prayers (
    id SERIAL PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    content TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE tags (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE prayer_tags (
    prayer_id INTEGER REFERENCES prayers(id) ON DELETE CASCADE,
    tag_id INTEGER REFERENCES tags(id) ON DELETE CASCADE,
    PRIMARY KEY (prayer_id, tag_id)
);

CREATE TABLE bible_verses (
    id SERIAL PRIMARY KEY,
    book VARCHAR(50) NOT NULL,
    chapter INTEGER NOT NULL,
    verse INTEGER NOT NULL,
    content TEXT NOT NULL,
    version VARCHAR(20) DEFAULT 'KOR'
);

CREATE TABLE hymns (
    id SERIAL PRIMARY KEY,
    number INTEGER UNIQUE NOT NULL,
    title VARCHAR(200) NOT NULL,
    lyrics TEXT,
    theme VARCHAR(100)
);

-- 테이블 소유권을 bibleai로 변경
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

-- 기본 데이터 입력
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
('건강', '건강을 위한 기도');

INSERT INTO bible_verses (book, chapter, verse, content, version) VALUES 
('요한복음', 3, 16, '하나님이 세상을 이처럼 사랑하사 독생자를 주셨으니 이는 그를 믿는 자마다 멸망하지 않고 영생을 얻게 하려 하심이라', 'KOR'),
('시편', 23, 1, '여호와는 나의 목자시니 내게 부족함이 없으리로다', 'KOR'),
('빌립보서', 4, 13, '내게 능력 주시는 자 안에서 내가 모든 것을 할 수 있느니라', 'KOR'),
('로마서', 8, 28, '우리가 알거니와 하나님을 사랑하는 자 곧 그의 뜻대로 부르심을 입은 자들에게는 모든 것이 합력하여 선을 이루느니라', 'KOR');

INSERT INTO prayers (title, content) VALUES 
('감사의 기도', '하나님 아버지, 오늘도 새로운 하루를 주셔서 감사합니다. 건강과 생명을 주시고, 가족과 함께할 수 있는 시간을 허락하심을 감사드립니다.'),
('위로의 기도', '주님, 지금 마음이 아프고 힘든 시간을 보내고 있습니다. 주님의 사랑과 위로로 이 아픔을 치유해 주시고, 희망을 잃지 않게 도와주소서.'),
('용기의 기도', '하나님, 앞으로 나아가야 할 길이 어렵고 두렵습니다. 주님께서 함께 하심을 믿고 담대히 나아갈 수 있는 용기를 주소서.'),
('회개의 기도', '하나님 아버지, 죄로 인해 주님께 상처를 드린 것을 회개합니다. 저의 잘못을 용서해 주시고, 새로운 마음으로 살아가게 도와주소서.'),
('치유의 기도', '치유의 하나님, 아픈 몸과 마음을 온전히 치유해 주소서. 주님의 능력으로 건강을 회복하게 하시고, 고통에서 벗어나게 해주소서.');

INSERT INTO prayer_tags (prayer_id, tag_id) VALUES 
(1, 1), (2, 2), (3, 3), (4, 4), (5, 5);

SELECT 'PostgreSQL 초기화가 완료되었습니다!' as message;