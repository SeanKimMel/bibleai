# 블로그 자동 생성 시스템 (Gemini API)

Gemini API를 사용하여 기독교 신앙 블로그를 자동으로 생성하는 시스템입니다.

> ⚠️ **중요**: 기존 Claude 수동 방식에서 Gemini API 자동화 방식으로 전환되었습니다 (2025-10-15)

## 📁 디렉토리 구조

```
blog_posting/
├── .env                          # 환경변수 설정 (API 키 포함)
├── .gitignore                    # Git 제외 파일
├── README.md                     # 이 파일
├── GEMINI_API_CHECKLIST.md       # Gemini API 구현 체크리스트
├── CLAUDE_PROMPT.md              # 기존 Claude 프롬프트 (참고용)
├── prompts/                      # 프롬프트 템플릿
│   ├── blog_generation.txt       # 블로그 생성 프롬프트
│   └── quality_evaluation.txt    # 품질 평가 프롬프트
├── scripts/                      # 실행 스크립트
│   ├── generate_blog.py          # 블로그 생성 스크립트
│   ├── evaluate_quality.py       # 품질 평가 스크립트
│   ├── prepare_data.sh           # 데이터 준비 스크립트
│   └── run_blog_generation.sh    # 통합 실행 스크립트
├── data/                         # 데이터 파일 (자동 생성)
└── output/                       # 생성된 블로그 (자동 생성)
```

---

## 🚀 빠른 시작

### 1. 환경 설정

```bash
# Python 패키지 설치
pip3 install python-dotenv requests

# .env 파일에서 API 키 확인
cd /workspace/bibleai/blog_posting
cat .env
```

### 2. 블로그 생성 (자동 완료)

```bash
# 기본 사용법: 키워드만 지정 (오늘 날짜 자동 사용)
cd scripts
./run_blog_generation.sh 평안

# 날짜 지정
./run_blog_generation.sh 평안 2025-10-15

# 다양한 키워드 예시
./run_blog_generation.sh 사랑
./run_blog_generation.sh 믿음
./run_blog_generation.sh 소망
./run_blog_generation.sh 감사
```

**자동으로 수행되는 작업**:
1. ✅ 데이터 준비 (성경구절, 찬송가, 기도문 조회)
2. ✅ Gemini API로 블로그 생성
3. ✅ YouTube 임베딩 자동 추가
4. ✅ 품질 평가 (총점 7.0/10 이상 확인)
5. ✅ 데이터베이스 저장
6. ✅ 웹사이트에 자동 게시

### 3. 생성된 블로그 확인

```bash
# JSON 파일 내용 보기
cat ../output/2025-10-15-평안.json | jq

# 웹사이트에서 확인
# http://localhost:8080/blog 접속
```

---

## 📊 워크플로우

```
0. [서버 확인]
   ↓
   run_blog_generation.sh
   → 서버 실행 여부 확인 (http://localhost:8080/health)
   → 실행 중이 아니면 안내 메시지와 함께 종료
   ↓
1. [데이터 준비]
   ↓
   prepare_data.sh
   → API 호출: GET /api/admin/blog/generate-data?keyword={keyword}&random=true
   → 성경 챕터 전체 + 찬송가 1개 + 기도문 2개 조회
   → 출력: data/{date}-{keyword}.json
   ↓
2. [콘텐츠 생성]
   ↓
   generate_blog.py
   → Gemini API 호출 (gemini-2.5-flash)
   → 프롬프트 템플릿 (prompts/blog_generation.txt) 사용
   → YouTube 검색 및 iframe 임베딩 자동 추가 ✨
   → 출력: output/{date}-{keyword}.json
   ↓
3. [품질 평가]
   ↓
   evaluate_quality.py
   → Gemini API로 5개 항목 평가
     - 신학적 정확성 (30%)
     - 콘텐츠 구조 (25%)
     - 독자 참여도 (20%)
     - 기술적 품질 (15%)
     - SEO 최적화 (10%)
   ↓
4. [발행 여부 판단]
   ↓
   총점 >= 7.0 AND 치명적 문제 없음?
   ├─ YES → [데이터베이스 저장]
   │         → POST /api/admin/blog/posts
   │         → ✅ 발행 완료!
   │
   └─ NO  → [재생성]
             → 최대 3회까지 재시도
             → 실패 파일 백업 (.failed-1, .failed-2, ...)
```

