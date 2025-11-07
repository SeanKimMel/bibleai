package hymn

import (
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"regexp"
	"strings"
	"time"
)

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

	client := &http.Client{
		Timeout: 5 * time.Second,
	}

	resp, err := client.Get(apiURL)
	if err != nil {
		return "", "", fmt.Errorf("API 요청 실패: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return "", "", fmt.Errorf("API 응답 실패: %d", resp.StatusCode)
	}

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return "", "", fmt.Errorf("응답 읽기 실패: %w", err)
	}

	var response HymnResponse
	if err := json.Unmarshal(body, &response); err != nil {
		return "", "", fmt.Errorf("JSON 파싱 실패: %w", err)
	}

	if !response.Success {
		return "", "", fmt.Errorf("API 응답 실패")
	}

	return response.Hymn.Title, response.Hymn.Lyrics, nil
}

// ReplaceHymnLyrics 찬송가 가사 플레이스홀더를 실제 가사로 교체
func ReplaceHymnLyrics(content string) string {
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
				// API 실패 시 원본 유지
				continue
			}

			// 정확한 제목으로 교체
			correctTitle := fmt.Sprintf("<p><strong>찬송가 %d장 - %s</strong></p>", hymnNumber, apiTitle)
			content = strings.ReplaceAll(content, match[0], correctTitle)
		}
	}

	// 2단계: 가사 플레이스홀더 교체
	// 패턴: > **찬송가 XXX장 - 제목**
	// > (가사는 자동으로 추가됩니다)
	pattern := regexp.MustCompile(`>\s*\*\*찬송가\s+(\d+)장\s*-\s*([^*]+)\*\*\s*>\s*\(가사는 자동으로 추가됩니다\)`)

	// 모든 매치 찾기
	matches := pattern.FindAllStringSubmatch(content, -1)

	for _, match := range matches {
		if len(match) > 2 {
			hymnNumberStr := match[1]
			// aiTitle := strings.TrimSpace(match[2]) // AI가 제안한 제목 (사용하지 않음)

			var hymnNumber int
			fmt.Sscanf(hymnNumberStr, "%d", &hymnNumber)

			// API에서 찬송가 정보 가져오기
			apiTitle, lyrics, err := FetchHymnLyrics(hymnNumber)
			if err != nil {
				// API 실패 시 원본 유지
				continue
			}

			// 가사를 blockquote 형식으로 변환
			lyricsLines := strings.Split(lyrics, "\n")
			formattedLyrics := fmt.Sprintf("> **찬송가 %d장 - %s**\n", hymnNumber, apiTitle)
			for _, line := range lyricsLines {
				if strings.TrimSpace(line) != "" {
					formattedLyrics += "> " + line + "\n"
				} else {
					// 빈 줄도 포함 (절 구분을 위해)
					formattedLyrics += ">\n"
				}
			}

			// 교체
			content = strings.ReplaceAll(content, match[0], strings.TrimSpace(formattedLyrics))
		}
	}

	// 추가 패턴: AI가 직접 가사를 작성한 경우 감지 및 경고
	// > **찬송가 XXX장 - 제목**
	// > 1절: ... 형식 감지
	wrongPattern := regexp.MustCompile(`>\s*\*\*찬송가\s+(\d+)장\s*-\s*([^*]+)\*\*\s*>\s*\d+절:`)
	wrongMatches := wrongPattern.FindAllStringSubmatch(content, -1)

	for _, match := range wrongMatches {
		if len(match) > 1 {
			hymnNumberStr := match[1]
			var hymnNumber int
			fmt.Sscanf(hymnNumberStr, "%d", &hymnNumber)

			// API에서 정확한 가사 가져오기
			apiTitle, lyrics, err := FetchHymnLyrics(hymnNumber)
			if err != nil {
				continue
			}

			// AI가 작성한 잘못된 가사 부분 찾기 (다음 섹션까지)
			// 간단히 처리: 다음 ## 또는 > **찬송가 까지
			startIdx := strings.Index(content, match[0])
			if startIdx == -1 {
				continue
			}

			// 다음 섹션 찾기
			remainContent := content[startIdx:]
			endPatterns := []string{"\n## ", "\n> **찬송가"}
			endIdx := len(remainContent)

			for _, endPat := range endPatterns {
				idx := strings.Index(remainContent[len(match[0]):], endPat)
				if idx != -1 && idx < endIdx {
					endIdx = idx + len(match[0])
				}
			}

			wrongSection := content[startIdx : startIdx+endIdx]

			// 가사를 blockquote 형식으로 변환
			lyricsLines := strings.Split(lyrics, "\n")
			formattedLyrics := fmt.Sprintf("> **찬송가 %d장 - %s**\n", hymnNumber, apiTitle)
			for _, line := range lyricsLines {
				if strings.TrimSpace(line) != "" {
					formattedLyrics += "> " + line + "\n"
				} else {
					// 빈 줄도 포함 (절 구분을 위해)
					formattedLyrics += ">\n"
				}
			}

			// 교체
			content = strings.ReplaceAll(content, wrongSection, strings.TrimSpace(formattedLyrics)+"\n")
		}
	}

	return content
}
