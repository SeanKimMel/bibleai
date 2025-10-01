# API 문서 (API Documentation)

## 📡 API 개요

주님말씀AI 웹앱의 REST API 문서입니다. 현재 구현된 API와 향후 계획된 API를 포함합니다.

**Base URL**: `http://localhost:8080`  
**Content-Type**: `application/json`  
**Character Encoding**: `UTF-8`

## 🔐 인증 (향후 구현)

관리자 기능은 JWT 토큰 기반 인증을 사용할 예정입니다.

```http
Authorization: Bearer <JWT_TOKEN>
```

## 📄 응답 형식

### 성공 응답
```json
{
    "success": true,
    "data": {...},
    "message": "성공 메시지",
    "timestamp": "2025-01-15T10:30:00Z"
}
```

### 에러 응답
```json
{
    "success": false,
    "error": "에러 메시지",
    "code": "ERROR_CODE",
    "timestamp": "2025-01-15T10:30:00Z"
}
```

### HTTP 상태 코드
- `200 OK`: 성공
- `201 Created`: 리소스 생성 성공
- `400 Bad Request`: 잘못된 요청
- `401 Unauthorized`: 인증 실패
- `403 Forbidden`: 권한 없음
- `404 Not Found`: 리소스 없음
- `500 Internal Server Error`: 서버 오류

## 🏠 시스템 API

### 시스템 상태 확인
```http
GET /api/status
```

**응답 예시:**
```json
{
    "success": true,
    "data": {
        "message": "주님말씀AI 웹앱에 오신 것을 환영합니다!",
        "status": "running",
        "database": "connected",
        "version": "v0.2.0-beta"
    }
}
```

### 헬스 체크
```http
GET /health
```

**응답 예시:**
```json
{
    "status": "healthy",
    "database": "connected",
    "timestamp": "2025-01-15T10:30:00Z",
    "uptime": "2h30m15s"
}
```

## 🏷️ 태그 API

### 태그 목록 조회
```http
GET /api/tags
```

**쿼리 파라미터:**
- `search` (선택): 태그 이름 검색
- `limit` (선택): 결과 개수 제한 (기본값: 50)

**응답 예시:**
```json
{
    "success": true,
    "data": {
        "tags": [
            {
                "id": 1,
                "name": "감사",
                "description": "감사와 찬양에 관한 기도",
                "created_at": "2025-01-15T10:00:00Z"
            },
            {
                "id": 2,
                "name": "위로",
                "description": "슬픔과 아픔 중에 위로를 구하는 기도",
                "created_at": "2025-01-15T10:00:00Z"
            }
        ],
        "total": 10
    }
}
```

### 태그 생성 (관리자, 향후 구현)
```http
POST /api/tags
Authorization: Bearer <JWT_TOKEN>
Content-Type: application/json
```

**요청 본문:**
```json
{
    "name": "새로운태그",
    "description": "태그 설명"
}
```

**응답 예시:**
```json
{
    "success": true,
    "data": {
        "id": 11,
        "name": "새로운태그",
        "description": "태그 설명",
        "created_at": "2025-01-15T11:00:00Z"
    },
    "message": "태그가 성공적으로 생성되었습니다."
}
```

### 태그 수정 (관리자, 향후 구현)
```http
PUT /api/tags/:id
Authorization: Bearer <JWT_TOKEN>
Content-Type: application/json
```

**요청 본문:**
```json
{
    "name": "수정된태그",
    "description": "수정된 설명"
}
```

### 태그 삭제 (관리자, 향후 구현)
```http
DELETE /api/tags/:id
Authorization: Bearer <JWT_TOKEN>
```

## 🙏 기도문 API

### 기도문 목록 조회 (향후 구현)
```http
GET /api/prayers
```

**쿼리 파라미터:**
- `tags` (선택): 쉼표로 구분된 태그 ID (예: `1,2`)
- `search` (선택): 제목/내용 검색
- `page` (선택): 페이지 번호 (기본값: 1)
- `limit` (선택): 페이지당 결과 수 (기본값: 10)

**응답 예시:**
```json
{
    "success": true,
    "data": {
        "prayers": [
            {
                "id": 1,
                "title": "감사 기도",
                "content": "하늘에 계신 우리 아버지 하나님...",
                "tags": [
                    {"id": 1, "name": "감사"}
                ],
                "created_at": "2025-01-15T10:00:00Z",
                "updated_at": "2025-01-15T10:00:00Z"
            }
        ],
        "pagination": {
            "current_page": 1,
            "total_pages": 5,
            "total_count": 42,
            "per_page": 10
        }
    }
}
```

### 태그별 기도문 조회 (향후 구현)
```http
GET /api/prayers/by-tags
```

