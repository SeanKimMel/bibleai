package handlers

import (
	"net/http"
	"strings"

	"github.com/gin-gonic/gin"
)

// Keyword 구조체
type Keyword struct {
	ID           int    `json:"id" db:"id"`
	Name         string `json:"name" db:"name"`
	Category     string `json:"category" db:"category"`
	UsageCount   int    `json:"usage_count" db:"usage_count"`
	PrayerCount  int    `json:"prayer_count" db:"prayer_count"`
	BibleCount   int    `json:"bible_count" db:"bible_count"`
	HymnCount    int    `json:"hymn_count" db:"hymn_count"`
	Icon         string `json:"icon" db:"icon"`
	Description  string `json:"description" db:"description"`
	IsFeatured   bool   `json:"is_featured" db:"is_featured"`
	CreatedAt    string `json:"created_at" db:"created_at"`
	UpdatedAt    string `json:"updated_at" db:"updated_at"`
}

// 키워드 테이블 생성
func CreateKeywordTables(c *gin.Context) {
	if db == nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "데이터베이스 연결이 없습니다"})
		return
	}

	// SQL 스크립트 실행
	sqlScript := `
-- 키워드 테이블 생성
CREATE TABLE IF NOT EXISTS keywords (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    category VARCHAR(20) DEFAULT 'general',
    usage_count INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 키워드 매핑 테이블들 생성
CREATE TABLE IF NOT EXISTS prayer_keywords (
    prayer_id INTEGER REFERENCES prayers(id) ON DELETE CASCADE,
    keyword_id INTEGER REFERENCES keywords(id) ON DELETE CASCADE,
    PRIMARY KEY (prayer_id, keyword_id)
);

CREATE TABLE IF NOT EXISTS bible_keywords (
    verse_id INTEGER REFERENCES bible_verses(id) ON DELETE CASCADE,
    keyword_id INTEGER REFERENCES keywords(id) ON DELETE CASCADE,
    PRIMARY KEY (verse_id, keyword_id)
);

CREATE TABLE IF NOT EXISTS hymn_keywords (
    hymn_id INTEGER REFERENCES hymns(id) ON DELETE CASCADE,
    keyword_id INTEGER REFERENCES keywords(id) ON DELETE CASCADE,
    PRIMARY KEY (hymn_id, keyword_id)
);

-- 인덱스 생성
CREATE INDEX IF NOT EXISTS idx_keywords_name ON keywords(name);
CREATE INDEX IF NOT EXISTS idx_keywords_usage_count ON keywords(usage_count DESC);
CREATE INDEX IF NOT EXISTS idx_prayer_keywords_keyword ON prayer_keywords(keyword_id);
CREATE INDEX IF NOT EXISTS idx_bible_keywords_keyword ON bible_keywords(keyword_id);
CREATE INDEX IF NOT EXISTS idx_hymn_keywords_keyword ON hymn_keywords(keyword_id);
`

	// SQL 문들을 분리하여 실행
	statements := strings.Split(sqlScript, ";")
	for _, stmt := range statements {
		stmt = strings.TrimSpace(stmt)
		if stmt == "" {
			continue
		}

		_, err := db.Exec(stmt)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{
				"error": "테이블 생성 실패",
				"details": err.Error(),
			})
			return
		}
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "키워드 테이블들이 성공적으로 생성되었습니다",
		"tables": []string{"keywords", "prayer_keywords", "bible_keywords", "hymn_keywords"},
	})
}

// 초기 키워드 데이터 삽입
func PopulateInitialKeywords(c *gin.Context) {
	if db == nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "데이터베이스 연결이 없습니다"})
		return
	}

	// 기본 키워드들 (기존 하드코딩된 키워드들 + 추가)
	keywords := []map[string]string{
		{"name": "사랑", "category": "감정"},
		{"name": "평안", "category": "감정"},
		{"name": "믿음", "category": "신앙"},
		{"name": "소망", "category": "신앙"},
		{"name": "감사", "category": "감정"},
		{"name": "위로", "category": "감정"},
		{"name": "용기", "category": "성품"},
		{"name": "지혜", "category": "성품"},
		{"name": "기쁨", "category": "감정"},
		{"name": "용서", "category": "관계"},
		{"name": "치유", "category": "기도"},
		{"name": "구원", "category": "신앙"},
		{"name": "회개", "category": "신앙"},
		{"name": "은혜", "category": "신앙"},
		{"name": "희망", "category": "감정"},
		{"name": "순종", "category": "성품"},
		{"name": "겸손", "category": "성품"},
		{"name": "인내", "category": "성품"},
		{"name": "의", "category": "성품"},
		{"name": "진리", "category": "신앙"},
		{"name": "성령", "category": "신앙"},
		{"name": "축복", "category": "기도"},
		{"name": "영생", "category": "신앙"},
		{"name": "십자가", "category": "신앙"},
		{"name": "가족", "category": "관계"},
		{"name": "직장", "category": "일상"},
		{"name": "건강", "category": "일상"},
		{"name": "평강", "category": "감정"},
	}

	insertCount := 0
	for _, keyword := range keywords {
		_, err := db.Exec(`
			INSERT INTO keywords (name, category)
			VALUES ($1, $2)
			ON CONFLICT (name) DO NOTHING
		`, keyword["name"], keyword["category"])

		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{
				"error": "키워드 삽입 실패",
				"details": err.Error(),
			})
			return
		}
		insertCount++
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "초기 키워드가 성공적으로 삽입되었습니다",
		"inserted_count": len(keywords),
	})
}

