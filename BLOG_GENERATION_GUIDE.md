# 블로그 자동 생성 가이드 (별도 Claude 세션용)

이 문서는 **개발 환경과 분리된 별도의 Claude 세션**에서 블로그를 생성하기 위한 완전한 가이드입니다.

---

## 📚 사용 가능한 API 목록

### 1. 블로그 생성용 데이터 수집 API ⭐

**엔드포인트**: `GET /api/admin/blog/generate-data`

**파라미터**:
- `keyword` (필수): 키워드 (예: 감사, 사랑, 평안, 믿음)
- `random` (선택): `true` 설정 시 랜덤 모드 (같은 키워드라도 다른 데이터 반환)

**예시**:
```bash
# 일반 모드 (항상 같은 결과)
curl "http://localhost:8080/api/admin/blog/generate-data?keyword=감사"

# 랜덤 모드 (매번 다른 결과)
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
        "theme": "감사"
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
  "slug": "2025-10-11-unique-slug",
  "content": "# 마크다운 콘텐츠\n\n본문...",
  "excerpt": "요약문 (300자 이내)",
  "keywords": "키워드1,키워드2,키워드3"
}
```

**예시**:
```bash
curl -X POST "http://localhost:8080/api/admin/blog/posts" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "감사의 의미를 되새기며",
    "slug": "2025-10-11-thanksgiving",
    "content": "# 감사의 의미를 되새기며\n\n...",
    "excerpt": "감사에 대한 묵상",
    "keywords": "감사,성경,묵상"
  }'
```

---

## 🤖 Claude에게 전달할 프롬프트 템플릿

### 프롬프트 1: 블로그 작성 요청

```
당신은 기독교 신앙 블로그 작성자입니다.

아래 API를 통해 수집한 데이터를 기반으로 신앙 묵상 블로그를 한국어 마크다운으로 작성해주세요.

## 수집된 데이터

[여기에 API 응답 JSON을 붙여넣으세요]

## 블로그 작성 요구사항

### 구조
1. **제목** (# 헤딩): 키워드를 중심으로 한 흥미로운 제목
2. **성경 본문 소개** (## 헤딩):
   - 대표 구절 1-2개를 인용 (> 블록쿼트)
   - 배경 및 맥락 설명
3. **묵상과 해석** (## 헤딩):
   - 성경 본문의 의미
   - 오늘날 우리에게 주는 교훈
   - 3-4개의 소주제로 나누어 설명
4. **찬송가 소개** (## 헤딩):
   - 제공된 찬송가 가사 일부를 ``` 코드블록으로 인용
   - 각 찬송가가 전하는 메시지 설명
