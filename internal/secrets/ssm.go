package secrets

import (
	"context"
	"fmt"
	"log"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/ssm"
)

// GetParameter는 AWS Parameter Store에서 파라미터를 가져옵니다
func GetParameter(parameterName string) (string, error) {
	// AWS 설정 로드 (EC2 인스턴스 IAM 역할 자동 인식)
	cfg, err := config.LoadDefaultConfig(context.TODO(),
		config.WithRegion("ap-northeast-2"), // 서울 리전
	)
	if err != nil {
		return "", fmt.Errorf("AWS 설정 로드 실패: %v", err)
	}

	// SSM 클라이언트 생성
	client := ssm.NewFromConfig(cfg)

	// 파라미터 조회
	input := &ssm.GetParameterInput{
		Name:           aws.String(parameterName),
		WithDecryption: aws.Bool(true), // SecureString 복호화
	}

	result, err := client.GetParameter(context.TODO(), input)
	if err != nil {
		return "", fmt.Errorf("파라미터 조회 실패 (%s): %v", parameterName, err)
	}

	return *result.Parameter.Value, nil
}

// DBConfig는 데이터베이스 연결 설정을 담는 구조체
type DBConfig struct {
	Host     string
	Port     string
	Username string
	Password string
	DBName   string
	SSLMode  string
}

// GetDBConfig는 Parameter Store에서 DB 설정을 가져옵니다
func GetDBConfig() (*DBConfig, error) {
	log.Println("🔐 AWS Parameter Store에서 DB 설정 로드 중...")

	// 각 파라미터 조회
	host, err := GetParameter("/bibleai/db/host")
	if err != nil {
		return nil, err
	}

	port, err := GetParameter("/bibleai/db/port")
	if err != nil {
		return nil, err
	}

	username, err := GetParameter("/bibleai/db/username")
	if err != nil {
		return nil, err
	}

	password, err := GetParameter("/bibleai/db/password")
	if err != nil {
		return nil, err
	}

	dbname, err := GetParameter("/bibleai/db/name")
	if err != nil {
		return nil, err
	}

	sslmode, err := GetParameter("/bibleai/db/sslmode")
	if err != nil {
		// sslmode는 선택사항, 기본값 사용
		sslmode = "disable"
		log.Printf("⚠️  /bibleai/db/sslmode 없음, 기본값 사용: %s", sslmode)
	}

	config := &DBConfig{
		Host:     host,
		Port:     port,
		Username: username,
		Password: password,
		DBName:   dbname,
		SSLMode:  sslmode,
	}

	log.Println("✅ AWS Parameter Store에서 DB 설정 로드 완료")
	return config, nil
}

// GetConnectionString은 DB 연결 문자열을 생성합니다
func (c *DBConfig) GetConnectionString() string {
	return fmt.Sprintf(
		"host=%s port=%s user=%s password=%s dbname=%s sslmode=%s",
		c.Host, c.Port, c.Username, c.Password, c.DBName, c.SSLMode,
	)
}