## ⚙️ 환경변수 설정

`.env` 파일:

```bash
# Gemini API (필수)
GEMINI_API_KEY=<your-api-key>

# 품질 평가 (선택)
QUALITY_THRESHOLD=7.0
MAX_RETRY_ATTEMPTS=3
```

> ⚠️ **중요**: 데이터베이스 접속 정보는 더 이상 필요 없습니다. 모든 데이터는 API를 통해 가져옵니다.

## 📝 품질 평가 기준

| 항목 | 가중치 | 최소 기준 |
|------|--------|----------|
| 신학적 정확성 | 30% | 6.0/10 |
| 콘텐츠 구조 | 25% | - |
| 독자 참여도 | 20% | - |
| 기술적 품질 | 15% | 7.0/10 |
| SEO 최적화 | 10% | - |

**발행 기준**: 총점 7.0/10 이상

## 🔧 개별 스크립트 사용법

### 데이터 준비
```bash
./scripts/prepare_data.sh 평안 2025-10-15
# → data/2025-10-15-평안.json 생성
```

### 블로그 생성
```bash
python3 scripts/generate_blog.py \
  data/2025-10-15-평안.json \
  output/2025-10-15-평안.json
```

### 품질 평가
```bash
python3 scripts/evaluate_quality.py \
  output/2025-10-15-평안.json
```

## 📄 프롬프트 템플릿 수정

### 블로그 생성 프롬프트

`prompts/blog_generation.txt` 파일을 수정하여 생성 스타일 변경 가능

**사용 가능한 변수**:
- `{{keyword}}` - 키워드
- `{{date}}` - 날짜
- `{{day_of_week}}` - 요일
- `{{current_month}}` - 월
- `{{slug}}` - URL slug
- `{{bible_verses}}` - 성경 구절 데이터 (JSON)
- `{{hymns}}` - 찬송가 데이터 (JSON)
- `{{prayers}}` - 기도문 데이터 (JSON)

### 품질 평가 프롬프트

`prompts/quality_evaluation.txt` 파일을 수정하여 평가 기준 변경 가능

## 🛠️ 문제 해결

### API 인증 오류
```bash
# .env 파일 확인
cat .env | grep GEMINI_API_KEY

# API 키가 없다면 추가
echo "GEMINI_API_KEY=your-api-key-here" >> .env
```

### 데이터베이스 연결 오류
```bash
# PostgreSQL 서비스 확인
sudo systemctl status postgresql

# 데이터베이스 접속 테스트
psql -h localhost -U bibleai -d bibleai
```

### Python 패키지 오류
```bash
# 패키지 재설치
pip3 install --upgrade python-dotenv requests
```

## 📊 생성 결과 예시

### 실행 로그
```bash
$ ./run_blog_generation.sh 소망 2025-10-16

==================================================
🤖 블로그 자동 생성 시작
==================================================
  키워드: 소망
  날짜: 2025-10-16
  품질 기준: 7.0/10.0
  최대 시도: 3회
==================================================

📊 1단계: 데이터 준비
  ✅ 성경 구절: 5개
  ✅ 찬송가: 3개
  ✅ 기도문: 2개

✍️ 2단계: 블로그 콘텐츠 생성
  📝 Gemini API 호출 중...
  ✅ 블로그 생성 완료!
  🎬 YouTube 임베딩 추가 중...
     🎵 찬송가 443장 검색 → 비디오 ID: 9qQzz6k-N2k
  ✅ 임베딩 완료!

📊 3단계: 품질 평가
  📊 항목별 점수:
    - 신학적 정확성: 9/10
    - 콘텐츠 구조: 9/10
    - 독자 참여도: 9/10
    - 기술적 품질: 8/10
    - SEO 최적화: 8/10
  🎯 총점: 8.8/10.0 ✅

💾 4단계: 데이터베이스 저장
  ✅ 블로그 ID: 37

==================================================
✅ 블로그 생성 및 발행 완료
==================================================
  제목: 흔들리는 세상 속, 변치 않는 소망의 닻을 내리다
  URL: http://localhost:8080/blog/2025-10-16-소망
  시도 횟수: 1회
==================================================
```

