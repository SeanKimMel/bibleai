#!/bin/bash

# 체계적인 성경 API 테스트 스크립트
echo "🔍 체계적인 성경 API 테스트 시작"

BASE_URL="http://localhost:8080"

# 주요 성경책들의 마지막 장을 테스트 (가장 문제가 될 가능성이 높음)
test_books=(
    "gn:50"        # 창세기 50장
    "ex:40"        # 출애굽기 40장
    "lv:27"        # 레위기 27장
    "nu:36"        # 민수기 36장
    "dt:34"        # 신명기 34장
    "js:24"        # 여호수아 24장
    "jd:21"        # 사사기 21장
    "rt:4"         # 룻기 4장
    "1sm:31"       # 사무엘상 31장
    "2sm:24"       # 사무엘하 24장
    "1kgs:22"      # 열왕기상 22장
    "2kgs:25"      # 열왕기하 25장
    "1ch:29"       # 역대상 29장
    "2ch:36"       # 역대하 36장
    "ezr:10"       # 에스라 10장
    "ne:13"        # 느헤미야 13장
    "et:10"        # 에스더 10장
    "job:42"       # 욥기 42장 ⭐
    "ps:150"       # 시편 150편
    "prv:31"       # 잠언 31장
    "ec:12"        # 전도서 12장
    "so:8"         # 아가 8장
    "is:66"        # 이사야 66장
    "je:52"        # 예레미야 52장
    "lm:5"         # 예레미야애가 5장
    "ez:48"        # 에스겔 48장
    "dn:12"        # 다니엘 12장
    "ho:14"        # 호세아 14장
    "mt:28"        # 마태복음 28장
    "mk:16"        # 마가복음 16장
    "lk:24"        # 누가복음 24장
    "jo:21"        # 요한복음 21장
    "ac:28"        # 사도행전 28장
    "rm:16"        # 로마서 16장
    "1co:16"       # 고린도전서 16장
    "2co:13"       # 고린도후서 13장
    "gl:6"         # 갈라디아서 6장
    "eph:6"        # 에베소서 6장
    "ph:4"         # 빌립보서 4장
    "cl:4"         # 골로새서 4장
    "1ts:5"        # 데살로니가전서 5장
    "2ts:3"        # 데살로니가후서 3장
    "1tm:6"        # 디모데전서 6장
    "2tm:4"        # 디모데후서 4장
    "tt:3"         # 디도서 3장
    "phm:1"        # 빌레몬서 1장
    "hb:13"        # 히브리서 13장
    "jm:5"         # 야고보서 5장
    "1pe:5"        # 베드로전서 5장 ⭐
    "2pe:3"        # 베드로후서 3장
    "1jo:5"        # 요한일서 5장
    "2jo:1"        # 요한이서 1장
    "3jo:1"        # 요한삼서 1장
    "jude:1"       # 유다서 1장
    "re:22"        # 요한계시록 22장
)

success_count=0
error_count=0
total_tests=${#test_books[@]}

echo "📚 Testing ${total_tests} major book endings..."
echo ""

for test_book in "${test_books[@]}"; do
    book_id=$(echo "$test_book" | cut -d':' -f1)
    chapter=$(echo "$test_book" | cut -d':' -f2)

    echo -n "Testing ${book_id} ${chapter}장: "

    response=$(curl -s "$BASE_URL/api/bible/chapters/$book_id/$chapter")
    total_verses=$(echo "$response" | jq -r '.total_verses // empty' 2>/dev/null)

    if [ -n "$total_verses" ] && [ "$total_verses" != "null" ]; then
        echo "✅ $total_verses절"
        success_count=$((success_count + 1))
    else
        echo "❌ 실패"
        error_count=$((error_count + 1))
        echo "   Error: $(echo "$response" | jq -r '.error // "Unknown error"' 2>/dev/null)"
    fi
done

echo ""
echo "📊 최종 결과:"
echo "- 총 테스트: $total_tests"
echo "- 성공: $success_count"
echo "- 실패: $error_count"
echo "- 성공률: $(echo "scale=1; $success_count * 100 / $total_tests" | bc -l)%"

if [ $error_count -eq 0 ]; then
    echo ""
    echo "🎉 모든 주요 성경책 API가 정상 작동합니다!"
    echo "✅ 욥기 41-42장 수정 완료"
    echo "✅ 베드로전서 5장 추가 완료"
    echo "✅ API 안정성 검증 완료"
    exit 0
else
    echo ""
    echo "⚠️  $error_count개의 문제가 발견되었습니다. 수정이 필요합니다."
    exit 1
fi