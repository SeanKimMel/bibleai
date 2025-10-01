#!/bin/bash

# 기도문 API 테스트 스크립트
API_URL="http://localhost:8080/api"

echo "🧪 기도문 API 테스트를 시작합니다..."
echo "======================================="

# 1. 태그 목록 확인
echo "1️⃣ 태그 목록 조회:"
curl -s "$API_URL/tags" | jq -r '.tags[] | "ID: \(.id), 이름: \(.name)"'
echo ""

# 2. 기존 기도문 확인
echo "2️⃣ 기존 기도문 개수 확인:"
EXISTING_COUNT=$(curl -s "$API_URL/prayers" | jq '.total')
echo "기존 기도문: $EXISTING_COUNT개"
echo ""

# 3. 샘플 기도문 데이터 삽입
echo "3️⃣ 샘플 기도문 데이터 삽입:"
PRAYER_COUNT=0
SUCCESS_COUNT=0
FAIL_COUNT=0

while IFS= read -r prayer; do
    PRAYER_COUNT=$((PRAYER_COUNT + 1))
    
    TITLE=$(echo "$prayer" | jq -r '.title')
    echo -n "[$PRAYER_COUNT] \"$TITLE\" 삽입 중... "
    
    RESPONSE=$(curl -s -X POST "$API_URL/prayers" \
        -H "Content-Type: application/json" \
        -d "$prayer")
    
    if echo "$RESPONSE" | jq -e '.prayer' > /dev/null 2>&1; then
        PRAYER_ID=$(echo "$RESPONSE" | jq -r '.prayer.id')
        echo "✅ 성공 (ID: $PRAYER_ID)"
        SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
    else
        echo "❌ 실패"
        echo "   오류: $(echo "$RESPONSE" | jq -r '.message // .error')"
        FAIL_COUNT=$((FAIL_COUNT + 1))
    fi
done < <(jq -c '.[]' sample_prayers.json)

echo ""
echo "📊 삽입 결과:"
echo "  - 성공: $SUCCESS_COUNT개"
echo "  - 실패: $FAIL_COUNT개"
echo "  - 총계: $PRAYER_COUNT개"
echo ""

# 4. 전체 기도문 개수 확인
echo "4️⃣ 업데이트된 기도문 개수 확인:"
NEW_COUNT=$(curl -s "$API_URL/prayers" | jq '.total')
echo "현재 기도문: $NEW_COUNT개"
echo ""

# 5. 태그별 조회 테스트
echo "5️⃣ 태그별 조회 테스트:"

# 감사 태그만
echo "감사 태그 (ID: 1):"
curl -s "$API_URL/prayers/by-tags?tag_ids=1" | jq -r '.prayers[] | "  - \(.title) (태그: \(.tags | map(.name) | join(", ")))"'

echo ""

# 위로+치유 태그 조합
echo "위로+치유 태그 조합 (ID: 2,5):"
curl -s "$API_URL/prayers/by-tags?tag_ids=2,5" | jq -r '.prayers[] | "  - \(.title) (태그: \(.tags | map(.name) | join(", ")))"'

echo ""
echo "✅ API 테스트 완료!"
echo ""
echo "🔗 API 엔드포인트 목록:"
echo "  GET  $API_URL/tags                    # 태그 목록"
echo "  GET  $API_URL/prayers                 # 전체 기도문"
echo "  GET  $API_URL/prayers/by-tags?tag_ids=1,2  # 태그별 기도문"
echo "  POST $API_URL/prayers                 # 기도문 생성"
echo "  POST $API_URL/prayers/:id/tags        # 기도문에 태그 추가"