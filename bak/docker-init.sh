#!/bin/bash

# Docker를 사용한 PostgreSQL 초기화 스크립트
echo "🐳 Docker를 사용하여 PostgreSQL 초기화를 진행합니다..."

# 임시 PostgreSQL 컨테이너 실행
echo "📦 임시 PostgreSQL 컨테이너를 시작합니다..."
docker run --name temp_postgres -e POSTGRES_PASSWORD=postgres -d -p 15432:5432 postgres:16-alpine

# 컨테이너 시작 대기
echo "⏳ PostgreSQL 컨테이너 시작을 기다립니다..."
for i in {1..30}; do
    if docker exec temp_postgres pg_isready > /dev/null 2>&1; then
        echo "✅ PostgreSQL 컨테이너가 준비되었습니다."
        break
    fi
    if [ $i -eq 30 ]; then
        echo "❌ PostgreSQL 컨테이너 시작 시간 초과"
        docker rm -f temp_postgres
        exit 1
    fi
    sleep 2
done

# 초기화 스크립트 실행
echo "📝 데이터베이스 초기화를 실행합니다..."
docker exec -i temp_postgres psql -U postgres << 'EOF'
-- bibleai 데이터베이스 및 사용자 생성
DROP DATABASE IF EXISTS bibleai;
DROP USER IF EXISTS bibleai;

CREATE DATABASE bibleai;
CREATE USER bibleai WITH ENCRYPTED PASSWORD 'bibleai123';
GRANT ALL PRIVILEGES ON DATABASE bibleai TO bibleai;
\q
EOF

# bibleai 데이터베이스에서 테이블 생성
echo "🏗️ 테이블 및 데이터를 생성합니다..."
docker exec -i temp_postgres psql -U postgres -d bibleai << 'EOF'
-- 권한 설정
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

-- 소유권 변경
ALTER TABLE prayers OWNER TO bibleai;
ALTER TABLE tags OWNER TO bibleai;
ALTER TABLE prayer_tags OWNER TO bibleai;
ALTER TABLE bible_verses OWNER TO bibleai;
ALTER TABLE hymns OWNER TO bibleai;

ALTER SEQUENCE prayers_id_seq OWNER TO bibleai;
ALTER SEQUENCE tags_id_seq OWNER TO bibleai;
ALTER SEQUENCE bible_verses_id_seq OWNER TO bibleai;
ALTER SEQUENCE hymns_id_seq OWNER TO bibleai;

-- 기본 데이터
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
('감사의 기도', '하나님 아버지, 오늘도 새로운 하루를 주셔서 감사합니다.'),
('위로의 기도', '주님, 지금 마음이 아프고 힘든 시간을 보내고 있습니다.'),
('용기의 기도', '하나님, 앞으로 나아가야 할 길이 어렵고 두렵습니다.'),
('회개의 기도', '하나님 아버지, 죄로 인해 주님께 상처를 드린 것을 회개합니다.'),
('치유의 기도', '치유의 하나님, 아픈 몸과 마음을 온전히 치유해 주소서.');

INSERT INTO prayer_tags (prayer_id, tag_id) VALUES 
(1, 1), (2, 2), (3, 3), (4, 4), (5, 5);

SELECT 'Database setup completed!' as message;
EOF

# 데이터를 로컬 PostgreSQL로 덤프
echo "📤 데이터를 로컬 PostgreSQL로 이전합니다..."
docker exec temp_postgres pg_dump -U postgres bibleai > bibleai_backup.sql

echo "📥 로컬 PostgreSQL에 데이터를 복원합니다..."
# 로컬 PostgreSQL에서 데이터베이스 생성 (현재 사용자로)
createdb bibleai 2>/dev/null || echo "데이터베이스 이미 존재하거나 권한 문제"
psql -d bibleai < bibleai_backup.sql 2>/dev/null || echo "일부 오류가 있을 수 있지만 계속 진행..."

# 임시 컨테이너 정리
echo "🧹 임시 컨테이너를 정리합니다..."
docker rm -f temp_postgres

# 백업 파일 정리
rm -f bibleai_backup.sql

echo ""
echo "✅ 데이터베이스 초기화 완료!"
echo "🧪 연결 테스트를 실행합니다..."

# 연결 테스트
if psql -d bibleai -c "SELECT COUNT(*) FROM tags;" 2>/dev/null; then
    echo "✅ 데이터베이스 연결 및 데이터 확인 성공!"
    echo ""
    echo "🚀 이제 애플리케이션을 실행할 수 있습니다:"
    echo "  ./start.sh    # 일반 실행"
    echo "  ./dev.sh      # 개발 모드"
else
    echo "⚠️  연결 테스트 실패. 수동으로 확인이 필요합니다."
fi