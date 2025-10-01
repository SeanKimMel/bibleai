#!/bin/bash

# 주님말씀AI 웹앱 종료 스크립트

echo "🛑 주님말씀AI 웹앱을 종료합니다..."

# Go 서버 프로세스 종료
echo "🔌 Go 웹서버를 종료하는 중..."
pkill -f "go run cmd/server/main.go" 2>/dev/null
pkill -f "bibleai" 2>/dev/null
pkill -f "air" 2>/dev/null

# 8080 포트 사용 중인 프로세스 강제 종료
if lsof -ti:8080 >/dev/null 2>&1; then
    echo "🔧 포트 8080 사용 중인 프로세스 종료..."
    lsof -ti:8080 | xargs kill -9 2>/dev/null
fi

# Docker 컨테이너 종료 (애플리케이션만)
echo "📦 Docker 컨테이너를 종료하는 중..."
docker-compose down

echo "✅ 애플리케이션 서비스가 종료되었습니다."
echo "💡 로컬 PostgreSQL은 계속 실행 중입니다."