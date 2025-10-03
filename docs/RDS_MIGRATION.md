# AWS RDS 마이그레이션 전략

## 🎯 개요

로컬 PostgreSQL에서 AWS RDS PostgreSQL로 마이그레이션하는 전략 및 절차를 설명합니다.

### 왜 RDS로 마이그레이션하는가?

**현재 문제점 (EC2 내장 PostgreSQL)**:
- ❌ 백업 관리 수동 작업
- ❌ 고가용성(HA) 미지원
- ❌ 자동 패치/업그레이드 불가
- ❌ EC2 장애 시 DB도 같이 중단
- ❌ 수동 모니터링 필요

**RDS의 장점**:
- ✅ 자동 백업 (최대 35일 보관)
- ✅ Multi-AZ 고가용성
- ✅ 자동 패치 및 업그레이드
- ✅ Read Replica 지원 (확장 가능)
- ✅ CloudWatch 통합 모니터링
- ✅ 포인트인타임 복구 (PITR)

---

## 📊 비용 분석

### RDS 비용 (서울 리전)

**db.t3.micro (추천)**:
- **사양**: 2 vCPU, 1GB RAM
- **용량**: 20GB SSD (gp2)
- **비용**:
  - 인스턴스: $0.017/시간 × 730시간 = **$12.41/월**
  - 스토리지: 20GB × $0.138/GB = **$2.76/월**
  - **총 비용: ~$15/월** (약 20,000원)

**db.t4g.micro (ARM 기반, 더 저렴)**:
- **사양**: 2 vCPU, 1GB RAM (Graviton2)
- **비용**: $0.014/시간 × 730시간 = **$10.22/월**
- **총 비용: ~$13/월** (약 17,000원)

### 비용 비교

| 항목 | EC2 내장 PostgreSQL | RDS db.t4g.micro |
|------|---------------------|------------------|
| DB 비용 | $0 | $13/월 |
| 백업 스토리지 | 수동 (S3 비용) | 자동 포함 |
| 관리 시간 | 주 2-3시간 | 0시간 |
| 고가용성 | 불가 | Multi-AZ (+$13/월) |
| **총 비용** | $0 (관리 부담) | **$13/월** |

**결론**: 월 $13로 관리 부담 제로 + 고가용성 확보

---

## 🗓️ 마이그레이션 타임라인

### Phase 1: 준비 (1-2일)
- RDS 인스턴스 생성
- Security Group 설정
- 연결 테스트

### Phase 2: 데이터 마이그레이션 (1-2시간)
- 로컬 DB 덤프
- RDS로 복원
- 데이터 검증

### Phase 3: 애플리케이션 전환 (30분)
- Parameter Store 업데이트
- 애플리케이션 재시작
- 연결 확인

### Phase 4: 검증 및 정리 (1일)
- API 테스트
- 성능 모니터링
- EC2 PostgreSQL 정리

**총 소요 시간**: 2-3일 (다운타임: 30분 이하)

---

## 📋 Phase 1: RDS 인스턴스 생성

### 1.1 RDS 인스턴스 생성 (AWS Console)

**AWS Console → RDS → Create database**

#### 기본 설정
- **Engine type**: PostgreSQL
- **Version**: PostgreSQL 16.x (최신 마이너 버전)
- **Templates**: Free tier (테스트용) 또는 Dev/Test

#### DB 인스턴스 설정
- **DB instance identifier**: `bibleai-db`
- **Master username**: `bibleai`
- **Master password**: 안전한 비밀번호 생성 및 저장
- **DB instance class**:
  - db.t4g.micro (권장, ARM 기반)
  - 또는 db.t3.micro (x86 기반)

#### 스토리지
- **Storage type**: General Purpose SSD (gp2)
- **Allocated storage**: 20 GB
- **Storage autoscaling**: 활성화
  - Maximum storage threshold: 100 GB

#### 연결
- **VPC**: Default VPC
- **Subnet group**: default
- **Public access**: Yes (개발 편의, 프로덕션은 No)
- **VPC security group**: Create new
  - Security group name: `bibleai-rds-sg`
- **Availability Zone**: No preference

#### 데이터베이스 옵션
- **Initial database name**: `bibleai`
- **DB parameter group**: default.postgres16
- **Option group**: default:postgres-16

#### 백업
- **Backup retention period**: 7 days (프로덕션: 30일)
- **Backup window**: 자동 (새벽 시간대)
- **Copy tags to snapshots**: 활성화

#### 모니터링
- **Enable Enhanced Monitoring**: 활성화
- **Monitoring Role**: Create new role
- **Granularity**: 60 seconds

