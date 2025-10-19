package gemini

import (
	"context"
	"encoding/json"
	"fmt"
	"log"
	"os"
	"strings"
	"time"

	"google.golang.org/genai"
)

// QualityScores 품질 평가 점수
type QualityScores struct {
	TheologicalAccuracy float64 `json:"theological_accuracy"`
	ContentStructure    float64 `json:"content_structure"`
	Engagement          float64 `json:"engagement"`
	TechnicalQuality    float64 `json:"technical_quality"`
	SeoOptimization     float64 `json:"seo_optimization"`
}

// QualityFeedback 품질 평가 피드백
type QualityFeedback struct {
	Strengths      []string `json:"strengths"`
	Improvements   []string `json:"improvements"`
	CriticalIssues []string `json:"critical_issues"`
}

// QualityEvaluation 품질 평가 결과
type QualityEvaluation struct {
	Scores             QualityScores            `json:"scores"`
	TotalScore         float64                  `json:"total_score"`
	WeightedBreakdown  map[string]float64       `json:"weighted_breakdown"`
	Feedback           QualityFeedback          `json:"feedback"`
	Recommendation     string                   `json:"recommendation"`
	Confidence         string                   `json:"confidence"`
}

// BlogContent 평가할 블로그 콘텐츠
type BlogContent struct {
	Title    string `json:"title"`
	Slug     string `json:"slug"`
	Content  string `json:"content"`
	Excerpt  string `json:"excerpt"`
	Keywords string `json:"keywords"`
}

// EvaluateQuality Gemini API를 사용하여 블로그 품질 평가
func EvaluateQuality(ctx context.Context, blog BlogContent) (*QualityEvaluation, error) {
	// Gemini API 키 확인
	apiKey := os.Getenv("GEMINI_API_KEY")
	if apiKey == "" {
		return nil, fmt.Errorf("GEMINI_API_KEY 환경변수가 설정되지 않았습니다")
	}

	// Gemini 클라이언트 생성
	client, err := genai.NewClient(ctx, &genai.ClientConfig{
		APIKey: apiKey,
		Backend: genai.BackendGeminiAPI,
	})
	if err != nil {
		return nil, fmt.Errorf("Gemini 클라이언트 생성 실패: %w", err)
	}

	// 평가 프롬프트 생성
	prompt := buildEvaluationPrompt(blog)

	// 생성 설정
	genConfig := &genai.GenerateContentConfig{
		Temperature:      genai.Ptr(float32(0.7)),
		ResponseMIMEType: "application/json",
	}

	// Gemini API 호출
	contents := []*genai.Content{
		{
			Role: "user",
			Parts: []*genai.Part{
				genai.NewPartFromText(prompt),
			},
		},
	}

	resp, err := client.Models.GenerateContent(ctx, "gemini-2.0-flash-exp", contents, genConfig)
	if err != nil {
		return nil, fmt.Errorf("Gemini API 호출 실패: %w", err)
	}

	// 응답에서 텍스트 추출
	if len(resp.Candidates) == 0 || len(resp.Candidates[0].Content.Parts) == 0 {
		return nil, fmt.Errorf("Gemini API 응답이 비어있습니다")
	}

	responseText := ""
	for _, part := range resp.Candidates[0].Content.Parts {
		if part.Text != "" {
			responseText += part.Text
		}
	}

	// JSON 파싱
	var evaluation QualityEvaluation
	if err := json.Unmarshal([]byte(responseText), &evaluation); err != nil {
		return nil, fmt.Errorf("JSON 파싱 실패: %w\n응답: %s", err, responseText[:min(500, len(responseText))])
	}

	return &evaluation, nil
}

