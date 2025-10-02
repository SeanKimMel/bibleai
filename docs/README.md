# 📚 프로젝트 문서

이 디렉토리에는 주님말씀AI 프로젝트의 모든 문서가 포함되어 있습니다.

## 📖 문서 목록

### 🚀 시작하기
- **[README.md](../README.md)** - 프로젝트 개요 및 빠른 시작
- **[DEVELOPMENT.md](DEVELOPMENT.md)** - 개발 환경 설정 가이드
- **[DEPLOYMENT.md](DEPLOYMENT.md)** - AWS EC2 배포 가이드

### 🔐 보안 및 설정
- **[SECURITY.md](SECURITY.md)** - 보안 가이드 및 모범 사례
- **[AWS_SECRETS_GUIDE.md](AWS_SECRETS_GUIDE.md)** - AWS Secrets Manager 구현 가이드
- **[PARAMETER_STORE_SETUP.md](PARAMETER_STORE_SETUP.md)** - AWS Parameter Store 설정 (권장 ⭐)
- **[SECRETS_COMPARISON.md](SECRETS_COMPARISON.md)** - 비밀번호 관리 방법 비교
- **[DB_CONNECTION_GUIDE.md](DB_CONNECTION_GUIDE.md)** - 데이터베이스 연결 풀 가이드

### 🏗️ 아키텍처 및 기술
- **[CLAUDE.md](CLAUDE.md)** - Claude AI 참조 문서 (프로젝트 전체 컨텍스트)
- **[TECHNICAL.md](TECHNICAL.md)** - 기술 스택 및 아키텍처
- **[API.md](API.md)** - API 문서
- **[API_REFERENCE.md](API_REFERENCE.md)** - API 상세 레퍼런스
- **[PROJECT.md](PROJECT.md)** - 프로젝트 구조 및 설계

### 📐 코딩 가이드
- **[CONTENT_CONSISTENCY_RULES.md](CONTENT_CONSISTENCY_RULES.md)** - 콘텐츠 일관성 규칙

### 💰 비즈니스
- **[ADSENSE_READINESS.md](ADSENSE_READINESS.md)** - Google AdSense 승인 준비 가이드

### 📊 참조 자료
- **[bible_book_id_mapping.md](bible_book_id_mapping.md)** - 성경 책 ID 매핑 테이블
- **[LICENSE_NOTICE.md](LICENSE_NOTICE.md)** - 라이선스 정보

---

## 🗂️ 디렉토리 구조

```
bibleai/
├── README.md                    # 프로젝트 메인 README
├── docs/                        # 📚 모든 문서 (이 디렉토리)
│   ├── CLAUDE.md               # AI 참조 문서
│   ├── DEVELOPMENT.md          # 개발 가이드
│   ├── DEPLOYMENT.md           # 배포 가이드
│   ├── SECURITY.md             # 보안 가이드
│   └── ...
├── development-only/           # 🔧 개발 전용 파일
│   ├── dev.sh                  # 개발 서버 스크립트
│   ├── test_api.sh             # API 테스트
│   └── *_test.sh               # 각종 테스트 스크립트
├── migrations/                 # 📦 데이터베이스 마이그레이션
│   ├── 001_initial.sql
│   ├── 002_*.sql
│   └── commentary/             # 성경 해석 SQL 파일들
│       ├── genesis_commentary.sql
│       └── ...
├── cmd/                        # 🚀 메인 애플리케이션
├── internal/                   # 📦 내부 패키지
└── web/                        # 🎨 프론트엔드
```

---

## 🎯 문서별 용도

### 개발자용
- `CLAUDE.md` - 프로젝트 전체 컨텍스트 이해
- `DEVELOPMENT.md` - 로컬 환경 설정
- `TECHNICAL.md` - 기술 스택 이해
- `API.md` - API 개발

### DevOps용
- `DEPLOYMENT.md` - EC2 배포
- `PARAMETER_STORE_SETUP.md` - 비밀번호 관리
- `DB_CONNECTION_GUIDE.md` - DB 최적화
- `SECURITY.md` - 보안 설정

### 기획/비즈니스용
- `PROJECT.md` - 프로젝트 개요
- `ADSENSE_READINESS.md` - 수익화 준비

---

**프로젝트**: 주님말씀AI 웹앱
**버전**: v0.6.0
