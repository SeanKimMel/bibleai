#!/bin/bash

# 운영 DB 타임존 마이그레이션 스크립트
# 실행: ./scripts/migrate_production_timezone.sh

set -e

echo "========================================="
echo "운영 DB 타임존 마이그레이션"
echo "========================================="
echo ""

# .env 파일에서 DB 정보 읽기
if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
else
    echo "❌ .env 파일을 찾을 수 없습니다."
    exit 1
fi

# DB 연결 정보 확인
echo "📋 DB 연결 정보:"
echo "   Host: $DB_HOST"
echo "   Port: $DB_PORT"
echo "   User: $DB_USER"
echo "   Database: $DB_NAME"
echo ""

# 확인 메시지
read -p "⚠️  운영 DB에 마이그레이션을 실행하시겠습니까? (yes/no): " confirm
if [ "$confirm" != "yes" ]; then
    echo "❌ 마이그레이션이 취소되었습니다."
    exit 0
fi

echo ""
echo "🔍 1단계: 현재 타임존 설정 확인 중..."
CURRENT_TZ=$(PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -U $DB_USER -d $DB_NAME -t -c "SHOW timezone;")
echo "   현재 타임존: $CURRENT_TZ"
echo ""

echo "📊 2단계: 마이그레이션 전 데이터 샘플 확인 중..."
PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -U $DB_USER -d $DB_NAME -c "SELECT id, title, created_at, published_at FROM blog_posts ORDER BY id DESC LIMIT 3;"
echo ""

echo "🚀 3단계: 마이그레이션 실행 중..."
PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -U $DB_USER -d $DB_NAME -f migrations/017_add_timezone_support.sql

if [ $? -eq 0 ]; then
    echo "✅ 마이그레이션 완료!"
else
    echo "❌ 마이그레이션 실패!"
    exit 1
fi

echo ""
echo "🔍 4단계: 마이그레이션 후 데이터 확인 중..."
PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -U $DB_USER -d $DB_NAME -c "SELECT id, title, created_at, published_at FROM blog_posts ORDER BY id DESC LIMIT 3;"
echo ""

echo "🔍 5단계: 새로운 타임존 설정 확인 중..."
NEW_TZ=$(PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -U $DB_USER -d $DB_NAME -t -c "SHOW timezone;")
echo "   새로운 타임존: $NEW_TZ"
echo ""

echo "========================================="
echo "✅ 마이그레이션 완료!"
echo "========================================="
echo ""
echo "📝 변경사항:"
echo "   - TIMESTAMP → TIMESTAMPTZ 변환"
echo "   - 타임존: $CURRENT_TZ → $NEW_TZ"
echo "   - 기존 데이터는 Asia/Seoul 기준으로 변환됨"
echo "   - 해외에서도 한국 시간 기준으로 표기됨"
echo ""
