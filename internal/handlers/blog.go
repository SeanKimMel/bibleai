package handlers

import (
	"database/sql"
	"math"
	"math/rand"
	"net/http"
	"strconv"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/russross/blackfriday/v2"
)

// BlogPost 구조체
type BlogPost struct {
	ID          int    `json:"id"`
	Title       string `json:"title"`
	Slug        string `json:"slug"`
	Content     string `json:"content"`
	ContentHTML string `json:"content_html,omitempty"`
	Excerpt     string `json:"excerpt"`
	Keywords    string `json:"keywords"`
	PublishedAt string `json:"published_at"`
	ViewCount   int    `json:"view_count"`
}

// CreateBlogPost - 블로그 생성 (관리자용)
func CreateBlogPost(c *gin.Context) {
	var post struct {
		Title    string `json:"title" binding:"required"`
		Slug     string `json:"slug" binding:"required"`
		Content  string `json:"content" binding:"required"`
		Excerpt  string `json:"excerpt"`
		Keywords string `json:"keywords"`
	}

	if err := c.ShouldBindJSON(&post); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "필수 입력값이 누락되었습니다", "details": err.Error()})
		return
	}

	// DB에 삽입
	var id int
	err := db.QueryRow(`
		INSERT INTO blog_posts (title, slug, content, excerpt, keywords, published_at)
		VALUES ($1, $2, $3, $4, $5, NOW())
		RETURNING id
	`, post.Title, post.Slug, post.Content, post.Excerpt, post.Keywords).Scan(&id)

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "블로그 생성 실패", "details": err.Error()})
		return
	}

	c.JSON(http.StatusCreated, gin.H{
		"success": true,
		"message": "블로그가 생성되었습니다",
		"id":      id,
	})
}

// GetBlogPosts - 블로그 목록 조회 (페이지네이션)
func GetBlogPosts(c *gin.Context) {
	// 페이지 파라미터
	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "10"))
	if page < 1 {
		page = 1
	}
	if limit < 1 || limit > 50 {
		limit = 10
	}

	offset := (page - 1) * limit

	// 전체 개수 조회
	var total int
	err := db.QueryRow("SELECT COUNT(*) FROM blog_posts WHERE is_published = true").Scan(&total)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "전체 개수 조회 실패"})
		return
	}

	// 블로그 목록 조회
	rows, err := db.Query(`
		SELECT id, title, slug, excerpt, keywords, published_at, view_count
		FROM blog_posts
		WHERE is_published = true
		ORDER BY published_at DESC
		LIMIT $1 OFFSET $2
	`, limit, offset)

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "블로그 조회 실패"})
		return
	}
	defer rows.Close()

	posts := []BlogPost{}
	for rows.Next() {
		var post BlogPost
		err := rows.Scan(
			&post.ID,
			&post.Title,
			&post.Slug,
			&post.Excerpt,
			&post.Keywords,
			&post.PublishedAt,
			&post.ViewCount,
		)
		if err != nil {
			continue
		}
		posts = append(posts, post)
	}

	// 페이지 정보 계산
	totalPages := int(math.Ceil(float64(total) / float64(limit)))

	c.JSON(http.StatusOK, gin.H{
		"posts":       posts,
		"total":       total,
		"page":        page,
		"limit":       limit,
		"total_pages": totalPages,
		"has_next":    page < totalPages,
		"has_prev":    page > 1,
	})
}

// GetBlogPost - 블로그 상세 조회
func GetBlogPost(c *gin.Context) {
	slug := c.Param("slug")

	var post BlogPost
	err := db.QueryRow(`
		SELECT id, title, slug, content, excerpt, keywords, published_at, view_count
		FROM blog_posts
		WHERE slug = $1 AND is_published = true
	`, slug).Scan(
		&post.ID,
		&post.Title,
		&post.Slug,
		&post.Content,
		&post.Excerpt,
		&post.Keywords,
		&post.PublishedAt,
		&post.ViewCount,
	)

	if err == sql.ErrNoRows {
		c.JSON(http.StatusNotFound, gin.H{"error": "블로그를 찾을 수 없습니다"})
		return
	}

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "블로그 조회 실패"})
		return
	}

	// 마크다운 → HTML 변환 (raw HTML 허용)
	renderer := blackfriday.NewHTMLRenderer(blackfriday.HTMLRendererParameters{
		Flags: blackfriday.CommonHTMLFlags,
	})
	htmlContent := blackfriday.Run([]byte(post.Content),
		blackfriday.WithRenderer(renderer),
		blackfriday.WithExtensions(blackfriday.CommonExtensions))
	post.ContentHTML = string(htmlContent)

	// 조회수 증가
	db.Exec("UPDATE blog_posts SET view_count = view_count + 1 WHERE id = $1", post.ID)

	c.JSON(http.StatusOK, post)
}

