#!/bin/bash

# 사용법: ./get_youtube_video_id.sh "찬송가 305장"

SEARCH_QUERY="$1"

if [ -z "$SEARCH_QUERY" ]; then
    echo "사용법: ./get_youtube_video_id.sh \"검색어\""
    echo "예시: ./get_youtube_video_id.sh \"찬송가 305장\""
    exit 1
fi

# URL 인코딩
ENCODED_QUERY=$(echo "$SEARCH_QUERY" | sed 's/ /+/g')

# 유튜브 검색 결과 가져오기
SEARCH_URL="https://www.youtube.com/results?search_query=${ENCODED_QUERY}"

echo "검색 URL: $SEARCH_URL"
echo "검색 중..."

# curl로 검색 결과 가져와서 여러 패턴으로 비디오 ID 추출 시도
HTML=$(curl -s "$SEARCH_URL")

# 패턴 1: "videoId":"..."
VIDEO_ID=$(echo "$HTML" | grep -oP '"videoId":"[^"]+' | head -1 | cut -d'"' -f4)

# 패턴이 실패하면 다른 패턴 시도
if [ -z "$VIDEO_ID" ]; then
    VIDEO_ID=$(echo "$HTML" | grep -oP '/watch\?v=[a-zA-Z0-9_-]{11}' | head -1 | cut -d'=' -f2)
fi

# 그래도 실패하면 ytInitialData 파싱
if [ -z "$VIDEO_ID" ]; then
    VIDEO_ID=$(echo "$HTML" | grep -oP 'ytInitialData.*?"videoId":"[^"]+' | head -1 | grep -oP '"videoId":"[^"]+' | cut -d'"' -f4)
fi

if [ -z "$VIDEO_ID" ]; then
    echo "❌ 비디오를 찾을 수 없습니다."
    echo "수동으로 찾으세요: $SEARCH_URL"
    exit 1
fi

echo ""
echo "✅ 찾은 비디오 ID: $VIDEO_ID"
echo ""
echo "일반 URL: https://www.youtube.com/watch?v=$VIDEO_ID"
echo "임베드 URL: https://www.youtube.com/embed/$VIDEO_ID"
echo ""
echo "📝 임베드 코드:"
echo '<div style="text-align: center; margin: 20px 0;">'
echo "  <iframe width=\"560\" height=\"315\" src=\"https://www.youtube.com/embed/$VIDEO_ID\" frameborder=\"0\" allow=\"accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture\" allowfullscreen></iframe>"
echo '</div>'
