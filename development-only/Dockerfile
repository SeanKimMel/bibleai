# Go 빌드 스테이지
FROM golang:1.23-alpine AS builder

# 작업 디렉토리 설정
WORKDIR /app

# 의존성 파일들 복사
COPY go.mod go.sum ./
RUN go mod download

# 소스 코드 복사
COPY . .

# 바이너리 빌드
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o main ./cmd/server

# 실행 스테이지
FROM alpine:latest

# 필요한 패키지 설치
RUN apk --no-cache add ca-certificates tzdata

# 작업 디렉토리 설정
WORKDIR /root/

# 빌드된 바이너리 복사
COPY --from=builder /app/main .

# 정적 파일들 복사
COPY --from=builder /app/web ./web

# 포트 노출
EXPOSE 8080

# 실행
CMD ["./main"]