#### 기타 설정
- **Enable auto minor version upgrade**: 활성화
- **Maintenance window**: 자동 (일요일 새벽)

### 1.2 Security Group 설정

RDS 생성 후 Security Group 편집:

**Inbound Rules**:
```
Type: PostgreSQL
Protocol: TCP
Port: 5432
Source:
  - EC2 인스턴스 Security Group (프로덕션)
  - 내 IP 주소 (개발/관리용)
```

**AWS CLI로 설정**:
```bash
# RDS Security Group ID 확인
RDS_SG_ID=$(aws ec2 describe-security-groups \
  --filters "Name=group-name,Values=bibleai-rds-sg" \
  --query "SecurityGroups[0].GroupId" --output text)

# EC2 Security Group ID 확인
EC2_SG_ID=$(aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=bibleai-server" \
  --query "Reservations[0].Instances[0].SecurityGroups[0].GroupId" \
  --output text)

# EC2에서 RDS 접근 허용
aws ec2 authorize-security-group-ingress \
  --group-id $RDS_SG_ID \
  --protocol tcp \
  --port 5432 \
  --source-group $EC2_SG_ID

# 내 IP에서 RDS 접근 허용 (관리용)
MY_IP=$(curl -s https://checkip.amazonaws.com)
aws ec2 authorize-security-group-ingress \
  --group-id $RDS_SG_ID \
  --protocol tcp \
  --port 5432 \
  --cidr $MY_IP/32
```

### 1.3 RDS 엔드포인트 확인

```bash
# RDS 엔드포인트 조회
aws rds describe-db-instances \
  --db-instance-identifier bibleai-db \
  --query "DBInstances[0].Endpoint.Address" \
  --output text

# 예시 출력:
# bibleai-db.c9akrhsi7hpq.ap-northeast-2.rds.amazonaws.com
```

### 1.4 로컬에서 RDS 연결 테스트

```bash
# PostgreSQL 클라이언트로 연결 테스트
psql -h bibleai-db.c9akrhsi7hpq.ap-northeast-2.rds.amazonaws.com \
     -U bibleai \
     -d bibleai

# 연결 성공 시:
# Password for user bibleai: [비밀번호 입력]
# psql (16.x)
# SSL connection (protocol: TLSv1.3, cipher: TLS_AES_256_GCM_SHA384, compression: off)
# Type "help" for help.
#
# bibleai=>
```

---

## 📋 Phase 2: 데이터 마이그레이션

### 2.1 로컬 PostgreSQL 백업

#### 스키마 + 데이터 전체 백업

```bash
# 전체 백업 (스키마 + 데이터)
pg_dump -h localhost -U bibleai -d bibleai \
  --no-owner --no-acl \
  -F c -f bibleai_full_backup.dump

# 또는 SQL 포맷 (읽기 쉬움)
pg_dump -h localhost -U bibleai -d bibleai \
  --no-owner --no-acl \
  -f bibleai_full_backup.sql
```

**옵션 설명**:
- `--no-owner`: OWNER 구문 제외 (RDS 관리자가 다름)
- `--no-acl`: GRANT/REVOKE 구문 제외
- `-F c`: Custom 포맷 (압축, 병렬 복원 가능)

#### 백업 파일 확인

```bash
ls -lh bibleai_full_backup.*
# -rw-r--r--  1 user  staff   15M 10월  2 10:30 bibleai_full_backup.dump
```

### 2.2 RDS로 데이터 복원

#### Custom 포맷 복원

```bash
# RDS 엔드포인트 저장
export RDS_HOST=bibleai-db.c9akrhsi7hpq.ap-northeast-2.rds.amazonaws.com

# 복원 실행 (병렬 작업 4개)
pg_restore -h $RDS_HOST -U bibleai -d bibleai \
  --no-owner --no-acl \
  -j 4 \
  bibleai_full_backup.dump

# 비밀번호 입력
```

#### SQL 포맷 복원

```bash
psql -h $RDS_HOST -U bibleai -d bibleai \
  -f bibleai_full_backup.sql
```

### 2.3 데이터 검증

#### 테이블 목록 확인

```bash
psql -h $RDS_HOST -U bibleai -d bibleai -c "\dt"
```

#### 데이터 개수 확인

