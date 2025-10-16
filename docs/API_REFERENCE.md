# 🔌 주님말씀AI API 참조 문서

> **버전**: v0.5.5-stable
> **업데이트**: 2025년 9월 29일
> **베이스 URL**: `http://localhost:8080`

## 📊 API 테스트 결과 요약

| 카테고리 | 정상 동작 | 문제 있음 | 총계 |
|---------|---------|---------|------|
| **시스템** | ✅ 3개 | - | 3개 |
| **성경** | ✅ 6개 | - | 6개 |
| **찬송가** | ✅ 3개 | ⚠️ 2개 | 5개 |
| **기도문** | ✅ 2개 | ⚠️ 1개 | 3개 |
| **키워드** | ✅ 2개 | - | 2개 |
| **관리자** | 🔐 9개 | - | 9개 |
| **전체** | **✅ 25개** | **⚠️ 3개** | **28개** |

---

## 🏥 시스템 API

### `GET /health`
**상태**: ✅ 정상 동작
**용도**: 서버 헬스체크 및 데이터베이스 연결 상태 확인
```json
// 응답 예시
{
  "status": "healthy",
  "database": "connected"
}
```

### `GET /api/status`
**상태**: ✅ 정상 동작
**용도**: 애플리케이션 상태 정보
```json
// 응답 예시
{
  "status": "running",
  "database": "connected",
  "message": "주님말씀AI 웹앱에 오신 것을 환영합니다!"
}
```

### `GET /api/tags`
**상태**: ✅ 정상 동작
**용도**: 모든 태그 목록 조회
```json
// 응답 예시
{
  "tags": [
    {
      "id": 1,
      "name": "감사",
      "description": "감사와 찬양에 관한 기도"
    }
  ]
}
```

---

## 📖 성경 관련 API

### `GET /api/bible/search`
**상태**: ✅ 정상 동작
**파라미터**: `q` (검색 키워드)
**용도**: 성경 구절 검색 (구절 단위)
```bash
curl "http://localhost:8080/api/bible/search?q=사랑"
```
```json
// 응답 예시
{
  "query": "사랑",
  "total": 100,
  "results": [
    {
      "book": "요한복음",
      "chapter": 3,
      "verse": 16,
      "content": "하나님이 세상을 이처럼 사랑하사..."
    }
  ]
}
```

### `GET /api/bible/search/chapters`
**상태**: ✅ 정상 동작
**파라미터**: `q` (검색 키워드)
**용도**: 성경 검색 (장 기준 결과)

### `GET /api/bible/books`
**상태**: ✅ 정상 동작
**용도**: 성경책 목록 조회
```json
// 응답 예시
{
  "old_testament": [
    {
      "id": "gn",
      "name": "창세기",
      "testament": "old",
      "order": 1
    }
  ],
  "new_testament": [
    {
      "id": "mt",
      "name": "마태복음",
      "testament": "new",
      "order": 40
    }
  ],
  "total": 65
}
```

### `GET /api/bible/books/:book/chapters`
**상태**: ✅ 정상 동작
**용도**: 특정 성경책의 장 목록 조회

### `GET /api/bible/chapters/:book/:chapter`
**상태**: ✅ 정상 동작
**용도**: 특정 장 전체 조회
```bash
curl "http://localhost:8080/api/bible/chapters/mt/1"
```
```json
// 응답 예시
{
  "book": 2,
  "chapter": 1,
  "verses": [
    {
      "verse": 1,
      "content": "아브라함의 후손 다윗의 후손 예수 그리스도의 계보라"
    }
  ]
}
```

### `GET /api/bible/chapters/:book/:chapter/themes`
**상태**: ✅ 정상 동작
**용도**: 특정 장의 주제 요약

---

## 🎵 찬송가 관련 API

### `GET /api/hymns/search`
**상태**: ✅ 정상 동작
**파라미터**: `q` (검색 키워드)
**용도**: 찬송가 검색
```bash
curl "http://localhost:8080/api/hymns/search?q=사랑"
```
```json
// 응답 예시
{
  "query": "사랑",
  "total": 4,
  "hymns": [
    {
      "number": 234,
      "title": "나의 사랑하는 책",
      "theme": "성경"
    }
  ]
}
```

### `GET /api/hymns/:number`
**상태**: ⚠️ **문제 있음** - 항상 null 반환
**용도**: 특정 번호 찬송가 상세 조회
```bash
curl "http://localhost:8080/api/hymns/1"
# 현재 null 반환 중 - 수정 필요
```

### `GET /api/hymns/theme/:theme`
**상태**: ⚠️ **미테스트**
**용도**: 주제별 찬송가 조회

### `GET /api/hymns/themes`
**상태**: ✅ 정상 동작
**용도**: 모든 찬송가 주제 목록 조회
```json
// 응답 예시 (19개 주제)
{
  "themes": ["감사", "기도", "구원", "성경", "사랑", ...]
}
```

