-- 성경책 book_id 매핑 수정 스크립트
-- GitHub 데이터의 실제 book_id와 한국어 이름을 매핑

-- 기존 데이터 삭제
DELETE FROM bible_books;

-- 실제 GitHub 데이터와 일치하는 book_id로 성경책 정보 삽입
INSERT INTO bible_books (book_id, book_name, book_name_english, testament, book_order, total_chapters) VALUES
-- 구약 39권 (GitHub 데이터 기준)
('gn', '창세기', 'Genesis', 'old', 1, 50),
('ex', '출애굽기', 'Exodus', 'old', 2, 40),
('lv', '레위기', 'Leviticus', 'old', 3, 27),
('nm', '민수기', 'Numbers', 'old', 4, 36),
('dt', '신명기', 'Deuteronomy', 'old', 5, 34),
('js', '여호수아', 'Joshua', 'old', 6, 24),
('jdg', '사사기', 'Judges', 'old', 7, 21),  -- jdg는 동일
('rt', '룻기', 'Ruth', 'old', 8, 4),
('1sm', '사무엘상', '1 Samuel', 'old', 9, 31),
('2sm', '사무엘하', '2 Samuel', 'old', 10, 24),
('1kgs', '열왕기상', '1 Kings', 'old', 11, 22),
('2kgs', '열왕기하', '2 Kings', 'old', 12, 25),
('1ch', '역대상', '1 Chronicles', 'old', 13, 29),
('2ch', '역대하', '2 Chronicles', 'old', 14, 36),
('ezr', '에스라', 'Ezra', 'old', 15, 10),
('ne', '느헤미야', 'Nehemiah', 'old', 16, 13),
('et', '에스더', 'Esther', 'old', 17, 10),
('job', '욥기', 'Job', 'old', 18, 42),
('ps', '시편', 'Psalms', 'old', 19, 150),
('prv', '잠언', 'Proverbs', 'old', 20, 31),
('ec', '전도서', 'Ecclesiastes', 'old', 21, 12),
('so', '아가', 'Song of Solomon', 'old', 22, 8),
('is', '이사야', 'Isaiah', 'old', 23, 66),
('jr', '예레미야', 'Jeremiah', 'old', 24, 52),
('lm', '예레미야애가', 'Lamentations', 'old', 25, 5),
('ez', '에스겔', 'Ezekiel', 'old', 26, 48),
('dn', '다니엘', 'Daniel', 'old', 27, 12),
('ho', '호세아', 'Hosea', 'old', 28, 14),
('jl', '요엘', 'Joel', 'old', 29, 3),
('am', '아모스', 'Amos', 'old', 30, 9),
('ob', '오바댜', 'Obadiah', 'old', 31, 1),
('jn', '요나', 'Jonah', 'old', 32, 4),
('mi', '미가', 'Micah', 'old', 33, 7),
('na', '나훔', 'Nahum', 'old', 34, 3),
('hk', '하박국', 'Habakkuk', 'old', 35, 3),
('zp', '스바냐', 'Zephaniah', 'old', 36, 3),
('hg', '학개', 'Haggai', 'old', 37, 2),
('zc', '스가랴', 'Zechariah', 'old', 38, 14),
('ml', '말라기', 'Malachi', 'old', 39, 4),

-- 신약 27권 (GitHub 데이터 기준)
('mt', '마태복음', 'Matthew', 'new', 40, 28),
('mk', '마가복음', 'Mark', 'new', 41, 16),
('lk', '누가복음', 'Luke', 'new', 42, 24),
('jo', '요한복음', 'John', 'new', 43, 21),
('act', '사도행전', 'Acts', 'new', 44, 28),
('rm', '로마서', 'Romans', 'new', 45, 16),
('1co', '고린도전서', '1 Corinthians', 'new', 46, 16),
('2co', '고린도후서', '2 Corinthians', 'new', 47, 13),
('gl', '갈라디아서', 'Galatians', 'new', 48, 6),
('eph', '에베소서', 'Ephesians', 'new', 49, 6),
('ph', '빌립보서', 'Philippians', 'new', 50, 4),
('cl', '골로새서', 'Colossians', 'new', 51, 4),
('1ts', '데살로니가전서', '1 Thessalonians', 'new', 52, 5),
('2ts', '데살로니가후서', '2 Thessalonians', 'new', 53, 3),
('1tm', '디모데전서', '1 Timothy', 'new', 54, 6),
('2tm', '디모데후서', '2 Timothy', 'new', 55, 4),
('tt', '디도서', 'Titus', 'new', 56, 3),
('phm', '빌레몬서', 'Philemon', 'new', 57, 1),
('hb', '히브리서', 'Hebrews', 'new', 58, 13),
('jm', '야고보서', 'James', 'new', 59, 5),
('1pe', '베드로전서', '1 Peter', 'new', 60, 5),
('2pe', '베드로후서', '2 Peter', 'new', 61, 3),
('1jo', '요한일서', '1 John', 'new', 62, 5),
('2jo', '요한이서', '2 John', 'new', 63, 1),
('3jo', '요한삼서', '3 John', 'new', 64, 1),
('jd', '유다서', 'Jude', 'new', 65, 1),
('re', '요한계시록', 'Revelation', 'new', 66, 22);

-- 잘못된 위치에 있는 유다서 수정 (구약에서 신약으로)
UPDATE bible_verses SET testament = 'new', book_name_korean = '유다서' WHERE book_id = 'jud';
-- jud를 jd로 변경하기 위한 임시 업데이트 (필요한 경우)
UPDATE bible_verses SET book_id = 'jd' WHERE book_id = 'jud';