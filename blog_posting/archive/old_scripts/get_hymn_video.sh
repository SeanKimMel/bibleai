#!/bin/bash

# 사용법: ./get_hymn_video.sh 50
# 또는: ./get_hymn_video.sh "이 몸의 소망 무엇인가"

SEARCH_TERM="$1"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
JSON_FILE="$SCRIPT_DIR/hymn_videos.json"

if [ -z "$SEARCH_TERM" ]; then
    echo "❌ 사용법: ./get_hymn_video.sh <찬송가번호 또는 제목>"
    echo "예시: ./get_hymn_video.sh 50"
    echo "예시: ./get_hymn_video.sh \"이 몸의 소망 무엇인가\""
    exit 1
fi

if [ ! -f "$JSON_FILE" ]; then
    echo "❌ hymn_videos.json 파일을 찾을 수 없습니다: $JSON_FILE"
    exit 1
fi

# 찬송가 번호로 검색 (숫자만 입력된 경우)
if [[ "$SEARCH_TERM" =~ ^[0-9]+$ ]]; then
    HYMN_NUM="$SEARCH_TERM"

    # jq로 JSON 파싱
    if command -v jq &> /dev/null; then
        RESULT=$(jq -r ".\"$HYMN_NUM\"" "$JSON_FILE")

        if [ "$RESULT" == "null" ]; then
            echo "❌ 찬송가 ${HYMN_NUM}장 정보를 찾을 수 없습니다."
            echo ""
            echo "💡 hymn_videos.json에 다음 형식으로 추가하세요:"
            echo "{"
            echo "  \"$HYMN_NUM\": {"
            echo "    \"title\": \"찬송가 제목\","
            echo "    \"videoId\": \"YouTube_VIDEO_ID\","
            echo "    \"channel\": \"채널명\","
            echo "    \"verified\": true,"
            echo "    \"notes\": \"메모\""
            echo "  }"
            echo "}"
            exit 1
        fi

        TITLE=$(echo "$RESULT" | jq -r '.title')
        VIDEO_ID=$(echo "$RESULT" | jq -r '.videoId')
        CHANNEL=$(echo "$RESULT" | jq -r '.channel')
        VERIFIED=$(echo "$RESULT" | jq -r '.verified')

        if [ "$VIDEO_ID" == "placeholder" ] || [ "$VERIFIED" == "false" ]; then
            echo "⚠️  찬송가 ${HYMN_NUM}장: $TITLE"
            echo "❌ 검증된 비디오 ID가 없습니다."
            echo ""
            echo "📝 비디오 ID를 추가하는 방법:"
            echo "1. 유튜브에서 검색: https://www.youtube.com/results?search_query=찬송가+${HYMN_NUM}장+${TITLE}"
            echo "2. 공식 채널의 영상 선택 (CTS, 새찬송가 등)"
            echo "3. URL에서 v= 뒤의 ID 복사"
            echo "4. hymn_videos.json 파일에서 \"$HYMN_NUM\" 항목의 videoId 수정"
            exit 1
        fi

        echo "✅ 찬송가 ${HYMN_NUM}장: $TITLE"
        echo ""
        echo "📺 비디오 ID: $VIDEO_ID"
        echo "📡 채널: $CHANNEL"
        echo ""
        echo "🔗 일반 URL: https://www.youtube.com/watch?v=$VIDEO_ID"
        echo "🔗 임베드 URL: https://www.youtube.com/embed/$VIDEO_ID"
        echo ""
        echo "📝 임베드 코드:"
        echo '<div style="text-align: center; margin: 20px 0;">'
        echo "  <iframe width=\"560\" height=\"315\" src=\"https://www.youtube.com/embed/$VIDEO_ID\" frameborder=\"0\" allow=\"accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture\" allowfullscreen></iframe>"
        echo '</div>'
        echo ""
        echo "🧪 테스트: 브라우저에서 https://www.youtube.com/embed/$VIDEO_ID 열어보기"

    else
        echo "❌ jq 명령어가 설치되어 있지 않습니다."
        echo "설치: sudo apt-get install jq"
        exit 1
    fi

else
    # 제목으로 검색
    echo "🔍 제목으로 검색: $SEARCH_TERM"

    if command -v jq &> /dev/null; then
        RESULT=$(jq -r "to_entries[] | select(.value.title | contains(\"$SEARCH_TERM\")) | .key + \": \" + .value.title + \" (ID: \" + .value.videoId + \")\"" "$JSON_FILE")

        if [ -z "$RESULT" ]; then
            echo "❌ '$SEARCH_TERM'와(과) 일치하는 찬송가를 찾을 수 없습니다."
            exit 1
        fi

        echo "✅ 찾은 찬송가:"
        echo "$RESULT"
    else
        echo "❌ jq 명령어가 설치되어 있지 않습니다."
        exit 1
    fi
fi