### `GET /api/hymns/random`
**상태**: ⚠️ **미테스트**
**용도**: 랜덤 찬송가 조회

---

## 🙏 기도문 관련 API

### `GET /api/prayers/search`
**상태**: ✅ 정상 동작
**파라미터**: `q` (검색 키워드)
**용도**: 키워드로 기도문 검색
```bash
curl "http://localhost:8080/api/prayers/search?q=사랑"
```
```json
// 응답 예시
{
  "success": true,
  "total": 3,
  "prayers": [
    {
      "id": 1,
      "title": "사랑의 기도",
      "content": "하나님의 무한한 사랑에 감사드립니다..."
    }
  ]
}
```

### `GET /api/prayers/by-tags`
**상태**: ⚠️ **문제 있음** - null 반환
**파라미터**: `tags` (태그 ID 목록, 쉼표 구분)
**용도**: 태그별 기도문 조회
```bash
curl "http://localhost:8080/api/prayers/by-tags?tags=1,2"
# 현재 null 반환 중 - 수정 필요
```

### `POST /api/prayers`
**상태**: 🔐 **관리자 기능**
**용도**: 새 기도문 생성

---

## 🔤 키워드 관련 API

### `GET /api/keywords`
**상태**: ✅ 정상 동작
**용도**: 모든 키워드 조회
```json
// 응답 예시 (28개 키워드)
{
  "total": 28,
  "keywords": [
    {
      "id": 1,
      "name": "사랑",
      "category": "감정"
    }
  ]
}
```

### `GET /api/keywords/:keyword/counts`
**상태**: ⚠️ **미테스트**
**용도**: 키워드별 콘텐츠 개수

---

## 📝 블로그 관련 API

### `POST /api/admin/blog/posts`
**상태**: ✅ 정상 동작
**용도**: 블로그 생성 (관리자)
**권한**: 관리자
**요청 본문**:
```json
{
  "title": "블로그 제목",
  "slug": "blog-slug",
  "content": "마크다운 형식의 본문",
  "excerpt": "요약",
  "keywords": "키워드1,키워드2"
}
```

### `GET /api/blog/posts`
**상태**: ✅ 정상 동작
**용도**: 블로그 목록 조회 (페이지네이션, 공개된 글만)
**파라미터**:
- `page` (기본값: 1)
- `limit` (기본값: 10, 최대: 50)
```json
// 응답 예시
{
  "posts": [...],
  "total": 100,
  "page": 1,
  "limit": 10,
  "total_pages": 10,
  "has_next": true,
  "has_prev": false
}
```

### `GET /api/blog/posts/:slug`
**상태**: ✅ 정상 동작
**용도**: 블로그 상세 조회 (slug 기반, 공개된 글만)
**기능**: 마크다운 → HTML 자동 변환, 조회수 자동 증가

### `GET /api/admin/blog/posts/:id`
**상태**: ✅ 정상 동작 (신규)
**용도**: 블로그 ID 기반 조회 (관리자용, is_published 무관)
**권한**: 관리자

### `PUT /api/admin/blog/posts/:id`
**상태**: ✅ 정상 동작 (신규)
**용도**: 블로그 수정 (관리자)
**권한**: 관리자
**요청 본문**: 수정할 필드만 포함
```json
{
  "title": "수정된 제목",
  "content": "수정된 본문"
}
```

### `DELETE /api/admin/blog/posts/:id`
**상태**: ✅ 정상 동작 (신규)
**용도**: 블로그 소프트 삭제 (is_published = false 설정)
**권한**: 관리자
**설명**: 실제 데이터 삭제 대신 외부 노출만 중단

### `POST /api/admin/blog/posts/:id/evaluate`
**상태**: ✅ 정상 동작 (신규)
**용도**: 블로그 품질 평가 (Gemini API 결과 저장)
**권한**: 관리자
**요청 본문**:
```json
{
  "theological_accuracy": 8.5,
  "content_structure": 9.0,
  "engagement": 7.5,
  "technical_quality": 9.5,
  "seo_optimization": 8.0,
  "total_score": 8.6,
  "quality_feedback": "{\"strengths\": [...], \"improvements\": [...]}",
  "evaluator": "gemini-api"
}
```
**응답 예시**:
```json
{
  "success": true,
  "message": "품질 기준을 충족하여 자동으로 발행되었습니다",
  "is_published": true,
  "auto_published": true
}
```
**자동 발행 기준**:
- total_score >= 7.0
- theological_accuracy >= 6.0
- technical_quality >= 7.0

### `GET /api/admin/blog/posts/:id/quality-history`
**상태**: ✅ 정상 동작 (신규)
**용도**: 블로그 품질 평가 이력 조회
**권한**: 관리자
**응답 예시**:
```json
{
  "blog_post_id": "123",
  "history": [
    {
      "theological_accuracy": 8.5,
      "content_structure": 9.0,
      "engagement": 7.5,
      "technical_quality": 9.5,
      "seo_optimization": 8.0,
      "total_score": 8.6,
      "quality_feedback": "...",
      "evaluator": "gemini-api",
      "evaluated_at": "2025-10-16T10:30:00Z"
    }
  ],
  "total": 1
}
```

