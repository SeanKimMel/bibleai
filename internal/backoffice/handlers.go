package backoffice

import (
	"context"
	"database/sql"
	"encoding/json"
	"log"
	"net/http"
	"regexp"
	"strconv"
	"time"

	"bibleai/internal/gemini"
	"bibleai/internal/hymn"
	"bibleai/internal/youtube"
	"github.com/gin-gonic/gin"
)

// Handlers 백오피스 핸들러
type Handlers struct {
	db *sql.DB
}

// NewHandlers 핸들러 초기화
func NewHandlers(db *sql.DB) *Handlers {
	return &Handlers{db: db}
}

// BlogPost 구조체
type BlogPost struct {
	ID                   int             `json:"id"`
	Title                string          `json:"title"`
	Slug                 string          `json:"slug"`
	Content              string          `json:"content"`
	Excerpt              string          `json:"excerpt"`
	Keywords             string          `json:"keywords"`
	IsPublished          bool            `json:"is_published"`
	PublishedAt          *time.Time      `json:"published_at"`
	CreatedAt            time.Time       `json:"created_at"`
	ViewCount            int             `json:"view_count"`
	TheologicalAccuracy  *float64        `json:"theological_accuracy"`
	ContentStructure     *float64        `json:"content_structure"`
	Engagement           *float64        `json:"engagement"`
	TechnicalQuality     *float64        `json:"technical_quality"`
	SeoOptimization      *float64        `json:"seo_optimization"`
	TotalScore           *float64        `json:"total_score"`
	QualityFeedback      json.RawMessage `json:"quality_feedback"`
	EvaluationDate       *time.Time      `json:"evaluation_date"`
	Evaluator            *string         `json:"evaluator"`
}

// Stats 통계 구조체
type Stats struct {
	TotalBlogs      int `json:"total_blogs"`
	PublishedBlogs  int `json:"published_blogs"`
	DraftBlogs      int `json:"draft_blogs"`
	EvaluatedBlogs  int `json:"evaluated_blogs"`
	AvgScore        float64 `json:"avg_score"`
}

// DashboardPage 대시보드 페이지
func (h *Handlers) DashboardPage(c *gin.Context) {
	c.HTML(http.StatusOK, "dashboard.html", gin.H{
		"title": "백오피스 대시보드",
	})
}

// BlogListPage 블로그 목록 페이지
func (h *Handlers) BlogListPage(c *gin.Context) {
	c.HTML(http.StatusOK, "blog_list.html", gin.H{
		"title": "블로그 관리",
	})
}

// BlogDetailPage 블로그 상세 페이지
func (h *Handlers) BlogDetailPage(c *gin.Context) {
	id := c.Param("id")
	c.HTML(http.StatusOK, "blog_detail.html", gin.H{
		"title": "블로그 상세",
		"id":    id,
	})
}

// BlogNewPage 신규 블로그 작성 페이지
func (h *Handlers) BlogNewPage(c *gin.Context) {
	c.HTML(http.StatusOK, "blog_new.html", gin.H{
		"title": "신규 블로그 작성",
	})
}

