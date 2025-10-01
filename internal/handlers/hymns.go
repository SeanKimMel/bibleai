package handlers

import (
	"database/sql"
	"fmt"
	"net/http"
	"strconv"
	"strings"

	"github.com/gin-gonic/gin"
)

// Hymn 구조체
type Hymn struct {
	ID             int    `json:"id" db:"id"`
	Number         int    `json:"number" db:"number"`
	NewHymnNumber  *int   `json:"new_hymn_number" db:"new_hymn_number"`
	Title          string `json:"title" db:"title"`
	Lyrics         string `json:"lyrics" db:"lyrics"`
	Theme          string `json:"theme" db:"theme"`
	Composer       string `json:"composer" db:"composer"`
	Author         string `json:"author" db:"author"`
	Tempo          string `json:"tempo" db:"tempo"`
	KeySignature   string `json:"key_signature" db:"key_signature"`
	BibleReference string `json:"bible_reference" db:"bible_reference"`
	ExternalLink   string `json:"external_link" db:"external_link"`
}

// HymnHandlers 구조체
type HymnHandlers struct {
	DB *sql.DB
}

// NewHymnHandlers 생성자
func NewHymnHandlers(db *sql.DB) *HymnHandlers {
	return &HymnHandlers{DB: db}
}

// SearchHymns 찬송가 검색 API
func (h *HymnHandlers) SearchHymns(c *gin.Context) {
	query := strings.TrimSpace(c.Query("q"))
	theme := strings.TrimSpace(c.Query("theme"))
	numberStr := strings.TrimSpace(c.Query("number"))
	limitStr := c.DefaultQuery("limit", "50")

	// limit 파라미터 파싱
	limit, err := strconv.Atoi(limitStr)
	if err != nil || limit <= 0 || limit > 1000 {
		limit = 50
	}

	var hymns []Hymn
	var queryBuilder strings.Builder
	var args []interface{}
	argIndex := 1

	// 기본 쿼리
	queryBuilder.WriteString(`
		SELECT id, number, new_hymn_number, title, lyrics, theme,
			   COALESCE(composer, '') as composer,
			   COALESCE(author, '') as author,
			   COALESCE(tempo, '') as tempo,
			   COALESCE(key_signature, '') as key_signature,
			   COALESCE(bible_reference, '') as bible_reference,
			   COALESCE(external_link, '') as external_link
		FROM hymns WHERE 1=1`)

	// 번호로 검색 (신찬송가 번호 우선, 없으면 기존 번호)
	if numberStr != "" {
		if number, err := strconv.Atoi(numberStr); err == nil {
			queryBuilder.WriteString(" AND (new_hymn_number = $")
			queryBuilder.WriteString(strconv.Itoa(argIndex))
			queryBuilder.WriteString(" OR (new_hymn_number IS NULL AND number = $")
			queryBuilder.WriteString(strconv.Itoa(argIndex))
			queryBuilder.WriteString("))")
			args = append(args, number)
			argIndex++
		}
	}

	// 주제로 검색
	if theme != "" {
		queryBuilder.WriteString(" AND LOWER(theme) LIKE LOWER($")
		queryBuilder.WriteString(strconv.Itoa(argIndex))
		queryBuilder.WriteString(")")
		args = append(args, "%"+theme+"%")
		argIndex++
	}

	// 텍스트 검색 (제목, 가사) - LIKE만 사용
	if query != "" {
		queryBuilder.WriteString(" AND (")
		queryBuilder.WriteString("LOWER(title) LIKE LOWER($")
		queryBuilder.WriteString(strconv.Itoa(argIndex))
		queryBuilder.WriteString(") OR ")
		queryBuilder.WriteString("LOWER(lyrics) LIKE LOWER($")
		queryBuilder.WriteString(strconv.Itoa(argIndex + 1))
		queryBuilder.WriteString("))")
		args = append(args, "%"+query+"%", "%"+query+"%")
		argIndex += 2
	}

	// 정렬 및 제한
	queryBuilder.WriteString(" ORDER BY number ASC LIMIT $")
	queryBuilder.WriteString(strconv.Itoa(argIndex))
	args = append(args, limit)

	finalQuery := queryBuilder.String()

	rows, err := h.DB.Query(finalQuery, args...)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "데이터베이스 조회 중 오류가 발생했습니다",
			"details": err.Error(),
		})
		return
	}
	defer rows.Close()

	for rows.Next() {
		var hymn Hymn
		err := rows.Scan(
			&hymn.ID, &hymn.Number, &hymn.NewHymnNumber, &hymn.Title, &hymn.Lyrics, &hymn.Theme,
			&hymn.Composer, &hymn.Author, &hymn.Tempo, &hymn.KeySignature, &hymn.BibleReference, &hymn.ExternalLink,
		)
		if err != nil {
			continue
		}
		hymns = append(hymns, hymn)
	}

	// 결과 반환
	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"total":   len(hymns),
		"hymns":   hymns,
		"query":   query,
		"theme":   theme,
		"number":  numberStr,
	})
}

