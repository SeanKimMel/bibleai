package database

import (
	"bibleai/internal/secrets"
	"database/sql"
	"fmt"
	"log"
	"os"
	"regexp"
	"time"

	_ "github.com/lib/pq"
)

type DB struct {
	*sql.DB
}

func NewConnection() (*DB, error) {
	var connStr string

	// AWS Parameter Store 사용 여부 확인
	useAWSParams := getEnv("USE_AWS_PARAMS", "false")

	if useAWSParams == "true" {
		// AWS Parameter Store에서 DB 설정 로드
		log.Println("🔐 AWS Parameter Store 모드 활성화")
		dbConfig, err := secrets.GetDBConfig()
		if err != nil {
			log.Printf("⚠️  AWS Parameter Store 로드 실패, 환경 변수로 폴백: %v", err)
			connStr = buildConnStrFromEnv()
		} else {
			connStr = dbConfig.GetConnectionString()
		}
	} else {
		// 로컬 개발: 환경 변수 사용
		log.Println("🔧 로컬 개발 모드: 환경 변수 사용")
		connStr = buildConnStrFromEnv()
	}

	log.Printf("연결 문자열: %s", maskPassword(connStr))
	db, err := sql.Open("postgres", connStr)
	if err != nil {
		return nil, fmt.Errorf("데이터베이스 연결 실패: %v", err)
	}

	// 연결 테스트
	if err := db.Ping(); err != nil {
		return nil, fmt.Errorf("데이터베이스 ping 실패: %v", err)
	}

	// Connection Pool 설정 (성능 최적화)
	// 동시 사용자 수에 맞춰 조정 가능
	db.SetMaxOpenConns(20)                      // 최대 동시 연결 수 (max)
	db.SetMaxIdleConns(10)                      // 최소 유휴 연결 수 (min)
	db.SetConnMaxLifetime(5 * time.Minute)      // 연결 최대 수명 5분
	db.SetConnMaxIdleTime(0)                    // 유휴 연결 무제한 유지 (0 = 자동 종료 안함)

	log.Println("데이터베이스에 성공적으로 연결되었습니다.")
	log.Printf("Connection Pool 설정: Min=%d, Max=%d, MaxLifetime=5m, IdleTimeout=무제한", 10, 20)

	// 미리 Min 개수만큼 연결 생성 (Eager Loading, 자바 HikariCP 방식)
	// 갑작스런 부하에 대응하기 위해 초기 연결 생성
	log.Printf("초기 연결 풀 생성 중 (%d개)...", 10)

	// 더미 쿼리를 동시에 실행하여 연결 생성
	done := make(chan bool, 10)
	for i := 0; i < 10; i++ {
		go func(idx int) {
			var result int
			err := db.QueryRow("SELECT 1").Scan(&result)
			if err != nil {
				log.Printf("경고: 초기 연결 #%d 생성 실패: %v", idx+1, err)
			}
			done <- true
		}(i)
	}

	// 모든 goroutine 완료 대기
	for i := 0; i < 10; i++ {
		<-done
	}

	log.Printf("✅ 초기 연결 풀 생성 완료 (%d개 대기 중)", 10)

	return &DB{db}, nil
}

func getEnv(key, defaultValue string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return defaultValue
}

// buildConnStrFromEnv는 환경 변수에서 연결 문자열 생성
func buildConnStrFromEnv() string {
	host := getEnv("DB_HOST", "localhost")
	port := getEnv("DB_PORT", "5432")
	user := getEnv("DB_USER", "bibleai")
	password := getEnv("DB_PASSWORD", "bibleai")
	dbname := getEnv("DB_NAME", "bibleai")
	sslmode := getEnv("DB_SSLMODE", "disable")

	return fmt.Sprintf("host=%s port=%s user=%s password=%s dbname=%s sslmode=%s",
		host, port, user, password, dbname, sslmode)
}

// maskPassword는 로그에 비밀번호를 마스킹
func maskPassword(connStr string) string {
	re := regexp.MustCompile(`password=[^\s]+`)
	return re.ReplaceAllString(connStr, "password=***")
}

func (db *DB) Close() error {
	return db.DB.Close()
}