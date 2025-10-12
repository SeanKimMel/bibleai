#!/usr/bin/env python3
"""
새찬송가 645장 전체를 데이터베이스에 삽입하는 스크립트
- 기존 29개 데이터의 상세 정보(가사, 작곡가 등)는 유지
- 새로운 616개는 번호와 제목만 삽입
"""

import json
import sys

def generate_insert_sql(json_file_path, output_sql_path):
    """JSON 파일에서 찬송가 데이터를 읽어 SQL INSERT 문 생성"""

    # JSON 파일 읽기
    with open(json_file_path, 'r', encoding='utf-8') as f:
        hymns = json.load(f)

    # SQL 파일 생성
    with open(output_sql_path, 'w', encoding='utf-8') as f:
        f.write("-- Migration: 새찬송가 645장 전체 삽입\n")
        f.write("-- 작성일: 2025-10-08\n")
        f.write("-- 기존 데이터: 상세 정보 유지, 제목만 업데이트\n")
        f.write("-- 신규 데이터: 번호와 제목만 삽입\n\n")

        f.write("BEGIN;\n\n")

        # 기존 데이터 개수 확인
        f.write("-- 작업 전 데이터 개수\n")
        f.write("SELECT '=== 작업 전 ===' as status, COUNT(*) as count FROM hymns;\n\n")

        # 각 찬송가에 대해 INSERT 문 생성
        for hymn in hymns:
            number = hymn['number']
            title = hymn['title_korean'].replace("'", "''")  # SQL 이스케이프

            # UPSERT: 존재하면 제목만 업데이트, 없으면 새로 삽입
            f.write(f"""INSERT INTO hymns (number, title, created_at, updated_at)
VALUES ({number}, '{title}', NOW(), NOW())
ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    updated_at = NOW();
""")

        f.write("\n-- 작업 후 데이터 개수 및 샘플\n")
        f.write("SELECT '=== 작업 후 ===' as status, COUNT(*) as count FROM hymns;\n")
        f.write("SELECT '=== 샘플 데이터 ===' as status;\n")
        f.write("SELECT number, title FROM hymns WHERE number IN (1, 100, 200, 300, 400, 500, 645) ORDER BY number;\n\n")

        f.write("COMMIT;\n\n")
        f.write("-- 최종 통계\n")
        f.write("SELECT\n")
        f.write("    COUNT(*) as total_hymns,\n")
        f.write("    COUNT(lyrics) as with_lyrics,\n")
        f.write("    COUNT(composer) as with_composer,\n")
        f.write("    COUNT(author) as with_author\n")
        f.write("FROM hymns;\n")

    print(f"✅ SQL 파일 생성 완료: {output_sql_path}")
    print(f"📊 총 {len(hymns)}개의 찬송가 INSERT 문 생성됨")

if __name__ == "__main__":
    json_file = "/workspace/bibleai/hymns_645_basic.json"
    output_sql = "/workspace/bibleai/migrations/006_insert_645_hymns.sql"

    try:
        generate_insert_sql(json_file, output_sql)
        sys.exit(0)
    except Exception as e:
        print(f"❌ 오류 발생: {e}", file=sys.stderr)
        sys.exit(1)
