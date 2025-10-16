package handlers

import (
	"database/sql"
	"fmt"
	"net/http"
	"strconv"
	"strings"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/lib/pq"
)

// Prayer 기도문 구조체
type Prayer struct {
	ID        int       `json:"id" db:"id"`
	Title     string    `json:"title" db:"title"`
	Content   string    `json:"content" db:"content"`
	Tags      []Tag     `json:"tags,omitempty"`
	CreatedAt time.Time `json:"created_at" db:"created_at"`
	UpdatedAt time.Time `json:"updated_at" db:"updated_at"`
}

// Tag 태그 구조체
type Tag struct {
	ID          int    `json:"id" db:"id"`
	Name        string `json:"name" db:"name"`
	Description string `json:"description" db:"description"`
}

// CreatePrayerRequest 기도문 생성 요청
type CreatePrayerRequest struct {
	Title   string `json:"title" binding:"required"`
	Content string `json:"content" binding:"required"`
	TagIDs  []int  `json:"tag_ids,omitempty"`
}

// GetPrayersByTagsRequest 태그별 기도문 조회 요청
type GetPrayersByTagsRequest struct {
	TagIDs []int `json:"tag_ids" binding:"required"`
}

// db 변수와 SetDB 함수는 pages.go에서 정의됨

// CreatePrayer 기도문 생성 API
// POST /api/prayers
func CreatePrayer(c *gin.Context) {
	var req CreatePrayerRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error":   "Invalid request format",
			"message": err.Error(),
		})
		return
	}

	// 트랜잭션 시작
	tx, err := db.Begin()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error":   "Database transaction failed",
			"message": err.Error(),
		})
		return
	}
	defer tx.Rollback()

	// 기도문 삽입
	var prayerID int
	err = tx.QueryRow(
		"INSERT INTO prayers (title, content, created_at, updated_at) VALUES ($1, $2, NOW(), NOW()) RETURNING id",
		req.Title, req.Content,
	).Scan(&prayerID)

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error":   "Failed to create prayer",
			"message": err.Error(),
		})
		return
	}

	// 태그 연결 (있는 경우)
	if len(req.TagIDs) > 0 {
		for _, tagID := range req.TagIDs {
			_, err = tx.Exec(
				"INSERT INTO prayer_tags (prayer_id, tag_id) VALUES ($1, $2)",
				prayerID, tagID,
			)
			if err != nil {
				c.JSON(http.StatusInternalServerError, gin.H{
					"error":   "Failed to link tags",
					"message": err.Error(),
				})
				return
			}
		}
	}

	// 커밋
	if err = tx.Commit(); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error":   "Failed to commit transaction",
			"message": err.Error(),
		})
		return
	}

	// 생성된 기도문 조회해서 반환
	prayer, err := getPrayerByID(prayerID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error":   "Prayer created but failed to retrieve",
			"message": err.Error(),
		})
		return
	}

	c.JSON(http.StatusCreated, gin.H{
		"message": "Prayer created successfully",
		"prayer":  prayer,
	})
}

