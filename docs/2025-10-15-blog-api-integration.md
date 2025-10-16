# 블로그 자동 생성 시스템 API 통합 및 개선

**날짜**: 2025-10-15
**작업자**: Claude
**관련 이슈**: 블로그 자동 생성 시스템 안정화

## 📋 작업 요약

블로그 자동 생성 시스템을 API 기반으로 전환하고, 서버 상태 확인 및 YouTube 임베딩 기능을 개선했습니다.

## 🔧 주요 변경사항

### 1. API 기반 데이터 조회로 전환

**변경 전**: PostgreSQL 직접 접근
```bash
# prepare_data.sh에서 psql 직접 실행
psql -h localhost -U bibleai -d bibleai -c "SELECT ..."
```

**변경 후**: REST API 사용
```bash
# /api/admin/blog/generate-data?keyword={keyword}&random=true
curl "http://localhost:8080/api/admin/blog/generate-data?keyword=평안&random=true"
```

**장점**:
- ✅ 데이터베이스 접속 정보 노출 방지
- ✅ API 로직 변경 시 자동 반영
- ✅ 일관된 데이터 접근 방식
- ✅ 서버 레이어의 비즈니스 로직 재사용

**영향 파일**:
- `blog_posting/scripts/prepare_data.sh` - 전체 재작성

### 2. 서버 실행 여부 확인 추가

블로그 생성 파이프라인 시작 전에 서버 상태를 확인하는 로직 추가:

```bash
# run_blog_generation.sh
echo "🔍 서버 연결 확인 중..."
if ! curl -s -f http://localhost:8080/health > /dev/null 2>&1; then
    echo "❌ 서버가 실행되지 않았거나 응답하지 않습니다."
    echo ""
    echo "서버를 먼저 실행해주세요:"
    echo "  cd /workspace/bibleai"
    echo "  go run cmd/server/main.go"
    exit 1
fi
echo "✅ 서버 연결 확인 완료"
```

**효과**:
- 서버 미실행 상태에서 즉시 종료
- 명확한 안내 메시지 제공
- 불필요한 API 호출 방지

**영향 파일**:
- `blog_posting/scripts/run_blog_generation.sh` - 서버 확인 로직 추가

### 3. YouTube 임베딩 패턴 수정

**문제**: 유튜브 링크 찾기 실패

```
로그: ✅ 비디오 ID: 9xjIJ9CU9UM
로그: ⚠️  유튜브 링크를 찾을 수 없습니다
```

**원인**: 정규표현식 패턴 불일치

```python
# 기존 패턴 (끝에 ** 필수)
youtube_link_pattern = r'(\*\*🎵\s+\[유튜브로.*?\]\(.*?\)\*\*)'

# 실제 생성된 콘텐츠
**🎵 [유튜브로 듣기](...)\n  # 끝에 ** 없음
```

**해결**: 옵셔널 패턴 적용

```python
# 수정된 패턴 (끝에 ** 있어도 되고 없어도 됨)
youtube_link_pattern = r'(\*\*🎵\s+\[유튜브로.*?\]\(.*?\)(?:\*\*)?)'
```

**결과**:
```html
<div style="text-align: center; margin: 20px 0;">
  <iframe width="560" height="315"
          src="https://www.youtube.com/embed/VZdMLgChd-8"
          frameborder="0"
          allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
          allowfullscreen>
  </iframe>
</div>
```

**영향 파일**:
- `blog_posting/scripts/generate_blog.py` - 정규표현식 수정

### 4. 스케줄러 가이드 문서화

매일 자동으로 블로그를 생성하는 방법을 README에 추가:

#### cron 방식
```bash
# 매일 오전 6시 실행
0 6 * * * /workspace/bibleai/blog_posting/scripts/daily_blog.sh
```

#### systemd 타이머 방식 (권장)
```ini
# /etc/systemd/system/bibleai-blog.timer
[Timer]
OnCalendar=daily
OnCalendar=06:00
Persistent=true
```

