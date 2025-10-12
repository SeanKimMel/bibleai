# 블로그 품질 검증 가이드

블로그 발행 전/후 품질을 검증하기 위한 평가 기준과 자동 검증 스크립트 개발 가이드

---

## 📊 평가 기준 (총 100점)

### 1. 신학적 정확성 (20점)

**평가 항목:**
- [ ] 성경 본문이 정확하게 인용되었는가?
- [ ] 성경 해석이 신학적으로 건전한가?
- [ ] 과장이나 왜곡이 없는가?
- [ ] 이단적 내용이 없는가?
- [ ] 성경 구절의 맥락을 올바르게 이해하고 있는가?

**배점:**
- 20점: 모든 항목 완벽
- 15점: 경미한 해석상 차이 1개
- 10점: 해석상 문제 2-3개
- 5점: 심각한 신학적 오류
- 0점: 이단적 내용 포함

**자동 검증 방법:**
```javascript
// 체크 항목:
1. 성경 구절 형식 검증: /([\w가-힣]+)\s+(\d+):(\d+)/
2. "이모지" 금지 규칙 확인
3. 금지 키워드 검색: ["이단", "영지주의", "기복신앙" 등]
4. 과장 표현 검색: ["반드시", "절대", "100%" 등]
```

---

### 2. 찬송가 정확성 (15점)

**평가 항목:**
- [ ] 찬송가 번호와 제목이 일치하는가?
- [ ] 새찬송가/통일찬송가 구분이 정확한가?
- [ ] 작사/작곡자 정보가 정확한가?
- [ ] 가사 인용이 정확한가? (제공된 데이터만 사용)
- [ ] 유튜브 비디오 ID가 검증되었는가?

**배점:**
- 15점: 모든 정보 정확
- 12점: 작은 정보 오류 1개 (작곡자 오타 등)
- 8점: 번호와 제목 불일치
- 0점: 완전히 다른 찬송가

**자동 검증 방법:**
```bash
# 1. 웹 검색으로 찬송가 번호-제목 검증
websearch "새찬송가 {number}장 제목"
# 응답에서 제목 추출하여 비교

# 2. 유튜브 oEmbed API로 비디오 검증
curl "https://www.youtube.com/oembed?url=https://www.youtube.com/watch?v={videoId}&format=json"
# 200 응답이면 OK, 그외는 실패

# 3. 찬송가 제목 패턴 매칭
grep -E "### 찬송가 \d+장: .+" content.md
```

---

### 3. 구조 및 완성도 (15점)

**평가 항목:**
- [ ] 제목이 있는가?
- [ ] 성경 본문 소개 섹션이 있는가?
- [ ] 묵상과 해석 섹션이 있는가? (3-4개 소주제)
- [ ] 찬송가 메시지 섹션이 있는가?
- [ ] 오늘의 적용 섹션이 있는가? (3가지)
- [ ] 마무리 기도가 있는가?
- [ ] 참고(오늘의 찬송)가 있는가?

**배점:**
- 15점: 모든 섹션 존재
- 12점: 1개 섹션 누락
- 9점: 2개 섹션 누락
- 0점: 3개 이상 누락

**자동 검증 방법:**
```javascript
const requiredSections = [
  /^# /m,                              // 제목
  /## 성경 본문 소개/,                  // 성경 소개
  /## 묵상과 해석/,                     // 묵상
  /### /g,                             // 소주제 (최소 3개)
  /## 찬송가가 전하는 메시지/,          // 찬송가
  /## 오늘의 적용/,                     // 적용
  /## 마무리 기도/,                     // 기도
  /\*\*오늘의 찬송\*\*:/                // 참고
];

// 각 패턴이 content에 존재하는지 확인
```

---

### 4. 메시지 연결성 (15점)

**평가 항목:**
- [ ] 성경 본문과 찬송가의 주제가 연결되는가?
- [ ] 찬송가 설명이 본문과 자연스럽게 연결되는가?
- [ ] 전체 메시지가 일관성 있게 흐르는가?
- [ ] 키워드가 본문 내용을 반영하는가?

**배점:**
- 15점: 완벽한 연결성
- 12점: 연결되지만 약간 억지스러움
- 8점: 연결이 약함
- 0점: 전혀 연결 안됨

**자동 검증 방법:**
```javascript
// 1. 키워드 빈도 체크
keywords.split(',').forEach(keyword => {
  const count = (content.match(new RegExp(keyword, 'g')) || []).length;
  if (count < 3) warning(`키워드 "${keyword}" 사용 빈도 낮음`);
});

// 2. 찬송가 섹션에서 성경 본문 언급 확인
const hymnSection = extractSection(content, '## 찬송가가 전하는 메시지');
const bibleRef = extractBibleReference(content);
if (!hymnSection.includes(bibleRef)) {
  warning('찬송가 섹션에 성경 본문 언급 없음');
}
```

