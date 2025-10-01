-- 성경 데이터 스키마 확장 (002번 마이그레이션)

-- bible_verses 테이블에 새 컬럼 추가
ALTER TABLE bible_verses ADD COLUMN IF NOT EXISTS book_id VARCHAR(10);
ALTER TABLE bible_verses ADD COLUMN IF NOT EXISTS testament VARCHAR(10); -- 'old' or 'new'  
ALTER TABLE bible_verses ADD COLUMN IF NOT EXISTS book_name_korean VARCHAR(50);

-- 성능을 위한 인덱스 추가
CREATE INDEX IF NOT EXISTS idx_bible_verses_book_id ON bible_verses(book_id);
CREATE INDEX IF NOT EXISTS idx_bible_verses_testament ON bible_verses(testament);
CREATE INDEX IF NOT EXISTS idx_bible_verses_book_chapter ON bible_verses(book, chapter);
CREATE INDEX IF NOT EXISTS idx_bible_verses_content_search ON bible_verses USING gin(to_tsvector('korean', content));

-- 찬송가 테이블 확장
ALTER TABLE hymns ADD COLUMN IF NOT EXISTS composer VARCHAR(100);
ALTER TABLE hymns ADD COLUMN IF NOT EXISTS author VARCHAR(100);
ALTER TABLE hymns ADD COLUMN IF NOT EXISTS year INTEGER;
ALTER TABLE hymns ADD COLUMN IF NOT EXISTS tune_name VARCHAR(100);
ALTER TABLE hymns ADD COLUMN IF NOT EXISTS category VARCHAR(50);
ALTER TABLE hymns ADD COLUMN IF NOT EXISTS tags TEXT[]; -- PostgreSQL 배열 타입

-- 찬송가 인덱스 추가
CREATE INDEX IF NOT EXISTS idx_hymns_category ON hymns(category);
CREATE INDEX IF NOT EXISTS idx_hymns_year ON hymns(year);
CREATE INDEX IF NOT EXISTS idx_hymns_title_search ON hymns USING gin(to_tsvector('korean', title));
CREATE INDEX IF NOT EXISTS idx_hymns_lyrics_search ON hymns USING gin(to_tsvector('korean', lyrics));

-- 데이터 관리용 테이블 생성
CREATE TABLE IF NOT EXISTS data_import_logs (
    id SERIAL PRIMARY KEY,
    import_type VARCHAR(50) NOT NULL, -- 'bible', 'hymns', 'prayers'
    status VARCHAR(20) NOT NULL, -- 'running', 'completed', 'failed'
    started_at TIMESTAMP DEFAULT NOW(),
    completed_at TIMESTAMP,
    total_records INTEGER DEFAULT 0,
    imported_records INTEGER DEFAULT 0,
    error_count INTEGER DEFAULT 0,
    error_details TEXT,
    created_by VARCHAR(100) DEFAULT 'system'
);

-- 인덱스
CREATE INDEX IF NOT EXISTS idx_import_logs_type ON data_import_logs(import_type);
CREATE INDEX IF NOT EXISTS idx_import_logs_status ON data_import_logs(status);
CREATE INDEX IF NOT EXISTS idx_import_logs_started ON data_import_logs(started_at);

