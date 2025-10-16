# 찬송가 비디오 데이터베이스 가이드

## 개요

미리 검증된 YouTube 비디오 ID를 데이터베이스에 저장하여 안정적으로 사용하는 시스템입니다.

## 파일 구조

```
scripts/
├── hymn_videos.json          # 찬송가 비디오 ID 데이터베이스
├── get_hymn_video.sh          # 비디오 ID 조회 스크립트
└── HYMN_VIDEO_DATABASE_GUIDE.md  # 이 파일
```

## 사용 방법

### 1. 비디오 ID 조회

```bash
# 찬송가 번호로 조회
./scripts/get_hymn_video.sh 50

# 제목으로 검색
./scripts/get_hymn_video.sh "이 몸의 소망"
```

### 2. 출력 예시

```
✅ 찬송가 50장: 이 몸의 소망 무엇인가

📺 비디오 ID: Ks5bzvT-D6I
📡 채널: CTS기독교TV

🔗 일반 URL: https://www.youtube.com/watch?v=Ks5bzvT-D6I
🔗 임베드 URL: https://www.youtube.com/embed/Ks5bzvT-D6I

📝 임베드 코드:
<div style="text-align: center; margin: 20px 0;">
  <iframe width="560" height="315" src="https://www.youtube.com/embed/Ks5bzvT-D6I" ...></iframe>
</div>
```

## 새 찬송가 비디오 추가하기

### 단계 1: 유튜브에서 검증된 영상 찾기

1. 유튜브에서 "찬송가 123장" 검색
2. **공식 채널 우선 선택**:
   - CTS기독교TV
   - 새찬송가 공식 채널
   - CGNTV
   - 대형 교회 채널 (온누리, 사랑의교회 등)
3. 개인 업로드 영상 피하기 (저작권 문제, 계정 해지 위험)

### 단계 2: 비디오 ID 추출

URL 형식:
```
https://www.youtube.com/watch?v=ABC123xyz
                                 ^^^^^^^^^
                                 이 부분이 비디오 ID
```

### 단계 3: 임베드 가능 여부 테스트

브라우저에서 직접 열어보기:
```
https://www.youtube.com/embed/ABC123xyz
```

- ✅ 재생되면 사용 가능
- ❌ "차단되었습니다" → 다른 영상 찾기
- ❌ "계정이 해지되어" → 다른 영상 찾기

### 단계 4: hymn_videos.json에 추가

```json
{
  "123": {
    "title": "찬송가 제목",
    "videoId": "ABC123xyz",
    "channel": "CTS기독교TV",
    "verified": true,
    "notes": "공식 채널, 한글 가사 표시"
  }
}
```

## JSON 필드 설명

| 필드 | 타입 | 설명 |
|------|------|------|
| `title` | string | 찬송가 제목 |
| `videoId` | string | YouTube 비디오 ID (11자) |
| `channel` | string | 채널명 |
| `verified` | boolean | 검증 완료 여부 (임베드 테스트 완료) |
| `notes` | string | 추가 메모 (가사 표시 여부 등) |

## 주의사항

### ✅ 좋은 영상

- 공식 교회/방송 채널
- 한글 가사 표시
- 고화질
- 오래된 업로드 (안정성)

### ❌ 피해야 할 영상

- 개인 업로드 (저작권 위험)
- 해외 채널 (언어 문제)
- 최근 업로드 (안정성 미검증)
- 저작권 경고가 있는 영상

## 블로그 작성 시 활용

### Claude 프롬프트에 포함

```
찬송가 비디오 ID를 다음 명령으로 확인:
./scripts/get_hymn_video.sh [찬송가번호]

verified=true인 비디오만 사용하세요.
```

## 트러블슈팅

### 문제: "jq 명령어가 설치되어 있지 않습니다"

```bash
sudo apt-get update
sudo apt-get install jq
```

### 문제: "찬송가 정보를 찾을 수 없습니다"

→ `hymn_videos.json`에 해당 찬송가를 추가해야 합니다.

### 문제: 임베드 시 "이 동영상을 재생할 수 없습니다"

→ `verified: false`로 변경하고 다른 영상을 찾아 추가합니다.

## 데이터베이스 확장 계획

현재 4개 찬송가만 등록되어 있습니다. 자주 사용되는 찬송가를 우선적으로 추가하세요:

- [ ] 1-100장 (대표 찬송가)
- [ ] 찬양/예배 관련 (300-350)
- [ ] 위로/소망 관련 (400-450)
- [ ] 감사/기쁨 관련 (500-550)

## 예시: 새 찬송가 추가하기

```bash
# 1. 유튜브에서 검색
https://www.youtube.com/results?search_query=찬송가+305장

# 2. CTS기독교TV 영상 선택
https://www.youtube.com/watch?v=xTvauM-7hqk

# 3. 임베드 테스트
https://www.youtube.com/embed/xTvauM-7hqk  ← 브라우저에서 재생 확인

# 4. hymn_videos.json 편집
{
  "305": {
    "title": "나 같은 죄인 살리신",
    "videoId": "xTvauM-7hqk",
    "channel": "CTS기독교TV",
    "verified": true,
    "notes": "공식 채널"
  }
}

# 5. 스크립트로 확인
./scripts/get_hymn_video.sh 305
```

## 자동화 아이디어 (향후)

1. **YouTube Data API v3 활용**:
   - 채널 화이트리스트 필터링
   - 조회수 기준 정렬
   - 자동 검증

2. **크론잡으로 정기 검증**:
   - 매일 모든 비디오 ID 체크
   - 차단/삭제된 영상 자동 감지

3. **웹 인터페이스**:
   - 브라우저에서 검색 → 미리보기 → 추가
   - HTML 파일 제공 (youtube-search-embed.html 참조)