// GetBlogs 블로그 목록 조회 (미발행 포함)
func (h *Handlers) GetBlogs(c *gin.Context) {
	// 쿼리 파라미터
	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "20"))
	status := c.DefaultQuery("status", "all") // all, published, draft, evaluated

	if page < 1 {
		page = 1
	}
	if limit < 1 || limit > 100 {
		limit = 20
	}

	offset := (page - 1) * limit

	// WHERE 조건 생성
	whereClause := "1=1"
	switch status {
	case "published":
		whereClause = "is_published = true"
	case "draft":
		whereClause = "is_published = false"
	case "evaluated":
		whereClause = "total_score IS NOT NULL"
	}

	// 전체 개수 조회
	var total int
	err := h.db.QueryRow("SELECT COUNT(*) FROM blog_posts WHERE " + whereClause).Scan(&total)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "개수 조회 실패"})
		return
	}

	// 블로그 목록 조회
	rows, err := h.db.Query(`
		SELECT
			id, title, slug, excerpt, keywords, is_published, published_at,
			created_at, view_count, theological_accuracy, content_structure,
			engagement, technical_quality, seo_optimization, total_score,
			evaluation_date, evaluator
		FROM blog_posts
		WHERE `+whereClause+`
		ORDER BY created_at DESC
		LIMIT $1 OFFSET $2
	`, limit, offset)

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "블로그 조회 실패"})
		return
	}
	defer rows.Close()

	blogs := []BlogPost{}
	for rows.Next() {
		var blog BlogPost
		err := rows.Scan(
			&blog.ID, &blog.Title, &blog.Slug, &blog.Excerpt, &blog.Keywords,
			&blog.IsPublished, &blog.PublishedAt, &blog.CreatedAt, &blog.ViewCount,
			&blog.TheologicalAccuracy, &blog.ContentStructure, &blog.Engagement,
			&blog.TechnicalQuality, &blog.SeoOptimization, &blog.TotalScore,
			&blog.EvaluationDate, &blog.Evaluator,
		)
		if err != nil {
			continue
		}
		blogs = append(blogs, blog)
	}

	c.JSON(http.StatusOK, gin.H{
		"blogs": blogs,
		"pagination": gin.H{
			"page":  page,
			"limit": limit,
			"total": total,
			"pages": (total + limit - 1) / limit,
		},
	})
}

// GetBlog 블로그 상세 조회
func (h *Handlers) GetBlog(c *gin.Context) {
	id := c.Param("id")

	var blog BlogPost
	err := h.db.QueryRow(`
		SELECT
			id, title, slug, content, excerpt, keywords, is_published,
			published_at, created_at, view_count, theological_accuracy,
			content_structure, engagement, technical_quality, seo_optimization,
			total_score, quality_feedback, evaluation_date, evaluator
		FROM blog_posts
		WHERE id = $1
	`, id).Scan(
		&blog.ID, &blog.Title, &blog.Slug, &blog.Content, &blog.Excerpt,
		&blog.Keywords, &blog.IsPublished, &blog.PublishedAt, &blog.CreatedAt,
		&blog.ViewCount, &blog.TheologicalAccuracy, &blog.ContentStructure,
		&blog.Engagement, &blog.TechnicalQuality, &blog.SeoOptimization,
		&blog.TotalScore, &blog.QualityFeedback, &blog.EvaluationDate, &blog.Evaluator,
	)

	if err == sql.ErrNoRows {
		c.JSON(http.StatusNotFound, gin.H{"error": "블로그를 찾을 수 없습니다"})
		return
	}
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "블로그 조회 실패"})
		return
	}

	c.JSON(http.StatusOK, blog)
}

// SaveEvaluation 블로그 평가 점수 저장
func (h *Handlers) SaveEvaluation(c *gin.Context) {
	id := c.Param("id")

	var req struct {
		TheologicalAccuracy float64 `json:"theological_accuracy"`
		ContentStructure    float64 `json:"content_structure"`
		Engagement          float64 `json:"engagement"`
		TechnicalQuality    float64 `json:"technical_quality"`
		SeoOptimization     float64 `json:"seo_optimization"`
		TotalScore          float64 `json:"total_score"`
		QualityFeedback     string  `json:"quality_feedback"`
		Evaluator           string  `json:"evaluator"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "잘못된 요청"})
		return
	}

	// 블로그 업데이트
	_, err := h.db.Exec(`
		UPDATE blog_posts SET
			theological_accuracy = $1,
			content_structure = $2,
			engagement = $3,
			technical_quality = $4,
			seo_optimization = $5,
			total_score = $6,
			quality_feedback = $7,
			evaluation_date = NOW(),
			evaluator = $8
		WHERE id = $9
	`, req.TheologicalAccuracy, req.ContentStructure, req.Engagement,
		req.TechnicalQuality, req.SeoOptimization, req.TotalScore,
		req.QualityFeedback, req.Evaluator, id)

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "평가 저장 실패"})
		return
	}

	// 업데이트된 블로그 조회 (자동 발행 트리거 확인)
	var isPublished bool
	err = h.db.QueryRow("SELECT is_published FROM blog_posts WHERE id = $1", id).Scan(&isPublished)
	if err != nil {
		c.JSON(http.StatusOK, gin.H{
			"success": true,
			"message": "평가 저장 완료",
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success":        true,
		"message":        "평가 저장 완료",
		"is_published":   isPublished,
		"auto_published": isPublished, // 트리거에 의해 자동 발행되었는지 여부
	})
}

// TogglePublish 블로그 발행 토글
func (h *Handlers) TogglePublish(c *gin.Context) {
	id := c.Param("id")

	var req struct {
		IsPublished bool `json:"is_published"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "잘못된 요청"})
		return
	}

	// 발행 상태 업데이트
	var publishedAt *time.Time
	if req.IsPublished {
		now := time.Now()
		publishedAt = &now
	}

	_, err := h.db.Exec(`
		UPDATE blog_posts SET
			is_published = $1,
			published_at = $2
		WHERE id = $3
	`, req.IsPublished, publishedAt, id)

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "발행 상태 변경 실패"})
		return
	}

	status := "발행 취소"
	if req.IsPublished {
		status = "발행 완료"
	}

	c.JSON(http.StatusOK, gin.H{
		"success":      true,
		"message":      status,
		"is_published": req.IsPublished,
	})
}

