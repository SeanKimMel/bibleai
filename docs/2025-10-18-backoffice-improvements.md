# 2025-10-18: 백오피스 개선 및 보안 강화

**날짜**: 2025-10-18
**작업자**: Claude
**관련 이슈**: 백오피스 배포, 보안 강화, UI 개선

## 📋 작업 개요

백오피스 시스템의 배포 자동화, 보안 강화, UI 개선 작업을 진행했습니다.

## 🎯 주요 작업 내용

### 1. 백오피스 배포 스크립트 생성

**파일**: `deploy_backoffice.sh` (신규)

#### 배경
- 기존 `deploy.sh`는 메인 서버만 배포
- 백오피스는 별도 바이너리(`cmd/backoffice/main.go`)로 독립 실행
- 백오피스 전용 배포 스크립트 필요

#### 구현 내용
```bash
#!/bin/bash
# deploy_backoffice.sh

# 1. Tailwind CSS 빌드
# 2. ARM64 백오피스 바이너리 빌드 (cmd/backoffice/main.go)
# 3. 백오피스 템플릿 전송 (web/backoffice/)
# 4. 백오피스 정적 파일 전송
# 5. 서버 재시작 (포트 9090)
```

#### 주요 특징
- 메인 서버와 독립적인 배포
- 백오피스 전용 템플릿 및 정적 파일 관리
- 로그 파일: `logs/deploy_backoffice_YYYYMMDD_HHMMSS.log`
- 프로세스 관리: `pkill backoffice`, `nohup ./backoffice`

### 2. 보안 강화

#### 2.1 .gitignore 업데이트

**파일**: `.gitignore`

**추가 항목**:
```gitignore
# 환경 변수
.env

# 빌드 산출물
bibleai
backoffice
server
*.pid
```

**목적**:
- API 키, 비밀번호 등 민감 정보 보호
- 빌드 산출물 및 프로세스 ID 파일 제외

#### 2.2 문서 내 민감 정보 제거

**수정된 파일**:
1. `docs/2025-10-16-gemini-blog-evaluation.md`
   - Gemini API 키 → `your_actual_api_key_here`

2. `docs/SEO_DEPLOYMENT.md`
   - EC2 IP (13.209.47.72) → `YOUR_EC2_IP` (8개 인스턴스)

3. `docs/CHANGELOG_2025-10-12.md`
   - EC2 IP → `YOUR_EC2_IP`

4. `docs/CLOUDFLARE_SETUP.md`
   - EC2 IP → `YOUR_EC2_IP` (3개 인스턴스)

5. `docs/HYMN_POPULAR_30_TODO.md`
   - `PGPASSWORD=bibleai` → `PGPASSWORD=${DB_PASSWORD}` (환경변수 사용)

#### 2.3 CLAUDE.md 보안 가이드라인 추가

**파일**: `docs/CLAUDE.md`

**추가된 섹션**: `🛡️ 보안 고려사항 > 🚨 민감 정보 보호 규칙 (최우선)`

**주요 내용**:
1. **민감 정보 목록**:
   - API 키, 인프라 정보, DB 비밀번호, 비밀값

2. **안전한 관리 방법**:
   - ✅ 환경변수 사용, 플레이스홀더 사용
   - ❌ 실제 값 노출 금지

3. **Git 보호 설정**:
   - .gitignore 필수 항목

4. **문서 작성 가이드**:
   - 예시 코드에 플레이스홀더 사용
   - 커밋 메시지 규칙

5. **노출 시 대응 절차**:
   - 즉시 교체, 커밋 정리, 강제 푸시, 문서화

**목적**: Claude AI가 향후 세션에서 민감 정보를 문서나 커밋에 포함하지 않도록 명확한 가이드라인 제공

#### 2.4 운영 환경 설정

**작업**: EC2 서버에 GEMINI_API_KEY 추가

```bash
# 운영 서버 .env 파일에 추가
ssh ec2-user@SERVER 'echo "GEMINI_API_KEY=actual_key" >> /home/ec2-user/bibleai/.env'
```

