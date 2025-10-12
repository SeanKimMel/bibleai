#!/bin/bash

# PostgreSQL 데이터베이스 초기화 스크립트
# .env 파일에서 DB_PASSWORD를 읽어서 init.sql 실행

set -e

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "🗄️  BibleAI 데이터베이스 초기화"
echo "================================"

# .env 파일 확인
if [ ! -f .env ]; then
    echo -e "${RED}❌ .env 파일을 찾을 수 없습니다${NC}"
    exit 1
fi

# .env 파일에서 환경 변수 로드
source .env

# DB_PASSWORD 확인
if [ -z "$DB_PASSWORD" ]; then
    echo -e "${RED}❌ .env 파일에 DB_PASSWORD가 설정되지 않았습니다${NC}"
    exit 1
fi

echo -e "${GREEN}✅ .env 파일 로드 완료${NC}"
echo "   DB_PASSWORD: ***"

# PostgreSQL 서비스 확인
if ! pgrep -x postgres > /dev/null; then
    echo -e "${YELLOW}⚠️  PostgreSQL 서비스가 실행되지 않고 있습니다${NC}"
    echo "   macOS: brew services start postgresql"
    echo "   Ubuntu: sudo systemctl start postgresql"
    exit 1
fi

echo -e "${GREEN}✅ PostgreSQL 서비스 실행 중${NC}"

# init.sql 실행
echo "🔧 데이터베이스 초기화 중..."

# psql 변수로 비밀번호 전달
psql -h localhost -U postgres -v db_password="'${DB_PASSWORD}'" -f init.sql

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ 데이터베이스 초기화 완료${NC}"
    echo ""
    echo "생성된 리소스:"
    echo "  - 데이터베이스: bibleai"
    echo "  - 사용자: bibleai (비밀번호: .env의 DB_PASSWORD)"
    echo ""
    echo "연결 테스트:"
    echo "  PGPASSWORD=\${DB_PASSWORD} psql -h localhost -U bibleai -d bibleai"
else
    echo -e "${RED}❌ 데이터베이스 초기화 실패${NC}"
    exit 1
fi
