package database

import (
	"database/sql"
	"fmt"
	"log"
	"os"

	_ "github.com/lib/pq"
)

type DB struct {
	*sql.DB
}

func NewConnection() (*DB, error) {
	// 환경변수에서 DB 설정 읽기
	host := getEnv("DB_HOST", "localhost")
	port := getEnv("DB_PORT", "5432")
	user := getEnv("DB_USER", "bibleai")
	password := getEnv("DB_PASSWORD", "bibleai")
	dbname := getEnv("DB_NAME", "bibleai")
	sslmode := getEnv("DB_SSLMODE", "disable")

	connStr := fmt.Sprintf("host=%s port=%s user=%s password=%s dbname=%s sslmode=%s",
		host, port, user, password, dbname, sslmode)
	
	log.Printf("연결 문자열: %s", connStr)
	db, err := sql.Open("postgres", connStr)
	if err != nil {
		return nil, fmt.Errorf("데이터베이스 연결 실패: %v", err)
	}

	// 연결 테스트
	if err := db.Ping(); err != nil {
		return nil, fmt.Errorf("데이터베이스 ping 실패: %v", err)
	}

	log.Println("데이터베이스에 성공적으로 연결되었습니다.")
	return &DB{db}, nil
}

func getEnv(key, defaultValue string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return defaultValue
}

func (db *DB) Close() error {
	return db.DB.Close()
}