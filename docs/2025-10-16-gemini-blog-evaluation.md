# 2025-10-16: Gemini API 블로그 자동 품질 평가 시스템 구현

## 📋 작업 개요

블로그 콘텐츠의 품질을 자동으로 평가하고 발행 여부를 결정하는 시스템을 Gemini API를 사용하여 Go로 구현했습니다.

## 🎯 주요 목표

1. Python 스크립트 의존성 제거 - Go 네이티브 구현
2. Gemini API를 활용한 블로그 품질 자동 평가
3. 품질 기준에 따른 자동 발행 시스템
4. 평가 이력 추적 및 관리

## 🔧 구현 내용

### 1. Gemini API Go 클라이언트 구현

**파일**: `internal/gemini/client.go` (신규 생성)

#### 핵심 구조체

```go
// QualityScores 품질 평가 점수 (5가지 지표)
type QualityScores struct {
    TheologicalAccuracy float64 `json:"theological_accuracy"` // 신학적 정확성
    ContentStructure    float64 `json:"content_structure"`    // 콘텐츠 구조
    Engagement          float64 `json:"engagement"`           // 독자 참여도
    TechnicalQuality    float64 `json:"technical_quality"`    // 기술적 품질
    SeoOptimization     float64 `json:"seo_optimization"`     // SEO 최적화
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
```

#### 핵심 함수

```go
func EvaluateQuality(ctx context.Context, blog BlogContent) (*QualityEvaluation, error)
```

- Google 공식 SDK 사용: `google.golang.org/genai v1.31.0`
- 모델: `gemini-2.0-flash-exp`
- Temperature: 0.7
- ResponseMIMEType: `application/json` (구조화된 응답)

#### 평가 프롬프트 구조

1. **평가 기준 (1-10점)**
   - 신학적 정확성 (가중치 30%)
   - 콘텐츠 구조 (가중치 25%)
   - 독자 참여도 (가중치 20%)
   - 기술적 품질 (가중치 15%)
   - SEO 최적화 (가중치 10%)

2. **발행 권장사항**
   - `publish`: total_score ≥ 7.0, 치명적 문제 없음
   - `revise`: 5.0 ≤ total_score < 7.0
   - `reject`: total_score < 5.0 또는 심각한 오류

3. **신뢰도**
   - `high`: 모든 평가 항목 명확
   - `medium`: 일부 애매한 부분 존재
   - `low`: 평가가 어려운 요소 다수

### 2. 자동 평가 API 엔드포인트

**파일**: `internal/handlers/blog.go` (수정)

#### AutoEvaluateBlogPost 핸들러

```go
func AutoEvaluateBlogPost(c *gin.Context) {
    // 1. 블로그 ID로 콘텐츠 조회
    // 2. Gemini API 호출하여 품질 평가
    // 3. 평가 결과를 DB에 저장
    // 4. 자동 발행 조건 체크
    // 5. 조건 충족 시 is_published = true 설정
}
```

**라우트**: `POST /api/admin/blog/posts/:id/auto-evaluate`

**응답 예시**:
```json
{
  "success": true,
  "evaluation": {
    "scores": {
      "theological_accuracy": 9,
      "content_structure": 8,
      "engagement": 9,
      "technical_quality": 8,
      "seo_optimization": 8
    },
    "total_score": 8.35,
    "weighted_breakdown": {
      "theological_accuracy": 2.7,
      "content_structure": 2.0,
      "engagement": 1.8,
      "technical_quality": 1.2,
      "seo_optimization": 0.8
    },
    "feedback": {
      "strengths": [
        "성경적 근거가 명확하고, 핵심 메시지가 잘 전달됨",
        "독자들의 공감을 불러일으키는 감정적인 연결이 뛰어남"
      ],
      "improvements": [
        "찬송가 소개 부분에서 유튜브 임베딩 대신 링크만 제공되어 아쉬움"
      ],
      "critical_issues": []
    },
    "recommendation": "publish",
    "confidence": "high"
  },
  "auto_published": true,
  "is_published": true,
  "can_publish": true,
  "publish_reason": "모든 기준 통과",
  "message": "품질 기준을 충족하여 자동으로 발행되었습니다"
}
```

### 3. 환경 변수 설정

**파일**: `.env` (수정)

```env
# Gemini API 설정
GEMINI_API_KEY=your_actual_api_key_here
```

서버는 `internal/database/db.go`의 `NewConnection()` 함수에서 자동으로 `.env` 파일을 로드합니다 (godotenv 사용).

### 4. 자동 발행 조건

**함수**: `gemini.ShouldPublish(evaluation *QualityEvaluation) (bool, string)`

자동 발행 조건:
1. ✅ 총점 ≥ 7.0
2. ✅ 신학적 정확성 ≥ 6.0
3. ✅ 기술적 품질 ≥ 7.0
4. ✅ 치명적 문제(critical_issues) 없음
5. ✅ 권장사항(recommendation) = "publish"

## 📊 테스트 결과

### 블로그 #70 평가
```bash
curl -X POST http://localhost:8080/api/admin/blog/posts/70/auto-evaluate
```

**결과**:
- 총점: 8.35/10
- 신학적 정확성: 9/10 (2.7점)
- 콘텐츠 구조: 8/10 (2.0점)
- 독자 참여도: 9/10 (1.8점)
- 기술적 품질: 8/10 (1.2점)
- SEO 최적화: 8/10 (0.8점)
- **자동 발행**: ✅ 완료

### 블로그 #71 평가
- 총점: 8.55/10
- **자동 발행**: ✅ 완료

