# 비밀번호 관리 방법 비교

## 📊 옵션별 비교표

| 방법 | 비용 | 난이도 | 보안 수준 | 추천 대상 |
|-----|------|--------|----------|----------|
| **1. .env 파일** | 무료 | ⭐ 쉬움 | ⚠️ 중간 | 로컬 개발 |
| **2. AWS Parameter Store** | 무료 | ⭐⭐ 보통 | ✅ 높음 | 소규모 프로젝트 |
| **3. AWS Secrets Manager** | $0.50/월 | ⭐⭐⭐ 복잡 | ✅ 매우 높음 | 프로덕션 |
| **4. .pgpass (PostgreSQL 전용)** | 무료 | ⭐ 쉬움 | ⚠️ 낮음 | 로컬만 |

---

## 1️⃣ .env 파일 (현재 방식)

### 장점
- 간단하고 빠름
- 추가 설정 불필요
- 무료

### 단점
- EC2에 직접 파일 업로드 필요
- 파일 유출 시 위험
- 버전 관리 불가

### 사용 방법
```bash
# .env 파일
DB_HOST=localhost
DB_PORT=5432
DB_USER=bibleai
DB_PASSWORD=실제_비밀번호
DB_NAME=bibleai
DB_SSLMODE=disable
```

### 보안 강화 팁
```bash
# EC2에서 파일 권한 설정
chmod 600 .env
chown ec2-user:ec2-user .env
```

---

## 2️⃣ AWS Systems Manager Parameter Store (무료 추천 ⭐)

### 장점
- **완전 무료**
- AWS 통합
- IAM 권한 관리
- 암호화 지원

### 단점
- API 호출 제한 (초당 1,000건)
- 자동 로테이션 없음

### 구현 방법

#### 파라미터 생성
```bash
# AWS CLI로 파라미터 생성
aws ssm put-parameter \
  --name "/bibleai/db/host" \
  --value "localhost" \
  --type "String"

aws ssm put-parameter \
  --name "/bibleai/db/port" \
  --value "5432" \
  --type "String"

aws ssm put-parameter \
  --name "/bibleai/db/username" \
  --value "bibleai" \
  --type "String"

aws ssm put-parameter \
  --name "/bibleai/db/password" \
  --value "실제_비밀번호" \
  --type "SecureString"  # 암호화됨

aws ssm put-parameter \
  --name "/bibleai/db/name" \
  --value "bibleai" \
  --type "String"
```

#### Go 코드 (간단 버전)

```go
// internal/secrets/ssm.go
package secrets

import (
	"context"
	"fmt"

	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/ssm"
)

func GetParameter(name string) (string, error) {
	cfg, err := config.LoadDefaultConfig(context.TODO(),
		config.WithRegion("ap-northeast-2"),
	)
	if err != nil {
		return "", err
	}

	client := ssm.NewFromConfig(cfg)

	input := &ssm.GetParameterInput{
		Name:           &name,
		WithDecryption: true, // SecureString 복호화
	}

	result, err := client.GetParameter(context.TODO(), input)
	if err != nil {
		return "", err
	}

	return *result.Parameter.Value, nil
}

// GetDBConnectionString은 Parameter Store에서 DB 연결 문자열 생성
func GetDBConnectionString() (string, error) {
	host, _ := GetParameter("/bibleai/db/host")
	port, _ := GetParameter("/bibleai/db/port")
	user, _ := GetParameter("/bibleai/db/username")
	password, err := GetParameter("/bibleai/db/password")
	if err != nil {
		return "", fmt.Errorf("비밀번호 조회 실패: %v", err)
	}
	dbname, _ := GetParameter("/bibleai/db/name")

	return fmt.Sprintf(
		"host=%s port=%s user=%s password=%s dbname=%s sslmode=disable",
		host, port, user, password, dbname,
	), nil
}
```

