package handlers

import (
	"bytes"
	"database/sql"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"strconv"
	"time"

	"github.com/gin-gonic/gin"
)

// BibleBook 성경책 구조체 (GitHub API 구조에 맞춤)
type BibleBook struct {
	ID       string     `json:"id"`
	Chapters [][]string `json:"chapters"` // 각 장은 문자열 배열(구절들)
}

// ImportProgress Import 진행상황
type ImportProgress struct {
	TotalBooks     int    `json:"total_books"`
	CompletedBooks int    `json:"completed_books"`
	CurrentBook    string `json:"current_book"`
	Status         string `json:"status"`
	StartTime      string `json:"start_time"`
	Errors         []string `json:"errors,omitempty"`
}

var importProgress ImportProgress

// ImportBibleData 성경 데이터 전체 Import API
// POST /api/admin/import/bible
func ImportBibleData(c *gin.Context) {
	// 이미 진행 중인 import가 있는지 확인
	if importProgress.Status == "running" {
		c.JSON(http.StatusConflict, gin.H{
			"error": "Import already in progress",
			"progress": importProgress,
		})
		return
	}

	// 진행상황 초기화
	importProgress = ImportProgress{
		Status:    "running",
		StartTime: time.Now().Format("2006-01-02 15:04:05"),
		Errors:    []string{},
	}

	// 백그라운드에서 import 실행
	go func() {
		err := performBibleImport()
		if err != nil {
			importProgress.Status = "failed"
			importProgress.Errors = append(importProgress.Errors, err.Error())
		} else {
			importProgress.Status = "completed"
		}
	}()

	c.JSON(http.StatusOK, gin.H{
		"message": "Bible import started",
		"progress": importProgress,
	})
}

// GetImportProgress Import 진행상황 조회 API
// GET /api/admin/import/bible/progress
func GetImportProgress(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{
		"progress": importProgress,
	})
}

// performBibleImport 실제 성경 데이터 import 실행
func performBibleImport() error {
	// GitHub API에서 한국어 성경 전체 데이터 가져오기
	url := "https://raw.githubusercontent.com/MaatheusGois/bible/main/versions/ko/ko.json"
	
	importProgress.CurrentBook = "데이터 다운로드 중..."
	
	resp, err := http.Get(url)
	if err != nil {
		return fmt.Errorf("failed to fetch Bible data: %v", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return fmt.Errorf("failed to fetch Bible data: status %d", resp.StatusCode)
	}

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return fmt.Errorf("failed to read response body: %v", err)
	}

	// UTF-8 BOM 제거
	body = bytes.TrimPrefix(body, []byte{0xEF, 0xBB, 0xBF})

	var bibleData []BibleBook
	if err := json.Unmarshal(body, &bibleData); err != nil {
		return fmt.Errorf("failed to parse Bible JSON: %v", err)
	}

	importProgress.TotalBooks = len(bibleData)
	importProgress.CurrentBook = "데이터베이스 저장 중..."

	// 트랜잭션 시작
	tx, err := db.Begin()
	if err != nil {
		return fmt.Errorf("failed to start transaction: %v", err)
	}
	defer tx.Rollback()

	// 기존 성경 데이터 삭제 (전체 재import)
	_, err = tx.Exec("DELETE FROM bible_verses WHERE version = 'KOR'")
	if err != nil {
		return fmt.Errorf("failed to clear existing Bible data: %v", err)
	}

	// 성경책 메타데이터 조회 (book_id -> book_name 매핑)
	bookNamesMap := make(map[string]string)
	rows, err := tx.Query("SELECT book_id, book_name FROM bible_books")
	if err != nil {
		return fmt.Errorf("failed to get book names: %v", err)
	}
	for rows.Next() {
		var bookId, bookName string
		if err := rows.Scan(&bookId, &bookName); err != nil {
			continue
		}
		bookNamesMap[bookId] = bookName
	}
	rows.Close()

	// 성경책별로 데이터 저장
	for bookIndex, book := range bibleData {
		importProgress.CompletedBooks = bookIndex
		
		// 책 이름 가져오기
		bookName, exists := bookNamesMap[book.ID]
		if !exists {
			bookName = book.ID // 기본값으로 ID 사용
		}
		importProgress.CurrentBook = bookName

		// 구약/신약 구분
		testament := "old"
		if bookIndex >= 39 { // 39번째부터 신약
			testament = "new"
		}

		// 각 장별로 처리
		for chapterIndex, chapter := range book.Chapters {
			chapterNumber := chapterIndex + 1 // 1부터 시작
			
			// 각 구절별로 처리
			for verseIndex, verseText := range chapter {
				verseNumber := verseIndex + 1 // 1부터 시작
				
				_, err = tx.Exec(`
					INSERT INTO bible_verses (book, book_id, chapter, verse, content, version, testament, book_name_korean)
					VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
				`, bookName, book.ID, chapterNumber, verseNumber, verseText, "KOR", testament, bookName)

				if err != nil {
					importError := fmt.Sprintf("Failed to insert verse %s %d:%d - %v", bookName, chapterNumber, verseNumber, err)
					importProgress.Errors = append(importProgress.Errors, importError)
					continue
				}
			}
		}

		// 진행상황 업데이트
		time.Sleep(10 * time.Millisecond) // API 과부하 방지 (더 빠르게)
	}

	// 트랜잭션 커밋
	if err = tx.Commit(); err != nil {
		return fmt.Errorf("failed to commit transaction: %v", err)
	}

	importProgress.CompletedBooks = importProgress.TotalBooks
	importProgress.CurrentBook = "완료"

	return nil
}