// buildEvaluationPrompt 평가 프롬프트 생성
func buildEvaluationPrompt(blog BlogContent) string {
	// 블로그 콘텐츠 JSON 변환
	contentJSON, _ := json.MarshalIndent(blog, "", "  ")

	prompt := `당신은 기독교 블로그 콘텐츠 품질 평가 전문가입니다.

## 👤 당신의 역할

당신은 **교회 운영자로서 발행 전에 콘텐츠를 평가할 의무가 있는 입장**입니다.
교회 공식 블로그에 게시될 콘텐츠의 신학적 정확성, 목회적 적절성, 교육적 가치를 책임지고 검토해야 합니다.
신앙 공동체에 해를 끼치거나 잘못된 가르침을 전파할 수 있는 내용은 반드시 걸러내야 하며,
성도들의 신앙 성장에 도움이 되는 양질의 콘텐츠만 발행되도록 엄격하게 평가해야 합니다.

## 📋 평가 대상 콘텐츠

다음 블로그 포스트를 평가해주세요:

` + string(contentJSON) + `

---

## 🎯 평가 기준 (각 항목 1-10점)

### 1. 신학적 정확성 (가중치 25%)
**평가 항목:**
- 성경 인용의 정확성
- 신학적 오류 없음
- 교리적 적합성
- 성경 해석의 적절성

**점수 가이드:**
- 9-10점: 신학적으로 완벽하고 깊이 있음
- 7-8점: 정확하며 적절함
- 5-6점: 대체로 괜찮으나 일부 개선 필요
- 1-4점: 심각한 신학적 오류 또는 부정확함

### 2. 콘텐츠 구조 (가중치 20%)
**평가 항목:**
- 도입-본론-결론 구조
- 문단 구성의 적절성
- 논리적 흐름
- 섹션 간 연결성

### 3. 독자 참여도 (가중치 15%)
**평가 항목:**
- 독자 공감 유도
- 실생활 적용 가능성
- 감정적 연결
- 구체적 예시 사용

### 4. 기술적 품질 (가중치 30%)
**평가 항목:**
- 맞춤법 및 문법
- 적절한 어휘 사용
- 문장 길이의 적절성
- 가독성
- **🎬 유튜브 임베딩 필수 검증**

**⚠️ 필수 확인사항 (반드시 체크!):**

1. **유튜브 임베딩 포함 여부 (필수! 초엄격 검증)**
   - 다음 패턴 중 하나라도 있으면 ✅:
     * <iframe src="https://www.youtube.com/embed/VIDEO_ID"
     * <iframe src="https://youtube.com/embed/VIDEO_ID"
     * https://www.youtube.com/embed/VIDEO_ID
     * https://youtube.com/embed/VIDEO_ID
   - 다음은 인정하지 않음 ❌:
     * YOUTUBE_SEARCH 태그만 있는 경우 (교체 전)
     * 일반 youtube.com/watch 링크
     * youtu.be 단축 링크
   - **❌ 없으면 critical_issues에 "YouTube 임베딩 없음" 추가**
   - **❌ 없으면 기술적 품질 점수는 다른 요소와 무관하게 무조건 4점 이하로 채점**
   - **⚠️ 중요: 맞춤법/문법이 완벽해도, 가독성이 뛰어나도 YouTube 임베딩이 없으면 절대 4점 초과 불가**

2. **찬송가 번호 명시 여부** (필수!)
   - 본문에 "찬송가 XXX장" 또는 "XXX장 찬송가" 패턴이 있는가?
   - 예: "찬송가 305장", "305장", "찬송가 364장 - 내 주를 가까이"
   - **없으면 critical_issues에 "❌ 찬송가 번호 누락" 추가**
   - **없으면 기술적 품질 점수 최대 5점**

3. **찬송가 가사 포함 여부** (필수!)
   - 본문에 찬송가 전체 가사가 blockquote 형식으로 포함되어 있는가?
   - blockquote(>) 안에 "절:" 또는 "1절", "2절" 등의 패턴이 있어야 함
   - **없으면 critical_issues에 "❌ 찬송가 가사 없음" 추가**
   - **없으면 기술적 품질 점수 최대 4점**

4. **성경 구절 내부 링크 포함 여부** (필수! 매우 엄격히 검증)
   - 본문의 모든 성경 인용에 내부 API 링크가 포함되어 있는가?
   - **반드시 다음 형식이어야 함**: [성경구절](/api/bible/chapters/{book_id}/{chapter})
   - 예시:
     * [요한복음 3:16](/api/bible/chapters/jo/3) ✅
     * [빌립보서 4:6-7](/api/bible/chapters/ph/4) ✅
     * [로마서 8:28](/api/bible/chapters/rm/8) ✅
   - **검증 방법**:
     1. 모든 성경 책명 뒤에 장:절 패턴이 있는지 확인
     2. 해당 구절에 [텍스트](/api/bible/chapters/xx/n) 형식의 링크가 있는지 확인
     3. book_id가 올바른 약어인지 확인 (jo, ph, rm, gn, ps 등)
   - **다음은 불인정** ❌:
     * 외부 링크 (https://bible.com/...)
     * 잘못된 형식 (/bible/... 또는 /chapters/... 등)
     * 링크 없는 평문 성경 구절
   - **❌ 없으면 critical_issues에 "성경 구절 내부 링크 없음" 추가**
   - **❌ 없으면 기술적 품질 점수 강제 2점 (발행 불가 수준)**

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

### 5. SEO 최적화 (가중치 10%)
**평가 항목:**
- 키워드 자연스러운 포함
- 메타 설명 최적화
- 제목의 매력도
- 구조적 마크업 (H1, H2, H3)

---

## 📊 출력 형식

반드시 다음 JSON 형식으로 출력하세요:

{
  "scores": {
    "theological_accuracy": 8,
    "content_structure": 7,
    "engagement": 9,
    "technical_quality": 8,
    "seo_optimization": 7
  },
  "total_score": 7.85,
  "weighted_breakdown": {
    "theological_accuracy": 2.0,
    "content_structure": 1.4,
    "engagement": 1.35,
    "technical_quality": 2.4,
    "seo_optimization": 0.7
  },
  "feedback": {
    "strengths": [
      "신학적 정확성이 뛰어나며 복음의 핵심이 잘 드러남",
      "독자와의 공감대 형성이 탁월함",
      "✅ YouTube iframe 임베딩 포함 (embed URL 확인)",
      "✅ 찬송가 가사 전체 포함됨 (blockquote 형식)",
      "✅ 모든 성경 구절에 내부 API 링크 포함 (/api/bible/chapters/{book}/{chapter} 형식)",
      "✅ 찬송가 번호 명시됨 (찬송가 305장)"
    ],
    "improvements": [
      "일부 문장이 너무 길어 가독성 저하"
    ],
    "critical_issues": [
      "❌ YouTube iframe 임베딩 없음 (YOUTUBE_SEARCH 태그만 있음)",
      "❌ 찬송가 번호 누락 (찬송가 XXX장 패턴 없음)",
      "❌ 찬송가 가사 없음 (blockquote 내 가사 누락)",
      "❌ 성경 구절 내부 링크 없음 (/api/bible/chapters/... 형식 누락)",
      "❌ 찬송가 제목 불일치 - 본문: 364장, YouTube: 492장",
      "❌ 잘못된 성경 링크 형식 (외부 링크 사용 또는 형식 오류)"
    ]
  },
  "recommendation": "publish",
  "confidence": "high"
}

---

## 📌 평가 지침

### 종합 점수 계산
total_score = (theological_accuracy × 0.25) + (content_structure × 0.20) + (engagement × 0.15) + (technical_quality × 0.30) + (seo_optimization × 0.10)

### 발행 권장사항 (recommendation)
- **"publish"**: total_score >= 7.0 이고 치명적 문제 없음
- **"revise"**: 5.0 <= total_score < 7.0 또는 일부 개선 필요
- **"reject"**: total_score < 5.0 또는 심각한 신학적 오류 또는 YouTube/성경링크 누락

### 신뢰도 (confidence)
- **"high"**: 모든 평가 항목이 명확함
- **"medium"**: 일부 애매한 부분 존재
- **"low"**: 평가가 어려운 요소 다수

### 치명적 문제 (critical_issues)
다음 사항이 발견되면 반드시 critical_issues에 기록:
- 심각한 신학적 오류
- 이단적 교리
- 성경 왜곡
- 부적절한 표현
- **❌ YouTube 임베딩 없음** (필수! iframe 또는 embed URL이 없을 경우)
- **❌ 찬송가 번호 누락** (필수! "찬송가 XXX장" 패턴이 없을 경우)
- **❌ 찬송가 가사 없음** (필수! blockquote 내 가사가 없을 경우)
- **❌ 성경 구절 내부 링크 없음** (필수! 내부 API 링크가 없을 경우)
- **❌ 찬송가 제목 불일치** (본문과 YouTube 섹션의 찬송가 번호가 다를 경우)

---

## ⚠️ 주의사항

1. **공정한 평가**: 개인적 신학 성향보다 일반적 기독교 교리 기준으로 평가
2. **구체적 피드백**: 추상적 표현보다 구체적 개선 방향 제시
3. **균형잡힌 평가**: 장점과 단점을 모두 언급
4. **JSON 형식 준수**: 유효한 JSON으로 출력
5. **필수 통과 기준 (매우 엄격!)**:
   - theological_accuracy >= 6.0
   - technical_quality >= 6.0
   - critical_issues가 비어있어야 함 (특히 YouTube, 성경링크 필수!)
   - **YouTube iframe 또는 embed URL 반드시 포함** (없으면 무조건 technical_quality ≤ 4점)
   - **성경 구절 내부 API 링크 반드시 포함** (없으면 무조건 technical_quality ≤ 2점)
   - **찬송가 번호 반드시 명시** ("찬송가 XXX장" 패턴 필수)
   - **찬송가 가사 반드시 포함** (blockquote 형식, 없으면 technical_quality 최대 4점)
   - **찬송가 제목 일치 확인 필수** (본문과 YouTube 섹션 일치)

⚠️ **점수 제한 규칙 엄수**:
- YouTube 임베딩 없음 → technical_quality는 4점 이하로만 채점 (맞춤법/가독성 완벽해도 4점 초과 불가)
- 성경 구절 링크 없음 → technical_quality는 2점 이하로만 채점
- 위 두 가지 모두 없으면 → technical_quality는 1점

이제 위의 콘텐츠를 평가하고 JSON 형식으로 결과를 출력해주세요.`

	return prompt
}

