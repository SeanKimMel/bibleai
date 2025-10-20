# 2025-10-20 찬송가 API 수정 및 시스템 개선

## 날짜
2025년 10월 20일

## 작업 개요
찬송가 가사 자동 교체 시스템 구축 및 백오피스 개선 작업을 진행했습니다. 주요 이슈는 찬송가 API 응답 구조 파싱 오류로 인해 잘못된 가사가 삽입되는 문제였으며, 이를 해결하고 여러 개선사항을 함께 적용했습니다.

## 주요 변경사항

### 1. 찬송가 가사 자동 교체 시스템 구축

#### 문제점
- AI가 블로그 생성 시 찬송가 번호를 잘못 선택하거나 일관성 없게 사용
- AI가 찬송가 가사를 직접 작성하여 부정확한 내용 포함 가능성

#### 해결방안
**새로운 패키지 생성: `internal/hymn/`**

```go
// internal/hymn/replacer.go

// HymnData 찬송가 데이터 구조
type HymnData struct {
    Number int    `json:"number"`
    Title  string `json:"title"`
    Lyrics string `json:"lyrics"`
}

// HymnResponse API 응답 구조
type HymnResponse struct {
    Success bool     `json:"success"`
    Hymn    HymnData `json:"hymn"`
}

// FetchHymnLyrics 찬송가 API에서 가사 가져오기
func FetchHymnLyrics(number int) (string, string, error) {
    apiURL := fmt.Sprintf("http://localhost:8080/api/hymns/%d", number)
    // API 호출 및 파싱
    return response.Hymn.Title, response.Hymn.Lyrics, nil
}

// ReplaceHymnLyrics 찬송가 가사 플레이스홀더를 실제 가사로 교체
func ReplaceHymnLyrics(content string) string {
    // 두 가지 패턴 감지 및 교체:
    // 1. > **찬송가 XXX장 - 제목**
    //    > (가사는 자동으로 추가됩니다)
    // 2. > **찬송가 XXX장 - 제목**
    //    > 1절: ... (AI가 직접 작성한 경우)
}
```

**백오피스 통합:**
```go
// internal/backoffice/handlers.go
func (h *Handlers) GenerateBlog(c *gin.Context) {
    // ... 블로그 생성 ...

    // YouTube 임베드 교체
    blog.Content = youtube.ReplaceYouTubeSearchTags(blog.Content)

    // 찬송가 가사를 API에서 가져와서 교체
    blog.Content = hymn.ReplaceHymnLyrics(blog.Content)

    // DB에 저장
}
```

#### Gemini 프롬프트 개선
```go
// internal/gemini/client.go
2. **찬송가 가사 포함 (필수!)**
   - **⚠️ 중요: 절대로 가사를 직접 작성하지 마세요! API에서 자동으로 가져옵니다**
   - **⚠️⚠️⚠️ 위의 YouTube 임베드에서 사용한 찬송가 번호와 정확히 동일한 번호를 사용하세요!**
   - 찬송가 정보만 명시하면 자동으로 가사가 추가됨
   - 위치: YouTube 임베드 섹션 바로 아래
   - 형식: 아래와 같이 찬송가 번호와 제목만 명시 (가사는 작성하지 않음!)
   - 예시 (위에서 305장을 선택했다면):
     > **찬송가 305장 - 나 같은 죄인 살리신**
     > (가사는 자동으로 추가됩니다)
   - **다시 한번 확인: YouTube 임베드의 찬송가 번호 = 가사 섹션의 찬송가 번호 (반드시 일치!)**
```

### 2. 찬송가 API 응답 구조 파싱 오류 수정 (추가 개선)

#### 문제 발견
```bash
# API 실제 응답 구조
curl http://localhost:8080/api/hymns/305

{
  "success": true,
  "hymn": {
    "number": 305,
    "title": "나 같은 죄인 살리신",
    "lyrics": "..."
  }
}
```

기존 코드는 루트에 `number`, `title`, `lyrics`가 있다고 가정했지만, 실제로는 `hymn` 객체 안에 있었습니다.

#### 수정 내용
```go
// 수정 전
type HymnResponse struct {
    Number int    `json:"number"`
    Title  string `json:"title"`
    Lyrics string `json:"lyrics"`
}

// 수정 후
type HymnData struct {
    Number int    `json:"number"`
    Title  string `json:"title"`
    Lyrics string `json:"lyrics"`
}

type HymnResponse struct {
    Success bool     `json:"success"`
    Hymn    HymnData `json:"hymn"`
}

// 파싱 수정
var response HymnResponse
if err := json.Unmarshal(body, &response); err != nil {
    return "", "", fmt.Errorf("JSON 파싱 실패: %w", err)
}

if !response.Success {
    return "", "", fmt.Errorf("API 응답 실패")
}

return response.Hymn.Title, response.Hymn.Lyrics, nil
```

**추가 개선 (2차):**

YouTube 임베드 위의 제목 부분도 API에서 가져오도록 패턴 추가:

```go
// 1단계: YouTube 임베드 위의 제목도 교체
// 패턴: <p><strong>찬송가 XXX장 - 제목</strong></p>
titlePattern := regexp.MustCompile(`<p><strong>찬송가\s+(\d+)장\s*-\s*([^<]+)</strong></p>`)
titleMatches := titlePattern.FindAllStringSubmatch(content, -1)

for _, match := range titleMatches {
    if len(match) > 2 {
        hymnNumberStr := match[1]
        var hymnNumber int
        fmt.Sscanf(hymnNumberStr, "%d", &hymnNumber)

        // API에서 찬송가 정보 가져오기
        apiTitle, _, err := FetchHymnLyrics(hymnNumber)
        if err != nil {
            continue
        }

        // 정확한 제목으로 교체
        correctTitle := fmt.Sprintf("<p><strong>찬송가 %d장 - %s</strong></p>", hymnNumber, apiTitle)
        content = strings.ReplaceAll(content, match[0], correctTitle)
    }
}
```

이제 **세 부분 모두** API에서 정확한 찬송가 데이터를 가져옵니다:
1. YouTube 임베드 위 제목: `<p><strong>찬송가 XXX장 - 제목</strong></p>`
2. YOUTUBE_SEARCH 태그: `YOUTUBE_SEARCH: 찬송가 XXX장`
3. 가사 섹션: `> **찬송가 XXX장 - 제목**` + 가사

### 3. 백오피스 systemd 서비스 관리

#### systemd 서비스 파일 추가
```ini
# bibleai-backoffice.service
[Unit]
Description=BibleAI Backoffice Server
After=network.target

[Service]
Type=simple
User=ec2-user
WorkingDirectory=/home/ec2-user/bibleai
ExecStart=/home/ec2-user/bibleai/backoffice
Restart=always
RestartSec=5
StandardOutput=append:/home/ec2-user/bibleai/backoffice.log
StandardError=append:/home/ec2-user/bibleai/backoffice.log

Environment="PORT=9090"
Environment="TZ=Asia/Seoul"

[Install]
WantedBy=multi-user.target
```

#### 배포 스크립트 개선
```bash
# deploy_backoffice.sh

# systemd 서비스 파일 전송
rsync -avz bibleai-backoffice.service ${SERVER_USER}@${SERVER_HOST}:${SERVER_PATH}/

# 서비스 설치 및 재시작
ssh ${SERVER_USER}@${SERVER_HOST} << EOF
  cd ${SERVER_PATH}

  # systemd 서비스 파일 복사 및 활성화
  sudo cp bibleai-backoffice.service /etc/systemd/system/
  sudo systemctl daemon-reload
  sudo systemctl enable bibleai-backoffice.service

  # 서비스 재시작
  sudo systemctl restart bibleai-backoffice.service

  # 서비스 상태 확인
  if sudo systemctl is-active --quiet bibleai-backoffice.service; then
    echo "✅ 백오피스 서비스 시작 성공"
    sudo systemctl status bibleai-backoffice.service --no-pager
  else
    echo "❌ 백오피스 서비스 시작 실패"
    sudo journalctl -u bibleai-backoffice.service -n 50 --no-pager
    exit 1
  fi
EOF
```

### 4. 백오피스 타임존 설정

```go
// cmd/backoffice/main.go
func main() {
    // 타임존을 한국 시간(KST)으로 설정
    location, err := time.LoadLocation("Asia/Seoul")
    if err != nil {
        log.Fatalf("타임존 설정 실패: %v", err)
    }
    time.Local = location

    // ...
}
```

### 5. 백오피스 UI 개선

#### 날짜/시간 표시 포맷 개선
```javascript
// web/backoffice/templates/blog_list.html
// 수정 전
const createdAt = new Date(blog.created_at).toLocaleDateString('ko-KR');

// 수정 후
const createdAt = new Date(blog.created_at).toLocaleString('ko-KR', {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
    hour: '2-digit',
    minute: '2-digit'
});
```

#### 모바일에서 생성시간 표시
```html
<!-- 수정 전 -->
<span class="mobile-hide" style="...">{{ createdAt }}</span>

<!-- 수정 후 (mobile-hide 클래스 제거) -->
<span style="...">{{ createdAt }}</span>
```

### 6. 블로그 목록 SSR 구현 (SEO 최적화)

#### 메인 페이지 서버 사이드 렌더링
```go
// internal/handlers/pages.go
func HomePage(c *gin.Context) {
    // 첫 페이지 블로그 목록 조회 (SEO를 위한 SSR)
    limit := 10
    offset := 0

    // 전체 개수 조회
    var total int
    db.QueryRow("SELECT COUNT(*) FROM blog_posts WHERE is_published = true").Scan(&total)

    // 블로그 목록 조회
    rows, err := db.Query(`
        SELECT id, title, slug, excerpt, keywords, published_at, view_count
        FROM blog_posts
        WHERE is_published = true
        ORDER BY published_at DESC
        LIMIT $1 OFFSET $2
    `, limit, offset)

    // 템플릿에 초기 데이터 전달
    c.HTML(http.StatusOK, "blog.html", gin.H{
        "Title": "신앙 이야기",
        // SSR을 위한 초기 데이터
        "Posts":      posts,
        "Total":      total,
        "TotalPages": totalPages,
        "HasNext":    1 < totalPages,
    })
}
```