// GetPrayersByTags 태그별 기도문 조회 API
// GET /api/prayers/by-tags?tag_ids=1,2
func GetPrayersByTags(c *gin.Context) {
	tagIDsParam := c.Query("tag_ids")
	if tagIDsParam == "" {
		c.JSON(http.StatusBadRequest, gin.H{
			"error":   "Missing tag_ids parameter",
			"message": "Please provide tag_ids as comma-separated values",
		})
		return
	}

	// 태그 ID 파싱
	tagIDStrs := strings.Split(tagIDsParam, ",")
	var tagIDs []int
	for _, idStr := range tagIDStrs {
		id, err := strconv.Atoi(strings.TrimSpace(idStr))
		if err != nil {
			c.JSON(http.StatusBadRequest, gin.H{
				"error":   "Invalid tag_ids format",
				"message": "tag_ids must be comma-separated integers",
			})
			return
		}
		tagIDs = append(tagIDs, id)
	}

	// 최대 2개 태그만 허용
	if len(tagIDs) > 2 {
		c.JSON(http.StatusBadRequest, gin.H{
			"error":   "Too many tags",
			"message": "Maximum 2 tags are allowed",
		})
		return
	}

	// 태그별 기도문 조회 (매칭되는 태그 수가 많은 순으로 정렬)
	placeholders := make([]string, len(tagIDs))
	args := make([]interface{}, len(tagIDs))
	for i, tagID := range tagIDs {
		placeholders[i] = fmt.Sprintf("$%d", i+1)
		args[i] = tagID
	}
	
	query := fmt.Sprintf(`
		SELECT DISTINCT p.id, p.title, p.content, p.created_at, p.updated_at,
		       COUNT(pt.tag_id) as match_count
		FROM prayers p
		JOIN prayer_tags pt ON p.id = pt.prayer_id
		WHERE pt.tag_id IN (%s)
		GROUP BY p.id, p.title, p.content, p.created_at, p.updated_at
		ORDER BY match_count DESC, p.created_at DESC
	`, strings.Join(placeholders, ","))

	rows, err := db.Query(query, args...)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error":   "Database query failed",
			"message": err.Error(),
		})
		return
	}
	defer rows.Close()

	var prayers []Prayer
	for rows.Next() {
		var prayer Prayer
		var matchCount int
		err := rows.Scan(
			&prayer.ID, &prayer.Title, &prayer.Content,
			&prayer.CreatedAt, &prayer.UpdatedAt, &matchCount,
		)
		if err != nil {
			continue
		}

		// 기도문의 태그들 조회
		tags, _ := getTagsForPrayer(prayer.ID)
		prayer.Tags = tags

		prayers = append(prayers, prayer)
	}

	c.JSON(http.StatusOK, gin.H{
		"prayers": prayers,
		"total":   len(prayers),
		"tag_ids": tagIDs,
	})
}

// SearchPrayers 키워드로 기도문 검색 API
// GET /api/prayers/search?q=keyword
func SearchPrayers(c *gin.Context) {
	keyword := c.Query("q")
	if keyword == "" {
		c.JSON(http.StatusBadRequest, gin.H{
			"error":   "Missing search keyword",
			"message": "Please provide a search keyword with 'q' parameter",
		})
		return
	}

	var prayers []Prayer
	var query string
	var rows *sql.Rows
	var err error

	// 1. 먼저 keywords 테이블에서 해당 키워드가 있는지 확인
	var prayerIDs pq.Int64Array
	err = db.QueryRow(`
		SELECT prayer_ids FROM keywords WHERE name = $1
	`, keyword).Scan(&prayerIDs)

	if err == nil && len(prayerIDs) > 0 {
		// Convert int64 to int
		prayerIDsInt := make([]int, len(prayerIDs))
		for i, n := range prayerIDs {
			prayerIDsInt[i] = int(n)
		}

		// 키워드 배열 기반 조회 (정확한 매칭)
		query = `
			SELECT id, title, content, created_at, updated_at
			FROM prayers
			WHERE id = ANY($1)
			ORDER BY created_at DESC
		`
		rows, err = db.Query(query, pq.Array(prayerIDsInt))
	} else {
		// ILIKE 기반 자유 검색 (검색창용)
		query = `
			SELECT DISTINCT p.id, p.title, p.content, p.created_at, p.updated_at
			FROM prayers p
			LEFT JOIN prayer_tags pt ON p.id = pt.prayer_id
			LEFT JOIN tags t ON pt.tag_id = t.id
			WHERE p.title ILIKE $1 OR p.content ILIKE $1 OR t.name ILIKE $1
			ORDER BY p.created_at DESC
		`
		searchTerm := "%" + keyword + "%"
		rows, err = db.Query(query, searchTerm)
	}

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error":   "Database query failed",
			"message": err.Error(),
		})
		return
	}
	defer rows.Close()

	for rows.Next() {
		var prayer Prayer
		err := rows.Scan(
			&prayer.ID, &prayer.Title, &prayer.Content,
			&prayer.CreatedAt, &prayer.UpdatedAt,
		)
		if err != nil {
			continue
		}

		// 기도문의 태그들 조회
		tags, _ := getTagsForPrayer(prayer.ID)
		prayer.Tags = tags

		prayers = append(prayers, prayer)
	}

	c.JSON(http.StatusOK, gin.H{
		"prayers": prayers,
		"total":   len(prayers),
		"query":   keyword,
		"success": true,
	})
}

