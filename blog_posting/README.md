# 블로그 자동 생성 워크스페이스

이 디렉토리는 **블로그 콘텐츠 생성 전용 Claude 세션**을 위한 독립적인 작업 공간입니다.

## 📁 디렉토리 구조

```
blog_posting/
├── README.md                      # 이 파일
├── QUICK_PUBLISH.md               # 🚀 빠른 발행 가이드 (키워드만 입력!)
├── BLOG_VALIDATION_GUIDE.md       # 📊 블로그 품질 검증 가이드 (NEW!)
├── API_GUIDE.md                   # API 사용 가이드
├── CLAUDE_PROMPT.md               # Claude용 프롬프트 템플릿
├── WORKFLOW.md                    # 단계별 작업 흐름
├── samples/                       # 샘플 데이터
│   ├── api_response_example.json  # API 응답 예시
│   └── blog_output_example.json   # 블로그 출력 예시
└── scripts/                       # 유틸리티 스크립트
    ├── fetch_data.sh              # 데이터 수집 스크립트
    ├── publish_blog.sh            # 블로그 발행 스크립트
    ├── auto_find_hymn_video.sh    # 찬송가 비디오 자동 검색
    ├── get_hymn_video.sh          # 찬송가 비디오 DB 조회
    ├── test_multiple_videos.sh    # 여러 비디오 ID 일괄 테스트
    ├── hymn_videos.json           # 검증된 비디오 ID 데이터베이스
    └── AUTO_VIDEO_FINDER_GUIDE.md # 자동 비디오 검증 가이드
```

---

## 🚀 빠른 시작

### ⚡ 초간단 방식 (추천!)

**개발 Claude에게 키워드만 입력:**
```
오늘 블로그 주제: 평안
```

끝! Claude가 자동으로:
- ✅ 데이터 수집
- ✅ 찬송가 번호 검증 (웹 검색)
- ✅ 찬송가 비디오 자동 검색
- ✅ 블로그 작성 및 발행

👉 **자세한 내용**: `QUICK_PUBLISH.md` 참고

---

### 📝 수동 방식 (단계별)

### 1단계: 데이터 수집
```bash
cd /workspace/bibleai/blog_posting
./scripts/fetch_data.sh 평안
```

### 2단계: 찬송가 비디오 자동 검색 (NEW! 🎉)
```bash
# 완전 자동으로 검증된 비디오 ID 찾기
./scripts/auto_find_hymn_video.sh "찬송가 200장 주 품에 품으소서"

# 출력된 비디오 ID 메모 (예: XP8WsSZAx1o)
```

### 3단계: Claude에게 요청
1. `CLAUDE_PROMPT.md` 파일 열기
2. 프롬프트 복사
3. 수집된 데이터 (`data.json`) 내용 붙여넣기
4. Claude가 블로그 JSON 생성 (비디오 ID 자동 포함)

### 4단계: 블로그 발행
```bash
./scripts/publish_blog.sh output.json
```

---

## 📚 문서

- **API_GUIDE.md**: 사용 가능한 모든 API 설명
- **CLAUDE_PROMPT.md**: Claude에게 전달할 프롬프트 템플릿
- **WORKFLOW.md**: 전체 작업 프로세스 설명
- **AUTO_VIDEO_FINDER_GUIDE.md**: 자동 비디오 검증 시스템 가이드 (NEW!)

---

## 🎥 자동 비디오 검증 시스템 (NEW!)

**문제점**: 수동으로 찾은 YouTube 비디오가 저작권 차단/계정 해지로 임베드 불가

**해결책**: yt-dlp + oEmbed API를 활용한 완전 자동 검증 시스템

### 주요 기능

✅ **YouTube 자동 검색**: yt-dlp로 검색 결과 추출
✅ **실시간 검증**: oEmbed API로 임베드 가능 여부 확인
✅ **순차 테스트**: 동작할 때까지 자동으로 다음 비디오 시도
✅ **데이터베이스**: 검증된 비디오 ID 자동 저장 및 재사용

### 사용 예시

```bash
# 완전 자동으로 검증된 비디오 찾기
./scripts/auto_find_hymn_video.sh "찬송가 200장 주 품에 품으소서"

# 출력:
# ✅ 동작하는 비디오를 찾았습니다!
# 📺 비디오 ID: XP8WsSZAx1o
# 📋 임베드 코드: [자동 생성]
```

자세한 내용은 `scripts/AUTO_VIDEO_FINDER_GUIDE.md` 참조

---

## 💡 사용 팁

1. **랜덤 모드 활용**: 같은 키워드라도 다양한 콘텐츠 생성
2. **시리즈물 작성**: 날짜만 다르게 하여 시리즈 구성
3. **품질 검토**: 발행 전 성경 구절과 신학 내용 확인
4. **비디오 자동화**: auto_find_hymn_video.sh로 검증된 비디오만 사용 (NEW!)

---

## ⚠️ 주의사항

- 이 디렉토리는 **콘텐츠 생성 전용**입니다
- 서버 코드 수정은 상위 디렉토리에서 진행하세요
- `.gitignore`에 `data.json`, `output.json` 추가됨 (개인 작업물)
