# 나이든 사용자를 위한 UI/UX 가이드라인

## 🎯 목표
주님말씀AI 웹앱을 나이든 사용자(50세 이상)가 쉽고 편리하게 사용할 수 있도록 접근성과 가시성을 극대화한다.

## 📐 디자인 원칙

### 1. 가독성 최우선 (Readability First)
- **폰트 크기**: 최소 16px 이상 (권장: 18px)
- **줄간격**: `leading-loose` (1.75) 사용
- **색상 대비**: WCAG AA 기준 이상 (4.5:1 이상)
- **폰트 굵기**: 중요 정보는 `font-semibold` 이상

### 2. 터치 친화성 (Touch Friendly)
- **최소 터치 영역**: 44×44px 이상
- **버튼 패딩**: `px-6 py-3` (최소)
- **버튼 간격**: 최소 8px 이상
- **터치 피드백**: hover/active 상태 명확히 표시

### 3. 단순명료함 (Simplicity)
- **한 화면 최대 정보량**: 5-7개 항목
- **계층 구조**: 최대 3단계까지
- **중요 기능 우선**: 80/20 법칙 적용
- **시각적 잡음 최소화**: 그림자, 애니메이션 절제

## 🎨 색상 시스템

### 기본 색상 팔레트
```css
/* 높은 대비 색상 사용 */
--text-primary: #1f2937;     /* 진한 회색 (기존 gray-800) */
--text-secondary: #374151;   /* 중간 회색 (기존 gray-700) */
--text-disabled: #6b7280;    /* 연한 회색 (기존 gray-500) */
--background: #ffffff;       /* 흰색 배경 */
--background-soft: #f9fafb;  /* 연한 배경 (기존 gray-50) */
--border: #d1d5db;          /* 경계선 (기존 gray-300) */
```

### 기능별 색상
```css
/* 성경 검색 */
--bible-primary: #2563eb;   /* blue-600 */
--bible-light: #dbeafe;     /* blue-100 */

/* 기도문 */
--prayer-primary: #059669;  /* green-600 */
--prayer-light: #dcfce7;    /* green-100 */

/* 찬송가 */
--hymn-primary: #9333ea;    /* purple-600 */
--hymn-light: #f3e8ff;     /* purple-100 */

/* 감정분석 */
--analysis-primary: #ea580c; /* orange-600 */
--analysis-light: #fed7aa;   /* orange-100 */
```

## 📝 타이포그래피

### 폰트 크기 시스템
```css
/* 나이든 사용자용 확대된 크기 */
--text-xs: 14px;    /* 보조 정보 (기존 12px) */
--text-sm: 16px;    /* 일반 텍스트 (기존 14px) */
--text-base: 18px;  /* 기본 텍스트 (기존 16px) */
--text-lg: 20px;    /* 강조 텍스트 (기존 18px) */
--text-xl: 24px;    /* 제목 (기존 20px) */
--text-2xl: 28px;   /* 큰 제목 (기존 24px) */
```

### 적용 기준
- **성경 구절**: `text-lg` (20px) + `leading-loose`
- **기도문 내용**: `text-lg` (20px) + `leading-loose`
- **버튼 텍스트**: `text-base` (18px) + `font-medium`
- **제목**: `text-xl` (24px) + `font-semibold`
- **보조 정보**: `text-sm` (16px)

## 🔲 컴포넌트 가이드라인

### 1. 버튼 (Buttons)
```css
.btn-senior-primary {
    @apply px-8 py-4 text-lg font-medium rounded-xl;
    @apply bg-blue-600 text-white;
    @apply hover:bg-blue-700 active:bg-blue-800;
    @apply focus:ring-4 focus:ring-blue-200;
    @apply transition-all duration-200;
    min-height: 48px; /* 최소 높이 보장 */
}

.btn-senior-secondary {
    @apply px-8 py-4 text-lg font-medium rounded-xl;
    @apply bg-gray-100 text-gray-800 border-2 border-gray-300;
    @apply hover:bg-gray-200 active:bg-gray-300;
    @apply focus:ring-4 focus:ring-gray-200;
    min-height: 48px;
}
```

### 2. 카드 (Cards)
```css
.card-senior {
    @apply bg-white rounded-2xl shadow-md p-6;
    @apply border-2 border-gray-200;
    @apply hover:shadow-lg transition-shadow duration-300;
}

.card-senior-interactive {
    @apply card-senior cursor-pointer;
    @apply hover:border-gray-300 hover:-translate-y-1;
    @apply active:translate-y-0;
}
```

### 3. 태그/카테고리 버튼
```css
.tag-senior {
    @apply px-6 py-4 text-lg font-medium rounded-xl;
    @apply bg-white border-2 border-gray-300;
    @apply hover:border-blue-400 hover:bg-blue-50;
    @apply active:bg-blue-100;
    @apply focus:ring-4 focus:ring-blue-200;
    @apply flex items-center space-x-3;
    @apply transition-all duration-200;
    min-height: 60px; /* 더 큰 터치 영역 */
}

.tag-senior.selected {
    @apply bg-blue-600 text-white border-blue-600;
    @apply hover:bg-blue-700 hover:border-blue-700;
}
```