```bash
# 로컬 DB
psql -h localhost -U bibleai -d bibleai -c "
SELECT
  'bible_verses' AS table_name, COUNT(*) AS count FROM bible_verses
UNION ALL
SELECT 'hymns', COUNT(*) FROM hymns
UNION ALL
SELECT 'prayers', COUNT(*) FROM prayers
UNION ALL
SELECT 'tags', COUNT(*) FROM tags;
"

# RDS
psql -h $RDS_HOST -U bibleai -d bibleai -c "
SELECT
  'bible_verses' AS table_name, COUNT(*) AS count FROM bible_verses
UNION ALL
SELECT 'hymns', COUNT(*) FROM hymns
UNION ALL
SELECT 'prayers', COUNT(*) FROM prayers
UNION ALL
SELECT 'tags', COUNT(*) FROM tags;
"

# 두 결과를 비교하여 동일한지 확인
```

#### 샘플 데이터 확인

```bash
# 성경 구절 샘플
psql -h $RDS_HOST -U bibleai -d bibleai -c "
SELECT book_id, chapter, verse, LEFT(content, 50)
FROM bible_verses
LIMIT 5;
"

# 찬송가 샘플
psql -h $RDS_HOST -U bibleai -d bibleai -c "
SELECT number, title
FROM hymns
ORDER BY number
LIMIT 5;
"
```

---

## 📋 Phase 3: 애플리케이션 전환

### 3.1 Parameter Store 업데이트

#### 기존 파라미터 백업

```bash
# 기존 파라미터 값 저장 (안전장치)
aws ssm get-parameters-by-path --path "/bibleai" --with-decryption > param_backup.json
```

#### RDS 연결 정보로 업데이트

```bash
# RDS 엔드포인트
RDS_ENDPOINT=bibleai-db.c9akrhsi7hpq.ap-northeast-2.rds.amazonaws.com

# 호스트 업데이트
aws ssm put-parameter \
  --name "/bibleai/db/host" \
  --value "$RDS_ENDPOINT" \
  --type "String" \
  --overwrite

# 포트 (기본값 그대로)
aws ssm put-parameter \
  --name "/bibleai/db/port" \
  --value "5432" \
  --type "String" \
  --overwrite

# 사용자명 (동일)
aws ssm put-parameter \
  --name "/bibleai/db/username" \
  --value "bibleai" \
  --type "String" \
  --overwrite

# 비밀번호 (RDS 마스터 비밀번호)
aws ssm put-parameter \
  --name "/bibleai/db/password" \
  --value "YOUR_RDS_MASTER_PASSWORD" \
  --type "SecureString" \
  --overwrite

# 데이터베이스명 (동일)
aws ssm put-parameter \
  --name "/bibleai/db/name" \
  --value "bibleai" \
  --type "String" \
  --overwrite

# SSL 모드 (RDS는 require 권장)
aws ssm put-parameter \
  --name "/bibleai/db/sslmode" \
  --value "require" \
  --type "String" \
  --overwrite
```

#### 파라미터 확인

```bash
# 업데이트된 파라미터 확인 (비밀번호 제외)
aws ssm get-parameters-by-path --path "/bibleai" \
  --query "Parameters[?Name!='/bibleai/db/password'].[Name,Value]" \
  --output table
```

### 3.2 EC2에서 애플리케이션 재시작

#### SSH 접속

```bash
ssh -i your-key.pem ec2-user@ec2-public-ip
```

#### 애플리케이션 재시작

```bash
# Systemd 서비스 재시작
sudo systemctl restart bibleai

# 로그 확인
sudo journalctl -u bibleai -f
```

**예상 로그 (성공)**:
```
🔐 AWS Parameter Store 모드 활성화
🔐 AWS Parameter Store에서 DB 설정 로드 중...
✅ AWS Parameter Store에서 DB 설정 로드 완료
연결 문자열: host=bibleai-db.c9akrhsi7hpq.ap-northeast-2.rds.amazonaws.com port=5432 user=bibleai password=*** dbname=bibleai sslmode=require
데이터베이스에 성공적으로 연결되었습니다.
Connection Pool 설정: Min=10, Max=20, MaxLifetime=5m, IdleTimeout=무제한
초기 연결 풀 생성 중 (10개)...
✅ 초기 연결 풀 생성 완료 (10개 대기 중)
서버가 :8080 포트에서 시작됩니다...
```

### 3.3 연결 확인

```bash
# Health check
curl http://localhost:8080/health

# 성경 검색 API 테스트
curl "http://localhost:8080/api/bible/search?q=사랑" | jq '.total'

# 찬송가 검색 API 테스트
curl "http://localhost:8080/api/hymns/search?q=주님" | jq 'length'
```

---

## 📋 Phase 4: 검증 및 정리

### 4.1 API 통합 테스트

