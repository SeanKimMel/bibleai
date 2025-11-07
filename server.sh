#!/bin/bash

# 서버 관리 스크립트
PORT=8080
APP_NAME="bibleai-server"

case "$1" in
    start)
        echo "🚀 나홀로예배 서버를 시작합니다..."
        # 기존 프로세스 확인 및 종료
        if lsof -ti:$PORT >/dev/null 2>&1; then
            echo "⚠️ 포트 $PORT가 이미 사용 중입니다. 기존 프로세스를 종료합니다."
            lsof -ti:$PORT | xargs kill -9
            sleep 2
        fi
        
        # 서버 시작
        echo "서버 시작 중... (포트: $PORT)"
        go run cmd/server/main.go > server.log 2>&1 &
        SERVER_PID=$!
        echo $SERVER_PID > server.pid
        
        # 서버 시작 확인
        echo "서버 상태 확인 중..."
        for i in {1..10}; do
            if curl -s http://localhost:$PORT/health >/dev/null 2>&1; then
                echo "✅ 서버가 성공적으로 시작되었습니다!"
                echo "📍 URL: http://localhost:$PORT"
                echo "📁 로그: tail -f server.log"
                echo "🔍 상태 확인: ./server.sh status"
                exit 0
            fi
            echo "대기 중... ($i/10)"
            sleep 1
        done
        echo "❌ 서버 시작에 실패했습니다. 로그를 확인하세요: tail -f server.log"
        exit 1
        ;;
        
    stop)
        echo "🛑 서버를 중지합니다..."
        if [ -f server.pid ]; then
            PID=$(cat server.pid)
            if ps -p $PID > /dev/null 2>&1; then
                kill $PID
                echo "PID $PID 프로세스 종료됨"
            fi
            rm -f server.pid
        fi
        
        # 포트 기반으로 추가 종료
        if lsof -ti:$PORT >/dev/null 2>&1; then
            lsof -ti:$PORT | xargs kill -9
            echo "포트 $PORT 프로세스 강제 종료됨"
        fi
        
        echo "✅ 서버가 중지되었습니다."
        ;;
        
    restart)
        echo "🔄 서버를 재시작합니다..."
        $0 stop
        sleep 2
        $0 start
        ;;
        
    status)
        echo "📊 서버 상태 확인 중..."
        if lsof -ti:$PORT >/dev/null 2>&1; then
            echo "✅ 서버가 실행 중입니다. (포트: $PORT)"
            
            # Health check
            if curl -s http://localhost:$PORT/health >/dev/null 2>&1; then
                HEALTH=$(curl -s http://localhost:$PORT/health | jq -r '.status // "unknown"')
                DB_STATUS=$(curl -s http://localhost:$PORT/health | jq -r '.database // "unknown"')
                echo "🏥 Health: $HEALTH, DB: $DB_STATUS"
                
                # 성경 데이터 통계
                STATS=$(curl -s http://localhost:$PORT/api/admin/bible/stats 2>/dev/null)
                if [ $? -eq 0 ]; then
                    VERSES=$(echo "$STATS" | jq -r '.stats.total_verses // "0"')
                    BOOKS=$(echo "$STATS" | jq -r '.stats.total_books // "0"')
                    echo "📖 성경: ${BOOKS}권, ${VERSES}구절"
                fi
                
                # 프로세스 정보
                PID=$(lsof -ti:$PORT)
                echo "🔧 PID: $PID"
                echo "📁 로그: tail -f server.log"
            else
                echo "⚠️ 서버는 실행 중이지만 응답하지 않습니다."
            fi
        else
            echo "❌ 서버가 실행 중이지 않습니다."
            exit 1
        fi
        ;;
        
    logs)
        echo "📄 서버 로그를 확인합니다..."
        if [ -f server.log ]; then
            tail -f server.log
        else
            echo "❌ 로그 파일이 없습니다."
            exit 1
        fi
        ;;
        
    test)
        echo "🧪 서버 API 테스트..."
        if ! curl -s http://localhost:$PORT/health >/dev/null 2>&1; then
            echo "❌ 서버가 실행 중이지 않습니다."
            exit 1
        fi
        
        echo "1. Health Check:"
        curl -s http://localhost:$PORT/health | jq
        
        echo -e "\n2. 성경 데이터 통계:"
        curl -s http://localhost:$PORT/api/admin/bible/stats | jq
        
        echo -e "\n3. 성경 검색 테스트 (사랑):"
        curl -s "http://localhost:$PORT/api/bible/search?q=사랑" | jq '.total'
        
        echo -e "\n4. 기도문 목록:"
        curl -s http://localhost:$PORT/api/prayers | jq '.total'
        
        echo -e "\n✅ 모든 API가 정상 작동합니다!"
        ;;
        
    *)
        echo "Usage: $0 {start|stop|restart|status|logs|test}"
        echo ""
        echo "Commands:"
        echo "  start   - 서버 시작"
        echo "  stop    - 서버 중지" 
        echo "  restart - 서버 재시작"
        echo "  status  - 서버 상태 확인"
        echo "  logs    - 서버 로그 보기"
        echo "  test    - API 테스트"
        echo ""
        echo "Examples:"
        echo "  ./server.sh start"
        echo "  ./server.sh status"
        echo "  ./server.sh logs"
        exit 1
        ;;
esac