// GetBibleStats 성경 데이터 통계 API
// GET /api/admin/bible/stats
func GetBibleStats(c *gin.Context) {
	stats := struct {
		TotalBooks    int `json:"total_books"`
		TotalChapters int `json:"total_chapters"`  
		TotalVerses   int `json:"total_verses"`
		OldTestament  int `json:"old_testament_books"`
		NewTestament  int `json:"new_testament_books"`
	}{}

	// 총 책 수
	err := db.QueryRow("SELECT COUNT(DISTINCT book) FROM bible_verses WHERE version = 'KOR'").Scan(&stats.TotalBooks)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to get book count"})
		return
	}

	// 총 장 수  
	err = db.QueryRow("SELECT COUNT(DISTINCT book || '-' || chapter) FROM bible_verses WHERE version = 'KOR'").Scan(&stats.TotalChapters)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to get chapter count"})
		return
	}

	// 총 구절 수
	err = db.QueryRow("SELECT COUNT(*) FROM bible_verses WHERE version = 'KOR'").Scan(&stats.TotalVerses)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to get verse count"})
		return
	}

	// 구약/신약 구분
	err = db.QueryRow("SELECT COUNT(DISTINCT book) FROM bible_verses WHERE version = 'KOR' AND testament = 'old'").Scan(&stats.OldTestament)
	if err != nil {
		stats.OldTestament = 0
	}

	err = db.QueryRow("SELECT COUNT(DISTINCT book) FROM bible_verses WHERE version = 'KOR' AND testament = 'new'").Scan(&stats.NewTestament)  
	if err != nil {
		stats.NewTestament = 0
	}

	c.JSON(http.StatusOK, gin.H{
		"stats": stats,
	})
}

// GetBibleChapter 특정 성경책의 특정 장의 모든 구절을 조회
// GET /api/bible/chapters/:book/:chapter
func GetBibleChapter(c *gin.Context) {
	book := c.Param("book")
	chapterStr := c.Param("chapter")

	if book == "" || chapterStr == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Book and chapter are required"})
		return
	}

	// chapter를 정수로 변환
	chapter, err := strconv.Atoi(chapterStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid chapter number"})
		return
	}

	if db == nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Database connection not initialized"})
		return
	}

	// 해당 장의 모든 구절과 해석 데이터를 verse 순서로 조회
	query := `
		SELECT bv.book_id, bv.chapter, bv.verse, bv.content,
		       COALESCE(bb.book_name, bv.book_name_korean, bv.book_id) as book_name,
		       bv.testament,
		       bv.chapter_title, bv.chapter_summary, bv.chapter_themes,
		       bv.chapter_context, bv.chapter_application
		FROM bible_verses bv
		LEFT JOIN bible_books bb ON bv.book_id = bb.book_id
		WHERE bv.book_id = $1 AND bv.chapter = $2
		ORDER BY bv.verse ASC
	`
	
	rows, err := db.Query(query, book, chapter)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to query verses"})
		return
	}
	defer rows.Close()

	var verses []map[string]interface{}
	var bookName string
	var testament string
	var commentary map[string]interface{}

	for rows.Next() {
		var bookId string
		var chap, verse int
		var content, name, test string
		var chapterTitle, chapterSummary, chapterThemes, chapterContext, chapterApplication *string

		if err := rows.Scan(&bookId, &chap, &verse, &content, &name, &test,
			&chapterTitle, &chapterSummary, &chapterThemes, &chapterContext, &chapterApplication); err != nil {
			continue
		}

		if bookName == "" {
			bookName = name
			testament = test
		}

		// 첫 번째 구절(verse=1)에서 해석 데이터 추출
		if verse == 1 && commentary == nil {
			if chapterTitle != nil || chapterSummary != nil {
				commentary = map[string]interface{}{
					"title":       chapterTitle,
					"summary":     chapterSummary,
					"themes":      chapterThemes,
					"context":     chapterContext,
					"application": chapterApplication,
				}
			}
		}

		verses = append(verses, map[string]interface{}{
			"verse":   verse,
			"content": content,
		})
	}

	if len(verses) == 0 {
		c.JSON(http.StatusNotFound, gin.H{"error": "Chapter not found"})
		return
	}

	// 이전/다음 장 정보 가져오기
	var prevChapter, nextChapter *int
	
	// 이전 장 확인
	var prevChap int
	prevQuery := `
		SELECT DISTINCT chapter FROM bible_verses 
		WHERE book_id = $1 AND chapter < $2 
		ORDER BY chapter DESC LIMIT 1
	`
	if err := db.QueryRow(prevQuery, book, chapter).Scan(&prevChap); err == nil {
		prevChapter = &prevChap
	}
	
	// 다음 장 확인  
	var nextChap int
	nextQuery := `
		SELECT DISTINCT chapter FROM bible_verses 
		WHERE book_id = $1 AND chapter > $2 
		ORDER BY chapter ASC LIMIT 1
	`
	if err := db.QueryRow(nextQuery, book, chapter).Scan(&nextChap); err == nil {
		nextChapter = &nextChap
	}

	response := gin.H{
		"book":           book,
		"book_name":      bookName,
		"testament":      testament,
		"chapter":        chapter,
		"verses":         verses,
		"total_verses":   len(verses),
		"prev_chapter":   prevChapter,
		"next_chapter":   nextChapter,
	}

	// 해석 데이터가 있으면 추가
	if commentary != nil {
		response["commentary"] = commentary
	}

	c.JSON(http.StatusOK, response)
}

