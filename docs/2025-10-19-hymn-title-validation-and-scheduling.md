# 2025-10-19: 찬송가 제목 일치 검증 강화 및 자동 스케줄링 시스템

## 📋 작업 개요

백오피스에서 블로그 생성 시 찬송가 제목과 YouTube 임베딩의 불일치 문제를 해결하기 위해 검증 로직을 강화하고, 자동 블로그 발행을 위한 스케줄링 시스템 문서를 작성했습니다.

## 🎯 주요 작업

### 1. 찬송가 제목 일치 검증 강화

#### 문제점
- 블로그 본문에 "찬송가 364장"으로 명시했지만, YouTube 임베딩은 "찬송가 492장"으로 잘못된 경우 발생
- 평가 시스템에서 이를 충분히 엄격하게 검증하지 못함

#### 해결 방법

**1) 블로그 생성 프롬프트 강화** (`internal/gemini/client.go:502-519`)

```go
1. **찬송가 YouTube 임베딩 (필수 형식!)**
   - 키워드와 관련된 찬송가를 선택 (예: "기도" → 찬송가 305장)
   - 임베드 위치: "오늘의 적용" 섹션 바로 위에 배치
   - **⚠️ 중요: 찬송가 번호를 정확히 확인하고 본문과 YOUTUBE_SEARCH 태그가 일치해야 함!**
   - **반드시 아래 형식을 정확히 따를 것:**

   예시 HTML:
   <div style="text-align: center; margin: 2rem 0;">
     <h3>관련 찬송가</h3>
     <p><strong>찬송가 305장 - 나 같은 죄인 살리신</strong></p>
     <p>YOUTUBE_SEARCH: 찬송가 305장</p>
   </div>

   - YOUTUBE_SEARCH 태그는 자동으로 실제 YouTube 임베드로 교체됨
   - **⚠️ 필수 확인사항: 찬송가 번호가 본문에 명시한 것과 정확히 일치해야 함**
     * 예: 본문에 "찬송가 305장"이라고 했으면 YOUTUBE_SEARCH에도 반드시 "찬송가 305장"
     * 잘못된 예: 본문 "364장"인데 YOUTUBE_SEARCH "492장" ❌
```

**2) 평가 프롬프트 강화** (`internal/gemini/client.go:216-228`)

```go
5. **찬송가 제목 일치 여부** (⚠️ 최우선 검증 항목!)
   - **본문 전체를 꼼꼼히 확인하여 찬송가 번호를 찾아내세요**
   - 본문에 명시된 찬송가 번호와 YouTube 섹션(YOUTUBE_SEARCH 또는 iframe)의 찬송가 번호가 일치하는가?
   - **검증 방법**:
     1. 본문에서 "찬송가 XXX장" 패턴을 찾음 (예: "찬송가 305장", "364장")
     2. YouTube 임베드 섹션에서 찬송가 번호 확인 (YOUTUBE_SEARCH: 찬송가 XXX장)
     3. 두 번호가 정확히 일치하는지 확인
   - **예시**:
     * ✅ 정확한 경우: 본문 "찬송가 364장" → YOUTUBE_SEARCH: 찬송가 364장
     * ❌ 불일치 사례: 본문 "찬송가 364장" → YOUTUBE_SEARCH: 찬송가 492장
     * ❌ 불일치 사례: 본문 "찬송가 305장" → YouTube 임베드에 다른 번호
   - **불일치하면 반드시 critical_issues에 "❌ 찬송가 제목 불일치 - 본문: XXX장, YouTube: YYY장" 형식으로 추가**
   - **불일치하면 기술적 품질 점수 강제 3점 이하 (발행 불가 수준)**
```

**3) 재생성 프롬프트 강화** (`internal/gemini/client.go:795-808`)

```go
2. **찬송가 정보 (필수!)**
   - 찬송가 번호 명시: "찬송가 XXX장" 패턴 (YouTube 섹션에 포함)
   - **⚠️ 최우선 확인: 본문에 명시한 찬송가 번호와 YOUTUBE_SEARCH의 찬송가 번호가 정확히 일치해야 함!**
   - 예시 (정확한 일치):
     * 본문: "찬송가 305장"
     * YOUTUBE_SEARCH: 찬송가 305장 ✅
   - **잘못된 예시 (불일치)**:
     * 본문: "찬송가 364장"
     * YOUTUBE_SEARCH: 찬송가 492장 ❌ (발행 불가!)
```

