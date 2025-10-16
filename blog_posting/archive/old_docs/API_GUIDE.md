# API 사용 가이드

## 📡 블로그 생성용 API

### 1. 데이터 수집 API

**엔드포인트**: `GET /api/admin/blog/generate-data`

**파라미터**:
- `keyword` (필수): 검색 키워드
- `random` (선택): `true` 설정 시 랜덤 데이터 반환

**예시**:
```bash
# 기본 모드
curl "http://localhost:8080/api/admin/blog/generate-data?keyword=감사"

# 랜덤 모드 (추천)
curl "http://localhost:8080/api/admin/blog/generate-data?keyword=감사&random=true"
```

**응답 형식**:
```json
{
  "keyword": "감사",
  "random_mode": true,
  "data": {
    "bible": {
      "book": "ps",
      "book_name": "시편",
      "chapter": 136,
      "theme": "감사",
      "relevance_score": 10,
      "verses": [
        {
          "verse": 1,
          "content": "여호와께 감사하라 그는 선하시며 그 인자하심이 영원함이로다"
        }
      ],
      "total_verses": 26
    },
    "prayers": [
      {
        "id": 1,
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
        "author": "작사가"
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

---

### 2. 블로그 발행 API

**엔드포인트**: `POST /api/admin/blog/posts`

**요청 형식**:
```json
{
  "title": "블로그 제목",
  "slug": "YYYY-MM-DD-slug",
  "content": "# 마크다운 콘텐츠\n\n본문...",
  "excerpt": "100-200자 요약",
  "keywords": "키워드1,키워드2,키워드3"
}
```

**예시**:
```bash
curl -X POST "http://localhost:8080/api/admin/blog/posts" \
  -H "Content-Type: application/json" \
  -d @output.json
```

**응답**:
```json
{
  "success": true,
  "message": "블로그가 생성되었습니다",
  "id": 5
}
```

---

### 3. 블로그 조회 API

```bash
# 목록 조회
curl "http://localhost:8080/api/blog/posts?page=1&limit=10"

# 상세 조회
curl "http://localhost:8080/api/blog/posts/2025-10-11-slug"
```

---

## 🎯 추천 키워드

### 감정/관계
- 사랑, 평안, 감사, 기쁨, 위로, 희망, 소망
- 용서, 화해, 가족, 형제, 섬김

### 신앙
- 믿음, 구원, 은혜, 회개, 순종, 겸손, 인내
- 기도, 찬양, 예배, 성령, 말씀, 진리

### 일상
- 직장, 건강, 지혜, 인도, 도움

---

## ⚙️ 랜덤 모드 vs 일반 모드

| 항목 | 일반 모드 | 랜덤 모드 |
|------|----------|----------|
| 성경 | 연관도 최고 1개 | 상위 10개 중 랜덤 |
| 찬송가 | 번호 순 3개 | 랜덤 3개 |
| 사용 시점 | 테스트용 | **실제 발행용 (추천)** |

**권장**: 항상 `random=true` 사용