// UpdateBlogPost - 블로그 수정 API (ID 기반)
func UpdateBlogPost(c *gin.Context) {
	id := c.Param("id")

	var post struct {
		Title    *string `json:"title"`
		Slug     *string `json:"slug"`
		Content  *string `json:"content"`
		Excerpt  *string `json:"excerpt"`
		Keywords *string `json:"keywords"`
	}

	if err := c.ShouldBindJSON(&post); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "잘못된 요청입니다", "details": err.Error()})
		return
	}

	// 업데이트할 필드 동적 구성
	updates := []string{}
	args := []interface{}{}
	argCount := 1

	if post.Title != nil {
		updates = append(updates, "title = $"+strconv.Itoa(argCount))
		args = append(args, *post.Title)
		argCount++
	}
	if post.Slug != nil {
		updates = append(updates, "slug = $"+strconv.Itoa(argCount))
		args = append(args, *post.Slug)
		argCount++
	}
	if post.Content != nil {
		updates = append(updates, "content = $"+strconv.Itoa(argCount))
		args = append(args, *post.Content)
		argCount++
	}
	if post.Excerpt != nil {
		updates = append(updates, "excerpt = $"+strconv.Itoa(argCount))
		args = append(args, *post.Excerpt)
		argCount++
	}
	if post.Keywords != nil {
		updates = append(updates, "keywords = $"+strconv.Itoa(argCount))
		args = append(args, *post.Keywords)
		argCount++
	}

	if len(updates) == 0 {
		c.JSON(http.StatusBadRequest, gin.H{"error": "업데이트할 필드가 없습니다"})
		return
	}

	updates = append(updates, "updated_at = NOW()")
	args = append(args, id)

	query := "UPDATE blog_posts SET " + string(updates[0])
	for i := 1; i < len(updates); i++ {
		query += ", " + updates[i]
	}
	query += " WHERE id = $" + strconv.Itoa(argCount) + " AND is_published = true"

	result, err := db.Exec(query, args...)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "블로그 수정 실패", "details": err.Error()})
		return
	}

	rowsAffected, _ := result.RowsAffected()
	if rowsAffected == 0 {
		c.JSON(http.StatusNotFound, gin.H{"error": "블로그를 찾을 수 없습니다"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": "블로그가 수정되었습니다",
	})
}

// DeleteBlogPost - 블로그 소프트 삭제 API (is_published = false 설정)
func DeleteBlogPost(c *gin.Context) {
	id := c.Param("id")

	result, err := db.Exec("UPDATE blog_posts SET is_published = false, updated_at = NOW() WHERE id = $1", id)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "블로그 삭제 실패", "details": err.Error()})
		return
	}

	rowsAffected, _ := result.RowsAffected()
	if rowsAffected == 0 {
		c.JSON(http.StatusNotFound, gin.H{"error": "블로그를 찾을 수 없습니다"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": "블로그가 삭제되었습니다 (외부 노출 중단)",
	})
}

