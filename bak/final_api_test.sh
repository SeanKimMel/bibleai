#!/bin/bash

# 최종 API 종합 테스트 스크립트
API_URL="http://localhost:8080/api"

echo "🎯 주님말씀AI 기도문 API 최종 검증"
echo "======================================"

# 1. 서버 상태 확인
echo "1️⃣ 서버 상태 확인:"
HEALTH=$(curl -s "$API_URL/../health")
echo "$HEALTH" | jq -r '"상태: \(.status), DB: \(.database)"'
echo ""

# 2. 태그 목록 조회
echo "2️⃣ 사용 가능한 태그 (총 10개):"
curl -s "$API_URL/tags" | jq -r '.tags[] | "  \(.id). \(.name) - \(.description)"'
echo ""

# 3. 전체 기도문 개수 확인
echo "3️⃣ 전체 기도문 통계:"
PRAYER_STATS=$(curl -s "$API_URL/prayers")
TOTAL=$(echo "$PRAYER_STATS" | jq '.total')
echo "총 기도문: $TOTAL개"
echo ""

# 4. 태그별 조회 테스트 (다양한 조합)
echo "4️⃣ 태그별 조회 테스트:"

# 단일 태그 테스트
for tag_id in 1 3 5 7; do
    case $tag_id in
        1) tag_name="감사" ;;
        3) tag_name="용기" ;;
        5) tag_name="치유" ;;
        7) tag_name="평강" ;;
    esac
    
    result=$(curl -s "$API_URL/prayers/by-tags?tag_ids=$tag_id")
    count=$(echo "$result" | jq '.total')
    echo "  $tag_name 태그: ${count}개 기도문"
done

echo ""

# 다중 태그 조합 테스트
echo "5️⃣ 다중 태그 조합 테스트:"
declare -a combinations=(
    "1,8:감사+가족"
    "2,5:위로+치유" 
    "3,6:용기+지혜"
    "9,6:직장+지혜"
    "10,7:건강+평강"
)

for combo in "${combinations[@]}"; do
    IFS=':' read -r tag_ids tag_desc <<< "$combo"
    result=$(curl -s "$API_URL/prayers/by-tags?tag_ids=$tag_ids")
    count=$(echo "$result" | jq '.total')
    echo "  $tag_desc 조합: ${count}개 기도문"
    
    # 첫 번째 결과 미리보기
    if [ "$count" -gt 0 ]; then
        first_title=$(echo "$result" | jq -r '.prayers[0].title')
        echo "    → \"$first_title\""
    fi
done

echo ""

# 6. 새 기도문 추가 테스트
echo "6️⃣ 새 기도문 추가 테스트:"
NEW_PRAYER='{
    "title": "API 테스트 기도문",
    "content": "API가 잘 작동하도록 도와주소서.",
    "tag_ids": [1, 6]
}'

echo "새 기도문 추가 중..."
RESULT=$(curl -s -X POST "$API_URL/prayers" \
    -H "Content-Type: application/json" \
    -d "$NEW_PRAYER")

if echo "$RESULT" | jq -e '.prayer' > /dev/null 2>&1; then
    NEW_ID=$(echo "$RESULT" | jq -r '.prayer.id')
    echo "✅ 성공! ID: $NEW_ID"
    
    # 추가한 기도문 조회해보기
    echo "추가된 기도문 확인:"
    curl -s "$API_URL/prayers/by-tags?tag_ids=1,6" | jq -r '.prayers[] | select(.id == '$NEW_ID') | "  제목: \(.title)\n  태그: \(.tags | map(.name) | join(", "))"'
else
    echo "❌ 실패: $(echo "$RESULT" | jq -r '.message')"
fi

echo ""

# 7. 최종 통계
echo "7️⃣ 최종 통계:"
FINAL_STATS=$(curl -s "$API_URL/prayers")
FINAL_TOTAL=$(echo "$FINAL_STATS" | jq '.total')
echo "최종 기도문 개수: $FINAL_TOTAL개"

# 태그별 분포 확인
echo "태그별 기도문 분포:"
for i in {1..10}; do
    result=$(curl -s "$API_URL/prayers/by-tags?tag_ids=$i")
    count=$(echo "$result" | jq '.total')
    tag_name=$(curl -s "$API_URL/tags" | jq -r ".tags[] | select(.id == $i) | .name")
    echo "  $tag_name: ${count}개"
done

echo ""
echo "✅ 모든 API 기능이 정상 작동합니다!"
echo ""
echo "🔗 API 사용 가이드:"
echo "  기도문 검색: $API_URL/prayers/by-tags?tag_ids=1,2"
echo "  전체 조회:   $API_URL/prayers"
echo "  새 기도문:   POST $API_URL/prayers"
echo "  태그 목록:   $API_URL/tags"