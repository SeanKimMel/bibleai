#!/bin/bash

# 백오피스 서버 시작 스크립트

echo "🚀 백오피스 서버를 시작합니다..."

# PID 파일 경로
PID_FILE="backoffice.pid"

# 기존 프로세스 확인 및 종료
if [ -f "$PID_FILE" ]; then
    OLD_PID=$(cat "$PID_FILE")
    if ps -p $OLD_PID > /dev/null 2>&1; then
        echo "기존 백오피스 서버 (PID: $OLD_PID)를 종료합니다..."
        kill $OLD_PID
        sleep 1
    fi
    rm -f "$PID_FILE"
fi

# 백오피스 서버 빌드
echo "백오피스 서버를 빌드합니다..."
go build -o backoffice ./cmd/backoffice

if [ $? -ne 0 ]; then
    echo "❌ 빌드 실패"
    exit 1
fi

# 백그라운드에서 실행
echo "백오피스 서버를 시작합니다 (포트: 9090)..."
nohup ./backoffice > backoffice.log 2>&1 &
BACKOFFICE_PID=$!

# PID 저장
echo $BACKOFFICE_PID > "$PID_FILE"

echo "✅ 백오피스 서버가 시작되었습니다 (PID: $BACKOFFICE_PID)"
echo "📍 http://localhost:9090"
echo "📄 로그: tail -f backoffice.log"