// GetBlogPostByID - ID 기반 블로그 조회 (관리자용, is_published 무관)
func GetBlogPostByID(c *gin.Context) {
	id := c.Param("id")

	var post BlogPost
	var theologicalAccuracy, contentStructure, engagement, technicalQuality, seoOptimization, totalScore sql.NullFloat64
	var qualityFeedback sql.NullString
	var evaluationDate sql.NullTime
	var evaluator sql.NullString

	err := db.QueryRow(`
		SELECT id, title, slug, content, excerpt, keywords, published_at, view_count,
		       theological_accuracy, content_structure, engagement,
		       technical_quality, seo_optimization, total_score,
		       quality_feedback, evaluation_date, evaluator
		FROM blog_posts
		WHERE id = $1
	`, id).Scan(
		&post.ID,
		&post.Title,
		&post.Slug,
		&post.Content,
		&post.Excerpt,
		&post.Keywords,
		&post.PublishedAt,
		&post.ViewCount,
		&theologicalAccuracy,
		&contentStructure,
		&engagement,
		&technicalQuality,
		&seoOptimization,
		&totalScore,
		&qualityFeedback,
		&evaluationDate,
		&evaluator,
	)

	if err == sql.ErrNoRows {
		c.JSON(http.StatusNotFound, gin.H{"error": "블로그를 찾을 수 없습니다"})
		return
	}

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "블로그 조회 실패"})
		return
	}

	// 품질 점수 포함 응답
	response := gin.H{
		"id":           post.ID,
		"title":        post.Title,
		"slug":         post.Slug,
		"content":      post.Content,
		"excerpt":      post.Excerpt,
		"keywords":     post.Keywords,
		"published_at": post.PublishedAt,
		"view_count":   post.ViewCount,
	}

	// 품질 평가 정보 추가 (있는 경우만)
	if totalScore.Valid {
		response["quality_scores"] = gin.H{
			"theological_accuracy": theologicalAccuracy.Float64,
			"content_structure":    contentStructure.Float64,
			"engagement":           engagement.Float64,
			"technical_quality":    technicalQuality.Float64,
			"seo_optimization":     seoOptimization.Float64,
			"total_score":          totalScore.Float64,
		}
		if qualityFeedback.Valid {
			response["quality_feedback"] = qualityFeedback.String
		}
		if evaluationDate.Valid {
			response["evaluation_date"] = evaluationDate.Time
		}
		if evaluator.Valid {
			response["evaluator"] = evaluator.String
		}
	}

	c.JSON(http.StatusOK, response)
}

// EvaluateBlogPost - 블로그 품질 평가 API (외부 스크립트 호출용)
func EvaluateBlogPost(c *gin.Context) {
	id := c.Param("id")

	// 요청 본문에서 평가 점수 받기
	var evaluation struct {
		TheologicalAccuracy float64 `json:"theological_accuracy" binding:"required,min=0,max=10"`
		ContentStructure    float64 `json:"content_structure" binding:"required,min=0,max=10"`
		Engagement          float64 `json:"engagement" binding:"required,min=0,max=10"`
		TechnicalQuality    float64 `json:"technical_quality" binding:"required,min=0,max=10"`
		SeoOptimization     float64 `json:"seo_optimization" binding:"required,min=0,max=10"`
		TotalScore          float64 `json:"total_score" binding:"required,min=0,max=10"`
		QualityFeedback     string  `json:"quality_feedback"`
		Evaluator           string  `json:"evaluator"`
	}

	if err := c.ShouldBindJSON(&evaluation); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "잘못된 요청입니다", "details": err.Error()})
		return
	}

	// 기본값 설정
	if evaluation.Evaluator == "" {
		evaluation.Evaluator = "gemini-api"
	}

	// 블로그 존재 확인
	var exists bool
	err := db.QueryRow("SELECT EXISTS(SELECT 1 FROM blog_posts WHERE id = $1)", id).Scan(&exists)
	if err != nil || !exists {
		c.JSON(http.StatusNotFound, gin.H{"error": "블로그를 찾을 수 없습니다"})
		return
	}

	// 품질 점수 업데이트
	_, err = db.Exec(`
		UPDATE blog_posts
		SET theological_accuracy = $1,
		    content_structure = $2,
		    engagement = $3,
		    technical_quality = $4,
		    seo_optimization = $5,
		    total_score = $6,
		    quality_feedback = $7,
		    evaluation_date = NOW(),
		    evaluator = $8,
		    updated_at = NOW()
		WHERE id = $9
	`, evaluation.TheologicalAccuracy,
		evaluation.ContentStructure,
		evaluation.Engagement,
		evaluation.TechnicalQuality,
		evaluation.SeoOptimization,
		evaluation.TotalScore,
		evaluation.QualityFeedback,
		evaluation.Evaluator,
		id)

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "품질 점수 저장 실패", "details": err.Error()})
		return
	}

	// 자동 발행 여부 확인
	var isPublished bool
	db.QueryRow("SELECT is_published FROM blog_posts WHERE id = $1", id).Scan(&isPublished)

	response := gin.H{
		"success":      true,
		"message":      "품질 평가가 저장되었습니다",
		"is_published": isPublished,
	}

	// 자동 발행 조건 체크
	autoPublishCondition := evaluation.TotalScore >= 7.0 &&
		evaluation.TheologicalAccuracy >= 6.0 &&
		evaluation.TechnicalQuality >= 7.0

	if autoPublishCondition && isPublished {
		response["auto_published"] = true
		response["message"] = "품질 기준을 충족하여 자동으로 발행되었습니다"
	} else if !autoPublishCondition {
		response["auto_published"] = false
		response["message"] = "품질 평가 저장 완료 (발행 기준 미달)"
		response["publish_requirements"] = gin.H{
			"total_score_required":          7.0,
			"theological_accuracy_required": 6.0,
			"technical_quality_required":    7.0,
		}
	}

	c.JSON(http.StatusOK, response)
}