**쿼리 파라미터:**
- `tag_ids` (필수): 쉼표로 구분된 태그 ID (예: `1,2`)
- `limit` (선택): 결과 개수 제한 (기본값: 10)

**응답 예시:**
```json
{
    "success": true,
    "data": {
        "prayers": [
            {
                "id": 1,
                "title": "감사와 위로의 기도",
                "content": "하나님 아버지...",
                "tags": [
                    {"id": 1, "name": "감사"},
                    {"id": 2, "name": "위로"}
                ],
                "match_count": 2
            }
        ],
        "search_tags": [
            {"id": 1, "name": "감사"},
            {"id": 2, "name": "위로"}
        ],
        "total": 3
    }
}
```

### 특정 기도문 조회 (향후 구현)
```http
GET /api/prayers/:id
```

**응답 예시:**
```json
{
    "success": true,
    "data": {
        "id": 1,
        "title": "감사 기도",
        "content": "하늘에 계신 우리 아버지 하나님...",
        "tags": [
            {"id": 1, "name": "감사"}
        ],
        "created_at": "2025-01-15T10:00:00Z",
        "updated_at": "2025-01-15T10:00:00Z"
    }
}
```

### 기도문 생성 (관리자, 향후 구현)
```http
POST /api/prayers
Authorization: Bearer <JWT_TOKEN>
Content-Type: application/json
```

**요청 본문:**
```json
{
    "title": "새로운 기도문",
    "content": "기도문 내용...",
    "tag_ids": [1, 2]
}
```

### 기도문 수정 (관리자, 향후 구현)
```http
PUT /api/prayers/:id
Authorization: Bearer <JWT_TOKEN>
Content-Type: application/json
```

### 기도문 삭제 (관리자, 향후 구현)
```http
DELETE /api/prayers/:id
Authorization: Bearer <JWT_TOKEN>
```

## 📖 성경 API

### 성경 구절 검색 (향후 구현)
```http
GET /api/bible/search
```

**쿼리 파라미터:**
- `keyword` (필수): 검색 키워드
- `book` (선택): 성경 책 이름 (예: "창세기")
- `version` (선택): 성경 번역본 (기본값: "KOR")
- `limit` (선택): 결과 개수 제한 (기본값: 20)

**응답 예시:**
```json
{
    "success": true,
    "data": {
        "verses": [
            {
                "id": 1,
                "book": "요한복음",
                "chapter": 3,
                "verse": 16,
                "content": "하나님이 세상을 이처럼 사랑하사...",
                "version": "KOR"
            }
        ],
        "keyword": "사랑",
        "total": 150
    }
}
```

### 특정 성경 구절 조회 (향후 구현)
```http
GET /api/bible/verse/:id
```

### 성경 책 목록 (향후 구현)
```http
GET /api/bible/books
```

**응답 예시:**
```json
{
    "success": true,
    "data": {
        "old_testament": [
            {"name": "창세기", "chapters": 50},
            {"name": "출애굽기", "chapters": 40}
        ],
        "new_testament": [
            {"name": "마태복음", "chapters": 28},
            {"name": "마가복음", "chapters": 16}
        ]
    }
}
```

## 🎵 찬송가 API

### 찬송가 목록/검색 (향후 구현)
```http
GET /api/hymns
```

**쿼리 파라미터:**
- `search` (선택): 번호, 제목, 가사 검색
- `theme` (선택): 주제별 필터링
- `number` (선택): 특정 번호
- `page` (선택): 페이지 번호
- `limit` (선택): 페이지당 결과 수

**응답 예시:**
```json
{
    "success": true,
    "data": {
        "hymns": [
            {
                "id": 1,
                "number": 1,
                "title": "만복의 근원 하나님",
                "theme": "찬양",
                "lyrics": "만복의 근원 하나님...",
                "has_lyrics": true
            }
        ],
        "pagination": {
            "current_page": 1,
            "total_pages": 60,
            "total_count": 595
        }
    }
}
```

### 특정 찬송가 조회 (향후 구현)
```http
GET /api/hymns/:number
```

**응답 예시:**
```json
{
    "success": true,
    "data": {
        "id": 1,
        "number": 1,
        "title": "만복의 근원 하나님",
        "theme": "찬양",
        "lyrics": "만복의 근원 하나님\n한 없는 은혜 베푸신...",
        "verses": [
            "만복의 근원 하나님\n한 없는 은혜 베푸신...",
            "천사들도 찬양하며\n주님께 경배하도다..."
        ]
    }
}
```

### 찬송가 주제 목록 (향후 구현)
```http
GET /api/hymns/themes
```

**응답 예시:**
```json
{
    "success": true,
    "data": {
        "themes": [
            {"name": "찬양", "count": 45},
            {"name": "경배", "count": 32},
            {"name": "감사", "count": 28},
            {"name": "성탄", "count": 15}
        ]
    }
}
```

