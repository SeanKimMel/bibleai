# 주님말씀AI 웹앱

Go + PostgreSQL로 구현된 모바일 우선 바이블 웹앱입니다.

## 기술 스택

- **Backend**: Go (Gin 프레임워크)
- **Database**: PostgreSQL
- **Frontend**: HTML Templates + Tailwind CSS
- **개발환경**: Docker Compose

## 프로젝트 구조

```
bible-app/
├── cmd/server/          # 메인 애플리케이션
├── internal/
│   ├── handlers/        # HTTP 핸들러들
│   ├── models/          # 데이터 모델들
│   ├── database/        # 데이터베이스 연결
│   └── middleware/      # 미들웨어
├── web/
│   ├── templates/       # HTML 템플릿
│   └── static/          # 정적 파일 (CSS, JS)
├── migrations/          # 데이터베이스 스키마
└── docker-compose.yml   # PostgreSQL 컨테이너
```

## 실행 방법

### 간편한 스크립트 사용 (추천)

#### 일반 실행
```bash
./start.sh    # 서버 시작
./stop.sh     # 서버 종료
```

#### 개발 모드 (자동 재시작)
```bash
./dev.sh      # 파일 변경시 자동 재시작
```

### 수동 실행

#### 1. PostgreSQL 시작
```bash
docker-compose up -d
```

#### 2. 애플리케이션 실행
```bash
go run cmd/server/main.go
```

#### 3. 확인
- 메인 페이지: http://localhost:8080
- 헬스 체크: http://localhost:8080/health
- 태그 API: http://localhost:8080/api/tags

## 스크립트 설명

- **start.sh**: PostgreSQL 컨테이너 시작 → 연결 대기 → Go 서버 실행
- **stop.sh**: Go 서버 종료 → PostgreSQL 컨테이너 종료
- **dev.sh**: 개발 모드로 실행 (파일 변경시 자동 재시작)

## 핵심 기능

### 현재 구현됨
- ✅ PostgreSQL 연결
- ✅ 기본 데이터베이스 스키마
- ✅ 태그 시스템
- ✅ 기본 API 엔드포인트

### 구현 예정
- 🔄 태그 기반 기도문 시스템
- 🔄 성경 검색 기능
- 🔄 찬송가 목록
- 🔄 HTML 템플릿 기반 웹 페이지
- 🔄 관리자 기능

## 환경 변수

```bash
DB_HOST=localhost       # 기본값
DB_PORT=5432           # 기본값
DB_USER=bibleai        # 기본값
DB_PASSWORD=bibleai123 # 기본값
DB_NAME=bibleai        # 기본값
DB_SSLMODE=disable     # 기본값
```

## 개발 상태

### ✅ 1단계: 기본 프로젝트 설정 (완료)
- ✅ Go 프로젝트 구조 생성
- ✅ Docker Compose PostgreSQL 설정  
- ✅ 기본 데이터베이스 연결
- ✅ 웹 서버 관리 스크립트 (start.sh, stop.sh, dev.sh)

### ✅ 2단계: 기본 웹 서버 구현 (완료)
- ✅ 기본 HTML 레이아웃 템플릿
- ✅ 메인 화면 (홈 페이지)
- ✅ 성경 검색 페이지
- ✅ 성경 분석 페이지 (더미)
- ✅ 찬송가 목록 페이지
- ✅ 기도문 찾기 페이지 (태그 기반)
- ✅ 모바일 우선 반응형 디자인
- ✅ JavaScript 유틸리티 및 PWA 준비
- ✅ 웹 페이지 라우팅

### 🔄 3단계: 태그/기도문 시스템 (진행 예정)
- 태그 CRUD API
- 기도문 CRUD API  
- 태그별 기도문 조회 기능
- 관리자 페이지 (기본 인증)