func min(a, b int) int {
	if a < b {
		return a
	}
	return b
}

// GeneratedBlog 생성된 블로그 콘텐츠
type GeneratedBlog struct {
	Title           string `json:"title"`
	Slug            string `json:"slug"`
	Content         string `json:"content"`
	Excerpt         string `json:"excerpt"`
	Keywords        string `json:"keywords"`
	MetaDescription string `json:"meta_description"`
}

// GenerateBlog Gemini API를 사용하여 블로그 생성
func GenerateBlog(ctx context.Context, keyword, date string) (*GeneratedBlog, error) {
	// Gemini API 키 확인
	apiKey := os.Getenv("GEMINI_API_KEY")
	if apiKey == "" {
		return nil, fmt.Errorf("GEMINI_API_KEY 환경변수가 설정되지 않았습니다")
	}

	// 고유한 slug 생성 (날짜-키워드-타임스탬프)
	timestamp := fmt.Sprintf("%d", time.Now().Unix()%10000) // 마지막 4자리
	slug := fmt.Sprintf("%s-%s-%s", date, keyword, timestamp)

	// Gemini 클라이언트 생성
	client, err := genai.NewClient(ctx, &genai.ClientConfig{
		APIKey:  apiKey,
		Backend: genai.BackendGeminiAPI,
	})
	if err != nil {
		return nil, fmt.Errorf("Gemini 클라이언트 생성 실패: %w", err)
	}

	// 블로그 생성 프롬프트
	prompt := buildBlogGenerationPrompt(keyword, date, slug)

	// 생성 설정
	genConfig := &genai.GenerateContentConfig{
		Temperature:      genai.Ptr(float32(0.7)),
		ResponseMIMEType: "application/json",
	}

	// Gemini API 호출
	contents := []*genai.Content{
		{
			Role: "user",
			Parts: []*genai.Part{
				genai.NewPartFromText(prompt),
			},
		},
	}

	resp, err := client.Models.GenerateContent(ctx, "gemini-2.0-flash-exp", contents, genConfig)
	if err != nil {
		return nil, fmt.Errorf("Gemini API 호출 실패: %w", err)
	}

	// 응답에서 텍스트 추출
	if len(resp.Candidates) == 0 || len(resp.Candidates[0].Content.Parts) == 0 {
		return nil, fmt.Errorf("Gemini API 응답이 비어있습니다")
	}

	responseText := ""
	for _, part := range resp.Candidates[0].Content.Parts {
		if part.Text != "" {
			responseText += part.Text
		}
	}

	// JSON 코드 블록 제거 (```json ... ``` 형식)
	responseText = cleanJSONResponse(responseText)

	// JSON 파싱 (유니코드 이스케이프 문제 해결)
	var blog GeneratedBlog
	if err := json.Unmarshal([]byte(responseText), &blog); err != nil {
		// 파싱 실패 시 수동으로 정리 시도
		responseText = fixUnicodeEscapes(responseText)
		if err2 := json.Unmarshal([]byte(responseText), &blog); err2 != nil {
			return nil, fmt.Errorf("JSON 파싱 실패: %w\n원본 응답 (처음 500자): %s", err, responseText[:min(500, len(responseText))])
		}
	}

	return &blog, nil
}