---

### 5. 가독성 및 문체 (10점)

**평가 항목:**
- [ ] 쉬운 한국어 사용 (일상 언어)
- [ ] 문단 구조가 명확한가?
- [ ] 이모지가 없는가? (금지 규칙)
- [ ] 적절한 문장 길이 (너무 길지 않음)
- [ ] 전문 용어 남발하지 않음

**배점:**
- 10점: 매우 읽기 쉬움
- 8점: 읽기 쉬우나 일부 긴 문장
- 6점: 다소 어려운 표현
- 0점: 이모지 사용 (금지 규칙 위반)

**자동 검증 방법:**
```javascript
// 1. 이모지 검출
const emojiRegex = /[\u{1F600}-\u{1F64F}\u{1F300}-\u{1F5FF}\u{1F680}-\u{1F6FF}\u{2600}-\u{26FF}\u{2700}-\u{27BF}]/u;
if (emojiRegex.test(content)) {
  error('이모지 사용 금지!');
}

// 2. 평균 문장 길이
const sentences = content.split(/[.!?]/);
const avgLength = sentences.reduce((sum, s) => sum + s.length, 0) / sentences.length;
if (avgLength > 100) {
  warning('평균 문장이 너무 깁니다');
}

// 3. 복잡한 용어 검출
const complexTerms = ['구원론', '종말론', '기독론', '성화', '칭의'];
complexTerms.forEach(term => {
  if (content.includes(term) && !hasExplanation(content, term)) {
    warning(`전문 용어 "${term}" 설명 필요`);
  }
});
```

---

### 6. 적용 가능성 (10점)

**평가 항목:**
- [ ] 3가지 실천 방법이 제시되었는가?
- [ ] 구체적인가? (추상적이지 않음)
- [ ] 실천 가능한가? (현실적)
- [ ] 각 항목이 굵게 표시되었는가?
- [ ] 설명이 충분한가?

**배점:**
- 10점: 3가지 모두 구체적이고 실천 가능
- 8점: 1-2개가 다소 추상적
- 5점: 대부분 추상적
- 0점: 적용 항목 없음

**자동 검증 방법:**
```javascript
// 1. 번호 매긴 항목 3개 확인
const applicationSection = extractSection(content, '## 오늘의 적용');
const numberedItems = applicationSection.match(/^\d\./gm);
if (!numberedItems || numberedItems.length < 3) {
  error('적용 항목이 3개 미만입니다');
}

// 2. 각 항목에 굵은 글씨 있는지 확인
const boldItems = applicationSection.match(/\*\*.+?\*\*/g);
if (!boldItems || boldItems.length < 3) {
  warning('각 적용 항목을 굵게 표시하세요');
}

// 3. 추상적 표현 검출
const abstractTerms = ['노력하세요', '힘쓰세요', '주의하세요'];
abstractTerms.forEach(term => {
  if (applicationSection.includes(term)) {
    warning(`추상적 표현 "${term}" 대신 구체적 행동 제시`);
  }
});
```

---

### 7. 기술적 정확성 (10점)

**평가 항목:**
- [ ] JSON 형식이 올바른가?
- [ ] slug 형식이 정확한가? (YYYY-MM-DD-slug)
- [ ] excerpt 길이가 적절한가? (100-200자)
- [ ] 유튜브 임베드 코드가 정확한가?
- [ ] 모든 링크가 작동하는가?
- [ ] 이스케이프 처리가 정확한가?

**배점:**
- 10점: 모든 기술적 요구사항 충족
- 8점: 경미한 오류 1개
- 5점: 중대한 오류 1개
- 0점: JSON 파싱 실패

**자동 검증 방법:**
```bash
# 1. JSON 검증
jq . output.json > /dev/null 2>&1
if [ $? -ne 0 ]; then
  echo "ERROR: Invalid JSON"
fi

# 2. Slug 형식 검증
slug=$(jq -r '.slug' output.json)
if [[ ! $slug =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}-.+$ ]]; then
  echo "ERROR: Invalid slug format"
fi

# 3. Excerpt 길이
excerpt=$(jq -r '.excerpt' output.json)
length=${#excerpt}
if [ $length -lt 100 ] || [ $length -gt 200 ]; then
  echo "WARNING: Excerpt length should be 100-200 chars (current: $length)"
fi

# 4. 유튜브 임베드 검증
if ! grep -q 'iframe.*youtube.com/embed/' output.json; then
  echo "ERROR: YouTube embed code not found"
fi

# 5. 링크 검증
links=$(jq -r '.content' output.json | grep -oE 'https?://[^\)]+')
for link in $links; do
  curl -s -o /dev/null -w "%{http_code}" "$link" | grep -q "200"
  if [ $? -ne 0 ]; then
    echo "WARNING: Link may be broken: $link"
  fi
done
```

