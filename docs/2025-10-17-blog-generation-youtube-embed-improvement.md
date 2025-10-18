# 2025-10-17: 블로그 자동 생성 및 YouTube 임베딩 개선 작업

## 📋 작업 개요

백오피스에서 Gemini API를 사용한 블로그 자동 생성 시 YouTube 임베딩, 찬송가 가사, 성경 구절 링크가 제대로 포함되도록 개선 작업을 진행했습니다.

---

## ✅ 완료된 작업

### 1. 블로그 평가 프롬프트 강화

**파일**: `internal/gemini/client.go` - `buildEvaluationPrompt()`

**추가된 필수 검증 항목**:

1. **YouTube 임베딩 포함 여부** (필수)
   - 본문에 iframe 또는 youtube.com/embed 링크 확인
   - 없으면 기술적 품질 점수 최대 5점

2. **찬송가 제목 일치 여부**
   - YouTube 영상 제목과 본문의 찬송가 번호/제목 일치 확인
   - 불일치하면 최대 6점

3. **찬송가 가사 포함 여부** (필수)
   - blockquote 형식으로 전체 가사 포함 확인
   - 없으면 최대 5점

4. **성경 구절 팝업 링크 포함 여부** (필수)
   - 모든 성경 인용에 bible.com 링크 확인
   - 없으면 최대 6점

**치명적 문제 (critical_issues) 추가**:
- ❌ YouTube 임베딩 없음
- ❌ 찬송가 가사 없음
- ❌ 성경 구절 팝업 링크 없음
- ❌ 찬송가 제목 불일치

**필수 통과 기준 업데이트**:
- theological_accuracy >= 6.0
- technical_quality >= 7.0
- critical_issues가 비어있어야 함
- YouTube 임베딩 반드시 포함
- 찬송가 가사 반드시 포함
- 성경 구절 팝업 링크 반드시 포함
- 찬송가 제목 일치 확인 필수

### 2. 블로그 생성 프롬프트 개선

**파일**: `internal/gemini/client.go` - `buildBlogGenerationPrompt()`

**추가된 구조 요구사항**:

1. **찬송가 YouTube 임베딩 (필수 형식)**
   ```html
   <div style="text-align: center; margin: 2rem 0;">
     <h3>🎵 관련 찬송가</h3>
     <p><strong>찬송가 305장 - 나 같은 죄인 살리신</strong></p>
     <p>YOUTUBE_SEARCH: 찬송가 305장</p>
   </div>
   ```
   - YOUTUBE_SEARCH 태그는 자동으로 실제 YouTube 임베드로 교체됨
   - 찬송가 번호와 제목을 정확히 명시

2. **찬송가 가사 포함 (필수)**
   - 전체 가사를 blockquote로 포함
   - YouTube 임베드 섹션 바로 아래 배치
   - 찬송가 번호 명시
   ```
   > **찬송가 305장 - 나 같은 죄인 살리신**
   > 1절: 나 같은 죄인 살리신...
   > 2절: 주 날 위하여 죽으사...
   ```

3. **성경 구절 팝업 링크 (필수)**
   - 모든 성경 인용에 bible.com 링크 추가
   - 형식: `[요한복음 3:16](https://bible.com/bible/1/JHN.3.16)`

### 3. YouTube 검색 기능 구현

**파일**: `internal/youtube/search.go` (신규 생성)

**구현 기능**:
- `SearchVideoID(query string)`: YouTube에서 비디오 ID 검색
- `GetEmbedCode(videoID string)`: YouTube 임베드 코드 생성
- `ReplaceYouTubeSearchTags(content string)`: YOUTUBE_SEARCH 태그를 실제 임베드로 교체

**참고한 Python 코드**: `blog_posting/scripts/get_youtube_id.py`

**구현 방식**:
1. YouTube 검색 URL로 HTTP 요청
2. HTML에서 정규식으로 videoId 추출
3. 임베드 코드 생성 및 교체

### 4. 백오피스 핸들러 수정

**파일**: `internal/backoffice/handlers.go`

**변경사항**:
- `GenerateBlog()` 함수에 YouTube 검색 태그 교체 로직 추가
- 블로그 생성 후 DB 저장 전에 `youtube.ReplaceYouTubeSearchTags()` 호출

```go
// YouTube 검색 태그를 실제 임베드로 교체
log.Printf("🔍 YouTube 검색 태그 처리 중...")
blog.Content = youtube.ReplaceYouTubeSearchTags(blog.Content)
log.Printf("✅ YouTube 임베드 교체 완료")
```

---

## 🔍 발견된 문제점

