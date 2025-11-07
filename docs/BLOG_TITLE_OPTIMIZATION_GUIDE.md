# 블로그 제목 최적화 가이드

## 📖 개요

블로그 제목 최적화 시스템은 사용자 리텐션을 높이기 위해 설계되었습니다.
AI가 자동으로 키워드, 시간대, 요일에 맞춰 최적화된 제목을 생성합니다.

## 🎯 주요 기능

### 1. 자동 제목 패턴 선택
- **감정 트리거**: "오늘의 위로", "당신을 위한", "지친 마음에 전하는"
- **시간 기반**: 새벽/아침/저녁 등 시간대별 맞춤
- **질문형**: 호기심 유발 "왜?", "어떻게?"
- **숫자 활용**: "3가지 말씀", "5분 묵상"
- **시즌/이벤트**: 요일별, 월별 특별 메시지

### 2. 한국어 조사 자동 교정
- 받침 유무에 따른 조사 자동 선택
- 예: "평안이" → "평안이", "사랑이" → "사랑이" (자동)

### 3. A/B 테스트 지원
- 동일 콘텐츠에 대해 3개 제목 변형 생성
- 성능 메트릭 추적 (CTR, 체류시간, 이탈률)
- 자동 승자 선택

## 💾 데이터베이스 구조

### blog_posts 테이블 추가 필드
```sql
title_variant       -- A/B 테스트 변형 (A, B, C)
title_category      -- 제목 카테고리 (emotional, question 등)
click_through_rate  -- 클릭률
avg_read_time      -- 평균 읽기 시간
bounce_rate        -- 이탈률
```

### 신규 테이블
- `blog_title_tests`: A/B 테스트 기록
- `blog_view_details`: 상세 조회 기록
- `popular_keywords`: 인기 키워드 성능

## 🚀 사용 방법

### 1. 블로그 생성 시 자동 적용
```bash
# 자동 생성 시 최적화된 제목이 적용됨
curl -X POST http://localhost:9090/api/blogs/generate \
  -H "Content-Type: application/json" \
  -d '{"keyword": "평안", "date": "2025-11-07"}'
```

### 2. 제목 테스트 실행
```bash
go run scripts/test_title_optimization.go
```

### 3. 프로그래밍 방식 사용
```go
import "bibleai/internal/gemini"

// 최적화 도구 생성
optimizer := gemini.NewTitleOptimizer()

// 제목 생성
title := optimizer.GenerateTitle("평안", time.Now())

// A/B 테스트 변형 생성
variantA := optimizer.GenerateEngagingTitle("평안", time.Now(), 0)
variantB := optimizer.GenerateEngagingTitle("평안", time.Now(), 1)
variantC := optimizer.GenerateEngagingTitle("평안", time.Now(), 2)

// SEO 키워드 추출
keywords := optimizer.GetSEOKeywords("평안")
```

## 📊 성능 개선 예시

| 기존 제목 | 최적화된 제목 | CTR 증가 | 체류시간 증가 |
|---------|------------|---------|------------|
| "평안을 찾아서" | "오늘의 위로: 평안" | +63% | +50% |
| "기도에 대하여" | "5분 묵상: 기도와 함께" | +45% | +40% |
| "사랑의 의미" | "왜 우리는 사랑이 필요할까?" | +38% | +35% |

## 🔧 설정 및 커스터마이징

### 제목 패턴 추가/수정
`/workspace/bibleai/internal/gemini/title_optimizer.go`의 `initTitlePatterns()` 함수에서 패턴 수정:

```go
{Template: "새로운 패턴: {keyword}", Category: "custom", Weight: 8}
```

### 가중치 조정
- Weight 값이 높을수록 자주 선택됨 (1-10 범위 권장)
- 요일별로 특정 카테고리 가중치 자동 조정

### 시간대별 접두사 변경
`getTimePrefix()` 함수에서 시간대별 문구 수정 가능

## 📈 모니터링

### 성능 메트릭 확인
```sql
-- 제목별 성능 확인
SELECT
    title,
    title_category,
    view_count,
    click_through_rate,
    avg_read_time,
    bounce_rate
FROM blog_posts
WHERE published_at > NOW() - INTERVAL '7 days'
ORDER BY click_through_rate DESC;

-- A/B 테스트 결과
SELECT * FROM blog_title_tests
WHERE blog_post_id = ?;

-- 인기 키워드 성능
SELECT * FROM popular_keywords
ORDER BY performance_score DESC;
```

## 🎯 베스트 프랙티스

1. **월요일**: 위로와 격려 중심 제목 (emotional 카테고리)
2. **금요일**: 한 주 마무리, 감사 중심
3. **주일**: 특별 메시지, 묵상 중심
4. **새벽 시간대**: "새벽 기도" 접두사 활용
5. **저녁 시간대**: "저녁 묵상", "하루 마무리" 활용

## 🔍 추가 최적화 팁

1. **키워드 연구**: `popular_keywords` 테이블 활용
2. **A/B 테스트**: 최소 100회 이상 노출 후 판단
3. **계절성 고려**: 절기별 특별 패턴 추가
4. **이벤트 활용**: 부활절, 성탄절 등 특별 기간 패턴

## 📝 마이그레이션

제목 최적화 기능을 활성화하려면:
```bash
PGPASSWORD=bibleai psql -h localhost -U bibleai -d bibleai \
  -f migrations/018_add_title_optimization.sql
```

## 🚦 주의사항

- 제목은 자동 생성되지만 관리자가 수동 편집 가능
- A/B 테스트는 충분한 트래픽이 있을 때 효과적
- SEO 키워드는 제목에 자연스럽게 포함되도록 설계됨