### 4. 아이콘
```css
/* 아이콘 크기 증대 */
.icon-senior-sm { @apply w-6 h-6; }   /* 기존 w-5 h-5 */
.icon-senior-md { @apply w-8 h-8; }   /* 기존 w-6 h-6 */
.icon-senior-lg { @apply w-10 h-10; } /* 기존 w-8 h-8 */
```

## 📱 레이아웃 원칙

### 1. 그리드 시스템
```html
<!-- 2열 그리드 (기존 2×5 → 2×3) -->
<div class="grid grid-cols-2 gap-4 md:gap-6">
    <!-- 각 항목이 충분히 큰 터치 영역 확보 -->
</div>

<!-- 1열 목록 (복잡한 정보용) -->
<div class="space-y-4">
    <!-- 세로 간격 충분히 확보 -->
</div>
```

### 2. 여백 시스템
```css
/* 더 큰 여백 사용 */
--spacing-xs: 8px;   /* 기존 4px */
--spacing-sm: 12px;  /* 기존 8px */
--spacing-md: 20px;  /* 기존 16px */
--spacing-lg: 28px;  /* 기존 24px */
--spacing-xl: 36px;  /* 기존 32px */
```

### 3. 컨테이너 제약
```css
/* 더 여유로운 최대 너비 */
.container-senior {
    max-width: 32rem; /* 기존 28rem (448px) → 512px */
    margin: 0 auto;
    padding: 0 1.5rem; /* 기존 1rem */
}
```

## 🔍 상호작용 가이드라인

### 1. 로딩 상태
```html
<!-- 더 명확한 로딕 표시 -->
<div class="flex items-center justify-center py-12">
    <svg class="animate-spin w-8 h-8 text-blue-600 mr-3">...</svg>
    <span class="text-lg text-gray-700">말씀을 불러오는 중입니다...</span>
</div>
```

### 2. 에러 상태
```html
<!-- 더 친숙한 에러 메시지 -->
<div class="text-center py-12">
    <div class="w-16 h-16 bg-red-100 rounded-full mx-auto mb-4 flex items-center justify-center">
        <span class="text-2xl">⚠️</span>
    </div>
    <p class="text-lg text-gray-800 mb-4">일시적인 문제가 발생했습니다</p>
    <button class="btn-senior-primary">다시 시도하기</button>
</div>
```

### 3. 성공 피드백
```html
<!-- 명확한 성공 알림 -->
<div class="bg-green-50 border-l-4 border-green-400 p-4 rounded-r-lg">
    <div class="flex items-center">
        <span class="text-2xl mr-3">✅</span>
        <p class="text-lg text-green-800">성공적으로 저장되었습니다</p>
    </div>
</div>
```

## 🎛️ 접근성 강화

### 1. 포커스 관리
```css
/* 명확한 포커스 표시 */
.focus-senior {
    @apply focus:outline-none focus:ring-4;
    @apply focus:ring-blue-400 focus:ring-opacity-50;
}
```

### 2. 키보드 네비게이션
```html
<!-- 적절한 tabindex 설정 -->
<button tabindex="0" class="btn-senior-primary">
    기도문 찾기
</button>

<!-- 건너뛰기 링크 -->
<a href="#main-content" class="sr-only focus:not-sr-only">
    메인 콘텐츠로 바로가기
</a>
```

### 3. 화면 읽기 도구 지원
```html
<!-- 의미있는 aria-label -->
<button aria-label="감사 관련 성경 구절 보기" data-tag="감사">
    🙏 감사
</button>

<!-- 상태 정보 제공 -->
<div role="status" aria-live="polite" id="loading-message">
    말씀을 불러오는 중입니다...
</div>
```

## 📋 체크리스트

### 기본 요구사항
- [ ] 모든 텍스트가 16px 이상
- [ ] 모든 버튼이 44×44px 이상
- [ ] 색상 대비가 4.5:1 이상
- [ ] 터치 영역 간격이 8px 이상

### 고급 요구사항
- [ ] 큰 글씨 모드 토글 버튼
- [ ] 키보드로 모든 기능 접근 가능
- [ ] 화면 읽기 도구와 호환
- [ ] 로딩/에러 상태 명확히 표시

### 테스트 방법
1. **시각적 테스트**: 1.5m 거리에서 가독성 확인
2. **터치 테스트**: 큰 손가락으로도 정확한 클릭 가능한지 확인
3. **키보드 테스트**: Tab키로 모든 요소 접근 가능한지 확인
4. **스크린 리더 테스트**: 내용이 논리적 순서로 읽히는지 확인

## 🔄 점진적 개선 계획

### 1단계 (즉시 적용)
- 폰트 크기 증대 (text-sm → text-base)
- 버튼 패딩 증가 (py-2 → py-3)
- 색상 대비 개선 (gray-600 → gray-800)

### 2단계 (레이아웃 개선)
- 그리드 시스템 조정 (3×2 태그 배치)
- 여백 확대
- 터치 영역 최적화

### 3단계 (기능 추가)
- 큰 글씨 모드 토글
- 음성 피드백 고려
- 고대비 모드 지원

---

**작성일**: 2025년 9월 26일  
**적용 대상**: 주님말씀AI 웹앱 전체  
**업데이트 주기**: 사용자 피드백 반영하여 월 1회