// GetFeaturedKeywords - 메인 페이지용 추천 키워드들 조회
func GetFeaturedKeywords(c *gin.Context) {
	if db == nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "데이터베이스 연결이 없습니다"})
		return
	}

	query := `
		SELECT id, name, category, usage_count, prayer_count, bible_count, hymn_count,
			   COALESCE(icon, '🔖') as icon,
			   COALESCE(description, '') as description,
			   is_featured, created_at, updated_at
		FROM keywords
		WHERE is_featured = TRUE
		ORDER BY name`

	rows, err := db.Query(query)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "데이터베이스 조회 중 오류가 발생했습니다",
		})
		return
	}
	defer rows.Close()

	var keywords []Keyword
	for rows.Next() {
		var keyword Keyword
		err := rows.Scan(
			&keyword.ID, &keyword.Name, &keyword.Category, &keyword.UsageCount,
			&keyword.PrayerCount, &keyword.BibleCount, &keyword.HymnCount,
			&keyword.Icon, &keyword.Description, &keyword.IsFeatured,
			&keyword.CreatedAt, &keyword.UpdatedAt,
		)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{
				"error": "데이터 파싱 중 오류가 발생했습니다",
			})
			return
		}
		keywords = append(keywords, keyword)
	}

	// 캐시 방지 헤더 추가
	c.Header("Cache-Control", "no-cache, no-store, must-revalidate")
	c.Header("Pragma", "no-cache")
	c.Header("Expires", "0")

	c.JSON(http.StatusOK, gin.H{
		"success":  true,
		"keywords": keywords,
		"total":    len(keywords),
	})
}

// 모든 키워드 조회 (사용량 순)
func GetAllKeywords(c *gin.Context) {
	if db == nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "데이터베이스 연결이 없습니다"})
		return
	}

	query := `
		SELECT id, name, category, usage_count, prayer_count, bible_count, hymn_count,
			   COALESCE(icon, '🔖') as icon,
			   COALESCE(description, '') as description,
			   is_featured, created_at, updated_at
		FROM keywords
		ORDER BY is_featured DESC, usage_count DESC, name`

	rows, err := db.Query(query)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "데이터베이스 조회 중 오류가 발생했습니다",
		})
		return
	}
	defer rows.Close()

	var keywords []Keyword
	for rows.Next() {
		var keyword Keyword
		err := rows.Scan(
			&keyword.ID, &keyword.Name, &keyword.Category, &keyword.UsageCount,
			&keyword.PrayerCount, &keyword.BibleCount, &keyword.HymnCount,
			&keyword.Icon, &keyword.Description, &keyword.IsFeatured,
			&keyword.CreatedAt, &keyword.UpdatedAt,
		)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{
				"error": "데이터 파싱 중 오류가 발생했습니다",
			})
			return
		}
		keywords = append(keywords, keyword)
	}

	c.JSON(http.StatusOK, gin.H{
		"success":  true,
		"keywords": keywords,
		"total":    len(keywords),
	})
}

// 키워드별 콘텐츠 개수 조회
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

	// 일단 더미 데이터로 응답 (실제 매핑 데이터가 없으므로)
	counts := map[string]int{
		"prayers": 0,
		"verses":  0,
		"hymns":   0,
	}

	// 기도문 개수 (tags 테이블과 연결되어 있는 기존 시스템 사용)
	var prayerCount int
	err := db.QueryRow(`
		SELECT COUNT(DISTINCT p.id)
		FROM prayers p
		JOIN prayer_tags pt ON p.id = pt.prayer_id
		JOIN tags t ON pt.tag_id = t.id
		WHERE t.name = $1
	`, keywordName).Scan(&prayerCount)
	if err == nil {
		counts["prayers"] = prayerCount
	}

	// 성경구절 개수 (더미)
	counts["verses"] = 3 + len(keywordName)%5

	// 찬송가 개수 (더미)
	counts["hymns"] = 2 + len(keywordName)%4

	c.JSON(http.StatusOK, gin.H{
		"keyword": keywordName,
		"counts":  counts,
		"total":   counts["prayers"] + counts["verses"] + counts["hymns"],
	})
}

// UpdateKeywordCounts - 키워드 카운트 업데이트 (관리자용)
func UpdateKeywordCounts(c *gin.Context) {
	if db == nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "데이터베이스 연결이 없습니다"})
		return
	}

	_, err := db.Exec("SELECT update_keyword_counts()")
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "키워드 카운트 업데이트 중 오류가 발생했습니다",
			"details": err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": "키워드 카운트가 성공적으로 업데이트되었습니다",
	})
}