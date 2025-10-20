# 📍 주님말씀AI 개발 로드맵

## 현재 상태 (2025-10-20)

### ✅ 완성된 핵심 기능
- **블로그 자동 생성 시스템**: Gemini API 기반 콘텐츠 생성
- **찬송가 자동 교체**: API에서 정확한 제목 및 가사 자동 삽입
- **품질 관리**: 5가지 지표 자동 평가 + 재생성 시스템
- **YouTube 임베딩**: 찬송가 영상 자동 검색 및 삽입
- **SEO 최적화**: 블로그 목록 SSR 구현
- **자동 스케줄링**: Cron/systemd 정기 발행

### 🎯 현재 수준
- **기술적 완성도**: 90%
- **콘텐츠 품질**: 85%
- **사용자 경험**: 75%
- **시각적 디자인**: 70%

---

## 🚀 Phase 1: Quick Wins (1-2주)

### 우선순위 1: 블로그 이미지 자동 삽입
**목표**: 시각적 매력도 향상, SEO 개선

#### A. Unsplash API 연동
```go
// internal/unsplash/client.go
- GetImageByKeyword(keyword string) (imageURL, photographer string)
- 키워드 기반 무료 고해상도 이미지 검색
- 저작권 표시 자동 삽입
```

**구현 계획**:
1. Unsplash API 키 발급 (무료: 50 requests/hour)
2. 블로그 생성 시 키워드로 이미지 검색
3. `<img>` 태그를 Markdown 상단에 자동 삽입
4. 출처 표기: "Photo by [작가명] on Unsplash"

**예상 효과**:
- 👁️ 시각적 매력도 +50%
- 📈 클릭률(CTR) +30%
- ⏱️ 체류시간 +20%

#### B. 대체안: 무료 성경 일러스트 DB
- Bible.com, OpenBible.info 등의 무료 이미지
- 직접 큐레이션한 이미지 풀 (100개)
- 키워드별 매핑 테이블

**예상 공수**: 2-3일

---

### 우선순위 2: 읽은 글 표시 기능
**목표**: 개인화된 사용자 경험 제공

#### 구현 방법
```javascript
// web/static/js/reading-tracker.js

// LocalStorage에 읽은 글 ID 저장
function markAsRead(blogId) {
    const readPosts = JSON.parse(localStorage.getItem('readPosts') || '[]');
    if (!readPosts.includes(blogId)) {
        readPosts.push(blogId);
        localStorage.setItem('readPosts', JSON.stringify(readPosts));
    }
}

// 읽은 글 표시
function displayReadStatus() {
    const readPosts = JSON.parse(localStorage.getItem('readPosts') || '[]');
    // 읽은 글에 체크 아이콘 표시
    // 읽지 않은 글에 "New" 배지 표시
}
```

**UI 디자인**:
- ✅ 읽은 글: 회색 체크 아이콘
- 🆕 최근 7일 이내: "New" 배지
- ⭐ 북마크 기능 (선택사항)

**예상 효과**:
- 🔄 재방문율 +15%
- 💡 사용자 편의성 향상

**예상 공수**: 1일

---

### 우선순위 3: 관리자 대시보드 강화
**목표**: 데이터 기반 의사결정

#### Google Analytics 4 연동
```html
<!-- web/templates/layout/base.html -->
<script async src="https://www.googletagmanager.com/gtag/js?id=G-XXXXXXXXXX"></script>
<script>
  window.dataLayer = window.dataLayer || [];
  function gtag(){dataLayer.push(arguments);}
  gtag('js', new Date());
  gtag('config', 'G-XXXXXXXXXX');
</script>
```

#### 백오피스 대시보드에 통계 추가
```go
// internal/backoffice/handlers.go

type DashboardStats struct {
    TodayVisitors    int
    WeeklyVisitors   int
    PopularKeywords  []KeywordStat
    AvgTimeOnPage    float64
    BounceRate       float64
}
```

**표시 지표**:
1. 일별/주별 방문자 수
2. 인기 키워드 TOP 10
3. 평균 체류시간
4. 이탈률 (Bounce Rate)
5. 블로그별 조회수 랭킹

**예상 공수**: 2일 (GA 연동) + 1일 (대시보드)

---

## 🎨 Phase 2: 사용자 경험 개선 (2-4주)

### 1. Web Push 알림 시스템
**목표**: 재방문율 증가

#### 구현 요소
- **PWA 완성**: Service Worker + Web App Manifest
- **알림 권한 요청**: 부드러운 UX (강제 X)
- **알림 시간 설정**: 사용자가 선택 (오전 7시, 점심, 저녁)
- **푸시 서버**: Firebase Cloud Messaging (무료)

#### 알림 콘텐츠
- "오늘의 말씀" (랜덤 성경 구절)
- "새 블로그 발행 알림"
- "일주일 만에 돌아오셨네요! 🙏"

**예상 효과**:
- 🔔 재방문율 +40%
- 💙 사용자 충성도 향상

**예상 공수**: 5일

---

### 2. 성경 구절 카드 이미지 생성
**목표**: SNS 바이럴, 자연스러운 유입

#### 기술 스택
```
Canvas API (Node.js) 또는 Go 이미지 라이브러리
+ Google Fonts (Noto Sans KR)
+ 무료 배경 이미지
```