// cleanJSONResponse JSON 응답에서 코드 블록 제거
func cleanJSONResponse(text string) string {
	text = strings.TrimSpace(text)

	// ```json ... ``` 제거
	if strings.HasPrefix(text, "```json") {
		text = text[7:]
	} else if strings.HasPrefix(text, "```") {
		text = text[3:]
	}

	if strings.HasSuffix(text, "```") {
		text = text[:len(text)-3]
	}

	return strings.TrimSpace(text)
}

// fixUnicodeEscapes 잘못된 유니코드 이스케이프 수정
func fixUnicodeEscapes(text string) string {
	// \uXXXX 형식이 아닌 잘못된 이스케이프 제거
	// 예: \> 같은 것들
	text = strings.ReplaceAll(text, "\\>", ">")
	text = strings.ReplaceAll(text, "\\<", "<")

	// 이미 올바른 이스케이프는 유지
	return text
}

// buildBlogGenerationPrompt 블로그 생성 프롬프트 생성
func buildBlogGenerationPrompt(keyword, date, slug string) string {
	// 간소화된 프롬프트 (찬송가/기도문/성경구절 데이터 없이)
	dateObj, _ := time.Parse("2006-01-02", date)
	weekdays := []string{"일요일", "월요일", "화요일", "수요일", "목요일", "금요일", "토요일"}
	dayOfWeek := weekdays[dateObj.Weekday()]
	currentMonth := dateObj.Month()

	return fmt.Sprintf(`당신은 기독교 신앙 블로그 전문 작가입니다.

## 📅 작성 정보
- 날짜: %s
- 요일: %s
- 키워드: %s
- 현재 월: %d월

## ✍️ 작성 요구사항

### 1. 구조 (⚠️ 반드시 이 순서와 형식으로!)

#### (1) 제목 (H1)
- 키워드를 중심으로 한 흥미롭고 공감되는 제목
- 예: "진정한 평안을 찾아서"

#### (2) 성경 본문 소개 (H2)
- 키워드와 관련된 대표 성경 구절 1-2개를 인용 (블록쿼트 사용)
- 구절 뒤에 (책 장:절) 표기
- 배경 및 맥락 설명 (2-3문단)
- 일상적 질문으로 시작하여 독자 공감 유도

#### (3) 묵상과 해석 (H2)
- 성경 본문의 의미
- 오늘날 우리에게 주는 교훈
- **반드시 3-4개의 소주제(H3)로 나누어 설명**
- 각 소주제는 구체적이고 실천적인 제목으로

#### (4) 오늘의 적용 (H2)
- 구체적인 실천 방법 3가지
- 번호 목록(1, 2, 3)으로 작성
- 각 항목: **첫 문장 굵게** + 자세한 설명 (2-3줄)

#### (5) 마무리 기도 (H2)
- 2-3문단의 기도문
- 주님께 드리는 기도 형식 (존칭 사용)
- "예수님의 이름으로 기도합니다. 아멘." 으로 마무리

### 2. 🎬 YouTube 임베딩 (필수!)

**⚠️ 반드시 포함해야 함:**

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
   - 찬송가 번호와 제목을 정확히 명시

2. **찬송가 가사 포함 (필수!)**
   - 찬송가 전체 가사를 blockquote로 포함
   - 위치: YouTube 임베드 섹션 바로 아래
   - 형식: 각 절을 구분하여 표시하고 **찬송가 번호 명시**
   - 예시:
     > **찬송가 305장 - 나 같은 죄인 살리신**
     > 1절: 나 같은 죄인 살리신...
     > 2절: 주 날 위하여 죽으사...

3. **성경 구절 내부 링크 (필수!)**
   - 본문에서 인용하는 모든 성경 구절에 내부 API 링크 추가
   - 링크 형식: /api/bible/chapters/{book_id}/{chapter}
   - 예시:
     * 요한복음 3장 → [요한복음 3:16](/api/bible/chapters/jo/3)
     * 고린도전서 13장 → [고린도전서 13:4-8](/api/bible/chapters/1co/13)
     * 창세기 1장 → [창세기 1:1](/api/bible/chapters/gn/1)
     * 시편 23편 → [시편 23:1](/api/bible/chapters/ps/23)
     * 로마서 8장 → [로마서 8:28](/api/bible/chapters/rm/8)
     * 빌립보서 4장 → [빌립보서 4:6-7](/api/bible/chapters/ph/4)
   - 주요 책 ID 약어 (반드시 정확히 사용!):
     * 구약: 창세기(gn), 출애굽기(ex), 레위기(lv), 민수기(nm), 신명기(dt)
     * 구약: 시편(ps), 잠언(prv), 전도서(ec), 이사야(is), 예레미야(jr)
     * 신약: 마태복음(mt), 마가복음(mk), 누가복음(lk), 요한복음(jo)
     * 신약: 사도행전(act), 로마서(rm), 고린도전서(1co), 고린도후서(2co)
     * 신약: 갈라디아서(gl), 에베소서(eph), 빌립보서(ph), 골로새서(cl)
     * 신약: 히브리서(hb), 야고보서(jm), 베드로전서(1pe), 요한일서(1jo)
   - 모든 성경 인용에 반드시 링크 포함

4. **검색 방법**
   - YouTube에서 "찬송가 [키워드 관련 찬송가 번호]" 검색
   - 예: 키워드가 "사랑"이면 → "찬송가 364장" (내 주를 가까이) 같은 관련 찬송가
   - 실제 존재하는 찬송가 번호만 사용

### 3. 작성 스타일

✅ **해야 할 것**:
- 따뜻하고 진솔한 톤
- 일상 언어 사용 (쉽고 공감되게)
- 구체적인 예시와 비유
- 성경 구절 정확하게 인용
- 분량: 1500-2500자

❌ **하지 말아야 할 것**:
- 이모지 사용 금지
- 복잡한 신학 용어
- 추상적이고 관념적인 설명
- 과장이나 허위 정보

### 3. 출력 형식

반드시 유효한 JSON 형식으로 출력하세요:

{
  "title": "블로그 제목",
  "slug": "%s",
  "content": "마크다운 형식의 전체 본문 (개행은 \\n 사용)",
  "excerpt": "100-200자 요약",
  "keywords": "%s,관련단어1,관련단어2",
  "meta_description": "150-160자 설명"
}

**주의**: content 필드의 모든 개행은 \n으로 이스케이프하고, 따옴표는 \", 역슬래시는 \\\\로 이스케이프하세요.
`, date, dayOfWeek, keyword, currentMonth, slug, keyword)
}

