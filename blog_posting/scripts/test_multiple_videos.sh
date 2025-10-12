#!/bin/bash

# 사용법: ./test_multiple_videos.sh VIDEO_ID1 VIDEO_ID2 VIDEO_ID3 ...
# 또는: ./test_multiple_videos.sh < video_ids.txt

echo "🧪 YouTube 비디오 일괄 테스트"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if [ $# -eq 0 ]; then
    echo "📋 표준 입력에서 비디오 ID를 읽습니다..."
    echo "   (종료하려면 Ctrl+D)"
    echo ""
    VIDEO_IDS=$(cat)
else
    VIDEO_IDS="$@"
fi

if [ -z "$VIDEO_IDS" ]; then
    echo "❌ 사용법: ./test_multiple_videos.sh VIDEO_ID1 VIDEO_ID2 ..."
    echo "예시: ./test_multiple_videos.sh dQw4w9WgXcQ Ks5bzvT-D6I"
    echo ""
    echo "또는 파일에서:"
    echo "  ./test_multiple_videos.sh < video_ids.txt"
    exit 1
fi

COUNT=0
FOUND=false

for VIDEO_ID in $VIDEO_IDS; do
    # 공백/개행 제거
    VIDEO_ID=$(echo "$VIDEO_ID" | tr -d '[:space:]')

    if [ -z "$VIDEO_ID" ]; then
        continue
    fi

    COUNT=$((COUNT + 1))
    echo "[$COUNT] 테스트: $VIDEO_ID"
    echo -n "    상태: "

    # oEmbed API로 검증
    OEMBED_RESPONSE=$(curl -s "https://www.youtube.com/oembed?url=https://www.youtube.com/watch?v=$VIDEO_ID&format=json")

    if [ "$OEMBED_RESPONSE" == "Not Found" ] || [ -z "$OEMBED_RESPONSE" ]; then
        echo "❌ 사용 불가 (Not Found)"
        continue
    fi

    # JSON 파싱
    if command -v jq &> /dev/null; then
        VIDEO_TITLE=$(echo "$OEMBED_RESPONSE" | jq -r '.title' 2>/dev/null)
        AUTHOR_NAME=$(echo "$OEMBED_RESPONSE" | jq -r '.author_name' 2>/dev/null)
    else
        VIDEO_TITLE=$(echo "$OEMBED_RESPONSE" | grep -oP '"title":"[^"]*"' | head -1 | cut -d'"' -f4 | sed 's/\\u[0-9a-fA-F]\{4\}//g')
        AUTHOR_NAME=$(echo "$OEMBED_RESPONSE" | grep -oP '"author_name":"[^"]*"' | head -1 | cut -d'"' -f4 | sed 's/\\u[0-9a-fA-F]\{4\}//g')
    fi

    if [ -z "$VIDEO_TITLE" ]; then
        echo "⚠️  응답 파싱 실패"
        continue
    fi

    echo "✅ 사용 가능!"
    echo "    제목: $VIDEO_TITLE"
    echo "    채널: $AUTHOR_NAME"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "✅ 첫 번째 동작하는 비디오:"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "📺 비디오 ID: $VIDEO_ID"
    echo "📝 제목: $VIDEO_TITLE"
    echo "👤 채널: $AUTHOR_NAME"
    echo ""
    echo "🔗 일반 URL: https://www.youtube.com/watch?v=$VIDEO_ID"
    echo "🔗 임베드 URL: https://www.youtube.com/embed/$VIDEO_ID"
    echo ""
    echo "📋 임베드 코드:"
    echo '<div style="text-align: center; margin: 20px 0;">'
    echo "  <iframe width=\"560\" height=\"315\" src=\"https://www.youtube.com/embed/$VIDEO_ID\" frameborder=\"0\" allow=\"accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture\" allowfullscreen></iframe>"
    echo '</div>'

    FOUND=true
    exit 0
done

if [ "$FOUND" = false ]; then
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "❌ 모든 비디오가 사용 불가능합니다"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "테스트한 비디오: $COUNT개"
fi
