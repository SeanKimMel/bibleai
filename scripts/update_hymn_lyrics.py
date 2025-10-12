#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
찬송가 가사 업데이트 스크립트
hymns/ 디렉토리의 가사 파일을 읽어서 데이터베이스에 업데이트
"""

import os
import psycopg2
from pathlib import Path

# 환경 변수에서 DB 정보 가져오기
DB_HOST = os.getenv('DB_HOST', 'localhost')
DB_PORT = os.getenv('DB_PORT', '5432')
DB_USER = os.getenv('DB_USER', 'bibleai')
DB_PASSWORD = os.getenv('DB_PASSWORD', 'bibleai')
DB_NAME = os.getenv('DB_NAME', 'bibleai')

def read_lyrics_file(file_path):
    """가사 파일 읽기"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            return f.read().strip()
    except Exception as e:
        print(f"❌ 파일 읽기 실패: {file_path} - {e}")
        return None

def update_hymn_lyrics(conn, number, lyrics):
    """데이터베이스에 가사 업데이트"""
    try:
        cursor = conn.cursor()
        cursor.execute("""
            UPDATE hymns
            SET lyrics = %s
            WHERE number = %s
        """, (lyrics, number))

        if cursor.rowcount > 0:
            return True
        else:
            print(f"⚠️  찬송가 {number}번이 DB에 없습니다.")
            return False
    except Exception as e:
        print(f"❌ DB 업데이트 실패 (찬송가 {number}번): {e}")
        return False

def main():
    print("="*50)
    print("찬송가 가사 업데이트 스크립트")
    print("="*50)

    # 데이터베이스 연결
    try:
        conn = psycopg2.connect(
            host=DB_HOST,
            port=DB_PORT,
            user=DB_USER,
            password=DB_PASSWORD,
            dbname=DB_NAME
        )
        print(f"✅ 데이터베이스 연결 성공")
    except Exception as e:
        print(f"❌ 데이터베이스 연결 실패: {e}")
        return

    # hymns 디렉토리 확인
    hymns_dir = Path('/workspace/bibleai/hymns')
    if not hymns_dir.exists():
        print(f"❌ hymns 디렉토리를 찾을 수 없습니다: {hymns_dir}")
        conn.close()
        return

    # 가사 파일 목록 가져오기 (Zone.Identifier 제외)
    lyrics_files = sorted([
        f for f in hymns_dir.glob('*.txt')
        if not f.name.endswith('Zone.Identifier')
    ])

    print(f"\n📁 총 {len(lyrics_files)}개 가사 파일 발견")
    print("-"*50)

    # 통계
    success_count = 0
    fail_count = 0
    skip_count = 0

    # 각 파일 처리
    for file_path in lyrics_files:
        # 파일명에서 번호 추출 (001.txt -> 1)
        number_str = file_path.stem  # 001
        try:
            number = int(number_str)
        except ValueError:
            print(f"⚠️  잘못된 파일명: {file_path.name}")
            skip_count += 1
            continue

        # 가사 읽기
        lyrics = read_lyrics_file(file_path)
        if lyrics is None:
            fail_count += 1
            continue

        # DB 업데이트
        if update_hymn_lyrics(conn, number, lyrics):
            success_count += 1
            if success_count % 50 == 0:
                print(f"✅ {success_count}개 처리 완료...")
        else:
            fail_count += 1

    # 변경사항 커밋
    conn.commit()
    conn.close()

    # 결과 출력
    print("-"*50)
    print(f"\n📊 처리 결과:")
    print(f"   ✅ 성공: {success_count}개")
    print(f"   ❌ 실패: {fail_count}개")
    print(f"   ⏭️  건너뜀: {skip_count}개")
    print(f"   📝 총: {len(lyrics_files)}개")
    print("\n✅ 가사 업데이트 완료!")
    print("="*50)

if __name__ == '__main__':
    main()
