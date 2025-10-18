package youtube

import (
	"fmt"
	"io"
	"net/http"
	"net/url"
	"regexp"
	"strings"
	"time"
)

// SearchVideoID YouTube에서 비디오 ID 검색
func SearchVideoID(query string) (string, error) {
	// URL 인코딩
	encodedQuery := url.QueryEscape(query)
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

	// 여러 패턴으로 비디오 ID 추출 시도
	patterns := []string{
		`"videoId":"([a-zA-Z0-9_-]{11})"`,
		`/watch\?v=([a-zA-Z0-9_-]{11})`,
		`watch\?v=([a-zA-Z0-9_-]{11})`,
	}

	for _, pattern := range patterns {
		re := regexp.MustCompile(pattern)
		matches := re.FindStringSubmatch(html)
		if len(matches) > 1 {
			videoID := matches[1]
			return videoID, nil
		}
	}

	return "", fmt.Errorf("비디오 ID를 찾을 수 없습니다")
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