#### 기능
- 성경 구절 텍스트 입력
- 자동으로 카드 이미지 생성
- 다운로드 버튼 (PNG, JPG)
- 카카오톡, 페이스북 직접 공유

**예상 효과**:
- 📱 SNS 공유 +300%
- 🌊 바이럴 효과

**예상 공수**: 4일

---

### 3. 블로그 공유 개선
**목표**: 소셜 미디어 최적화

#### Open Graph 메타태그 개선
```html
<meta property="og:image" content="[Unsplash 이미지 또는 자동 생성 카드]">
<meta property="og:description" content="[블로그 발췌문 100자]">
<meta property="twitter:card" content="summary_large_image">
```

#### 공유 버튼 추가
- 카카오톡 공유 (Kakao SDK)
- 페이스북 공유
- 트위터 공유
- URL 복사

**예상 공수**: 2일

---

## 💎 Phase 3: 커뮤니티 기능 (1-2개월)

### 1. 댓글 시스템

#### 옵션 A: Disqus (빠른 도입)
- **장점**: 설치 5분, 스팸 필터 내장, 무료
- **단점**: 광고, 제3자 의존성

#### 옵션 B: 자체 구축
```go
// 테이블 설계
type Comment struct {
    ID        int
    BlogID    int
    Author    string  // 익명 또는 닉네임
    Content   string
    CreatedAt time.Time
    IsApproved bool   // 관리자 승인
}
```

**기능**:
- 익명 댓글 (이메일만 수집)
- 관리자 승인 시스템
- 욕설 필터링
- 대댓글 (1depth만)

**예상 공수**: 5일 (Disqus) / 2주 (자체)

---

### 2. 기도 제목 공유
**목표**: 커뮤니티 참여, 영적 연결

#### 기능
```go
type PrayerRequest struct {
    ID        int
    Title     string   // 기도 제목
    Content   string   // 상세 내용 (선택)
    Author    string   // 익명 가능
    PrayCount int      // "함께 기도합니다" 카운트
    CreatedAt time.Time
}
```

**UI**:
- 기도 제목 작성 폼
- 목록 보기 (최신순, 인기순)
- "함께 기도합니다" 버튼 (하트 아이콘)
- 개인정보 보호 (익명 옵션)

**예상 공수**: 1주

---

## ⚡ Phase 4: 성능 최적화 (선택적, 트래픽 증가 시)

### 1. Redis 캐싱
**목표**: 응답 속도 10배 향상

#### 캐싱 대상
- 블로그 목록 (1분 TTL)
- 인기 블로그 (10분 TTL)
- 성경 구절 검색 결과 (5분 TTL)

#### 인프라
- AWS ElastiCache (t4g.micro: $13/월)
- 또는 EC2 인스턴스에 Redis 직접 설치 (무료)

**예상 효과**:
- ⚡ 응답 속도: 200ms → 20ms
- 💰 DB 부하 감소 → 비용 절감

**예상 공수**: 3일

---

### 2. CDN 이미지 최적화
**목표**: 로딩 속도 개선

#### 기능
- Unsplash 이미지 WebP 변환
- Lazy Loading (Intersection Observer)
- Responsive Images (srcset)

**예상 효과**:
- 📉 페이지 로딩 시간 -40%
- 📱 모바일 경험 개선

**예상 공수**: 2일

---

## 💰 Phase 5: 수익화 (장기)

### 1. 후원 시스템
**옵션**:
- Buy Me a Coffee
- Toss 간편 결제 링크
- GitHub Sponsors

**메시지**: "서버 운영 후원하기 ☕"

---

### 2. 전자책 (eBook)
**내용**: 월별 인기 블로그 모음집
- PDF / EPUB 형식
- 무료 또는 $2.99

---

## 📊 성공 지표 (KPI)

### 단기 (3개월)
- 일 방문자: 100명 → 500명
- 페이지뷰: 500 → 2,000
- 평균 체류시간: 1분 → 3분
- 재방문율: 10% → 30%

### 중기 (6개월)
- 일 방문자: 500명 → 2,000명
- SNS 공유: 0 → 100회/주
- 댓글/기도 제목: 0 → 50개/주

### 장기 (1년)
- 일 방문자: 2,000명 → 10,000명
- 후원 수익: $0 → $50/월 (서버 비용 충당)
- 커뮤니티: 활성 사용자 1,000명

---

## 🎯 다음 스프린트 추천 (2주)

**Week 1**:
1. Unsplash API 연동 (2일)
2. 읽은 글 표시 기능 (1일)
3. 테스트 및 버그 수정 (2일)

**Week 2**:
1. Google Analytics 연동 (1일)
2. 관리자 대시보드 통계 (2일)
3. 문서화 및 배포 (2일)

**예상 결과**:
- 블로그 이미지 100% 적용
- 사용자 읽기 경험 개선
- 데이터 기반 의사결정 가능

---

## 🤔 의사결정 기준

### 우선순위 판단
1. **개발 비용** (시간/돈)
2. **사용자 가치** (얼마나 도움이 되는가)
3. **기술적 복잡도**
4. **유지보수 부담**

### 추가하지 않기로 한 것들
- ❌ 로그인 시스템 (현재 불필요)
- ❌ 결제 시스템 (조기 수익화 부담)
- ❌ 관리자 권한 관리 (1인 운영)

---

**작성일**: 2025-10-20
**다음 업데이트**: Phase 1 완료 후