**배경**:
- 백오피스 배포 시 .env 파일이 전송되지 않음 (gitignore)
- 운영 환경에서 Gemini API 사용 시 필수
- 수동으로 환경변수 추가 필요

### 3. 백오피스 UI 개선

#### 3.1 재발행 버튼 항상 표시

**파일**: `web/backoffice/templates/blog_detail.html`

**변경 전**:
```javascript
// 점수 < 7.0 또는 치명적 문제가 있을 때만 표시
if (hasCriticalIssues || blog.total_score < 7.0) {
    btnRegenerate.style.display = 'inline-block';
} else {
    btnRegenerate.style.display = 'none';
}
```

**변경 후**:
```javascript
// 항상 표시 (통과한 컨텐츠도 재생성 가능)
btnRegenerate.style.display = 'inline-block';
```

**목적**:
- 평가를 통과한 블로그도 개선 가능
- 사용자 피드백 반영하여 언제든 재생성 가능
- UX 개선

#### 3.2 하단 네비게이션 컨텐츠 가림 문제 해결

**파일**: `web/backoffice/templates/base.html`

**문제점**:
- 페이징이나 하단 컨텐츠가 고정된 네비게이션에 가려짐
- 사용자가 마지막 항목을 클릭하기 어려움

**해결 방법**:
```css
/* 변경 전 */
.container {
    max-width: 1400px;
    margin: 2rem auto;
    padding: 0 2rem;
}

/* 변경 후 */
.container {
    max-width: 1400px;
    margin: 2rem auto;
    padding: 0 2rem 5rem 2rem; /* 하단에 5rem padding 추가 */
}

/* 모바일 */
@media (max-width: 768px) {
    .container {
        padding: 0 0.5rem 5rem 0.5rem; /* 모바일에서도 유지 */
        margin: 0.5rem auto;
        max-width: 100vw;
    }
}
```

**효과**:
- 페이징 버튼이 네비게이션에 가려지지 않음
- 모든 컨텐츠가 스크롤 가능한 영역에 표시
- 데스크톱/모바일 모두 적용

## 📁 수정된 파일 목록

### 신규 파일
```
deploy_backoffice.sh          # 백오피스 배포 스크립트
docs/2025-10-18-backoffice-improvements.md  # 작업 일지 (이 파일)
```

### 수정된 파일
```
.gitignore                    # .env, 빌드 산출물 추가
docs/CLAUDE.md                # 보안 가이드라인 추가
docs/2025-10-16-gemini-blog-evaluation.md  # API 키 제거
docs/SEO_DEPLOYMENT.md        # EC2 IP 마스킹
docs/CHANGELOG_2025-10-12.md  # EC2 IP 마스킹
docs/CLOUDFLARE_SETUP.md      # EC2 IP 마스킹
docs/HYMN_POPULAR_30_TODO.md  # DB 접속 환경변수 사용
web/backoffice/templates/blog_detail.html  # 재발행 버튼 항상 표시
web/backoffice/templates/base.html  # 하단 padding 추가
```

## 🚀 배포 내역

### 배포 시간
- 1차: 10:50 (백오피스 초기 배포)
- 2차: 16:43 (재발행 버튼 개선)
- 3차: 17:01 (UI 개선, SSH 연결 실패로 보류)

### 로컬 환경
- 백오피스 서버: http://localhost:9090
- 프로세스 PID: 18210
- 로그: `backoffice.log`

### 운영 환경
- 백오피스 서버: http://SERVER:9090
- GEMINI_API_KEY 설정 완료
- 마지막 성공 배포: 16:43 (PID: 239676)

## 📊 Git 커밋 내역

```bash
78ee2bb - chore: .env 파일 gitignore 추가 및 백오피스 배포 스크립트 생성
061d887 - security: 문서에서 Gemini API 키 제거
493a752 - security: 문서에서 모든 민감 정보 제거
78bab64 - docs: CLAUDE.md에 민감 정보 보호 규칙 추가
b294518 - security: CLAUDE.md 예시에서 실제 API 키 제거
```

