#!/bin/bash
# 블로그 자동 생성 예시 스크립트
# 사용법: ./scripts/generate_blog_example.sh {키워드}

KEYWORD=${1:-"감사"}
API_URL="http://localhost:8080"

echo "======================================"
echo "블로그 자동 생성 예시"
echo "키워드: $KEYWORD"
echo "======================================"
echo ""

# 1. 데이터 수집
echo "📚 Step 1: 데이터 수집 중..."
DATA=$(curl -s "$API_URL/api/admin/blog/generate-data?keyword=$KEYWORD")

echo "✅ 데이터 수집 완료"
echo ""

# 2. 데이터 확인
echo "📊 Step 2: 수집된 데이터 요약"
echo "$DATA" | jq '{
  keyword,
  summary,
  bible_info: {
    book: .data.bible.book_name,
    chapter: .data.bible.chapter,
    verses: .data.bible.total_verses
  },
  prayers_count: (.data.prayers | length),
  hymns_count: (.data.hymns | length)
}'
echo ""

# 3. 성경 본문 미리보기
echo "📖 Step 3: 성경 본문 미리보기 (처음 3구절)"
echo "$DATA" | jq -r '.data.bible.verses[:3] | .[] | "\(.verse)절: \(.content)"'
echo ""

# 4. 찬송가 정보
echo "🎵 Step 4: 찬송가 정보"
echo "$DATA" | jq -r '.data.hymns | .[] | "- \(.new_hymn_number)장: \(.title)"'
echo ""

# 5. 기도문 정보
echo "🙏 Step 5: 기도문 정보"
echo "$DATA" | jq -r '.data.prayers | .[] | "- \(.title)"'
echo ""

echo "======================================"
echo "💡 다음 단계:"
echo "======================================"
echo "1. 위 데이터를 Claude API에 전달"
echo "2. 프롬프트: '위 성경, 기도문, 찬송가를 조합하여 신앙 묵상 블로그를 마크다운으로 작성해주세요'"
echo "3. Claude가 생성한 마크다운을 /api/admin/blog/posts로 발행"
echo ""
echo "📝 샘플 블로그 발행 명령어:"
echo "curl -X POST \"$API_URL/api/admin/blog/posts\" \\"
echo "  -H \"Content-Type: application/json\" \\"
echo "  -d '{"
echo "    \"title\": \"${KEYWORD}에 대한 묵상\","
echo "    \"slug\": \"2025-10-08-${KEYWORD}\","
echo "    \"content\": \"# ${KEYWORD}에 대한 묵상\n\n...\","
echo "    \"excerpt\": \"${KEYWORD}을 주제로 성경, 기도문, 찬송가를 통해 묵상합니다.\","
echo "    \"keywords\": \"${KEYWORD},성경,묵상\""
echo "  }'"
echo ""