// GetBlogQualityHistory - 블로그 품질 평가 이력 조회
func GetBlogQualityHistory(c *gin.Context) {
	id := c.Param("id")

	rows, err := db.Query(`
		SELECT theological_accuracy, content_structure, engagement,
		       technical_quality, seo_optimization, total_score,
		       quality_feedback, evaluator, evaluated_at
		FROM blog_quality_history
		WHERE blog_post_id = $1
		ORDER BY evaluated_at DESC
		LIMIT 10
	`, id)

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "이력 조회 실패"})
		return
	}
	defer rows.Close()

	var history []gin.H
	for rows.Next() {
		var theologicalAccuracy, contentStructure, engagement, technicalQuality, seoOptimization, totalScore float64
		var qualityFeedback, evaluator string
		var evaluatedAt time.Time

		err := rows.Scan(
			&theologicalAccuracy,
			&contentStructure,
			&engagement,
			&technicalQuality,
			&seoOptimization,
			&totalScore,
			&qualityFeedback,
			&evaluator,
			&evaluatedAt,
		)

		if err != nil {
			continue
		}

		history = append(history, gin.H{
			"theological_accuracy": theologicalAccuracy,
			"content_structure":    contentStructure,
			"engagement":           engagement,
			"technical_quality":    technicalQuality,
			"seo_optimization":     seoOptimization,
			"total_score":          totalScore,
			"quality_feedback":     qualityFeedback,
			"evaluator":            evaluator,
			"evaluated_at":         evaluatedAt,
		})
	}

	c.JSON(http.StatusOK, gin.H{
		"blog_post_id": id,
		"history":      history,
		"total":        len(history),
	})
}

