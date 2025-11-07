#!/bin/bash
# JSON 파일을 데이터베이스에 저장하는 스크립트

set -e

# 사용법 출력
function usage() {
    echo "사용법: $0 <json_file>"
    echo ""
    echo "예시:"
    echo "  $0 ../output/2025-10-15-사랑.json"
    exit 1
}

# 매개변수 확인
if [ -z "$1" ]; then
    usage
fi

JSON_FILE=$1

# 파일 존재 확인
if [ ! -f "$JSON_FILE" ]; then
    echo "❌ 파일을 찾을 수 없습니다: $JSON_FILE"
    exit 1
fi

echo "=================================================="
echo "💾 데이터베이스에 블로그 저장"
echo "=================================================="
echo "  파일: $JSON_FILE"
echo ""

# JSON에서 필드 추출
TITLE=$(jq -r '.title' "$JSON_FILE")
SLUG=$(jq -r '.slug' "$JSON_FILE")
CONTENT=$(jq -r '.content' "$JSON_FILE")
EXCERPT=$(jq -r '.excerpt' "$JSON_FILE")
KEYWORDS=$(jq -r '.keywords' "$JSON_FILE")

# 필수 필드 확인
if [ -z "$TITLE" ] || [ "$TITLE" == "null" ]; then
    echo "❌ title 필드가 없습니다."
    exit 1
fi

if [ -z "$SLUG" ] || [ "$SLUG" == "null" ]; then
    echo "❌ slug 필드가 없습니다."
    exit 1
fi

if [ -z "$CONTENT" ] || [ "$CONTENT" == "null" ]; then
    echo "❌ content 필드가 없습니다."
    exit 1
fi

echo "📝 추출된 데이터:"
echo "  제목: $TITLE"
echo "  슬러그: $SLUG"
echo "  키워드: $KEYWORDS"
echo ""

# PostgreSQL에 데이터 삽입
# ON CONFLICT를 사용하여 중복 slug가 있으면 업데이트
PGPASSWORD=bibleai psql -h localhost -U bibleai -d bibleai <<EOF
INSERT INTO blog_posts (title, slug, content, excerpt, keywords, is_published)
VALUES (
    '$TITLE',
    '$SLUG',
    \$content\$
$CONTENT
\$content\$,
    '$EXCERPT',
    '$KEYWORDS',
    true
)
ON CONFLICT (slug)
DO UPDATE SET
    title = EXCLUDED.title,
    content = EXCLUDED.content,
    excerpt = EXCLUDED.excerpt,
    keywords = EXCLUDED.keywords,
    updated_at = now();
EOF

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ 데이터베이스에 저장 완료!"
    echo ""
    echo "확인: http://localhost:8080/blog"
    echo "=================================================="
else
    echo ""
    echo "❌ 데이터베이스 저장 실패"
    exit 1
fi
