#!/bin/bash

# 사용법: ./test_youtube_embed.sh VIDEO_ID

VIDEO_ID=$1

if [ -z "$VIDEO_ID" ]; then
    echo "사용법: ./test_youtube_embed.sh VIDEO_ID"
    echo "예시: ./test_youtube_embed.sh xTvauM-7hqk"
    exit 1
fi

EMBED_URL="https://www.youtube.com/embed/${VIDEO_ID}"
echo "테스트 URL: ${EMBED_URL}"
echo ""
echo "브라우저에서 이 URL을 열어서 재생되는지 확인하세요:"
echo "${EMBED_URL}"
echo ""
echo "또는 일반 유튜브 URL:"
echo "https://www.youtube.com/watch?v=${VIDEO_ID}"
