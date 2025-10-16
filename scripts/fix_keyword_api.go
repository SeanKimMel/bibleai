package main

import (
	"fmt"
)

// GetKeywordContentCounts 함수 수정 제안
// 실제 매핑 테이블을 사용하도록 수정

func GetKeywordContentCountsFixed() string {
	return `
// GetKeywordContentCounts - 키워드별 콘텐츠 개수 조회 (수정됨)
func GetKeywordContentCounts(c *gin.Context) {
	keywordName := c.Param("keyword")
	if keywordName == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "키워드명이 필요합니다"})
		return
	}

	if db == nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "데이터베이스 연결이 없습니다"})
		return
	}

	counts := map[string]int{
		"prayers": 0,
		"verses":  0,
		"hymns":   0,
	}

	// 기도문 개수 (keywords 시스템 사용)
	var prayerCount int
	err := db.QueryRow(` + "`" + `
		SELECT COUNT(DISTINCT p.id)
		FROM prayers p
		JOIN prayer_keywords pk ON p.id = pk.prayer_id
		JOIN keywords k ON pk.keyword_id = k.id
		WHERE k.name = $1
	` + "`" + `, keywordName).Scan(&prayerCount)
	if err == nil {
		counts["prayers"] = prayerCount
	}

	// 성경구절 개수 (실제 매핑 사용)
	var verseCount int
	err = db.QueryRow(` + "`" + `
		SELECT COUNT(DISTINCT bv.id)
		FROM bible_verses bv
		JOIN bible_keywords bk ON bv.id = bk.verse_id
		JOIN keywords k ON bk.keyword_id = k.id
		WHERE k.name = $1
	` + "`" + `, keywordName).Scan(&verseCount)
	if err == nil {
		counts["verses"] = verseCount
	}

	// 찬송가 개수 (실제 매핑 사용)
	var hymnCount int
	err = db.QueryRow(` + "`" + `
		SELECT COUNT(DISTINCT h.id)
		FROM hymns h
		JOIN hymn_keywords hk ON h.id = hk.hymn_id
		JOIN keywords k ON hk.keyword_id = k.id
		WHERE k.name = $1
	` + "`" + `, keywordName).Scan(&hymnCount)
	if err == nil {
		counts["hymns"] = hymnCount
	}

	c.JSON(http.StatusOK, gin.H{
		"keyword": keywordName,
		"counts":  counts,
		"total":   counts["prayers"] + counts["verses"] + counts["hymns"],
	})
}
`
}

func GetHymnsByKeyword() string {
	return `
// GetHymnsByKeyword - 키워드로 찬송가 검색 (새로운 API)
func (h *HymnHandlers) GetHymnsByKeyword(c *gin.Context) {
	keyword := strings.TrimSpace(c.Param("keyword"))
	limitStr := c.DefaultQuery("limit", "20")

	if keyword == "" {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "키워드를 입력해주세요",
		})
		return
	}

	limit, err := strconv.Atoi(limitStr)
	if err != nil || limit <= 0 || limit > 50 {
		limit = 20
	}

	var hymns []Hymn
	query := ` + "`" + `
		SELECT DISTINCT h.id, h.number, h.title,
			   COALESCE(h.lyrics, '') as lyrics,
			   COALESCE(h.theme, '') as theme,
			   COALESCE(h.composer, '') as composer,
			   COALESCE(h.author, '') as author,
			   COALESCE(h.tempo, '') as tempo,
			   COALESCE(h.key_signature, '') as key_signature,
			   COALESCE(h.bible_reference, '') as bible_reference,
			   COALESCE(h.external_link, '') as external_link
		FROM hymns h
		JOIN hymn_keywords hk ON h.id = hk.hymn_id
		JOIN keywords k ON hk.keyword_id = k.id
		WHERE k.name = $1
		ORDER BY h.number ASC
		LIMIT $2` + "`" + `

	rows, err := h.DB.Query(query, keyword, limit)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "데이터베이스 조회 중 오류가 발생했습니다",
		})
		return
	}
	defer rows.Close()

	for rows.Next() {
		var hymn Hymn
		err := rows.Scan(
			&hymn.ID, &hymn.Number, &hymn.Title, &hymn.Lyrics, &hymn.Theme,
			&hymn.Composer, &hymn.Author, &hymn.Tempo, &hymn.KeySignature,
			&hymn.BibleReference, &hymn.ExternalLink,
		)
		if err != nil {
			continue
		}
		hymns = append(hymns, hymn)
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"total":   len(hymns),
		"keyword": keyword,
		"hymns":   hymns,
	})
}
`
}

func main() {
	fmt.Println("=== API 수정 제안 ===")
	fmt.Println("\n1. keywords.go의 GetKeywordContentCounts 함수를 실제 매핑 테이블 사용하도록 수정")
	fmt.Println("\n2. hymns.go에 GetHymnsByKeyword 함수 추가")
	fmt.Println("\n3. main.go에 라우트 추가:")
	fmt.Println("   r.GET(\"/api/hymns/keyword/:keyword\", hymnHandlers.GetHymnsByKeyword)")

	fmt.Println("\n=== 현재 문제점 ===")
	fmt.Println("- 키워드 시스템과 찬송가 theme 시스템이 분리되어 있음")
	fmt.Println("- GetKeywordContentCounts가 더미 데이터 반환")
	fmt.Println("- 키워드로 찬송가를 검색하는 API 없음")

	fmt.Println("\n=== 해결 방안 ===")
	fmt.Println("1. 기존 theme 시스템 유지 (호환성)")
	fmt.Println("2. 키워드 시스템 병행 사용 (확장성)")
	fmt.Println("3. 실제 매핑 테이블 활용하도록 API 수정")
}