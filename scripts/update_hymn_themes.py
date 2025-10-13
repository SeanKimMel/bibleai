#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import json
import re
import psycopg2
from psycopg2.extras import RealDictCursor
from collections import Counter

# 데이터베이스 연결
DB_CONFIG = {
    'host': 'localhost',
    'database': 'bibleai',
    'user': 'bibleai',
    'password': 'bibleai'
}

# 주제 카테고리 정의 (기존 API와 호환되도록 슬래시 구조 유지)
THEME_PATTERNS = {
    '예배/찬양': ['찬양', '경배', '할렐루야', '영광', '찬송', '거룩'],
    '예배/송영': ['삼위일체', '성부', '성자', '성령', '송영'],
    '구원/십자가': ['십자가', '보혈', '구속', '대속', '속죄', '구원', '구세주'],
    '구원/은혜': ['은혜', '긍휼', '자비', '사랑'],
    '신앙/기도': ['기도', '간구', '응답', '부르짖'],
    '신앙/믿음': ['믿음', '신뢰', '의지', '순종', '충성'],
    '신앙/소망': ['소망', '희망', '기대', '바람'],
    '감사/기쁨': ['감사', '기쁨', '즐거움', '행복', '축복'],
    '위로/평안': ['위로', '평안', '평화', '안식', '쉼'],
    '인도/보호': ['인도', '보호', '지키', '목자', '길', '방패'],
    '회개/용서': ['회개', '용서', '죄', '정결', '깨끗'],
    '천국/영생': ['천국', '하늘나라', '영생', '영원', '부활'],
    '성탄/재림': ['성탄', '탄생', '재림', '강림', '임하'],
    '헌신/봉사': ['헌신', '봉사', '섬김', '사명', '전도', '선교'],
    '시련/인내': ['고난', '시련', '인내', '어려움', '승리']
}

def analyze_hymn_for_theme(title, lyrics):
    """찬송가 제목과 가사를 분석하여 가장 적합한 주제 반환"""
    text = f"{title} {lyrics}".lower()

    theme_scores = {}

    # 각 주제별로 점수 계산
    for theme, keywords in THEME_PATTERNS.items():
        score = 0
        for keyword in keywords:
            if keyword in text:
                # 제목에 있으면 가중치 3, 가사에만 있으면 가중치 1
                if keyword in title.lower():
                    score += 3
                else:
                    score += text.count(keyword)

        if score > 0:
            theme_scores[theme] = score

    # 점수가 가장 높은 주제 선택
    if theme_scores:
        best_theme = max(theme_scores, key=theme_scores.get)
        return best_theme

    # 기본 주제 할당 (키워드가 없는 경우)
    if '하나님' in text or '주님' in text or '예수' in text:
        return '예배/찬양'

    return '신앙/믿음'  # 기본값

def main():
    try:
        # 데이터베이스 연결
        conn = psycopg2.connect(**DB_CONFIG)
        cur = conn.cursor(cursor_factory=RealDictCursor)

        # 모든 찬송가 조회
        cur.execute("""
            SELECT id, number, title, lyrics, theme
            FROM hymns
            ORDER BY number
        """)
        hymns = cur.fetchall()

        print(f"총 {len(hymns)}개의 찬송가 theme을 업데이트합니다.")

        # 주제별 통계
        theme_counts = Counter()
        updated_count = 0

        # 각 찬송가 theme 업데이트
        for hymn in hymns:
            hymn_id = hymn['id']
            number = hymn['number']
            title = hymn['title'] or ''
            lyrics = hymn['lyrics'] or ''
            current_theme = hymn['theme'] or ''

            # 새로운 theme 분석
            new_theme = analyze_hymn_for_theme(title, lyrics)

            # theme이 변경되었거나 비어있던 경우만 업데이트
            if new_theme != current_theme or not current_theme:
                cur.execute("""
                    UPDATE hymns
                    SET theme = %s, updated_at = NOW()
                    WHERE id = %s
                """, (new_theme, hymn_id))
                updated_count += 1

            theme_counts[new_theme] += 1

            if number % 100 == 0:
                print(f"  {number}번까지 처리 완료...")

        conn.commit()

        # 통계 출력
        print(f"\n=== 업데이트 완료 ===")
        print(f"총 찬송가 수: {len(hymns)}")
        print(f"업데이트된 찬송가: {updated_count}")

        print("\n=== 주제별 분포 ===")
        for theme, count in theme_counts.most_common(15):
            percentage = (count / len(hymns)) * 100
            print(f"  {theme}: {count}개 ({percentage:.1f}%)")

        # 업데이트 확인
        cur.execute("""
            SELECT theme, COUNT(*) as count
            FROM hymns
            WHERE theme IS NOT NULL AND theme != ''
            GROUP BY theme
            ORDER BY count DESC
        """)

        result = cur.fetchall()

        print("\n=== DB 실제 분포 확인 ===")
        for row in result[:10]:
            print(f"  {row['theme']}: {row['count']}개")

        cur.close()
        conn.close()

    except psycopg2.Error as e:
        print(f"데이터베이스 오류: {e}")
    except Exception as e:
        print(f"오류 발생: {e}")

if __name__ == "__main__":
    main()