## 🔍 기술적 세부사항

### 배포 스크립트 구조

**deploy_backoffice.sh**:
1. **설정 로드**: `deploy.config` 파일에서 서버 정보 로드
2. **SSH 연결 테스트**: 포트 22 연결 및 인증 확인
3. **빌드**: ARM64 아키텍처 바이너리 생성
4. **전송**: rsync로 바이너리 및 템플릿 전송
5. **재시작**: 기존 프로세스 종료 후 새 프로세스 시작
6. **검증**: pgrep으로 프로세스 시작 확인

### 환경변수 관리

**.env 파일 구조**:
```env
# Gemini API 설정
GEMINI_API_KEY=actual_key_here

# 데이터베이스 설정
DB_HOST=localhost
DB_PORT=5432
DB_USER=bibleai
DB_PASSWORD=actual_password
DB_NAME=bibleai
DB_SSLMODE=disable

# 서버 설정
PORT=8080
ENVIRONMENT=development
```

**중요**: .env 파일은 gitignore 처리되어 수동 관리 필요

### CSS Padding 계산

**네비게이션 높이**:
- 링크 padding: `1rem * 2 = 2rem` (상하)
- 텍스트 높이: 약 `1.5rem`
- 총 높이: 약 `3.5rem`

**컨테이너 하단 padding**:
- 설정값: `5rem`
- 여유 공간: `5rem - 3.5rem = 1.5rem`
- 충분한 스크롤 여유 확보

## 💡 향후 개선 사항

### 1. 배포 자동화
- [ ] .env 파일 안전하게 전송하는 방법 고려
- [ ] AWS Secrets Manager 또는 Parameter Store 활용
- [ ] CI/CD 파이프라인 구축

### 2. 보안 강화
- [ ] 정기적인 보안 감사
- [ ] API 키 로테이션 정책
- [ ] 접근 로그 모니터링

### 3. UI/UX 개선
- [ ] 반응형 디자인 추가 개선
- [ ] 다크 모드 지원
- [ ] 키보드 단축키 추가

### 4. 문서화
- [ ] API 문서 자동 생성
- [ ] 배포 가이드 추가
- [ ] 트러블슈팅 가이드

## 🔗 관련 문서

- [CLAUDE.md](./CLAUDE.md) - 프로젝트 참조 문서
- [2025-10-16-gemini-blog-evaluation.md](./2025-10-16-gemini-blog-evaluation.md) - Gemini API 평가 시스템
- [SEO_DEPLOYMENT.md](./SEO_DEPLOYMENT.md) - SEO 및 배포 가이드
- [deploy_backoffice.sh](../deploy_backoffice.sh) - 백오피스 배포 스크립트

## ✅ 완료 사항

- [x] 백오피스 배포 스크립트 생성
- [x] .gitignore에 민감 정보 추가
- [x] 모든 문서에서 민감 정보 제거
- [x] CLAUDE.md에 보안 가이드라인 추가
- [x] 운영 환경 GEMINI_API_KEY 설정
- [x] 재발행 버튼 항상 표시
- [x] 하단 네비게이션 컨텐츠 가림 문제 해결
- [x] 로컬 및 운영 환경 배포

## 📝 참고사항

### 배포 시 주의사항
1. **VPN 연결**: EC2 SSH 접속 시 OpenVPN 연결 필수
2. **환경변수**: .env 파일은 수동으로 서버에 생성 필요
3. **포트**: 백오피스는 9090, 메인 서버는 8080 사용
4. **프로세스 관리**: 백오피스와 메인 서버는 별도 프로세스

### 보안 체크리스트
- [x] API 키 gitignore 처리
- [x] 문서에서 실제 값 제거
- [x] 환경변수 사용 권장
- [x] 플레이스홀더 사용
- [x] 보안 가이드라인 문서화

---

**작업 시작**: 2025-10-18 10:00
**작업 완료**: 2025-10-18 17:00
**총 소요 시간**: 약 7시간
**주요 성과**: 백오피스 배포 자동화, 보안 강화, UI 개선
