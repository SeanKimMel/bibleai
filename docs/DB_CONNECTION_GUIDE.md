# 데이터베이스 연결 및 Connection Pool 가이드

## 📊 Go vs PHP: DB 연결 방식 비교

### PHP (전통적 방식)
```php
// 매 요청마다 새 연결 생성
$conn = new PDO("mysql:host=localhost;dbname=mydb", $user, $pass);
// 쿼리 실행
$result = $conn->query("SELECT * FROM users");
// 연결 종료
$conn = null;
```

**동작 방식**:
- 사용자 요청 → DB 연결 생성 → 쿼리 실행 → 연결 종료
- 동시 사용자 100명 = DB 연결 100개 생성/종료
- 연결 생성 오버헤드가 큼

### Go (Connection Pool 방식)
```go
// 애플리케이션 시작 시 1회만 Pool 생성
db, _ := sql.Open("postgres", connStr)

// 요청마다 Pool에서 연결 빌려 사용
row := db.QueryRow("SELECT * FROM users WHERE id = $1", id)
// 자동으로 Pool에 반환 (명시적 종료 불필요)
```

**동작 방식**:
- 서버 시작 → Connection Pool 생성 (예: 10개 유휴 연결 유지)
- 사용자 요청 → Pool에서 연결 빌림 → 쿼리 실행 → Pool에 반환
- 동시 사용자 100명 = Pool의 25개 연결을 재사용
- 연결 재사용으로 성능 향상

---

## ⚙️ 현재 Connection Pool 설정

`internal/database/db.go`에서 설정된 값:

```go
db.SetMaxOpenConns(25)                 // 최대 동시 연결 수
db.SetMaxIdleConns(10)                 // 유휴 연결 풀 크기
db.SetConnMaxLifetime(5 * time.Minute) // 연결 최대 수명 5분
db.SetConnMaxIdleTime(3 * time.Minute) // 유휴 연결 최대 시간 3분
```

### 각 설정의 의미

#### 1. `MaxOpenConns` (최대 동시 연결 수): 25
- **의미**: 동시에 열 수 있는 최대 DB 연결 수
- **동작**: 26번째 요청은 연결이 반환될 때까지 대기
- **권장값**: 예상 동시 사용자 수 × 0.5 ~ 1.0
  - 소규모 (< 50명): 10~25
  - 중규모 (50~200명): 25~50
  - 대규모 (> 200명): 50~100

#### 2. `MaxIdleConns` (유휴 연결 풀 크기): 10
- **의미**: 사용 후 Pool에 유지할 연결 수
- **동작**: 10개까지는 연결을 닫지 않고 재사용 대기
- **권장값**: MaxOpenConns의 30~50%
  - MaxOpen=25 → MaxIdle=10~12
  - 너무 낮으면: 연결 재생성 오버헤드
  - 너무 높으면: DB 리소스 낭비

#### 3. `ConnMaxLifetime` (연결 최대 수명): 5분
- **의미**: 연결이 생성된 후 최대 유지 시간
- **동작**: 5분 경과 시 자동으로 새 연결로 교체
- **권장값**: 3~10분
  - DB 재시작 대응
  - 오래된 연결 방지

#### 4. `ConnMaxIdleTime` (유휴 연결 최대 시간): 3분
- **의미**: 사용되지 않는 연결의 최대 대기 시간
- **동작**: 3분간 미사용 시 연결 종료
- **권장값**: 1~5분
  - 야간 등 트래픽 적을 때 리소스 절약

---

## 🔢 동시 사용자별 연결 수 시뮬레이션

### 시나리오 1: 동시 사용자 10명
```
Pool: [유휴 10개 준비]
요청 10개 → Pool에서 10개 빌림 → 쿼리 실행 (평균 50ms)
             → 10개 반환 → Pool: [유휴 10개]
실제 DB 연결: 10개 (재사용)
```

### 시나리오 2: 동시 사용자 100명
```
Pool: [유휴 10개 준비]
요청 100개 → 처음 10개: Pool에서 빌림
           → 다음 15개: 새 연결 생성 (Max 25까지)
           → 나머지 75개: 대기 (기존 연결 반환될 때까지)

쿼리 속도가 빠르면 (50ms):
- 1초에 20회 회전 가능
- 25개 연결로 500명 처리 가능

쿼리 속도가 느리면 (500ms):
- 1초에 2회 회전
- 25개 연결로 50명만 처리
```

### 시나리오 3: PHP 방식 (비교)
```
동시 사용자 100명 → DB 연결 100개 생성
                  → 연결 오버헤드 (각 100ms)
                  → 총 시간: 10초 (100ms × 100)

Go Pool 방식 → 25개 연결 재사용
            → 연결 오버헤드: 1회만 (최초)
            → 총 시간: 2.5초 (50ms × 50회 회전)
```

---

## 📈 성능 최적화 전략

