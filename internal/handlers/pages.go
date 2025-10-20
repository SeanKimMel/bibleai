package handlers

import (
	"database/sql"
	"fmt"
	"html/template"
	"net/http"
	"strings"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/russross/blackfriday/v2"
)

// 데이터베이스 연결을 저장할 변수
var db *sql.DB

// 데이터베이스 설정 함수
func SetDB(database *sql.DB) {
	db = database
}

// 메인 페이지 (블로그)
func HomePage(c *gin.Context) {
	// 첫 페이지 블로그 목록 조회 (SEO를 위한 SSR)
	limit := 10
	offset := 0

	// 전체 개수 조회
	var total int
	err := db.QueryRow("SELECT COUNT(*) FROM blog_posts WHERE is_published = true").Scan(&total)
	if err != nil {
		println("블로그 카운트 조회 에러:", err.Error())
	}
	println("전체 블로그 개수:", total)

	// 블로그 목록 조회
	rows, err := db.Query(`
		SELECT id, title, slug, excerpt, keywords, published_at, view_count
		FROM blog_posts
		WHERE is_published = true
		ORDER BY published_at DESC
		LIMIT $1 OFFSET $2
	`, limit, offset)

	posts := []map[string]interface{}{}
	if err == nil {
		defer rows.Close()
		for rows.Next() {
			var id, viewCount int
			var title, slug, excerpt, keywords, publishedAt string
			if err := rows.Scan(&id, &title, &slug, &excerpt, &keywords, &publishedAt, &viewCount); err == nil {
				posts = append(posts, map[string]interface{}{
					"id":           id,
					"title":        title,
					"slug":         slug,
					"excerpt":      excerpt,
					"keywords":     keywords,
					"published_at": publishedAt,
					"view_count":   viewCount,
				})
			}
		}
	} else {
		println("블로그 목록 조회 에러:", err.Error())
	}
	println("조회된 블로그 개수:", len(posts))

	// 페이지 정보
	totalPages := int((float64(total) + float64(limit) - 1) / float64(limit))

	c.HTML(http.StatusOK, "blog.html", gin.H{
		"Title":       "신앙 이야기",
		"Description": "매일 업데이트되는 묵상과 신앙 이야기를 나눕니다.",
		"CurrentPath": c.Request.URL.Path,
		"ShowBackButton": false,
		"ShowNavigation": true,
		"PageType":      "blog",
		// SSR을 위한 초기 데이터
		"Posts":      posts,
		"Total":      total,
		"TotalPages": totalPages,
		"HasNext":    1 < totalPages,
	})
}

// 성경 검색 페이지
func BibleSearchPage(c *gin.Context) {
	c.HTML(http.StatusOK, "bible-search.html", gin.H{
		"Title": "성경 검색",
		"Description": "키워드로 성경 구절을 빠르게 검색하세요. 66권 성경 전체에서 원하는 말씀을 찾을 수 있습니다.",
		"CurrentPath": c.Request.URL.Path,
		"ShowBackButton": true,
		"ShowNavigation": true,
		"PageType": "bible-search",
	})
}

// 오늘의 키워드 페이지
func BibleAnalysisPage(c *gin.Context) {
	c.HTML(http.StatusOK, "bible-analysis.html", gin.H{
		"Title": "오늘의 키워드",
		"Description": "성경, 찬송가, 기도문을 키워드로 통합 검색하세요. 매일 업데이트되는 추천 키워드로 오늘 필요한 말씀을 찾아보세요.",
		"CurrentPath": c.Request.URL.Path,
		"ShowBackButton": true,
		"ShowNavigation": true,
		"PageType": "bible-analysis",
	})
}

// 찬송가 페이지
func HymnsPage(c *gin.Context) {
	c.HTML(http.StatusOK, "hymns.html", gin.H{
		"Title": "찬송가",
		"Description": "새찬송가 645곡 전체를 검색하고 감상하세요. 가사, 주제별로 찬송가를 쉽게 찾을 수 있습니다.",
		"CurrentPath": c.Request.URL.Path,
		"ShowBackButton": true,
		"ShowNavigation": true,
		"PageType": "hymns",
	})
}