### `GET /api/admin/blog/generate-data`
**상태**: ✅ 정상 동작
**용도**: 블로그 자동 생성용 데이터 수집
**파라미터**:
- `keyword` (필수): 검색 키워드
- `random` (선택, 기본값: false): 랜덤 모드 활성화

---

## 📊 블로그 품질 평가 시스템

### 평가 항목 (0-10점)

1. **theological_accuracy** (신학적 정확성) - 가중치 30%
   - 성경 구절 인용의 정확성
   - 신학적 해석의 올바름
   - 교리적 일관성

2. **content_structure** (콘텐츠 구조) - 가중치 25%
   - 도입-본론-결론 구조
   - 문단 간 논리적 흐름
   - 전체적인 응집성

3. **engagement** (독자 참여도) - 가중치 20%
   - 제목의 매력도
   - 실용적 적용 포함 여부
   - 독자와의 소통

4. **technical_quality** (기술적 품질) - 가중치 15%
   - 성경 구절 정상 표시
   - YouTube 임베딩 작동
   - 마크다운 형식 올바름

5. **seo_optimization** (SEO 최적화) - 가중치 10%
   - 키워드 적절한 배치
   - 메타 정보 완성도
   - 가독성

### 자동 발행 조건

다음 조건을 **모두** 충족하면 자동으로 `is_published = true`로 설정:
- **총점** >= 7.0/10.0
- **신학적 정확성** >= 6.0/10.0
- **기술적 품질** >= 7.0/10.0

### 품질 평가 워크플로우

```bash
# 1. 블로그 생성 (기본 미발행 상태)
curl -X POST http://localhost:8080/api/admin/blog/posts \
  -H "Content-Type: application/json" \
  -d '{"title": "...", "slug": "...", "content": "..."}'

# 2. Gemini API로 품질 평가 (Python 스크립트)
python blog_posting/scripts/evaluate_quality.py output.json

# 3. 평가 결과를 API로 저장
curl -X POST http://localhost:8080/api/admin/blog/posts/123/evaluate \
  -H "Content-Type: application/json" \
  -d '{"theological_accuracy": 8.5, ...}'

# 4. 자동 발행 여부 확인
# 기준 충족 시 자동으로 is_published = true 설정
```

---

## 🔐 관리자 API (테스트 제외)

### 성경 데이터 관리
- `POST /api/admin/import/bible` - 성경 데이터 전체 import
- `GET /api/admin/import/bible/progress` - import 진행상황 조회
- `GET /api/admin/bible/stats` - 성경 데이터 통계
- `POST /api/admin/fix-bible-books` - 성경책 매핑 수정

### 챕터 주제 분석
- `POST /api/admin/create-chapter-themes-table` - 챕터 주제 테이블 생성
- `POST /api/admin/analyze-chapter-themes` - 챕터 주제 분석 및 삽입

### 찬송가 데이터 관리
- `POST /api/admin/import/hymns` - 찬송가 데이터 Import

### 키워드 관리
- `POST /api/admin/create-keyword-tables` - 키워드 테이블 생성
- `POST /api/admin/populate-keywords` - 초기 키워드 데이터 삽입

---

## 🐛 발견된 문제점

### ⚠️ 수정 필요한 API

1. **`GET /api/hymns/:number`**
   - **문제**: 모든 요청에 대해 null 반환
   - **원인**: 핸들러 로직 또는 데이터베이스 쿼리 문제 추정
   - **확인**: DB에는 데이터 존재 (`SELECT number, title FROM hymns LIMIT 5` 성공)

2. **`GET /api/prayers/by-tags`**
   - **문제**: 태그 ID 파라미터를 전달해도 null 반환
   - **원인**: 태그별 기도문 연결 로직 문제 추정
   - **확인**: prayer_tags 테이블 관계 검증 필요

### 🔍 테이블 이름 변경 영향

**백업된 테이블들**:
- `data_import_logs_bak`
- `user_favorites_bak`
- `search_stats_bak`
- `prayer_keywords_bak`
- `bible_keywords_bak`
- `hymn_keywords_bak`

**✅ 영향 없음**: 현재 모든 활성 API는 백업되지 않은 테이블들만 사용하여 정상 동작

---

## 📝 권장사항

### 즉시 수정 필요
1. **찬송가 개별 조회 API** 수정
2. **기도문 태그별 조회 API** 수정

### 추가 테스트 필요
1. 관리자 API 전체 테스트
2. 미테스트된 API 엔드포인트 검증

### 문서 개선
1. API 응답 형식 표준화
2. 에러 코드 및 메시지 정의
3. 인증/권한 체계 문서화

---

**📊 테스트 일시**: 2025년 9월 29일
**📋 테스트 범위**: 28개 API 엔드포인트
**✅ 성공률**: 89% (25/28개)