// SearchBible 성경 검색 API
// GET /api/bible/search?q=사랑&book=요한복음&chapter=3
func SearchBible(c *gin.Context) {
	query := c.Query("q")
	if query == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Search query is required"})
		return
	}

	book := c.Query("book")
	chapter := c.Query("chapter")

	// 동적 SQL 쿼리 구성 (한글 책 이름 포함)
	sqlQuery := `
		SELECT bv.book_id, bv.chapter, bv.verse, bv.content,
		       COALESCE(bb.book_name, bv.book_name_korean, bv.book_id) as book_name
		FROM bible_verses bv
		LEFT JOIN bible_books bb ON bv.book_id = bb.book_id
		WHERE bv.version = 'KOR' AND bv.content ILIKE $1
	`
	args := []interface{}{"%" + query + "%"}

	if book != "" {
		sqlQuery += " AND bv.book_id = $" + strconv.Itoa(len(args)+1)
		args = append(args, book)
	}

	if chapter != "" {
		chapterNum, err := strconv.Atoi(chapter)
		if err == nil {
			sqlQuery += " AND bv.chapter = $" + strconv.Itoa(len(args)+1)
			args = append(args, chapterNum)
		}
	}

	sqlQuery += " ORDER BY bv.book_id, bv.chapter, bv.verse LIMIT 100"

	rows, err := db.Query(sqlQuery, args...)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Search failed"})
		return
	}
	defer rows.Close()

	var results []map[string]interface{}
	for rows.Next() {
		var book, content, bookName string
		var chapter, verse int

		err := rows.Scan(&book, &chapter, &verse, &content, &bookName)
		if err != nil {
			continue
		}

		results = append(results, map[string]interface{}{
			"book":      book,
			"book_name": bookName,
			"chapter":   chapter,
			"verse":     verse,
			"content":   content,
		})
	}

	c.JSON(http.StatusOK, gin.H{
		"query":   query,
		"results": results,
		"total":   len(results),
	})
}

// GetBibleBooks 성경책 목록 조회 API
// GET /api/bible/books
func GetBibleBooks(c *gin.Context) {
	// 실제로 import된 성경책 데이터를 기반으로 조회
	rows, err := db.Query(`
		SELECT DISTINCT 
			bv.book_id, 
			COALESCE(bb.book_name, bv.book_name_korean, bv.book_id) as book_name,
			bv.testament,
			COALESCE(bb.book_order, 999) as book_order
		FROM bible_verses bv
		LEFT JOIN bible_books bb ON bv.book_id = bb.book_id
		WHERE bv.version = 'KOR'
		ORDER BY book_order, bv.book_id
	`)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to get bible books"})
		return
	}
	defer rows.Close()

	type BookInfo struct {
		ID        string `json:"id"`
		Name      string `json:"name"`
		Testament string `json:"testament"`
		Order     int    `json:"order"`
	}

	var oldBooks []BookInfo
	var newBooks []BookInfo

	for rows.Next() {
		var book BookInfo
		err := rows.Scan(&book.ID, &book.Name, &book.Testament, &book.Order)
		if err != nil {
			continue
		}

		if book.Testament == "old" {
			oldBooks = append(oldBooks, book)
		} else {
			newBooks = append(newBooks, book)
		}
	}

	c.JSON(http.StatusOK, gin.H{
		"old_testament": oldBooks,
		"new_testament": newBooks,
		"total": len(oldBooks) + len(newBooks),
	})
}

// FixBibleBooksMapping 성경책 한글 이름 매핑 수정
// POST /api/admin/fix-bible-books
func FixBibleBooksMapping(c *gin.Context) {
	// 성경책 코드와 한글 이름 매핑
	bookMapping := map[string]string{
		// 구약성경
		"gn": "창세기", "ex": "출애굽기", "lv": "레위기", "nm": "민수기", "dt": "신명기",
		"js": "여호수아", "jud": "사사기", "rt": "룻기", "1sm": "사무엘상", "2sm": "사무엘하",
		"1kgs": "열왕기상", "2kgs": "열왕기하", "1ch": "역대상", "2ch": "역대하",
		"ezr": "에스라", "ne": "느헤미야", "et": "에스더", "job": "욥기", "ps": "시편",
		"prv": "잠언", "ec": "전도서", "so": "아가", "is": "이사야", "jr": "예레미야",
		"lm": "예레미야애가", "ez": "에스겔", "dn": "다니엘", "ho": "호세아", "jl": "요엘",
		"am": "아모스", "ob": "오바댜", "jn": "요나", "mi": "미가", "na": "나훔",
		"hk": "하박국", "zp": "스바냐", "hg": "학개", "zc": "스가랴", "ml": "말라기",
		
		// 신약성경
		"mt": "마태복음", "mk": "마가복음", "lk": "누가복음", "jo": "요한복음",
		"act": "사도행전", "rm": "로마서", "1co": "고린도전서", "2co": "고린도후서",
		"gl": "갈라디아서", "eph": "에베소서", "ph": "빌립보서", "cl": "골로새서",
		"1ts": "데살로니가전서", "2ts": "데살로니가후서", "1tm": "디모데전서", "2tm": "디모데후서",
		"tt": "디도서", "phm": "빌레몬서", "hb": "히브리서", "jm": "야고보서",
		"1pe": "베드로전서", "2pe": "베드로후서", "1jo": "요한일서", "2jo": "요한이서",
		"3jo": "요한삼서", "jd": "유다서", "re": "요한계시록",
	}

	// 트랜잭션 시작
	tx, err := db.Begin()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to start transaction"})
		return
	}
	defer tx.Rollback()

	// bible_verses 테이블의 book_name_korean 필드 업데이트
	updateCount := 0
	for bookId, koreanName := range bookMapping {
		result, err := tx.Exec(`
			UPDATE bible_verses 
			SET book_name_korean = $1 
			WHERE book_id = $2 AND version = 'KOR'
		`, koreanName, bookId)
		
		if err != nil {
			continue
		}
		
		if rowsAffected, err := result.RowsAffected(); err == nil && rowsAffected > 0 {
			updateCount++
		}
	}

	// bible_books 테이블도 업데이트 (존재하는 경우)
	for bookId, koreanName := range bookMapping {
		tx.Exec(`
			INSERT INTO bible_books (book_id, book_name, book_order) 
			VALUES ($1, $2, 999)
			ON CONFLICT (book_id) 
			DO UPDATE SET book_name = $2
		`, bookId, koreanName)
	}

	// 커밋
	if err = tx.Commit(); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to commit transaction"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "Bible books mapping updated successfully",
		"updated_books": updateCount,
		"total_mappings": len(bookMapping),
	})
}