### 생성된 JSON 구조
```json
{
  "title": "흔들리는 세상 속, 변치 않는 소망의 닻을 내리다",
  "slug": "2025-10-16-소망",
  "content": "# 흔들리는 세상 속...\n\n### 찬송가 443장: 저 장미꽃 위에 이슬\n\n**🎵 [유튜브로 듣기](...)**\n\n<div style=\"text-align: center; margin: 20px 0;\">\n  <iframe width=\"560\" height=\"315\" src=\"https://www.youtube.com/embed/9qQzz6k-N2k\" ...\n</div>\n\n...",
  "excerpt": "흔들리는 세상 속에서도 하나님의 약속에 소망을 두고...",
  "keywords": "소망,하나님,믿음,약속,위로,평안,일상신앙",
  "meta_description": "변화무쌍한 세상 속에서도 변치 않는 하나님의 약속에 소망을 두는 방법..."
}
```

## ✨ 주요 기능

### 🎬 자동 YouTube 임베딩
- 찬송가 번호로 자동 검색
- YouTube 페이지 HTML 파싱으로 비디오 ID 추출
- iframe 코드 자동 생성 및 삽입
- **Claude LLM 간섭 없음** (순수 Python 처리)

### 📊 자동 품질 평가
- Gemini API로 5개 항목 자동 평가
- 총점 7.0/10 미만 시 자동 재생성 (최대 3회)
- 신학적 정확성 6.0 이상 필수
- 기술적 품질 7.0 이상 필수

### 🔄 재시도 메커니즘
- 품질 기준 미달 시 자동 재생성
- 실패 파일 자동 백업 (.failed-1, .failed-2, ...)
- 지수 백오프로 API 할당량 관리

## 🎯 다음 단계

- [x] 데이터베이스 저장 자동화 ✅
- [x] YouTube 임베딩 자동화 ✅
- [x] 품질 평가 시스템 ✅
- [x] API 기반 데이터 조회 전환 ✅
- [x] 서버 실행 확인 절차 추가 ✅
- [ ] 스케줄러 설정 (매일 자동 생성)
- [ ] 이메일 알림 기능
- [ ] 통계 및 분석 대시보드

## 📅 스케줄러 설정 (매일 자동 생성)

### cron을 사용한 자동 실행

매일 특정 시간에 블로그를 자동으로 생성하려면 cron을 설정합니다.

#### 1. 서버가 항상 실행 중이어야 함

스케줄러는 서버가 실행 중인 상태에서만 작동합니다. 서버를 백그라운드로 실행하세요:

```bash
# 서버 백그라운드 실행
cd /workspace/bibleai
nohup go run cmd/server/main.go > server.log 2>&1 &

# 또는 systemd 서비스로 등록 (권장)
sudo systemctl enable bibleai
sudo systemctl start bibleai
```

#### 2. 키워드 목록 파일 생성

매일 사용할 키워드 목록을 준비합니다:

```bash
# /workspace/bibleai/blog_posting/keywords.txt
사랑
믿음
소망
감사
평안
지혜
은혜
구원
회개
용서
```

#### 3. 자동 실행 스크립트 생성

`/workspace/bibleai/blog_posting/scripts/daily_blog.sh`:

```bash
#!/bin/bash
# 매일 자동으로 블로그 생성하는 스크립트

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
KEYWORDS_FILE="$SCRIPT_DIR/../keywords.txt"
LOG_FILE="$SCRIPT_DIR/../logs/daily_$(date +%Y%m%d).log"

# 로그 디렉토리 생성
mkdir -p "$SCRIPT_DIR/../logs"

# 키워드 파일에서 랜덤하게 하나 선택
KEYWORD=$(shuf -n 1 "$KEYWORDS_FILE")
DATE=$(date +%Y-%m-%d)

echo "======================================" >> "$LOG_FILE"
echo "시작 시간: $(date)" >> "$LOG_FILE"
echo "키워드: $KEYWORD" >> "$LOG_FILE"
echo "======================================" >> "$LOG_FILE"

# 블로그 생성 실행
cd "$SCRIPT_DIR"
./run_blog_generation.sh "$KEYWORD" "$DATE" >> "$LOG_FILE" 2>&1

echo "완료 시간: $(date)" >> "$LOG_FILE"
echo "" >> "$LOG_FILE"
```

