#!/bin/bash

# 찬송가 데이터 Import 스크립트
# 사용법: ./import_hymns.sh [JSON_FILE]

set -e

SERVER_URL="http://localhost:8080"
DEFAULT_FILE="hymns_import_example.json"

# 파일명 파라미터 처리
JSON_FILE=${1:-$DEFAULT_FILE}

echo "🎵 찬송가 데이터 Import 시작..."
echo "📁 파일: $JSON_FILE"
echo "🔗 서버: $SERVER_URL"

# 파일 존재 확인
if [[ ! -f "$JSON_FILE" ]]; then
    echo "❌ 파일을 찾을 수 없습니다: $JSON_FILE"
    echo "💡 사용법: $0 [JSON파일명]"
    echo "📄 예시 파일: $DEFAULT_FILE"
    exit 1
fi

# 서버 상태 확인
echo "🔍 서버 상태 확인 중..."
if ! curl -s "$SERVER_URL/health" > /dev/null; then
    echo "❌ 서버에 연결할 수 없습니다. 서버가 실행 중인지 확인하세요."
    echo "🚀 서버 시작: ./server.sh start"
    exit 1
fi

echo "✅ 서버 연결 확인됨"

# JSON 파일 유효성 검사
echo "📝 JSON 파일 유효성 검사 중..."
if ! jq empty "$JSON_FILE" 2>/dev/null; then
    echo "❌ 유효하지 않은 JSON 파일입니다: $JSON_FILE"
    exit 1
fi

# 데이터 개수 확인
HYMN_COUNT=$(jq length "$JSON_FILE")
echo "📊 Import할 찬송가 개수: $HYMN_COUNT개"

# API 호출
echo "📤 데이터 전송 중..."
RESPONSE=$(curl -s -X POST \
    -H "Content-Type: application/json" \
    -d @"$JSON_FILE" \
    "$SERVER_URL/api/admin/import/hymns")

# 응답 처리
echo "📥 서버 응답:"
echo "$RESPONSE" | jq .

# 결과 확인
SUCCESS=$(echo "$RESPONSE" | jq -r '.success // false')
if [[ "$SUCCESS" == "true" ]]; then
    SUCCESS_COUNT=$(echo "$RESPONSE" | jq -r '.success_count // 0')
    ERROR_COUNT=$(echo "$RESPONSE" | jq -r '.error_count // 0')

    echo ""
    echo "✅ Import 완료!"
    echo "📊 성공: $SUCCESS_COUNT개"
    echo "❌ 실패: $ERROR_COUNT개"

    if [[ "$ERROR_COUNT" -gt 0 ]]; then
        echo "⚠️  오류 내용:"
        echo "$RESPONSE" | jq -r '.errors[]? // empty'
    fi
else
    echo ""
    echo "❌ Import 실패"
    ERROR_MSG=$(echo "$RESPONSE" | jq -r '.error // "알 수 없는 오류"')
    echo "💬 오류: $ERROR_MSG"
    exit 1
fi

echo ""
echo "🎵 찬송가 Import 완료!"
echo "🔍 확인: curl -s '$SERVER_URL/api/hymns/search' | jq '.total'"