#!/bin/bash
# Docker 기반 애플리케이션 배포 스크립트

set -e

# 설정
APP_NAME="bibleai"
APP_DIR="/home/ec2-user/bibleai"
REPO_URL="https://github.com/{사용자명}/{저장소명}.git"  # 실제 값으로 변경 필요
CONTAINER_NAME="bibleai"
IMAGE_NAME="bibleai:latest"
PORT="8080"

echo "🚀 $APP_NAME 애플리케이션 배포 시작..."

# 1. 저장소 클론 또는 업데이트
if [ -d "$APP_DIR" ]; then
    echo "📥 기존 코드 업데이트..."
    cd $APP_DIR
    git pull origin main
else
    echo "📥 저장소 클론..."
    git clone $REPO_URL $APP_DIR
    cd $APP_DIR
fi

# 2. 환경 변수 파일 확인
if [ ! -f ".env" ]; then
    echo "❌ .env 파일이 없습니다!"
    echo ""
    echo "📝 다음 명령어로 .env 파일을 생성하세요:"
    echo "   cp .env.example .env"
    echo "   nano .env"
    echo ""
    echo "필수 환경 변수:"
    echo "   - LOCAL_DB_HOST"
    echo "   - LOCAL_DB_PORT"
    echo "   - LOCAL_DB_USER"
    echo "   - LOCAL_DB_PASSWORD"
    exit 1
fi

# 3. Docker 이미지 빌드
echo "🏗️  Docker 이미지 빌드..."
docker build -t $IMAGE_NAME .

# 4. 기존 컨테이너 중지 및 제거
echo "🛑 기존 컨테이너 중지..."
docker stop $CONTAINER_NAME 2>/dev/null || true
docker rm $CONTAINER_NAME 2>/dev/null || true

# 5. PostgreSQL 컨테이너 확인 (필요한 경우)
# if ! docker ps | grep -q postgres; then
#     echo "🐘 PostgreSQL 컨테이너 시작..."
#     docker run -d \
#       --name postgres \
#       --restart unless-stopped \
#       -e POSTGRES_DB=bibleai \
#       -e POSTGRES_USER=bibleai \
#       -e POSTGRES_PASSWORD=${DB_PASSWORD} \
#       -p 5432:5432 \
#       -v pgdata:/var/lib/postgresql/data \
#       postgres:16
# fi

# 6. 새 컨테이너 실행
echo "▶️  새 컨테이너 실행..."
docker run -d \
  --name $CONTAINER_NAME \
  --restart unless-stopped \
  -p $PORT:8080 \
  --env-file .env \
  $IMAGE_NAME

# 7. 헬스 체크
echo "🏥 헬스 체크 대기 중..."
sleep 5

for i in {1..10}; do
    if curl -f http://localhost:$PORT/api/health > /dev/null 2>&1; then
        echo "✅ 애플리케이션이 정상적으로 실행 중입니다!"
        echo ""
        echo "📍 접속 정보:"
        echo "   - 로컬: http://localhost:$PORT"
        echo "   - 외부: http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):$PORT"
        echo ""
        echo "📋 유용한 명령어:"
        echo "   - 로그 보기: docker logs -f $CONTAINER_NAME"
        echo "   - 컨테이너 중지: docker stop $CONTAINER_NAME"
        echo "   - 컨테이너 재시작: docker restart $CONTAINER_NAME"
        exit 0
    fi
    echo "  대기 중... ($i/10)"
    sleep 2
done

echo "❌ 헬스 체크 실패!"
echo "📋 컨테이너 로그:"
docker logs $CONTAINER_NAME
exit 1