// DeleteBlog 블로그 삭제
func (h *Handlers) DeleteBlog(c *gin.Context) {
	id := c.Param("id")

	_, err := h.db.Exec("DELETE FROM blog_posts WHERE id = $1", id)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "블로그 삭제 실패"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": "블로그가 삭제되었습니다",
	})
}

// GetStats 통계 조회
func (h *Handlers) GetStats(c *gin.Context) {
	var stats Stats

	// 총 블로그 수
	h.db.QueryRow("SELECT COUNT(*) FROM blog_posts").Scan(&stats.TotalBlogs)

	// 발행된 블로그 수
	h.db.QueryRow("SELECT COUNT(*) FROM blog_posts WHERE is_published = true").Scan(&stats.PublishedBlogs)

	// 미발행 블로그 수
	stats.DraftBlogs = stats.TotalBlogs - stats.PublishedBlogs

	// 평가된 블로그 수
	h.db.QueryRow("SELECT COUNT(*) FROM blog_posts WHERE total_score IS NOT NULL").Scan(&stats.EvaluatedBlogs)

	// 평균 점수
	h.db.QueryRow("SELECT COALESCE(AVG(total_score), 0) FROM blog_posts WHERE total_score IS NOT NULL").Scan(&stats.AvgScore)

	c.JSON(http.StatusOK, stats)
}