### 7. 메인 페이지 변경

**네비게이션 순서 조정:**
- 기존: 홈 → 성경읽기 → 찬송가 → 기도 → 블로그
- 변경: **블로그** → 성경읽기 → 기도 → 찬송가

**메인 페이지를 블로그로 설정:**
- `/` 경로에서 블로그 목록을 바로 표시
- 첫 페이지는 서버 사이드에서 렌더링 (SEO 최적화)

## 커밋 내역

```bash
4fa33b6 fix: YouTube 임베드 위 찬송가 제목도 API에서 가져오도록 수정
8232e23 docs: 2025-10-20 찬송가 API 수정 및 시스템 개선 문서화
0bee029 fix: 찬송가 API 응답 구조 파싱 오류 수정
b2a5590 feat: 찬송가 가사 자동 교체 시스템 및 백오피스 개선
6774ebd feat: 블로그 목록 SSR 구현 (SEO 최적화)
b9f8854 feat: 메인 페이지를 블로그로 변경 및 네비게이션 순서 조정
```

## 배포 결과

### 메인 서버 배포
```
✅ 빌드 완료 (크기: 24M)
✅ EC2로 파일 전송 완료
✅ 서버 재시작 성공 (PID: 360471)
```

### 백오피스 배포
```
✅ 빌드 완료 (크기: 24M)
✅ systemd 서비스 파일 전송 완료
✅ 백오피스 서비스 시작 성공
● bibleai-backoffice.service - BibleAI Backoffice Server
   Active: active (running)
```

## 기술적 세부사항

### 찬송가 가사 교체 플로우

1. **AI 블로그 생성**
   - Gemini가 찬송가 번호만 명시하고 가사는 작성하지 않음
   - 형식: `> **찬송가 305장 - 제목**\n> (가사는 자동으로 추가됩니다)`

2. **YouTube 임베드 교체**
   - `youtube.ReplaceYouTubeSearchTags()` 실행
   - `YOUTUBE_SEARCH: 찬송가 305장` → 실제 YouTube 임베드

3. **찬송가 가사 교체**
   - `hymn.ReplaceHymnLyrics()` 실행
   - 패턴 감지 → API 호출 → 가사 교체

4. **DB 저장**
   - 완성된 블로그 콘텐츠 저장

### API 엔드포인트 구조

```
GET /api/hymns/:number

Response:
{
  "success": true,
  "hymn": {
    "id": 809,
    "number": 305,
    "title": "나 같은 죄인 살리신",
    "lyrics": "(1)나 같은 죄인 살리신...",
    "theme": "구원/은혜",
    "composer": "",
    "author": "",
    "tempo": "",
    "key_signature": "G",
    "bible_reference": "에베소서 2:22",
    "external_link": "https://hymnkorea.org/50?keyword_type=all&keyword=305"
  }
}
```

## 개선 효과

### 1. 찬송가 정확도 향상
- ✅ API에서 정확한 가사를 가져와 부정확한 내용 방지
- ✅ 찬송가 번호 불일치 문제 해결
- ✅ AI의 창작 가사 방지

### 2. 백오피스 안정성 향상
- ✅ systemd를 통한 자동 재시작
- ✅ 로그 관리 개선 (journalctl + 파일)
- ✅ 서비스 상태 모니터링 용이

### 3. 사용자 경험 개선
- ✅ 모바일에서 블로그 생성시간 표시
- ✅ 날짜/시간 포맷 개선 (시:분까지 표시)
- ✅ 타임존 일관성 (KST)

### 4. SEO 최적화
- ✅ 메인 페이지 SSR 적용
- ✅ 첫 페이지 로딩 속도 개선
- ✅ 검색엔진 크롤러 접근성 향상

## 향후 개선 사항

1. **찬송가 가사 캐싱**
   - 동일한 찬송가 번호 반복 호출 시 캐싱 활용
   - 메모리 또는 Redis 캐시 도입 검토

2. **찬송가 번호 검증 강화**
   - YouTube 임베드와 가사 섹션의 찬송가 번호 일치 검증
   - 불일치 시 경고 로그 및 알림

3. **백오피스 모니터링**
   - Prometheus + Grafana 연동
   - 서비스 상태, 성능 메트릭 수집

4. **에러 처리 개선**
   - API 호출 실패 시 재시도 로직
   - 타임아웃 설정 최적화

## 참고 문서
- [2025-10-19 찬송가 제목 일치 검증 강화 및 자동 스케줄링 시스템](./2025-10-19-hymn-title-validation-and-scheduling.md)
- [2025-10-18 백오피스 시스템 문서화 및 업데이트](./2025-10-18-backoffice-improvements.md)
- [Auto Scheduling Guide](./AUTO_SCHEDULING.md)
