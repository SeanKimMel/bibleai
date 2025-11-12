package youtube

import (
	"fmt"
	"io"
	"math/rand"
	"net/http"
	"net/url"
	"regexp"
	"strings"
	"time"
)

// SearchVideoID YouTube에서 비디오 ID 검색 (다양성 개선)
func SearchVideoID(query string) (string, error) {
	// 검색어 변형 생성
	searchQueries := generateSearchVariations(query)

	// 랜덤하게 검색어 선택
	rand.Seed(time.Now().UnixNano())
	selectedQuery := searchQueries[rand.Intn(len(searchQueries))]

	// URL 인코딩
	encodedQuery := url.QueryEscape(selectedQuery)
	searchURL := fmt.Sprintf("https://www.youtube.com/results?search_query=%s", encodedQuery)

	// HTTP 클라이언트 설정
	client := &http.Client{
		Timeout: 10 * time.Second,
	}

	// HTTP 요청 생성
	req, err := http.NewRequest("GET", searchURL, nil)
	if err != nil {
		return "", fmt.Errorf("요청 생성 실패: %w", err)
	}

	// User-Agent 헤더 추가 (필수)
	req.Header.Set("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36")

	// 검색 결과 가져오기
	resp, err := client.Do(req)
	if err != nil {
		return "", fmt.Errorf("검색 실패: %w", err)
	}
	defer resp.Body.Close()

	// HTML 읽기
	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return "", fmt.Errorf("응답 읽기 실패: %w", err)
	}

	html := string(body)

	// 여러 패턴으로 비디오 ID 추출 시도 (상위 5개 수집)
	patterns := []string{
		`"videoId":"([a-zA-Z0-9_-]{11})"`,
		`/watch\?v=([a-zA-Z0-9_-]{11})`,
		`watch\?v=([a-zA-Z0-9_-]{11})`,
	}

	var videoIDs []string
	seenIDs := make(map[string]bool)

	for _, pattern := range patterns {
		re := regexp.MustCompile(pattern)
		matches := re.FindAllStringSubmatch(html, -1)
		for _, match := range matches {
			if len(match) > 1 {
				videoID := match[1]
				if !seenIDs[videoID] {
					videoIDs = append(videoIDs, videoID)
					seenIDs[videoID] = true
					if len(videoIDs) >= 5 {
						break
					}
				}
			}
		}
		if len(videoIDs) >= 5 {
			break
		}
	}

	if len(videoIDs) == 0 {
		return "", fmt.Errorf("비디오 ID를 찾을 수 없습니다")
	}

	// 상위 5개 중에서 랜덤 선택 (첫 번째는 제외하고 2-5번째 우선)
	if len(videoIDs) > 1 {
		// 80% 확률로 2-5번째 선택, 20% 확률로 첫 번째 선택
		if rand.Float32() < 0.8 {
			return videoIDs[1+rand.Intn(len(videoIDs)-1)], nil
		}
	}

	return videoIDs[0], nil
}

// generateSearchVariations 검색어 변형 생성
func generateSearchVariations(query string) []string {
	variations := []string{query}

	// 찬송가 번호 추출
	hymnPattern := regexp.MustCompile(`찬송가\s*(\d+)장`)
	if matches := hymnPattern.FindStringSubmatch(query); len(matches) > 1 {
		hymnNumber := matches[1]

		// 다양한 검색어 변형 추가
		variations = append(variations,
			fmt.Sprintf("새찬송가 %s장", hymnNumber),
			fmt.Sprintf("찬송가 %s장 CCM", hymnNumber),
			fmt.Sprintf("찬송가 %s장 연주", hymnNumber),
			fmt.Sprintf("찬송가 %s장 피아노", hymnNumber),
			fmt.Sprintf("hymn %s korean", hymnNumber),
			fmt.Sprintf("찬송가 %s장 은혜로운", hymnNumber),
			fmt.Sprintf("찬송가 %s장 새벽기도", hymnNumber),
		)
	}

	return variations
}

// GetEmbedCode YouTube 임베드 코드 생성
func GetEmbedCode(videoID string) string {
	return fmt.Sprintf(`<div style="text-align: center; margin: 2rem 0;">
  <iframe width="560" height="315" src="https://www.youtube.com/embed/%s"
          title="YouTube video player" frameborder="0"
          allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share"
          allowfullscreen></iframe>
  <p><a href="https://www.youtube.com/watch?v=%s" target="_blank">유튜브에서 보기</a></p>
</div>`, videoID, videoID)
}

// ReplaceYouTubeSearchTags YOUTUBE_SEARCH 태그를 실제 임베드로 교체
func ReplaceYouTubeSearchTags(content string) string {
	// YOUTUBE_SEARCH: 찾기 패턴
	pattern := regexp.MustCompile(`<p>YOUTUBE_SEARCH:\s*([^<]+)</p>`)

	// 모든 매치 찾기
	matches := pattern.FindAllStringSubmatch(content, -1)

	for _, match := range matches {
		if len(match) > 1 {
			searchQuery := strings.TrimSpace(match[1])

			// YouTube 검색
			videoID, err := SearchVideoID(searchQuery)
			if err != nil {
				// 검색 실패 시 기본 메시지로 교체
				content = strings.ReplaceAll(content, match[0],
					fmt.Sprintf(`<p style="color: #999;">YouTube 검색 실패: %s</p>`, searchQuery))
				continue
			}

			// 임베드 코드로 교체
			embedCode := GetEmbedCode(videoID)
			content = strings.ReplaceAll(content, match[0], embedCode)
		}
	}

	return content
}
