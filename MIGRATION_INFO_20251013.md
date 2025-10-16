# 데이터 마이그레이션 정보
작성일: 2025-10-13

## 📊 주요 변경 테이블

### 1. **hymns 테이블** (핵심 변경)
- **변경된 필드**: `theme`
- **변경 내용**:
  - 645개 모든 찬송가의 theme 필드 업데이트 완료
  - 15개 카테고리로 체계적 분류
- **데이터 형식**: `VARCHAR(100)`
- **예시값**:
  - `예배/찬양`
  - `구원/은혜`
  - `인도/보호`
  - `구원/십자가`
  - `회개/용서`

### 2. **keywords 테이블** (유지)
- 기존 테이블 그대로 유지
- 향후 확장 가능한 구조로 보존

## ❌ 삭제된 테이블
```sql
-- 이미 삭제 완료
DROP TABLE IF EXISTS hymn_keywords CASCADE;
DROP TABLE IF EXISTS prayer_keywords CASCADE;
DROP TABLE IF EXISTS bible_keywords CASCADE;
DROP TABLE IF EXISTS hymn_keywords_bak CASCADE;
DROP TABLE IF EXISTS prayer_keywords_bak CASCADE;
DROP TABLE IF EXISTS bible_keywords_bak CASCADE;
```

## ✅ 마이그레이션 실행 파일

### 1. **테이블 스키마 변경**
```bash
# 실행할 SQL 파일
/workspace/bibleai/migrations/011_hymn_themes_update.sql
```

### 2. **데이터 업데이트 스크립트**
```bash
# Python 스크립트 실행 (이미 완료됨)
python3 /workspace/bibleai/scripts/update_hymn_themes.py
```

## 🔧 마이그레이션 명령어

### 로컬에서 실행 시:
```bash
# 1. 테이블 스키마 업데이트
export PGPASSWORD=bibleai
psql -h localhost -U bibleai -d bibleai < /workspace/bibleai/migrations/011_hymn_themes_update.sql

# 2. 데이터 업데이트 (Python 필요)
pip3 install psycopg2-binary
python3 /workspace/bibleai/scripts/update_hymn_themes.py
```

### 프로덕션 서버에서 실행 시:
```bash
# EC2 서버 접속
ssh -i /path/to/key.pem ec2-user@13.209.47.72

# 데이터베이스 백업 (중요!)
pg_dump -h localhost -U bibleai -d bibleai > backup_$(date +%Y%m%d_%H%M%S).sql

# 마이그레이션 실행
psql -h localhost -U bibleai -d bibleai < migrations/011_hymn_themes_update.sql
```

## 📈 마이그레이션 결과 확인

### 데이터 검증 쿼리:
```sql
-- 1. Theme 분포 확인
SELECT theme, COUNT(*) as count
FROM hymns
WHERE theme IS NOT NULL
GROUP BY theme
ORDER BY count DESC;

-- 2. Theme 통계 함수 실행
SELECT * FROM get_theme_statistics();

-- 3. 특정 Theme의 찬송가 확인
SELECT number, title, theme
FROM hymns
WHERE theme LIKE '%찬양%'
LIMIT 10;
```

## 🎯 예상 결과

### Theme 분포:
- 예배/찬양: 185개 (28.7%)
- 구원/은혜: 126개 (19.5%)
- 인도/보호: 72개 (11.2%)
- 구원/십자가: 61개 (9.5%)
- 회개/용서: 45개 (7.0%)
- 기타: 156개 (24.1%)

총 645개 찬송가 모두 theme 할당 완료

## ⚠️ 주의사항
1. 백업 필수 - 마이그레이션 전 반드시 데이터베이스 백업
2. API 호환성 - 기존 API와 100% 호환 (테스트 완료)
3. 롤백 계획 - 백업 파일로 복원 가능

## 📞 문의
문제 발생 시 연락처: [개발팀]