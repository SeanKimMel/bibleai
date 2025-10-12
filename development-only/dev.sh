#!/bin/bash

# 주님말씀AI 웹앱 개발 모드 (자동 재시작)

echo "🔧 주님말씀AI 웹앱 개발 모드를 시작합니다..."

# air 패키지 설치 확인
if ! command -v air &> /dev/null; then
    echo "📦 air 패키지를 설치하는 중..."
    go install github.com/cosmtrek/air@latest
fi

# .air.toml 설정 파일 생성
if [ ! -f ".air.toml" ]; then
    echo "⚙️  air 설정 파일을 생성하는 중..."
    cat > .air.toml << 'EOF'
root = "."
testdata_dir = "testdata"
tmp_dir = "tmp"

[build]
  args_bin = []
  bin = "./tmp/main"
  cmd = "go build -o ./tmp/main ./cmd/server"
  delay = 1000
  exclude_dir = ["assets", "tmp", "vendor", "testdata", "web/static"]
  exclude_file = []
  exclude_regex = ["_test.go"]
  exclude_unchanged = false
  follow_symlink = false
  full_bin = ""
  include_dir = []
  include_ext = ["go", "tpl", "tmpl", "html", "sql"]
  include_file = []
  kill_delay = "0s"
  log = "build-errors.log"
  poll = false
  poll_interval = 0
  rerun = false
  rerun_delay = 500
  send_interrupt = false
  stop_on_root = false

[color]
  app = ""
  build = "yellow"
  main = "magenta"
  runner = "green"
  watcher = "cyan"

[log]
  main_only = false
  time = false

[misc]
  clean_on_exit = false

[screen]
  clear_on_rebuild = false
  keep_scroll = true
EOF
fi

# 로컬 PostgreSQL 연결 확인
echo "🐘 로컬 PostgreSQL 연결을 확인하는 중..."
if ! pg_isready -h localhost -p 5432 > /dev/null 2>&1; then
    echo "❌ 로컬 PostgreSQL 서버가 실행되지 않았습니다."
    echo "먼저 다음을 실행하세요:"
    echo "1. PostgreSQL 서비스 시작"
    echo "2. ./init-db.sh 실행 (최초 1회)"
    exit 1
fi

# .env 파일에서 DB_PASSWORD 로드
if [ -f .env ]; then
    source .env
fi

# bibleai 데이터베이스 존재 확인
if ! PGPASSWORD=${DB_PASSWORD} psql -h localhost -U bibleai -d bibleai -c "SELECT 1;" > /dev/null 2>&1; then
    echo "❌ bibleai 데이터베이스에 접근할 수 없습니다."
    echo "먼저 ./init-db.sh 를 실행하여 데이터베이스를 초기화하세요."
    exit 1
fi

echo "✅ 데이터베이스 연결 확인됨"

# Go 의존성 확인
echo "📦 Go 의존성을 확인하는 중..."
go mod tidy

echo ""
echo "🚀 개발 서버를 시작합니다 (자동 재시작 모드)..."
echo "📁 다음 파일들의 변경사항을 감지합니다:"
echo "   - .go 파일"
echo "   - .html, .tmpl, .tpl 템플릿 파일"
echo "   - .sql 파일"
echo ""
echo "📖 API 엔드포인트:"
echo "   - 메인: http://localhost:8080"
echo "   - 헬스체크: http://localhost:8080/health"
echo "   - 태그 목록: http://localhost:8080/api/tags"
echo ""
echo "🛑 개발 서버를 중지하려면 Ctrl+C 를 누르세요."
echo ""

# air로 자동 재시작 모드 실행
air