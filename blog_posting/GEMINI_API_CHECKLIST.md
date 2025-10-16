# Gemini API 전환 체크리스트

## 📋 구현 체크리스트

### 1. API 기본 설정
- [ ] **Gemini API 키 획득**
  - Google AI Studio에서 API 키 생성
  - `.env` 파일에 `GEMINI_API_KEY` 추가

- [ ] **API 엔드포인트 확인**
  - Base URL: `https://generativelanguage.googleapis.com/v1beta/models/`
  - Model: `gemini-1.5-pro-latest` 또는 `gemini-1.5-flash`

### 2. 기술 구현 사항

#### 2.1 프롬프트 파일 관리 (`prompts/blog_generation_prompt.txt`)
- [ ] **프롬프트 파일 구조**
  - [ ] 텍스트 파일로 프롬프트 저장
  - [ ] 변수 치환을 위한 플레이스홀더 사용 (`{{keyword}}`, `{{date}}` 등)
  - [ ] 버전 관리 가능하도록 Git에 포함

- [ ] **프롬프트 템플릿 예시**
  ```txt
  당신은 기독교 신앙 블로그 전문 작가입니다.

  ## 오늘의 정보
  - 날짜: {{date}}
  - 요일: {{day_of_week}}
  - 키워드: {{keyword}}

  ## 제공된 콘텐츠
  {{bible_verses}}
  {{hymns}}
  {{prayers}}

  ## 작성 지침
  [기존 CLAUDE_PROMPT.md 내용 참조]

  ## 출력 형식
  반드시 JSON 형식으로 출력하세요:
  {
    "title": "...",
    "content": "...",
    ...
  }
  ```

- [ ] **프롬프트 로딩 로직**
  ```python
  def load_prompt_template(template_path):
      with open(template_path, 'r', encoding='utf-8') as f:
          return f.read()

  def render_prompt(template, data):
      prompt = template
      for key, value in data.items():
          prompt = prompt.replace(f'{{{{{key}}}}}', str(value))
      return prompt
  ```

#### 2.2 API 호출 스크립트 (`scripts/generate_blog.py`)
- [ ] **기본 구조**
  ```python
  - API 키 로드 (환경변수)
  - 프롬프트 파일 로드 및 변수 치환
  - API 호출 함수
  - 응답 파싱
  - JSON 저장
  ```

- [ ] **주요 기능**
  - [ ] 데이터 준비 (성경구절, 찬송가, 기도문)
  - [ ] 프롬프트 템플릿 로드 (`prompts/blog_generation_prompt.txt`)
  - [ ] 변수 치환 (날짜, 키워드, 콘텐츠)
  - [ ] API 요청 생성
  - [ ] 응답 처리 및 검증
  - [ ] 출력 형식 변환

#### 2.2 데이터 준비 (`scripts/prepare_data.sh`)
- [ ] **데이터베이스에서 가져올 정보**
  - [ ] 키워드별 성경구절 (최대 5개)
  - [ ] 키워드별 찬송가 (최대 3개)
  - [ ] 키워드별 기도문 (최대 2개)

- [ ] **데이터 형식**
  ```json
  {
    "keyword": "평안",
    "date": "2025-10-15",
    "bible_verses": [...],
    "hymns": [...],
    "prayers": [...]
  }
  ```

### 3. Gemini API 요청 형식

#### 3.1 요청 구조
```python
request = {
    "contents": [{
        "parts": [{
            "text": prompt_text
        }]
    }],
    "generationConfig": {
        "temperature": 0.7,
        "topP": 0.95,
        "maxOutputTokens": 8192,
        "responseMimeType": "application/json"
    }
}
```

#### 3.2 프롬프트 구성
- [ ] **시스템 지시사항**
  - 기독교 블로그 작가 역할
  - JSON 형식 출력
  - 한국어 작성

- [ ] **입력 데이터**
  - 오늘의 키워드
  - 날짜/요일 정보
  - 관련 콘텐츠 (성경, 찬송가, 기도문)

