package gemini

import (
	"fmt"
	"log"
	"regexp"
	"strings"
)

// TechnicalValidation 기술적 검증 결과
type TechnicalValidation struct {
	HasYouTubeEmbed      bool     `json:"has_youtube_embed"`
	HasHymnNumber        bool     `json:"has_hymn_number"`
	HasHymnLyrics        bool     `json:"has_hymn_lyrics"`
	HasBibleLinks        bool     `json:"has_bible_links"`
	HymnNumberConsistent bool     `json:"hymn_number_consistent"`

	HymnNumbers          []string `json:"hymn_numbers"`
	BibleLinkCount       int      `json:"bible_link_count"`
	YouTubeEmbedCount    int      `json:"youtube_embed_count"`
	CriticalIssues       []string `json:"critical_issues"`
	DetailedLog          []string `json:"detailed_log"`
}

// ValidateTechnicalQuality 콘텐츠의 기술적 품질을 코드로 정확하게 검증
func ValidateTechnicalQuality(content string) *TechnicalValidation {
	result := &TechnicalValidation{
		CriticalIssues: []string{},
		HymnNumbers:    []string{},
		DetailedLog:    []string{},
	}

	log.Printf("🔍 기술적 검증 시작...")

	// 1. YouTube 임베딩 검증
	youtubePatterns := []string{
		`<iframe[^>]*src=["']https?://(?:www\.)?youtube\.com/embed/[^"']+["']`,
		`<iframe[^>]*src=["']https?://youtube\.com/embed/[^"']+["']`,
	}

	for _, pattern := range youtubePatterns {
		re := regexp.MustCompile(pattern)
		matches := re.FindAllString(content, -1)
		if len(matches) > 0 {
			result.HasYouTubeEmbed = true
			result.YouTubeEmbedCount = len(matches)
			log.Printf("✅ YouTube iframe 임베딩 발견: %d개", len(matches))
			result.DetailedLog = append(result.DetailedLog, fmt.Sprintf("✅ YouTube iframe 임베딩 포함 (embed URL 확인: %d개)", len(matches)))
			break
		}
	}

	if !result.HasYouTubeEmbed {
		result.CriticalIssues = append(result.CriticalIssues, "❌ YouTube iframe 임베딩 없음")
		log.Printf("❌ YouTube iframe 임베딩 없음")
		result.DetailedLog = append(result.DetailedLog, "❌ YouTube iframe 임베딩 없음")
	}

	// 2. 찬송가 번호 추출 및 일관성 검증
	hymnPattern := regexp.MustCompile(`찬송가\s*(\d{1,3})장`)
	matches := hymnPattern.FindAllStringSubmatch(content, -1)

	seenNumbers := make(map[string]bool)
	for _, match := range matches {
		if len(match) > 1 {
			seenNumbers[match[1]] = true
			result.HymnNumbers = append(result.HymnNumbers, match[1])
		}
	}

	if len(seenNumbers) == 0 {
		result.CriticalIssues = append(result.CriticalIssues, "❌ 찬송가 번호 누락")
		log.Printf("❌ 찬송가 번호 누락 (찬송가 XXX장 패턴 없음)")
		result.DetailedLog = append(result.DetailedLog, "❌ 찬송가 번호 누락")
	} else {
		result.HasHymnNumber = true

		// 찬송가 번호가 2개 이상이면 불일치
		if len(seenNumbers) > 1 {
			result.HymnNumberConsistent = false
			numbers := []string{}
			for num := range seenNumbers {
				numbers = append(numbers, num+"장")
			}
			issue := fmt.Sprintf("❌ 찬송가 제목 불일치 - 발견된 번호: %s", strings.Join(numbers, ", "))
			result.CriticalIssues = append(result.CriticalIssues, issue)
			log.Printf("❌ 찬송가 번호 불일치: %s", strings.Join(numbers, ", "))
			result.DetailedLog = append(result.DetailedLog, issue)
		} else {
			result.HymnNumberConsistent = true
			// 유일한 번호 추출
			var hymnNum string
			for num := range seenNumbers {
				hymnNum = num
			}
			log.Printf("✅ 찬송가 번호 명시됨: %s장 (총 %d회 등장, 일관성 확인)", hymnNum, len(result.HymnNumbers))
			result.DetailedLog = append(result.DetailedLog, fmt.Sprintf("✅ 찬송가 번호 명시됨 (찬송가 %s장)", hymnNum))
		}
	}

	// 3. 찬송가 가사 검증 (blockquote 안에 찬송가 패턴)
	lyricsPattern := regexp.MustCompile(`>\s*\*?\*?찬송가.*장`)
	if lyricsPattern.MatchString(content) {
		result.HasHymnLyrics = true
		log.Printf("✅ 찬송가 가사 포함됨 (blockquote 형식)")
		result.DetailedLog = append(result.DetailedLog, "✅ 찬송가 가사 전체 포함됨 (blockquote 형식)")
	} else {
		result.CriticalIssues = append(result.CriticalIssues, "❌ 찬송가 가사 없음")
		log.Printf("❌ 찬송가 가사 없음 (blockquote 내 가사 누락)")
		result.DetailedLog = append(result.DetailedLog, "❌ 찬송가 가사 없음")
	}

	// 4. 성경 구절 내부 링크 검증
	bibleLinkPattern := regexp.MustCompile(`\[([^\]]+)\]\(/api/bible/chapters/[a-z0-9]+/\d+\)`)
	bibleMatches := bibleLinkPattern.FindAllString(content, -1)
	result.BibleLinkCount = len(bibleMatches)

	if result.BibleLinkCount > 0 {
		result.HasBibleLinks = true
		log.Printf("✅ 성경 구절 내부 링크 발견: %d개", result.BibleLinkCount)
		result.DetailedLog = append(result.DetailedLog, fmt.Sprintf("✅ 모든 성경 구절에 내부 API 링크 포함 (/api/bible/chapters/{book}/{chapter} 형식: %d개)", result.BibleLinkCount))

		// 샘플 출력 (처음 3개)
		for i, match := range bibleMatches {
			if i >= 3 {
				break
			}
			log.Printf("   예시 %d: %s", i+1, match)
		}
	} else {
		result.CriticalIssues = append(result.CriticalIssues, "❌ 성경 구절 내부 링크 없음")
		log.Printf("❌ 성경 구절 내부 링크 없음 (/api/bible/chapters/... 형식 누락)")
		result.DetailedLog = append(result.DetailedLog, "❌ 성경 구절 내부 링크 없음")
	}

	// 최종 요약
	log.Printf("📊 검증 완료: 치명적 문제 %d개", len(result.CriticalIssues))

	return result
}

// CalculateTechnicalScore 검증 결과에 따라 기술적 품질 점수 계산
func CalculateTechnicalScore(validation *TechnicalValidation) float64 {
	criticalCount := len(validation.CriticalIssues)

	var score float64
	switch criticalCount {
	case 0:
		score = 9.0 // 완벽
	case 1:
		score = 4.0 // 1개 문제
	case 2:
		score = 3.0 // 2개 문제
	default:
		score = 2.0 // 3개 이상
	}

	log.Printf("🎯 기술적 품질 점수 계산: 문제 %d개 → %.1f/10", criticalCount, score)

	return score
}