#### 적용 효과

- **생성 단계**: AI가 찬송가 번호를 선택할 때 본문과 YOUTUBE_SEARCH 태그의 일치를 강하게 인식
- **평가 단계**: 불일치 발견 시 `critical_issues`에 명확한 메시지 추가 및 기술적 품질 점수 3점 이하로 강제
- **재생성 단계**: 재생성 시에도 동일한 검증 기준 적용

### 2. 자동 스케줄링 시스템 문서화

#### 문서 작성: `docs/AUTO_SCHEDULING.md`

사용자가 정기적으로 블로그를 자동 발행할 수 있도록 3가지 방법을 문서화했습니다.

**방법 1: Linux Cron (권장)**

```bash
# 스크립트 생성
cat > /workspace/bibleai/scripts/auto_blog_generate.sh << 'EOF'
#!/bin/bash
TODAY=$(date +%Y-%m-%d)
curl -X POST http://localhost:9090/api/blogs/generate \
  -H "Content-Type: application/json" \
  -d "{\"keyword\": \"\", \"date\": \"$TODAY\"}"
EOF

chmod +x /workspace/bibleai/scripts/auto_blog_generate.sh

# Cron 설정 (매일 오전 6시)
crontab -e
# 추가: 0 6 * * * /workspace/bibleai/scripts/auto_blog_generate.sh >> /workspace/bibleai/logs/auto_blog.log 2>&1
```

**스케줄 패턴 예시**:
- `0 6 * * *` - 매일 오전 6시
- `0 */6 * * *` - 6시간마다
- `0 9 * * 1-5` - 평일 오전 9시
- `0 8 * * 0` - 매주 일요일 오전 8시

**방법 2: systemd Timer (고급)**

```ini
# /etc/systemd/system/bibleai-autoblog.service
[Unit]
Description=BibleAI Auto Blog Generation
After=network.target

[Service]
Type=oneshot
User=ec2-user
WorkingDirectory=/home/ec2-user/bibleai
EnvironmentFile=/home/ec2-user/bibleai/.env
ExecStart=/home/ec2-user/bibleai/scripts/auto_blog_generate.sh
StandardOutput=append:/home/ec2-user/bibleai/logs/auto_blog.log
StandardError=append:/home/ec2-user/bibleai/logs/auto_blog_error.log

# /etc/systemd/system/bibleai-autoblog.timer
[Unit]
Description=BibleAI Auto Blog Generation Timer
Requires=bibleai-autoblog.service

[Timer]
OnCalendar=*-*-* 06:00:00
Persistent=true

[Install]
WantedBy=timers.target
```

**방법 3: Go 기반 자체 스케줄러 (선택)**

```go
import "github.com/robfig/cron/v3"

func startAutoScheduler(handlers *backoffice.Handlers) {
    c := cron.New()
    c.AddFunc("0 6 * * *", func() {
        ctx := context.Background()
        today := time.Now().Format("2006-01-02")
        blog, err := gemini.GenerateBlog(ctx, "", today)
        if err != nil {
            log.Printf("자동 블로그 생성 실패: %v", err)
            return
        }
        log.Printf("자동 블로그 생성 완료: %s", blog.Title)
    })
    c.Start()
}
```

#### 문서 포함 내용

1. **3가지 스케줄링 방법** (Cron, systemd Timer, Go 스케줄러)
2. **로그 관리 및 로테이션** 설정
3. **모니터링 방법** (로그 확인, PostgreSQL 쿼리)
4. **알림 설정** (이메일 알림 예시)
5. **권장 스케줄** (트래픽 적은 시간대)
6. **문제 해결 가이드** (Cron 미실행, API 실패 등)

## 📂 수정된 파일

### 코드 파일
- `internal/gemini/client.go` - 블로그 생성/평가/재생성 프롬프트 강화

### 문서 파일
- `docs/AUTO_SCHEDULING.md` - 자동 스케줄링 시스템 완전 가이드 (신규)
- `docs/2025-10-19-hymn-title-validation-and-scheduling.md` - 오늘 작업 내역 (신규)

## 🚀 배포 내역

### 로컬 환경
- 백오피스 서버 재시작 완료 (PID: 19941)
- 포트: 9090
- 접속: http://localhost:9090