// GetAllPrayers 모든 기도문 조회 API
// GET /api/prayers
func GetAllPrayers(c *gin.Context) {
	query := `
		SELECT id, title, content, created_at, updated_at
		FROM prayers
		ORDER BY created_at DESC
	`

	rows, err := db.Query(query)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error":   "Database query failed",
			"message": err.Error(),
		})
		return
	}
	defer rows.Close()

	var prayers []Prayer
	for rows.Next() {
		var prayer Prayer
		err := rows.Scan(
			&prayer.ID, &prayer.Title, &prayer.Content,
			&prayer.CreatedAt, &prayer.UpdatedAt,
		)
		if err != nil {
			continue
		}

		// 기도문의 태그들 조회
		tags, _ := getTagsForPrayer(prayer.ID)
		prayer.Tags = tags

		prayers = append(prayers, prayer)
	}

	c.JSON(http.StatusOK, gin.H{
		"prayers": prayers,
		"total":   len(prayers),
	})
}

// AddTagsToPrayer 기도문에 태그 추가 API
// POST /api/prayers/:id/tags
func AddTagsToPrayer(c *gin.Context) {
	prayerIDStr := c.Param("id")
	prayerID, err := strconv.Atoi(prayerIDStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error":   "Invalid prayer ID",
			"message": "Prayer ID must be a number",
		})
		return
	}

	var req struct {
		TagIDs []int `json:"tag_ids" binding:"required"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error":   "Invalid request format",
			"message": err.Error(),
		})
		return
	}

	// 기도문 존재 확인
	var exists bool
	err = db.QueryRow("SELECT EXISTS(SELECT 1 FROM prayers WHERE id = $1)", prayerID).Scan(&exists)
	if err != nil || !exists {
		c.JSON(http.StatusNotFound, gin.H{
			"error":   "Prayer not found",
			"message": "The specified prayer does not exist",
		})
		return
	}

	// 태그 추가 (중복 무시)
	for _, tagID := range req.TagIDs {
		_, err = db.Exec(
			"INSERT INTO prayer_tags (prayer_id, tag_id) VALUES ($1, $2) ON CONFLICT DO NOTHING",
			prayerID, tagID,
		)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{
				"error":   "Failed to add tags",
				"message": err.Error(),
			})
			return
		}
	}

	// 업데이트된 기도문 조회
	prayer, err := getPrayerByID(prayerID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error":   "Tags added but failed to retrieve prayer",
			"message": err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "Tags added successfully",
		"prayer":  prayer,
	})
}

// 헬퍼 함수들
func getPrayerByID(id int) (*Prayer, error) {
	var prayer Prayer
	err := db.QueryRow(
		"SELECT id, title, content, created_at, updated_at FROM prayers WHERE id = $1",
		id,
	).Scan(&prayer.ID, &prayer.Title, &prayer.Content, &prayer.CreatedAt, &prayer.UpdatedAt)

	if err != nil {
		return nil, err
	}

	// 태그들 조회
	tags, _ := getTagsForPrayer(id)
	prayer.Tags = tags

	return &prayer, nil
}

func getTagsForPrayer(prayerID int) ([]Tag, error) {
	query := `
		SELECT t.id, t.name, t.description
		FROM tags t
		JOIN prayer_tags pt ON t.id = pt.tag_id
		WHERE pt.prayer_id = $1
		ORDER BY t.name
	`

	rows, err := db.Query(query, prayerID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var tags []Tag
	for rows.Next() {
		var tag Tag
		err := rows.Scan(&tag.ID, &tag.Name, &tag.Description)
		if err != nil {
			continue
		}
		tags = append(tags, tag)
	}

	return tags, nil
}