---

### 8. 분량 및 깊이 (5점)

**평가 항목:**
- [ ] 전체 분량이 1500-2500자인가?
- [ ] 묵상 소주제가 3-4개인가?
- [ ] 각 섹션의 설명이 충분한가?
- [ ] 표면적이지 않고 깊이가 있는가?

**배점:**
- 5점: 적절한 분량과 깊이
- 3점: 분량 부족 또는 과다
- 1점: 매우 짧거나 매우 김
- 0점: 1000자 미만

**자동 검증 방법:**
```javascript
// 1. 글자 수 계산
const content = data.content.replace(/[#*>\-\[\]()]/g, ''); // 마크다운 제거
const charCount = content.length;

if (charCount < 1500) {
  warning(`분량 부족: ${charCount}자 (권장: 1500-2500자)`);
} else if (charCount > 3000) {
  warning(`분량 과다: ${charCount}자 (권장: 1500-2500자)`);
} else {
  success(`적절한 분량: ${charCount}자`);
}

// 2. 소주제 개수 확인
const subsections = content.match(/^### /gm);
if (!subsections || subsections.length < 3) {
  warning('묵상 소주제가 3개 미만입니다');
}
```

---

## 🤖 자동 검증 스크립트 개발 가이드

### 스크립트 구조

```bash
#!/bin/bash
# validate_blog.sh

OUTPUT_FILE="output.json"
SCORE=0
MAX_SCORE=100
ERRORS=()
WARNINGS=()

# 1. JSON 검증
validate_json() {
  # ...
}

# 2. 찬송가 번호 웹 검증
validate_hymn() {
  # WebSearch로 번호-제목 확인
  # ...
}

# 3. 구조 검증
validate_structure() {
  # 필수 섹션 존재 여부
  # ...
}

# 4. 기술적 검증
validate_technical() {
  # slug, excerpt, links
  # ...
}

# 5. 품질 검증
validate_quality() {
  # 이모지, 문장 길이, 분량
  # ...
}

# 6. 최종 리포트
generate_report() {
  echo "========================================="
  echo "블로그 품질 검증 결과"
  echo "========================================="
  echo "총점: $SCORE / $MAX_SCORE"
  echo ""
  echo "오류: ${#ERRORS[@]}개"
  for err in "${ERRORS[@]}"; do
    echo "  ❌ $err"
  done
  echo ""
  echo "경고: ${#WARNINGS[@]}개"
  for warn in "${WARNINGS[@]}"; do
    echo "  ⚠️  $warn"
  done
}

# 실행
validate_json
validate_hymn
validate_structure
validate_technical
validate_quality
generate_report
```

---

## 📝 Claude 프롬프트 (자동 검증용)

```
당신은 기독교 블로그 품질 검증 전문가입니다.

다음 JSON 블로그 데이터를 검증하고 점수를 매기세요.

## 평가 기준 (100점 만점)

### 1. 신학적 정확성 (20점)
- 성경 구절이 정확하게 인용되었는가?
- 성경 해석이 신학적으로 건전한가?
- 과장이나 왜곡이 없는가?
- 이단적 내용이 없는가?

### 2. 찬송가 정확성 (15점)
- 찬송가 번호와 제목이 일치하는가? (웹 검색으로 반드시 확인)
- 비디오 ID가 검증되었는가?
- 시즌 적합성 (성탄=12월, 부활=3-4월)
- 성경과의 주제 연결이 자연스러운가?

### 3. 구조 및 완성도 (15점) ⭐ 가장 중요!
**필수 구조 체크:**
- [ ] `# 제목` (H1) - 첫 줄에 있는가?
- [ ] `## 성경 본문 소개` (H2)
- [ ] `## 묵상과 해석` (H2) + ### 소주제 3-4개 (H3)
- [ ] `## 찬송가가 전하는 메시지` (H2) + ### 찬송가 (H3)
- [ ] 찬송가 제목 바로 다음에 iframe 있는가?
- [ ] `## 오늘의 적용` (H2) + 번호 목록 3개
- [ ] `## 마무리 기도` (H2)
- [ ] `---` 구분선 + **오늘의 찬송**

**감점 사항:**
- H1 누락: -5점
- ### 소주제 누락: -3점
- iframe 누락: -2점
- 섹션 이름 변경: -2점 (예: "오늘의 성경", "오늘의 찬송가" 등)

