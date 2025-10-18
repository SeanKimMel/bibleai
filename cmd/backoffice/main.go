package main

import (
	"log"
	"net/http"

	"bibleai/internal/backoffice"
	"bibleai/internal/database"

	"github.com/gin-gonic/gin"
)

func main() {
	// 데이터베이스 연결 (메인 API와 동일한 DB 사용)
	db, err := database.NewConnection()
	if err != nil {
		log.Fatalf("데이터베이스 연결 실패: %v", err)
	}
	defer db.Close()

	// Gin 설정
	gin.SetMode(gin.DebugMode)
	r := gin.Default()

	// HTML 템플릿 로드
	r.LoadHTMLGlob("web/backoffice/templates/*.html")

	// 정적 파일 (CSS, JS 등)
	r.Static("/static", "./web/static")

	// 백오피스 핸들러 초기화
	handlers := backoffice.NewHandlers(db.DB)

	// 헬스 체크
	r.GET("/health", func(c *gin.Context) {
		if err := db.Ping(); err != nil {
			c.JSON(http.StatusServiceUnavailable, gin.H{
				"status":   "unhealthy",
				"database": "disconnected",
			})
			return
		}

		c.JSON(http.StatusOK, gin.H{
			"status":   "healthy",
			"database": "connected",
		})
	})

	// 백오피스 웹 페이지
	r.GET("/", handlers.DashboardPage)
	r.GET("/blogs", handlers.BlogListPage)
	r.GET("/blogs/new", handlers.BlogNewPage)
	r.GET("/blogs/:id", handlers.BlogDetailPage)

	// 백오피스 API 엔드포인트
	api := r.Group("/api")
	{
		// 블로그 목록 (미발행 포함)
		api.GET("/blogs", handlers.GetBlogs)

		// 블로그 생성 (수동)
		api.POST("/blogs", handlers.CreateBlog)

		// 블로그 자동 생성 (Gemini API)
		api.POST("/blogs/generate", handlers.GenerateBlog)

		// 블로그 상세 조회
		api.GET("/blogs/:id", handlers.GetBlog)

		// 블로그 평가 점수 저장
		api.POST("/blogs/:id/evaluate", handlers.SaveEvaluation)

		// Gemini API로 블로그 품질 평가
		api.POST("/blogs/:id/gemini-evaluate", handlers.EvaluateBlog)

		// 블로그 재생성 (평가 피드백 기반)
		api.POST("/blogs/:id/regenerate", handlers.RegenerateBlog)

		// 블로그 평가 이력 조회
		api.GET("/blogs/:id/evaluation-history", handlers.GetEvaluationHistory)

		// 블로그 발행 토글
		api.POST("/blogs/:id/publish", handlers.TogglePublish)

		// 블로그 삭제
		api.DELETE("/blogs/:id", handlers.DeleteBlog)

		// 통계 조회
		api.GET("/stats", handlers.GetStats)
	}

	// 서버 시작 (포트 9090)
	port := ":9090"
	log.Printf("🚀 백오피스 서버 시작: http://localhost%s", port)
	if err := r.Run(port); err != nil {
		log.Fatalf("서버 시작 실패: %v", err)
	}
}
