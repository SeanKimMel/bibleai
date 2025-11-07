# Deprecated Code

이 폴더에는 더 이상 사용되지 않는 코드가 보관되어 있습니다.

## blog_posting_python/

**폐기 날짜**: 2025-11-03
**폐기 사유**: 운영 환경에서는 백오피스 Go 서버가 Gemini API를 직접 호출하여 블로그를 생성하므로, Python 스크립트는 사용되지 않음
**대체 코드**: `/workspace/bibleai/internal/gemini/client.go` - GenerateBlog 함수
**삭제 예정일**: 2025-12-03 (1개월 후)

### 포함된 파일들
- `scripts/generate_blog.py` - Gemini API로 블로그 생성 (hymn_number 추출 로직 포함)
- `scripts/evaluate_quality.py` - 품질 평가
- `scripts/prepare_data.sh` - 데이터 준비
- `scripts/run_blog_generation.sh` - 파이프라인 실행

### 참고사항
로컬 개발/테스트 목적으로만 사용 가능하며, 운영 환경에서는 사용되지 않습니다.
