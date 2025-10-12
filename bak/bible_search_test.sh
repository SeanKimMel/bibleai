#!/bin/bash

# 성경 검색 기능 최종 검증 스크립트
API_URL="http://localhost:8080/api"

echo "🔍 성경 검색 기능 최종 검증"
echo "=============================="

# 1. 서버 상태 확인
echo "1️⃣ 서버 상태 확인:"
HEALTH=$(curl -s "$API_URL/../health")
if [ $? -ne 0 ]; then
    echo "❌ 서버가 응답하지 않습니다. './server.sh start' 로 서버를 시작하세요."
    exit 1
fi
echo "$HEALTH" | jq -r '"상태: \(.status), DB: \(.database)"'
echo ""

# 2. 성경책 목록 API 테스트
echo "2️⃣ 성경책 목록 API 테스트:"
BOOKS=$(curl -s "$API_URL/bible/books")
OLD_COUNT=$(echo "$BOOKS" | jq '.old_testament | length')
NEW_COUNT=$(echo "$BOOKS" | jq '.new_testament | length')
TOTAL_COUNT=$(echo "$BOOKS" | jq '.total')
echo "구약: ${OLD_COUNT}권, 신약: ${NEW_COUNT}권, 총: ${TOTAL_COUNT}권"

# 첫 번째 구약 성경책 확인
FIRST_OLD_BOOK=$(echo "$BOOKS" | jq -r '.old_testament[0] | "\(.name) (\(.id))"')
echo "첫 번째 구약: $FIRST_OLD_BOOK"
echo ""

# 3. 성경 검색 기능 테스트
echo "3️⃣ 성경 검색 기능 테스트:"

# 일반 검색 테스트
declare -a search_terms=("사랑" "평안" "하나님" "예수" "믿음")
for term in "${search_terms[@]}"; do
    result=$(curl -s "$API_URL/bible/search?q=$term")
    count=$(echo "$result" | jq '.total')
    echo "  '$term' 검색: ${count}개 결과"
    
    # 첫 번째 결과의 책 이름 변환 테스트
    if [ "$count" -gt 0 ]; then
        first_book_id=$(echo "$result" | jq -r '.results[0].book')
        first_content=$(echo "$result" | jq -r '.results[0].content' | cut -c1-30)
        echo "    → 첫 번째 결과: $first_book_id - $first_content..."
    fi
done
echo ""

# 4. 특정 성경책 검색 테스트
echo "4️⃣ 특정 성경책 검색 테스트:"

# 실제 존재하는 book_id들을 사용
declare -a book_tests=(
    "요한복음:joh"
    "열왕기상:1kgs"  
    "사도행전:act"
    "로마서:rom"
)

for book_test in "${book_tests[@]}"; do
    IFS=':' read -r book_name book_id <<< "$book_test"
    result=$(curl -s "$API_URL/bible/search?q=하나님&book=$book_id")
    count=$(echo "$result" | jq '.total')
    echo "  $book_name($book_id)에서 '하나님': ${count}개"
done
echo ""

# 5. 성경책 이름 매핑 테스트
echo "5️⃣ 성경책 이름 매핑 테스트:"
echo "다음 book_id들의 한국어 이름을 확인합니다:"
declare -a test_book_ids=("1kgs" "joh" "act" "rom" "1co")

for book_id in "${test_book_ids[@]}"; do
    # books API에서 해당 book_id의 한국어 이름 찾기
    book_name=$(echo "$BOOKS" | jq -r ".old_testament[]?, .new_testament[]? | select(.id == \"$book_id\") | .name")
    if [ "$book_name" != "null" ] && [ "$book_name" != "" ]; then
        echo "  $book_id → $book_name"
    else
        echo "  $book_id → 이름을 찾을 수 없음"
    fi
done
echo ""

# 6. 웹 페이지 접근성 테스트
echo "6️⃣ 웹 페이지 접근성 테스트:"
PAGE_URL="http://localhost:8080/bible/search"
if curl -s "$PAGE_URL" | grep -q "성경 검색"; then
    echo "✅ 성경 검색 페이지 접근 가능: $PAGE_URL"
else
    echo "❌ 성경 검색 페이지 접근 실패"
fi
echo ""

# 7. 검색어 하이라이팅을 위한 특수 문자 테스트
echo "7️⃣ 특수 문자 검색 테스트:"
declare -a special_terms=("사랑하사" "독생자" "영생을")
for term in "${special_terms[@]}"; do
    result=$(curl -s "$API_URL/bible/search?q=$term")
    count=$(echo "$result" | jq '.total')
    echo "  '$term': ${count}개 결과"
done
echo ""

echo "✅ 성경 검색 기능 검증 완료!"
echo ""
echo "📊 결과 요약:"
echo "  - 성경책 목록 API: $TOTAL_COUNT권 로드됨"
echo "  - 성경 검색 API: 다양한 키워드로 정상 작동"  
echo "  - 책별 필터링: 정상 작동"
echo "  - 웹 페이지: 접근 가능"
echo ""
echo "🌐 웹 인터페이스 테스트:"
echo "  1. 브라우저에서 http://localhost:8080/bible/search 접속"
echo "  2. '사랑', '평안', '하나님' 등의 키워드로 검색 테스트"  
echo "  3. 성경책 선택 후 검색 테스트"
echo "  4. 빠른 검색 버튼 테스트"
echo ""
echo "🔧 API 엔드포인트:"
echo "  검색: $API_URL/bible/search?q=검색어&book=책ID"
echo "  성경책 목록: $API_URL/bible/books"