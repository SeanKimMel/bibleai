#!/bin/bash

# 완전 자동 찬송가 비디오 검색 및 검증
# 사용법: ./auto_find_hymn_video.sh "찬송가 200장 주 품에 품으소서"

SEARCH_QUERY="$1"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
YT_DLP="/tmp/yt-dlp"

# yt-dlp 설치 확인
if [ ! -f "$YT_DLP" ]; then
    echo "📥 yt-dlp 다운로드 중..."
    curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o "$YT_DLP" 2>/dev/null
    chmod +x "$YT_DLP"
    echo "✅ yt-dlp 설치 완료"
    echo ""
fi

if [ -z "$SEARCH_QUERY" ]; then
    echo "❌ 사용법: ./auto_find_hymn_video.sh \"검색어\""
    echo "예시: ./auto_find_hymn_video.sh \"찬송가 200장 주 품에 품으소서\""
    exit 1
fi

echo "🔍 검색어: $SEARCH_QUERY"
echo ""

# YouTube 검색 (상위 10개)
echo "📡 YouTube 검색 중..."
SEARCH_RESULTS=$("$YT_DLP" -j --flat-playlist "ytsearch10:$SEARCH_QUERY" 2>/dev/null)

if [ -z "$SEARCH_RESULTS" ]; then
    echo "❌ 검색 결과가 없습니다."
    exit 1
fi

# JSON 파싱을 위해 jq 확인
if ! command -v jq &> /dev/null; then
    echo "⚠️  jq가 설치되어 있지 않아 수동 파싱을 사용합니다."
    USE_JQ=false
else
    USE_JQ=true
fi

COUNT=0
FOUND=false

# 각 줄이 하나의 JSON 객체
while IFS= read -r line; do
    if [ -z "$line" ]; then
        continue
    fi

    COUNT=$((COUNT + 1))

    # 비디오 ID 추출
    if [ "$USE_JQ" = true ]; then
        VIDEO_ID=$(echo "$line" | jq -r '.id' 2>/dev/null)
        VIDEO_TITLE=$(echo "$line" | jq -r '.title' 2>/dev/null)
        CHANNEL=$(echo "$line" | jq -r '.channel' 2>/dev/null)
    else
        VIDEO_ID=$(echo "$line" | grep -oP '"id":\s*"[^"]+' | head -1 | cut -d'"' -f4)
        VIDEO_TITLE=$(echo "$line" | grep -oP '"title":\s*"[^"]+' | head -1 | cut -d'"' -f4)
        CHANNEL=$(echo "$line" | grep -oP '"channel":\s*"[^"]+' | head -1 | cut -d'"' -f4)
    fi

    if [ -z "$VIDEO_ID" ]; then
        continue
    fi

    echo "[$COUNT] 테스트: $VIDEO_ID"
    echo "    제목: $VIDEO_TITLE"
    echo "    채널: $CHANNEL"
    echo -n "    검증: "

    # oEmbed API로 임베드 가능 여부 확인
    OEMBED_RESPONSE=$(curl -s "https://www.youtube.com/oembed?url=https://www.youtube.com/watch?v=$VIDEO_ID&format=json")

    if [ "$OEMBED_RESPONSE" == "Not Found" ] || [ -z "$OEMBED_RESPONSE" ]; then
        echo "❌ 임베드 불가"
        continue
    fi

    echo "✅ 사용 가능!"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "✅ 동작하는 비디오를 찾았습니다!"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "📺 비디오 ID: $VIDEO_ID"
    echo "📝 제목: $VIDEO_TITLE"
    echo "👤 채널: $CHANNEL"
    echo ""
    echo "🔗 일반 URL: https://www.youtube.com/watch?v=$VIDEO_ID"
    echo "🔗 임베드 URL: https://www.youtube.com/embed/$VIDEO_ID"
    echo ""
    echo "📋 임베드 코드:"
    echo '<div style="text-align: center; margin: 20px 0;">'
    echo "  <iframe width=\"560\" height=\"315\" src=\"https://www.youtube.com/embed/$VIDEO_ID\" frameborder=\"0\" allow=\"accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture\" allowfullscreen></iframe>"
    echo '</div>'
    echo ""
    echo "💾 블로그 작성 시 이 비디오 ID를 사용하세요: $VIDEO_ID"

    FOUND=true
    exit 0

done <<< "$SEARCH_RESULTS"

if [ "$FOUND" = false ]; then
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "❌ 모든 검색 결과가 사용 불가능합니다"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "테스트한 비디오: $COUNT개"
    echo ""
    echo "💡 다른 검색어를 시도해보세요:"
    echo "   - 채널명 추가: \"$SEARCH_QUERY CTS\""
    echo "   - 키워드 변경: \"$SEARCH_QUERY 공식\""
fi
