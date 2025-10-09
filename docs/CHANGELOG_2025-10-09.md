# 변경 로그 - 2025년 10월 9일

## 📝 주요 변경사항

### 1. 블로그 시스템 구현 (URL 기반 네비게이션)

**배경:**
- 기존 모달 팝업 방식에서 URL 기반 네비게이션으로 전환
- URL 공유 기능 추가 필요
- 상대 날짜("오늘", "어제")를 절대 날짜로 변경 필요

**구현 내용:**
- ✅ 블로그 목록 페이지: `/blog`
- ✅ 블로그 상세 페이지: `/blog/:slug`
- ✅ 마크다운 → HTML 자동 변환 (blackfriday/v2)
- ✅ 조회수 자동 증가
- ✅ 키워드 태그 표시
- ✅ 페이지네이션 (10개씩)
- ✅ 날짜 포맷: "2025년 10월 9일" (절대 날짜)

**파일 변경:**
```
신규:
- web/templates/pages/blog.html
- web/templates/pages/blog_detail.html
- internal/handlers/blog.go
- migrations/003_blog_posts.sql

수정:
- cmd/server/main.go (라우팅 추가)
- internal/handlers/pages.go (BlogPage, BlogDetailPage)
- web/templates/layout/base.html (블로그 탭 추가, 6개 탭)
```

**주요 기능:**
- URL 공유 가능
- SEO 친화적인 slug 기반 URL
- 네비게이션 탭에서 블로그 접근
- 모바일/데스크탑 반응형 디자인

---

### 2. Tailwind CSS 프로덕션 최적화

**배경:**
- CDN 방식 (~3MB) 사용으로 초기 로딩 느림
- 개발자 콘솔 경고: "cdn.tailwindcss.com should not be used in production"
- 불필요한 외부 의존성

**구현 내용:**
- ✅ Tailwind CLI 설정 (package.json, tailwind.config.js)
- ✅ CSS 빌드 프로세스 구축 (input.css → output.css)
- ✅ 배포 스크립트에 CSS 빌드 단계 추가
- ✅ .gitignore에 빌드 산출물 제외

**성능 개선:**
```
파일 크기: 3MB → 56KB (98.1% 감소, 53배 작음)
로딩 속도: 대폭 향상
외부 의존성: 제거
브라우저 캐싱: 최적화
```

**배포 프로세스:**
```bash
# 1. Tailwind CSS 빌드
npm run build:css

# 2. Go 바이너리 빌드
GOOS=linux GOARCH=arm64 go build

# 3. 파일 전송 (rsync)
# 4. 서버 재시작
```

**파일 변경:**
```
신규:
- package.json
- tailwind.config.js
- web/static/css/input.css
- web/static/css/output.css (빌드 산출물)

수정:
- web/templates/layout/base.html (CDN → 로컬 CSS)
- deploy.sh (CSS 빌드 단계 추가)
- .gitignore (output.css 제외)
```

---

### 3. YouTube 임베디드 반응형 최적화

**배경:**
- 모바일에서 YouTube 영상이 화면을 벗어나 절반이 잘림
- 데스크탑/모바일 간 일관성 없는 표시

**구현 내용:**
- ✅ iframe 반응형 스타일 추가
- ✅ 16:9 비율 자동 유지 (aspect-ratio)
- ✅ 모바일 최적화 (768px 이하)
- ✅ 블로그 목록/상세 페이지 모두 적용

**CSS 스타일:**
```css
.markdown-content iframe {
    max-width: 100%;      /* 화면 넘지 않음 */
    width: 100%;          /* 가로 전체 사용 */
    height: auto;
    aspect-ratio: 16 / 9; /* 비율 유지 */
    border-radius: 0.5rem;
    margin: 1.5rem 0;
}

@media (max-width: 768px) {
    .markdown-content iframe {
        margin: 1rem 0;
    }
}
```

**사용 방법:**
```markdown
블로그 마크다운 콘텐츠에 iframe 태그만 추가:

<iframe width="560" height="315"
  src="https://www.youtube.com/embed/VIDEO_ID"
  allowfullscreen>
</iframe>

→ 자동으로 반응형으로 표시됨
```

**파일 변경:**
```
수정:
- web/templates/pages/blog_detail.html
- web/templates/pages/blog.html
```

---

## 🚀 배포 정보

**배포 일시:** 2025년 10월 9일
**배포 환경:** AWS EC2 (Amazon Linux 2023)
**프로덕션 URL:** https://haruinfo.net

**배포된 기능:**
1. ✅ 블로그 시스템 (URL 기반)
2. ✅ Tailwind CSS 최적화 (56KB)
3. ✅ YouTube 반응형

**테스트 URL:**
- 블로그 목록: https://haruinfo.net/blog
- YouTube 테스트: https://haruinfo.net/blog/test-youtube-responsive

---

## 📊 데이터베이스 스키마

### blog_posts 테이블
```sql
CREATE TABLE blog_posts (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    slug VARCHAR(255) UNIQUE NOT NULL,
    content TEXT NOT NULL,
    excerpt TEXT,
    keywords VARCHAR(500),
    is_published BOOLEAN DEFAULT false,
    published_at TIMESTAMP,
    view_count INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

---

## 🔧 기술 스택

**백엔드:**
- Go 1.x
- Gin Web Framework
- PostgreSQL 16
- Markdown: blackfriday/v2

**프론트엔드:**
- Tailwind CSS 3.4.0 (프로덕션 빌드)
- Vanilla JavaScript
- HTML Templates (Go template engine)

**인프라:**
- AWS EC2 (ARM64)
- Cloudflare (CDN, 캐싱)
- rsync (배포)

---

## 📝 다음 단계

**계획된 작업:**
1. 찬송가 데이터 완성 (645곡 중 95.5% 누락)
2. 블로그 관리자 페이지 구현
3. 이미지 업로드 기능
4. 댓글 시스템 (선택)
5. RSS 피드 생성

**진행 중:**
- 없음

**보류:**
- 찬송가 작곡가/작사가 데이터 수집 (별도 작업)

---

## 🐛 알려진 이슈

**해결됨:**
- ✅ Tailwind CDN 경고
- ✅ 블로그 HTML 태그 이스케이프 문제
- ✅ YouTube 모바일 잘림 현상

**현재 없음**

---

## 📚 참고 문서

- [블로그 생성 가이드](../BLOG_GENERATION_GUIDE.md)
- [API 문서](../API_DOCUMENTATION.md)
- [Claude 작업 메모](./CLAUDE.md)
- [로컬 테스트 가이드](./LOCAL_AWS_TESTING.md)

---

**작성자:** Claude Code
**리뷰:** 완료
**커밋:** 2025-10-09
