# 찬송가 키워드 시스템 설계 검토

## 🔴 현재 구조의 문제점
```sql
-- 현재: 1개 찬송가 = 1개 테마만 가능
hymns.theme = '예배/찬양'  -- 단일 값만 저장
```

**한계:**
- 찬송가 9번 "하늘에 가득 찬 영광의 하나님"
  - 현재: `theme = '예배/찬양'` (하나만)
  - 실제 필요: 예배, 찬양, 영광, 삼위일체, 지혜, 구원 등 여러 키워드

## 💡 가능한 해결 방안들

### 방안 1: PostgreSQL JSONB 필드 사용
```sql
ALTER TABLE hymns ADD COLUMN keywords JSONB;

-- 데이터 예시
UPDATE hymns SET keywords = '["예배", "찬양", "영광", "삼위일체"]'::jsonb WHERE number = 9;

-- 검색 쿼리
SELECT * FROM hymns WHERE keywords @> '"찬양"';  -- JSONB 연산자
```

**장점:**
- 구조 변경 최소화
- 유연한 데이터 저장
- PostgreSQL 네이티브 지원
- 인덱싱 가능 (GIN index)

**단점:**
- JOIN 불가 (통계 어려움)
- 키워드 정규화 어려움

### 방안 2: 정규화된 매핑 테이블 (다대다)
```sql
-- 키워드 마스터
CREATE TABLE keywords (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) UNIQUE,
    category VARCHAR(20)
);

-- 찬송가-키워드 매핑
CREATE TABLE hymn_keywords (
    hymn_id INTEGER REFERENCES hymns(id),
    keyword_id INTEGER REFERENCES keywords(id),
    PRIMARY KEY (hymn_id, keyword_id)
);
```

**장점:**
- 완전한 정규화
- 통계 쿼리 쉬움
- 키워드 중앙 관리
- 확장성 좋음

**단점:**
- 테이블 추가 필요
- JOIN 필요

### 방안 3: 태그 문자열 (구분자 사용)
```sql
ALTER TABLE hymns ALTER COLUMN theme TYPE TEXT;

-- 데이터 예시
UPDATE hymns SET theme = '예배,찬양,영광,삼위일체' WHERE number = 9;

-- 검색
SELECT * FROM hymns WHERE theme LIKE '%찬양%';
```

**장점:**
- 가장 간단한 구현
- 기존 필드 활용

**단점:**
- 검색 성능 나쁨
- 정규화 위반
- 통계 어려움

### 방안 4: 하이브리드 (메인 테마 + 키워드들)
```sql
-- theme: 대표 테마 1개 (기존 API 호환)
-- keywords: 추가 키워드들 (JSONB 또는 매핑 테이블)

ALTER TABLE hymns ADD COLUMN keywords JSONB;
-- 또는
CREATE TABLE hymn_keywords (...);
```

**장점:**
- 기존 API 100% 호환
- 점진적 마이그레이션 가능
- 유연성 + 호환성

**단점:**
- 약간의 중복성

## 🎯 추천 방안 비교

| 기준 | JSONB | 매핑 테이블 | 태그 문자열 | 하이브리드 |
|------|-------|------------|------------|-----------|
| 구현 난이도 | ⭐⭐ | ⭐⭐⭐ | ⭐ | ⭐⭐⭐ |
| 검색 성능 | ⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐ | ⭐⭐⭐ |
| 확장성 | ⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐ | ⭐⭐⭐⭐ |
| API 호환성 | ⭐⭐ | ⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
| 데이터 정규화 | ⭐⭐ | ⭐⭐⭐⭐ | ⭐ | ⭐⭐⭐ |

## 🤔 고려사항

1. **현재 사용 패턴**
   - 주로 테마별 검색?
   - 키워드 조합 검색 필요?
   - 통계/분석 중요도?

2. **기술 스택**
   - PostgreSQL 버전? (JSONB 지원)
   - ORM 사용? (Go의 경우)
   - 프론트엔드 요구사항?

3. **성능 요구사항**
   - 동시 사용자 수?
   - 검색 빈도?
   - 응답 시간 목표?

4. **유지보수**
   - 키워드 추가/수정 빈도?
   - 관리 UI 필요?
   - 데이터 일관성 중요도?