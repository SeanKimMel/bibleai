#!/bin/bash

# 주님말씀AI 웹앱 시작 스크립트

echo "🙏 주님말씀AI 웹앱을 시작합니다..."

# 현재 디렉토리 확인
if [ ! -f "go.mod" ]; then
    echo "❌ go.mod 파일을 찾을 수 없습니다. 프로젝트 루트 디렉토리에서 실행해주세요."
    exit 1
fi

# 로컬 PostgreSQL 연결 확인
echo "🐘 로컬 PostgreSQL 연결을 확인하는 중..."
if ! pg_isready -h localhost -p 5432 > /dev/null 2>&1; then
    echo "❌ 로컬 PostgreSQL 서버가 실행되지 않았습니다."
    echo "먼저 다음을 실행하세요:"
    echo "1. PostgreSQL 서비스 시작"
    echo "2. ./init-db.sh 실행 (최초 1회)"
    exit 1
fi

# bibleai 데이터베이스 존재 확인
if ! PGPASSWORD=bibleai psql -h localhost -U bibleai -d bibleai -c "SELECT 1;" > /dev/null 2>&1; then
    echo "❌ bibleai 데이터베이스에 접근할 수 없습니다."
    echo "먼저 ./init-db.sh 를 실행하여 데이터베이스를 초기화하세요."
    exit 1
fi

echo "✅ 데이터베이스 연결 확인됨"

# Go 의존성 확인
echo "📦 Go 의존성을 확인하는 중..."
go mod tidy

# 웹 서버 시작
echo "🚀 웹 서버를 시작합니다 (포트: 8080)..."
echo "📖 API 엔드포인트:"
echo "   - 메인: http://localhost:8080"
echo "   - 헬스체크: http://localhost:8080/health"
echo "   - 태그 목록: http://localhost:8080/api/tags"
echo ""
echo "🛑 서버를 중지하려면 Ctrl+C 를 누르세요."
echo ""

go run cmd/server/main.go