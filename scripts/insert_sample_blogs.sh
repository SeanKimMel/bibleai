#!/bin/bash
# 샘플 블로그 데이터 삽입 스크립트

API_URL="http://localhost:8080/api/admin/blog/posts"

echo "📝 샘플 블로그 데이터 삽입 시작..."
echo ""

# JSON 파일 읽기
while IFS= read -r post; do
    echo "삽입 중: $(echo $post | jq -r '.title')"

    response=$(curl -s -X POST "$API_URL" \
        -H "Content-Type: application/json" \
        -d "$post")

    if echo "$response" | jq -e '.success' > /dev/null 2>&1; then
        echo "✅ 성공: ID $(echo $response | jq -r '.id')"
    else
        echo "❌ 실패: $(echo $response | jq -r '.error')"
    fi
    echo ""
done < <(jq -c '.[]' sample_blog_data.json)

echo "✅ 샘플 블로그 데이터 삽입 완료!"