```bash
# 서버 관리 스크립트로 전체 테스트
./server.sh test

# 예상 출력:
# ========================================
# 🧪 BibleAI API 테스트
# ========================================
#
# 1. Health Check 테스트
# ✅ 서버 정상 작동 중
#
# 2. 성경 검색 API 테스트
# ✅ 성경 검색 성공: 100개 결과
#
# 3. 기도문 검색 API 테스트
# ✅ 기도문 검색 완료
#
# ========================================
# ✅ 모든 테스트 통과!
# ========================================
```

### 4.2 성능 모니터링 (24시간)

#### CloudWatch 메트릭 확인

**AWS Console → RDS → bibleai-db → Monitoring**

주요 메트릭:
- **CPUUtilization**: 평균 5-10% 이하 정상
- **DatabaseConnections**: 10-20개 연결 유지 확인
- **FreeableMemory**: 500MB 이상 유지
- **ReadLatency/WriteLatency**: 10ms 이하 정상

#### 애플리케이션 로그 모니터링

```bash
# 실시간 로그 확인 (에러 모니터링)
sudo journalctl -u bibleai -f | grep -i error

# 최근 1시간 에러 로그
sudo journalctl -u bibleai --since "1 hour ago" | grep -i error
```

### 4.3 EC2 PostgreSQL 정리

**RDS 마이그레이션 성공 확인 후 EC2 PostgreSQL 정리**:

```bash
# PostgreSQL 서비스 중지
sudo systemctl stop postgresql
sudo systemctl disable postgresql

# PostgreSQL 데이터 백업 (안전장치)
sudo tar -czf /home/ec2-user/postgres_backup_$(date +%Y%m%d).tar.gz \
  /var/lib/pgsql

# PostgreSQL 패키지 제거 (선택사항, 나중에 실행 권장)
# sudo yum remove -y postgresql16 postgresql16-server
```

**중요**: PostgreSQL 제거는 RDS 안정성이 1주일 이상 확인된 후 진행 권장

---

## 🔄 롤백 계획

마이그레이션 실패 시 EC2 PostgreSQL로 빠르게 복귀하는 절차입니다.

### 롤백 시나리오

1. **RDS 연결 실패**
2. **데이터 불일치 발견**
3. **성능 문제 발생**

### 롤백 절차 (5분 이내)

#### 1단계: Parameter Store 복원

```bash
# 백업한 파라미터로 복원
aws ssm put-parameter --name "/bibleai/db/host" --value "localhost" --type "String" --overwrite
aws ssm put-parameter --name "/bibleai/db/sslmode" --value "disable" --type "String" --overwrite
```

#### 2단계: EC2 PostgreSQL 재시작

```bash
# PostgreSQL 서비스 시작
sudo systemctl start postgresql

# 데이터 확인
psql -U bibleai -d bibleai -c "\dt"
```

#### 3단계: 애플리케이션 재시작

```bash
sudo systemctl restart bibleai
sudo journalctl -u bibleai -f
```

#### 4단계: 연결 확인

```bash
curl http://localhost:8080/health
```

---

## 🔐 보안 강화

### RDS 보안 체크리스트

#### ✅ 완료해야 할 항목

- [ ] **Public access 비활성화** (프로덕션)
  - EC2와 같은 VPC 내에서만 접근

- [ ] **SSL/TLS 연결 강제**
  ```sql
  -- RDS Parameter Group에서 설정
  rds.force_ssl = 1
  ```

- [ ] **마스터 비밀번호 교체**
  - 초기 비밀번호를 강력한 비밀번호로 변경

- [ ] **암호화 활성화**
  - Storage encryption (생성 시 설정)
  - SSL in transit (sslmode=require)

- [ ] **백업 암호화**
  - 자동 백업 암호화 활성화

- [ ] **Monitoring 알림 설정**
  - CloudWatch Alarms 설정
  - CPU > 80%, Connections > 80 등

### SSL 연결 설정

#### 애플리케이션에서 SSL 연결 강제

Parameter Store에서 sslmode 업데이트:
```bash
aws ssm put-parameter \
  --name "/bibleai/db/sslmode" \
  --value "require" \
  --type "String" \
  --overwrite
```

RDS 인증서 다운로드 (선택사항, verify-full 사용 시):
```bash
wget https://truststore.pki.rds.amazonaws.com/ap-northeast-2/ap-northeast-2-bundle.pem
```

---

## 📊 모니터링 및 알림 설정

### CloudWatch Alarms 생성

#### 1. CPU 사용률 알림