// GetHymnByNumber 특정 번호의 찬송가 조회
func (h *HymnHandlers) GetHymnByNumber(c *gin.Context) {
	numberStr := c.Param("number")
	number, err := strconv.Atoi(numberStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "유효하지 않은 찬송가 번호입니다",
		})
		return
	}

	var hymn Hymn
	query := `
		SELECT id, number, new_hymn_number, title, lyrics, theme,
			   COALESCE(composer, '') as composer,
			   COALESCE(author, '') as author,
			   COALESCE(tempo, '') as tempo,
			   COALESCE(key_signature, '') as key_signature,
			   COALESCE(bible_reference, '') as bible_reference,
			   COALESCE(external_link, '') as external_link
		FROM hymns WHERE new_hymn_number = $1`

	row := h.DB.QueryRow(query, number)
	err = row.Scan(
		&hymn.ID, &hymn.Number, &hymn.NewHymnNumber, &hymn.Title, &hymn.Lyrics, &hymn.Theme,
		&hymn.Composer, &hymn.Author, &hymn.Tempo, &hymn.KeySignature, &hymn.BibleReference, &hymn.ExternalLink,
	)
	if err != nil {
		if err == sql.ErrNoRows {
			c.JSON(http.StatusNotFound, gin.H{
				"error": "해당 번호의 찬송가를 찾을 수 없습니다",
			})
		} else {
			c.JSON(http.StatusInternalServerError, gin.H{
				"error": "데이터베이스 조회 중 오류가 발생했습니다",
			})
		}
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"hymn":    hymn,
	})
}

// GetHymnsByTheme 주제별 찬송가 조회
func (h *HymnHandlers) GetHymnsByTheme(c *gin.Context) {
	theme := strings.TrimSpace(c.Param("theme"))
	limitStr := c.DefaultQuery("limit", "20")

	if theme == "" {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "주제를 입력해주세요",
		})
		return
	}

	limit, err := strconv.Atoi(limitStr)
	if err != nil || limit <= 0 || limit > 50 {
		limit = 20
	}

	var hymns []Hymn
	query := `
		SELECT id, number, new_hymn_number, title, lyrics, theme,
			   COALESCE(composer, '') as composer,
			   COALESCE(author, '') as author,
			   COALESCE(tempo, '') as tempo,
			   COALESCE(key_signature, '') as key_signature,
			   COALESCE(bible_reference, '') as bible_reference,
			   COALESCE(external_link, '') as external_link
		FROM hymns 
		WHERE LOWER(theme) LIKE LOWER($1)
		ORDER BY number ASC 
		LIMIT $2`

	rows, err := h.DB.Query(query, "%"+theme+"%", limit)
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
			&hymn.ID, &hymn.Number, &hymn.NewHymnNumber, &hymn.Title, &hymn.Lyrics, &hymn.Theme,
			&hymn.Composer, &hymn.Author, &hymn.Tempo, &hymn.KeySignature, &hymn.BibleReference, &hymn.ExternalLink,
		)
		if err != nil {
			continue
		}
		hymns = append(hymns, hymn)
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"total":   len(hymns),
		"theme":   theme,
		"hymns":   hymns,
	})
}