### 4. 메시지 연결성 (15점)
- 키워드 ↔ 성경 본문 연결
- 성경 ↔ 찬송가 주제 연결
- 일관된 메시지 흐름

### 5. 가독성 및 문체 (10점)
- 이모지 없음 (발견 시 0점)
- 명확한 문단 구조
- 쉬운 한국어 사용
- 적절한 문장 길이

### 6. 적용 가능성 (10점)
- 3가지 구체적 실천 방법
- 첫 문장 굵게 표시
- 2-3줄 설명
- 실천 가능성 높음

### 7. 기술적 정확성 (10점)
- JSON 형식 정확
- slug 형식: YYYY-MM-DD-slug
- excerpt 길이: 100-200자
- HTML 태그 정상 작동

### 8. 분량 및 깊이 (5점)
- 1500-2500자 권장
- 묵상 소주제 3-4개
- 표면적이지 않고 깊이 있음

## 검증 절차

1. **구조 검증 (최우선)**: H1, H2, H3 체크
2. **찬송가 번호 웹 검증**: "새찬송가 [번호]장" 검색
3. **각 항목별 점수 산정**
4. **오류/경고 목록 작성**
5. **최종 리포트 생성**

## 출력 형식

```json
{
  "total_score": 95,
  "grade": "A+",
  "scores": {
    "theological": 20,
    "hymn": 15,
    "structure": 15,
    "connection": 15,
    "readability": 10,
    "application": 10,
    "technical": 10,
    "depth": 5
  },
  "structure_check": {
    "h1_title": true,
    "bible_intro": true,
    "meditation_with_subtitles": true,
    "subtitle_count": 3,
    "hymn_section": true,
    "iframe_present": true,
    "application_3items": true,
    "prayer_section": true,
    "today_hymn_footer": true
  },
  "errors": [
    "H1 제목 누락 - 반드시 # 제목으로 시작해야 함",
    "찬송가 섹션에 iframe 누락"
  ],
  "warnings": [
    "## 묵상과 해석 섹션에 ### 소주제가 2개만 있음 (3-4개 권장)"
  ],
  "recommendations": [
    "샘플 구조(samples/blog_output_example.json)를 참고하여 작성하세요"
  ]
}
```

## 평가 후 피드백

**구조 문제 발견 시:**
"⚠️ 구조 문제: [문제점]. samples/blog_output_example.json의 구조를 따라 작성해주세요."

**고득점 블로그:**
"✅ 우수: 구조, 내용, 메시지 연결 모두 탁월합니다."

이제 다음 블로그를 검증하세요:

[블로그 JSON 데이터]
```

---

## 🎯 사용 시나리오

### 시나리오 1: 발행 전 검증
```bash
# 1. 블로그 작성 완료
# 2. 검증 실행
./scripts/validate_blog.sh output.json

# 3. 점수 확인
# 95점 이상: 즉시 발행
# 80-94점: 경고 확인 후 발행
# 80점 미만: 수정 후 재검증
```

### 시나리오 2: 발행 후 품질 관리
```bash
# 기발행 블로그 점수 확인
curl -s "http://localhost:8080/api/blog/posts/[slug]" | \
  ./scripts/validate_blog.sh --stdin

# 평균 점수 계산
./scripts/calc_average_score.sh
```

### 시나리오 3: 배치 검증
```bash
# 모든 블로그 검증
for slug in $(curl -s "http://localhost:8080/api/blog/posts" | jq -r '.posts[].slug'); do
  echo "Validating: $slug"
  curl -s "http://localhost:8080/api/blog/posts/$slug" | \
    ./scripts/validate_blog.sh --stdin --summary
done
```

---

## 📌 참고 사례

### ✅ 고득점 사례 (99점)
- **ID 16**: "하나님께서 주시는 참된 평안"
- 찬송가 200장 "달고 오묘한 그 말씀" (정확)
- 성경-찬송가 완벽 연결
- 구체적 적용 3가지

### ❌ 저득점 사례 (40점)
- **ID 13**: "하나님께서 주시는 참된 평안" (구버전)
- 찬송가 200장 "주 품에 품으소서" (오류)
- 찬송가 번호와 제목 완전 불일치
- 웹 검증 필요성 입증

---

## 🔄 지속적 개선

### 평가 기준 업데이트
- 실제 발행 사례를 통해 기준 개선
- 독자 피드백 반영
- 새로운 품질 지표 추가

### 자동화 확대
- GitHub Actions 통합
- 발행 전 자동 검증
- 품질 리포트 자동 생성
- Slack/이메일 알림

---

**작성일**: 2025-10-08
**버전**: 1.0
**다음 업데이트**: 실제 스크립트 구현 후 피드백 반영
