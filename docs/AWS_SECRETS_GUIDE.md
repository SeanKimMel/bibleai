# AWS Secrets Manager 구현 가이드

## 📋 개요

AWS Secrets Manager를 사용하여 데이터베이스 연결 정보를 안전하게 관리하는 가이드입니다.

## 💰 비용

- **시크릿 저장**: $0.40/월/시크릿
- **API 호출**: $0.05/10,000건
- **예상 총 비용**: ~$0.50/월 (1개 시크릿, 월 1,000회 호출 기준)

---

## 🚀 1단계: AWS Secrets Manager 설정

### AWS Console에서 시크릿 생성

```bash
# AWS CLI로 시크릿 생성 (더 빠름)
aws secretsmanager create-secret \
  --name bibleai/database/credentials \
  --description "BibleAI 데이터베이스 연결 정보" \
  --secret-string '{
    "host": "localhost",
    "port": "5432",
    "username": "bibleai",
    "password": "실제_안전한_비밀번호",
    "dbname": "bibleai",
    "sslmode": "disable"
  }'
```

또는 AWS Console에서:
1. AWS Secrets Manager 콘솔 열기
2. "Store a new secret" 클릭
3. Secret type: "Other type of secret"
4. Key/Value로 입력:
   - host: localhost
   - port: 5432
   - username: bibleai
   - password: 실제_비밀번호
   - dbname: bibleai
   - sslmode: disable
5. Secret name: `bibleai/database/credentials`
6. 생성 완료

---

## 🔧 2단계: Go 애플리케이션 통합

### 필요한 패키지 설치

```bash
go get github.com/aws/aws-sdk-go-v2/config
go get github.com/aws/aws-sdk-go-v2/service/secretsmanager
```

### internal/secrets/secrets.go 생성

```go
package secrets

import (
	"context"
	"encoding/json"
	"fmt"
	"log"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/secretsmanager"
)

type DBCredentials struct {
	Host     string `json:"host"`
	Port     string `json:"port"`
	Username string `json:"username"`
	Password string `json:"password"`
	DBName   string `json:"dbname"`
	SSLMode  string `json:"sslmode"`
}

// GetDBCredentials는 AWS Secrets Manager에서 DB 자격증명을 가져옵니다
func GetDBCredentials(secretName string) (*DBCredentials, error) {
	// AWS 설정 로드
	cfg, err := config.LoadDefaultConfig(context.TODO(),
		config.WithRegion("ap-northeast-2"), // 서울 리전
	)
	if err != nil {
		return nil, fmt.Errorf("AWS 설정 로드 실패: %v", err)
	}

	// Secrets Manager 클라이언트 생성
	client := secretsmanager.NewFromConfig(cfg)

	// 시크릿 조회
	input := &secretsmanager.GetSecretValueInput{
		SecretId: aws.String(secretName),
	}

	result, err := client.GetSecretValue(context.TODO(), input)
	if err != nil {
		return nil, fmt.Errorf("시크릿 조회 실패: %v", err)
	}

	// JSON 파싱
	var creds DBCredentials
	if err := json.Unmarshal([]byte(*result.SecretString), &creds); err != nil {
		return nil, fmt.Errorf("시크릿 파싱 실패: %v", err)
	}

	log.Printf("✅ AWS Secrets Manager에서 DB 자격증명 로드 완료")
	return &creds, nil
}

// GetConnectionString은 DB 연결 문자열을 생성합니다
func (c *DBCredentials) GetConnectionString() string {
	return fmt.Sprintf(
		"host=%s port=%s user=%s password=%s dbname=%s sslmode=%s",
		c.Host, c.Port, c.Username, c.Password, c.DBName, c.SSLMode,
	)
}
```

### internal/database/db.go 수정

```go
package database

import (
	"database/sql"
	"fmt"
	"log"
	"os"
	"time"

	"bibleai/internal/secrets"

	_ "github.com/lib/pq"
)

type DB struct {
	*sql.DB
}

func NewConnection() (*DB, error) {
	var connStr string

	// 환경 변수로 시크릿 이름 지정 (기본값: bibleai/database/credentials)
	secretName := os.Getenv("AWS_SECRET_NAME")
	if secretName == "" {
		secretName = "bibleai/database/credentials"
	}

	// AWS 환경인지 확인 (AWS_REGION 환경 변수로 판단)
	if os.Getenv("AWS_REGION") != "" || os.Getenv("USE_AWS_SECRETS") == "true" {
		log.Printf("🔐 AWS Secrets Manager에서 DB 자격증명 로드 중...")

		creds, err := secrets.GetDBCredentials(secretName)
		if err != nil {
			// Secrets Manager 실패 시 폴백
			log.Printf("⚠️  AWS Secrets Manager 실패, 환경 변수로 폴백: %v", err)
			connStr = buildConnStrFromEnv()
		} else {
			connStr = creds.GetConnectionString()
		}
	} else {
		// 로컬 개발: 환경 변수 사용
		log.Printf("🔧 로컬 개발 모드: 환경 변수 사용")
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

	// Connection Pool 설정
	db.SetMaxOpenConns(20)
	db.SetMaxIdleConns(10)
	db.SetConnMaxLifetime(5 * time.Minute)
	db.SetConnMaxIdleTime(0) // 무제한 유지

	log.Println("데이터베이스에 성공적으로 연결되었습니다.")
	log.Printf("Connection Pool 설정: Min=%d, Max=%d, MaxLifetime=5m, IdleTimeout=무제한", 10, 20)

	// 초기 연결 풀 생성
	log.Printf("초기 연결 풀 생성 중 (%d개)...", 10)
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

	for i := 0; i < 10; i++ {
		<-done
	}

	log.Printf("✅ 초기 연결 풀 생성 완료 (%d개 대기 중)", 10)

	return &DB{db}, nil
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
	// password=xxx 부분을 password=*** 로 마스킹
	import "regexp"
	re := regexp.MustCompile(`password=[^\s]+`)
	return re.ReplaceAllString(connStr, "password=***")
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
```

