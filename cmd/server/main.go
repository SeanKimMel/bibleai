package main

import (
	"log"
	"net/http"

	"bibleai/internal/database"
	"bibleai/internal/handlers"
	"bibleai/internal/static"

	"github.com/gin-gonic/gin"
)

func main() {
	// 데이터베이스 연결
	db, err := database.NewConnection()
	if err != nil {
		log.Fatalf("데이터베이스 연결 실패: %v", err)
	}
	defer db.Close()

	// 템플릿 캐시 방지를 위해 개발 모드 설정
	gin.SetMode(gin.DebugMode)
	r := gin.Default()

	// HTML 템플릿을 글로빙 패턴으로 효율적 로드
	r.LoadHTMLGlob("web/templates/**/*.html")

	// 파비콘 라우트 (embed로 바이너리에 포함) - 정적 파일 서빙보다 먼저 등록
	r.GET("/favicon.ico", func(c *gin.Context) {
		c.Data(http.StatusOK, "image/x-icon", static.FaviconIco)
	})

	// SEO: robots.txt (embed로 바이너리에 포함) - 정적 파일 서빙보다 먼저 등록
	r.GET("/robots.txt", func(c *gin.Context) {
		c.String(http.StatusOK, static.RobotsTxt)
	})

	// 정적 파일 서빙
	r.Static("/static", "./web/static")

	// 웹 페이지 라우트
	r.GET("/", handlers.HomePage)
	r.GET("/bible/search", handlers.BibleSearchPage)
	r.GET("/bible/analysis", handlers.BibleAnalysisPage)
	r.GET("/hymns", handlers.HymnsPage)
	r.GET("/prayers", handlers.PrayersPage)
	r.GET("/blog", handlers.BlogPage)
	r.GET("/blog/:slug", handlers.BlogDetailPage)

	// SEO: sitemap.xml (동적 생성)
	r.GET("/sitemap.xml", handlers.GenerateSitemap)
	
	// 테스트 페이지
	r.StaticFile("/test/bible-search", "./test_bible_search.html")
	
	// 데이터베이스 핸들러에 전달
	handlers.SetDB(db.DB)
	
	// 찬송가 핸들러 초기화
	hymnHandlers := handlers.NewHymnHandlers(db.DB)

	// 서버 시작 시 키워드 카운트 업데이트
	log.Println("키워드 카운트를 업데이트합니다...")
	if _, err := db.DB.Exec("SELECT update_keyword_counts()"); err != nil {
		log.Printf("키워드 카운트 업데이트 실패: %v", err)
	} else {
		log.Println("키워드 카운트 업데이트 완료")
	}
	
	// API 라우트
	r.GET("/api/status", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{
			"message": "주님말씀AI 웹앱에 오신 것을 환영합니다!",
			"status":  "running",
			"database": "connected",
		})
	})
	
	// 헬스 체크
	r.GET("/health", func(c *gin.Context) {
		// 데이터베이스 연결 확인
		if err := db.Ping(); err != nil {
			c.JSON(http.StatusServiceUnavailable, gin.H{
				"status": "unhealthy", 
				"database": "disconnected",
			})
			return
		}
		
		c.JSON(http.StatusOK, gin.H{
			"status": "healthy",
			"database": "connected",
		})
	})
	
	// 태그 목록 조회 (테스트용)
	r.GET("/api/tags", func(c *gin.Context) {
		rows, err := db.Query("SELECT id, name, description FROM tags ORDER BY name")
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "태그 조회 실패"})
			return
		}
		defer rows.Close()

		var tags []map[string]interface{}
		for rows.Next() {
			var id int
			var name, description string
			if err := rows.Scan(&id, &name, &description); err != nil {
				continue
			}
			tags = append(tags, map[string]interface{}{
				"id": id,
				"name": name,
				"description": description,
			})
		}

		c.JSON(http.StatusOK, gin.H{"tags": tags})
	})

	// 기도문 API 엔드포인트
	r.POST("/api/prayers", handlers.CreatePrayer)                // 기도문 생성
	r.GET("/api/prayers", handlers.GetAllPrayers)                // 모든 기도문 조회
	r.GET("/api/prayers/search", handlers.SearchPrayers)         // 키워드로 기도문 검색
	r.GET("/api/prayers/by-tags", handlers.GetPrayersByTags)     // 태그별 기도문 조회
	r.POST("/api/prayers/:id/tags", handlers.AddTagsToPrayer)    // 기도문에 태그 추가
	
	// 성경 데이터 import API 엔드포인트
	r.POST("/api/admin/import/bible", handlers.ImportBibleData)         // 성경 데이터 전체 import
	r.GET("/api/admin/import/bible/progress", handlers.GetImportProgress) // import 진행상황 조회
	r.GET("/api/admin/bible/stats", handlers.GetBibleStats)             // 성경 데이터 통계
	r.POST("/api/admin/fix-bible-books", handlers.FixBibleBooksMapping) // 성경책 매핑 수정

	// 성경 챕터 주제 관련 API
	r.POST("/api/admin/create-chapter-themes-table", handlers.CreateChapterThemesTable) // 챕터 주제 테이블 생성
	r.POST("/api/admin/analyze-chapter-themes", handlers.AnalyzeAndPopulateChapterThemes) // 챕터 주제 분석 및 삽입
	r.GET("/api/bible/search", handlers.SearchBible)                    // 성경 검색 (구절 단위)
	r.GET("/api/bible/search/chapters", handlers.SearchBibleByChapter)  // 성경 검색 (챕터 단위)
	r.GET("/api/bible/books", handlers.GetBibleBooks)                   // 성경책 목록 조회
	r.GET("/api/bible/books/:book/chapters", handlers.GetBibleBookChapters) // 성경책 장 목록 조회
	r.GET("/api/bible/chapters/:book/:chapter", handlers.GetBibleChapter) // 특정 장 읽기
	r.GET("/api/bible/chapters/:book/:chapter/themes", handlers.GetChapterSummary) // 특정 장의 주제 요약
	r.GET("/api/verses/by-tag/:tag", handlers.GetVersesByTag)           // 태그별 성경 구절 조회
	
	// 찬송가 API 엔드포인트
	r.GET("/api/hymns/search", hymnHandlers.SearchHymns)          // 찬송가 검색
	r.GET("/api/hymns/:number", hymnHandlers.GetHymnByNumber)     // 특정 번호 찬송가 조회
	r.GET("/api/hymns/theme/:theme", hymnHandlers.GetHymnsByTheme) // 주제별 찬송가 조회
	r.GET("/api/hymns/themes", hymnHandlers.GetHymnThemes)        // 모든 주제 목록 조회
	r.GET("/api/hymns/random", hymnHandlers.GetRandomHymns)       // 랜덤 찬송가 조회
	r.POST("/api/admin/import/hymns", hymnHandlers.ImportHymnsData) // 찬송가 데이터 Import

	// 키워드 관련 API 엔드포인트
	r.POST("/api/admin/create-keyword-tables", handlers.CreateKeywordTables)    // 키워드 테이블 생성
	r.POST("/api/admin/populate-keywords", handlers.PopulateInitialKeywords)    // 초기 키워드 데이터 삽입
	r.GET("/api/keywords", handlers.GetAllKeywords)                            // 모든 키워드 조회
	r.GET("/api/keywords/featured", handlers.GetFeaturedKeywords)              // 추천 키워드 조회 (메인 페이지용)
	r.POST("/api/admin/update-keyword-counts", handlers.UpdateKeywordCounts)   // 키워드 카운트 업데이트
	r.GET("/api/keywords/:keyword/counts", handlers.GetKeywordContentCounts)   // 키워드별 콘텐츠 개수

	// 블로그 API 엔드포인트
	r.POST("/api/admin/blog/posts", handlers.CreateBlogPost)                    // 블로그 생성 (관리자)
	r.GET("/api/blog/posts", handlers.GetBlogPosts)                             // 블로그 목록 (페이지네이션)
	r.GET("/api/blog/posts/:slug", handlers.GetBlogPost)                        // 블로그 상세
	r.GET("/api/admin/blog/posts/:id", handlers.GetBlogPostByID)                // 블로그 ID 기반 조회 (관리자)
	r.PUT("/api/admin/blog/posts/:id", handlers.UpdateBlogPost)                 // 블로그 수정 (관리자)
	r.DELETE("/api/admin/blog/posts/:id", handlers.DeleteBlogPost)              // 블로그 소프트 삭제 (관리자)
	r.POST("/api/admin/blog/posts/:id/evaluate", handlers.EvaluateBlogPost)     // 블로그 품질 평가 (관리자)
	r.GET("/api/admin/blog/posts/:id/quality-history", handlers.GetBlogQualityHistory) // 품질 평가 이력 조회
	r.GET("/api/admin/blog/generate-data", handlers.GenerateBlogData)           // 블로그 자동 생성용 데이터 수집

	log.Println("서버가 :8080 포트에서 시작됩니다...")
	r.Run("0.0.0.0:8080")
}