// 기도문 페이지
func PrayersPage(c *gin.Context) {
	println("PrayersPage handler called - rendering a-prayers.html")

	// 데이터베이스에서 태그 목록 조회
	tags, err := getTagsFromDB()
	if err != nil {
		// 에러 발생시 빈 태그 목록으로 처리하여 페이지는 정상 표시
		println("태그 조회 실패:", err.Error())
		tags = []map[string]interface{}{}
	}

	c.HTML(http.StatusOK, "a-prayers.html", gin.H{
		"Title": "기도문 찾기",
		"Description": "상황과 주제에 맞는 기도문을 태그로 찾아보세요. 새벽기도, 감사기도, 회개기도 등 다양한 기도문을 제공합니다.",
		"CurrentPath": c.Request.URL.Path,
		"ShowBackButton": true,
		"ShowNavigation": true,
		"PageType": "prayers",
		"Tags": tags,
		"CacheVersion": "3",
	})
}

// 블로그 페이지
func BlogPage(c *gin.Context) {
	// 첫 페이지 블로그 목록 조회 (SEO를 위한 SSR)
	limit := 10
	offset := 0

	// 전체 개수 조회
	var total int
	err := db.QueryRow("SELECT COUNT(*) FROM blog_posts WHERE is_published = true").Scan(&total)
	if err != nil {
		println("블로그 카운트 조회 에러:", err.Error())
	}
	println("전체 블로그 개수:", total)

	// 블로그 목록 조회
	rows, err := db.Query(`
		SELECT id, title, slug, excerpt, keywords, published_at, view_count
		FROM blog_posts
		WHERE is_published = true
		ORDER BY published_at DESC
		LIMIT $1 OFFSET $2
	`, limit, offset)

	posts := []map[string]interface{}{}
	if err == nil {
		defer rows.Close()
		for rows.Next() {
			var id, viewCount int
			var title, slug, excerpt, keywords, publishedAt string
			if err := rows.Scan(&id, &title, &slug, &excerpt, &keywords, &publishedAt, &viewCount); err == nil {
				posts = append(posts, map[string]interface{}{
					"id":           id,
					"title":        title,
					"slug":         slug,
					"excerpt":      excerpt,
					"keywords":     keywords,
					"published_at": publishedAt,
					"view_count":   viewCount,
				})
			}
		}
	} else {
		println("블로그 목록 조회 에러:", err.Error())
	}
	println("조회된 블로그 개수:", len(posts))

	// 페이지 정보
	totalPages := int((float64(total) + float64(limit) - 1) / float64(limit))

	c.HTML(http.StatusOK, "blog.html", gin.H{
		"Title":       "신앙 이야기",
		"Description": "매일 업데이트되는 묵상과 신앙 이야기를 나눕니다.",
		"CurrentPath": c.Request.URL.Path,
		"ShowBackButton": false,
		"ShowNavigation": true,
		"PageType":      "blog",
		// SSR을 위한 초기 데이터
		"Posts":      posts,
		"Total":      total,
		"TotalPages": totalPages,
		"HasNext":    1 < totalPages,
	})
}

// 블로그 상세 페이지
func BlogDetailPage(c *gin.Context) {
	slug := c.Param("slug")

	// 데이터베이스에서 블로그 글 조회
	var post struct {
		ID          int
		Title       string
		Slug        string
		Content     string
		ContentHTML template.HTML
		Excerpt     string
		Keywords    string
		PublishedAt time.Time
		ViewCount   int
	}

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
		c.HTML(http.StatusNotFound, "404.html", gin.H{
			"Title": "페이지를 찾을 수 없습니다",
		})
		return
	}

	if err != nil {
		c.HTML(http.StatusInternalServerError, "500.html", gin.H{
			"Title": "서버 오류",
		})
		return
	}

	// 마크다운 → HTML 변환
	htmlContent := blackfriday.Run([]byte(post.Content))
	post.ContentHTML = template.HTML(htmlContent)

	// 조회수 증가
	db.Exec("UPDATE blog_posts SET view_count = view_count + 1 WHERE id = $1", post.ID)

	// 키워드 리스트 생성
	var keywordList []string
	if post.Keywords != "" {
		keywordList = strings.Split(post.Keywords, ",")
		for i, k := range keywordList {
			keywordList[i] = strings.TrimSpace(k)
		}
	}

	// 날짜 포맷팅
	formattedDate := post.PublishedAt.Format("2006년 1월 2일")

	c.HTML(http.StatusOK, "blog_detail.html", gin.H{
		"Title":         post.Title,
		"Description":   post.Excerpt,
		"CurrentPath":   c.Request.URL.Path,
		"ShowBackButton": false,
		"ShowNavigation": true,
		"PageType":      "blog-detail",
		"Post":          post,
		"KeywordList":   keywordList,
		"FormattedDate": formattedDate,
	})
}