// GetBibleBookChapters 특정 성경책의 장 목록 조회
// GET /api/bible/books/:book/chapters
func GetBibleBookChapters(c *gin.Context) {
	book := c.Param("book")
	if book == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Book parameter is required"})
		return
	}

	if db == nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Database connection not initialized"})
		return
	}

	// 해당 책의 장 목록을 조회
	query := `
		SELECT DISTINCT chapter, 
		       COALESCE(bb.book_name, bv.book_name_korean, bv.book_id) as book_name
		FROM bible_verses bv
		LEFT JOIN bible_books bb ON bv.book_id = bb.book_id
		WHERE bv.book_id = $1 AND bv.version = 'KOR'
		ORDER BY chapter ASC
	`
	
	rows, err := db.Query(query, book)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to query chapters"})
		return
	}
	defer rows.Close()

	var chapters []int
	var bookName string
	
	for rows.Next() {
		var chapter int
		var name string
		
		if err := rows.Scan(&chapter, &name); err != nil {
			continue
		}
		
		if bookName == "" {
			bookName = name
		}
		
		chapters = append(chapters, chapter)
	}

	if len(chapters) == 0 {
		c.JSON(http.StatusNotFound, gin.H{"error": "Book not found"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"book":         book,
		"book_name":    bookName,
		"chapters":     chapters,
		"total_chapters": len(chapters),
		"max_chapter":  chapters[len(chapters)-1],
	})
}

