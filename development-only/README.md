# 개발 전용 파일 (Development Only)

이 디렉토리는 **개발 및 테스트 용도**의 파일들을 포함합니다.
프로덕션 배포에는 사용되지 않습니다.

## 📋 파일 목록

### 🐳 Docker 관련 (백업/참고용, 미사용)
```
Dockerfile              - 애플리케이션 Docker 이미지
docker-compose.yml      - Docker Compose 설정
.dockerignore          - Docker 빌드 제외 파일
```

**참고**: 현재 프로젝트는 Docker를 사용하지 않습니다.
- 네이티브 Go 바이너리 방식 채택
- Docker 파일은 백업/참고용으로 보관

### 🚀 EC2 배포 스크립트
```
setup-ec2.sh           - EC2 초기 환경 구축 (30분)
update-app.sh          - 애플리케이션 업데이트 (3분)
test-aws-params.sh     - AWS Parameter Store 테스트
```

### 🗄️ 데이터베이스 스크립트
```
init-db.sh             - PostgreSQL 초기 설정
```

## 🎯 배포 전략

현재 프로젝트는 **네이티브 Go 바이너리 + .env 설정** 방식을 사용합니다.

### 왜 Docker를 사용하지 않는가?

**프로젝트 특성**:
- ✅ 규모가 작음 (Go 파일 10개 미만)
- ✅ 의존성 단순함 (PostgreSQL만)
- ✅ 단일 서버 배포
- ✅ 네이티브가 더 빠르고 효율적

**Docker 대신 선택**:
- 네이티브 Go 바이너리 (더 빠름)
- .env 파일 설정 (더 간단함)
- Systemd 서비스 관리 (AWS EC2 네이티브)

**비용 절감**:
- Docker: t3.small 필요 ($14/월)
- 네이티브: t3.micro 충분 ($7/월)
- **50% 절감**

## 📚 참고 문서

- [QUICK_START.md](../docs/QUICK_START.md) - 5분 시작 가이드
- [SIMPLE_DEPLOYMENT.md](../docs/SIMPLE_DEPLOYMENT.md) - 심플 배포
- [EC2_DEPLOYMENT.md](../docs/EC2_DEPLOYMENT.md) - 전체 AWS 배포
- [DEPLOYMENT.md](../docs/DEPLOYMENT.md) - 네이티브 배포 전략

---

**작성일**: 2025년 10월 3일
**업데이트**: 2025년 10월 3일
