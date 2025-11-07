package gemini

import (
	"fmt"
	"math/rand"
	"strings"
	"time"
)

// TitlePattern 제목 패턴 구조체
type TitlePattern struct {
	Template string
	Category string
	Weight   int // 선택 가중치 (높을수록 자주 선택됨)
}

// TitleOptimizer 제목 최적화 도구
type TitleOptimizer struct {
	patterns []TitlePattern
	rng      *rand.Rand
}

// NewTitleOptimizer 제목 최적화 도구 생성
func NewTitleOptimizer() *TitleOptimizer {
	return &TitleOptimizer{
		patterns: initTitlePatterns(),
		rng:      rand.New(rand.NewSource(time.Now().UnixNano())),
	}
}

// initTitlePatterns 제목 패턴 초기화
func initTitlePatterns() []TitlePattern {
	return []TitlePattern{
		// 감정 트리거 패턴 (리텐션 높음)
		{Template: "오늘의 위로: {keyword}", Category: "emotional", Weight: 10},
		{Template: "당신을 위한 {keyword}", Category: "emotional", Weight: 9},
		{Template: "{keyword}로 얻는 진정한 평안", Category: "emotional", Weight: 8},
		{Template: "지친 마음에 전하는 {keyword}", Category: "emotional", Weight: 8},

		// 시간 기반 패턴
		{Template: "[{time_prefix}] {keyword}로 시작하는 하루", Category: "time", Weight: 7},
		{Template: "{time_prefix}에 만나는 {keyword}", Category: "time", Weight: 6},

		// 질문형 패턴 (호기심 유발)
		{Template: "왜 우리는 {keyword}가 필요할까?", Category: "question", Weight: 8},
		{Template: "어떻게 {keyword}를 실천할 수 있을까?", Category: "question", Weight: 7},
		{Template: "{keyword}, 정말 가능할까?", Category: "question", Weight: 6},

		// 숫자 활용 패턴 (구체성)
		{Template: "{keyword}를 위한 3가지 말씀", Category: "numbered", Weight: 7},
		{Template: "오늘 꼭 기억할 {keyword}의 의미", Category: "numbered", Weight: 6},
		{Template: "5분 묵상: {keyword}와 함께", Category: "numbered", Weight: 8},

		// 약속/보장형 패턴
		{Template: "{keyword}가 주는 놀라운 변화", Category: "promise", Weight: 7},
		{Template: "{keyword}로 찾은 새로운 삶", Category: "promise", Weight: 6},

		// 시즌/이벤트 패턴
		{Template: "[{month}월 특별 메시지] {keyword}", Category: "seasonal", Weight: 5},
		{Template: "[주일 묵상] {keyword}와 함께하는 안식", Category: "seasonal", Weight: 6},
	}
}

// GenerateTitle 최적화된 제목 생성
func (to *TitleOptimizer) GenerateTitle(keyword string, date time.Time) string {
	// 시간 기반 접두사 결정
	timePrefix := to.getTimePrefix(date)
	month := int(date.Month())
	dayOfWeek := date.Weekday()

	// 적절한 패턴 선택 (가중치 기반)
	pattern := to.selectPattern(dayOfWeek)

	// 템플릿 변수 치환 (한국어 조사 처리 포함)
	title := strings.ReplaceAll(pattern.Template, "{keyword}", keyword)
	title = to.fixKoreanJosa(title, keyword)
	title = strings.ReplaceAll(title, "{time_prefix}", timePrefix)
	title = strings.ReplaceAll(title, "{month}", fmt.Sprintf("%d", month))

	return title
}

// getTimePrefix 시간대별 접두사 결정
func (to *TitleOptimizer) getTimePrefix(date time.Time) string {
	hour := date.Hour()

	switch {
	case hour >= 4 && hour < 7:
		return "새벽 기도"
	case hour >= 7 && hour < 10:
		return "아침 묵상"
	case hour >= 10 && hour < 12:
		return "오전 말씀"
	case hour >= 12 && hour < 15:
		return "점심 묵상"
	case hour >= 15 && hour < 18:
		return "오후의 은혜"
	case hour >= 18 && hour < 21:
		return "저녁 기도"
	default:
		return "밤의 묵상"
	}
}

