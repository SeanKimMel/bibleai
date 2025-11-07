package main

import (
	"bibleai/internal/gemini"
	"fmt"
	"time"
)

func main() {
	// 제목 최적화 도구 생성
	optimizer := gemini.NewTitleOptimizer()

	// 테스트 키워드들
	keywords := []string{"사랑", "평안", "기도", "감사", "소망"}

	fmt.Println("=== 블로그 제목 최적화 테스트 ===\n")

	// 각 키워드에 대해 다양한 시간대와 요일로 테스트
	for _, keyword := range keywords {
		fmt.Printf("키워드: %s\n", keyword)
		fmt.Println("--------------------------------------------------")

		// 월요일 아침
		mondayMorning := time.Date(2025, 11, 10, 8, 0, 0, 0, time.Local)
		title1 := optimizer.GenerateTitle(keyword, mondayMorning)
		fmt.Printf("월요일 아침: %s\n", title1)

		// 금요일 저녁
		fridayEvening := time.Date(2025, 11, 14, 19, 0, 0, 0, time.Local)
		title2 := optimizer.GenerateTitle(keyword, fridayEvening)
		fmt.Printf("금요일 저녁: %s\n", title2)

		// 주일 아침
		sundayMorning := time.Date(2025, 11, 16, 9, 0, 0, 0, time.Local)
		title3 := optimizer.GenerateTitle(keyword, sundayMorning)
		fmt.Printf("주일 아침: %s\n", title3)

		// A/B 테스트용 변형 생성
		fmt.Println("\nA/B 테스트 변형:")
		for i := 0; i < 3; i++ {
			variant := optimizer.GenerateEngagingTitle(keyword, mondayMorning, i)
			fmt.Printf("  변형 %c: %s\n", 'A'+i, variant)
		}

		// SEO 키워드 추출
		seoKeywords := optimizer.GetSEOKeywords(keyword)
		fmt.Printf("\nSEO 키워드: %v\n", seoKeywords[:5]) // 처음 5개만 표시

		fmt.Println()
	}

	// 성능 비교 예시
	fmt.Println("\n=== 제목 패턴 성능 비교 ===")
	fmt.Println("(시뮬레이션 데이터)")
	fmt.Println()

	patterns := []struct {
		title       string
		views       int
		ctr         float64
		avgReadTime int
	}{
		{"오늘의 위로: 평안", 1250, 8.5, 180},
		{"평안을 찾아서", 800, 5.2, 120},
		{"5분 묵상: 평안과 함께", 1100, 7.8, 200},
		{"왜 우리는 평안이 필요할까?", 950, 6.9, 165},
	}

	for _, p := range patterns {
		fmt.Printf("제목: %-35s | 조회수: %4d | CTR: %4.1f%% | 평균체류: %3d초\n",
			p.title, p.views, p.ctr, p.avgReadTime)
	}

	fmt.Println("\n✅ 최적화된 제목들이 더 높은 클릭률과 체류시간을 보입니다!")
}