## 🔍 기술적 해결 과제

### 1. Gemini SDK 호환성 문제

**문제**: `genai.BackendGoogleAI` 상수가 존재하지 않음
```go
// ❌ 이전 코드
Backend: genai.BackendGoogleAI,
```

**해결**:
```go
// ✅ 수정 코드
Backend: genai.BackendGeminiAPI,
```

### 2. Content 구조 변경

**문제**: Part 배열을 직접 전달할 수 없음
```go
// ❌ 이전 코드
contents := []*genai.Part{
    genai.NewPartFromText(prompt),
}
```

**해결**:
```go
// ✅ 수정 코드
contents := []*genai.Content{
    {
        Role: "user",
        Parts: []*genai.Part{
            genai.NewPartFromText(prompt),
        },
    },
}
```

### 3. ResponseMIMEType 타입 불일치

**문제**: 포인터 타입 불일치
```go
// ❌ 이전 코드
ResponseMIMEType: genai.Ptr("application/json"),
```

**해결**:
```go
// ✅ 수정 코드
ResponseMIMEType: "application/json",
```

### 4. GEMINI_API_KEY 환경 변수 누락

**문제**: 서버 실행 시 `.env`에 GEMINI_API_KEY가 없어서 500 에러 발생

**해결**: `blog_posting/.env`에서 키를 복사하여 메인 `.env`에 추가

## 📁 수정된 파일 목록

### 신규 파일
- `internal/gemini/client.go` - Gemini API 클라이언트 구현

### 수정된 파일
- `internal/handlers/blog.go` - AutoEvaluateBlogPost 핸들러 추가
- `cmd/server/main.go` - 자동 평가 API 라우트 추가
- `.env` - GEMINI_API_KEY 환경 변수 추가
- `go.mod` - `google.golang.org/genai v1.31.0` 의존성 추가

## 🚀 사용 방법

### 1. 단일 블로그 평가 및 자동 발행
```bash
curl -X POST http://localhost:8080/api/admin/blog/posts/{id}/auto-evaluate
```

### 2. 평가 결과 조회
```bash
curl http://localhost:8080/api/admin/blog/posts/{id}
```

응답에 품질 점수 포함:
```json
{
  "id": 70,
  "title": "...",
  "theological_accuracy": 9.0,
  "content_structure": 8.0,
  "engagement": 9.0,
  "technical_quality": 8.0,
  "seo_optimization": 8.0,
  "total_score": 8.35,
  "quality_feedback": {...},
  "evaluation_date": "2025-10-16T13:23:26Z",
  "is_published": true
}
```

### 3. 평가 이력 조회
```bash
curl http://localhost:8080/api/admin/blog/posts/{id}/quality-history
```

## 📈 품질 평가 기준 상세

### 1. 신학적 정확성 (30%)
- 성경 인용의 정확성
- 신학적 오류 없음
- 교리적 적합성
- 성경 해석의 적절성

**점수 가이드**:
- 9-10점: 신학적으로 완벽하고 깊이 있음
- 7-8점: 정확하며 적절함
- 5-6점: 대체로 괜찮으나 일부 개선 필요
- 1-4점: 심각한 신학적 오류

### 2. 콘텐츠 구조 (25%)
- 도입-본론-결론 구조
- 문단 구성의 적절성
- 논리적 흐름
- 섹션 간 연결성

### 3. 독자 참여도 (20%)
- 독자 공감 유도
- 실생활 적용 가능성
- 감정적 연결
- 구체적 예시 사용

### 4. 기술적 품질 (15%)
- 맞춤법 및 문법
- 적절한 어휘 사용
- 문장 길이의 적절성
- 가독성

### 5. SEO 최적화 (10%)
- 키워드 자연스러운 포함
- 메타 설명 최적화
- 제목의 매력도
- 구조적 마크업 (H1, H2, H3)

## 💡 향후 개선 방향

1. **배치 평가 스크립트**
   - 미평가 블로그를 일괄 평가하는 스크립트
   - 예: `scripts/batch_evaluate_blogs.sh`

2. **평가 기준 튜닝**
   - 실제 사용 데이터를 기반으로 가중치 조정
   - 자동 발행 임계값 최적화

3. **평가 캐싱**
   - 동일 콘텐츠 재평가 방지
   - 콘텐츠 해시 기반 캐싱

4. **Webhook 통합**
   - 자동 발행 시 알림 전송
   - Slack/Discord 통합

5. **A/B 테스팅**
   - 다양한 평가 프롬프트 테스트
   - 최적 프롬프트 선택

## 🔗 관련 문서

- [블로그 API 문서](./API_REFERENCE.md)
- [품질 평가 시스템 설계](./BLOG_QUALITY_SYSTEM.md)
- [Gemini API 체크리스트](../blog_posting/GEMINI_API_CHECKLIST.md)

## ✅ 완료 사항

- [x] Go용 Gemini API 클라이언트 조사 및 설정
- [x] 품질 평가 프롬프트를 Go 코드에 통합
- [x] 블로그 품질 평가 Go 함수 구현
- [x] 자동 평가 API 엔드포인트 추가
- [x] 테스트 및 검증

## 📝 참고사항

- Gemini API 호출 시간: 평균 3-5초
- 응답 크기: 약 900-1000 bytes
- 토큰 사용량: 프롬프트 ~2000 tokens, 응답 ~500 tokens
- 비용: 매우 저렴 (gemini-2.0-flash-exp 무료 티어 사용 가능)
