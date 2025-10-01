# 보안 가이드

## 환경 변수 설정

프로젝트를 처음 설정할 때 다음 단계를 따르세요:

### 1. 환경 변수 파일 생성

```bash
cp .env.example .env
```

### 2. .env 파일 수정

`.env` 파일을 열어 실제 데이터베이스 계정 정보로 수정하세요:

```bash
LOCAL_DB_HOST=localhost
LOCAL_DB_PORT=5432
LOCAL_DB_USER=your_actual_username
LOCAL_DB_PASSWORD=your_secure_password
LOCAL_DB_SSLMODE=disable
```

## 보안 주의사항

### ⚠️ 절대 커밋하지 말아야 할 것들

- `.env` 파일 (실제 비밀번호 포함)
- `*.log` 파일 (로그에 민감한 정보 포함 가능)
- `*.pid` 파일
- 데이터베이스 백업 파일 (`*.backup`, `*.dump`)
- 빌드된 바이너리 (`bibleai`, `server`)

### ✅ 커밋해도 되는 것들

- `.env.example` (예제 파일, 실제 값 없음)
- 소스 코드 (`.go`, `.html`, `.js`, `.css`)
- 문서 파일 (`.md`)
- 마이그레이션 스크립트 (비밀번호 없는 SQL)
- 설정 파일 (민감한 정보 없는)

## PostgreSQL 보안 설정

### 로컬 개발 환경

로컬 개발에서는 `.pgpass` 파일을 사용하여 비밀번호를 관리합니다:

```bash
# ~/.pgpass 파일 생성 (Linux/Mac)
echo "localhost:5432:bibleai:bibleai:bibleai123" > ~/.pgpass
chmod 600 ~/.pgpass
```

### 프로덕션 환경

프로덕션 환경에서는:
1. 강력한 비밀번호 사용 (최소 16자, 대소문자, 숫자, 특수문자 혼합)
2. SSL/TLS 연결 활성화 (`DB_SSLMODE=require`)
3. 데이터베이스 접근을 특정 IP로 제한
4. 정기적인 비밀번호 변경
5. 최소 권한 원칙 적용

## Git 보안

### 실수로 민감한 정보를 커밋한 경우

```bash
# 특정 파일을 Git 히스토리에서 완전히 제거
git filter-branch --force --index-filter \
  "git rm --cached --ignore-unmatch .env" \
  --prune-empty --tag-name-filter cat -- --all

# 강제 푸시 (주의: 협업 시 팀원들과 조율 필요)
git push origin --force --all
```

더 안전한 방법은 BFG Repo-Cleaner를 사용하는 것입니다.

## 데이터베이스 접근 권한

### 애플리케이션 전용 사용자 생성

```sql
-- 최소 권한 사용자 생성
CREATE USER bibleai_app WITH PASSWORD 'secure_password';

-- 필요한 권한만 부여
GRANT CONNECT ON DATABASE bibleai TO bibleai_app;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO bibleai_app;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO bibleai_app;
```

## API 보안

현재 구현된 보안 기능:
- SQL Injection 방지 (Prepared Statements)
- XSS 방지 (Go 템플릿 자동 이스케이핑)
- CORS 설정

### 향후 추가 필요 사항

1. **Rate Limiting**: API 요청 횟수 제한
2. **JWT 인증**: 관리자 기능 보호
3. **HTTPS**: SSL/TLS 인증서 적용
4. **입력 검증**: 모든 사용자 입력 검증 강화
5. **CSRF 토큰**: Cross-Site Request Forgery 방지

## 문의

보안 취약점을 발견하셨다면 공개 이슈 대신 이메일로 연락주세요.