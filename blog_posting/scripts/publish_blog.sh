#!/bin/bash

# 블로그 발행 스크립트
# 사용법: ./publish_blog.sh <output.json>

if [ -z "$1" ]; then
  echo "사용법: $0 <output.json>"
  echo "예시: $0 output.json"
  exit 1
fi

INPUT_FILE="$1"

if [ ! -f "$INPUT_FILE" ]; then
  echo "❌ 파일을 찾을 수 없습니다: $INPUT_FILE"
  exit 1
fi

echo "📝 블로그를 발행합니다..."

# JSON 유효성 검사
jq . "$INPUT_FILE" > /dev/null 2>&1
if [ $? -ne 0 ]; then
  echo "❌ JSON 형식이 올바르지 않습니다"
  exit 1
fi

# 필수 필드 확인
REQUIRED_FIELDS=("title" "slug" "content" "excerpt" "keywords")
for field in "${REQUIRED_FIELDS[@]}"; do
  if ! jq -e ".$field" "$INPUT_FILE" > /dev/null 2>&1; then
    echo "❌ 필수 필드가 누락되었습니다: $field"
    exit 1
  fi
done

echo "✅ JSON 검증 완료"
echo ""

# API 호출
RESPONSE=$(curl -s -X POST "http://localhost:8080/api/admin/blog/posts" \
  -H "Content-Type: application/json" \
  -d @"$INPUT_FILE")

echo "$RESPONSE" | jq .

# 성공 여부 확인
if echo "$RESPONSE" | jq -e '.success' > /dev/null 2>&1; then
  BLOG_ID=$(echo "$RESPONSE" | jq -r '.id')
  echo ""
  echo "✅ 블로그가 성공적으로 발행되었습니다!"
  echo "📍 ID: $BLOG_ID"
  echo "🔗 URL: http://localhost:8080/blog"
else
  echo ""
  echo "❌ 블로그 발행 실패"
  exit 1
fi