### 문제 1: 평가 검증 미흡
- 블로그 76번이 찬송가 번호/제목 없이도 평가 통과됨
- 실제로는 찬송가 정보가 없는데 "✅ YouTube 임베딩 포함, 찬송가 제목 일치 확인" 피드백 받음
- 평가 점수: 8.4점 (theological_accuracy: 9.0, technical_quality: 9.0)

### 문제 2: 생성된 콘텐츠 품질
블로그 76번 (`2025-10-17-기도-307`) 내용 분석:
- ✅ 성경 구절 링크: 정상 포함됨 ([빌립보서 4:6-7](https://bible.com/bible/1/PHP.4.6-7))
- ❌ YouTube 임베딩: 있지만 찬송가 번호/제목 없음
- ❌ 찬송가 가사: 있지만 찬송가 번호 명시 안 됨 (44-49줄)
- ❌ 제대로 된 구조: YOUTUBE_SEARCH 태그 사용 안 함

---

## 🚧 미완료 사항 (TODO)

### 1. 코드 빌드 및 테스트
- [ ] `internal/youtube/search.go` 모듈 빌드 확인
- [ ] 백오피스 서버 재시작
- [ ] 실제 블로그 생성 테스트
- [ ] YouTube 검색 및 임베드 교체 동작 확인

### 2. 프롬프트 추가 개선
- [ ] Gemini가 YOUTUBE_SEARCH 태그를 정확히 사용하도록 프롬프트 강화
- [ ] 찬송가 번호를 반드시 명시하도록 예제 추가
- [ ] 평가 시 찬송가 번호 누락을 critical_issue로 판단하도록 개선

### 3. 평가 로직 강화
- [ ] 찬송가 번호 정규식 검증 추가
- [ ] YOUTUBE_SEARCH 태그 또는 실제 iframe 존재 여부 검증
- [ ] 찬송가 가사에 "찬송가 XXX장" 패턴 확인

### 4. DB 데이터 정리
- [ ] 기존 부적합 블로그 재평가 또는 삭제
- [ ] 블로그 76번 재생성 또는 수동 수정

### 5. 추가 기능 구현
- [ ] YouTube 검색 실패 시 대체 로직 (다른 검색어 시도)
- [ ] 찬송가 DB 연동하여 정확한 가사 가져오기
- [ ] 성경 구절 API 연동하여 정확한 본문 인용

---

## 📝 참고 파일

### 수정된 파일
- `internal/gemini/client.go` - 평가/생성 프롬프트 강화
- `internal/backoffice/handlers.go` - YouTube 태그 교체 로직 추가

### 신규 생성 파일
- `internal/youtube/search.go` - YouTube 검색 및 임베드 생성

### 참고한 기존 파일
- `blog_posting/scripts/get_youtube_id.py` - Python YouTube 검색 구현
- `blog_posting/scripts/add_youtube_embeds.py` - 임베드 추가 로직

---

## 🎯 다음 작업 계획

1. **빌드 및 테스트**
   - Go 모듈 빌드 확인
   - 백오피스 서버 재시작
   - 새로운 블로그 생성 테스트

2. **프롬프트 미세 조정**
   - Gemini가 YOUTUBE_SEARCH 태그를 정확히 사용하도록 개선
   - 더 명확한 예제 제공

3. **평가 검증 강화**
   - 정규식 기반 검증 추가
   - 실제 콘텐츠 파싱하여 검증

4. **기존 데이터 처리**
   - 부적합 블로그 재평가/재생성

---

## ⚠️ 주의사항

- **아직 빌드 및 테스트 미완료**: 코드 작성만 완료, 실제 동작 검증 필요
- **프롬프트 준수 불확실**: Gemini가 YOUTUBE_SEARCH 태그를 제대로 사용할지 미지수
- **평가 로직 신뢰성 낮음**: 현재 평가가 실제 콘텐츠를 제대로 검증하지 못함
- **기존 블로그 품질**: 76번 포함 일부 블로그는 재생성 필요

---

## 📊 작업 로그

### 백오피스 로그 (backoffice.log)
```
[GIN] 2025/10/17 - 19:25:28 | 200 | 22.597984615s | ::1 | POST "/api/blogs/generate"
[GIN] 2025/10/17 - 19:25:31 | 200 |    1.488305ms | ::1 | GET  "/blogs/76"
```

### 블로그 76번 데이터
- ID: 76
- 제목: "고요한 시간 속으로: 기도를 통해 얻는 놀라운 평안"
- Slug: "2025-10-17-기도-307"
- 총점: 8.4/10
- 발행 상태: true
- 문제: 찬송가 번호 누락, YouTube 임베드 부적합

---

**작성일**: 2025년 10월 17일
**다음 작업**: 2025년 10월 18일부터 계속
