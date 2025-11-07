#!/bin/bash
# 모든 미평가 블로그를 자동으로 평가하는 스크립트

set -e

# 서버 URL 확인
SERVER_URL="${API_BASE_URL:-http://localhost:8080}"

echo "🔍 서버 연결 확인 중..."
if ! curl -s -f "$SERVER_URL/health" > /dev/null 2>&1; then
    echo "❌ 서버가 실행되지 않았거나 응답하지 않습니다."
    echo "   서버를 먼저 실행해주세요: ./server.sh start"
    exit 1
fi
echo "✅ 서버 연결 확인 완료"

# 미평가 블로그 ID 목록 조회
echo ""
echo "📊 미평가 블로그 목록 조회 중..."
BLOG_IDS=$(psql -h localhost -U bibleai -d bibleai -t -c \
    "SELECT id FROM blog_posts WHERE total_score IS NULL ORDER BY id;")

if [ -z "$BLOG_IDS" ]; then
    echo "✅ 모든 블로그가 이미 평가되었습니다!"
    exit 0
fi

# 블로그 개수
TOTAL=$(echo "$BLOG_IDS" | wc -l)
echo "📝 총 $TOTAL 개의 미평가 블로그 발견"

# 각 블로그 평가
CURRENT=0
SUCCESS=0
FAILED=0

for BLOG_ID in $BLOG_IDS; do
    CURRENT=$((CURRENT + 1))
    echo ""
    echo "=================================================="
    echo "[$CURRENT/$TOTAL] 블로그 ID: $BLOG_ID 평가 중..."
    echo "=================================================="

    if python3 blog_posting/scripts/evaluate_quality.py --id "$BLOG_ID"; then
        SUCCESS=$((SUCCESS + 1))
        echo "✅ 평가 성공 (ID: $BLOG_ID)"
    else
        FAILED=$((FAILED + 1))
        echo "❌ 평가 실패 (ID: $BLOG_ID)"
        # 실패해도 다음 블로그 계속 평가
        continue
    fi

    # API 과부하 방지를 위한 대기
    sleep 2
done

echo ""
echo "=================================================="
echo "📊 평가 완료 요약"
echo "=================================================="
echo "✅ 성공: $SUCCESS 개"
echo "❌ 실패: $FAILED 개"
echo "📝 전체: $TOTAL 개"
echo "=================================================="

if [ $FAILED -eq 0 ]; then
    echo "🎉 모든 블로그 평가 완료!"
    exit 0
else
    echo "⚠️  일부 블로그 평가 실패"
    exit 1
fi
