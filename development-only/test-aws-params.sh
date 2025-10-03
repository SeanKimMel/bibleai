#!/bin/bash

# AWS Parameter Store 로컬 테스트 스크립트
# 사용법: ./test-aws-params.sh [profile]

PROFILE=${1:-default}

echo "========================================="
echo "AWS Parameter Store 로컬 테스트"
echo "========================================="
echo ""

# AWS CLI 설치 확인
if ! command -v aws &> /dev/null; then
    echo "❌ AWS CLI가 설치되지 않았습니다."
    echo "   설치: brew install awscli (macOS)"
    echo "   설치: sudo apt install awscli (Ubuntu)"
    exit 1
fi

# AWS 자격 증명 확인
echo "1️⃣  AWS 자격 증명 확인..."
aws sts get-caller-identity --profile "$PROFILE" > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "❌ AWS 자격 증명이 설정되지 않았습니다."
    echo "   설정: aws configure --profile $PROFILE"
    exit 1
fi
echo "✅ AWS 자격 증명 확인 완료"
echo ""

# Parameter Store 파라미터 목록
PARAMS=(
    "/bibleai/db/host"
    "/bibleai/db/port"
    "/bibleai/db/username"
    "/bibleai/db/password"
    "/bibleai/db/name"
    "/bibleai/db/sslmode"
)

# 각 파라미터 테스트
echo "2️⃣  Parameter Store 접근 테스트..."
ALL_PASSED=true
for PARAM in "${PARAMS[@]}"; do
    VALUE=$(aws ssm get-parameter --name "$PARAM" --with-decryption --profile "$PROFILE" --query 'Parameter.Value' --output text 2>/dev/null)
    if [ $? -eq 0 ]; then
        if [ "$PARAM" == "/bibleai/db/password" ]; then
            echo "   ✅ $PARAM = ***"
        else
            echo "   ✅ $PARAM = $VALUE"
        fi
    else
        echo "   ❌ $PARAM (파라미터가 존재하지 않음)"
        ALL_PASSED=false
    fi
done
echo ""

# 최종 결과
if [ "$ALL_PASSED" = true ]; then
    echo "========================================="
    echo "✅ 모든 테스트 통과!"
    echo "========================================="
    echo ""
    echo "애플리케이션 실행:"
    echo "  export AWS_PROFILE=$PROFILE"
    echo "  export USE_AWS_PARAMS=true"
    echo "  ./server.sh start"
else
    echo "========================================="
    echo "❌ 일부 파라미터가 존재하지 않습니다."
    echo "========================================="
    echo ""
    echo "파라미터 생성 방법:"
    echo "  aws ssm put-parameter --profile $PROFILE \\"
    echo "    --name '/bibleai/db/password' \\"
    echo "    --value 'your-password' \\"
    echo "    --type 'SecureString'"
    exit 1
fi