- [ ] **출력 형식 지정**
  ```json
  {
    "title": "블로그 제목",
    "slug": "url-slug",
    "keyword": "키워드",
    "content": "본문 내용 (HTML)",
    "summary": "요약 (150자)",
    "tags": ["태그1", "태그2"],
    "meta_description": "메타 설명"
  }
  ```

### 4. 에러 처리

- [ ] **API 관련 에러**
  - [ ] 인증 실패 (401)
  - [ ] 할당량 초과 (429)
  - [ ] 서버 에러 (500)

- [ ] **데이터 검증**
  - [ ] JSON 파싱 에러
  - [ ] 필수 필드 누락
  - [ ] 형식 불일치

- [ ] **재시도 로직**
  - [ ] 최대 3회 재시도
  - [ ] 지수 백오프 적용
  - [ ] 에러 로깅

### 5. 컨텐츠 품질 평가 시스템

#### 5.1 품질 평가 방식
- [ ] **옵션 1: Gemini API로 자체 평가 (권장)**
  - 생성된 콘텐츠를 다시 Gemini에 보내서 평가
  - 비용: 약간 증가하지만 일관성 높음
  - 속도: 빠름 (API 2회 호출)

- [ ] **옵션 2: 규칙 기반 평가**
  - Python으로 체크리스트 검증
  - 비용: 무료
  - 속도: 매우 빠름
  - 정확도: 낮음

#### 5.2 품질 평가 스크립트 (`scripts/evaluate_quality.py`)
- [ ] **평가 항목**
  ```python
  quality_criteria = {
      "theological_accuracy": {
          "weight": 0.3,
          "checks": [
              "성경 인용 정확성",
              "신학적 오류 없음",
              "교리 적합성"
          ]
      },
      "content_structure": {
          "weight": 0.25,
          "checks": [
              "도입-본론-결론 구조",
              "문단 구성 적절성",
              "논리적 흐름"
          ]
      },
      "engagement": {
          "weight": 0.2,
          "checks": [
              "독자 공감 유도",
              "실생활 적용 가능성",
              "감정적 연결"
          ]
      },
      "technical_quality": {
          "weight": 0.15,
          "checks": [
              "맞춤법 및 문법",
              "적절한 어휘 사용",
              "문장 길이 적절성"
          ]
      },
      "seo_optimization": {
          "weight": 0.1,
          "checks": [
              "키워드 포함 여부",
              "메타 설명 최적화",
              "제목 매력도"
          ]
      }
  }
  ```

- [ ] **평가 프롬프트 템플릿** (`prompts/quality_evaluation_prompt.txt`)
  ```txt
  다음 블로그 포스트를 평가해주세요.

  ## 평가 대상 포스트
  {{generated_content}}

  ## 평가 기준 (각 항목 1-10점)
  1. 신학적 정확성 (가중치 30%)
  2. 콘텐츠 구조 (가중치 25%)
  3. 독자 참여도 (가중치 20%)
  4. 기술적 품질 (가중치 15%)
  5. SEO 최적화 (가중치 10%)

  ## 출력 형식 (JSON)
  {
    "scores": {
      "theological_accuracy": 8,
      "content_structure": 7,
      "engagement": 9,
      "technical_quality": 8,
      "seo_optimization": 7
    },
    "total_score": 7.9,
    "feedback": {
      "strengths": ["장점1", "장점2"],
      "improvements": ["개선점1", "개선점2"]
    },
    "recommendation": "publish" // or "revise" or "reject"
  }
  ```

- [ ] **평가 로직**
  ```python
  def evaluate_content(content):
      # 1. 평가 프롬프트 로드
      eval_prompt = load_prompt_template('prompts/quality_evaluation_prompt.txt')

      # 2. 콘텐츠 삽입
      prompt = render_prompt(eval_prompt, {
          'generated_content': json.dumps(content, ensure_ascii=False)
      })

      # 3. Gemini API 호출
      evaluation = call_gemini_api(prompt)

      # 4. 점수 확인
      return evaluation

  def should_publish(evaluation, threshold=7.0):
      return evaluation['total_score'] >= threshold
  ```

