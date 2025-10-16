# 🔄 키워드 시스템 전체 개편 체크리스트

## 📋 Phase 1: 현황 분석 및 백업

### 1.1 데이터 백업
- [ ] 전체 데이터베이스 백업
  ```bash
  pg_dump -h localhost -U bibleai -d bibleai > backup_$(date +%Y%m%d).sql
  ```
- [ ] 관련 테이블 개별 백업
  - [ ] keywords 테이블
  - [ ] tags 테이블
  - [ ] prayer_tags 테이블
  - [ ] hymns 테이블 (theme 필드)

### 1.2 영향받는 파일 목록 정리
- [ ] **Go 핸들러 파일**
  - [ ] `/internal/handlers/keywords.go`
  - [ ] `/internal/handlers/prayers.go`
  - [ ] `/internal/handlers/bible_import.go`
  - [ ] `/internal/handlers/hymns.go`
  - [ ] `/internal/handlers/pages.go`
  - [ ] `/cmd/server/main.go`

- [ ] **프론트엔드 템플릿**
  - [ ] `/web/templates/pages/home-content` (키워드 표시)
  - [ ] `/web/templates/pages/hymns.html`
  - [ ] `/web/templates/pages/prayers.html`
  - [ ] `/web/templates/pages/bible-search.html`

- [ ] **JavaScript 파일**
  - [ ] 키워드 클릭 이벤트 처리
  - [ ] API 호출 부분

## 📋 Phase 2: 데이터베이스 스키마 변경

### 2.1 keywords 테이블 확장
```sql
-- 새 컬럼 추가
ALTER TABLE keywords
ADD COLUMN hymn_numbers INTEGER[] DEFAULT '{}',
ADD COLUMN bible_refs JSONB DEFAULT '[]',
ADD COLUMN prayer_ids INTEGER[] DEFAULT '{}';

-- 인덱스 추가
CREATE INDEX idx_keywords_hymn_numbers ON keywords USING GIN(hymn_numbers);
CREATE INDEX idx_keywords_bible_refs ON keywords USING GIN(bible_refs);
```

### 2.2 데이터 마이그레이션
- [ ] tags → keywords 통합
  - [ ] tags 테이블 데이터를 keywords로 이전
  - [ ] 중복 제거
- [ ] 찬송가 매핑
  - [ ] theme 분석하여 hymn_numbers 배열 생성
  - [ ] 645개 찬송가 전체 매핑
- [ ] 성경 매핑
  - [ ] 하드코딩된 데이터 추출
  - [ ] bible_refs JSONB 형식으로 저장
- [ ] 기도문 매핑
  - [ ] prayer_tags 관계 → prayer_ids 배열로

### 2.3 불필요한 테이블 정리
- [ ] prayer_tags 테이블 삭제
- [ ] tags 테이블 삭제 (통합 후)

## 📋 Phase 3: API 수정

### 3.1 keywords.go 수정
- [ ] `GetAllKeywords()` - 새 필드 포함
- [ ] `GetFeaturedKeywords()` - 새 필드 포함
- [ ] `GetKeywordContentCounts()` - 실제 데이터 반환
  ```go
  // 더미 데이터 제거, 배열 길이 반환
  counts["hymns"] = len(hymn_numbers)
  counts["verses"] = len(bible_refs)
  counts["prayers"] = len(prayer_ids)
  ```

### 3.2 새 API 추가
- [ ] `/api/keywords/:keyword/hymns` - 키워드별 찬송가
- [ ] `/api/keywords/:keyword/verses` - 키워드별 성경구절
- [ ] `/api/keywords/:keyword/prayers` - 키워드별 기도문
- [ ] `/api/keywords/:keyword/all` - 통합 조회

### 3.3 기존 API 수정
- [ ] `/api/verses/by-tag/:tag` - 하드코딩 제거
- [ ] `/api/prayers/by-tags` - keywords 사용으로 변경
- [ ] `/api/tags` - keywords로 리다이렉트

### 3.4 라우트 수정 (main.go)
- [ ] 새 엔드포인트 추가
- [ ] 구버전 API 호환성 유지 (필요시)

## 📋 Phase 4: 프론트엔드 수정

### 4.1 홈페이지 키워드 섹션
- [ ] 키워드 클릭 시 통합 결과 표시
- [ ] 카운트 표시 (실제 데이터)

### 4.2 검색 페이지
- [ ] 키워드 기반 필터링
- [ ] 멀티 콘텐츠 타입 표시

### 4.3 JavaScript 수정
- [ ] API 호출 URL 변경
- [ ] 응답 데이터 구조 변경 대응

## 📋 Phase 5: 테스트

### 5.1 단위 테스트
- [ ] 키워드 조회 API
- [ ] 콘텐츠 카운트 API
- [ ] 통합 검색 API

### 5.2 통합 테스트
- [ ] 홈페이지 키워드 클릭 → 결과 표시
- [ ] 찬송가 검색
- [ ] 성경 검색
- [ ] 기도문 검색

### 5.3 성능 테스트
- [ ] 쿼리 성능 (배열 vs JOIN)
- [ ] 메모리 사용량
- [ ] 응답 시간

## 📋 Phase 6: 배포

### 6.1 스테이징 환경
- [ ] 마이그레이션 스크립트 실행
- [ ] API 동작 확인
- [ ] 프론트엔드 확인

### 6.2 프로덕션 배포
- [ ] 데이터베이스 백업
- [ ] 마이그레이션 실행
- [ ] 서버 재시작
- [ ] 모니터링

## 🚨 롤백 계획

### 문제 발생 시:
1. 서버 이전 버전으로 롤백
2. 데이터베이스 백업 복원
3. keywords 테이블 원복
   ```sql
   ALTER TABLE keywords
   DROP COLUMN hymn_numbers,
   DROP COLUMN bible_refs,
   DROP COLUMN prayer_ids;
   ```

## 📊 예상 변경 규모

- **데이터베이스**: 3개 테이블, 4개 컬럼
- **Go 코드**: 6개 파일, 약 500줄
- **프론트엔드**: 4개 템플릿, 약 200줄
- **API 엔드포인트**: 4개 신규, 5개 수정

## ⏱️ 예상 소요 시간

| 단계 | 예상 시간 |
|------|----------|
| Phase 1 (백업/분석) | 30분 |
| Phase 2 (DB 변경) | 2시간 |
| Phase 3 (API 수정) | 3시간 |
| Phase 4 (프론트) | 2시간 |
| Phase 5 (테스트) | 1시간 |
| Phase 6 (배포) | 1시간 |
| **총계** | **약 9시간** |

## 🎯 핵심 목표

1. **단순화**: tags/keywords 통합
2. **성능**: JOIN 제거, 배열 사용
3. **실제 데이터**: 하드코딩/더미 제거
4. **확장성**: JSONB로 유연한 구조

## ⚠️ 주의사항

1. **호환성**: 기존 API 깨지지 않도록
2. **데이터 무결성**: 매핑 정확성 검증
3. **성능**: 대용량 배열 처리 시 주의
4. **백업**: 각 단계별 백업 필수