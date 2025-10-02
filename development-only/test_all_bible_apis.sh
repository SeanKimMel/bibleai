#!/bin/bash

# 모든 성경 API 전수조사 스크립트
# 모든 책과 장을 테스트하여 오류를 찾습니다

BASE_URL="http://localhost:8080"
RESULTS_FILE="bible_api_test_results.txt"
ERRORS_FILE="bible_api_errors.txt"

echo "🔍 성경 API 전수조사 시작 ($(date))" | tee $RESULTS_FILE
echo "📊 오류 목록" > $ERRORS_FILE

# 서버 상태 확인
echo "📡 서버 상태 확인..." | tee -a $RESULTS_FILE
if ! curl -s "$BASE_URL/health" | grep -q "healthy"; then
    echo "❌ 서버가 실행되지 않거나 응답하지 않습니다" | tee -a $RESULTS_FILE
    exit 1
fi
echo "✅ 서버 정상 동작" | tee -a $RESULTS_FILE

# 데이터베이스에서 모든 책과 장 조합 가져오기
echo "📚 데이터베이스에서 책과 장 조합 조회..." | tee -a $RESULTS_FILE

# PostgreSQL 쿼리 실행하여 모든 책-장 조합을 가져옴
BOOK_CHAPTERS=$(psql -h localhost -U bibleai -d bibleai -t -c "
SELECT book_id || ',' || chapter as book_chapter
FROM bible_verses
WHERE book_id IS NOT NULL
GROUP BY book_id, chapter
ORDER BY book_id, chapter;
")

if [ -z "$BOOK_CHAPTERS" ]; then
    echo "❌ 데이터베이스에서 책 정보를 가져올 수 없습니다" | tee -a $RESULTS_FILE
    exit 1
fi

TOTAL_TESTS=0
SUCCESS_COUNT=0
ERROR_COUNT=0

echo "🚀 API 테스트 시작..." | tee -a $RESULTS_FILE

# 각 책-장 조합 테스트
while IFS= read -r line; do
    # 공백 제거
    line=$(echo "$line" | tr -d ' ')

    if [ -z "$line" ]; then
        continue
    fi

    # book_id와 chapter 분리
    book_id=$(echo "$line" | cut -d',' -f1)
    chapter=$(echo "$line" | cut -d',' -f2)

    if [ -z "$book_id" ] || [ -z "$chapter" ]; then
        continue
    fi

    TOTAL_TESTS=$((TOTAL_TESTS + 1))

    # API 호출 테스트
    URL="$BASE_URL/api/bible/chapters/$book_id/$chapter"

    # curl로 API 호출하고 응답 확인
    RESPONSE=$(curl -s -w "HTTP_CODE:%{http_code}" "$URL")
    HTTP_CODE=$(echo "$RESPONSE" | grep "HTTP_CODE:" | cut -d':' -f2)
    RESPONSE_BODY=$(echo "$RESPONSE" | sed 's/HTTP_CODE:[0-9]*$//')

    if [ "$HTTP_CODE" = "200" ]; then
        # JSON 응답 검증
        TOTAL_VERSES=$(echo "$RESPONSE_BODY" | jq -r '.total_verses // empty' 2>/dev/null)

        if [ -n "$TOTAL_VERSES" ] && [ "$TOTAL_VERSES" != "null" ]; then
            SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
            echo "✅ $book_id $chapter장: $TOTAL_VERSES절" | tee -a $RESULTS_FILE
        else
            ERROR_COUNT=$((ERROR_COUNT + 1))
            echo "⚠️  $book_id $chapter장: HTTP 200이지만 응답 구조 이상" | tee -a $RESULTS_FILE
            echo "URL: $URL" >> $ERRORS_FILE
            echo "Response: $RESPONSE_BODY" >> $ERRORS_FILE
            echo "---" >> $ERRORS_FILE
        fi
    else
        ERROR_COUNT=$((ERROR_COUNT + 1))
        ERROR_MSG=$(echo "$RESPONSE_BODY" | jq -r '.error // empty' 2>/dev/null)
        if [ -z "$ERROR_MSG" ]; then
            ERROR_MSG="HTTP $HTTP_CODE"
        fi

        echo "❌ $book_id $chapter장: $ERROR_MSG" | tee -a $RESULTS_FILE
        echo "URL: $URL" >> $ERRORS_FILE
        echo "HTTP Code: $HTTP_CODE" >> $ERRORS_FILE
        echo "Response: $RESPONSE_BODY" >> $ERRORS_FILE
        echo "---" >> $ERRORS_FILE
    fi

    # 진행률 표시 (10의 배수마다)
    if [ $((TOTAL_TESTS % 10)) -eq 0 ]; then
        echo "📊 진행률: $TOTAL_TESTS 테스트 완료 (성공: $SUCCESS_COUNT, 실패: $ERROR_COUNT)"
    fi

    # 서버 과부하 방지를 위한 짧은 대기
    sleep 0.1

done <<< "$BOOK_CHAPTERS"

echo "" | tee -a $RESULTS_FILE
echo "📊 전수조사 완료 결과:" | tee -a $RESULTS_FILE
echo "- 총 테스트: $TOTAL_TESTS" | tee -a $RESULTS_FILE
echo "- 성공: $SUCCESS_COUNT" | tee -a $RESULTS_FILE
echo "- 실패: $ERROR_COUNT" | tee -a $RESULTS_FILE
echo "- 성공률: $(echo "scale=2; $SUCCESS_COUNT * 100 / $TOTAL_TESTS" | bc -l)%" | tee -a $RESULTS_FILE

if [ $ERROR_COUNT -gt 0 ]; then
    echo "" | tee -a $RESULTS_FILE
    echo "❌ $ERROR_COUNT개의 오류가 발견되었습니다" | tee -a $RESULTS_FILE
    echo "📄 상세 오류 정보: $ERRORS_FILE" | tee -a $RESULTS_FILE
    exit 1
else
    echo "" | tee -a $RESULTS_FILE
    echo "🎉 모든 API 테스트 성공!" | tee -a $RESULTS_FILE
    exit 0
fi