// selectPattern 가중치 기반 패턴 선택
func (to *TitleOptimizer) selectPattern(dayOfWeek time.Weekday) TitlePattern {
	// 요일별 카테고리 우선순위 조정
	var filteredPatterns []TitlePattern

	switch dayOfWeek {
	case time.Monday:
		// 월요일: 위로와 격려 중심
		for _, p := range to.patterns {
			if p.Category == "emotional" || p.Category == "promise" {
				p.Weight *= 2 // 가중치 2배
			}
			filteredPatterns = append(filteredPatterns, p)
		}
	case time.Friday:
		// 금요일: 감사와 마무리
		for _, p := range to.patterns {
			if p.Category == "numbered" || p.Category == "time" {
				p.Weight *= 2
			}
			filteredPatterns = append(filteredPatterns, p)
		}
	case time.Sunday:
		// 주일: 특별 메시지
		for _, p := range to.patterns {
			if p.Category == "seasonal" {
				p.Weight *= 3
			}
			filteredPatterns = append(filteredPatterns, p)
		}
	default:
		filteredPatterns = to.patterns
	}

	// 가중치 기반 랜덤 선택
	totalWeight := 0
	for _, p := range filteredPatterns {
		totalWeight += p.Weight
	}

	randomWeight := to.rng.Intn(totalWeight)
	currentWeight := 0

	for _, p := range filteredPatterns {
		currentWeight += p.Weight
		if randomWeight < currentWeight {
			return p
		}
	}

	// 기본값 (도달하지 않아야 함)
	return filteredPatterns[0]
}

// GetSEOKeywords 제목에 추가할 SEO 키워드 추출
func (to *TitleOptimizer) GetSEOKeywords(keyword string) []string {
	// 기본 SEO 키워드
	baseKeywords := []string{
		"오늘의", "매일", "은혜", "말씀", "기도", "묵상", "성경",
	}

	// 키워드별 연관 단어
	relatedMap := map[string][]string{
		"사랑":  {"하나님의 사랑", "이웃 사랑", "참사랑"},
		"평안":  {"평화", "안식", "쉼"},
		"기도":  {"간구", "중보", "감사"},
		"믿음":  {"신앙", "확신", "소망"},
		"감사":  {"감사절", "감사 기도", "감사 찬양"},
		"용서":  {"화해", "회개", "자비"},
		"소망":  {"희망", "기대", "미래"},
		"은혜":  {"축복", "감동", "선물"},
	}

	keywords := append([]string{}, baseKeywords...)

	// 연관 키워드 추가
	if related, exists := relatedMap[keyword]; exists {
		keywords = append(keywords, related...)
	}

	return keywords
}

// GenerateEngagingTitle A/B 테스트용 제목 변형 생성
func (to *TitleOptimizer) GenerateEngagingTitle(keyword string, date time.Time, version int) string {
	titles := []string{
		to.GenerateTitle(keyword, date),
	}

	// 버전별 다른 패턴 강제 선택
	for i := 1; i < 3; i++ {
		// 다른 카테고리 패턴 선택을 위해 시간 조작
		fakeDate := date.Add(time.Hour * time.Duration(i*6))
		titles = append(titles, to.GenerateTitle(keyword, fakeDate))
	}

	if version >= 0 && version < len(titles) {
		return titles[version]
	}

	return titles[0]
}

// fixKoreanJosa 한국어 조사 자동 수정
func (to *TitleOptimizer) fixKoreanJosa(title string, keyword string) string {
	// 키워드의 마지막 글자로 받침 여부 확인
	hasJongsung := hasKoreanJongsung(keyword)

	// 조사 교정
	if hasJongsung {
		// 받침이 있는 경우
		title = strings.ReplaceAll(title, keyword+"를", keyword+"을")
		title = strings.ReplaceAll(title, keyword+"가", keyword+"이")
		title = strings.ReplaceAll(title, keyword+"와", keyword+"과")
		title = strings.ReplaceAll(title, keyword+"는", keyword+"은")
		title = strings.ReplaceAll(title, keyword+"로", keyword+"으로")
	} else {
		// 받침이 없는 경우
		title = strings.ReplaceAll(title, keyword+"을", keyword+"를")
		title = strings.ReplaceAll(title, keyword+"이", keyword+"가")
		title = strings.ReplaceAll(title, keyword+"과", keyword+"와")
		title = strings.ReplaceAll(title, keyword+"은", keyword+"는")
		// "로"는 그대로
	}

	return title
}

// hasKoreanJongsung 한글 문자열의 마지막 글자 받침 여부 확인
func hasKoreanJongsung(str string) bool {
	if str == "" {
		return false
	}

	// 문자열의 마지막 문자 추출
	runes := []rune(str)
	lastRune := runes[len(runes)-1]

	// 한글 유니코드 범위 확인 (가=0xAC00, 힣=0xD7A3)
	if lastRune < 0xAC00 || lastRune > 0xD7A3 {
		return false
	}

	// 종성 확인: (문자코드 - 0xAC00) % 28
	// 28로 나눈 나머지가 0이면 받침이 없음
	return (lastRune-0xAC00)%28 != 0
}