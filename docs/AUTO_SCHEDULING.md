# 블로그 자동 발행 스케줄링 가이드

## 개요

랜덤 키워드를 사용한 블로그 자동 생성 API(`/api/blogs/generate`)를 정기적으로 호출하여 자동 발행 시스템을 구축하는 방법입니다.

## API 파라미터

### `/api/blogs/generate` POST 요청

```json
{
  "keyword": "",           // 비어있으면 랜덤 키워드 선택
  "date": "2025-10-19",   // 블로그 작성 날짜
  "auto_publish": true    // (선택) true이면 평가 무시하고 무조건 발행
}
```

**발행 방식**:
- `auto_publish` 미지정 또는 `false`: 품질 평가 점수 기반 자동 발행 (총점 ≥7.0)
- `auto_publish: true`: 평가 점수 무시하고 **무조건 발행** (품질이 낮아도 발행됨)

**권장 사용**:
- 일반적인 경우: `auto_publish` 미지정 (품질 관리)
- 테스트 또는 긴급 발행: `auto_publish: true`

## 방법 1: Linux Cron (권장)

### 설정 방법

1. **스크립트 파일 생성**

```bash
# /home/ec2-user/bibleai/scripts/auto_blog_generate.sh
#!/bin/bash

# 백오피스 API 호출 (백오피스가 .env를 이미 읽고 있으므로 별도 로드 불필요)
TODAY=$(date +%Y-%m-%d)

# 방법 1: 품질 평가 기반 자동 발행 (권장)
curl -X POST http://localhost:9090/api/blogs/generate \
  -H "Content-Type: application/json" \
  -d "{\"keyword\": \"\", \"date\": \"$TODAY\"}" \
  >> /home/ec2-user/bibleai/logs/auto_blog_$(date +%Y%m).log 2>&1

# 방법 2: 강제 발행 (품질 무시, 테스트용)
# curl -X POST http://localhost:9090/api/blogs/generate \
#   -H "Content-Type: application/json" \
#   -d "{\"keyword\": \"\", \"date\": \"$TODAY\", \"auto_publish\": true}" \
#   >> /home/ec2-user/bibleai/logs/auto_blog_$(date +%Y%m).log 2>&1

echo "$(date): 블로그 자동 생성 완료" >> /home/ec2-user/bibleai/logs/auto_blog_$(date +%Y%m).log
```

2. **실행 권한 부여**

```bash
chmod +x /home/ec2-user/bibleai/scripts/auto_blog_generate.sh
```

3. **Cron 설정**

```bash
crontab -e
```

다음 내용 추가:

```cron
# 매일 오전 6시에 블로그 자동 생성
0 6 * * * /home/ec2-user/bibleai/scripts/auto_blog_generate.sh

# 매일 오전 6시, 정오 12시, 저녁 6시에 블로그 생성 (하루 3회)
0 6,12,18 * * * /home/ec2-user/bibleai/scripts/auto_blog_generate.sh

# 평일(월~금) 오전 9시에만 생성
0 9 * * 1-5 /home/ec2-user/bibleai/scripts/auto_blog_generate.sh
```

4. **Cron 확인**

```bash
# Cron 목록 확인
crontab -l

# Cron 로그 확인
tail -f /home/ec2-user/bibleai/logs/auto_blog_$(date +%Y%m).log
```

### Cron 스케줄 예시

| 패턴 | 설명 |
|------|------|
| `0 6 * * *` | 매일 오전 6시 |
| `0 */6 * * *` | 6시간마다 (0시, 6시, 12시, 18시) |
| `0 9,12,15,18 * * *` | 오전 9시, 정오, 오후 3시, 6시 |
| `0 9 * * 1-5` | 평일 오전 9시 |
| `0 8 * * 0` | 매주 일요일 오전 8시 |

## 방법 2: systemd Timer (고급)

systemd timer를 사용하면 더 정교한 스케줄링이 가능합니다.

### 설정 방법

1. **Service 파일 생성**

```bash
sudo vi /etc/systemd/system/bibleai-autoblog.service
```

```ini
[Unit]
Description=BibleAI Auto Blog Generation
After=network.target

[Service]
Type=oneshot
User=ec2-user
WorkingDirectory=/home/ec2-user/bibleai
ExecStart=/home/ec2-user/bibleai/scripts/auto_blog_generate.sh
StandardOutput=append:/home/ec2-user/bibleai/logs/auto_blog.log
StandardError=append:/home/ec2-user/bibleai/logs/auto_blog_error.log
```

2. **Timer 파일 생성**

```bash
sudo vi /etc/systemd/system/bibleai-autoblog.timer
```

```ini
[Unit]
Description=BibleAI Auto Blog Generation Timer
Requires=bibleai-autoblog.service

[Timer]
# 매일 오전 6시에 실행
OnCalendar=*-*-* 06:00:00
Persistent=true

[Install]
WantedBy=timers.target
```

3. **Timer 활성화**