// ShouldPublish 발행 여부 판단
func ShouldPublish(evaluation *QualityEvaluation) (bool, string) {
	// 🔧 Critical Issues가 있으면 점수를 강제로 낮춤 (AI가 점수를 잘못 주는 경우 대비)
	if len(evaluation.Feedback.CriticalIssues) > 0 {
		// Critical Issues 있으면 기술적 품질 점수를 2점으로 강제
		if evaluation.Scores.TechnicalQuality > 2.0 {
			log.Printf("⚠️  Critical Issues 발견: 기술적 품질 점수를 %.1f → 2.0으로 강제 조정", evaluation.Scores.TechnicalQuality)
			evaluation.Scores.TechnicalQuality = 2.0

			// 총점도 재계산
			evaluation.TotalScore = (evaluation.Scores.TheologicalAccuracy * 0.25) +
				(evaluation.Scores.ContentStructure * 0.20) +
				(evaluation.Scores.Engagement * 0.15) +
				(evaluation.Scores.TechnicalQuality * 0.30) +
				(evaluation.Scores.SeoOptimization * 0.10)

			log.Printf("⚠️  총점 재계산: %.1f/10", evaluation.TotalScore)
		}

		return false, fmt.Sprintf("치명적 문제 발견: %d개 (기술 점수 강제 조정)", len(evaluation.Feedback.CriticalIssues))
	}

	// 필수 통과 기준 체크
	if evaluation.Scores.TheologicalAccuracy < 6.0 {
		return false, fmt.Sprintf("신학적 정확성 미달: %.1f/10 (최소 6.0 필요)", evaluation.Scores.TheologicalAccuracy)
	}

	if evaluation.Scores.TechnicalQuality < 7.0 {
		return false, fmt.Sprintf("기술적 품질 미달: %.1f/10 (최소 7.0 필요)", evaluation.Scores.TechnicalQuality)
	}

	// 총점 체크
	if evaluation.TotalScore < 7.0 {
		return false, fmt.Sprintf("총점 미달: %.1f/10 (최소 7.0 필요)", evaluation.TotalScore)
	}

	// 권장사항 체크
	if strings.ToLower(evaluation.Recommendation) != "publish" {
		return false, fmt.Sprintf("권장사항: %s", evaluation.Recommendation)
	}

	return true, "모든 기준 통과"
}

