#!/bin/bash
# 블로그 생성 파이프라인 통합 실행 스크립트

set -e  # 에러 발생시 즉시 종료

# 스크립트 디렉토리 확인
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

# .env 파일 로드
if [ -f "../.env" ]; then
    export $(cat ../.env | grep -v '^#' | xargs)
fi

# 환경변수 확인
MAX_RETRY_ATTEMPTS=${MAX_RETRY_ATTEMPTS:-3}
QUALITY_THRESHOLD=${QUALITY_THRESHOLD:-7.0}

# 사용법 출력
function usage() {
    echo "사용법: $0 <keyword> [date]"
    echo ""
    echo "예시:"
    echo "  $0 평안"
    echo "  $0 평안 2025-10-15"
    echo ""
    echo "환경변수:"
    echo "  GEMINI_API_KEY      - Gemini API 키 (필수)"
    echo "  QUALITY_THRESHOLD   - 최소 품질 점수 (기본값: 7.0)"
    echo "  MAX_RETRY_ATTEMPTS  - 최대 재시도 횟수 (기본값: 3)"
    exit 1
}

# 매개변수 확인
if [ -z "$1" ]; then
    usage
fi

KEYWORD=$1
DATE=${2:-$(date +%Y-%m-%d)}

# API 키 확인
if [ -z "$GEMINI_API_KEY" ]; then
    echo "❌ GEMINI_API_KEY가 설정되지 않았습니다."
    echo "   .env 파일에 API 키를 추가하세요."
    exit 1
fi

echo "=================================================="
echo "🤖 블로그 자동 생성 시작"
echo "=================================================="
echo "  키워드: $KEYWORD"
echo "  날짜: $DATE"
echo "  품질 기준: $QUALITY_THRESHOLD/10.0"
echo "  최대 시도: $MAX_RETRY_ATTEMPTS회"
echo "=================================================="
echo ""

# 서버 실행 여부 확인
echo "🔍 서버 연결 확인 중..."
if ! curl -s -f http://localhost:8080/health > /dev/null 2>&1; then
    echo "❌ 서버가 실행되지 않았거나 응답하지 않습니다."
    echo ""
    echo "서버를 먼저 실행해주세요:"
    echo "  cd /workspace/bibleai"
    echo "  go run cmd/server/main.go"
    echo ""
    echo "또는:"
    echo "  ./development-only/start.sh"
    exit 1
fi
echo "✅ 서버 연결 확인 완료"
echo ""

# 출력 디렉토리 생성
OUTPUT_DIR="../output"
mkdir -p "$OUTPUT_DIR"

# 재시도 루프
for attempt in $(seq 1 $MAX_RETRY_ATTEMPTS); do
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "🔄 시도 #$attempt"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    # 1단계: 데이터 준비
    echo ""
    echo "📊 1단계: 데이터 준비"
    echo "─────────────────────────────────────────────"
    DATA_FILE="../data/${DATE}-${KEYWORD}.json"

    if ./prepare_data.sh "$KEYWORD" "$DATE"; then
        echo "✅ 데이터 준비 성공"
    else
        echo "❌ 데이터 준비 실패"
        exit 1
    fi

    # 2단계: 콘텐츠 생성
    echo ""
    echo "✍️  2단계: 블로그 콘텐츠 생성"
    echo "─────────────────────────────────────────────"
    CONTENT_FILE="$OUTPUT_DIR/${DATE}-${KEYWORD}.json"

    # Python 스크립트에 데이터 전달하여 실행
    if python3 generate_blog.py "$DATA_FILE" "$CONTENT_FILE"; then
        echo "✅ 콘텐츠 생성 성공"
    else
        echo "❌ 콘텐츠 생성 실패"
        if [ $attempt -lt $MAX_RETRY_ATTEMPTS ]; then
            echo "   다시 시도합니다..."
            continue
        else
            echo "   최대 재시도 횟수를 초과했습니다."
            exit 1
        fi
    fi

    # 3단계: 품질 평가
    echo ""
    echo "📊 3단계: 품질 평가"
    echo "─────────────────────────────────────────────"

    if python3 evaluate_quality.py "$CONTENT_FILE"; then
        echo ""
        echo "🎉 품질 평가 통과! 발행 준비 완료"
        echo ""
        echo "=================================================="
        echo "✅ 블로그 생성 완료"
        echo "=================================================="
        echo "  최종 파일: $CONTENT_FILE"
        echo "  시도 횟수: $attempt회"
        echo ""
        echo "💾 4단계: 데이터베이스 저장"
        echo "─────────────────────────────────────────────"

        # API를 통해 블로그 저장
        RESPONSE=$(curl -s -X POST http://localhost:8080/api/admin/blog/posts \
            -H "Content-Type: application/json" \
            -d @"$CONTENT_FILE")

        if echo "$RESPONSE" | grep -q '"success":true'; then
            BLOG_ID=$(echo "$RESPONSE" | jq -r '.id')
            echo "✅ 데이터베이스 저장 완료! (ID: $BLOG_ID)"
            echo ""
            echo "=================================================="
            echo "✅ 블로그 생성 및 발행 완료"
            echo "=================================================="
            echo "  블로그 ID: $BLOG_ID"
            echo "  제목: $(jq -r '.title' "$CONTENT_FILE")"
            echo "  슬러그: $(jq -r '.slug' "$CONTENT_FILE")"
            echo "  시도 횟수: $attempt회"
            echo ""
            echo "확인하기:"
            echo "  블로그 목록: http://localhost:8080/blog"
            echo "  블로그 상세: http://localhost:8080/blog/$(jq -r '.slug' "$CONTENT_FILE")"
            echo "=================================================="
            exit 0
        else
            echo "❌ 데이터베이스 저장 실패"
            echo "응답: $RESPONSE"
            echo ""
            echo "수동으로 저장하려면:"
            echo "  curl -X POST http://localhost:8080/api/admin/blog/posts -H 'Content-Type: application/json' -d @$CONTENT_FILE"
            exit 1
        fi
    else
        echo ""
        echo "⚠️  품질 평가 실패 (시도 #$attempt)"

        if [ $attempt -lt $MAX_RETRY_ATTEMPTS ]; then
            echo "   피드백을 반영하여 재생성합니다..."
            # 실패한 파일을 백업
            mv "$CONTENT_FILE" "${CONTENT_FILE}.failed-${attempt}"
            sleep 2
            continue
        else
            echo ""
            echo "=================================================="
            echo "❌ 최대 재시도 횟수 초과"
            echo "=================================================="
            echo "  시도 횟수: $MAX_RETRY_ATTEMPTS회"
            echo "  생성된 파일들:"
            for i in $(seq 1 $attempt); do
                failed_file="${CONTENT_FILE}.failed-${i}"
                if [ -f "$failed_file" ]; then
                    echo "    - 시도 #$i: $failed_file"
                fi
            done
            echo ""
            echo "권장사항:"
            echo "  1. 프롬프트 템플릿 수정 (prompts/blog_generation.txt)"
            echo "  2. 품질 기준 조정 (.env의 QUALITY_THRESHOLD)"
            echo "  3. 데이터 확인 ($DATA_FILE)"
            echo "=================================================="
            exit 1
        fi
    fi
done
