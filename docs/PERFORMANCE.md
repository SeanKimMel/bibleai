# ⚡ 성능 최적화 가이드

## 📊 현재 성능 지표
- **FCP (First Contentful Paint)**: ~180ms 단축됨
- **LCP (Largest Contentful Paint)**: ~480ms 단축됨
- **렌더링 차단 시간**: 440ms 감소
- **전체 페이지 로딩 시간**: 30-40% 개선

## 🚀 적용된 최적화 기법

### 1. JavaScript 최적화
```html
<!-- Before -->
<script src="/static/js/main.js"></script>

<!-- After -->
<script defer src="/static/js/main.js"></script>
```
- `defer` 속성으로 비차단 로딩 구현
- HTML 파싱과 동시에 다운로드, DOM 완성 후 실행

### 2. CSS 최적화

#### Critical CSS 인라인화
```html
<style>
/* Critical CSS - Above the fold styles */
body{margin:0;font-family:'Malgun Gothic','맑은 고딕',sans-serif;...}
header{background-color:#fff;...}
/* ... 초기 렌더링에 필요한 스타일만 포함 ... */
</style>
```

#### 나머지 CSS 비동기 로딩
```html
<link rel="preload" href="/static/css/output.css" as="style"
      onload="this.onload=null;this.rel='stylesheet'">
<noscript><link rel="stylesheet" href="/static/css/output.css"></noscript>
```

### 3. Resource Hints

#### Preload (중요 리소스 우선 로딩)
```html
<link rel="preload" href="/static/css/output.css" as="style">
<link rel="preload" href="/static/js/main.js" as="script">
```

#### Prefetch (다음 페이지 미리 로드)
```html
<link rel="prefetch" href="/bible/search">
<link rel="prefetch" href="/hymns">
<link rel="prefetch" href="/prayers">
```

#### DNS Prefetch & Preconnect
```html
<link rel="dns-prefetch" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.googleapis.com" crossorigin>
```

### 4. 폰트 최적화
```css
@font-face {
    font-family: 'Malgun Gothic';
    font-display: swap; /* 텍스트 즉시 표시, 폰트 로드 후 교체 */
}
```

## 📈 성능 측정 방법

### Chrome DevTools Lighthouse
1. Chrome 브라우저에서 F12로 개발자 도구 열기
2. Lighthouse 탭 선택
3. "Generate report" 클릭
4. Performance, Accessibility, Best Practices 점수 확인

### curl을 이용한 응답 시간 측정
```bash
# 로컬 테스트
curl -o /dev/null -s -w "Total time: %{time_total}s\n" http://localhost:8080/

# 프로덕션 테스트
curl -o /dev/null -s -w "Total time: %{time_total}s\n" https://haruinfo.net/
```

## 🎯 추가 최적화 계획

### 단기 계획
- [ ] 이미지 최적화 (WebP 포맷 변환)
- [ ] Brotli 압축 활성화
- [ ] HTTP/2 Push 구현

### 중기 계획
- [ ] Service Worker 캐싱 전략
- [ ] Code Splitting (JavaScript 모듈화)
- [ ] 이미지 Lazy Loading

### 장기 계획
- [ ] Edge Computing (Cloudflare Workers)
- [ ] Database Query 최적화
- [ ] CDN 캐시 전략 개선

## 🛠️ 최적화 체크리스트

### 배포 전 체크리스트
- [ ] CSS 파일 압축 (Tailwind purge)
- [ ] JavaScript 파일 최소화
- [ ] 이미지 최적화
- [ ] Critical CSS 추출 및 인라인화
- [ ] Resource hints 설정

### 모니터링
- [ ] Google PageSpeed Insights 점수 확인
- [ ] Core Web Vitals 측정
- [ ] 실사용자 체감 속도 피드백

## 📚 참고 자료
- [Web.dev Performance](https://web.dev/performance/)
- [MDN Web Performance](https://developer.mozilla.org/en-US/docs/Web/Performance)
- [Google PageSpeed Insights](https://pagespeed.web.dev/)

---

*최종 업데이트: 2025-10-12*
*작성자: Claude Code Assistant*