// RegenerateBlog 평가 피드백을 기반으로 블로그 재생성
func RegenerateBlog(ctx context.Context, originalBlog BlogContent, evaluation *QualityEvaluation, customFeedback string) (*GeneratedBlog, error) {
	// Gemini API 키 확인
	apiKey := os.Getenv("GEMINI_API_KEY")
	if apiKey == "" {
		return nil, fmt.Errorf("GEMINI_API_KEY 환경변수가 설정되지 않았습니다")
	}

	// Gemini 클라이언트 생성
	client, err := genai.NewClient(ctx, &genai.ClientConfig{
		APIKey:  apiKey,
		Backend: genai.BackendGeminiAPI,
	})
	if err != nil {
		return nil, fmt.Errorf("Gemini 클라이언트 생성 실패: %w", err)
	}

	// 재생성 프롬프트 생성
	prompt := buildBlogRegenerationPrompt(originalBlog, evaluation, customFeedback)

	// 생성 설정
	genConfig := &genai.GenerateContentConfig{
		Temperature:      genai.Ptr(float32(0.7)),
		ResponseMIMEType: "application/json",
	}

	// Gemini API 호출
	contents := []*genai.Content{
		{
			Role: "user",
			Parts: []*genai.Part{
				genai.NewPartFromText(prompt),
			},
		},
	}

	resp, err := client.Models.GenerateContent(ctx, "gemini-2.0-flash-exp", contents, genConfig)
	if err != nil {
		return nil, fmt.Errorf("Gemini API 호출 실패: %w", err)
	}

	// 응답에서 텍스트 추출
	if len(resp.Candidates) == 0 || len(resp.Candidates[0].Content.Parts) == 0 {
		return nil, fmt.Errorf("Gemini API 응답이 비어있습니다")
	}

	responseText := ""
	for _, part := range resp.Candidates[0].Content.Parts {
		if part.Text != "" {
			responseText += part.Text
		}
	}

	// JSON 코드 블록 제거
	responseText = cleanJSONResponse(responseText)

	// JSON 파싱
	var blog GeneratedBlog
	if err := json.Unmarshal([]byte(responseText), &blog); err != nil {
		responseText = fixUnicodeEscapes(responseText)
		if err2 := json.Unmarshal([]byte(responseText), &blog); err2 != nil {
			return nil, fmt.Errorf("JSON 파싱 실패: %w\n원본 응답 (처음 500자): %s", err, responseText[:min(500, len(responseText))])
		}
	}

	return &blog, nil
}

