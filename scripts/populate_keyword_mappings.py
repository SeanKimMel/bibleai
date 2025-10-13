#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import json
import psycopg2
from psycopg2.extras import RealDictCursor, Json
from collections import defaultdict
import random

# 데이터베이스 연결
DB_CONFIG = {
    'host': 'localhost',
    'database': 'bibleai',
    'user': 'bibleai',
    'password': 'bibleai'
}

# 키워드별 매핑 규칙 (찬송가 theme 기반)
KEYWORD_MAPPINGS = {
    # 감정 카테고리
    '사랑': {
        'themes': ['구원/은혜', '신앙/믿음'],
        'bible': [
            {'book': '고전', 'chapter': 13},
            {'book': '요일', 'chapter': 4},
            {'book': '요', 'chapter': 3},
            {'book': '롬', 'chapter': 8},
            {'book': '엡', 'chapter': 5}
        ]
    },
    '평안': {
        'themes': ['위로/평안'],
        'bible': [
            {'book': '요', 'chapter': 14},
            {'book': '빌', 'chapter': 4},
            {'book': '시', 'chapter': 23},
            {'book': '사', 'chapter': 26}
        ]
    },
    '감사': {
        'themes': ['감사/기쁨'],
        'bible': [
            {'book': '시', 'chapter': 100},
            {'book': '살전', 'chapter': 5},
            {'book': '엡', 'chapter': 5},
            {'book': '골', 'chapter': 3},
            {'book': '시', 'chapter': 136}
        ]
    },
    '위로': {
        'themes': ['위로/평안'],
        'bible': [
            {'book': '고후', 'chapter': 1},
            {'book': '시', 'chapter': 23},
            {'book': '마', 'chapter': 11},
            {'book': '사', 'chapter': 40}
        ]
    },
    '기쁨': {
        'themes': ['감사/기쁨'],
        'bible': [
            {'book': '빌', 'chapter': 4},
            {'book': '시', 'chapter': 16},
            {'book': '느', 'chapter': 8},
            {'book': '롬', 'chapter': 15}
        ]
    },
    '희망': {
        'themes': ['신앙/소망'],
        'bible': [
            {'book': '롬', 'chapter': 5},
            {'book': '히', 'chapter': 11},
            {'book': '렘', 'chapter': 29},
            {'book': '시', 'chapter': 42}
        ]
    },

    # 신앙 카테고리
    '믿음': {
        'themes': ['신앙/믿음'],
        'bible': [
            {'book': '히', 'chapter': 11},
            {'book': '롬', 'chapter': 10},
            {'book': '갈', 'chapter': 2},
            {'book': '약', 'chapter': 2},
            {'book': '엡', 'chapter': 2}
        ]
    },
    '소망': {
        'themes': ['신앙/소망'],
        'bible': [
            {'book': '롬', 'chapter': 8},
            {'book': '히', 'chapter': 6},
            {'book': '벧전', 'chapter': 1},
            {'book': '시', 'chapter': 62}
        ]
    },
    '구원': {
        'themes': ['구원/십자가', '구원/은혜'],
        'bible': [
            {'book': '롬', 'chapter': 10},
            {'book': '엡', 'chapter': 2},
            {'book': '행', 'chapter': 4},
            {'book': '딛', 'chapter': 3},
            {'book': '요', 'chapter': 3}
        ]
    },
    '회개': {
        'themes': ['회개/용서'],
        'bible': [
            {'book': '요일', 'chapter': 1},
            {'book': '시', 'chapter': 51},
            {'book': '행', 'chapter': 3},
            {'book': '눅', 'chapter': 15}
        ]
    },
    '은혜': {
        'themes': ['구원/은혜'],
        'bible': [
            {'book': '엡', 'chapter': 2},
            {'book': '고후', 'chapter': 12},
            {'book': '롬', 'chapter': 5},
            {'book': '딛', 'chapter': 2},
            {'book': '히', 'chapter': 4}
        ]
    },
    '성령': {
        'themes': ['예배/송영'],
        'bible': [
            {'book': '행', 'chapter': 2},
            {'book': '롬', 'chapter': 8},
            {'book': '고전', 'chapter': 12},
            {'book': '갈', 'chapter': 5},
            {'book': '요', 'chapter': 14}
        ]
    },
    '영생': {
        'themes': ['천국/영생'],
        'bible': [
            {'book': '요', 'chapter': 3},
            {'book': '요', 'chapter': 17},
            {'book': '롬', 'chapter': 6},
            {'book': '요일', 'chapter': 5}
        ]
    },
    '십자가': {
        'themes': ['구원/십자가'],
        'bible': [
            {'book': '고전', 'chapter': 1},
            {'book': '갈', 'chapter': 6},
            {'book': '골', 'chapter': 2},
            {'book': '빌', 'chapter': 2}
        ]
    },

    # 예배 카테고리
    '찬양': {
        'themes': ['예배/찬양'],
        'bible': [
            {'book': '시', 'chapter': 150},
            {'book': '시', 'chapter': 100},
            {'book': '대상', 'chapter': 16},
            {'book': '계', 'chapter': 5},
            {'book': '시', 'chapter': 95}
        ]
    },
    '경배': {
        'themes': ['예배/찬양'],
        'bible': [
            {'book': '계', 'chapter': 4},
            {'book': '시', 'chapter': 95},
            {'book': '요', 'chapter': 4},
            {'book': '대하', 'chapter': 20}
        ]
    },
    '영광': {
        'themes': ['예배/찬양', '예배/송영'],
        'bible': [
            {'book': '계', 'chapter': 4},
            {'book': '사', 'chapter': 6},
            {'book': '시', 'chapter': 29},
            {'book': '롬', 'chapter': 11}
        ]
    },

    # 성품 카테고리
    '용기': {
        'themes': ['시련/인내'],
        'bible': [
            {'book': '수', 'chapter': 1},
            {'book': '신', 'chapter': 31},
            {'book': '사', 'chapter': 41},
            {'book': '고전', 'chapter': 16}
        ]
    },
    '지혜': {
        'themes': ['신앙/믿음'],
        'bible': [
            {'book': '잠', 'chapter': 3},
            {'book': '약', 'chapter': 1},
            {'book': '잠', 'chapter': 8},
            {'book': '전', 'chapter': 7}
        ]
    },
    '순종': {
        'themes': ['헌신/봉사'],
        'bible': [
            {'book': '삼상', 'chapter': 15},
            {'book': '신', 'chapter': 11},
            {'book': '히', 'chapter': 5},
            {'book': '빌', 'chapter': 2}
        ]
    },
    '겸손': {
        'themes': ['헌신/봉사'],
        'bible': [
            {'book': '빌', 'chapter': 2},
            {'book': '벧전', 'chapter': 5},
            {'book': '미', 'chapter': 6},
            {'book': '약', 'chapter': 4}
        ]
    },
    '인내': {
        'themes': ['시련/인내'],
        'bible': [
            {'book': '약', 'chapter': 1},
            {'book': '롬', 'chapter': 5},
            {'book': '히', 'chapter': 12},
            {'book': '갈', 'chapter': 6}
        ]
    },

    # 관계 카테고리
    '용서': {
        'themes': ['회개/용서'],
        'bible': [
            {'book': '마', 'chapter': 18},
            {'book': '엡', 'chapter': 4},
            {'book': '골', 'chapter': 3},
            {'book': '눅', 'chapter': 17}
        ]
    },
    '가족': {
        'themes': ['인도/보호'],
        'bible': [
            {'book': '엡', 'chapter': 5},
            {'book': '엡', 'chapter': 6},
            {'book': '잠', 'chapter': 31},
            {'book': '신', 'chapter': 6}
        ]
    },

    # 기도 카테고리
    '치유': {
        'themes': ['인도/보호'],
        'bible': [
            {'book': '약', 'chapter': 5},
            {'book': '시', 'chapter': 147},
            {'book': '렘', 'chapter': 17},
            {'book': '말', 'chapter': 4}
        ]
    },
    '축복': {
        'themes': ['구원/은혜'],
        'bible': [
            {'book': '민', 'chapter': 6},
            {'book': '신', 'chapter': 28},
            {'book': '엡', 'chapter': 1},
            {'book': '시', 'chapter': 1}
        ]
    },

    # 추가 키워드들
    '부활': {
        'themes': ['구원/십자가', '신앙/소망'],
        'bible': [
            {'book': '고전', 'chapter': 15},
            {'book': '요', 'chapter': 20},
            {'book': '롬', 'chapter': 6},
            {'book': '마', 'chapter': 28}
        ]
    },
    '성탄': {
        'themes': ['예수 탄생'],
        'bible': [
            {'book': '눅', 'chapter': 2},
            {'book': '마', 'chapter': 2},
            {'book': '요', 'chapter': 1},
            {'book': '사', 'chapter': 9}
        ]
    },
    '거룩': {
        'themes': ['예배/찬양', '헌신/봉사'],
        'bible': [
            {'book': '레', 'chapter': 19},
            {'book': '벧전', 'chapter': 1},
            {'book': '살전', 'chapter': 4},
            {'book': '히', 'chapter': 12}
        ]
    },
    '진리': {
        'themes': ['신앙/믿음'],
        'bible': [
            {'book': '요', 'chapter': 8},
            {'book': '요', 'chapter': 14},
            {'book': '요', 'chapter': 17},
            {'book': '시', 'chapter': 119}
        ]
    },
    '보혈': {
        'themes': ['구원/십자가'],
        'bible': [
            {'book': '히', 'chapter': 9},
            {'book': '벧전', 'chapter': 1},
            {'book': '요일', 'chapter': 1},
            {'book': '계', 'chapter': 7}
        ]
    },
    '대속': {
        'themes': ['구원/십자가'],
        'bible': [
            {'book': '사', 'chapter': 53},
            {'book': '막', 'chapter': 10},
            {'book': '고후', 'chapter': 5},
            {'book': '갈', 'chapter': 3}
        ]
    },
    '구속': {
        'themes': ['구원/십자가', '구원/은혜'],
        'bible': [
            {'book': '엡', 'chapter': 1},
            {'book': '롬', 'chapter': 3},
            {'book': '골', 'chapter': 1},
            {'book': '출', 'chapter': 15}
        ]
    },
    '의': {
        'themes': ['신앙/믿음'],
        'bible': [
            {'book': '롬', 'chapter': 3},
            {'book': '마', 'chapter': 5},
            {'book': '약', 'chapter': 2},
            {'book': '시', 'chapter': 23}
        ]
    },
    '충성': {
        'themes': ['헌신/봉사'],
        'bible': [
            {'book': '마', 'chapter': 25},
            {'book': '고전', 'chapter': 4},
            {'book': '계', 'chapter': 2},
            {'book': '눅', 'chapter': 16}
        ]
    },
    '평강': {
        'themes': ['위로/평안'],
        'bible': [
            {'book': '롬', 'chapter': 5},
            {'book': '요', 'chapter': 16},
            {'book': '빌', 'chapter': 4},
            {'book': '사', 'chapter': 26}
        ]
    },
    '할렐루야': {
        'themes': ['예배/찬양'],
        'bible': [
            {'book': '시', 'chapter': 150},
            {'book': '시', 'chapter': 148},
            {'book': '계', 'chapter': 19},
            {'book': '시', 'chapter': 146}
        ]
    },
    '찬송': {
        'themes': ['예배/찬양'],
        'bible': [
            {'book': '시', 'chapter': 149},
            {'book': '시', 'chapter': 147},
            {'book': '엡', 'chapter': 5},
            {'book': '골', 'chapter': 3}
        ]
    },
    '간구': {
        'themes': ['기도/간구'],
        'bible': [
            {'book': '빌', 'chapter': 4},
            {'book': '마', 'chapter': 7},
            {'book': '눅', 'chapter': 11},
            {'book': '시', 'chapter': 6}
        ]
    },
    '응답': {
        'themes': ['기도/간구'],
        'bible': [
            {'book': '시', 'chapter': 34},
            {'book': '왕상', 'chapter': 18},
            {'book': '사', 'chapter': 65},
            {'book': '렘', 'chapter': 33}
        ]
    },
    '건강': {
        'themes': ['인도/보호'],
        'bible': [
            {'book': '약', 'chapter': 5},
            {'book': '요삼', 'chapter': 1},
            {'book': '잠', 'chapter': 3},
            {'book': '시', 'chapter': 103}
        ]
    },
    '직장': {
        'themes': ['헌신/봉사'],
        'bible': [
            {'book': '골', 'chapter': 3},
            {'book': '엡', 'chapter': 6},
            {'book': '벧전', 'chapter': 2},
            {'book': '잠', 'chapter': 16}
        ]
    },
    '추수': {
        'themes': ['감사/기쁨'],
        'bible': [
            {'book': '시', 'chapter': 126},
            {'book': '레', 'chapter': 23},
            {'book': '갈', 'chapter': 6},
            {'book': '마', 'chapter': 9}
        ]
    }
}

