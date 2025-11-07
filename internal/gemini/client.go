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

	// ✨ 코드 기반 기술적 검증 수행
	log.Printf("🔧 코드 기반 기술 검증 시작...")
	techValidation := ValidateTechnicalQuality(blog.Content)

	// Gemini의 critical_issues를 기술적 검증 결과로 대체
	evaluation.Feedback.CriticalIssues = techValidation.CriticalIssues

	// 기술적 품질 점수 강제 조정
	originalTechnical := evaluation.Scores.TechnicalQuality
	if len(techValidation.CriticalIssues) > 0 {
		evaluation.Scores.TechnicalQuality = CalculateTechnicalScore(techValidation)
		log.Printf("⚠️  기술적 검증: %d개 문제 발견, 점수 %.1f → %.1f 강제 조정",
			len(techValidation.CriticalIssues),
			originalTechnical,
			evaluation.Scores.TechnicalQuality)
	} else {
		// 문제 없으면 원래 점수 유지 (최대 9점)
		if evaluation.Scores.TechnicalQuality > 9.0 {
			evaluation.Scores.TechnicalQuality = 9.0
		}
		log.Printf("✅ 기술적 검증: 문제 없음, 점수 %.1f 유지", evaluation.Scores.TechnicalQuality)
	}

	// Feedback의 strengths에 검증 성공 항목 추가
	if len(techValidation.DetailedLog) > 0 {
		// 기존 strengths 유지하면서 기술 검증 결과 추가
		newStrengths := []string{}
		for _, strength := range evaluation.Feedback.Strengths {
			// 기존의 기술 관련 피드백은 제거 (중복 방지)
			if !strings.Contains(strength, "YouTube") &&
				!strings.Contains(strength, "찬송가") &&
				!strings.Contains(strength, "성경 구절") {
				newStrengths = append(newStrengths, strength)
			}
		}
		// 기술 검증 로그 추가
		for _, logItem := range techValidation.DetailedLog {
			if strings.HasPrefix(logItem, "✅") {
				newStrengths = append(newStrengths, logItem)
			}
		}
		evaluation.Feedback.Strengths = newStrengths
	}

	// 총점 재계산 (가중치 반영)
	evaluation.TotalScore =
		(evaluation.Scores.TheologicalAccuracy * 0.25) +
			(evaluation.Scores.ContentStructure * 0.20) +
			(evaluation.Scores.Engagement * 0.15) +
			(evaluation.Scores.TechnicalQuality * 0.30) +
			(evaluation.Scores.SeoOptimization * 0.10)

	log.Printf("📊 최종 총점: %.1f/10 (기술 검증 반영 후)", evaluation.TotalScore)

	return &evaluation, nil
}

// buildEvaluationPrompt 평가 프롬프트 생성
func buildEvaluationPrompt(blog BlogContent) string {
	// 블로그 콘텐츠 JSON 변환
	contentJSON, _ := json.MarshalIndent(blog, "", "  ")

	prompt := `당신은 기독교 블로그 콘텐츠 품질 평가 전문가입니다.

## 📋 평가 대상 콘텐츠

` + string(contentJSON) + `

---

## 🎯 평가 기준 (각 항목 1-10점)

### 1. 신학적 정확성 (가중치 25%)
- 성경 해석의 정확성
- 교리적 적합성
- 복음의 핵심 메시지

**점수 가이드:**
- 9-10점: 신학적으로 완벽하고 깊이 있음
- 7-8점: 정확하며 적절함
- 5-6점: 대체로 괜찮으나 일부 개선 필요
- 1-4점: 심각한 신학적 오류

### 2. 콘텐츠 구조 (가중치 20%)
- 논리적 흐름
- 문단 구성의 적절성
- 섹션 간 연결성

### 3. 독자 참여도 (가중치 15%)
- 독자 공감 유도
- 실생활 적용 가능성
- 구체적 예시 사용

### 4. 기술적 품질 (가중치 30%)
⚠️ **주의: YouTube 임베딩, 찬송가 번호, 성경 링크는 시스템이 자동으로 검증합니다.**
**여기서는 맞춤법, 문법, 문장 구조, 가독성만 평가하세요.**

**평가 항목:**
- 맞춤법 및 문법
- 문장 길이의 적절성
- 어휘 사용의 적절성
- 전반적인 가독성

### 5. SEO 최적화 (가중치 10%)
- 키워드 자연스러운 포함
- 제목의 매력도
- 메타 설명 적절성

---

## 📊 출력 형식 (JSON)

{
  "scores": {
    "theological_accuracy": 8,
    "content_structure": 7,
    "engagement": 9,
    "technical_quality": 8,
    "seo_optimization": 7
  },
  "total_score": 0,
  "feedback": {
    "strengths": [
      "신학적 정확성이 뛰어나며 복음의 핵심이 잘 드러남",
      "독자와의 공감대 형성이 탁월함"
    ],
    "improvements": [
      "일부 문장이 너무 길어 가독성 저하"
    ],
    "critical_issues": []
  },
  "recommendation": "publish",
  "confidence": "high"
}

**중요 지침:**
- **critical_issues는 비워두세요** (시스템이 자동으로 YouTube, 찬송가, 성경 링크 검증)
- **total_score는 0으로 두세요** (시스템이 가중치 적용하여 자동 계산)
- **기술적 품질은 맞춤법/문법/가독성만 평가** (기술 요소는 코드로 검증)

이제 위의 콘텐츠를 평가하고 JSON 형식으로 결과를 출력해주세요.`

	return prompt
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

	// 제목 최적화 도구 사용
	titleOptimizer := NewTitleOptimizer()
	suggestedTitle := titleOptimizer.GenerateTitle(keyword, dateObj)

	return fmt.Sprintf(`당신은 기독교 신앙 블로그 전문 작가입니다.

## 📅 작성 정보
- 날짜: %s
- 요일: %s
- 키워드: %s
- 현재 월: %d월

## ✍️ 작성 요구사항

### 1. 구조 (⚠️ 반드시 이 순서와 형식으로!)

#### (1) 제목 (H1)
- 다음 제목을 사용하세요: "%s"
- (이 제목은 사용자 리텐션을 위해 최적화되었습니다)

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
   - **⚠️ 매우 중요: 하나의 찬송가 번호만 선택하고, 모든 곳에서 동일한 번호를 사용하세요!**
   - 키워드와 관련된 찬송가를 선택 (예: "기도" → 찬송가 305장)
   - 임베드 위치: "오늘의 적용" 섹션 바로 위에 배치
   - **반드시 아래 형식을 정확히 따를 것:**

   예시 HTML:
   <div style="text-align: center; margin: 2rem 0;">
     <h3>관련 찬송가</h3>
     <p><strong>찬송가 305장 - 나 같은 죄인 살리신</strong></p>
     <p>YOUTUBE_SEARCH: 찬송가 305장</p>
   </div>

   - **⚠️⚠️⚠️ 절대 엄수 사항:**
     * 한 번 선택한 찬송가 번호는 끝까지 일관되게 사용
     * 본문에 "찬송가 305장"이라고 쓴 경우 → YOUTUBE_SEARCH와 가사 섹션에도 반드시 "305장"
     * 절대 다른 번호로 바꾸지 말 것!
     * 잘못된 예: 제목 "305장" → YOUTUBE_SEARCH "492장" ❌ (이것은 절대 금지!)
   - 찬송가 번호와 제목을 정확히 명시

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
`, date, dayOfWeek, keyword, currentMonth, suggestedTitle, slug, keyword)
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