```bash
aws cloudwatch put-metric-alarm \
  --alarm-name bibleai-rds-high-cpu \
  --alarm-description "RDS CPU > 80%" \
  --metric-name CPUUtilization \
  --namespace AWS/RDS \
  --statistic Average \
  --period 300 \
  --threshold 80 \
  --comparison-operator GreaterThanThreshold \
  --dimensions Name=DBInstanceIdentifier,Value=bibleai-db \
  --evaluation-periods 2 \
  --alarm-actions arn:aws:sns:ap-northeast-2:ACCOUNT_ID:bibleai-alerts
```

#### 2. 연결 수 알림

```bash
aws cloudwatch put-metric-alarm \
  --alarm-name bibleai-rds-high-connections \
  --alarm-description "RDS Connections > 80" \
  --metric-name DatabaseConnections \
  --namespace AWS/RDS \
  --statistic Average \
  --period 300 \
  --threshold 80 \
  --comparison-operator GreaterThanThreshold \
  --dimensions Name=DBInstanceIdentifier,Value=bibleai-db \
  --evaluation-periods 2
```

#### 3. 저장공간 알림

```bash
aws cloudwatch put-metric-alarm \
  --alarm-name bibleai-rds-low-storage \
  --alarm-description "RDS Free Storage < 2GB" \
  --metric-name FreeStorageSpace \
  --namespace AWS/RDS \
  --statistic Average \
  --period 300 \
  --threshold 2147483648 \
  --comparison-operator LessThanThreshold \
  --dimensions Name=DBInstanceIdentifier,Value=bibleai-db \
  --evaluation-periods 1
```

---

## 🚀 고급 기능 (향후)

### Multi-AZ 배포 (고가용성)

**비용**: 기존 비용 × 2 (약 $26/월)

**활성화 방법**:
```bash
aws rds modify-db-instance \
  --db-instance-identifier bibleai-db \
  --multi-az \
  --apply-immediately
```

**장점**:
- 자동 장애 조치 (1-2분 내)
- 데이터 손실 없음
- 패치/백업 시 다운타임 없음

### Read Replica (읽기 확장)

**비용**: 기존 비용과 동일 (약 $13/월)

**생성 방법**:
```bash
aws rds create-db-instance-read-replica \
  --db-instance-identifier bibleai-db-replica \
  --source-db-instance-identifier bibleai-db \
  --db-instance-class db.t4g.micro \
  --availability-zone ap-northeast-2c
```

**사용 사례**:
- 검색 API는 Read Replica에서 처리
- 쓰기 작업만 Primary에서 처리
- 부하 분산 효과

---

## 📋 마이그레이션 체크리스트

### 사전 준비
- [ ] RDS 인스턴스 생성 완료
- [ ] Security Group 설정 완료
- [ ] 로컬에서 RDS 연결 테스트 성공
- [ ] EC2에서 RDS 연결 테스트 성공

### 데이터 마이그레이션
- [ ] 로컬 PostgreSQL 백업 완료
- [ ] RDS로 데이터 복원 완료
- [ ] 테이블 개수 확인 (로컬 vs RDS)
- [ ] 데이터 개수 확인 (각 테이블)
- [ ] 샘플 데이터 검증 완료

### 애플리케이션 전환
- [ ] Parameter Store 백업 완료
- [ ] Parameter Store 업데이트 완료
- [ ] 애플리케이션 재시작 성공
- [ ] 연결 로그 확인 (RDS 엔드포인트 표시)
- [ ] Health check 성공

### 검증
- [ ] API 테스트 전체 통과
- [ ] 웹 페이지 정상 작동 확인
- [ ] 24시간 모니터링 완료
- [ ] CloudWatch 알림 설정 완료

### 정리
- [ ] EC2 PostgreSQL 서비스 중지
- [ ] EC2 PostgreSQL 데이터 백업 완료
- [ ] 롤백 계획 문서화 완료
- [ ] 마이그레이션 완료 보고서 작성

---

## 🎯 성공 기준

### 기술적 성공 기준
1. ✅ RDS 연결 성공률 99.9% 이상
2. ✅ API 응답 시간 500ms 이하 유지
3. ✅ 데이터 무결성 100% (로컬 vs RDS)
4. ✅ 다운타임 30분 이하

### 운영적 성공 기준
1. ✅ 자동 백업 정상 작동
2. ✅ CloudWatch 모니터링 정상
3. ✅ 알림 시스템 작동 확인
4. ✅ 롤백 계획 검증 완료

---

**작성일**: 2025년 10월 2일
**프로젝트**: 주님말씀AI 웹앱
**목표**: EC2 PostgreSQL → AWS RDS 마이그레이션
**예상 비용**: $13/월 (db.t4g.micro)
**예상 소요 시간**: 2-3일 (다운타임 30분 이하)
