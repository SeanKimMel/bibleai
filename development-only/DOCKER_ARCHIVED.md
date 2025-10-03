# Docker 사용하지 않음 (Archived)

## ⚠️ 중요 공지

**이 프로젝트는 Docker를 사용하지 않습니다.**

## 📁 Docker 파일들

다음 파일들은 **백업/참고용**으로만 보관됩니다:

- `Dockerfile` - 애플리케이션 이미지
- `docker-compose.yml` - Docker Compose 설정
- `.dockerignore` - Docker 빌드 제외 파일

## 🎯 왜 Docker를 사용하지 않는가?

### 프로젝트 특성
1. **규모가 작음**: Go 파일 10개 미만
2. **의존성 단순**: PostgreSQL 하나만
3. **단일 서버**: 복잡한 오케스트레이션 불필요
4. **AWS EC2**: 네이티브 배포가 더 효율적

### 비용 비교

| 방식 | 인스턴스 | 메모리 | 월 비용 |
|------|----------|--------|---------|
| **Docker** | t3.small | 2GB | $14/월 |
| **네이티브** | t3.micro | 1GB | $7/월 |
| **절감** | - | - | **50%** |

### 성능 비교

| 항목 | Docker | 네이티브 | 우위 |
|------|--------|----------|------|
| 메모리 오버헤드 | ~100MB | 0MB | 네이티브 |
| 시작 시간 | 5-10초 | 1-2초 | 네이티브 |
| 재배포 시간 | 2-3분 | 30초 | 네이티브 |
| 복잡도 | 높음 | 낮음 | 네이티브 |

## ✅ 현재 배포 방식

### 네이티브 Go 바이너리 + .env

**장점**:
- 🚀 더 빠른 시작 속도
- 💰 비용 50% 절감
- 🎯 간단한 설정 (.env 파일)
- 🔧 Systemd 네이티브 관리
- 📦 의존성 없음

**구조**:
```
EC2 인스턴스
├── Go 바이너리 (bibleai)
├── .env 파일 (설정)
├── Systemd 서비스
└── Nginx (리버스 프록시)
```

**배포 절차** (3분):
```bash
git pull
go build -o bibleai ./cmd/server
sudo systemctl restart bibleai
```

## 🔄 Docker로 되돌리고 싶다면?

이 디렉토리의 Docker 파일들을 루트로 이동:

```bash
cp development-only/Dockerfile .
cp development-only/docker-compose.yml .
cp development-only/.dockerignore .

docker-compose up --build
```

하지만 **권장하지 않습니다**. 네이티브 방식이 이 프로젝트에 더 적합합니다.

## 📚 참고 문서

- [DEPLOYMENT.md](../docs/DEPLOYMENT.md) - 네이티브 배포 전략
- [AMI_DEPLOYMENT.md](../docs/AMI_DEPLOYMENT.md) - AMI 골든 이미지
- [SIMPLE_DEPLOYMENT.md](../docs/SIMPLE_DEPLOYMENT.md) - 심플 배포

---

**결론**: Small project, simple solution. Docker는 오버엔지니어링입니다.

**작성일**: 2025년 10월 3일