// CreateBlog 블로그 생성 API
func (h *Handlers) CreateBlog(c *gin.Context) {
	var req struct {
		Title    string `json:"title" binding:"required"`
		Slug     string `json:"slug" binding:"required"`
		Content  string `json:"content" binding:"required"`
		Excerpt  string `json:"excerpt"`
		Keywords string `json:"keywords"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "필수 입력값이 누락되었습니다"})
		return
	}

	var id int
	err := h.db.QueryRow(`
		INSERT INTO blog_posts (title, slug, content, excerpt, keywords, is_published, created_at)
		VALUES ($1, $2, $3, $4, $5, false, NOW())
		RETURNING id
	`, req.Title, req.Slug, req.Content, req.Excerpt, req.Keywords).Scan(&id)

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "블로그 생성 실패: " + err.Error()})
		return
	}

	c.JSON(http.StatusCreated, gin.H{
		"success": true,
		"message": "블로그가 생성되었습니다",
		"id":      id,
	})
}

// QualityHistory 품질 평가 이력
type QualityHistory struct {
	ID                  int             `json:"id"`
	BlogPostID          int             `json:"blog_post_id"`
	TheologicalAccuracy float64         `json:"theological_accuracy"`
	ContentStructure    float64         `json:"content_structure"`
	Engagement          float64         `json:"engagement"`
	TechnicalQuality    float64         `json:"technical_quality"`
	SeoOptimization     float64         `json:"seo_optimization"`
	TotalScore          float64         `json:"total_score"`
	QualityFeedback     json.RawMessage `json:"quality_feedback"`
	Evaluator           string          `json:"evaluator"`
	EvaluatedAt         time.Time       `json:"evaluated_at"`
}

// GetEvaluationHistory 블로그 평가 이력 조회
func (h *Handlers) GetEvaluationHistory(c *gin.Context) {
	id := c.Param("id")

	rows, err := h.db.Query(`
		SELECT
			id, blog_post_id, theological_accuracy, content_structure,
			engagement, technical_quality, seo_optimization, total_score,
			quality_feedback, evaluator, evaluated_at
		FROM blog_quality_history
		WHERE blog_post_id = $1
		ORDER BY evaluated_at DESC
	`, id)

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "평가 이력 조회 실패"})
		return
	}
	defer rows.Close()

	history := []QualityHistory{}
	for rows.Next() {
		var h QualityHistory
		err := rows.Scan(
			&h.ID, &h.BlogPostID, &h.TheologicalAccuracy, &h.ContentStructure,
			&h.Engagement, &h.TechnicalQuality, &h.SeoOptimization, &h.TotalScore,
			&h.QualityFeedback, &h.Evaluator, &h.EvaluatedAt,
		)
		if err != nil {
			continue
		}
		history = append(history, h)
	}

	c.JSON(http.StatusOK, gin.H{
		"history": history,
		"count":   len(history),
	})
}

// GenerateBlog Gemini API로 블로그 자동 생성 및 저장
func (h *Handlers) GenerateBlog(c *gin.Context) {
	var req struct {
		Keyword     string `json:"keyword"`      // 선택적: 비어있으면 랜덤 선택
		Date        string `json:"date"`
		AutoPublish *bool  `json:"auto_publish"` // 선택적: true이면 평가 무시하고 무조건 발행
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		// JSON 파싱 실패시에도 계속 진행 (빈 키워드로)
		req.Keyword = ""
	}

	// 키워드가 없으면 keywords 테이블에서 랜덤 선택
	if req.Keyword == "" {
		var keyword string
		err := h.db.QueryRow(`
			SELECT name
			FROM keywords
			WHERE bible_count > 0 OR hymn_count > 0 OR prayer_count > 0
			ORDER BY RANDOM()
			LIMIT 1
		`).Scan(&keyword)

		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "랜덤 키워드 선택 실패: " + err.Error()})
			return
		}

		req.Keyword = keyword
		log.Printf("🎲 랜덤 키워드 선택: %s", keyword)
	}

	// 날짜가 없으면 오늘 날짜 사용
	if req.Date == "" {
		req.Date = time.Now().Format("2006-01-02")
	}

	// Gemini API로 블로그 생성
	ctx := context.Background()
	blog, err := gemini.GenerateBlog(ctx, req.Keyword, req.Date)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "블로그 생성 실패: " + err.Error()})
		return
	}

	// YouTube 검색 태그를 실제 임베드로 교체
	log.Printf("🔍 YouTube 검색 태그 처리 중...")
	blog.Content = youtube.ReplaceYouTubeSearchTags(blog.Content)
	log.Printf("✅ YouTube 임베드 교체 완료")

	// 찬송가 가사를 API에서 가져와서 교체
	log.Printf("🎵 찬송가 가사 교체 중...")
	blog.Content = hymn.ReplaceHymnLyrics(blog.Content)
	log.Printf("✅ 찬송가 가사 교체 완료")

	// 찬송가 번호 추출
	hymnNumber := extractHymnNumber(blog.Content)
	if hymnNumber > 0 {
		log.Printf("🎵 찬송가 %d장 추출됨", hymnNumber)
	}

	// DB에 저장
	var id int
	err = h.db.QueryRow(`
		INSERT INTO blog_posts (title, slug, content, excerpt, keywords, hymn_number, is_published, created_at)
		VALUES ($1, $2, $3, $4, $5, $6, false, NOW())
		RETURNING id
	`, blog.Title, blog.Slug, blog.Content, blog.Excerpt, blog.Keywords, hymnNumber).Scan(&id)

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "블로그 저장 실패: " + err.Error()})
		return
	}

	// 생성된 블로그 자동 평가
	blogContent := gemini.BlogContent{
		Title:    blog.Title,
		Slug:     blog.Slug,
		Content:  blog.Content,
		Excerpt:  blog.Excerpt,
		Keywords: blog.Keywords,
	}

	evaluation, err := gemini.EvaluateQuality(ctx, blogContent)
	if err != nil {
		// 평가 실패해도 블로그는 저장됨
		c.JSON(http.StatusOK, gin.H{
			"success":         true,
			"message":         "블로그가 생성되었습니다 (평가 실패)",
			"id":              id,
			"blog":            blog,
			"evaluation_error": err.Error(),
		})
		return
	}

	// 평가 결과 저장
	feedbackJSON, _ := json.Marshal(evaluation.Feedback)
	_, err = h.db.Exec(`
		UPDATE blog_posts SET
			theological_accuracy = $1,
			content_structure = $2,
			engagement = $3,
			technical_quality = $4,
			seo_optimization = $5,
			total_score = $6,
			quality_feedback = $7,
			evaluation_date = NOW(),
			evaluator = 'gemini-api'
		WHERE id = $8
	`, evaluation.Scores.TheologicalAccuracy, evaluation.Scores.ContentStructure,
		evaluation.Scores.Engagement, evaluation.Scores.TechnicalQuality,
		evaluation.Scores.SeoOptimization, evaluation.TotalScore,
		feedbackJSON, id)

	if err != nil {
		c.JSON(http.StatusOK, gin.H{
			"success": true,
			"message": "블로그가 생성되었습니다 (평가 저장 실패)",
			"id":      id,
			"blog":    blog,
		})
		return
	}

	// 발행 여부 결정
	var isPublished bool
	var publishReason string

	if req.AutoPublish != nil && *req.AutoPublish {
		// auto_publish=true이면 평가 무시하고 무조건 발행
		isPublished = true
		publishReason = "사용자 요청에 의한 강제 발행"
		log.Printf("🚀 강제 발행: 블로그 ID %d", id)

		_, err = h.db.Exec(`UPDATE blog_posts SET is_published = true WHERE id = $1`, id)
		if err != nil {
			log.Printf("발행 상태 업데이트 실패: %v", err)
		}
	} else {
		// 평가 점수 기반 자동 발행
		canPublish, reason := gemini.ShouldPublish(evaluation)
		publishReason = reason

		if canPublish {
			isPublished = true
			log.Printf("✅ 자동 발행: 블로그 ID %d (총점: %.1f)", id, evaluation.TotalScore)

			_, err = h.db.Exec(`UPDATE blog_posts SET is_published = true WHERE id = $1`, id)
			if err != nil {
				log.Printf("발행 상태 업데이트 실패: %v", err)
			}
		} else {
			log.Printf("⏸️  미발행: 블로그 ID %d - %s", id, reason)
		}
	}

	c.JSON(http.StatusOK, gin.H{
		"success":        true,
		"message":        "블로그가 생성되고 평가되었습니다",
		"id":             id,
		"blog":           blog,
		"evaluation":     evaluation,
		"is_published":   isPublished,
		"reason":         publishReason,
		"auto_published": isPublished,
	})
}

// EvaluateBlog Gemini API를 사용하여 블로그 품질 평가
func (h *Handlers) EvaluateBlog(c *gin.Context) {
	id := c.Param("id")

	// 블로그 조회
	var blog BlogPost
	err := h.db.QueryRow(`
		SELECT id, title, slug, content, excerpt, keywords
		FROM blog_posts
		WHERE id = $1
	`, id).Scan(&blog.ID, &blog.Title, &blog.Slug, &blog.Content, &blog.Excerpt, &blog.Keywords)

	if err == sql.ErrNoRows {
		c.JSON(http.StatusNotFound, gin.H{"error": "블로그를 찾을 수 없습니다"})
		return
	}
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "블로그 조회 실패"})
		return
	}

	// Gemini API로 품질 평가
	ctx := context.Background()
	blogContent := gemini.BlogContent{
		Title:    blog.Title,
		Slug:     blog.Slug,
		Content:  blog.Content,
		Excerpt:  blog.Excerpt,
		Keywords: blog.Keywords,
	}

	evaluation, err := gemini.EvaluateQuality(ctx, blogContent)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "품질 평가 실패: " + err.Error()})
		return
	}

	// 평가 결과를 DB에 저장
	feedbackJSON, _ := json.Marshal(evaluation.Feedback)

	_, err = h.db.Exec(`
		UPDATE blog_posts SET
			theological_accuracy = $1,
			content_structure = $2,
			engagement = $3,
			technical_quality = $4,
			seo_optimization = $5,
			total_score = $6,
			quality_feedback = $7,
			evaluation_date = NOW(),
			evaluator = 'gemini-api'
		WHERE id = $8
	`, evaluation.Scores.TheologicalAccuracy, evaluation.Scores.ContentStructure,
		evaluation.Scores.Engagement, evaluation.Scores.TechnicalQuality,
		evaluation.Scores.SeoOptimization, evaluation.TotalScore,
		feedbackJSON, id)

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "평가 결과 저장 실패"})
		return
	}

	// 발행 여부 판단
	canPublish, reason := gemini.ShouldPublish(evaluation)

	// 트리거에 의해 자동 발행되었는지 확인
	var isPublished bool
	h.db.QueryRow("SELECT is_published FROM blog_posts WHERE id = $1", id).Scan(&isPublished)

	c.JSON(http.StatusOK, gin.H{
		"success":        true,
		"message":        "평가 완료",
		"evaluation":     evaluation,
		"can_publish":    canPublish,
		"reason":         reason,
		"is_published":   isPublished,
		"auto_published": isPublished && canPublish,
	})
}

// RegenerateBlog 평가 피드백을 기반으로 블로그 재생성
func (h *Handlers) RegenerateBlog(c *gin.Context) {
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "잘못된 ID"})
		return
	}

	// 요청 바디에서 사용자 피드백 읽기
	var req struct {
		CustomFeedback string `json:"custom_feedback"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		// 바디가 없거나 파싱 실패해도 계속 진행 (선택적 파라미터)
		req.CustomFeedback = ""
	}

	ctx := context.Background()

	// 기존 블로그 조회
	var blog BlogPost
	var feedback sql.NullString
	err = h.db.QueryRow(`
		SELECT id, title, slug, content, excerpt, keywords,
			theological_accuracy, content_structure, engagement,
			technical_quality, seo_optimization, total_score,
			quality_feedback
		FROM blog_posts WHERE id = $1
	`, id).Scan(&blog.ID, &blog.Title, &blog.Slug, &blog.Content, &blog.Excerpt, &blog.Keywords,
		&blog.TheologicalAccuracy, &blog.ContentStructure, &blog.Engagement,
		&blog.TechnicalQuality, &blog.SeoOptimization, &blog.TotalScore,
		&feedback)

	if err != nil {
		if err == sql.ErrNoRows {
			c.JSON(http.StatusNotFound, gin.H{"error": "블로그를 찾을 수 없습니다"})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"error": "블로그 조회 실패"})
		return
	}

	// 평가 결과가 없으면 먼저 평가
	if blog.TotalScore == nil || !feedback.Valid {
		c.JSON(http.StatusBadRequest, gin.H{"error": "먼저 블로그를 평가해야 합니다"})
		return
	}

	// 평가 결과 파싱
	var qualityFeedback gemini.QualityFeedback
	if err := json.Unmarshal([]byte(feedback.String), &qualityFeedback); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "평가 결과 파싱 실패"})
		return
	}

	// 평가 객체 재구성
	evaluation := &gemini.QualityEvaluation{
		Scores: gemini.QualityScores{
			TheologicalAccuracy: *blog.TheologicalAccuracy,
			ContentStructure:    *blog.ContentStructure,
			Engagement:          *blog.Engagement,
			TechnicalQuality:    *blog.TechnicalQuality,
			SeoOptimization:     *blog.SeoOptimization,
		},
		TotalScore: *blog.TotalScore,
		Feedback:   qualityFeedback,
	}

	// 블로그 재생성
	originalBlog := gemini.BlogContent{
		Title:    blog.Title,
		Slug:     blog.Slug,
		Content:  blog.Content,
		Excerpt:  blog.Excerpt,
		Keywords: blog.Keywords,
	}

	regeneratedBlog, err := gemini.RegenerateBlog(ctx, originalBlog, evaluation, req.CustomFeedback)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "블로그 재생성 실패: " + err.Error()})
		return
	}

	// YouTube 검색 태그를 실제 임베드로 교체
	log.Printf("🔍 YouTube 검색 태그 처리 중...")
	regeneratedBlog.Content = youtube.ReplaceYouTubeSearchTags(regeneratedBlog.Content)
	log.Printf("✅ YouTube 임베드 교체 완료")

	// DB 업데이트
	_, err = h.db.Exec(`
		UPDATE blog_posts SET
			title = $1,
			content = $2,
			excerpt = $3,
			keywords = $4,
			updated_at = NOW()
		WHERE id = $5
	`, regeneratedBlog.Title, regeneratedBlog.Content, regeneratedBlog.Excerpt,
		regeneratedBlog.Keywords, id)

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "블로그 업데이트 실패"})
		return
	}

	// 재생성된 블로그 자동 평가
	blogContent := gemini.BlogContent{
		Title:    regeneratedBlog.Title,
		Slug:     blog.Slug, // slug는 유지
		Content:  regeneratedBlog.Content,
		Excerpt:  regeneratedBlog.Excerpt,
		Keywords: regeneratedBlog.Keywords,
	}

	newEvaluation, err := gemini.EvaluateQuality(ctx, blogContent)
	if err != nil {
		// 재생성은 성공했지만 평가 실패
		c.JSON(http.StatusOK, gin.H{
			"success":         true,
			"message":         "블로그가 재생성되었습니다 (평가 실패)",
			"id":              id,
			"blog":            regeneratedBlog,
			"evaluation_error": err.Error(),
		})
		return
	}

	// 평가 결과 저장
	feedbackJSON, _ := json.Marshal(newEvaluation.Feedback)
	_, err = h.db.Exec(`
		UPDATE blog_posts SET
			theological_accuracy = $1,
			content_structure = $2,
			engagement = $3,
			technical_quality = $4,
			seo_optimization = $5,
			total_score = $6,
			quality_feedback = $7,
			evaluation_date = NOW(),
			evaluator = 'gemini-api-regenerated'
		WHERE id = $8
	`, newEvaluation.Scores.TheologicalAccuracy, newEvaluation.Scores.ContentStructure,
		newEvaluation.Scores.Engagement, newEvaluation.Scores.TechnicalQuality,
		newEvaluation.Scores.SeoOptimization, newEvaluation.TotalScore,
		feedbackJSON, id)

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "평가 결과 저장 실패"})
		return
	}

	// 발행 여부 판단
	canPublish, reason := gemini.ShouldPublish(newEvaluation)

	c.JSON(http.StatusOK, gin.H{
		"success":       true,
		"message":       "블로그가 재생성 및 평가되었습니다",
		"blog":          regeneratedBlog,
		"evaluation":    newEvaluation,
		"can_publish":   canPublish,
		"reason":        reason,
		"old_score":     *blog.TotalScore,
		"new_score":     newEvaluation.TotalScore,
		"improved":      newEvaluation.TotalScore > *blog.TotalScore,
	})
}

// extractHymnNumber 블로그 콘텐츠에서 찬송가 번호 추출
func extractHymnNumber(content string) int {
	// 패턴: "찬송가 123장", "### 찬송가 123장", "**찬송가 123장"
	patterns := []string{
		`찬송가\s*(\d+)장`,
		`찬송가\s*(\d+)\s*장`,
	}

	for _, pattern := range patterns {
		re := regexp.MustCompile(pattern)
		matches := re.FindStringSubmatch(content)
		if len(matches) > 1 {
			num, err := strconv.Atoi(matches[1])
			if err == nil && num > 0 && num <= 645 {
				return num
			}
		}
	}

	return 0
}