-- 사용자 즐겨찾기 테이블 (향후 사용)
CREATE TABLE IF NOT EXISTS user_favorites (
    id SERIAL PRIMARY KEY,
    user_session VARCHAR(255), -- 세션 기반 (로그인 기능 없으므로)
    content_type VARCHAR(20) NOT NULL, -- 'prayer', 'bible_verse', 'hymn'
    content_id INTEGER NOT NULL,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_favorites_session ON user_favorites(user_session);
CREATE INDEX IF NOT EXISTS idx_favorites_type ON user_favorites(content_type);
CREATE INDEX IF NOT EXISTS idx_favorites_content ON user_favorites(content_type, content_id);

-- 검색 통계 테이블 (향후 분석용)
CREATE TABLE IF NOT EXISTS search_stats (
    id SERIAL PRIMARY KEY,
    search_type VARCHAR(20) NOT NULL, -- 'prayer', 'bible', 'hymn'  
    search_query TEXT NOT NULL,
    result_count INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT NOW(),
    ip_address INET,
    user_agent TEXT
);

CREATE INDEX IF NOT EXISTS idx_search_stats_type ON search_stats(search_type);
CREATE INDEX IF NOT EXISTS idx_search_stats_created ON search_stats(created_at);

-- 성경책 정보 테이블 (메타데이터)
CREATE TABLE IF NOT EXISTS bible_books (
    id SERIAL PRIMARY KEY,
    book_id VARCHAR(10) UNIQUE NOT NULL,
    book_name VARCHAR(50) NOT NULL,
    book_name_english VARCHAR(50),
    testament VARCHAR(10) NOT NULL, -- 'old', 'new'
    book_order INTEGER NOT NULL, -- 1-66
    total_chapters INTEGER NOT NULL,
    created_at TIMESTAMP DEFAULT NOW()
);

-- 기본 성경책 정보 삽입 (구약 39권 + 신약 27권)
INSERT INTO bible_books (book_id, book_name, book_name_english, testament, book_order, total_chapters) VALUES
-- 구약
('gen', '창세기', 'Genesis', 'old', 1, 50),
('exo', '출애굽기', 'Exodus', 'old', 2, 40),
('lev', '레위기', 'Leviticus', 'old', 3, 27),
('num', '민수기', 'Numbers', 'old', 4, 36),
('deu', '신명기', 'Deuteronomy', 'old', 5, 34),
('jos', '여호수아', 'Joshua', 'old', 6, 24),
('jdg', '사사기', 'Judges', 'old', 7, 21),
('rut', '룻기', 'Ruth', 'old', 8, 4),
('1sa', '사무엘상', '1 Samuel', 'old', 9, 31),
('2sa', '사무엘하', '2 Samuel', 'old', 10, 24),
('1ki', '열왕기상', '1 Kings', 'old', 11, 22),
('2ki', '열왕기하', '2 Kings', 'old', 12, 25),
('1ch', '역대상', '1 Chronicles', 'old', 13, 29),
('2ch', '역대하', '2 Chronicles', 'old', 14, 36),
('ezr', '에스라', 'Ezra', 'old', 15, 10),
('neh', '느헤미야', 'Nehemiah', 'old', 16, 13),
('est', '에스더', 'Esther', 'old', 17, 10),
('job', '욥기', 'Job', 'old', 18, 42),
('psa', '시편', 'Psalms', 'old', 19, 150),
('pro', '잠언', 'Proverbs', 'old', 20, 31),
('ecc', '전도서', 'Ecclesiastes', 'old', 21, 12),
('sol', '아가', 'Song of Solomon', 'old', 22, 8),
('isa', '이사야', 'Isaiah', 'old', 23, 66),
('jer', '예레미야', 'Jeremiah', 'old', 24, 52),
('lam', '예레미야애가', 'Lamentations', 'old', 25, 5),
('eze', '에스겔', 'Ezekiel', 'old', 26, 48),
('dan', '다니엘', 'Daniel', 'old', 27, 12),
('hos', '호세아', 'Hosea', 'old', 28, 14),
('joe', '요엘', 'Joel', 'old', 29, 3),
('amo', '아모스', 'Amos', 'old', 30, 9),
('oba', '오바댜', 'Obadiah', 'old', 31, 1),
('jon', '요나', 'Jonah', 'old', 32, 4),
('mic', '미가', 'Micah', 'old', 33, 7),
('nah', '나훔', 'Nahum', 'old', 34, 3),
('hab', '하박국', 'Habakkuk', 'old', 35, 3),
('zep', '스바냐', 'Zephaniah', 'old', 36, 3),
('hag', '학개', 'Haggai', 'old', 37, 2),
('zec', '스가랴', 'Zechariah', 'old', 38, 14),
('mal', '말라기', 'Malachi', 'old', 39, 4),
-- 신약
('mat', '마태복음', 'Matthew', 'new', 40, 28),
('mar', '마가복음', 'Mark', 'new', 41, 16),
('luk', '누가복음', 'Luke', 'new', 42, 24),
('joh', '요한복음', 'John', 'new', 43, 21),
('act', '사도행전', 'Acts', 'new', 44, 28),
('rom', '로마서', 'Romans', 'new', 45, 16),
('1co', '고린도전서', '1 Corinthians', 'new', 46, 16),
('2co', '고린도후서', '2 Corinthians', 'new', 47, 13),
('gal', '갈라디아서', 'Galatians', 'new', 48, 6),
('eph', '에베소서', 'Ephesians', 'new', 49, 6),
('phi', '빌립보서', 'Philippians', 'new', 50, 4),
('col', '골로새서', 'Colossians', 'new', 51, 4),
('1th', '데살로니가전서', '1 Thessalonians', 'new', 52, 5),
('2th', '데살로니가후서', '2 Thessalonians', 'new', 53, 3),
('1ti', '디모데전서', '1 Timothy', 'new', 54, 6),
('2ti', '디모데후서', '2 Timothy', 'new', 55, 4),
('tit', '디도서', 'Titus', 'new', 56, 3),
('phm', '빌레몬서', 'Philemon', 'new', 57, 1),
('heb', '히브리서', 'Hebrews', 'new', 58, 13),
('jam', '야고보서', 'James', 'new', 59, 5),
('1pe', '베드로전서', '1 Peter', 'new', 60, 5),
('2pe', '베드로후서', '2 Peter', 'new', 61, 3),
('1jo', '요한일서', '1 John', 'new', 62, 5),
('2jo', '요한이서', '2 John', 'new', 63, 1),
('3jo', '요한삼서', '3 John', 'new', 64, 1),
('jud', '유다서', 'Jude', 'new', 65, 1),
('rev', '요한계시록', 'Revelation', 'new', 66, 22)
ON CONFLICT (book_id) DO NOTHING;

-- 성경책 인덱스
CREATE INDEX IF NOT EXISTS idx_bible_books_testament ON bible_books(testament);
CREATE INDEX IF NOT EXISTS idx_bible_books_order ON bible_books(book_order);