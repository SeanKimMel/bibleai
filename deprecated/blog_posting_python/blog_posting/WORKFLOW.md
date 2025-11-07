# 블로그 발행 워크플로우

완전한 단계별 가이드입니다.

---

## 🔄 전체 프로세스

```
1. 키워드 선택
   ↓
2. 데이터 수집 (API)
   ↓
3. Claude에게 블로그 작성 요청 (별도 세션)
   ↓
4. 생성된 블로그 검토
   ↓
5. 블로그 발행 (API)
   ↓
6. 결과 확인
```

---

## 📝 상세 단계

### Step 1: 키워드 선택

**추천 키워드 목록**:
```
감정: 사랑, 평안, 감사, 기쁨, 위로, 희망, 소망
신앙: 믿음, 구원, 은혜, 회개, 순종, 겸손, 인내
관계: 용서, 화해, 가족, 형제, 섬김
일상: 직장, 건강, 지혜, 인도, 도움
영적: 기도, 찬양, 예배, 성령, 말씀, 진리
```

**선택 기준**:
- 시즌성 (크리스마스 → 성탄, 부활절 → 부활)
- 독자 관심도 (view_count 확인)
- 다양성 (최근에 다루지 않은 주제)

---

### Step 2: 데이터 수집

#### 방법 A: 스크립트 사용 (추천)
```bash
cd /workspace/bibleai/blog_posting
./scripts/fetch_data.sh 감사
```

#### 방법 B: 직접 curl
```bash
curl "http://localhost:8080/api/admin/blog/generate-data?keyword=감사&random=true" \
  | jq . > data.json
```

#### 확인사항:
```bash
# 데이터 요약 확인
cat data.json | jq '{
  keyword,
  has_bible: .summary.has_bible,
  has_prayer: .summary.has_prayer,
  has_hymn: .summary.has_hymn,
  bible_chapter: .data.bible.chapter,
  hymns_count: (.data.hymns | length)
}'
```

- `has_bible: true` 필수
- `has_hymn: true` 권장
- 찬송가 0개면 다른 키워드 시도

---

### Step 3: Claude에게 작성 요청 (별도 세션)

**중요**: 개발 Claude와 분리된 **새 Claude 창** 사용

1. **프롬프트 준비**:
   ```bash
   cat CLAUDE_PROMPT.md
   ```

2. **찬송가 비디오 ID 확인/생성** (data.json에 찬송가가 있는 경우):
   ```bash
   # 데이터베이스에서 확인
   ./scripts/get_hymn_video.sh 200

   # 없으면 자동 검색 (완전 자동화!)
   ./scripts/auto_find_hymn_video.sh "찬송가 200장 주 품에 품으소서"

   # 출력된 비디오 ID를 메모
   # 예: XP8WsSZAx1o
   ```

3. **새 Claude 세션 시작**

4. **프롬프트 복사 + 데이터 붙여넣기**:
   - `CLAUDE_PROMPT.md` 전체 복사
   - `[여기에 data.json 내용을 붙여넣으세요]` 부분에 `data.json` 내용 붙여넣기
   - (선택) 찬송가 비디오 ID를 추가로 제공

5. **Claude가 JSON 생성 대기** (1-2분)

6. **생성된 JSON 저장**:
   ```bash
   # Claude의 출력을 복사하여 저장
   cat > output.json << 'EOF'
   {
     "title": "...",
     "slug": "...",
     ...
   }
   EOF
   ```

---

### Step 4: 생성된 블로그 검토

#### 자동 검증:
```bash
# JSON 형식 검증
jq . output.json

# 필수 필드 확인
jq '{title, slug, excerpt_length: (.excerpt | length), keywords}' output.json
```

#### 수동 검토 체크리스트:
- [ ] 성경 구절이 정확한가?
- [ ] 이모지가 없는가?
- [ ] slug가 유일한가? (날짜 확인)
- [ ] excerpt가 100-200자인가?
- [ ] 신학적으로 문제없는가?
- [ ] 오타나 어색한 표현은 없는가?

#### 수정이 필요하면:
```bash
# output.json 편집
nano output.json

# 또는 Claude에게 수정 요청
# "위 블로그에서 slug를 2025-10-12로 변경해주세요"
```

---

### Step 5: 블로그 발행

#### 방법 A: 스크립트 사용 (추천)
```bash
./scripts/publish_blog.sh output.json
```

#### 방법 B: 직접 curl
```bash
curl -X POST "http://localhost:8080/api/admin/blog/posts" \
  -H "Content-Type: application/json" \
  -d @output.json \
  | jq .
```

#### 성공 응답:
```json
{
  "success": true,
  "message": "블로그가 생성되었습니다",
  "id": 5
}
```

---

### Step 6: 결과 확인

#### 웹에서 확인:
```
http://localhost:8080/blog
```

#### API로 확인:
```bash
# 최신 블로그 목록
curl "http://localhost:8080/api/blog/posts?page=1&limit=5" \
  | jq '.posts[] | {id, title, view_count}'

# 특정 블로그 상세
curl "http://localhost:8080/api/blog/posts/2025-10-11-slug" \
  | jq '{title, view_count, keywords}'
```

#### 통계:
```bash
# 전체 블로그 개수
curl -s "http://localhost:8080/api/blog/posts" | jq '.total'
```

---

## ⚡ 빠른 가이드 (숙련자용)

```bash
# 1. 데이터 수집
./scripts/fetch_data.sh 평안

# 2. 찬송가 비디오 ID 확인 (자동!)
./scripts/auto_find_hymn_video.sh "찬송가 200장 주 품에 품으소서"

# 3. Claude 세션에서 블로그 작성
# (CLAUDE_PROMPT.md + data.json)

# 4. 발행
./scripts/publish_blog.sh output.json

# 5. 확인
curl "http://localhost:8080/api/blog/posts?page=1&limit=1" | jq '.posts[0]'
```

---

## 🚨 문제 해결

### 문제 1: "데이터가 없습니다"
```bash
# 다른 키워드 시도
./scripts/fetch_data.sh 사랑
```

### 문제 2: "slug가 중복됩니다"
```json
{
  "error": "duplicate key value violates unique constraint"
}
```
→ `output.json`에서 slug 날짜 변경

### 문제 3: "JSON 파싱 오류"
```bash
# JSON 검증
jq . output.json

# 이스케이프 확인 (특히 따옴표, 개행)
```

### 문제 4: "성경 구절이 이상합니다"
→ Claude에게 수정 요청:
```
"성경 구절을 data.json에 있는 원문 그대로 사용해주세요"
```

---

## 📊 작업 기록

작업 후 기록 남기기:
```bash
echo "$(date): 키워드=평안, slug=2025-10-11-peace, id=5" >> work_log.txt
```

---

## 🎯 다음 단계

1. **자동화**: GitHub Actions로 매일 자동 발행
2. **분석**: view_count로 인기 주제 파악
3. **시리즈**: 같은 키워드로 시리즈물 구성
4. **다양화**: 새로운 키워드 조합 시도