```bash
# Timer 활성화
sudo systemctl enable bibleai-autoblog.timer
sudo systemctl start bibleai-autoblog.timer

# 상태 확인
sudo systemctl status bibleai-autoblog.timer
sudo systemctl list-timers bibleai-autoblog.timer
```

### systemd Timer 스케줄 예시

```ini
# 매일 오전 6시
OnCalendar=*-*-* 06:00:00

# 6시간마다
OnCalendar=*-*-* 00/6:00:00

# 평일 오전 9시
OnCalendar=Mon-Fri *-*-* 09:00:00

# 매주 일요일 오전 8시
OnCalendar=Sun *-*-* 08:00:00
```

## 방법 3: Go 기반 자체 스케줄러 (선택)

백오피스 애플리케이션에 직접 스케줄러를 내장하는 방법입니다.

### 구현 예시

```go
// cmd/backoffice/main.go에 추가
import (
    "github.com/robfig/cron/v3"
)

func startAutoScheduler(handlers *backoffice.Handlers) {
    c := cron.New()

    // 매일 오전 6시에 블로그 자동 생성
    c.AddFunc("0 6 * * *", func() {
        ctx := context.Background()

        // 랜덤 키워드로 블로그 생성
        today := time.Now().Format("2006-01-02")
        blog, err := gemini.GenerateBlog(ctx, "", today)
        if err != nil {
            log.Printf("자동 블로그 생성 실패: %v", err)
            return
        }

        log.Printf("자동 블로그 생성 완료: %s", blog.Title)
    })

    c.Start()
    log.Println("📅 자동 스케줄러 시작: 매일 오전 6시 블로그 생성")
}
```

### 장단점

**장점**:
- 애플리케이션 자체에 스케줄러 내장
- Go 코드로 복잡한 로직 구현 가능
- 별도의 Cron 설정 불필요

**단점**:
- 백오피스 애플리케이션이 항상 실행 중이어야 함
- 재시작 시 스케줄 초기화

## 로그 관리

### 로그 디렉토리 생성

```bash
mkdir -p /home/ec2-user/bibleai/logs
```

### 로그 로테이션 설정

```bash
sudo vi /etc/logrotate.d/bibleai-autoblog
```

```
/home/ec2-user/bibleai/logs/auto_blog_*.log {
    monthly
    rotate 12
    compress
    delaycompress
    missingok
    notifempty
}
```

## 모니터링

### 자동 생성 결과 확인

```bash
# 로그 확인
tail -f /home/ec2-user/bibleai/logs/auto_blog_$(date +%Y%m).log

# 최근 생성된 블로그 확인 (PostgreSQL)
psql -U bibleai -d bibleai -c "SELECT id, title, created_at, is_published FROM blogs ORDER BY created_at DESC LIMIT 5;"

# Cron 실행 확인
grep CRON /var/log/syslog | tail -20
```

### 알림 설정 (선택)

실패 시 이메일 알림을 받으려면:

```bash
# 스크립트에 이메일 알림 추가
if [ $? -ne 0 ]; then
    echo "블로그 생성 실패: $(date)" | mail -s "BibleAI 자동 블로그 생성 실패" admin@example.com
fi
```

## 권장 사항

### 프로덕션 환경

1. **Cron 사용 (권장)**
   - 간단하고 안정적
   - 시스템 재시작 시에도 동작
   - 로그 관리 용이

2. **스케줄 추천**
   - 하루 1회: 오전 6시 또는 새벽 2시 (트래픽 적은 시간)
   - 하루 2회: 오전 6시, 저녁 6시
   - 평일만: 월~금 오전 9시

3. **에러 핸들링**
   - 로그 파일에 모든 출력 기록
   - 실패 시 알림 설정
   - 월별 로그 로테이션

### 개발/테스트 환경

- 짧은 주기로 테스트 (예: 5분마다)
- 로그 상세 출력
- 수동 실행으로 먼저 확인

```bash
# 테스트용 Cron (5분마다)
*/5 * * * * /home/ec2-user/bibleai/scripts/auto_blog_generate.sh
```

## 문제 해결

### Cron이 실행되지 않을 때

```bash
# Cron 서비스 상태 확인
sudo systemctl status cron

# Cron 재시작
sudo systemctl restart cron

# 스크립트 권한 확인
chmod +x /home/ec2-user/bibleai/scripts/auto_blog_generate.sh
```

### API 호출 실패

```bash
# 백오피스가 실행 중인지 확인
curl http://localhost:9090/health

# 백오피스 재시작
pkill -f backoffice
./start_backoffice.sh
```

### 로그 파일 권한 문제

```bash
# 로그 디렉토리 권한 설정
chown -R ec2-user:ec2-user /home/ec2-user/bibleai/logs
chmod 755 /home/ec2-user/bibleai/logs
```

## 참고

- 백오피스 API: `/api/blogs/generate`
- 키워드를 비워두면 keywords 테이블에서 랜덤 선택
- 품질 평가 통과 시 자동 발행 (`is_published=true`)
- 실패 시 로그에서 원인 확인 가능