**추가 기능**:
- 키워드 목록에서 랜덤 선택
- 로그 파일 자동 생성
- 실행 시간 및 완료 시간 기록

**영향 파일**:
- `blog_posting/README.md` - 스케줄러 섹션 추가
- `blog_posting/scripts/daily_blog.sh` - 신규 생성 (문서화만, 실제 파일 미생성)

## 📊 테스트 결과

### 테스트 1: 소망 키워드
```bash
$ ./run_blog_generation.sh 소망

✅ 서버 연결 확인 완료
✅ 데이터 준비 성공
  성경: ps 71장 (24절)
  찬송가: 0개
  기도문: 0개
✅ 블로그 생성 완료
  🎵 찬송가 363장 유튜브 검색 중...
     ✅ 비디오 ID: 9xjIJ9CU9UM
     ⚠️  유튜브 링크를 찾을 수 없습니다  # 패턴 문제
✅ 품질 평가 통과 (8.9/10.0)
✅ 데이터베이스 저장 완료 (ID: 70)
```

### 테스트 2: 믿음 키워드 (패턴 수정 후)
```bash
$ ./run_blog_generation.sh 믿음

✅ 서버 연결 확인 완료
✅ 데이터 준비 성공
  성경: rm 3장 (31절)
  찬송가: 0개
  기도문: 0개
✅ 블로그 생성 완료
  🎵 찬송가 384장 유튜브 검색 중...
     ✅ 비디오 ID: VZdMLgChd-8
     ✅ iframe 임베딩 추가 완료  # 수정 후 성공!
✅ 품질 평가 통과 (8.5/10.0)
✅ 데이터베이스 저장 완료 (ID: 71)
```

## 📁 변경된 파일 목록

```
blog_posting/
├── README.md                      # 수정: 워크플로우, 환경변수, 스케줄러 가이드
└── scripts/
    ├── prepare_data.sh            # 수정: API 기반으로 전체 재작성
    ├── run_blog_generation.sh     # 수정: 서버 확인 로직 추가
    └── generate_blog.py           # 수정: YouTube 임베딩 패턴 수정
```

## 🎯 개선 효과

### 1. 보안 강화
- 데이터베이스 접속 정보 노출 제거
- `.env` 파일에 DB 설정 불필요

### 2. 유지보수성 향상
- API 로직 변경 시 스크립트 수정 불필요
- 일관된 데이터 접근 방식

### 3. 안정성 향상
- 서버 미실행 상태 조기 감지
- 명확한 에러 메시지 제공

### 4. 사용자 경험 개선
- YouTube 임베딩 정상 작동
- 블로그 페이지에서 찬송가 직접 재생 가능

## 🚀 다음 단계

### 즉시 가능
- [ ] `daily_blog.sh` 스크립트 실제 생성
- [ ] `keywords.txt` 파일 작성
- [ ] cron 또는 systemd 타이머 설정

### 추가 개선 사항
- [ ] 실패 시 이메일/슬랙 알림
- [ ] 통계 대시보드 (생성 횟수, 평균 품질 점수 등)
- [ ] 다중 키워드 동시 생성 지원
- [ ] API 할당량 모니터링

## 📚 관련 문서

- [블로그 자동 생성 README](../blog_posting/README.md)
- [Gemini API 체크리스트](../blog_posting/GEMINI_API_CHECKLIST.md)
- [블로그 생성 프롬프트](../blog_posting/prompts/blog_generation.txt)

## 💡 학습 내용

### API 설계의 중요성
- 데이터 접근을 API로 통일하면 유지보수성이 크게 향상됨
- `/api/admin/blog/generate-data` API가 이미 존재했기에 쉽게 전환 가능

### 정규표현식 패턴 매칭
- 실제 생성된 콘텐츠 형식을 정확히 파악해야 함
- 옵셔널 패턴 `(?:...)?` 활용으로 유연성 확보

### 자동화 시스템 설계
- 사전 조건(서버 실행) 확인의 중요성
- 명확한 에러 메시지로 사용자 가이드

---

**작업 완료**: 2025-10-15