// GenerateBlogData - 블로그 자동 생성을 위한 데이터 수집 API
// GET /api/admin/blog/generate-data?keyword={키워드}&random={true/false}
func GenerateBlogData(c *gin.Context) {
	keyword := c.Query("keyword")
	if keyword == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "keyword 파라미터가 필요합니다"})
		return
	}

	// random 파라미터 (기본값: false)
	randomMode := c.DefaultQuery("random", "false") == "true"

	result := gin.H{
		"keyword": keyword,
		"random_mode": randomMode,
		"data":    gin.H{},
	}

	// 1. 성경 챕터 검색
	var bibleQuery string
	if randomMode {
		// 랜덤 모드: 연관도 높은 챕터 중 랜덤 선택 (상위 10개 중)
		bibleQuery = `
			SELECT
				bct.book,
				bct.book_name,
				bct.chapter,
				bct.theme,
				bct.relevance_score
			FROM bible_chapter_themes bct
			WHERE bct.theme ILIKE $1
			ORDER BY bct.relevance_score DESC, bct.keyword_count DESC
			LIMIT 10
		`
	} else {
		// 일반 모드: 연관도 최고 1개
		bibleQuery = `
			SELECT
				bct.book,
				bct.book_name,
				bct.chapter,
				bct.theme,
				bct.relevance_score
			FROM bible_chapter_themes bct
			WHERE bct.theme ILIKE $1
			ORDER BY bct.relevance_score DESC, bct.keyword_count DESC
			LIMIT 1
		`
	}
	var bibleBook, bibleBookName, bibleTheme string
	var bibleChapter, bibleScore int

	if randomMode {
		// 랜덤 모드: 여러 개 중에서 랜덤 선택
		rows, err := db.Query(bibleQuery, "%"+keyword+"%")
		if err == nil {
			defer rows.Close()
			var candidates []struct {
				book, bookName, theme string
				chapter, score int
			}
			for rows.Next() {
				var cand struct {
					book, bookName, theme string
					chapter, score int
				}
				if err := rows.Scan(&cand.book, &cand.bookName, &cand.chapter, &cand.theme, &cand.score); err == nil {
					candidates = append(candidates, cand)
				}
			}
			if len(candidates) > 0 {
				// 랜덤 선택
				rand.Seed(time.Now().UnixNano())
				selected := candidates[rand.Intn(len(candidates))]
				bibleBook = selected.book
				bibleBookName = selected.bookName
				bibleChapter = selected.chapter
				bibleTheme = selected.theme
				bibleScore = selected.score
			}
		}
	} else {
		// 일반 모드: 최고 1개
		db.QueryRow(bibleQuery, "%"+keyword+"%").Scan(&bibleBook, &bibleBookName, &bibleChapter, &bibleTheme, &bibleScore)
	}

	if bibleBook != "" {
		// 해당 챕터의 구절들 조회
		versesQuery := `
			SELECT verse, content
			FROM bible_verses
			WHERE book_id = $1 AND chapter = $2
			ORDER BY verse ASC
		`
		rows, err := db.Query(versesQuery, bibleBook, bibleChapter)
		if err == nil {
			verses := []gin.H{}
			for rows.Next() {
				var verse int
				var content string
				if err := rows.Scan(&verse, &content); err == nil {
					verses = append(verses, gin.H{
						"verse":   verse,
						"content": content,
					})
				}
			}
			rows.Close()

			result["data"].(gin.H)["bible"] = gin.H{
				"book":            bibleBook,
				"book_name":       bibleBookName,
				"chapter":         bibleChapter,
				"theme":           bibleTheme,
				"relevance_score": bibleScore,
				"verses":          verses,
				"total_verses":    len(verses),
			}
		}
	}

	// 2. 기도문 검색 (최대 2개)
	prayers := []gin.H{}
	prayersQuery := `
		SELECT DISTINCT p.id, p.title, p.content
		FROM prayers p
		LEFT JOIN prayer_tags pt ON p.id = pt.prayer_id
		LEFT JOIN tags t ON pt.tag_id = t.id
		WHERE p.title ILIKE $1 OR p.content ILIKE $1 OR t.name ILIKE $1
		ORDER BY p.created_at DESC
		LIMIT 2
	`
	rows, err := db.Query(prayersQuery, "%"+keyword+"%")
	if err == nil {
		for rows.Next() {
			var id int
			var title, content string
			if err := rows.Scan(&id, &title, &content); err == nil {
				prayers = append(prayers, gin.H{
					"id":      id,
					"title":   title,
					"content": content,
				})
			}
		}
		rows.Close()
	}
	result["data"].(gin.H)["prayers"] = prayers

	// 3. 찬송가 검색 (1개만)
	hymns := []gin.H{}
	var hymnsQuery string
	if randomMode {
		// 랜덤 모드: 더 많은 후보 중에서 랜덤 선택
		hymnsQuery = `
			SELECT id, number, new_hymn_number, title, lyrics, theme,
				   COALESCE(composer, '') as composer,
				   COALESCE(author, '') as author,
				   COALESCE(external_link, '') as external_link
			FROM hymns
			WHERE LOWER(title) LIKE LOWER($1) OR LOWER(lyrics) LIKE LOWER($1) OR LOWER(theme) LIKE LOWER($1)
			ORDER BY RANDOM()
			LIMIT 1
		`
	} else {
		// 일반 모드: 번호 순
		hymnsQuery = `
			SELECT id, number, new_hymn_number, title, lyrics, theme,
				   COALESCE(composer, '') as composer,
				   COALESCE(author, '') as author,
				   COALESCE(external_link, '') as external_link
			FROM hymns
			WHERE LOWER(title) LIKE LOWER($1) OR LOWER(lyrics) LIKE LOWER($1) OR LOWER(theme) LIKE LOWER($1)
			ORDER BY number ASC
			LIMIT 1
		`
	}
	rows, err = db.Query(hymnsQuery, "%"+keyword+"%")
	if err == nil {
		for rows.Next() {
			var id, number int
			var newHymnNumber *int
			var title, lyrics, theme, composer, author, externalLink string
			if err := rows.Scan(&id, &number, &newHymnNumber, &title, &lyrics, &theme, &composer, &author, &externalLink); err == nil {
				hymn := gin.H{
					"id":            id,
					"number":        number,
					"title":         title,
					"lyrics":        lyrics,
					"theme":         theme,
					"composer":      composer,
					"author":        author,
					"external_link": externalLink,
				}
				if newHymnNumber != nil {
					hymn["new_hymn_number"] = *newHymnNumber
				}
				hymns = append(hymns, hymn)
			}
		}
		rows.Close()
	}
	result["data"].(gin.H)["hymns"] = hymns

	// 4. 데이터 요약
	dataSummary := gin.H{
		"has_bible":  result["data"].(gin.H)["bible"] != nil,
		"has_prayer": len(prayers) > 0,
		"has_hymn":   len(hymns) > 0,
	}
	result["summary"] = dataSummary

	c.JSON(http.StatusOK, result)
}
