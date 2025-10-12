# 주님말씀AI API 문서

## 목차
- [성경 API](#성경-api)
- [기도문 API](#기도문-api)
- [찬송가 API](#찬송가-api)
- [키워드 API](#키워드-api)
- [블로그 API](#블로그-api)
- [관리자 API](#관리자-api)

---

## 성경 API

### 1. 성경책 목록 조회
**GET** `/api/bible/books`

성경 전체 목록을 구약/신약으로 분류하여 조회

**응답 예시:**
```json
{
  "old_testament": [
    {"id": "gn", "name": "창세기", "testament": "old", "order": 1},
    ...
  ],
  "new_testament": [
    {"id": "mt", "name": "마태복음", "testament": "new", "order": 40},
    ...
  ],
  "total": 66
}
```

### 2. 성경책 장 목록 조회
**GET** `/api/bible/books/:book/chapters`

특정 성경책의 모든 장 목록 조회

**파라미터:**
- `book` (경로): 성경책 ID (예: `gn`, `mt`)

**응답 예시:**
```json
{
  "book": "gn",
  "book_name": "창세기",
  "chapters": [1, 2, 3, ..., 50],
  "total_chapters": 50,
  "max_chapter": 50
}
```

### 3. 특정 장 읽기
**GET** `/api/bible/chapters/:book/:chapter`

특정 성경책의 특정 장의 모든 구절을 조회 (+ 챕터 해석)

**파라미터:**
- `book` (경로): 성경책 ID
- `chapter` (경로): 장 번호

**응답 예시:**
```json
{
  "book": "gn",
  "book_name": "창세기",
  "testament": "old",
  "chapter": 1,
  "verses": [
    {"verse": 1, "content": "태초에 하나님이 천지를 창조하시니라"},
    {"verse": 2, "content": "땅이 혼돈하고 공허하며..."}
  ],
  "total_verses": 31,
  "prev_chapter": null,
  "next_chapter": 2,
  "commentary": {
    "title": "창조의 시작",
    "summary": "하나님께서 6일 동안 천지를 창조하시는 과정",
    "themes": "[\"창조\", \"시작\", \"하나님의 능력\"]",
    "context": "창세기 첫 장은...",
    "application": "우리도 하나님의 창조 질서 안에서..."
  }
}
```

### 4. 성경 검색 (구절 단위)
**GET** `/api/bible/search?q={키워드}&book={성경책}&chapter={장}`

성경 구절을 키워드로 검색 (최대 100개)

**쿼리 파라미터:**
- `q` (필수): 검색 키워드
- `book` (선택): 성경책 ID
- `chapter` (선택): 장 번호

**응답 예시:**
```json
{
  "query": "사랑",
  "results": [
    {
      "book": "jo",
      "book_name": "요한복음",
      "chapter": 3,
      "verse": 16,
      "content": "하나님이 세상을 이처럼 사랑하사..."
    }
  ],
  "total": 87
}
```

### 5. 성경 검색 (챕터 단위)
**GET** `/api/bible/search/chapters?q={키워드}`

성경 장 단위로 주제 검색 (챕터별 키워드 집계 기반)

**쿼리 파라미터:**
- `q` (필수): 검색 키워드/주제

**응답 예시:**
```json
{
  "query": "사랑",
  "results": [
    {
      "book": "jo",
      "book_name": "요한복음",
      "chapter": 3,
      "theme": "사랑",
      "relevance_score": 8,
      "keyword_count": 12,
      "chapter_url": "/api/bible/chapters/jo/3"
    }
  ],
  "total": 25,
  "search_type": "chapter_based"
}
```

### 6. 챕터 주제 요약 조회
**GET** `/api/bible/chapters/:book/:chapter/themes`

특정 장의 주제 요약 정보 조회

**응답 예시:**
```json
{
  "book": "jo",
  "book_name": "요한복음",
  "chapter": 3,
  "themes": [
    {"theme": "사랑", "relevance_score": 8, "keyword_count": 12},
    {"theme": "구원", "relevance_score": 6, "keyword_count": 8}
  ],
  "theme_count": 2
}
```

### 7. 태그별 성경 구절 조회
**GET** `/api/verses/by-tag/:tag`

특정 태그와 관련된 대표 성경 구절들 조회

**파라미터:**
- `tag` (경로): 태그 이름 (감사, 위로, 용기, 회개, 치유, 지혜, 평강, 가족, 직장, 건강)

**응답 예시:**
```json
{
  "tag": "감사",
  "verses": [
    {
      "book": "ps",
      "book_name": "시편",
      "chapter": 100,
      "verse": 4,
      "content": "감사함으로 그의 문에 들어가며..."
    }
  ],
  "total": 3
}
```

---

## 기도문 API

### 1. 기도문 생성
**POST** `/api/prayers`

새로운 기도문을 생성

**요청 본문:**
```json
{
  "title": "아침 기도",
  "content": "주님, 오늘도 저를 인도하여 주소서...",
  "tag_ids": [1, 3]
}
```

**응답 예시:**
```json
{
  "message": "Prayer created successfully",
  "prayer": {
    "id": 5,
    "title": "아침 기도",
    "content": "주님, 오늘도...",
    "tags": [
      {"id": 1, "name": "감사", "description": "감사의 기도"},
      {"id": 3, "name": "인도", "description": "인도를 구하는 기도"}
    ],
    "created_at": "2025-10-07T10:00:00Z",
    "updated_at": "2025-10-07T10:00:00Z"
  }
}
```

### 2. 모든 기도문 조회
**GET** `/api/prayers`

모든 기도문을 최신순으로 조회

**응답 예시:**
```json
{
  "prayers": [
    {
      "id": 1,
      "title": "저녁 기도",
      "content": "주님, 오늘 하루를...",
      "tags": [...]
    }
  ],
  "total": 15
}
```

### 3. 키워드로 기도문 검색
**GET** `/api/prayers/search?q={키워드}`

기도문 제목, 내용, 태그에서 키워드 검색

**쿼리 파라미터:**
- `q` (필수): 검색 키워드

**응답 예시:**
```json
{
  "prayers": [...],
  "total": 5,
  "query": "감사",
  "success": true
}
```

### 4. 태그별 기도문 조회
**GET** `/api/prayers/by-tags?tag_ids=1,2`

특정 태그들과 관련된 기도문 조회 (최대 2개 태그)

**쿼리 파라미터:**
- `tag_ids` (필수): 쉼표로 구분된 태그 ID들 (최대 2개)

**응답 예시:**
```json
{
  "prayers": [...],
  "total": 8,
  "tag_ids": [1, 2]
}
```

### 5. 기도문에 태그 추가
**POST** `/api/prayers/:id/tags`

기존 기도문에 새로운 태그 추가

**파라미터:**
- `id` (경로): 기도문 ID

**요청 본문:**
```json
{
  "tag_ids": [4, 5]
}
```

---

## 찬송가 API

### 1. 찬송가 검색
**GET** `/api/hymns/search?q={키워드}&theme={주제}&number={번호}&limit={개수}`

찬송가를 다양한 조건으로 검색

**쿼리 파라미터:**
- `q` (선택): 제목, 가사에서 검색
- `theme` (선택): 주제로 검색
- `number` (선택): 신찬송가 번호로 검색
- `limit` (선택): 결과 개수 (기본: 50, 최대: 1000)

**응답 예시:**
```json
{
  "success": true,
  "total": 12,
  "hymns": [
    {
      "id": 1,
      "number": 1,
      "new_hymn_number": 1,
      "title": "만복의 근원 하나님",
      "lyrics": "만복의 근원 하나님...",
      "theme": "찬양",
      "composer": "작곡가명",
      "author": "작사가명",
      "tempo": "Andante",
      "key_signature": "F Major",
      "bible_reference": "시편 100편",
      "external_link": "https://..."
    }
  ],
  "query": "감사",
  "theme": "",
  "number": ""
}
```

### 2. 특정 번호 찬송가 조회
**GET** `/api/hymns/:number`

신찬송가 번호로 특정 찬송가 조회

**파라미터:**
- `number` (경로): 신찬송가 번호

**응답 예시:**
```json
{
  "success": true,
  "hymn": {
    "id": 1,
    "number": 1,
    "new_hymn_number": 1,
    "title": "만복의 근원 하나님",
    ...
  }
}
```

### 3. 주제별 찬송가 조회
**GET** `/api/hymns/theme/:theme?limit={개수}`

특정 주제의 찬송가 조회

**파라미터:**
- `theme` (경로): 주제명

**쿼리 파라미터:**
- `limit` (선택): 결과 개수 (기본: 20, 최대: 50)

**응답 예시:**
```json
{
  "success": true,
  "total": 8,
  "theme": "감사",
  "hymns": [...]
}
```

### 4. 찬송가 주제 목록 조회
**GET** `/api/hymns/themes`

모든 찬송가 주제 목록과 개수 조회

**응답 예시:**
```json
{
  "success": true,
  "total": 25,
  "themes": [
    {"theme": "찬양", "count": 45},
    {"theme": "감사", "count": 32},
    ...
  ]
}
```

### 5. 랜덤 찬송가 조회
**GET** `/api/hymns/random?limit={개수}`

랜덤으로 찬송가 조회

**쿼리 파라미터:**
- `limit` (선택): 결과 개수 (기본: 5, 최대: 10)

**응답 예시:**
```json
{
  "success": true,
  "total": 5,
  "hymns": [...]
}
```

---

## 키워드 API

### 1. 추천 키워드 조회 (메인 페이지용)
**GET** `/api/keywords/featured`

메인 페이지에 표시할 추천 키워드들 조회

**응답 예시:**
```json
{
  "success": true,
  "keywords": [
    {
      "id": 1,
      "name": "사랑",
      "category": "감정",
      "usage_count": 156,
      "prayer_count": 23,
      "bible_count": 87,
      "hymn_count": 46,
      "icon": "❤️",
      "description": "하나님의 사랑과 이웃 사랑",
      "is_featured": true,
      "created_at": "...",
      "updated_at": "..."
    }
  ],
  "total": 10
}
```

### 2. 모든 키워드 조회
**GET** `/api/keywords`

모든 키워드를 사용량 순으로 조회

**응답 예시:**
```json
{
  "success": true,
  "keywords": [...],
  "total": 28
}
```

### 3. 키워드별 콘텐츠 개수 조회
**GET** `/api/keywords/:keyword/counts`

특정 키워드와 관련된 콘텐츠 개수 조회

**파라미터:**
- `keyword` (경로): 키워드명

**응답 예시:**
```json
{
  "keyword": "사랑",
  "counts": {
    "prayers": 23,
    "verses": 87,
    "hymns": 46
  },
  "total": 156
}
```

---

## 블로그 API

### 1. 블로그 목록 조회 (페이지네이션)
**GET** `/api/blog/posts?page={페이지}&limit={개수}`

블로그 포스트 목록을 페이지네이션으로 조회

**쿼리 파라미터:**
- `page` (선택): 페이지 번호 (기본: 1)
- `limit` (선택): 페이지당 개수 (기본: 10, 최대: 50)

**응답 예시:**
```json
{
  "posts": [
    {
      "id": 1,
      "title": "사랑의 의미를 되새기며",
      "slug": "2025-10-07-love",
      "excerpt": "하나님의 무조건적인 사랑과 우리의 응답에 대해 묵상합니다.",
      "keywords": "사랑,요한복음,하나님,신앙",
      "published_at": "2025-10-07T17:06:32Z",
      "view_count": 42
    }
  ],
  "total": 3,
  "page": 1,
  "limit": 10,
  "total_pages": 1,
  "has_next": false,
  "has_prev": false
}
```

### 2. 블로그 상세 조회
**GET** `/api/blog/posts/:slug`

특정 블로그 포스트 상세 조회 (마크다운 → HTML 변환, 조회수 자동 증가)

**파라미터:**
- `slug` (경로): 블로그 슬러그 (예: `2025-10-07-love`)

**응답 예시:**
```json
{
  "id": 1,
  "title": "사랑의 의미를 되새기며",
  "slug": "2025-10-07-love",
  "content": "# 사랑의 의미를 되새기며\n\n...",
  "content_html": "<h1>사랑의 의미를 되새기며</h1>\n<p>...</p>",
  "excerpt": "하나님의 무조건적인 사랑과...",
  "keywords": "사랑,요한복음,하나님,신앙",
  "published_at": "2025-10-07T17:06:32Z",
  "view_count": 43
}
```

### 3. 블로그 생성 (관리자용)
**POST** `/api/admin/blog/posts`

새로운 블로그 포스트 생성

**요청 본문:**
```json
{
  "title": "새로운 글 제목",
  "slug": "2025-10-08-new-post",
  "content": "# 마크다운 콘텐츠\n\n본문...",
  "excerpt": "요약문",
  "keywords": "키워드1,키워드2,키워드3"
}
```

**응답 예시:**
```json
{
  "success": true,
  "message": "블로그가 생성되었습니다",
  "id": 4
}
```

### 4. 블로그 자동 생성용 데이터 수집 (관리자용) ⭐
**GET** `/api/admin/blog/generate-data?keyword={키워드}`

특정 키워드로 성경+기도문+찬송가 데이터를 한 번에 조합하여 반환 (AI 블로그 생성용)

**쿼리 파라미터:**
- `keyword` (필수): 검색 키워드 (예: 감사, 사랑, 믿음)

**응답 예시:**
```json
{
  "keyword": "감사",
  "data": {
    "bible": {
      "book": "ps",
      "book_name": "시편",
      "chapter": 136,
      "theme": "감사",
      "relevance_score": 10,
      "verses": [
        {"verse": 1, "content": "여호와께 감사하라..."},
        {"verse": 2, "content": "모든 신에 뛰어나신..."}
      ],
      "total_verses": 26
    },
    "prayers": [
      {
        "id": 5,
        "title": "감사의 기도",
        "content": "주님께 감사드립니다..."
      }
    ],
    "hymns": [
      {
        "id": 12,
        "number": 12,
        "new_hymn_number": 12,
        "title": "감사하는 마음 받으소서",
        "lyrics": "감사하는 마음 받으소서...",
        "theme": "감사",
        "composer": "작곡가",
        "author": "작사가",
        "external_link": "https://..."
      }
    ]
  },
  "summary": {
    "has_bible": true,
    "has_prayer": true,
    "has_hymn": true
  }
}
```

**활용 방법:**
1. 이 API로 키워드 기반 데이터를 수집
2. AI (Claude API)에게 해당 데이터와 프롬프트를 전달
3. AI가 마크다운 블로그 작성
4. `/api/admin/blog/posts`로 블로그 발행

---

## 관리자 API

### 1. 성경 데이터 Import
**POST** `/api/admin/import/bible`

GitHub에서 한국어 성경 전체 데이터를 import (백그라운드)

**응답 예시:**
```json
{
  "message": "Bible import started",
  "progress": {
    "total_books": 0,
    "completed_books": 0,
    "current_book": "",
    "status": "running",
    "start_time": "2025-10-07 10:00:00",
    "errors": []
  }
}
```

### 2. Import 진행상황 조회
**GET** `/api/admin/import/bible/progress`

성경 데이터 import 진행상황 조회

**응답 예시:**
```json
{
  "progress": {
    "total_books": 66,
    "completed_books": 39,
    "current_book": "마태복음",
    "status": "running",
    "start_time": "2025-10-07 10:00:00",
    "errors": []
  }
}
```

### 3. 성경 데이터 통계
**GET** `/api/admin/bible/stats`

성경 데이터 통계 조회

**응답 예시:**
```json
{
  "stats": {
    "total_books": 66,
    "total_chapters": 1189,
    "total_verses": 31102,
    "old_testament_books": 39,
    "new_testament_books": 27
  }
}
```

### 4. 찬송가 데이터 Import
**POST** `/api/admin/import/hymns`

찬송가 데이터를 일괄 import

**요청 본문:** (찬송가 배열)
```json
[
  {
    "number": 1,
    "title": "만복의 근원 하나님",
    "lyrics": "...",
    "theme": "찬양",
    "composer": "...",
    ...
  }
]
```

### 5. 키워드 테이블 생성
**POST** `/api/admin/create-keyword-tables`

키워드 관련 테이블들 생성

### 6. 초기 키워드 삽입
**POST** `/api/admin/populate-keywords`

초기 키워드 데이터 삽입 (28개)

### 7. 키워드 카운트 업데이트
**POST** `/api/admin/update-keyword-counts`

모든 키워드의 콘텐츠 개수 업데이트

### 8. 챕터 주제 테이블 생성
**POST** `/api/admin/create-chapter-themes-table`

성경 챕터별 주제 테이블 생성

### 9. 챕터 주제 분석 및 삽입
**POST** `/api/admin/analyze-chapter-themes`

성경 전체를 분석하여 챕터별 주제 데이터 삽입

---

## 태그 API

### 태그 목록 조회
**GET** `/api/tags`

모든 태그 목록 조회

**응답 예시:**
```json
{
  "tags": [
    {"id": 1, "name": "감사", "description": "감사의 기도"},
    {"id": 2, "name": "회개", "description": "회개의 기도"},
    ...
  ]
}
```

---

## 상태 확인 API

### 1. 서버 상태
**GET** `/api/status`

서버 및 데이터베이스 연결 상태 확인

**응답 예시:**
```json
{
  "message": "주님말씀AI 웹앱에 오신 것을 환영합니다!",
  "status": "running",
  "database": "connected"
}
```

### 2. 헬스 체크
**GET** `/health`

서버 헬스 체크

**응답 예시:**
```json
{
  "status": "healthy",
  "database": "connected"
}
```

---

## API 조합 가능성

### ✅ 블로그 자동 생성을 위한 API 조합

다음 API들을 조합하여 **성경 + 기도문 + 찬송가** 기반 블로그를 생성할 수 있습니다:

1. **키워드 선택**: `/api/keywords/featured` → 키워드 선택
2. **성경 구절 검색**: `/api/bible/search/chapters?q={키워드}` → 관련 챕터 찾기
3. **특정 장 읽기**: `/api/bible/chapters/{book}/{chapter}` → 성경 본문 + 해석
4. **기도문 검색**: `/api/prayers/search?q={키워드}` → 관련 기도문
5. **찬송가 검색**: `/api/hymns/search?q={키워드}` or `/api/hymns/theme/{주제}` → 관련 찬송가
6. **블로그 생성**: `/api/admin/blog/posts` → 위 데이터를 조합하여 마크다운 생성 및 삽입

**예시 워크플로우:**
```
1. 키워드 "감사" 선택
2. /api/bible/search/chapters?q=감사 → 데살로니가전서 5장
3. /api/bible/chapters/1ts/5 → 본문 전체 + 해석
4. /api/prayers/search?q=감사 → 감사 기도문 3개
5. /api/hymns/search?theme=감사 → 감사 찬송가 5개
6. AI가 위 데이터를 조합하여 마크다운 블로그 작성
7. /api/admin/blog/posts 로 블로그 발행
```

---

## 사용 예시

### 예시 1: 키워드 기반 통합 검색
```bash
# 1. "사랑" 키워드로 성경 챕터 검색
curl "http://localhost:8080/api/bible/search/chapters?q=사랑"

# 2. 해당 챕터 읽기
curl "http://localhost:8080/api/bible/chapters/jo/3"

# 3. "사랑" 관련 기도문 검색
curl "http://localhost:8080/api/prayers/search?q=사랑"

# 4. "사랑" 주제 찬송가 검색
curl "http://localhost:8080/api/hymns/theme/사랑"
```

### 예시 2: 블로그 자동 생성
```bash
# 1. 데이터 수집 (위 API들로)
# 2. AI로 마크다운 생성
# 3. 블로그 발행
curl -X POST "http://localhost:8080/api/admin/blog/posts" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "사랑에 대한 묵상",
    "slug": "2025-10-08-love-meditation",
    "content": "# 사랑에 대한 묵상\n\n## 성경 본문\n...",
    "excerpt": "사랑의 본질을 성경, 기도문, 찬송가를 통해 묵상합니다.",
    "keywords": "사랑,요한복음,묵상"
  }'
```

---

## 결론

**모든 API가 갖춰져 있습니다!**
- ✅ 성경 API: 검색, 챕터 읽기, 주제 분석
- ✅ 기도문 API: 검색, 태그별 조회
- ✅ 찬송가 API: 검색, 주제별 조회, 랜덤
- ✅ 블로그 API: 목록, 상세, 생성
- ✅ 키워드 API: 추천, 콘텐츠 개수

**다음 단계:**
AI 기반 블로그 자동 생성 API를 추가하여 위 API들을 자동으로 조합하는 엔드포인트를 만들 수 있습니다.