// GetHymnThemes 모든 찬송가 주제 목록 조회
func (h *HymnHandlers) GetHymnThemes(c *gin.Context) {
	type ThemeCount struct {
		Theme string `json:"theme"`
		Count int    `json:"count"`
	}
	var themes []ThemeCount

	query := `
		SELECT theme, COUNT(*) as count 
		FROM hymns 
		WHERE theme IS NOT NULL AND theme != ''
		GROUP BY theme 
		ORDER BY count DESC, theme ASC`

	rows, err := h.DB.Query(query)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "주제 목록 조회 중 오류가 발생했습니다",
		})
		return
	}
	defer rows.Close()

	for rows.Next() {
		var theme ThemeCount
		err := rows.Scan(&theme.Theme, &theme.Count)
		if err != nil {
			continue
		}
		themes = append(themes, theme)
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"total":   len(themes),
		"themes":  themes,
	})
}

// ImportHymnsData 찬송가 데이터 일괄 Import API
// POST /api/admin/import/hymns
func (h *HymnHandlers) ImportHymnsData(c *gin.Context) {
	var hymns []Hymn

	if err := c.ShouldBindJSON(&hymns); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "Invalid JSON format",
			"details": err.Error(),
		})
		return
	}

	if len(hymns) == 0 {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "No hymns data provided",
		})
		return
	}

	// 트랜잭션 시작
	tx, err := h.DB.Begin()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "Failed to start transaction",
		})
		return
	}
	defer tx.Rollback()

	// 기존 찬송가 데이터 모두 삭제
	_, err = tx.Exec("DELETE FROM hymns")
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "Failed to clear existing hymns",
		})
		return
	}

	successCount := 0
	var errors []string

	for _, hymn := range hymns {
		// 찬송가 데이터 삽입 (중복 시 업데이트)
		_, err := tx.Exec(`
			INSERT INTO hymns (number, title, lyrics, theme, composer, author, tempo, key_signature, bible_reference)
			VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
			ON CONFLICT (number) DO UPDATE SET
				title = EXCLUDED.title,
				lyrics = EXCLUDED.lyrics,
				theme = EXCLUDED.theme,
				composer = EXCLUDED.composer,
				author = EXCLUDED.author,
				tempo = EXCLUDED.tempo,
				key_signature = EXCLUDED.key_signature,
				bible_reference = EXCLUDED.bible_reference,
				updated_at = NOW()
		`, hymn.Number, hymn.Title, hymn.Lyrics, hymn.Theme,
			hymn.Composer, hymn.Author, hymn.Tempo, hymn.KeySignature, hymn.BibleReference)

		if err != nil {
			errors = append(errors, fmt.Sprintf("Failed to import hymn %d: %v", hymn.Number, err))
			continue
		}
		successCount++
	}

	// 트랜잭션 커밋
	if err = tx.Commit(); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "Failed to commit transaction",
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": "Hymns import completed",
		"total_provided": len(hymns),
		"success_count": successCount,
		"error_count": len(errors),
		"errors": errors,
	})
}

// GetRandomHymns 랜덤 찬송가 조회 (인기 찬송가 대신)
func (h *HymnHandlers) GetRandomHymns(c *gin.Context) {
	limitStr := c.DefaultQuery("limit", "5")
	
	limit, err := strconv.Atoi(limitStr)
	if err != nil || limit <= 0 || limit > 10 {
		limit = 5
	}

	var hymns []Hymn
	query := `
		SELECT id, number, new_hymn_number, title, lyrics, theme,
			   COALESCE(composer, '') as composer,
			   COALESCE(author, '') as author,
			   COALESCE(tempo, '') as tempo,
			   COALESCE(key_signature, '') as key_signature,
			   COALESCE(bible_reference, '') as bible_reference,
			   COALESCE(external_link, '') as external_link
		FROM hymns 
		ORDER BY RANDOM()
		LIMIT $1`

	rows, err := h.DB.Query(query, limit)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "찬송가 조회 중 오류가 발생했습니다",
		})
		return
	}
	defer rows.Close()

	for rows.Next() {
		var hymn Hymn
		err := rows.Scan(
			&hymn.ID, &hymn.Number, &hymn.NewHymnNumber, &hymn.Title, &hymn.Lyrics, &hymn.Theme,
			&hymn.Composer, &hymn.Author, &hymn.Tempo, &hymn.KeySignature, &hymn.BibleReference, &hymn.ExternalLink,
		)
		if err != nil {
			continue
		}
		hymns = append(hymns, hymn)
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"total":   len(hymns),
		"hymns":   hymns,
	})
}