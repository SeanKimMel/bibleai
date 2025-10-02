# AWS Parameter Store 설정 가이드

## 🚀 빠른 시작 (5분)

### 1단계: AWS Parameter Store에 값 저장

```bash
# AWS CLI로 파라미터 생성 (EC2 또는 로컬에서 실행)

# DB 호스트
aws ssm put-parameter \
  --name "/bibleai/db/host" \
  --value "localhost" \
  --type "String" \
  --region ap-northeast-2

# DB 포트
aws ssm put-parameter \
  --name "/bibleai/db/port" \
  --value "5432" \
  --type "String" \
  --region ap-northeast-2

# DB 사용자명
aws ssm put-parameter \
  --name "/bibleai/db/username" \
  --value "bibleai" \
  --type "String" \
  --region ap-northeast-2

# DB 비밀번호 (암호화됨!)
aws ssm put-parameter \
  --name "/bibleai/db/password" \
  --value "실제_안전한_비밀번호" \
  --type "SecureString" \
  --region ap-northeast-2

# DB 이름
aws ssm put-parameter \
  --name "/bibleai/db/name" \
  --value "bibleai" \
  --type "String" \
  --region ap-northeast-2

# SSL 모드 (선택사항)
aws ssm put-parameter \
  --name "/bibleai/db/sslmode" \
  --value "disable" \
  --type "String" \
  --region ap-northeast-2
```

### 2단계: EC2 IAM 역할 설정

#### IAM 정책 생성

AWS Console → IAM → Policies → Create Policy

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

**정책 이름**: `BibleAI-ParameterStore-ReadOnly`

#### IAM 역할 생성

AWS Console → IAM → Roles → Create Role

1. **Trusted entity**: AWS service → EC2
2. **Permissions**: 위에서 만든 `BibleAI-ParameterStore-ReadOnly` 정책 선택
3. **Role name**: `BibleAI-EC2-Role`
4. 생성 완료

#### EC2에 역할 연결

AWS Console → EC2 → Instances → 인스턴스 선택
- Actions → Security → Modify IAM role
- `BibleAI-EC2-Role` 선택
- Save

### 3단계: 애플리케이션 배포

#### Docker로 배포

```bash
# EC2에서 실행
cd /home/ec2-user/bibleai

# 최신 코드 pull
git pull origin main

# Docker 이미지 빌드
docker build -t bibleai:latest .

# 기존 컨테이너 중지
docker stop bibleai 2>/dev/null || true
docker rm bibleai 2>/dev/null || true

# 새 컨테이너 실행 (AWS Parameter Store 활성화)
docker run -d \
  --name bibleai \
  --restart unless-stopped \
  -p 8080:8080 \
  -e USE_AWS_PARAMS=true \
  bibleai:latest

# 로그 확인
docker logs -f bibleai
```

로그에서 다음 메시지를 확인하세요:
```
🔐 AWS Parameter Store 모드 활성화
🔐 AWS Parameter Store에서 DB 설정 로드 중...
✅ AWS Parameter Store에서 DB 설정 로드 완료
연결 문자열: host=localhost port=5432 user=bibleai password=*** dbname=bibleai sslmode=disable
✅ 초기 연결 풀 생성 완료 (10개 대기 중)
```

---

## 🔄 환경별 사용 방법

### 로컬 개발 (현재 방식 유지)

```bash
# .env 파일 사용
DB_HOST=localhost
DB_PORT=5432
DB_USER=bibleai
DB_PASSWORD=로컬_비밀번호
DB_NAME=bibleai
DB_SSLMODE=disable

# USE_AWS_PARAMS 설정 안함 (기본값: false)

# 서버 실행
./server.sh start
```

로그 확인:
```
🔧 로컬 개발 모드: 환경 변수 사용
```

### EC2 프로덕션 (Parameter Store)

```bash
# 환경 변수로 Parameter Store 활성화
export USE_AWS_PARAMS=true

# 또는 Docker run 시
docker run -d \
  -e USE_AWS_PARAMS=true \
  bibleai:latest
```

로그 확인:
```
🔐 AWS Parameter Store 모드 활성화
✅ AWS Parameter Store에서 DB 설정 로드 완료
```

---

## 🧪 로컬에서 AWS Parameter Store 테스트

AWS CLI 프로필이 설정되어 있다면 로컬에서도 테스트 가능합니다:

```bash
# AWS 자격증명 설정
export AWS_PROFILE=your-profile
export AWS_REGION=ap-northeast-2

# Parameter Store 활성화
export USE_AWS_PARAMS=true

# 서버 실행
./server.sh start
```

---

## 🔐 파라미터 값 확인/수정

### 현재 값 확인

```bash
# 단일 파라미터 조회
aws ssm get-parameter \
  --name "/bibleai/db/host" \
  --region ap-northeast-2

# 비밀번호 복호화하여 조회
aws ssm get-parameter \
  --name "/bibleai/db/password" \
  --with-decryption \
  --region ap-northeast-2

# 모든 bibleai 파라미터 목록
aws ssm get-parameters-by-path \
  --path "/bibleai" \
  --recursive \
  --region ap-northeast-2
```

### 파라미터 값 수정

```bash
# 비밀번호 변경 예시
aws ssm put-parameter \
  --name "/bibleai/db/password" \
  --value "새로운_비밀번호" \
  --type "SecureString" \
  --overwrite \
  --region ap-northeast-2

# 애플리케이션 재시작 (새 값 적용)
docker restart bibleai
```

### 파라미터 삭제

```bash
# 단일 파라미터 삭제
aws ssm delete-parameter \
  --name "/bibleai/db/password" \
  --region ap-northeast-2

# 모든 bibleai 파라미터 삭제 (주의!)
aws ssm delete-parameters \
  --names \
    "/bibleai/db/host" \
    "/bibleai/db/port" \
    "/bibleai/db/username" \
    "/bibleai/db/password" \
    "/bibleai/db/name" \
    "/bibleai/db/sslmode" \
  --region ap-northeast-2
```

---

## 🚨 트러블슈팅

### 에러 1: AWS 자격증명 없음

```
⚠️  AWS Parameter Store 로드 실패: NoCredentialProviders: no valid providers in chain
```

**해결:**
- EC2: IAM 역할이 연결되었는지 확인
- 로컬: `aws configure` 실행 또는 `AWS_PROFILE` 설정

### 에러 2: 권한 없음

```
⚠️  AWS Parameter Store 로드 실패: AccessDeniedException: User is not authorized
```

**해결:**
- IAM 정책에서 `ssm:GetParameter` 권한 확인
- 파라미터 경로가 `/bibleai/*`와 일치하는지 확인

### 에러 3: 파라미터 없음

```
⚠️  파라미터 조회 실패 (/bibleai/db/password): ParameterNotFound
```

**해결:**
- 1단계 다시 실행 (파라미터 생성)
- 파라미터 이름 오타 확인

### 에러 4: 리전 불일치

```
⚠️  AWS Parameter Store 로드 실패: parameter not found
```

**해결:**
- 파라미터를 `ap-northeast-2` (서울) 리전에 생성했는지 확인
- `internal/secrets/ssm.go`의 리전 설정 확인

---

## 💡 폴백 동작

AWS Parameter Store 로드 실패 시 자동으로 환경 변수로 폴백됩니다:

```
⚠️  AWS Parameter Store 로드 실패, 환경 변수로 폴백: ...
🔧 로컬 개발 모드: 환경 변수 사용
```

이 경우 `.env` 파일 또는 환경 변수의 값을 사용합니다.

---

## 📋 체크리스트

배포 전 확인사항:

- [ ] AWS Parameter Store에 6개 파라미터 생성됨
- [ ] IAM 정책 생성됨 (`BibleAI-ParameterStore-ReadOnly`)
- [ ] IAM 역할 생성됨 (`BibleAI-EC2-Role`)
- [ ] EC2 인스턴스에 IAM 역할 연결됨
- [ ] 코드 최신 버전 pull 완료
- [ ] Docker 이미지 빌드 완료
- [ ] `USE_AWS_PARAMS=true` 환경 변수 설정
- [ ] 로그에서 Parameter Store 로드 성공 확인
- [ ] DB 연결 정상 동작 확인

---

## 📊 비용

**AWS Parameter Store (Standard):**
- ✅ **완전 무료**
- 10,000개 파라미터까지 무료
- API 호출 무제한 무료 (Standard tier)

**현재 사용량:**
- 파라미터: 6개
- 비용: **$0.00/월**

---

## 🎯 다음 단계

1. **로컬에서 테스트** (현재 .env 방식 유지)
2. **AWS에 파라미터 생성** (위 1단계)
3. **IAM 역할 설정** (위 2단계)
4. **EC2에 배포** (위 3단계)
5. **.env 파일 삭제** (보안 강화)

완료! 🎉