#### 5.3 발행 기준 설정
- [ ] **최소 품질 점수**
  - 기본 임계값: 7.0/10.0
  - 환경변수로 조정 가능: `QUALITY_THRESHOLD`

- [ ] **필수 통과 항목**
  - 신학적 정확성: 최소 6.0 이상
  - 맞춤법/문법: 최소 7.0 이상

- [ ] **자동 재생성 로직**
  ```python
  max_attempts = 3
  for attempt in range(max_attempts):
      content = generate_blog(data)
      evaluation = evaluate_content(content)

      if should_publish(evaluation):
          publish(content)
          break
      else:
          # 피드백을 프롬프트에 추가하여 재생성
          data['feedback'] = evaluation['feedback']
  ```

### 6. 스크립트 통합

#### 6.1 메인 실행 스크립트 (`scripts/run_blog_generation.sh`)
```bash
#!/bin/bash
# 1. 데이터 준비
./prepare_data.sh

# 2. Gemini API 호출 (콘텐츠 생성)
python3 generate_blog.py

# 3. 품질 평가
python3 evaluate_quality.py

# 4. 평가 결과 확인
if [ $? -eq 0 ]; then
    echo "✅ 품질 평가 통과 - 발행 진행"
    # 5. DB 저장
    ./save_to_db.sh
else
    echo "❌ 품질 평가 실패 - 재생성 필요"
    exit 1
fi
```

#### 6.2 품질 평가 워크플로우
```
[데이터 준비]
    ↓
[Gemini: 콘텐츠 생성]
    ↓
[Gemini: 품질 평가]
    ↓
[점수 >= 7.0?]
    ├─ Yes → [DB 저장 및 발행]
    └─ No  → [피드백 추가 후 재생성 (최대 3회)]
```

### 7. 테스트 항목

- [ ] **단위 테스트**
  - [ ] API 연결 테스트
  - [ ] 프롬프트 생성 테스트
  - [ ] 응답 파싱 테스트

- [ ] **통합 테스트**
  - [ ] 전체 파이프라인 테스트
  - [ ] 다양한 키워드 테스트
  - [ ] 에러 상황 테스트

### 8. 문서화

- [ ] **README.md 업데이트**
  - [ ] Gemini API 사용법
  - [ ] 설치 및 설정 가이드
  - [ ] 실행 방법
  - [ ] 품질 평가 시스템 설명

- [ ] **API_GUIDE.md 작성**
  - [ ] Gemini API 상세 설명
  - [ ] 요청/응답 예시
  - [ ] 트러블슈팅 가이드
  - [ ] 품질 평가 기준 문서화

- [ ] **프롬프트 버전 관리**
  - [ ] `prompts/` 폴더에 모든 프롬프트 저장
  - [ ] 변경 이력 Git으로 관리
  - [ ] 버전별 성능 비교 문서화

## 🔧 기술 스택

### 필요 패키지
```bash
# Python
pip install google-generativeai
pip install python-dotenv
pip install requests

# Bash
jq (JSON 파싱용)
curl (API 테스트용)
```

## 📝 참고사항

### Gemini vs Claude 차이점
1. **API 형식**
   - Gemini: REST API with JSON
   - Claude: Messages API

2. **토큰 제한**
   - Gemini 1.5 Pro: 입력 2M, 출력 8K
   - Claude: 입력 200K, 출력 4K

3. **가격**
   - Gemini: 더 저렴한 편
   - Claude: 품질 대비 가격 높음

### 장점
- API 직접 호출로 자동화 용이
- JSON 응답 형식 지정 가능
- 대용량 컨텍스트 처리
- 빠른 응답 속도

### 주의사항
- API 키 보안 관리 필수
- Rate Limiting 고려
- 비용 모니터링 필요
- 응답 품질 검증 필요

## 🚀 다음 단계

1. API 키 설정 확인
2. 기본 스크립트 작성
3. 테스트 실행
4. 프로덕션 배포

---

*최종 업데이트: 2025-10-15*