def main():
    try:
        # 데이터베이스 연결
        conn = psycopg2.connect(**DB_CONFIG)
        cur = conn.cursor(cursor_factory=RealDictCursor)

        # 1. 모든 키워드 가져오기
        cur.execute("SELECT id, name, category FROM keywords ORDER BY name")
        keywords = cur.fetchall()

        # 2. 찬송가 theme별로 그룹화
        cur.execute("""
            SELECT number, title, theme
            FROM hymns
            WHERE theme IS NOT NULL AND theme != ''
            ORDER BY number
        """)
        hymns = cur.fetchall()

        # theme별 찬송가 그룹화
        hymns_by_theme = defaultdict(list)
        for hymn in hymns:
            if hymn['theme']:
                hymns_by_theme[hymn['theme']].append(hymn['number'])

        print(f"총 {len(keywords)}개 키워드 매핑 시작...")
        print(f"찬송가 {len(hymns)}개 로드 완료")

        # 3. 각 키워드별로 매핑 데이터 생성
        for keyword in keywords:
            keyword_name = keyword['name']

            # 찬송가 매핑
            hymn_numbers = []
            if keyword_name in KEYWORD_MAPPINGS:
                themes = KEYWORD_MAPPINGS[keyword_name].get('themes', [])
                for theme in themes:
                    if theme in hymns_by_theme:
                        # 해당 theme의 찬송가 중 일부 선택
                        theme_hymns = hymns_by_theme[theme]
                        # 최대 20개까지만
                        sample_size = min(20, len(theme_hymns))
                        hymn_numbers.extend(random.sample(theme_hymns, sample_size))

            # 중복 제거 및 정렬
            hymn_numbers = sorted(list(set(hymn_numbers)))[:30]  # 최대 30개

            # 성경 매핑
            bible_chapters = []
            if keyword_name in KEYWORD_MAPPINGS:
                bible_chapters = KEYWORD_MAPPINGS[keyword_name].get('bible', [])

            # 기도문 매핑 (랜덤하게 일부 할당)
            prayer_ids = []
            if keyword_name in ['사랑', '감사', '위로', '기쁨', '평안', '구원', '믿음']:
                # 주요 키워드는 더 많은 기도문 연결
                prayer_ids = random.sample(range(1, 38), random.randint(3, 8))
            elif keyword_name in KEYWORD_MAPPINGS:
                prayer_ids = random.sample(range(1, 38), random.randint(1, 4))

            # 데이터베이스 업데이트
            if hymn_numbers or bible_chapters or prayer_ids:
                cur.execute("""
                    UPDATE keywords
                    SET
                        hymn_numbers = %s,
                        bible_chapters = %s,
                        prayer_ids = %s,
                        updated_at = NOW()
                    WHERE name = %s
                """, (
                    hymn_numbers,
                    Json(bible_chapters),
                    prayer_ids,
                    keyword_name
                ))

                print(f"  {keyword_name}: 찬송가 {len(hymn_numbers)}개, "
                      f"성경 {len(bible_chapters)}장, 기도문 {len(prayer_ids)}개")

        conn.commit()

        # 4. 통계 출력
        cur.execute("""
            SELECT
                COUNT(*) as total_keywords,
                COUNT(CASE WHEN array_length(hymn_numbers, 1) > 0 THEN 1 END) as with_hymns,
                COUNT(CASE WHEN jsonb_array_length(bible_chapters) > 0 THEN 1 END) as with_bible,
                COUNT(CASE WHEN array_length(prayer_ids, 1) > 0 THEN 1 END) as with_prayers
            FROM keywords
        """)
        stats = cur.fetchone()

        print("\n=== 매핑 완료 ===")
        print(f"총 키워드: {stats['total_keywords']}")
        print(f"찬송가 매핑: {stats['with_hymns']}개 키워드")
        print(f"성경 매핑: {stats['with_bible']}개 키워드")
        print(f"기도문 매핑: {stats['with_prayers']}개 키워드")

        cur.close()
        conn.close()

    except psycopg2.Error as e:
        print(f"데이터베이스 오류: {e}")
    except Exception as e:
        print(f"오류 발생: {e}")

if __name__ == "__main__":
    main()