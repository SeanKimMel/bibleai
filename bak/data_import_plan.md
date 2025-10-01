# 성경 및 찬송가 데이터 Import 계획서

## 🔍 연구 결과 요약

### 성경 데이터 소스
1. **MaatheusGois/bible** (GitHub)
   - **형식**: JSON API 
   - **한국어 지원**: ✅ (language id: "ko")
   - **구조**: 책별, 장별, 절별 세분화 가능
   - **장점**: REST API 형태로 바로 사용 가능, 오픈소스
   - **URL 패턴**: 
     ```
     전체: https://raw.githubusercontent.com/maatheusgois/bible/main/versions/ko/ko.json
     책별: .../ko/ko/{book-id}/{book-id}.json  
     절별: .../ko/ko/{book-id}/{chapter}/{verse}.json
     ```

2. **lifthrasiir/bible.mearie.org** (GitHub)
   - **형식**: Python 웹앱 + 데이터
   - **한국어 지원**: ✅ (여러 번역본)
   - **장점**: 한국어 특화, 여러 번역본 지원
   - **단점**: 데이터 추출 필요

### 찬송가 데이터 소스
1. **현재 상태**: 종합적인 오픈소스 한국어 찬송가 데이터베이스 **부족**
2. **대안 방법**:
   - 웹 스크래핑 (저작권 주의)
   - 수동 데이터 입력
   - 기존 앱/사이트와 협력

## 📋 Implementation 우선순위

### Phase 1: 성경 데이터 Import (우선순위: 높음)
- **소스**: MaatheusGois/bible GitHub API
- **방법**: JSON API 호출 후 로컬 DB 저장
- **예상 데이터량**: 31,000+ 구절
- **소요시간**: 1-2일

### Phase 2: 찬송가 데이터 Import (우선순위: 중간)  
- **방법**: 수동 입력 + 점진적 확장
- **초기 목표**: 인기 찬송가 50-100곡
- **소요시간**: 2-3일 (초기)

### Phase 3: 데이터 관리 시스템 (우선순위: 낮음)
- **기능**: 자동 동기화, 데이터 검증, 백업
- **소요시간**: 1주일

## 🛠️ 기술적 구현 방안

### 1. 성경 데이터 Import API
```go
// internal/handlers/bible_import.go
func ImportBibleData(c *gin.Context) {
    // GitHub API에서 한국어 성경 데이터 fetch
    // 66권의 책 정보를 순차적으로 가져와서
    // 로컬 PostgreSQL에 저장
}
```

### 2. 데이터베이스 스키마 확장
```sql
-- 성경 구절 테이블 확장
ALTER TABLE bible_verses ADD COLUMN book_id VARCHAR(10);
ALTER TABLE bible_verses ADD COLUMN book_name_korean VARCHAR(50);
ALTER TABLE bible_verses ADD COLUMN testament VARCHAR(10); -- 'old' or 'new'

-- 인덱스 추가
CREATE INDEX idx_bible_verses_book ON bible_verses(book_id);
CREATE INDEX idx_bible_verses_chapter ON bible_verses(chapter);
```

### 3. 찬송가 데이터 구조
```sql
-- 찬송가 테이블 확장
ALTER TABLE hymns ADD COLUMN composer VARCHAR(100);
ALTER TABLE hymns ADD COLUMN author VARCHAR(100);
ALTER TABLE hymns ADD COLUMN year INTEGER;
ALTER TABLE hymns ADD COLUMN tune_name VARCHAR(100);
```

## 📊 데이터 품질 및 저작권

### 성경 데이터
- **품질**: GitHub 오픈소스, 커뮤니티 검증
- **저작권**: 퍼블릭 도메인 (MIT 라이선스)
- **안정성**: 높음

### 찬송가 데이터  
- **품질**: 수동 검증 필요
- **저작권**: ⚠️ 주의 필요 (통합찬송가 저작권)
- **안정성**: 직접 관리 필요

## 🚀 실행 계획

### Step 1: 성경 데이터 Import 시스템 구축
1. Bible Import API 개발
2. 배치 처리 스크립트 작성  
3. 진행상황 모니터링 UI
4. 에러 처리 및 재시도 로직

### Step 2: 찬송가 데이터 시작
1. 찬송가 CRUD API 확장
2. 관리자 페이지 개발
3. 초기 데이터 입력 도구
4. 사용자 기여 시스템 (향후)

### Step 3: 통합 및 최적화
1. 통합 검색 기능
2. 성능 최적화 (인덱스, 캐싱)
3. API 문서화
4. 백업 및 복구 시스템

## 💾 예상 데이터 규모

| 데이터 유형 | 예상 레코드 수 | 저장 공간 | Import 시간 |
|------------|---------------|-----------|-------------|
| 성경 구절   | ~31,000      | ~50MB     | 2-3시간     |
| 찬송가 (초기)| ~100        | ~5MB      | 1시간       |
| 찬송가 (목표)| ~600        | ~30MB     | 1일        |

## ⚠️ 리스크 및 고려사항

### 기술적 리스크
- API 속도 제한 (GitHub)
- 네트워크 연결 불안정
- 데이터 형식 불일치

### 법적 리스크
- 찬송가 저작권 문제
- 성경 번역본 라이선스

### 해결 방안
- 순차적 API 호출 (rate limiting 준수)
- 재시도 메커니즘 구현
- 저작권 명시 및 출처 표기
- 공정 이용 원칙 준수

## 📈 성공 지표

### Phase 1 완료 기준
- [ ] 성경 66권 전체 데이터 import 완료
- [ ] 검색 기능 정상 작동
- [ ] 성능 테스트 통과 (< 500ms 응답)

### Phase 2 완료 기준  
- [ ] 찬송가 100곡 데이터 입력 완료
- [ ] 찬송가 검색 및 재생 기능 구현
- [ ] 사용자 피드백 수집 시스템

---

**작성일**: 2025년 1월 15일  
**검토일**: 매주 월요일  
**담당자**: Claude AI + 개발팀