#!/bin/bash

# 사용법: ./find_working_hymn_video.sh "찬송가 50장"

SEARCH_QUERY="$1"

if [ -z "$SEARCH_QUERY" ]; then
    echo "❌ 사용법: ./find_working_hymn_video.sh \"검색어\""
    echo "예시: ./find_working_hymn_video.sh \"찬송가 50장\""
    exit 1
fi

echo "🔍 검색어: $SEARCH_QUERY"
echo ""

# 우선순위 채널 목록
PRIORITY_CHANNELS=(
    "CTS기독교TV"
    "새찬송가"
    "CGNTV"
    "온누리교회"
    "사랑의교회"
)

# 각 채널별로 검색 시도
for CHANNEL in "${PRIORITY_CHANNELS[@]}"; do
    echo "📺 채널 검색 중: $CHANNEL"

    # URL 인코딩
    ENCODED_QUERY=$(echo "$SEARCH_QUERY $CHANNEL" | sed 's/ /+/g')
    SEARCH_URL="https://www.youtube.com/results?search_query=${ENCODED_QUERY}"

    echo "   URL: $SEARCH_URL"

    # 검색 결과 가져오기
    HTML=$(curl -s "$SEARCH_URL" -H "User-Agent: Mozilla/5.0")

    # 여러 패턴으로 비디오 ID 추출
    VIDEO_IDS=$(echo "$HTML" | grep -oP '"videoId":"[^"]{11}"' | cut -d'"' -f4 | head -10)

    if [ -z "$VIDEO_IDS" ]; then
        echo "   ⚠️  비디오 ID를 추출할 수 없습니다"
        continue
    fi

    # 각 비디오 ID 테스트
    FOUND_COUNT=0
    for VIDEO_ID in $VIDEO_IDS; do
        FOUND_COUNT=$((FOUND_COUNT + 1))
        echo -n "   [$FOUND_COUNT] 테스트 중: $VIDEO_ID ... "

        # oEmbed API로 비디오 유효성 확인
        OEMBED_RESPONSE=$(curl -s "https://www.youtube.com/oembed?url=https://www.youtube.com/watch?v=$VIDEO_ID&format=json")

        if [ "$OEMBED_RESPONSE" == "Not Found" ] || [ -z "$OEMBED_RESPONSE" ]; then
            echo "❌ 사용 불가"
            continue
        fi

        # JSON 파싱 (jq 있으면 사용, 없으면 grep)
        if command -v jq &> /dev/null; then
            VIDEO_TITLE=$(echo "$OEMBED_RESPONSE" | jq -r '.title')
            AUTHOR_NAME=$(echo "$OEMBED_RESPONSE" | jq -r '.author_name')
        else
            VIDEO_TITLE=$(echo "$OEMBED_RESPONSE" | grep -oP '"title":"[^"]*"' | cut -d'"' -f4)
            AUTHOR_NAME=$(echo "$OEMBED_RESPONSE" | grep -oP '"author_name":"[^"]*"' | cut -d'"' -f4)
        fi

        echo "✅ 사용 가능!"
        echo ""
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "✅ 동작하는 비디오를 찾았습니다!"
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
        echo ""
        echo "💾 hymn_videos.json에 추가하시겠습니까?"
        echo "   비디오 ID를 복사해서 수동으로 추가하세요."

        exit 0
    done

    echo "   ⚠️  이 채널에서 사용 가능한 비디오를 찾지 못했습니다"
    echo ""
done

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "❌ 동작하는 비디오를 찾지 못했습니다"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "💡 해결 방법:"
echo "1. 유튜브에서 직접 검색: https://www.youtube.com/results?search_query=$(echo "$SEARCH_QUERY" | sed 's/ /+/g')"
echo "2. 공식 채널의 영상 선택"
echo "3. 비디오 ID를 수동으로 추출"
echo "4. ./test_youtube_embed.sh [VIDEO_ID] 로 테스트"