// buildBlogRegenerationPrompt 블로그 재생성 프롬프트 생성
func buildBlogRegenerationPrompt(original BlogContent, evaluation *QualityEvaluation, customFeedback string) string {
	// 피드백을 문자열로 변환
	strengthsStr := ""
	for i, s := range evaluation.Feedback.Strengths {
		strengthsStr += fmt.Sprintf("%d. %s\n", i+1, s)
	}

	improvementsStr := ""
	for i, s := range evaluation.Feedback.Improvements {
		improvementsStr += fmt.Sprintf("%d. %s\n", i+1, s)
	}

	criticalIssuesStr := ""
	for i, s := range evaluation.Feedback.CriticalIssues {
		criticalIssuesStr += fmt.Sprintf("%d. %s\n", i+1, s)
	}

	// 사용자 커스텀 피드백 섹션
	customFeedbackSection := ""
	if customFeedback != "" {
		customFeedbackSection = fmt.Sprintf(`

---

## 👤 백오피스 사용자의 추가 요청사항

**⚠️ 최우선 반영 필수!**

%s

**중요**: 위의 사용자 요청사항은 AI 평가보다 우선순위가 높습니다. 반드시 모두 반영하여 재생성하세요.

---
`, customFeedback)
	}

	return fmt.Sprintf(`당신은 기독교 블로그 콘텐츠 개선 전문가입니다.

## 📋 기존 블로그 콘텐츠

**제목**: %s
**슬러그**: %s
**키워드**: %s

**본문**:
%s

---

## 📊 품질 평가 결과

**총점**: %.1f/10

**세부 점수**:
- 신학적 정확성: %.1f/10
- 콘텐츠 구조: %.1f/10
- 독자 참여도: %.1f/10
- 기술적 품질: %.1f/10
- SEO 최적화: %.1f/10

**강점**:
%s

**개선 필요사항**:
%s

**치명적 문제**:
%s
%s
---

## 🎯 재생성 요구사항

위의 평가 결과를 **반드시 반영**하여 블로그를 재생성하세요.

### ✅ 필수 개선사항

1. **치명적 문제 전체 해결** (최우선!)
   - 위에 나열된 모든 치명적 문제를 반드시 해결
   - YouTube 임베딩, 성경 링크, 찬송가 가사 등 누락된 요소 추가

2. **개선 필요사항 모두 반영**
   - 평가에서 지적된 모든 개선사항 적용
   - 문장 길이, 가독성, 구조 등 세밀하게 개선

3. **강점은 유지**
   - 평가에서 좋았던 부분은 그대로 유지
   - 신학적 정확성, 독자 공감 등 긍정적 요소 보존

### 🔍 기술적 필수사항 (매우 엄격!)

1. **YouTube 임베딩 (필수! 최우선!)**
   - **반드시 YOUTUBE_SEARCH 태그를 사용하세요 (신규 생성과 동일 방식)**
   - 형식 예시 (HTML):
     <div style="text-align: center; margin: 2rem 0;">
       <h3>관련 찬송가</h3>
       <p><strong>찬송가 305장 - 나 같은 죄인 살리신</strong></p>
       <p>YOUTUBE_SEARCH: 찬송가 305장</p>
     </div>
   - YOUTUBE_SEARCH 태그는 자동으로 실제 YouTube iframe으로 교체됨
   - 위치: "오늘의 적용" 섹션 바로 위 또는 적절한 위치
   - **⚠️ YOUTUBE_SEARCH 태그 없으면 평가 시 기술적 품질 4점 이하로 채점되어 발행 불가!**

2. **찬송가 정보 (필수!)**
   - 찬송가 번호 명시: "찬송가 XXX장" 패턴 (YouTube 섹션에 포함)
   - **⚠️ 최우선 확인: 본문에 명시한 찬송가 번호와 YOUTUBE_SEARCH의 찬송가 번호가 정확히 일치해야 함!**
   - 예시 (정확한 일치):
     * 본문: "찬송가 305장"
     * YOUTUBE_SEARCH: 찬송가 305장 ✅
   - **잘못된 예시 (불일치)**:
     * 본문: "찬송가 364장"
     * YOUTUBE_SEARCH: 찬송가 492장 ❌ (발행 불가!)
   - 전체 가사를 blockquote 형식(>)으로 포함
   - 예시:
     > **찬송가 305장 - 나 같은 죄인 살리신**
     > 1절: 나 같은 죄인 살리신...
     > 2절: 주 날 위하여 죽으사...

3. **성경 구절 링크 (필수! 최우선!)**
   - 모든 성경 인용에 내부 API 링크 추가
   - 형식: [성경구절](/api/bible/chapters/{book_id}/{chapter})
   - 주요 책 ID:
     * 구약: 창세기(gn), 출애굽기(ex), 시편(ps), 잠언(prv), 이사야(is)
     * 신약: 마태복음(mt), 요한복음(jo), 로마서(rm), 고린도전서(1co), 빌립보서(ph), 골로새서(cl), 히브리서(hb), 야고보서(jm)
   - **⚠️ 없으면 평가 시 기술적 품질 2점 이하로 채점되어 발행 불가!**

### 📝 출력 형식

반드시 유효한 JSON 형식으로 출력하세요:

{
  "title": "개선된 블로그 제목",
  "slug": "%s",
  "content": "마크다운 형식의 전체 본문 (개행은 \\n 사용)",
  "excerpt": "100-200자 요약",
  "keywords": "%s",
  "meta_description": "150-160자 설명"
}

**주의**: content 필드의 모든 개행은 \n으로 이스케이프하고, 따옴표는 \", 역슬래시는 \\\\로 이스케이프하세요.

**목표**: 평가 점수가 최소 8.0 이상이 되도록 개선하세요!
`,
		original.Title,
		original.Slug,
		original.Keywords,
		original.Content,
		evaluation.TotalScore,
		evaluation.Scores.TheologicalAccuracy,
		evaluation.Scores.ContentStructure,
		evaluation.Scores.Engagement,
		evaluation.Scores.TechnicalQuality,
		evaluation.Scores.SeoOptimization,
		strengthsStr,
		improvementsStr,
		criticalIssuesStr,
		customFeedbackSection,
		original.Slug,
		original.Keywords,
	)
}