### 1. **트래픽 모니터링 필수**
```bash
# PostgreSQL 현재 연결 수 확인
SELECT count(*) FROM pg_stat_activity WHERE datname = 'bibleai';

# 대기 중인 연결 확인
SELECT count(*) FROM pg_stat_activity WHERE wait_event IS NOT NULL;
```

### 2. **설정 값 조정 기준**

#### 🟢 연결 수 부족 징후
- 로그에 "waiting for available connection" 메시지
- 응답 시간 급증 (> 1초)
- **해결**: `MaxOpenConns` 증가 (25 → 50)

#### 🟡 DB 부하 과다 징후
- DB CPU 사용률 > 80%
- DB 메모리 부족
- **해결**: `MaxOpenConns` 감소, 쿼리 최적화

#### 🔴 연결 누수 징후
- DB 연결이 계속 증가
- 서버 재시작 전까지 연결 유지
- **해결**: 코드에서 `rows.Close()` 확인

### 3. **프로덕션 권장 설정**

```go
// 소규모 서비스 (< 100명 동시 접속)
db.SetMaxOpenConns(25)
db.SetMaxIdleConns(10)
db.SetConnMaxLifetime(5 * time.Minute)
db.SetConnMaxIdleTime(3 * time.Minute)

// 중규모 서비스 (100~500명)
db.SetMaxOpenConns(50)
db.SetMaxIdleConns(20)
db.SetConnMaxLifetime(5 * time.Minute)
db.SetConnMaxIdleTime(3 * time.Minute)

// 대규모 서비스 (> 500명)
db.SetMaxOpenConns(100)
db.SetMaxIdleConns(30)
db.SetConnMaxLifetime(5 * time.Minute)
db.SetConnMaxIdleTime(2 * time.Minute)
```

### 4. **DB 서버 리소스 고려**

PostgreSQL 기본 최대 연결 수: 100
```sql
-- 현재 max_connections 확인
SHOW max_connections;

-- 권장: 애플리케이션 MaxOpenConns < DB max_connections
-- 예: DB=100 → App1=25, App2=25, 여유=50
```

---

## 🔐 읽기 전용 권한 설정 (권장)

현재 기능(성경/찬송가/기도문 검색)은 읽기만 필요합니다.

### 프로덕션 DB 사용자 분리
```sql
-- 1. 읽기 전용 사용자 생성
CREATE USER bibleai_app WITH PASSWORD 'secure_password';

-- 2. 읽기 권한만 부여
GRANT CONNECT ON DATABASE bibleai TO bibleai_app;
GRANT USAGE ON SCHEMA public TO bibleai_app;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO bibleai_app;
GRANT SELECT ON ALL SEQUENCES IN SCHEMA public TO bibleai_app;

-- 3. 미래 테이블에도 자동 적용
ALTER DEFAULT PRIVILEGES IN SCHEMA public
GRANT SELECT ON TABLES TO bibleai_app;

-- 4. 관리자 계정은 별도 유지
-- bibleai 사용자: 데이터 관리용 (INSERT, UPDATE, DELETE)
-- bibleai_app 사용자: 애플리케이션용 (SELECT만)
```

### `.env` 설정
```bash
# 프로덕션 (읽기 전용)
LOCAL_DB_USER=bibleai_app
LOCAL_DB_PASSWORD=<실제_보안_비밀번호>

# 개발 (전체 권한)
LOCAL_DB_USER=bibleai
LOCAL_DB_PASSWORD=<실제_개발_비밀번호>
```

---

## 🧪 Connection Pool 테스트

### 1. 현재 설정 확인
```bash
# 서버 재시작 후 로그 확인
./server.sh restart
grep "Connection Pool" server.log

# 출력 예:
# Connection Pool 설정: MaxOpen=25, MaxIdle=10, MaxLifetime=5m
```

### 2. 부하 테스트 (Apache Bench)
```bash
# 동시 100명, 총 1000 요청
ab -n 1000 -c 100 http://localhost:8080/api/bible/search?q=사랑

# 결과 확인:
# - Requests per second (높을수록 좋음)
# - Connection Times (낮을수록 좋음)
```

### 3. DB 연결 모니터링
```bash
# 실시간 연결 수 확인 (1초마다)
watch -n 1 'psql -U bibleai -d bibleai -c "SELECT count(*) FROM pg_stat_activity WHERE datname = '\''bibleai'\'';"'
```

---

## 📚 참고 자료

- [Go database/sql 공식 문서](https://pkg.go.dev/database/sql)
- [PostgreSQL Connection Pooling](https://www.postgresql.org/docs/current/runtime-config-connection.html)
- [Connection Pool 모범 사례](https://go.dev/doc/database/manage-connections)

---

**작성일**: 2025-10-01
**프로젝트**: 주님말씀AI 웹앱
**버전**: v0.6.0
