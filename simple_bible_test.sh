#!/bin/bash

# 간단한 성경 API 테스트 스크립트
echo "🔍 성경 API 샘플 테스트 시작"

BASE_URL="http://localhost:8080"
test_cases=(
    "gn/1"     # 창세기 1장
    "ex/1"     # 출애굽기 1장
    "ps/1"     # 시편 1장
    "ps/23"    # 시편 23편
    "is/53"    # 이사야 53장
    "mt/1"     # 마태복음 1장
    "jo/3"     # 요한복음 3장
    "rm/8"     # 로마서 8장
    "1co/13"   # 고린도전서 13장
    "job/41"   # 욥기 41장 (우리가 수정한 것)
    "job/42"   # 욥기 42장
    "1pe/5"    # 베드로전서 5장 (우리가 추가한 것)
)

success_count=0
total_tests=${#test_cases[@]}

for test_case in "${test_cases[@]}"; do
    echo -n "Testing $test_case: "

    response=$(curl -s "http://localhost:8080/api/bible/chapters/$test_case")
    total_verses=$(echo "$response" | jq -r '.total_verses // empty' 2>/dev/null)

    if [ -n "$total_verses" ] && [ "$total_verses" != "null" ]; then
        echo "✅ $total_verses verses"
        success_count=$((success_count + 1))
    else
        echo "❌ Failed"
        echo "   Response: $response"
    fi
done

echo ""
echo "📊 Test Results: $success_count/$total_tests successful"

if [ $success_count -eq $total_tests ]; then
    echo "🎉 All sample tests passed!"
    exit 0
else
    echo "⚠️  Some tests failed"
    exit 1
fi