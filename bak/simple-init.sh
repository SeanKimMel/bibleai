#!/bin/bash

# 간단한 PostgreSQL 초기화 스크립트
echo "🔧 PostgreSQL 초기화를 시작합니다..."

# PostgreSQL 서비스 확인
if ! pg_isready > /dev/null 2>&1; then
    echo "❌ PostgreSQL 서비스가 실행되지 않았습니다."
    exit 1
fi

echo "✅ PostgreSQL 서비스 확인됨"

# 현재 사용자로 접속 시도 (peer 인증)
echo "🔑 현재 사용자로 PostgreSQL 접속을 시도합니다..."

# 먼저 데이터베이스가 존재하는지 확인
DB_EXISTS=$(psql -lqt | cut -d \| -f 1 | grep -qw bibleai && echo "yes" || echo "no")

if [ "$DB_EXISTS" = "yes" ]; then
    echo "✅ bibleai 데이터베이스가 이미 존재합니다."
else
    echo "📝 bibleai 데이터베이스를 생성합니다..."
    createdb bibleai 2>/dev/null || {
        echo "❌ 데이터베이스 생성 실패. 수동으로 생성하세요:"
        echo "  sudo -u postgres createdb bibleai"
        echo "  sudo -u postgres createuser bibleai"
        exit 1
    }
fi

# 사용자 확인 및 생성
echo "👤 bibleai 사용자를 확인합니다..."
USER_EXISTS=$(psql -t -c "SELECT 1 FROM pg_roles WHERE rolname='bibleai'" 2>/dev/null | grep -q 1 && echo "yes" || echo "no")

if [ "$USER_EXISTS" = "no" ]; then
    echo "📝 bibleai 사용자를 생성합니다..."
    createuser bibleai 2>/dev/null || {
        echo "❌ 사용자 생성 실패"
        exit 1
    }
fi

# 테이블 생성
echo "📋 테이블을 생성합니다..."
psql -d bibleai << 'EOF'
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

-- 성경 구절 테이블
CREATE TABLE IF NOT EXISTS bible_verses (
    id SERIAL PRIMARY KEY,
    book VARCHAR(50) NOT NULL,
    chapter INTEGER NOT NULL,
    verse INTEGER NOT NULL,
    content TEXT NOT NULL,
    version VARCHAR(20) DEFAULT 'KOR'
);

-- 찬송가 테이블
CREATE TABLE IF NOT EXISTS hymns (
    id SERIAL PRIMARY KEY,
    number INTEGER UNIQUE NOT NULL,
    title VARCHAR(200) NOT NULL,
    lyrics TEXT,
    theme VARCHAR(100)
);

-- 기본 태그 데이터
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

-- 기본 성경 구절
INSERT INTO bible_verses (book, chapter, verse, content, version) VALUES 
('요한복음', 3, 16, '하나님이 세상을 이처럼 사랑하사 독생자를 주셨으니 이는 그를 믿는 자마다 멸망하지 않고 영생을 얻게 하려 하심이라', 'KOR'),
('시편', 23, 1, '여호와는 나의 목자시니 내게 부족함이 없으리로다', 'KOR'),
('빌립보서', 4, 13, '내게 능력 주시는 자 안에서 내가 모든 것을 할 수 있느니라', 'KOR'),
('로마서', 8, 28, '우리가 알거니와 하나님을 사랑하는 자 곧 그의 뜻대로 부르심을 입은 자들에게는 모든 것이 합력하여 선을 이루느니라', 'KOR')
ON CONFLICT DO NOTHING;

-- 샘플 기도문
INSERT INTO prayers (title, content) VALUES 
('감사의 기도', '하나님 아버지, 오늘도 새로운 하루를 주셔서 감사합니다.'),
('위로의 기도', '주님, 지금 마음이 아프고 힘든 시간을 보내고 있습니다.'),
('용기의 기도', '하나님, 앞으로 나아가야 할 길이 어렵고 두렵습니다.'),
('회개의 기도', '하나님 아버지, 죄로 인해 주님께 상처를 드린 것을 회개합니다.'),
('치유의 기도', '치유의 하나님, 아픈 몸과 마음을 온전히 치유해 주소서.')
ON CONFLICT DO NOTHING;

-- 기도문과 태그 연결
INSERT INTO prayer_tags (prayer_id, tag_id) VALUES 
(1, 1), (2, 2), (3, 3), (4, 4), (5, 5)
ON CONFLICT DO NOTHING;

GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO bibleai;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO bibleai;

SELECT 'Database setup completed!' as status;
EOF

echo "✅ 데이터베이스 초기화 완료!"
echo "🚀 이제 ./dev.sh 또는 ./start.sh를 실행하세요."