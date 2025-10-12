#!/bin/bash

# 데이터 수집 스크립트
# 사용법: ./fetch_data.sh <키워드>

if [ -z "$1" ]; then
  echo "사용법: $0 <키워드>"
  echo "예시: $0 감사"
  exit 1
fi

KEYWORD="$1"
OUTPUT_FILE="data.json"

echo "🔍 키워드 '$KEYWORD'로 데이터를 수집합니다..."

curl -s "http://localhost:8080/api/admin/blog/generate-data?keyword=$KEYWORD&random=true" \
  | jq . > "$OUTPUT_FILE"

if [ $? -eq 0 ]; then
  echo "✅ 데이터 수집 완료: $OUTPUT_FILE"
  echo ""
  echo "📊 데이터 요약:"
  cat "$OUTPUT_FILE" | jq '{
    keyword,
    random_mode,
    has_bible: .summary.has_bible,
    has_prayer: .summary.has_prayer,
    has_hymn: .summary.has_hymn,
    bible_chapter: .data.bible.chapter,
    hymns_count: (.data.hymns | length)
  }'
else
  echo "❌ 데이터 수집 실패"
  exit 1
fi
