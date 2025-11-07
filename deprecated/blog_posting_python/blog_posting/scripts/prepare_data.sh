#!/bin/bash
# API를 통해 키워드 관련 데이터를 가져와 JSON으로 저장

set -e  # 에러 발생시 즉시 종료

# 키워드 매개변수 확인
if [ -z "$1" ]; then
    echo "사용법: $0 <keyword> [date]"
    echo "예시: $0 평안 2025-10-15"
    exit 1
fi

KEYWORD=$1
DATE=${2:-$(date +%Y-%m-%d)}
OUTPUT_DIR="../data"
OUTPUT_FILE="$OUTPUT_DIR/${DATE}-${KEYWORD}.json"
API_URL="http://localhost:8080/api/admin/blog/generate-data"

# 출력 디렉토리 생성
mkdir -p "$OUTPUT_DIR"

echo "📊 데이터 준비 중..."
echo "  키워드: $KEYWORD"
echo "  날짜: $DATE"
echo "  출력 파일: $OUTPUT_FILE"
echo "  API: $API_URL"

# API를 통해 데이터 가져오기 (random 모드 사용)
echo "  🌐 API 호출 중..."
RESPONSE=$(curl -s -f "${API_URL}?keyword=${KEYWORD}&random=true")

if [ $? -ne 0 ]; then
    echo "❌ API 호출 실패"
    echo "   서버가 실행 중인지 확인하세요: http://localhost:8080"
    exit 1
fi

# API 응답을 파싱하여 필요한 형식으로 변환
echo "$RESPONSE" | jq "{
  keyword: .keyword,
  date: \"$DATE\",
  bible: .data.bible,
  hymns: [.data.hymns[] // empty],
  prayers: .data.prayers
}" > "$OUTPUT_FILE"

# 결과 확인
if [ -f "$OUTPUT_FILE" ]; then
    echo "✅ 데이터 준비 완료!"
    echo "  파일 크기: $(du -h "$OUTPUT_FILE" | cut -f1)"

    # 각 카테고리 정보 출력
    if command -v jq &> /dev/null; then
        BIBLE_BOOK=$(jq -r '.bible.book_name // "없음"' "$OUTPUT_FILE")
        BIBLE_CHAPTER=$(jq -r '.bible.chapter // "N/A"' "$OUTPUT_FILE")
        BIBLE_VERSES=$(jq -r '.bible.total_verses // 0' "$OUTPUT_FILE")
        HYMNS_COUNT=$(jq '.hymns | length // 0' "$OUTPUT_FILE")
        PRAYERS_COUNT=$(jq '.prayers | length // 0' "$OUTPUT_FILE")

        echo "  성경: ${BIBLE_BOOK} ${BIBLE_CHAPTER}장 (${BIBLE_VERSES}절)"
        echo "  찬송가: ${HYMNS_COUNT}개"
        echo "  기도문: ${PRAYERS_COUNT}개"
    fi
else
    echo "❌ 파일 생성 실패"
    exit 1
fi