// GetVersesByTag 특정 태그와 관련된 성경 구절들 조회
// GET /api/verses/by-tag/:tag
func GetVersesByTag(c *gin.Context) {
	tag := c.Param("tag")
	if tag == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Tag parameter is required"})
		return
	}

	if db == nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Database connection not initialized"})
		return
	}

	// 태그별 대표 성경 구절 매핑 (하드코딩으로 시작, 추후 DB로 이동)
	verseMapping := map[string][]map[string]interface{}{
		"감사": {
			{"book": "ps", "book_name": "시편", "chapter": 100, "verse": 4, "content": "감사함으로 그의 문에 들어가며 찬송함으로 그의 궁정에 들어가서 그에게 감사하며 그의 이름을 송축할지어다"},
			{"book": "1ts", "book_name": "데살로니가전서", "chapter": 5, "verse": 18, "content": "범사에 감사하라 이것이 그리스도 예수 안에서 너희를 향하신 하나님의 뜻이니라"},
			{"book": "eph", "book_name": "에베소서", "chapter": 5, "verse": 20, "content": "범사에 우리 주 예수 그리스도의 이름으로 항상 아버지 하나님께 감사하며"},
		},
		"위로": {
			{"book": "ps", "book_name": "시편", "chapter": 23, "verse": 4, "content": "내가 사망의 음침한 골짜기로 다닐지라도 해를 두려워하지 않을 것은 주께서 나와 함께 하심이라 주의 지팡이와 막대기가 나를 안위하시나이다"},
			{"book": "mt", "book_name": "마태복음", "chapter": 11, "verse": 28, "content": "수고하고 무거운 짐 진 자들아 다 내게로 오라 내가 너희를 쉬게 하리라"},
			{"book": "2co", "book_name": "고린도후서", "chapter": 1, "verse": 3, "content": "찬송하리로다 그는 우리 주 예수 그리스도의 하나님이시요 자비의 아버지시요 모든 위로의 하나님이시며"},
		},
		"용기": {
			{"book": "js", "book_name": "여호수아", "chapter": 1, "verse": 9, "content": "내가 네게 명령한 것이 아니냐 강하고 담대하라 두려워하지 말며 놀라지 말라 네가 어디로 가든지 네 하나님 여호와가 너와 함께 하느니라"},
			{"book": "ph", "book_name": "빌립보서", "chapter": 4, "verse": 13, "content": "내게 능력 주시는 자 안에서 내가 모든 것을 할 수 있느니라"},
			{"book": "dt", "book_name": "신명기", "chapter": 31, "verse": 6, "content": "강하고 담대하라 그들을 두려워하지 말라 그들 앞에서 떨지 말라 네 하나님 여호와께서 친히 너와 함께 가시며"},
		},
		"회개": {
			{"book": "1jo", "book_name": "요한일서", "chapter": 1, "verse": 9, "content": "만일 우리가 우리 죄를 자백하면 그는 미쁘시고 의로우사 우리 죄를 사하시며 우리를 모든 불의에서 깨끗하게 하실 것이요"},
			{"book": "ps", "book_name": "시편", "chapter": 51, "verse": 10, "content": "하나님이여 내 속에 정한 마음을 창조하시고 내 안에 정직한 영을 새롭게 하소서"},
			{"book": "act", "book_name": "사도행전", "chapter": 3, "verse": 19, "content": "그러므로 너희가 회개하고 돌이켜 너희 죄 없이 함을 받으라 이같이 하면 새롭게 되는 날이 주 앞으로부터 이를 것이요"},
		},
		"치유": {
			{"book": "jr", "book_name": "예레미야", "chapter": 17, "verse": 14, "content": "여호와여 주께서 나를 고치시면 내가 낫겠사오니 나를 구원하시면 내가 구원을 얻으리이다 주는 나의 찬송이시니이다"},
			{"book": "ps", "book_name": "시편", "chapter": 147, "verse": 3, "content": "상심한 자들을 고치시며 그들의 상처를 싸매시는도다"},
			{"book": "ml", "book_name": "말라기", "chapter": 4, "verse": 2, "content": "내 이름을 경외하는 너희에게는 공의로운 해가 떠올라서 치료하는 광선을 비추리니"},
		},
		"지혜": {
			{"book": "prv", "book_name": "잠언", "chapter": 3, "verse": 5, "content": "너는 마음을 다하여 여호와를 신뢰하고 네 명철을 의지하지 말라"},
			{"book": "jm", "book_name": "야고보서", "chapter": 1, "verse": 5, "content": "너희 중에 누구든지 지혜가 부족하거든 모든 사람에게 후히 주시고 꾸짖지 아니하시는 하나님께 구하라 그리하면 주시리라"},
			{"book": "prv", "book_name": "잠언", "chapter": 9, "verse": 10, "content": "여호와를 경외하는 것이 지혜의 근본이요 거룩하신 자를 아는 것이 명철이니라"},
		},
		"평강": {
			{"book": "jo", "book_name": "요한복음", "chapter": 14, "verse": 27, "content": "평안을 너희에게 끼치노니 곧 나의 평안을 너희에게 주노니 내가 너희에게 주는 것은 세상이 주는 것과 같지 아니하니라"},
			{"book": "ph", "book_name": "빌립보서", "chapter": 4, "verse": 7, "content": "모든 지각에 뛰어난 하나님의 평강이 그리스도 예수 안에서 너희 마음과 생각을 지키시리라"},
			{"book": "is", "book_name": "이사야", "chapter": 26, "verse": 3, "content": "주께서 심지가 견고한 자를 평강하고 평강하도록 지키시리니 이는 그가 주를 신뢰함이니이다"},
		},
		"가족": {
			{"book": "eph", "book_name": "에베소서", "chapter": 6, "verse": 1, "content": "자녀들아 주 안에서 너희 부모에게 순종하라 이것이 옳으니라"},
			{"book": "js", "book_name": "여호수아", "chapter": 24, "verse": 15, "content": "오직 나와 내 집은 여호와를 섬기겠노라"},
			{"book": "prv", "book_name": "잠언", "chapter": 22, "verse": 6, "content": "마땅히 행할 길을 아이에게 가르치라 그리하면 늙어도 그것을 떠나지 아니하리라"},
		},
		"직장": {
			{"book": "cl", "book_name": "골로새서", "chapter": 3, "verse": 23, "content": "무엇을 하든지 마음을 다하여 주께 하듯 하고 사람에게 하듯 하지 말라"},
			{"book": "ec", "book_name": "전도서", "chapter": 9, "verse": 10, "content": "네 손이 일을 얻는 대로 힘을 다하여 할지어다"},
			{"book": "prv", "book_name": "잠언", "chapter": 16, "verse": 3, "content": "너의 행사를 여호와께 맡기라 그리하면 네가 경영하는 것이 이루어지리라"},
		},
		"건강": {
			{"book": "3jo", "book_name": "요한삼서", "chapter": 1, "verse": 2, "content": "사랑하는 자여 네 영혼이 잘됨 같이 네가 범사에 잘되고 강건하기를 내가 간구하노라"},
			{"book": "prv", "book_name": "잠언", "chapter": 17, "verse": 22, "content": "마음의 즐거움은 양약이라도 심령의 근심은 뼈를 마르게 하느니라"},
			{"book": "ex", "book_name": "출애굽기", "chapter": 15, "verse": 26, "content": "이르시되 너희가 너희 하나님 나 여호와의 말을 들어 순종하고 내가 보기에 의를 행하며 내 계명에 귀를 기울이며 내 모든 규례를 지키면 내가 애굽 사람에게 내린 모든 질병 중 하나도 너희에게 내리지 아니하리니 나는 너희를 치료하는 여호와임이라"},
		},
	}

	verses, exists := verseMapping[tag]
	if !exists {
		c.JSON(http.StatusNotFound, gin.H{
			"error": "Tag not found",
			"available_tags": []string{"감사", "위로", "용기", "회개", "치유", "지혜", "평강", "가족", "직장", "건강"},
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"tag": tag,
		"verses": verses,
		"total": len(verses),
	})
}

