package hymn

import (
	"database/sql"
	"fmt"
	"math/rand"
	"time"
)

// HymnSelector 찬송가 선택기
type HymnSelector struct {
	DB *sql.DB
}

// NewHymnSelector 생성자
func NewHymnSelector(db *sql.DB) *HymnSelector {
	return &HymnSelector{DB: db}
}

// GetRecentlyUsedHymns 최근 30일간 사용된 찬송가 번호 조회
func (h *HymnSelector) GetRecentlyUsedHymns() ([]int, error) {
	query := `
		SELECT DISTINCT hymn_number
		FROM blog_posts
		WHERE hymn_number IS NOT NULL
		AND created_at > NOW() - INTERVAL '30 days'
		ORDER BY hymn_number
	`

	rows, err := h.DB.Query(query)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var hymns []int
	for rows.Next() {
		var hymn int
		if err := rows.Scan(&hymn); err != nil {
			continue
		}
		hymns = append(hymns, hymn)
	}

	return hymns, nil
}

// GetHymnUsageCount 특정 찬송가의 사용 횟수 조회
func (h *HymnSelector) GetHymnUsageCount(hymnNumber int) (int, error) {
	var count int
	query := `
		SELECT COUNT(*)
		FROM blog_posts
		WHERE hymn_number = $1
		AND created_at > NOW() - INTERVAL '30 days'
	`

	err := h.DB.QueryRow(query, hymnNumber).Scan(&count)
	return count, err
}

// SuggestHymnByKeyword 키워드별 찬송가 추천 (사용 빈도 고려)
func (h *HymnSelector) SuggestHymnByKeyword(keyword string) (int, error) {
	// 키워드별 찬송가 풀
	hymnPools := map[string][]int{
		"사랑":   {304, 364, 412, 220, 93, 279, 292, 404, 218, 199},
		"기도":   {305, 492, 363, 411, 365, 361, 362, 364, 487, 490},
		"은혜":   {94, 310, 413, 200, 438, 287, 288, 406, 407, 410},
		"찬양":   {31, 32, 33, 34, 67, 35, 36, 37, 38, 39},
		"십자가": {136, 147, 144, 151, 149, 135, 138, 139, 140, 141},
		"감사":   {301, 309, 428, 429, 588, 589, 590, 592, 593, 594},
		"소망":   {488, 491, 370, 495, 384, 380, 487, 498, 499, 500},
		"믿음":   {338, 336, 357, 330, 342, 343, 344, 345, 346, 347},
		"평안":   {413, 371, 377, 419, 478, 559, 560, 561, 562, 563},
		"구원":   {254, 255, 256, 257, 258, 259, 260, 261, 262, 263},
		"회개":   {268, 269, 270, 271, 272, 273, 274, 275, 276, 277},
		"헌신":   {323, 324, 325, 326, 327, 328, 329, 321, 322, 315},
	}

	// 키워드에 해당하는 찬송가 풀 가져오기
	pool, exists := hymnPools[keyword]
	if !exists {
		// 키워드가 없으면 랜덤 범위에서 선택
		rand.Seed(time.Now().UnixNano())
		return rand.Intn(400) + 100, nil // 100-500 범위
	}

	// 최근 사용된 찬송가 조회
	recentlyUsed, _ := h.GetRecentlyUsedHymns()
	recentMap := make(map[int]bool)
	for _, hymn := range recentlyUsed {
		recentMap[hymn] = true
	}

	// 사용되지 않은 찬송가 우선 선택
	var candidates []int
	for _, hymn := range pool {
		if !recentMap[hymn] {
			candidates = append(candidates, hymn)
		}
	}

	// 모든 찬송가가 최근 사용된 경우, 가장 적게 사용된 것 선택
	if len(candidates) == 0 {
		candidates = pool
	}

	// 랜덤 선택
	rand.Seed(time.Now().UnixNano())
	selected := candidates[rand.Intn(len(candidates))]

	return selected, nil
}

// GetLeastUsedHymns 가장 적게 사용된 찬송가 목록 조회
func (h *HymnSelector) GetLeastUsedHymns(limit int) ([]int, error) {
	query := `
		SELECT h.number
		FROM hymns h
		LEFT JOIN (
			SELECT hymn_number, COUNT(*) as usage_count
			FROM blog_posts
			WHERE hymn_number IS NOT NULL
			GROUP BY hymn_number
		) bp ON h.number = bp.hymn_number
		ORDER BY COALESCE(bp.usage_count, 0) ASC, RANDOM()
		LIMIT $1
	`

	rows, err := h.DB.Query(query, limit)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var hymns []int
	for rows.Next() {
		var hymn int
		if err := rows.Scan(&hymn); err != nil {
			continue
		}
		hymns = append(hymns, hymn)
	}

	return hymns, nil
}

// FormatHymnSuggestion 찬송가 추천 메시지 생성
func (h *HymnSelector) FormatHymnSuggestion(keyword string) string {
	hymn, err := h.SuggestHymnByKeyword(keyword)
	if err != nil {
		return fmt.Sprintf("키워드 '%s'에 대한 추천 찬송가: 일반적인 찬송가 사용", keyword)
	}

	recentlyUsed, _ := h.GetRecentlyUsedHymns()

	return fmt.Sprintf(
		"키워드 '%s' 추천 찬송가: %d장\n최근 사용된 찬송가 (피해주세요): %v",
		keyword, hymn, recentlyUsed,
	)
}