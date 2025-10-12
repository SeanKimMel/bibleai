#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
찬송가 가사 SQL 생성 스크립트
hymns/ 디렉토리의 가사 파일을 읽어서 UPDATE SQL 생성
"""

from pathlib import Path

def read_lyrics_file(file_path):
    """가사 파일 읽기"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            return f.read().strip()
    except Exception as e:
        print(f"-- ❌ 파일 읽기 실패: {file_path} - {e}")
        return None

def escape_sql_string(text):
    """SQL 문자열 이스케이프"""
    # 작은따옴표를 두 개로 변경 (PostgreSQL 이스케이프)
    return text.replace("'", "''")

def main():
    print("-- ==========================================")
    print("-- 찬송가 가사 업데이트 SQL")
    print("-- ==========================================")
    print()

    # hymns 디렉토리 확인
    hymns_dir = Path('/workspace/bibleai/hymns')
    if not hymns_dir.exists():
        print(f"-- ❌ hymns 디렉토리를 찾을 수 없습니다: {hymns_dir}")
        return

    # 가사 파일 목록 가져오기 (Zone.Identifier 제외)
    lyrics_files = sorted([
        f for f in hymns_dir.glob('*.txt')
        if not f.name.endswith('Zone.Identifier')
    ])

    print(f"-- 📁 총 {len(lyrics_files)}개 가사 파일 발견")
    print()
    print("BEGIN;")
    print()

    # 통계
    success_count = 0

    # 각 파일 처리
    for file_path in lyrics_files:
        # 파일명에서 번호 추출 (001.txt -> 1)
        number_str = file_path.stem  # 001
        try:
            number = int(number_str)
        except ValueError:
            print(f"-- ⚠️  잘못된 파일명: {file_path.name}")
            continue

        # 가사 읽기
        lyrics = read_lyrics_file(file_path)
        if lyrics is None:
            continue

        # SQL 이스케이프
        escaped_lyrics = escape_sql_string(lyrics)

        # UPDATE SQL 생성
        print(f"-- 찬송가 {number}번")
        print(f"UPDATE hymns SET lyrics = '{escaped_lyrics}' WHERE number = {number};")
        print()

        success_count += 1

    print("COMMIT;")
    print()
    print(f"-- ✅ {success_count}개 UPDATE 문 생성 완료")
    print("-- ==========================================")

if __name__ == '__main__':
    main()