// CreateChapterThemesTable 챕터 주제 테이블 생성 API
// POST /api/admin/create-chapter-themes-table
func CreateChapterThemesTable(c *gin.Context) {
	if db == nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Database connection not available"})
		return
	}

	// 마이그레이션 SQL 읽기
	migrationSQL := `
-- 성경 챕터별 주제/키워드 테이블
CREATE TABLE IF NOT EXISTS bible_chapter_themes (
    id SERIAL PRIMARY KEY,
    book VARCHAR(10) NOT NULL,
    book_name VARCHAR(50) NOT NULL,
    chapter INTEGER NOT NULL,
    theme VARCHAR(100) NOT NULL,
    relevance_score INTEGER DEFAULT 1,
    keyword_count INTEGER DEFAULT 0,
    summary TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 인덱스 생성
CREATE INDEX IF NOT EXISTS idx_chapter_themes_theme ON bible_chapter_themes(theme);
CREATE INDEX IF NOT EXISTS idx_chapter_themes_book_chapter ON bible_chapter_themes(book, chapter);
CREATE INDEX IF NOT EXISTS idx_chapter_themes_relevance ON bible_chapter_themes(relevance_score DESC);
CREATE INDEX IF NOT EXISTS idx_chapter_themes_compound ON bible_chapter_themes(theme, relevance_score DESC);

-- 중복 방지 제약조건
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'unique_book_chapter_theme'
    ) THEN
        ALTER TABLE bible_chapter_themes
        ADD CONSTRAINT unique_book_chapter_theme
        UNIQUE (book, chapter, theme);
    END IF;
END $$;

-- 업데이트 트리거 함수
CREATE OR REPLACE FUNCTION update_chapter_themes_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 트리거 생성
DROP TRIGGER IF EXISTS trigger_update_chapter_themes_updated_at ON bible_chapter_themes;
CREATE TRIGGER trigger_update_chapter_themes_updated_at
    BEFORE UPDATE ON bible_chapter_themes
    FOR EACH ROW
    EXECUTE FUNCTION update_chapter_themes_updated_at();
	`

	// SQL 실행
	_, err := db.Exec(migrationSQL)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "Failed to create chapter themes table",
			"details": err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "Chapter themes table created successfully",
		"table": "bible_chapter_themes",
	})
}

// AnalyzeAndPopulateChapterThemes 챕터별 키워드 분석 및 데이터 삽입 API
// POST /api/admin/analyze-chapter-themes
func AnalyzeAndPopulateChapterThemes(c *gin.Context) {
	if db == nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Database connection not available"})
		return
	}

	// 주요 키워드 목록 (확장 가능)
	keywords := []string{
		"사랑", "믿음", "소망", "평안", "감사", "기도", "구원", "은혜", "축복", "지혜",
		"회개", "용서", "치유", "능력", "영광", "찬양", "예배", "순종", "겸손", "인내",
		"위로", "도움", "보호", "인도", "약속", "언약", "왕", "주님", "하나님", "예수",
		"성령", "교회", "제자", "섬김", "전도", "선교", "복음", "말씀", "진리", "계명",
		"의", "거룩", "정의", "공의", "자비", "긍휼", "친교", "교제", "형제", "가족",
		"부모", "자녀", "결혼", "일", "청지기", "청렴", "정직", "근면", "절제", "금식",
		"기쁨", "슬픔", "고난", "시험", "환난", "핍박", "승리", "이김", "영생", "심판",
		"죽음", "부활", "재림", "천국", "지옥", "천사", "마귀", "사탄", "죄", "유혹",
	}

	// 기존 데이터 삭제 (재분석을 위해)
	_, err := db.Exec("DELETE FROM bible_chapter_themes")
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "Failed to clear existing data",
			"details": err.Error(),
		})
		return
	}

	processed := 0
	errors := []string{}

	// 각 키워드별로 챕터 분석
	for _, keyword := range keywords {
		// 키워드가 포함된 챕터별 집계 쿼리
		query := `
			SELECT
				book_id as book,
				book_name_korean as book_name,
				chapter,
				COUNT(*) as keyword_count
			FROM bible_verses
			WHERE content LIKE $1 AND version = 'KOR'
			GROUP BY book_id, book_name_korean, chapter
			HAVING COUNT(*) >= 2
			ORDER BY COUNT(*) DESC
		`

		rows, err := db.Query(query, "%"+keyword+"%")
		if err != nil {
			errors = append(errors, fmt.Sprintf("Failed to analyze keyword '%s': %v", keyword, err))
			continue
		}

		// 각 챕터에 대해 데이터 삽입
		for rows.Next() {
			var book, bookName string
			var chapter, keywordCount int

			err := rows.Scan(&book, &bookName, &chapter, &keywordCount)
			if err != nil {
				errors = append(errors, fmt.Sprintf("Failed to scan row for keyword '%s': %v", keyword, err))
				continue
			}

			// 연관도 점수 계산 (키워드 등장 횟수 기반)
			relevanceScore := keywordCount
			if relevanceScore > 10 {
				relevanceScore = 10 // 최대 10점
			}

			// 데이터 삽입 (중복 시 무시)
			insertQuery := `
				INSERT INTO bible_chapter_themes (book, book_name, chapter, theme, relevance_score, keyword_count)
				VALUES ($1, $2, $3, $4, $5, $6)
				ON CONFLICT (book, chapter, theme) DO UPDATE SET
					relevance_score = GREATEST(bible_chapter_themes.relevance_score, $5),
					keyword_count = GREATEST(bible_chapter_themes.keyword_count, $6),
					updated_at = CURRENT_TIMESTAMP
			`

			_, err = db.Exec(insertQuery, book, bookName, chapter, keyword, relevanceScore, keywordCount)
			if err != nil {
				errors = append(errors, fmt.Sprintf("Failed to insert data for %s %d:%s - %v", bookName, chapter, keyword, err))
				continue
			}

			processed++
		}
		rows.Close()
	}

	// 결과 통계
	var totalRecords int
	err = db.QueryRow("SELECT COUNT(*) FROM bible_chapter_themes").Scan(&totalRecords)
	if err != nil {
		totalRecords = -1
	}

	result := gin.H{
		"message": "Chapter themes analysis completed",
		"processed_keywords": len(keywords),
		"processed_records": processed,
		"total_records": totalRecords,
	}

	if len(errors) > 0 {
		result["errors"] = errors
		result["error_count"] = len(errors)
	}

	c.JSON(http.StatusOK, result)
}