#### IAM 권한
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ssm:GetParameter",
        "ssm:GetParameters"
      ],
      "Resource": "arn:aws:ssm:ap-northeast-2:*:parameter/bibleai/*"
    }
  ]
}
```

---

## 3️⃣ AWS Secrets Manager (프로덕션 권장)

### 장점
- 자동 비밀번호 로테이션
- 버전 관리
- 완전한 감사 로그
- JSON 형식 지원

### 단점
- 비용 발생 ($0.40/월/시크릿)

### 언제 사용?
- 프로덕션 환경
- 자동 비밀번호 변경 필요
- 규정 준수 필요

상세 내용은 `AWS_SECRETS_GUIDE.md` 참조

---

## 4️⃣ .pgpass 파일 (PostgreSQL 전용)

### 장점
- PostgreSQL 네이티브 방식
- 간단함

### 단점
- PostgreSQL에서만 작동
- Go 애플리케이션에서 사용 불가
- 낮은 보안성

### 사용 방법
```bash
# ~/.pgpass
localhost:5432:bibleai:bibleai:실제_비밀번호

chmod 600 ~/.pgpass
```

---

## 🎯 프로젝트별 추천

### 현재 프로젝트 (주님말씀AI)

#### Phase 1: 개발/테스트 (현재)
✅ **추천: .env 파일**
- 비용: 무료
- 난이도: 쉬움
- 충분한 보안성

```bash
# 현재 방식 유지
.env 파일 + .gitignore
```

#### Phase 2: EC2 배포 (초기 프로덕션)
✅ **추천: AWS Parameter Store**
- 비용: 무료
- AWS 통합
- 좋은 보안성

```bash
# 마이그레이션 순서
1. Parameter Store에 값 저장
2. Go 코드에 SSM 통합
3. EC2 IAM 역할 설정
4. .env 파일 제거
```

#### Phase 3: 본격 프로덕션 (사용자 1,000명+)
✅ **추천: AWS Secrets Manager**
- 자동 로테이션
- 완전한 감사
- 규정 준수

---

## 🚀 즉시 실행 가능한 선택지

### Option A: 현재 방식 유지 + 보안 강화
```bash
# EC2에서
chmod 600 /home/ec2-user/bibleai/.env
chown ec2-user:ec2-user /home/ec2-user/bibleai/.env

# .gitignore에 추가 (이미 완료)
.env
```

**비용: 무료**
**작업 시간: 5분**

### Option B: AWS Parameter Store로 전환
```bash
# 1. 파라미터 생성 (10분)
aws ssm put-parameter --name "/bibleai/db/password" --value "비밀번호" --type "SecureString"

# 2. Go 코드 수정 (30분)
# internal/secrets/ssm.go 추가

# 3. EC2 IAM 역할 설정 (5분)

# 4. 배포 (5분)
```

**비용: 무료**
**작업 시간: 50분**

### Option C: AWS Secrets Manager (완벽한 보안)
```bash
# 1. 시크릿 생성 (5분)
aws secretsmanager create-secret ...

# 2. Go 코드 수정 (1시간)
# 3. EC2 설정 (10분)
# 4. 테스트 및 배포 (20분)
```

**비용: $0.50/월**
**작업 시간: 1.5시간**

---

## 💡 내 추천 (단계별)

### 지금 당장 (오늘)
**현재 .env 방식 유지 + 파일 권한 강화**
```bash
chmod 600 .env
```

### 다음 주 (EC2 배포 준비)
**AWS Parameter Store로 전환**
- 무료
- AWS 네이티브
- 충분한 보안

### 3개월 후 (사용자 증가 시)
**AWS Secrets Manager로 업그레이드**
- 자동 로테이션
- 완벽한 보안

---

## 📋 구현 체크리스트

### Parameter Store 전환 (추천)

- [ ] AWS CLI 설치 및 설정
- [ ] Parameter Store에 DB 정보 저장
- [ ] Go 프로젝트에 AWS SDK 추가
- [ ] `internal/secrets/ssm.go` 구현
- [ ] `internal/database/db.go` 수정
- [ ] EC2 IAM 역할 생성 및 연결
- [ ] 로컬 테스트 (폴백 동작 확인)
- [ ] EC2 배포 및 테스트
- [ ] .env 파일 삭제

**예상 시간: 1시간**
**비용: 무료**

---

**결론: AWS Parameter Store를 사용하면 무료이면서도 안전하게 비밀번호를 관리할 수 있습니다!**