## 🤖 AI 분석 API (더미, 향후 구현)

### 감정 분석 요청
```http
POST /api/ai/analyze-emotion
Content-Type: application/json
```

**요청 본문:**
```json
{
    "text": "오늘 힘든 일이 있어서 기분이 우울해요"
}
```

**응답 예시:**
```json
{
    "success": true,
    "data": {
        "emotion": "sadness",
        "confidence": 0.85,
        "description": "슬픔과 우울감이 감지됩니다.",
        "recommended_tags": ["위로", "평강"],
        "processing_time": "1.2s"
    }
}
```

## 👤 관리자 API (향후 구현)

### 로그인
```http
POST /api/admin/login
Content-Type: application/json
```

**요청 본문:**
```json
{
    "username": "admin",
    "password": "password"
}
```

**응답 예시:**
```json
{
    "success": true,
    "data": {
        "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
        "expires_at": "2025-01-15T22:00:00Z",
        "user": {
            "id": 1,
            "username": "admin",
            "role": "administrator"
        }
    }
}
```

### 대시보드 통계
```http
GET /api/admin/dashboard
Authorization: Bearer <JWT_TOKEN>
```

**응답 예시:**
```json
{
    "success": true,
    "data": {
        "statistics": {
            "total_prayers": 150,
            "total_tags": 12,
            "total_hymns": 595,
            "total_bible_verses": 31102
        },
        "recent_activity": [
            {
                "action": "prayer_created",
                "timestamp": "2025-01-15T10:30:00Z",
                "details": "새로운 기도문이 추가되었습니다."
            }
        ]
    }
}
```

## 🔍 검색 API 공통 기능

### 전체 검색 (향후 구현)
```http
GET /api/search
```

**쿼리 파라미터:**
- `q` (필수): 검색 키워드
- `type` (선택): `prayers`, `bible`, `hymns`, `all` (기본값)
- `limit` (선택): 각 카테고리별 결과 수

**응답 예시:**
```json
{
    "success": true,
    "data": {
        "prayers": [
            {"id": 1, "title": "사랑의 기도", "content": "..."}
        ],
        "bible_verses": [
            {"id": 1, "book": "요한복음", "chapter": 3, "verse": 16, "content": "..."}
        ],
        "hymns": [
            {"id": 1, "number": 405, "title": "나 같은 죄인 살리신"}
        ],
        "query": "사랑",
        "total_results": {
            "prayers": 15,
            "bible_verses": 89,
            "hymns": 7
        }
    }
}
```

## ⚠️ 에러 코드

| 코드 | 메시지 | 설명 |
|------|--------|------|
| `INVALID_REQUEST` | 잘못된 요청입니다 | 요청 형식이 올바르지 않음 |
| `MISSING_PARAMETER` | 필수 파라미터가 누락되었습니다 | 필수 파라미터 없음 |
| `RESOURCE_NOT_FOUND` | 리소스를 찾을 수 없습니다 | 요청한 데이터가 존재하지 않음 |
| `DATABASE_ERROR` | 데이터베이스 오류가 발생했습니다 | DB 연결/쿼리 오류 |
| `AUTHENTICATION_FAILED` | 인증에 실패했습니다 | 잘못된 토큰 또는 만료됨 |
| `AUTHORIZATION_FAILED` | 권한이 없습니다 | 해당 작업을 수행할 권한 없음 |
| `RATE_LIMIT_EXCEEDED` | 요청 횟수 제한을 초과했습니다 | 너무 많은 요청 |

## 📊 사용량 제한 (향후 구현)

### 일반 사용자
- 검색 API: 분당 60회
- 기도문 조회: 분당 30회

### 관리자
- 모든 API: 분당 300회

## 🧪 테스트 가이드

### cURL 예시
```bash
# 시스템 상태 확인
curl -X GET "http://localhost:8080/api/status"

# 태그 목록 조회
curl -X GET "http://localhost:8080/api/tags"

# 헬스 체크
curl -X GET "http://localhost:8080/health"
```

### JavaScript 예시
```javascript
// 태그 목록 가져오기
const response = await fetch('/api/tags');
const data = await response.json();

if (data.success) {
    console.log(data.data.tags);
} else {
    console.error(data.error);
}
```

### Thunder Client/Postman 컬렉션 (향후 제공)
프로젝트 루트의 `api-collection.json` 파일로 제공 예정.

---

**API 버전**: v1.0  
**최종 업데이트**: 2025년 1월 15일  
**Base URL**: http://localhost:8080  

> **참고**: 현재 대부분의 API는 구현 예정 단계입니다. 실제 구현 순서는 프로젝트 진행에 따라 달라질 수 있습니다.