#### 4. 실행 권한 부여

```bash
chmod +x /workspace/bibleai/blog_posting/scripts/daily_blog.sh
```

#### 5. crontab 설정

```bash
# crontab 편집
crontab -e

# 매일 오전 6시에 실행
0 6 * * * /workspace/bibleai/blog_posting/scripts/daily_blog.sh

# 매일 오전 6시와 오후 6시에 실행 (하루 2회)
0 6,18 * * * /workspace/bibleai/blog_posting/scripts/daily_blog.sh

# 평일(월~금) 오전 7시에 실행
0 7 * * 1-5 /workspace/bibleai/blog_posting/scripts/daily_blog.sh
```

#### 6. cron 로그 확인

```bash
# 실행 로그 확인
tail -f /workspace/bibleai/blog_posting/logs/daily_$(date +%Y%m%d).log

# cron 동작 확인
sudo grep CRON /var/log/syslog
```

### systemd 타이머 사용 (권장)

cron보다 더 강력한 systemd 타이머를 사용할 수도 있습니다:

#### 1. 서비스 파일 생성

`/etc/systemd/system/bibleai-blog.service`:

```ini
[Unit]
Description=BibleAI Blog Daily Generation
Requires=bibleai.service
After=bibleai.service

[Service]
Type=oneshot
User=bibleai
WorkingDirectory=/workspace/bibleai/blog_posting/scripts
ExecStart=/workspace/bibleai/blog_posting/scripts/daily_blog.sh
StandardOutput=append:/workspace/bibleai/blog_posting/logs/systemd.log
StandardError=append:/workspace/bibleai/blog_posting/logs/systemd.log

[Install]
WantedBy=multi-user.target
```

#### 2. 타이머 파일 생성

`/etc/systemd/system/bibleai-blog.timer`:

```ini
[Unit]
Description=BibleAI Blog Daily Generation Timer
Requires=bibleai-blog.service

[Timer]
OnCalendar=daily
OnCalendar=06:00
Persistent=true

[Install]
WantedBy=timers.target
```

#### 3. 타이머 활성화

```bash
# 타이머 활성화
sudo systemctl daemon-reload
sudo systemctl enable bibleai-blog.timer
sudo systemctl start bibleai-blog.timer

# 타이머 상태 확인
sudo systemctl status bibleai-blog.timer
sudo systemctl list-timers
```

### 주의사항

1. **서버 상태**: 스케줄러 실행 전에 서버가 실행 중인지 확인 (`http://localhost:8080/health`)
2. **API 할당량**: Gemini API 할당량을 고려하여 실행 빈도 조정
3. **로그 관리**: 로그 파일이 너무 커지지 않도록 주기적으로 정리
4. **에러 알림**: 실패 시 이메일이나 슬랙 알림 추가 권장

## 📚 관련 문서

- [Gemini API 체크리스트](GEMINI_API_CHECKLIST.md)
- [기존 Claude 프롬프트](CLAUDE_PROMPT.md) (참고용)

---

**최종 업데이트**: 2025-10-15

## 📝 주요 변경 이력

### 2025-10-15
- ✅ **API 기반 데이터 조회로 전환**: PostgreSQL 직접 접근 대신 `/api/admin/blog/generate-data` API 사용
- ✅ **서버 실행 확인 추가**: 블로그 생성 전 서버 상태 체크 (`/health` 엔드포인트)
- ✅ **YouTube 임베딩 패턴 수정**: 생성된 콘텐츠 형식에 맞게 정규표현식 개선
- ✅ **스케줄러 가이드 추가**: cron 및 systemd 타이머를 사용한 자동 실행 방법 문서화