### 운영 환경 (EC2)
- 백오피스 배포 완료 (PID: 280090)
- 서버: 13.209.47.72
- 포트: 9090
- 접속: http://13.209.47.72:9090

**배포 단계**:
1. Tailwind CSS 빌드 (48K)
2. ARM64 바이너리 빌드 (24M)
3. rsync로 파일 전송 (백오피스, 템플릿, 정적 파일)
4. 운영 서버에서 백오피스 재시작

## 🎯 기대 효과

### 찬송가 제목 검증 강화
1. **생성 품질 향상**: AI가 찬송가 번호 일치를 더 엄격하게 준수
2. **자동 발행 정확도 증가**: 불일치 콘텐츠는 critical_issues로 잡혀 발행 차단
3. **사용자 경험 개선**: 블로그에서 찬송가 정보와 YouTube 영상이 항상 일치

### 자동 스케줄링 시스템
1. **자동화된 콘텐츠 생성**: 매일 또는 원하는 시간에 자동으로 블로그 생성
2. **운영 효율성**: 수동 개입 없이 정기적인 콘텐츠 발행
3. **확장성**: Cron, systemd, Go 스케줄러 중 환경에 맞는 방법 선택 가능

## 🔍 테스트 방법

### 찬송가 제목 검증 테스트

1. **백오피스 접속**: http://localhost:9090/blogs/new
2. **자동 생성 클릭**: 랜덤 키워드로 블로그 생성
3. **평가 결과 확인**:
   - 찬송가 번호가 본문과 YouTube 섹션에서 일치하는지 확인
   - 불일치 시 critical_issues에 "찬송가 제목 불일치" 메시지 확인
   - 기술적 품질 점수가 3점 이하인지 확인

### 자동 스케줄링 테스트 (로컬)

```bash
# 테스트용 스크립트 실행
TODAY=$(date +%Y-%m-%d)
curl -X POST http://localhost:9090/api/blogs/generate \
  -H "Content-Type: application/json" \
  -d "{\"keyword\": \"\", \"date\": \"$TODAY\"}"

# 결과 확인
psql -U bibleai -d bibleai -c "SELECT id, title, created_at, is_published FROM blogs ORDER BY created_at DESC LIMIT 1;"
```

### 자동 스케줄링 테스트 (운영)

```bash
# SSH 접속
ssh -i /workspace/bibleai-ec2-key.pem ec2-user@13.209.47.72

# Cron 설정 (5분마다 테스트)
crontab -e
# 추가: */5 * * * * /home/ec2-user/bibleai/scripts/auto_blog_generate.sh >> /home/ec2-user/bibleai/logs/auto_blog.log 2>&1

# 로그 확인
tail -f /home/ec2-user/bibleai/logs/auto_blog.log
```

## 📊 관련 문서

- [AUTO_SCHEDULING.md](AUTO_SCHEDULING.md) - 자동 스케줄링 완전 가이드
- [2025-10-18-backoffice-improvements.md](2025-10-18-backoffice-improvements.md) - 이전 백오피스 개선 작업
- [2025-10-16-gemini-blog-evaluation.md](2025-10-16-gemini-blog-evaluation.md) - Gemini 평가 시스템 구축
- [CLAUDE.md](../CLAUDE.md) - 백오피스 시스템 전체 구조

## ✅ 완료 체크리스트

- [x] 찬송가 제목 일치 검증 강화 (생성/평가/재생성)
- [x] 자동 스케줄링 문서 작성 (AUTO_SCHEDULING.md)
- [x] 로컬 백오피스 재시작 및 테스트
- [x] 운영 환경 백오피스 배포
- [x] 작업 내역 문서화 (2025-10-19)
- [ ] CLAUDE.md 업데이트 (다음 단계)
- [ ] README.md 업데이트 (다음 단계)

## 🔄 다음 단계

1. CLAUDE.md에 찬송가 검증 강화 및 스케줄링 내용 추가
2. README.md에 자동 스케줄링 기능 추가
3. 운영 환경에서 Cron 설정하여 자동 블로그 발행 시작
4. 1주일 후 자동 생성된 블로그 품질 평가 및 개선

---

**작성일**: 2025-10-19
**작성자**: Claude (AI Assistant)
**배포 상태**: ✅ 운영 환경 배포 완료
