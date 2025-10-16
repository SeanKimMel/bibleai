#!/bin/bash
# 매일 자동으로 블로그 생성하는 스크립트

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
KEYWORDS_FILE="$SCRIPT_DIR/../keywords.txt"
LOG_DIR="$SCRIPT_DIR/../logs"
LOG_FILE="$LOG_DIR/daily_$(date +%Y%m%d).log"

# 로그 디렉토리 생성
mkdir -p "$LOG_DIR"

# 키워드 파일에서 랜덤하게 하나 선택
KEYWORD=$(shuf -n 1 "$KEYWORDS_FILE")
DATE=$(date +%Y-%m-%d)

echo "======================================" >> "$LOG_FILE"
echo "시작 시간: $(date)" >> "$LOG_FILE"
echo "키워드: $KEYWORD" >> "$LOG_FILE"
echo "날짜: $DATE" >> "$LOG_FILE"
echo "======================================" >> "$LOG_FILE"

# 블로그 생성 실행
cd "$SCRIPT_DIR"
./run_blog_generation.sh "$KEYWORD" "$DATE" >> "$LOG_FILE" 2>&1

EXIT_CODE=$?

if [ $EXIT_CODE -eq 0 ]; then
    echo "✅ 성공!" >> "$LOG_FILE"
else
    echo "❌ 실패 (Exit Code: $EXIT_CODE)" >> "$LOG_FILE"
fi

echo "완료 시간: $(date)" >> "$LOG_FILE"
echo "" >> "$LOG_FILE"

exit $EXIT_CODE
