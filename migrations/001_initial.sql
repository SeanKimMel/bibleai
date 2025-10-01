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