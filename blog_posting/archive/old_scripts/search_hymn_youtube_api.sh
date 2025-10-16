#!/bin/bash

# YouTube Data API v3를 사용한 찬송가 검색
# 사용법: ./search_hymn_youtube_api.sh "찬송가 50장"

SEARCH_QUERY="$1"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# API 키 확인
API_KEY_FILE="$SCRIPT_DIR/.youtube_api_key"

if [ ! -f "$API_KEY_FILE" ]; then
    echo "❌ YouTube API 키가 설정되지 않았습니다."
    echo ""
    echo "📝 API 키 설정 방법:"
    echo "1. Google Cloud Console에서 프로젝트 생성"
    echo "   https://console.cloud.google.com/"
    echo "2. YouTube Data API v3 활성화"
    echo "3. API 키 생성 (사용자 인증 정보 > API 키)"
    echo "4. 다음 파일에 저장:"
    echo "   echo 'YOUR_API_KEY' > $API_KEY_FILE"
    echo ""
    echo "💡 무료 할당량: 하루 10,000 유닛 (검색 1회 = 100 유닛)"
    exit 1
fi

API_KEY=$(cat "$API_KEY_FILE" | tr -d '[:space:]')

if [ -z "$SEARCH_QUERY" ]; then
    echo "❌ 사용법: ./search_hymn_youtube_api.sh \"검색어\""
    echo "예시: ./search_hymn_youtube_api.sh \"찬송가 50장\""
    exit 1
fi

echo "🔍 검색어: $SEARCH_QUERY"
echo ""

# URL 인코딩
ENCODED_QUERY=$(echo "$SEARCH_QUERY" | jq -sRr @uri)

# YouTube Data API v3 검색
API_URL="https://www.googleapis.com/youtube/v3/search"
PARAMS="part=snippet&type=video&videoEmbeddable=true&maxResults=10&q=${ENCODED_QUERY}&key=${API_KEY}"

echo "📡 YouTube API 검색 중..."

RESPONSE=$(curl -s "${API_URL}?${PARAMS}")

# 에러 체크
ERROR=$(echo "$RESPONSE" | jq -r '.error.message // empty' 2>/dev/null)
if [ -n "$ERROR" ]; then
    echo "❌ API 에러: $ERROR"
    exit 1
fi

# 검색 결과 파싱
VIDEO_COUNT=$(echo "$RESPONSE" | jq '.items | length')

if [ "$VIDEO_COUNT" -eq 0 ]; then
    echo "❌ 검색 결과가 없습니다."
    exit 1
fi

echo "✅ $VIDEO_COUNT 개의 비디오를 찾았습니다."
echo ""

# 각 비디오 테스트
for i in $(seq 0 $((VIDEO_COUNT - 1))); do
    VIDEO_ID=$(echo "$RESPONSE" | jq -r ".items[$i].id.videoId")
    VIDEO_TITLE=$(echo "$RESPONSE" | jq -r ".items[$i].snippet.title")
    CHANNEL_TITLE=$(echo "$RESPONSE" | jq -r ".items[$i].snippet.channelTitle")

    echo "[$((i + 1))] 테스트: $VIDEO_ID"
    echo "    제목: $VIDEO_TITLE"
    echo "    채널: $CHANNEL_TITLE"
    echo -n "    검증: "

    # oEmbed API로 임베드 가능 여부 재확인
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
    echo "👤 채널: $CHANNEL_TITLE"
    echo ""
    echo "🔗 일반 URL: https://www.youtube.com/watch?v=$VIDEO_ID"
    echo "🔗 임베드 URL: https://www.youtube.com/embed/$VIDEO_ID"
    echo ""
    echo "📋 임베드 코드:"
    echo '<div style="text-align: center; margin: 20px 0;">'
    echo "  <iframe width=\"560\" height=\"315\" src=\"https://www.youtube.com/embed/$VIDEO_ID\" frameborder=\"0\" allow=\"accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture\" allowfullscreen></iframe>"
    echo '</div>'

    exit 0
done

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "❌ 모든 검색 결과가 사용 불가능합니다"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
