# 자동 비디오 검증 시스템 가이드

## 개요

YouTube 비디오를 **자동으로 검증**하여 임베드 가능한 비디오만 선택하는 시스템입니다.

## 핵심 기능

✅ **YouTube oEmbed API 활용**: 비디오가 실제로 임베드 가능한지 확인
✅ **순차 테스트**: 여러 비디오를 순서대로 테스트하여 첫 번째 동작하는 비디오 반환
✅ **자동 검증**: "Not Found", 저작권 차단, 계정 해지된 비디오 자동 제외

## 사용 방법

### 방법 1: 여러 비디오 ID를 일괄 테스트 (추천)

```bash
# 유튜브에서 검색한 비디오 ID들을 입력
./scripts/test_multiple_videos.sh VIDEO_ID1 VIDEO_ID2 VIDEO_ID3

# 또는 파일에서 읽기
echo "VIDEO_ID1
VIDEO_ID2
VIDEO_ID3" | ./scripts/test_multiple_videos.sh
```

#### 실제 사용 예시

1. **유튜브에서 수동 검색**
   ```
   https://www.youtube.com/results?search_query=찬송가+50장
   ```

2. **여러 영상의 비디오 ID 복사**
   - 영상 1: `https://www.youtube.com/watch?v=ABC123` → `ABC123`
   - 영상 2: `https://www.youtube.com/watch?v=DEF456` → `DEF456`
   - 영상 3: `https://www.youtube.com/watch?v=GHI789` → `GHI789`

3. **스크립트로 일괄 테스트**
   ```bash
   ./scripts/test_multiple_videos.sh ABC123 DEF456 GHI789
   ```

4. **결과 확인**
   ```
   [1] 테스트: ABC123
       상태: ❌ 사용 불가 (Not Found)

   [2] 테스트: DEF456
       상태: ✅ 사용 가능!
       제목: 찬송가 50장 - 이 몸의 소망 무엇인가
       채널: CTS기독교TV

   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   ✅ 첫 번째 동작하는 비디오: DEF456

   📋 임베드 코드:
   <div style="text-align: center; margin: 20px 0;">
     <iframe src="https://www.youtube.com/embed/DEF456" ...></iframe>
   </div>
   ```

### 방법 2: YouTube Data API v3 사용 (완전 자동화)

API 키가 있다면 검색부터 검증까지 완전 자동화가 가능합니다.

#### API 키 설정

1. **Google Cloud Console에서 API 키 생성**
   - https://console.cloud.google.com/
   - 프로젝트 생성
   - YouTube Data API v3 활성화
   - API 키 생성

2. **API 키 저장**
   ```bash
   echo 'YOUR_API_KEY_HERE' > scripts/.youtube_api_key
   ```

3. **스크립트 실행**
   ```bash
   ./scripts/search_hymn_youtube_api.sh "찬송가 50장"
   ```

#### 출력 예시

```
🔍 검색어: 찬송가 50장

📡 YouTube API 검색 중...
✅ 10 개의 비디오를 찾았습니다.

[1] 테스트: ABC123xyz
    제목: 찬송가 50장 - 이 몸의 소망 무엇인가 | CTS
    채널: CTS기독교TV
    검증: ✅ 사용 가능!

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ 동작하는 비디오를 찾았습니다!

📺 비디오 ID: ABC123xyz
📋 임베드 코드: [자동 생성]
```

## 검증 원리

### YouTube oEmbed API

```bash
curl "https://www.youtube.com/oembed?url=https://www.youtube.com/watch?v=VIDEO_ID&format=json"
```

**응답**:
- ✅ **동작**: JSON 반환 (제목, 채널, 임베드 코드)
- ❌ **차단**: `"Not Found"` 문자열 반환

### 자동 필터링되는 경우

1. ❌ 저작권 차단 (Rhino Entertainment 등)
2. ❌ 계정 해지된 영상
3. ❌ 삭제된 영상
4. ❌ 비공개/연령 제한 영상 (일부)

## 워크플로우 비교

### 기존 방식 (수동)

```
1. 유튜브 검색
2. 영상 클릭
3. 비디오 ID 복사
4. 브라우저에서 embed URL 테스트
5. 재생 안되면 다시 1번부터 반복 😰
```

