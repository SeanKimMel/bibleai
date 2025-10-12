# AWS Parameter Store 로컬 테스트 가이드

이 문서는 로컬 개발 환경에서 AWS Parameter Store 통합을 테스트하는 방법을 설명합니다.

## 📋 목차

1. [개요](#개요)
2. [방법 1: AWS CLI 자격 증명 설정 (권장)](#방법-1-aws-cli-자격-증명-설정-권장)
3. [방법 2: 프로필 기반 개발](#방법-2-프로필-기반-개발)
4. [방법 3: 하이브리드 워크플로우 (실용적 권장)](#방법-3-하이브리드-워크플로우-실용적-권장)
5. [자동 테스트 스크립트](#자동-테스트-스크립트)
6. [문제 해결](#문제-해결)

---

## 개요

프로덕션 환경에서는 EC2 인스턴스 IAM 역할이 자동으로 Parameter Store 접근 권한을 제공하지만, 로컬 개발 환경에서는 AWS 자격 증명을 수동으로 설정해야 합니다.

**주요 원칙**:
- **로컬 개발**: 환경 변수 (`.env` 파일 또는 직접 export)
- **AWS 테스트**: AWS CLI 자격 증명 + `USE_AWS_PARAMS=true`
- **프로덕션**: EC2 IAM 역할 + `USE_AWS_PARAMS=true`

---

## 방법 1: AWS CLI 자격 증명 설정 (권장)

### 1단계: AWS CLI 설치

```bash
# macOS
brew install awscli

# Ubuntu/Debian
sudo apt install awscli

# Windows
# https://aws.amazon.com/cli/ 에서 설치 프로그램 다운로드
```

### 2단계: IAM 사용자 생성 및 권한 부여

AWS Console에서 다음 작업을 수행합니다:

#### IAM 사용자 생성
1. **AWS Console** → **IAM** → **Users** → **Create user**
2. **User name**: `bibleai-developer` (또는 원하는 이름)
3. **Access key - Programmatic access** 선택

#### 권한 정책 추가
사용자에게 다음 정책을 직접 연결하거나 새 정책을 생성합니다:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ssm:GetParameter",
                "ssm:GetParameters",
                "ssm:GetParametersByPath"
            ],
            "Resource": "arn:aws:ssm:ap-northeast-2:*:parameter/bibleai/*"
        }
    ]
}
```

**정책 이름**: `BibleAI-ParameterStore-ReadOnly`

#### Access Key 생성 및 저장
1. 사용자 생성 완료 후 **Access Key ID**와 **Secret Access Key**를 안전하게 저장
2. **중요**: Secret Access Key는 이 화면에서만 볼 수 있으므로 반드시 저장!

### 3단계: AWS CLI 자격 증명 구성

```bash
# AWS CLI 구성 실행
aws configure

# 입력 정보:
AWS Access Key ID [None]: AKIA..................
AWS Secret Access Key [None]: ........................................
Default region name [None]: ap-northeast-2
Default output format [None]: json
```

이 명령은 다음 파일을 자동으로 생성합니다:

**`~/.aws/credentials`**:
```ini
[default]
aws_access_key_id = AKIA..................
aws_secret_access_key = ........................................
```

**`~/.aws/config`**:
```ini
[default]
region = ap-northeast-2
output = json
```

### 4단계: Parameter Store 접근 테스트

```bash
# 단일 파라미터 조회
aws ssm get-parameter --name "/bibleai/db/password" --with-decryption

# 성공 응답 예시:
# {
#     "Parameter": {
#         "Name": "/bibleai/db/password",
#         "Type": "SecureString",
#         "Value": "<from .env file>",
#         "Version": 1,
#         ...
#     }
# }

# 모든 bibleai 파라미터 조회
aws ssm get-parameters-by-path --path "/bibleai" --with-decryption
```

### 5단계: Go 애플리케이션에서 테스트

```bash
# 환경 변수 설정 (터미널 세션에서만 유효)
export USE_AWS_PARAMS=true

# 서버 시작
./server.sh start

# 로그 확인
./server.sh logs
```

**예상 로그 (성공)**:
```
🔐 AWS Parameter Store 모드 활성화
🔐 AWS Parameter Store에서 DB 설정 로드 중...
✅ AWS Parameter Store에서 DB 설정 로드 완료
연결 문자열: host=localhost port=5432 user=bibleai password=*** dbname=bibleai sslmode=disable
데이터베이스에 성공적으로 연결되었습니다.
```

**예상 로그 (실패 후 폴백)**:
```
🔐 AWS Parameter Store 모드 활성화
🔐 AWS Parameter Store에서 DB 설정 로드 중...
⚠️  AWS Parameter Store 로드 실패, 환경 변수로 폴백: NoCredentialProviders: no valid providers in chain
🔧 로컬 개발 모드: 환경 변수 사용
연결 문자열: host=localhost port=5432 user=bibleai password=*** dbname=bibleai sslmode=disable
```

---

## 방법 2: 프로필 기반 개발

여러 AWS 계정이나 환경을 사용하는 경우 프로필을 분리할 수 있습니다.

### 프로필 설정

```bash
# 개발용 프로필 추가
aws configure --profile bibleai-dev
# Access Key, Secret Key, Region 입력

# 프로덕션용 프로필 추가
aws configure --profile bibleai-prod
# 프로덕션 Access Key, Secret Key, Region 입력
```

**`~/.aws/credentials` 결과**:
```ini
[default]
aws_access_key_id = AKIA_DEFAULT_KEY
aws_secret_access_key = DEFAULT_SECRET

[bibleai-dev]
aws_access_key_id = AKIA_DEV_KEY
aws_secret_access_key = DEV_SECRET

[bibleai-prod]
aws_access_key_id = AKIA_PROD_KEY
aws_secret_access_key = PROD_SECRET
```

### 프로필 사용

```bash
# 개발 프로필로 애플리케이션 실행
export AWS_PROFILE=bibleai-dev
export USE_AWS_PARAMS=true
./server.sh start

# 또는 한 줄로:
AWS_PROFILE=bibleai-dev USE_AWS_PARAMS=true ./server.sh start

# 프로덕션 프로필로 테스트 (주의!)
export AWS_PROFILE=bibleai-prod
export USE_AWS_PARAMS=true
./server.sh start
```

### 프로필별 Parameter Store 테스트

```bash
# 개발 환경 파라미터 조회
aws ssm get-parameter --name "/bibleai/db/password" --with-decryption --profile bibleai-dev

# 프로덕션 환경 파라미터 조회
aws ssm get-parameter --name "/bibleai/db/password" --with-decryption --profile bibleai-prod
```

---

## 방법 3: 하이브리드 워크플로우 (실용적 권장)

대부분의 개발은 로컬 환경 변수로 하고, Parameter Store는 가끔 테스트하는 방식입니다.

### 일반 개발 (로컬 환경 변수)

```bash
# .env 파일 사용 (권장)
source .env
./server.sh start

# 또는 .env 파일 없이 직접 export (테스트용)
export DB_HOST=localhost
export DB_PORT=5432
export DB_USER=bibleai
export DB_PASSWORD=<.env 파일 참조>
export DB_NAME=bibleai
export DB_SSLMODE=disable

# USE_AWS_PARAMS는 기본적으로 false (또는 설정 안 함)
./server.sh start
```

### AWS Parameter Store 테스트

```bash
# Parameter Store 테스트 시에만 활성화
export USE_AWS_PARAMS=true
./server.sh start

# 테스트 완료 후 비활성화
unset USE_AWS_PARAMS
./server.sh start
```

### 권장 워크플로우

1. **일상 개발**: 환경 변수 사용 (빠르고 간단)
2. **AWS 통합 테스트**: 주 1회 정도 `USE_AWS_PARAMS=true`로 테스트
3. **프로덕션 배포 전**: 반드시 Parameter Store 통합 확인

---

## 자동 테스트 스크립트

프로젝트에 포함된 `development-only/test-aws-params.sh` 스크립트를 사용하면 자동으로 테스트할 수 있습니다.

### 사용법

```bash
# 기본 프로필로 테스트
./development-only/test-aws-params.sh

# 특정 프로필로 테스트
./development-only/test-aws-params.sh bibleai-dev
```

### 스크립트 동작

1. ✅ AWS CLI 설치 확인
2. ✅ AWS 자격 증명 확인
3. ✅ 각 Parameter Store 파라미터 접근 테스트:
   - `/bibleai/db/host`
   - `/bibleai/db/port`
   - `/bibleai/db/username`
   - `/bibleai/db/password` (마스킹 표시)
   - `/bibleai/db/name`
   - `/bibleai/db/sslmode`
4. ✅ 애플리케이션 실행 방법 안내

### 예상 출력

**성공 시**:
```
=========================================
AWS Parameter Store 로컬 테스트
=========================================

1️⃣  AWS 자격 증명 확인...
✅ AWS 자격 증명 확인 완료

2️⃣  Parameter Store 접근 테스트...
   ✅ /bibleai/db/host = localhost
   ✅ /bibleai/db/port = 5432
   ✅ /bibleai/db/username = bibleai
   ✅ /bibleai/db/password = ***
   ✅ /bibleai/db/name = bibleai
   ✅ /bibleai/db/sslmode = disable

=========================================
✅ 모든 테스트 통과!
=========================================

애플리케이션 실행:
  export AWS_PROFILE=default
  export USE_AWS_PARAMS=true
  ./server.sh start
```

**실패 시**:
```
=========================================
AWS Parameter Store 로컬 테스트
=========================================

1️⃣  AWS 자격 증명 확인...
❌ AWS 자격 증명이 설정되지 않았습니다.
   설정: aws configure --profile default
```

---

## 문제 해결

### 1. "NoCredentialProviders: no valid providers in chain"

**원인**: AWS 자격 증명이 설정되지 않음

**해결**:
```bash
aws configure
# Access Key ID와 Secret Access Key 입력
```

### 2. "AccessDeniedException: User is not authorized"

**원인**: IAM 사용자에게 SSM 권한이 없음

**해결**:
1. AWS Console → IAM → Users → 사용자 선택
2. Permissions → Add permissions → Attach policies directly
3. `BibleAI-ParameterStore-ReadOnly` 정책 연결

또는 인라인 정책 추가:
```json
{
    "Version": "2012-10-17",
    "Statement": [{
        "Effect": "Allow",
        "Action": ["ssm:GetParameter", "ssm:GetParameters"],
        "Resource": "arn:aws:ssm:ap-northeast-2:*:parameter/bibleai/*"
    }]
}
```

### 3. "ParameterNotFound"

**원인**: Parameter Store에 파라미터가 없음

**해결**:
```bash
# 파라미터 생성
aws ssm put-parameter \
  --name "/bibleai/db/password" \
  --value "your-password" \
  --type "SecureString"

# 전체 파라미터 목록 확인
aws ssm describe-parameters --filters "Key=Name,Values=/bibleai"
```

### 4. "InvalidSignatureException"

**원인**: 시스템 시간이 AWS 서버 시간과 맞지 않음

**해결**:
```bash
# macOS
sudo sntp -sS time.apple.com

# Ubuntu
sudo ntpdate ntp.ubuntu.com

# Windows
# 설정 → 시간 및 언어 → 자동으로 시간 설정
```

### 5. "Region not found"

**원인**: AWS 리전이 설정되지 않음

**해결**:
```bash
# 리전 명시적으로 설정
aws configure set region ap-northeast-2

# 또는 환경 변수로 설정
export AWS_REGION=ap-northeast-2
```

---

## 보안 고려사항

### Access Key 관리

✅ **권장사항**:
- Access Key를 안전한 비밀번호 관리자에 저장
- 로컬 개발용 IAM 사용자는 Parameter Store 읽기 권한만 부여
- 주기적으로 Access Key 교체 (90일마다)

❌ **절대 금지**:
- Access Key를 Git에 커밋
- Access Key를 코드에 하드코딩
- 프로덕션 관리자 권한을 로컬 개발에 사용

### `.aws/credentials` 파일 보호

```bash
# 파일 권한 확인 (읽기 전용으로 설정)
chmod 600 ~/.aws/credentials
chmod 600 ~/.aws/config

# Git에서 제외 (이미 자동 제외되지만 확인)
echo ".aws/" >> ~/.gitignore_global
```

### IAM 사용자 권한 최소화 원칙

로컬 개발용 IAM 사용자에게는 **읽기 전용** 권한만 부여:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ssm:GetParameter",
                "ssm:GetParameters",
                "ssm:GetParametersByPath"
            ],
            "Resource": "arn:aws:ssm:ap-northeast-2:*:parameter/bibleai/*"
        }
    ]
}
```

❌ **주지 말아야 할 권한**:
- `ssm:PutParameter` (파라미터 생성/수정)
- `ssm:DeleteParameter` (파라미터 삭제)
- `ssm:*` (모든 SSM 권한)
- `*:*` (모든 AWS 권한)

---

## 요약 및 권장 워크플로우

### 최초 1회 설정

```bash
# 1. AWS CLI 설치
brew install awscli  # macOS

# 2. IAM 사용자 생성 및 권한 부여 (AWS Console)
# 3. AWS CLI 자격 증명 설정
aws configure
```

### 일상 개발

```bash
# 로컬 환경 변수로 개발 (빠르고 간단)
source .env  # .env 파일의 DB_PASSWORD 사용
./server.sh start
```

### 주간 AWS 통합 테스트

```bash
# 1. Parameter Store 접근 테스트
./development-only/test-aws-params.sh

# 2. 애플리케이션 AWS 모드 테스트
export USE_AWS_PARAMS=true
./server.sh start

# 3. 로그 확인
./server.sh logs

# 4. 테스트 완료 후 로컬 모드 복귀
unset USE_AWS_PARAMS
./server.sh restart
```

### 프로덕션 배포 전 확인

```bash
# 1. Parameter Store 파라미터 존재 확인
aws ssm get-parameters-by-path --path "/bibleai" --with-decryption

# 2. EC2 IAM 역할 권한 확인 (AWS Console)
# 3. 배포 후 로그 확인
ssh ec2-user@ec2-ip
sudo journalctl -u bibleai -f
```

---

**작성일**: 2025년 10월 2일
**프로젝트**: 주님말씀AI 웹앱
**참조 문서**: `docs/PARAMETER_STORE_SETUP.md`, `docs/DEPLOYMENT.md`
