#!/bin/bash

# 서버 모니터링 스크립트
echo "🔍 주님말씀AI 서버 상태 모니터링"
echo "================================="

# 서버 프로세스 확인
echo "📊 서버 프로세스 상태:"
if pgrep -f "go run cmd/server/main.go" > /dev/null; then
    echo "  ✅ 서버 실행 중 (PID: $(pgrep -f 'go run cmd/server/main.go'))"
else
    echo "  ❌ 서버 중지됨"
fi

# 포트 상태 확인  
echo ""
echo "🌐 포트 상태:"
if ss -tln | grep :8080 > /dev/null; then
    echo "  ✅ 포트 8080 열림"
else
    echo "  ❌ 포트 8080 닫힘"
fi

# 헬스체크
echo ""
echo "💓 헬스체크:"
if curl -s http://localhost:8080/health > /dev/null 2>&1; then
    echo "  ✅ 서버 응답 정상"
    HEALTH_RESPONSE=$(curl -s http://localhost:8080/health)
    echo "  📋 상태: $HEALTH_RESPONSE"
else
    echo "  ❌ 서버 응답 없음"
fi

# 데이터베이스 연결 확인
echo ""
echo "🗄️ 데이터베이스 연결:"
if PGPASSWORD=bibleai psql -h localhost -U bibleai -d bibleai -c "SELECT 1;" > /dev/null 2>&1; then
    echo "  ✅ PostgreSQL 연결 정상"
    TAG_COUNT=$(PGPASSWORD=bibleai psql -h localhost -U bibleai -d bibleai -t -c "SELECT COUNT(*) FROM tags;" 2>/dev/null | xargs)
    echo "  📊 태그 수: $TAG_COUNT"
else
    echo "  ❌ PostgreSQL 연결 실패"
fi

# 실시간 로그 확인 옵션
echo ""
echo "📝 로그 확인 옵션:"
if [ -f "server.log" ]; then
    echo "  📄 로그 파일: server.log"
    echo "  📊 로그 라인 수: $(wc -l < server.log)"
    echo ""
    echo "실시간 로그를 보려면: tail -f server.log"
    echo "최근 로그를 보려면: tail -20 server.log"
else
    echo "  ❌ 로그 파일 없음"
fi

echo ""
echo "🔧 관리 명령어:"
echo "  ./monitor.sh     # 상태 확인"
echo "  ./start.sh       # 서버 시작"
echo "  ./stop.sh        # 서버 중지"
echo "  ./dev.sh         # 개발 모드"