// SearchBibleByChapter 챕터 기반 성경 검색 API
// GET /api/bible/search/chapters?q=키워드
func SearchBibleByChapter(c *gin.Context) {
	if db == nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Database connection not available"})
		return
	}

	query := c.Query("q")
	if query == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Query parameter 'q' is required"})
		return
	}

	// 한글 성경책 이름 매핑 (영문코드 → 한글)
	bookNameMap := map[string]string{
		"gn": "창세기", "ex": "출애굽기", "lv": "레위기", "nm": "민수기", "dt": "신명기",
		"js": "여호수아", "rt": "룻기", "1sm": "사무엘상", "2sm": "사무엘하",
		"1kgs": "열왕기상", "2kgs": "열왕기하", "1ch": "역대상", "2ch": "역대하",
		"ezr": "에스라", "ne": "느헤미야", "et": "에스더", "job": "욥기", "ps": "시편",
		"prv": "잠언", "ec": "전도서", "so": "아가", "is": "이사야", "jr": "예레미야",
		"lm": "예레미야애가", "ez": "에스겔", "dn": "다니엘", "ho": "호세아", "jl": "요엘",
		"am": "아모스", "ob": "오바댜", "jn": "요나", "mi": "미가", "na": "나훔",
		"hk": "하박국", "zp": "스바냐", "hg": "학개", "zc": "스가랴", "ml": "말라기",
		"mt": "마태복음", "mk": "마가복음", "lk": "누가복음", "jo": "요한복음", "act": "사도행전",
		"rm": "로마서", "1co": "고린도전서", "2co": "고린도후서", "gl": "갈라디아서", "eph": "에베소서",
		"ph": "빌립보서", "cl": "골로새서", "1ts": "데살로니가전서", "2ts": "데살로니가후서",
		"1tm": "디모데전서", "2tm": "디모데후서", "tt": "디도서", "phm": "빌레몬서", "hb": "히브리서",
		"jm": "야고보서", "1pe": "베드로전서", "2pe": "베드로후서", "1jo": "요한일서", "2jo": "요한이서",
		"3jo": "요한삼서", "jd": "유다서", "re": "요한계시록",
	}

	// 한글 축약형 → 영문 코드 매핑 (keywords 테이블 bible_chapters용)
	koreanToCodeMap := map[string]string{
		"창": "gn", "출": "ex", "레": "lv", "민": "nm", "신": "dt",
		"수": "js", "룻": "rt", "삼상": "1sm", "삼하": "2sm",
		"왕상": "1kgs", "왕하": "2kgs", "대상": "1ch", "대하": "2ch",
		"스": "ezr", "느": "ne", "에": "et", "욥": "job", "시": "ps",
		"잠": "prv", "전": "ec", "아": "so", "사": "is", "렘": "jr",
		"애": "lm", "겔": "ez", "단": "dn", "호": "ho", "욜": "jl",
		"암": "am", "옵": "ob", "욘": "jn", "미": "mi", "나": "na",
		"합": "hk", "습": "zp", "학": "hg", "슥": "zc", "말": "ml",
		"마": "mt", "막": "mk", "눅": "lk", "요": "jo", "행": "act",
		"롬": "rm", "고전": "1co", "고후": "2co", "갈": "gl", "엡": "eph",
		"빌": "ph", "골": "cl", "살전": "1ts", "살후": "2ts",
		"딤전": "1tm", "딤후": "2tm", "딛": "tt", "몬": "phm", "히": "hb",
		"약": "jm", "벧전": "1pe", "벧후": "2pe", "요일": "1jo", "요이": "2jo",
		"요삼": "3jo", "유": "jd", "계": "re",
	}

	type ChapterResult struct {
		Book           string `json:"book"`
		BookName       string `json:"book_name"`
		Chapter        int    `json:"chapter"`
		Theme          string `json:"theme"`
		RelevanceScore int    `json:"relevance_score"`
		KeywordCount   int    `json:"keyword_count"`
		ChapterURL     string `json:"chapter_url"`
	}

	var results []ChapterResult
	var searchQuery string
	var rows *sql.Rows
	var err error

	// 1. 먼저 keywords 테이블에서 해당 키워드의 bible_chapters 배열 조회
	var bibleChaptersJSON []byte
	err = db.QueryRow(`
		SELECT bible_chapters FROM keywords WHERE name = $1
	`, query).Scan(&bibleChaptersJSON)

	if err == nil && len(bibleChaptersJSON) > 0 {
		// JSONB 배열을 파싱
		type BibleChapter struct {
			Book    string `json:"book"`
			Chapter int    `json:"chapter"`
		}
		var chapters []BibleChapter
		if err := json.Unmarshal(bibleChaptersJSON, &chapters); err == nil && len(chapters) > 0 {
			// 한글 코드를 영문 코드로 변환
			type EnglishBibleChapter struct {
				Book    string `json:"book"`
				Chapter int    `json:"chapter"`
			}
			var englishChapters []EnglishBibleChapter
			for _, ch := range chapters {
				if englishCode, ok := koreanToCodeMap[ch.Book]; ok {
					englishChapters = append(englishChapters, EnglishBibleChapter{
						Book:    englishCode,
						Chapter: ch.Chapter,
					})
				}
			}

			if len(englishChapters) > 0 {
				// 변환된 영문 코드로 JSONB 생성
				englishChaptersJSON, err := json.Marshal(englishChapters)
				if err == nil {
					// 키워드 배열 기반 조회 (정확한 매칭)
					// 각 장에서 가장 관련성 높은 테마만 선택 (ROW_NUMBER로 1개씩만)
					searchQuery = `
						WITH ranked_themes AS (
							SELECT DISTINCT
								bct.book,
								bct.book_name,
								bct.chapter,
								bct.theme,
								bct.relevance_score,
								bct.keyword_count,
								ROW_NUMBER() OVER (
									PARTITION BY bct.book, bct.chapter
									ORDER BY bct.relevance_score DESC, bct.keyword_count DESC
								) AS rn
							FROM bible_chapter_themes bct
							CROSS JOIN jsonb_array_elements($1::jsonb) AS chapter_elem
							WHERE bct.book = (chapter_elem->>'book')
							  AND bct.chapter = (chapter_elem->>'chapter')::int
						)
						SELECT book, book_name, chapter, theme, relevance_score, keyword_count
						FROM ranked_themes
						WHERE rn = 1
						ORDER BY
							relevance_score DESC,
							keyword_count DESC,
							book,
							chapter
					`
					rows, err = db.Query(searchQuery, englishChaptersJSON)

					if err == nil {
						goto processResults
					}
				}
			}
		}
	}

	// 2. ILIKE 기반 자유 검색 (검색창용)
	searchQuery = `
		SELECT
			bct.book,
			bct.book_name,
			bct.chapter,
			bct.theme,
			bct.relevance_score,
			bct.keyword_count
		FROM bible_chapter_themes bct
		WHERE bct.theme ILIKE $1
		ORDER BY
			bct.relevance_score DESC,
			bct.keyword_count DESC,
			bct.book,
			bct.chapter
		LIMIT 20
	`
	rows, err = db.Query(searchQuery, "%"+query+"%")

