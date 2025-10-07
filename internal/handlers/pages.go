package handlers

import (
	"database/sql"
	"fmt"
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
)

// 데이터베이스 연결을 저장할 변수
var db *sql.DB

// 데이터베이스 설정 함수
func SetDB(database *sql.DB) {
	db = database
}

// 메인 페이지 (키워드 메인)
func HomePage(c *gin.Context) {
	c.HTML(http.StatusOK, "bible-analysis.html", gin.H{
		"Title": "오늘의 키워드",
		"Description": "성경, 찬송가, 기도문을 키워드로 통합 검색하세요. 매일 업데이트되는 추천 키워드로 오늘 필요한 말씀을 찾아보세요.",
		"CurrentPath": c.Request.URL.Path,
		"ShowNavigation": true,
		"PageType": "bible-analysis",
		"CacheVersion": "4",
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
	baseURL := "https://bibleai.wiki"
	now := time.Now().Format("2006-01-02")

	sitemap := `<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9"
        xmlns:geo="http://www.google.com/geo/sitemap/1.0">
  <!-- 홈페이지 (최우선) -->
  <url>
    <loc>` + baseURL + `/</loc>
    <lastmod>` + now + `</lastmod>
    <changefreq>daily</changefreq>
    <priority>1.0</priority>
    <geo:geo>
      <geo:format>kml</geo:format>
    </geo:geo>
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
    <priority>0.8</priority>
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
</urlset>`

	c.Header("Content-Type", "application/xml; charset=utf-8")
	c.String(http.StatusOK, sitemap)
}