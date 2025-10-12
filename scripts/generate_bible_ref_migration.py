#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
수집한 성경구절 데이터를 SQL 마이그레이션 파일로 변환
"""

import json

def main():
    # JSON 파일 읽기
    with open('/workspace/bibleai/hymn_bible_references.json', 'r', encoding='utf-8') as f:
        data = json.load(f)

    # SQL 파일 생성
    output_file = '/workspace/bibleai/migrations/008_update_hymn_bible_references.sql'

    with open(output_file, 'w', encoding='utf-8') as f:
        f.write("-- 찬송가 성경구절 업데이트\n")
        f.write("-- hbible.co.kr에서 수집한 537개 찬송가의 성경구절 데이터\n\n")

        update_count = 0
        for number, bible_ref in sorted(data.items(), key=lambda x: int(x[0])):
            # PostgreSQL에서 작은따옴표 이스케이프
            escaped_ref = bible_ref.replace("'", "''")

            sql = f"UPDATE hymns SET bible_reference = '{escaped_ref}' WHERE number = {number};\n"
            f.write(sql)
            update_count += 1

    print(f"✅ SQL 마이그레이션 파일 생성 완료")
    print(f"   📁 파일: {output_file}")
    print(f"   📊 총 {update_count}개 UPDATE 문 생성")

if __name__ == '__main__':
    main()
