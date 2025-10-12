#!/usr/bin/env python3
"""
찬송가 작곡가/작사가 정보 업데이트 SQL 생성 스크립트
"""

import json
import sys

def generate_update_sql(json_file_path, output_sql_path):
    """JSON 파일에서 찬송가 작곡가/작사가 정보를 읽어 SQL UPDATE 문 생성"""

    # JSON 파일 읽기
    with open(json_file_path, 'r', encoding='utf-8') as f:
        hymns = json.load(f)

    # SQL 파일 생성
    with open(output_sql_path, 'w', encoding='utf-8') as f:
        f.write("-- Migration: 찬송가 작곡가/작사가 정보 업데이트\n")
        f.write("-- 작성일: 2025-10-08\n")
        f.write("-- 목적: 29개 찬송가의 정확한 작곡가/작사가 정보로 업데이트\n\n")

        f.write("BEGIN;\n\n")

        # 업데이트 전 현황 확인
        f.write("-- 업데이트 전 현황\n")
        f.write("SELECT '=== 업데이트 전 ===' as status;\n")
        f.write("SELECT number, title, composer, author FROM hymns WHERE number IN (")
        f.write(",".join(str(h['number']) for h in hymns))
        f.write(") ORDER BY number;\n\n")

        # 각 찬송가에 대해 UPDATE 문 생성
        f.write("-- 작곡가/작사가 정보 업데이트\n")
        for hymn in hymns:
            number = hymn['number']
            composer = hymn['composer'].replace("'", "''")  # SQL 이스케이프
            author = hymn['author'].replace("'", "''")  # SQL 이스케이프

            f.write(f"UPDATE hymns SET \n")
            f.write(f"    composer = '{composer}',\n")
            f.write(f"    author = '{author}',\n")
            f.write(f"    updated_at = NOW()\n")
            f.write(f"WHERE number = {number};\n\n")

        # 업데이트 후 확인
        f.write("-- 업데이트 후 확인\n")
        f.write("SELECT '=== 업데이트 후 ===' as status;\n")
        f.write("SELECT number, title, composer, author FROM hymns WHERE number IN (")
        f.write(",".join(str(h['number']) for h in hymns))
        f.write(") ORDER BY number;\n\n")

        f.write("COMMIT;\n\n")

        # 통계
        f.write("-- 최종 통계\n")
        f.write("SELECT '=== 통계 ===' as status, COUNT(*) as updated_count FROM hymns WHERE number IN (")
        f.write(",".join(str(h['number']) for h in hymns))
        f.write(");\n")

    print(f"✅ SQL 파일 생성 완료: {output_sql_path}")
    print(f"📊 총 {len(hymns)}개의 찬송가 UPDATE 문 생성됨")

if __name__ == "__main__":
    json_file = "/tmp/hymns_composer_author.json"
    output_sql = "/workspace/bibleai/migrations/007_update_hymns_composers.sql"

    try:
        generate_update_sql(json_file, output_sql)
        sys.exit(0)
    except Exception as e:
        print(f"❌ 오류 발생: {e}", file=sys.stderr)
        sys.exit(1)
