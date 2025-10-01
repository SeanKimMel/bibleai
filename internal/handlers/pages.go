package handlers

import (
	"database/sql"
	"fmt"
	"net/http"

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
		"ShowNavigation": true,
		"PageType": "bible-analysis",
		"CacheVersion": "4",
	})
}

// 성경 검색 페이지
func BibleSearchPage(c *gin.Context) {
	c.HTML(http.StatusOK, "bible-search.html", gin.H{
		"Title": "성경 검색",
		"ShowBackButton": true,
		"ShowNavigation": true,
		"PageType": "bible-search",
	})
}

// 오늘의 키워드 페이지
func BibleAnalysisPage(c *gin.Context) {
	c.HTML(http.StatusOK, "bible-analysis.html", gin.H{
		"Title": "오늘의 키워드",
		"ShowBackButton": true,
		"ShowNavigation": true,
		"PageType": "bible-analysis",
	})
}

// 찬송가 페이지
func HymnsPage(c *gin.Context) {
	c.HTML(http.StatusOK, "hymns.html", gin.H{
		"Title": "찬송가",
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