5. **오늘의 적용** (## 헤딩):
   - 구체적인 실천 방법 3가지 (번호 목록)
6. **마무리 기도** (## 헤딩):
   - 2-3문단의 기도문

### 작성 스타일
- 따뜻하고 진솔한 톤
- 복잡한 신학 용어보다는 일상 언어 사용
- 구체적인 예시와 비유 활용
- 분량: 1500-2500자 (너무 길지 않게)

### 제약사항
- 이모지 사용 금지
- 성경 구절은 정확하게 인용
- 찬송가 가사는 제공된 내용만 사용
- 허위 정보나 과장 금지

## 출력 형식

작성한 블로그를 아래 JSON 형식으로 출력해주세요:

```json
{
  "title": "블로그 제목",
  "slug": "2025-10-11-slug-here",
  "content": "# 블로그 제목\n\n## 성경 본문 소개\n\n...",
  "excerpt": "100-200자 요약",
  "keywords": "키워드1,키워드2,키워드3"
}
```

**중요**:
- slug는 "YYYY-MM-DD-영문-제목" 형식 (소문자, 하이픈 구분)
- excerpt는 본문 내용을 100-200자로 요약
- keywords는 키워드와 관련 단어들을 쉼표로 구분 (3-5개)
```

---

### 프롬프트 2: API 호출 및 발행 요청

```
위에서 작성한 블로그 JSON을 아래 명령어로 발행해주세요:

curl -X POST "http://localhost:8080/api/admin/blog/posts" \
  -H "Content-Type: application/json" \
  -d '[여기에 JSON 붙여넣기]'

발행 후 결과를 확인해주세요:

curl "http://localhost:8080/api/blog/posts?page=1&limit=5" | jq .
```

---

## 📋 전체 워크플로우

### Step 1: 데이터 수집

```bash
# 키워드 선택 (예: 평안)
KEYWORD="평안"

# 랜덤 모드로 데이터 수집 (매번 다른 데이터)
curl "http://localhost:8080/api/admin/blog/generate-data?keyword=$KEYWORD&random=true" | jq . > blog_data.json
```

### Step 2: Claude에게 전달

1. 새 Claude 창 열기 (개발 환경과 분리)
2. **프롬프트 1** 복사
3. `blog_data.json` 내용을 `[여기에 API 응답 JSON을 붙여넣으세요]` 부분에 붙여넣기
4. Claude가 블로그 JSON을 생성할 때까지 대기

### Step 3: 블로그 발행

Claude가 생성한 JSON을 파일로 저장:
```bash
# Claude의 출력을 blog_post.json에 저장
cat > blog_post.json << 'EOF'
{
  "title": "...",
  "slug": "...",
  "content": "...",
  "excerpt": "...",
  "keywords": "..."
}
EOF
```

발행:
```bash
curl -X POST "http://localhost:8080/api/admin/blog/posts" \
  -H "Content-Type: application/json" \
  -d @blog_post.json | jq .
```

### Step 4: 확인

```bash
# 블로그 목록 확인
curl "http://localhost:8080/api/blog/posts" | jq '.posts[] | {id, title, slug}'

# 특정 블로그 확인
curl "http://localhost:8080/api/blog/posts/2025-10-11-peace" | jq '{title, view_count}'
```

---

## 🎯 추천 키워드 목록

### 감정 관련
- 사랑, 평안, 감사, 기쁨, 위로, 희망, 소망

### 신앙 관련
- 믿음, 구원, 은혜, 회개, 순종, 겸손, 인내

### 관계 관련
- 용서, 화해, 가족, 형제, 섬김

### 일상 관련
- 직장, 건강, 지혜, 인도, 도움

### 영적 관련
- 기도, 찬양, 예배, 성령, 말씀, 진리

---

## ⚠️ 주의사항

1. **중복 방지**:
   - 같은 slug는 사용 불가 (날짜를 다르게 설정)
   - `random=true` 파라미터로 다양한 콘텐츠 생성

2. **데이터 검증**:
   - API 응답에 `has_bible`, `has_prayer`, `has_hymn`을 확인
   - 데이터가 없으면 다른 키워드 시도

3. **콘텐츠 품질**:
   - Claude가 생성한 내용을 검토 후 발행
   - 성경 구절이 정확한지 확인
   - 신학적으로 문제가 없는지 검토

4. **환경 분리**:
   - 개발 Claude 세션: 코드 작성, 디버깅
   - 블로그 Claude 세션: 콘텐츠 생성 전용

---

## 🚀 자동화 아이디어

### GitHub Actions로 매일 자동 발행

```yaml
# .github/workflows/daily-blog.yml
name: Daily Blog Generation

on:
  schedule:
    - cron: '0 9 * * *'  # 매일 오전 9시 (KST 18시)
  workflow_dispatch:  # 수동 실행

jobs:
  generate-blog:
    runs-on: ubuntu-latest
    steps:
      - name: Fetch data
        run: |
          KEYWORD=$(shuf -n1 -e "사랑" "평안" "감사" "믿음" "소망")
          curl "https://your-domain.com/api/admin/blog/generate-data?keyword=$KEYWORD&random=true" \
            -o blog_data.json

      - name: Generate blog with Claude API
        env:
          ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
        run: |
          # Claude API 호출하여 블로그 생성
          # (프롬프트와 blog_data.json 전달)

      - name: Publish blog
        run: |
          curl -X POST "https://your-domain.com/api/admin/blog/posts" \
            -H "Content-Type: application/json" \
            -d @blog_post.json
```

---

## 📊 사용 통계

### 현재 데이터베이스 현황
```bash
# 성경 챕터 통계
curl "http://localhost:8080/api/admin/bible/stats" | jq .

# 키워드별 콘텐츠 개수
curl "http://localhost:8080/api/keywords/featured" | jq '.keywords[] | {name, bible_count, hymn_count}'
```

---

## 💡 팁

1. **다양성 확보**: `random=true`를 항상 사용하여 같은 키워드라도 다른 글 생성
2. **시리즈물**: 같은 키워드로 여러 편 작성 가능 (날짜와 slug만 다르게)
3. **계절 반영**: 시즌에 맞는 키워드 선택 (크리스마스 → 성탄, 부활절 → 부활)
4. **독자 반응**: view_count를 보고 인기 있는 주제를 더 작성

---

## 🔗 참고 링크

- API 전체 문서: `API_DOCUMENTATION.md`
- 서버 배포 가이드: `DEPLOYMENT.md`
- 샘플 스크립트: `scripts/generate_blog_example.sh`