### 새 방식 (자동 검증)

```
1. 유튜브 검색
2. 여러 영상의 ID 복사 (3-5개)
3. 스크립트 실행
4. 첫 번째 동작하는 비디오 자동 선택 ✅
```

### 최적 방식 (API 사용)

```
1. 스크립트 실행
2. 끝! 🎉
```

## 실전 예시

### 찬송가 305장 비디오 찾기

```bash
# 1. 유튜브에서 "찬송가 305장" 검색
# 2. 상위 5개 영상의 ID 복사:
#    - xTvauM-7hqk (CTS)
#    - D9ioyEvdggk (개인)
#    - Ks5bzvT-D6I (삭제된 계정)
#    - ABC123xyz (공식)
#    - DEF456uvw (교회)

# 3. 일괄 테스트
./scripts/test_multiple_videos.sh \
  xTvauM-7hqk \
  D9ioyEvdggk \
  Ks5bzvT-D6I \
  ABC123xyz \
  DEF456uvw

# 4. 출력:
#    [1] xTvauM-7hqk: ✅ 사용 가능!
#    → 첫 번째 동작하는 비디오 발견! 임베드 코드 생성
```

## 데이터베이스에 추가

동작하는 비디오를 찾았다면 `hymn_videos.json`에 추가:

```json
{
  "305": {
    "title": "나 같은 죄인 살리신",
    "videoId": "xTvauM-7hqk",
    "channel": "CTS기독교TV",
    "verified": true,
    "notes": "자동 검증 완료 (2025-10-07)"
  }
}
```

## 팁과 요령

### 효율적인 비디오 수집

1. **공식 채널 우선**
   ```
   찬송가 50장 CTS
   찬송가 50장 새찬송가
   찬송가 50장 CGNTV
   ```

2. **한 번에 5-10개 ID 수집**
   - 스크립트가 자동으로 첫 번째 동작하는 것 선택
   - 모두 실패해도 바로 다음 검색으로 진행 가능

3. **북마크 활용**
   ```
   https://www.youtube.com/results?search_query=찬송가+[번호]+CTS
   ```

### 자주 하는 실수

❌ **잘못된 방법**: 하나씩 테스트
```bash
./test_multiple_videos.sh VIDEO_ID1  # 실패
./test_multiple_videos.sh VIDEO_ID2  # 실패
./test_multiple_videos.sh VIDEO_ID3  # 성공
```

✅ **올바른 방법**: 한 번에 테스트
```bash
./test_multiple_videos.sh VIDEO_ID1 VIDEO_ID2 VIDEO_ID3
# 자동으로 VIDEO_ID3 반환
```

## API 할당량 관리 (API 사용 시)

- **무료 할당량**: 하루 10,000 유닛
- **검색 1회**: 100 유닛
- **하루 최대 검색**: 100회
- **찬송가 데이터베이스 구축**: 충분함 (645곡 = 645회 검색)

## 트러블슈팅

### "Not Found" 에러

→ 정상 작동입니다. 해당 비디오는 임베드 불가이므로 자동으로 다음 비디오로 넘어갑니다.

### 모든 비디오가 실패

```
❌ 모든 비디오가 사용 불가능합니다
```

→ 다른 검색어나 채널명을 추가해서 다시 시도:
```bash
# 채널명 추가
찬송가 50장 → 찬송가 50장 CTS
```

### API 에러 (API 사용 시)

```
❌ API 에러: The request cannot be completed because you have exceeded your quota.
```

→ 내일 다시 시도하거나, 수동 방식(방법 1) 사용

## 다음 단계

1. ✅ **데이터베이스 확장**: 자주 사용하는 찬송가 추가
2. ✅ **자동화**: 블로그 작성 시 스크립트 통합
3. 🔄 **정기 검증**: 주기적으로 기존 비디오 ID 재검증

## 관련 파일

- `test_multiple_videos.sh` - 여러 비디오 ID 일괄 테스트
- `search_hymn_youtube_api.sh` - YouTube API로 자동 검색 (API 키 필요)
- `hymn_videos.json` - 검증된 비디오 데이터베이스
- `get_hymn_video.sh` - 데이터베이스에서 비디오 조회
