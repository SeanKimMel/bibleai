# 작업 일지 - 2025년 10월 7일

## 📋 작업 개요

블로그 자동 생성 시스템 구축 및 배포 프로세스 개선

---

## 🎯 주요 작업 내용

### 1. 블로그 생성용 API 구현

#### 1.1 데이터 수집 API 생성
**파일**: `internal/handlers/blog.go`

**새 엔드포인트**: `GET /api/admin/blog/generate-data`

**기능**:
- 키워드 기반으로 성경 챕터, 기도문, 찬송가 데이터 수집
- 랜덤 모드 지원으로 같은 키워드에서도 다양한 콘텐츠 생성 가능

**파라미터**:
- `keyword` (필수): 검색 키워드
- `random` (선택): `true` 설정 시 랜덤 데이터 반환

**랜덤 모드 구현**:
```go
// 성경: 연관도 상위 10개 중 랜덤 선택
if randomMode {
    // 상위 10개 챕터 조회 후 랜덤 선택
    candidates := // ... 상위 10개
    selected := candidates[rand.Intn(len(candidates))]
}

// 찬송가: RANDOM() 정렬로 1개 선택
ORDER BY RANDOM() LIMIT 1
```

**응답 형식**:
```json
{
  "keyword": "평안",
  "random_mode": true,
  "data": {
    "bible": { /* 챕터 정보 + 전체 구절 */ },
    "prayers": [ /* 관련 기도문 */ ],
    "hymns": [ /* 찬송가 1개 */ ]
  },
  "summary": {
    "has_bible": true,
    "has_prayer": false,
    "has_hymn": true
  }
}
```

#### 1.2 찬송가 개수 변경
- **변경 전**: 3개
- **변경 후**: 1개 (LIMIT 1)
- **이유**: 블로그 콘텐츠 집중도 향상 및 유튜브 임베드 추가

---

### 2. 블로그 발행 워크스페이스 구축

**목적**: 개발 환경과 블로그 생성 환경 분리

#### 2.1 디렉토리 구조
```
blog_posting/
├── README.md              # 시작 가이드
├── API_GUIDE.md          # API 사용법
├── CLAUDE_PROMPT.md      # Claude 프롬프트 템플릿
├── WORKFLOW.md           # 단계별 워크플로우
├── .gitignore            # 임시 파일 제외
├── samples/              # 샘플 데이터
│   ├── api_response_example.json
│   └── blog_output_example.json
└── scripts/              # 유틸리티 스크립트
    ├── fetch_data.sh     # 데이터 수집
    └── publish_blog.sh   # 블로그 발행
```

#### 2.2 작성한 문서

**README.md**:
- 빠른 시작 가이드 (3단계)
- 디렉토리 구조 설명
- 사용 팁 및 주의사항

**API_GUIDE.md**:
- 데이터 수집 API 상세 설명
- 블로그 발행 API 문서
- 추천 키워드 목록
- 랜덤 모드 vs 일반 모드 비교표

**CLAUDE_PROMPT.md**:
- 블로그 작성을 위한 완전한 프롬프트 템플릿
- 구조 요구사항 (7단계)
- 작성 스타일 가이드
- JSON 출력 형식 및 예시
- 체크리스트

**주요 업데이트**:
- 찬송가 1개만 사용
- 찬송가 전체 가사 링크 추가
- 유튜브 iframe 임베드 추가
- 예시 코드 포함

**WORKFLOW.md**:
- 6단계 상세 워크플로우
- 각 단계별 명령어 및 확인사항
- 문제 해결 섹션
- 빠른 가이드 (숙련자용)

#### 2.3 유틸리티 스크립트

**fetch_data.sh**:
```bash
./scripts/fetch_data.sh 감사
# → data.json 생성 + 요약 출력
```

**기능**:
- API 호출 및 JSON 저장
- 데이터 요약 자동 출력 (has_bible, has_hymn, 챕터 정보 등)
- 에러 처리

**publish_blog.sh**:
```bash
./scripts/publish_blog.sh output.json
# → 블로그 발행 + 결과 확인
```

**기능**:
- JSON 형식 검증
- 필수 필드 확인
- API 호출 및 결과 출력
- 성공 시 블로그 ID 및 URL 표시

---

### 3. 프론트엔드 개선

#### 3.1 블로그 페이지 팝업 기능 추가
**파일**: `web/templates/pages/blog.html`

**기능**: 찬송가 링크를 팝업으로 열기

**구현**:
```javascript
// hymnkorea.org 링크만 선택적으로 팝업
modalContent.querySelectorAll('a[href*="hymnkorea.org"]').forEach(link => {
    link.addEventListener('click', (e) => {
        e.preventDefault();
        const width = 900;
        const height = 700;
        const left = (screen.width - width) / 2;
        const top = (screen.height - height) / 2;
        window.open(url, 'hymn', `width=${width},height=${height}...`);
    });
});
```

**특징**:
- 팝업 크기: 900x700
- 중앙 정렬
- 스크롤 가능, 크기 조절 가능

---

### 4. 배포 프로세스 개선

#### 4.1 문제 발견
**증상**: EC2에서 `robots.txt` 404 에러

**원인 분석**:
- **서버 코드**: `web/static/robots.txt` 경로 기대
- **실제 EC2**: `static/robots.txt` 경로에 파일 존재
- **rsync 동작**: `web/`의 **내용물**만 복사하여 경로 불일치 발생