---

## 🔐 3단계: IAM 권한 설정

### EC2 인스턴스 역할 생성

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "secretsmanager:GetSecretValue",
        "secretsmanager:DescribeSecret"
      ],
      "Resource": "arn:aws:secretsmanager:ap-northeast-2:YOUR_ACCOUNT_ID:secret:bibleai/database/credentials-*"
    }
  ]
}
```

### EC2에 IAM 역할 연결

1. EC2 콘솔에서 인스턴스 선택
2. Actions → Security → Modify IAM role
3. 위에서 생성한 역할 선택
4. 저장

---

## 🚀 4단계: 배포 스크립트 수정

### deploy-docker.sh (AWS Secrets Manager 사용)

```bash
#!/bin/bash
set -e

APP_DIR="/home/ec2-user/bibleai"
REPO_URL="https://github.com/SeanKimMel/bibleai.git"

echo "🚀 애플리케이션 배포 시작..."

# 1. 코드 업데이트
if [ -d "$APP_DIR" ]; then
    cd $APP_DIR && git pull origin main
else
    git clone $REPO_URL $APP_DIR && cd $APP_DIR
fi

# 2. Docker 이미지 빌드
echo "🏗️  Docker 이미지 빌드..."
docker build -t bibleai:latest .

# 3. 기존 컨테이너 중지
docker stop bibleai 2>/dev/null || true
docker rm bibleai 2>/dev/null || true

# 4. 새 컨테이너 실행 (AWS Secrets Manager 사용)
echo "▶️  새 컨테이너 실행 (AWS Secrets Manager)..."
docker run -d \
  --name bibleai \
  --restart unless-stopped \
  -p 8080:8080 \
  -e USE_AWS_SECRETS=true \
  -e AWS_REGION=ap-northeast-2 \
  -e AWS_SECRET_NAME=bibleai/database/credentials \
  bibleai:latest

echo "✅ 배포 완료!"
docker logs -f bibleai
```

---

## 🧪 5단계: 로컬 테스트

### 로컬에서는 .env 파일 사용

```bash
# .env
DB_HOST=localhost
DB_PORT=5432
DB_USER=bibleai
DB_PASSWORD=로컬_비밀번호
DB_NAME=bibleai
DB_SSLMODE=disable

# AWS Secrets Manager 사용하지 않음
# USE_AWS_SECRETS=false (기본값)
```

### AWS 환경에서 테스트하려면

```bash
# 로컬에서 AWS Secrets Manager 테스트
export USE_AWS_SECRETS=true
export AWS_REGION=ap-northeast-2
export AWS_PROFILE=your-profile  # AWS CLI 프로필

./server.sh start
```

---

## 🔄 6단계: 시크릿 업데이트 방법

### 비밀번호 변경 시

```bash
# AWS CLI로 업데이트
aws secretsmanager update-secret \
  --secret-id bibleai/database/credentials \
  --secret-string '{
    "host": "localhost",
    "port": "5432",
    "username": "bibleai",
    "password": "새로운_비밀번호",
    "dbname": "bibleai",
    "sslmode": "disable"
  }'

# 애플리케이션 재시작 (새 비밀번호 적용)
docker restart bibleai
```

---

## 📊 비교표: 환경별 사용 방법

| 환경 | 비밀번호 관리 | 설정 방법 |
|-----|-------------|----------|
| **로컬 개발** | `.env` 파일 | 환경 변수 사용 |
| **EC2 개발** | AWS Secrets Manager | `USE_AWS_SECRETS=true` |
| **프로덕션** | AWS Secrets Manager | IAM 역할 + Secrets Manager |

---

## 🛡️ 보안 장점

1. **암호화**: AWS가 자동으로 암호화 (KMS 사용)
2. **접근 제어**: IAM 정책으로 세밀한 권한 관리
3. **감사 로그**: CloudTrail로 모든 접근 기록
4. **버전 관리**: 시크릿 변경 히스토리 추적
5. **자동 로테이션**: 정기적 비밀번호 자동 변경 가능
6. **파일 없음**: .env 파일 불필요, 유출 위험 제거

---

## 🚨 주의사항

1. **IAM 역할 필수**: EC2 인스턴스에 IAM 역할 연결 필수
2. **리전 확인**: 서울 리전 사용 (`ap-northeast-2`)
3. **비용 모니터링**: 매월 $0.50 정도 발생
4. **폴백 메커니즘**: Secrets Manager 실패 시 환경 변수로 폴백

---

## 📚 참고 자료

- [AWS Secrets Manager 문서](https://docs.aws.amazon.com/secretsmanager/)
- [AWS SDK for Go v2](https://aws.github.io/aws-sdk-go-v2/docs/)
- [IAM 역할 모범 사례](https://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html)

---

**작성일**: 2025-10-01
**프로젝트**: 주님말씀AI 웹앱
**버전**: v0.6.0