// 데이터베이스에서 태그 목록을 조회하는 헬퍼 함수
func getTagsFromDB() ([]map[string]interface{}, error) {
	if db == nil {
		return nil, fmt.Errorf("데이터베이스 연결이 없습니다")
	}

	rows, err := db.Query("SELECT id, name FROM tags ORDER BY name")
	if err != nil {
		return nil, fmt.Errorf("태그 쿼리 실행 실패: %v", err)
	}
	defer rows.Close()

	var tags []map[string]interface{}
	for rows.Next() {
		var id int
		var name string
		if err := rows.Scan(&id, &name); err != nil {
			continue // 개별 행 스캔 에러는 건너뛰고 계속 진행
		}
		tags = append(tags, map[string]interface{}{
			"ID": id,
			"Name": name,
		})
	}

	return tags, nil
}

// SEO: Sitemap.xml 동적 생성 핸들러
func GenerateSitemap(c *gin.Context) {
	baseURL := "https://haruinfo.net"
	now := time.Now().Format("2006-01-02")

	// 정적 페이지들
	sitemap := `<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
  <!-- 홈페이지 (블로그) - 최우선 -->
  <url>
    <loc>` + baseURL + `/</loc>
    <lastmod>` + now + `</lastmod>
    <changefreq>daily</changefreq>
    <priority>1.0</priority>
  </url>

  <!-- 블로그 목록 -->
  <url>
    <loc>` + baseURL + `/blog</loc>
    <lastmod>` + now + `</lastmod>
    <changefreq>daily</changefreq>
    <priority>1.0</priority>
  </url>

  <!-- 성경 검색 -->
  <url>
    <loc>` + baseURL + `/bible/search</loc>
    <lastmod>` + now + `</lastmod>
    <changefreq>weekly</changefreq>
    <priority>0.9</priority>
  </url>

  <!-- 오늘의 키워드 -->
  <url>
    <loc>` + baseURL + `/bible/analysis</loc>
    <lastmod>` + now + `</lastmod>
    <changefreq>daily</changefreq>
    <priority>0.7</priority>
  </url>

  <!-- 찬송가 -->
  <url>
    <loc>` + baseURL + `/hymns</loc>
    <lastmod>` + now + `</lastmod>
    <changefreq>weekly</changefreq>
    <priority>0.8</priority>
  </url>

  <!-- 기도문 -->
  <url>
    <loc>` + baseURL + `/prayers</loc>
    <lastmod>` + now + `</lastmod>
    <changefreq>weekly</changefreq>
    <priority>0.8</priority>
  </url>
`

	// 블로그 포스트들 동적 추가
	if db != nil {
		rows, err := db.Query(`
			SELECT slug, published_at, updated_at
			FROM blog_posts
			WHERE is_published = true
			ORDER BY published_at DESC
		`)
		if err == nil {
			defer rows.Close()

			for rows.Next() {
				var slug string
				var publishedAt, updatedAt time.Time
				if err := rows.Scan(&slug, &publishedAt, &updatedAt); err == nil {
					lastmod := updatedAt
					if lastmod.IsZero() {
						lastmod = publishedAt
					}

					sitemap += `
  <!-- 블로그: ` + slug + ` -->
  <url>
    <loc>` + baseURL + `/blog/` + slug + `</loc>
    <lastmod>` + lastmod.Format("2006-01-02") + `</lastmod>
    <changefreq>monthly</changefreq>
    <priority>0.7</priority>
  </url>
`
				}
			}
		}
	}

	sitemap += `</urlset>`

	c.Header("Content-Type", "application/xml; charset=utf-8")
	c.String(http.StatusOK, sitemap)
}