processResults:
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "Failed to search chapters",
			"details": err.Error(),
		})
		return
	}
	defer rows.Close()

	for rows.Next() {
		var result ChapterResult
		err := rows.Scan(
			&result.Book,
			&result.BookName,
			&result.Chapter,
			&result.Theme,
			&result.RelevanceScore,
			&result.KeywordCount,
		)
		if err != nil {
			continue
		}

		// 한글 성경책 이름 적용
		if koreanName, exists := bookNameMap[result.Book]; exists {
			result.BookName = koreanName
		}

		// 챕터 URL 생성
		result.ChapterURL = fmt.Sprintf("/api/bible/chapters/%s/%d", result.Book, result.Chapter)
		results = append(results, result)
	}

	c.JSON(http.StatusOK, gin.H{
		"query":   query,
		"results": results,
		"total":   len(results),
		"search_type": "chapter_based",
		"description": "성경 장 단위 주제 검색 결과",
	})
}

// GetChapterSummary 특정 챕터의 주제 요약 API
// GET /api/bible/chapters/:book/:chapter/themes
func GetChapterSummary(c *gin.Context) {
	if db == nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Database connection not available"})
		return
	}

	book := c.Param("book")
	chapterStr := c.Param("chapter")

	chapter, err := strconv.Atoi(chapterStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid chapter number"})
		return
	}

	// 해당 챕터의 모든 주제들 조회
	query := `
		SELECT
			bct.theme,
			bct.relevance_score,
			bct.keyword_count,
			bct.book_name
		FROM bible_chapter_themes bct
		WHERE bct.book = $1 AND bct.chapter = $2
		ORDER BY bct.relevance_score DESC, bct.keyword_count DESC
	`

	rows, err := db.Query(query, book, chapter)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "Failed to get chapter themes",
			"details": err.Error(),
		})
		return
	}
	defer rows.Close()

	type ThemeInfo struct {
		Theme          string `json:"theme"`
		RelevanceScore int    `json:"relevance_score"`
		KeywordCount   int    `json:"keyword_count"`
	}

	var themes []ThemeInfo
	var bookName string

	for rows.Next() {
		var theme ThemeInfo
		err := rows.Scan(&theme.Theme, &theme.RelevanceScore, &theme.KeywordCount, &bookName)
		if err != nil {
			continue
		}
		themes = append(themes, theme)
	}

	if len(themes) == 0 {
		c.JSON(http.StatusNotFound, gin.H{
			"error": "No themes found for this chapter",
			"book": book,
			"chapter": chapter,
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"book":       book,
		"book_name":  bookName,
		"chapter":    chapter,
		"themes":     themes,
		"theme_count": len(themes),
	})
}