**확인 과정**:
```bash
# 로컬
/workspace/bibleai/web/static/robots.txt  ✅

# EC2 (배포 전)
/home/ec2-user/bibleai/static/robots.txt  ❌ (경로 불일치)
/home/ec2-user/bibleai/web/static/robots.txt  ❌ (파일 없음)
```

#### 4.2 deploy.sh 수정

**변경 전**:
```bash
rsync -avz ... \
  bibleai \
  web/ \
  ${SERVER_HOST}:${SERVER_PATH}/
# → web/의 내용물이 루트로 복사됨
```

**변경 후**:
```bash
# 바이너리 전송
rsync -avz ... \
  bibleai \
  ${SERVER_HOST}:${SERVER_PATH}/

# web 디렉토리 전송 (구조 유지)
rsync -avz --delete ... \
  web/ \
  ${SERVER_HOST}:${SERVER_PATH}/web/
```

**개선사항**:
1. **경로 수정**: `web/` → `web/web/`로 전송하여 구조 유지
2. **--delete 추가**: 로컬에 없는 파일 자동 삭제 (완전 동기화)
3. **안전장치**: `--exclude`로 중요 파일 보호 (*.log, .git 등)

#### 4.3 배포 결과
```bash
# EC2 (배포 후)
/home/ec2-user/bibleai/web/static/robots.txt  ✅

# 내용 확인
# 주님말씀AI - Robots.txt
# Google, Naver 검색엔진 최적화
User-agent: *
Allow: /
```

**검증**:
- ✅ 로컬 서버 (localhost:8080): 정상
- ✅ 실제 사이트 (haruinfo.net): 정상 (Cloudflare 자동 갱신)

---

## 📊 영향 분석

### 긍정적 영향

1. **블로그 생성 효율성 향상**:
   - API를 통한 자동 데이터 수집
   - 랜덤 모드로 콘텐츠 다양성 확보
   - 별도 Claude 세션 사용으로 환경 분리

2. **사용자 경험 개선**:
   - 찬송가 전체 가사 팝업으로 편리한 열람
   - 유튜브 임베드로 바로 듣기 가능
   - 블로그 콘텐츠 집중도 향상 (찬송가 1개)

3. **배포 안정성 향상**:
   - 경로 불일치 문제 해결
   - --delete로 완전 동기화
   - 자동화된 스크립트로 인적 오류 감소

### 주의사항

1. **--delete 옵션**:
   - 로컬에서 파일 삭제 시 EC2에서도 삭제됨
   - --exclude로 보호된 파일 외에는 주의 필요

2. **Cloudflare 캐시**:
   - 배포 후 1-2분 대기 또는 수동 퍼지 필요
   - 특히 정적 파일 (robots.txt, sitemap.xml 등)

---

## 🔧 기술 스택

- **백엔드**: Go, Gin, PostgreSQL
- **프론트엔드**: HTML, JavaScript (Vanilla), Tailwind CSS
- **배포**: rsync, SSH, EC2 (ARM64)
- **CDN**: Cloudflare Proxy (Flexible SSL)
- **AI**: Claude (블로그 콘텐츠 생성)

---

## 📝 사용 예시

### 블로그 생성 전체 흐름

```bash
# 1. 데이터 수집
cd /workspace/bibleai/blog_posting
./scripts/fetch_data.sh 평안

# 2. Claude 세션에서 블로그 작성
# - CLAUDE_PROMPT.md 내용 복사
# - data.json 내용 붙여넣기
# - 생성된 JSON을 output.json으로 저장

# 3. 블로그 발행
./scripts/publish_blog.sh output.json

# 4. 확인
curl "http://localhost:8080/api/blog/posts?page=1&limit=1" | jq '.posts[0]'
```

**실제 생성된 블로그**:
- ID: 4 - "진정한 평안을 찾아서" (2025-10-10)
- ID: 5 - "온 피조물이 함께 드리는 찬양" (2025-10-07)
- ID: 6 - "진정한 평안을 찾아서" (2025-10-11) - 샘플 테스트

---

## 🚀 다음 단계 제안

1. **자동화 개선**:
   - GitHub Actions로 정기 블로그 발행
   - 배포 후 Cloudflare 캐시 자동 퍼지

2. **콘텐츠 품질**:
   - view_count 기반 인기 주제 분석
   - 키워드 조합으로 시리즈물 구성

3. **모니터링**:
   - 블로그 조회수 추적
   - SEO 성과 측정 (Google Search Console)

4. **기능 확장**:
   - 댓글 시스템
   - 블로그 카테고리/태그
   - RSS 피드

---

## 📚 참고 문서

- `blog_posting/README.md` - 블로그 발행 시작 가이드
- `blog_posting/WORKFLOW.md` - 상세 워크플로우
- `blog_posting/API_GUIDE.md` - API 문서
- `blog_posting/CLAUDE_PROMPT.md` - Claude 프롬프트 템플릿
- `API_DOCUMENTATION.md` - 전체 API 레퍼런스

---

## ✅ 검증 완료 항목

- [x] 데이터 수집 API 동작 확인
- [x] 랜덤 모드 테스트 (서로 다른 결과 확인)
- [x] 블로그 발행 API 테스트
- [x] 팝업 기능 동작 확인
- [x] 배포 스크립트 테스트
- [x] EC2 파일 경로 확인
- [x] 실제 사이트 robots.txt 확인
- [x] 유틸리티 스크립트 실행 테스트

---

**작성일**: 2025년 10월 7일
**작성자**: Claude Code
**소요 시간**: 약 2시간
**커밋 수**: 다수 (주요 파일 변경)
