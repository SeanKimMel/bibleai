#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import json
import re
import psycopg2
from psycopg2.extras import RealDictCursor
from collections import defaultdict, Counter

# 데이터베이스 연결
DB_CONFIG = {
    'host': 'localhost',
    'database': 'bibleai',
    'user': 'bibleai',
    'password': 'bibleai'
}

# 기존 API와 동일한 키워드 체계 사용
BASE_KEYWORDS = {
    '감정': ['사랑', '평안', '감사', '위로', '기쁨', '희망', '평강'],
    '신앙': ['믿음', '소망', '구원', '회개', '은혜', '진리', '성령', '영생', '십자가'],
    '성품': ['용기', '지혜', '순종', '겸손', '인내', '의'],
    '관계': ['용서', '가족'],
    '기도': ['치유', '축복'],
    '일상': ['직장', '건강']
}

# 찬송가 특화 키워드 추가 (짧고 간결하게)
HYMN_KEYWORDS = {
    '예배': ['찬양', '경배', '영광', '거룩', '할렐루야'],
    '구원': ['십자가', '보혈', '구속', '대속'],
    '기도': ['간구', '응답', '부르짖음'],
    '신앙': ['믿음', '소망', '사랑', '은혜', '축복'],
    '감정': ['기쁨', '평안', '위로', '감사', '찬송'],
    '성품': ['충성', '헌신', '순종', '겸손'],
    '계절': ['성탄', '부활', '추수']
}

def extract_keywords(title, lyrics, max_keywords=3):
    """찬송가 제목과 가사에서 키워드 추출 (최대 3개)"""
    keywords = []
    text = f"{title} {lyrics}".lower()

    # 모든 키워드를 점수화
    keyword_scores = {}

    # BASE_KEYWORDS 체크
    for category, words in BASE_KEYWORDS.items():
        for word in words:
            if word in text:
                count = text.count(word)
                if count > 0:
                    keyword_scores[word] = count * 2  # 기본 키워드는 가중치 2배

    # HYMN_KEYWORDS 체크
    for category, words in HYMN_KEYWORDS.items():
        for word in words:
            if word in text:
                count = text.count(word)
                if count > 0:
                    keyword_scores[word] = count

    # 특별 패턴 감지
    # 1. 주제별 자동 태깅
    if '하나님' in text or '주님' in text or '예수' in text:
        if '찬양' not in keyword_scores:
            keyword_scores['찬양'] = 1

    if '십자가' in text or '보혈' in text:
        if '구원' not in keyword_scores:
            keyword_scores['구원'] = 2

    if '성탄' in text or '베들레헴' in text or '구유' in text:
        keyword_scores['성탄'] = 3

    if '부활' in text or '빈 무덤' in text:
        keyword_scores['부활'] = 3

    # 상위 키워드 선택
    sorted_keywords = sorted(keyword_scores.items(), key=lambda x: x[1], reverse=True)

    # 최대 3개까지만 선택
    for keyword, score in sorted_keywords[:max_keywords]:
        keywords.append(keyword)

    # 키워드가 없으면 기본값 '찬양' 추가
    if not keywords:
        keywords = ['찬양']

    return keywords

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

        print(f"총 {len(hymns)}개의 찬송가를 분석합니다.")

        # 분석 결과 저장
        hymn_keywords_data = []
        all_keywords = Counter()

        for hymn in hymns:
            hymn_id = hymn['id']
            number = hymn['number']
            title = hymn['title'] or ''
            lyrics = hymn['lyrics'] or ''

            # 키워드 추출 (최대 3개)
            keywords = extract_keywords(title, lyrics)

            if keywords:
                hymn_keywords_data.append({
                    'hymn_id': hymn_id,
                    'number': number,
                    'title': title,
                    'keywords': keywords
                })

                # 전체 키워드 통계
                for keyword in keywords:
                    all_keywords[keyword] += 1

            if number % 100 == 0:
                print(f"  {number}번까지 분석 완료...")

        # 키워드 데이터베이스에 삽입
        print("\n키워드를 데이터베이스에 저장합니다...")

        # 1. keywords 테이블에 새로운 키워드 추가
        unique_keywords = set()
        for item in hymn_keywords_data:
            unique_keywords.update(item['keywords'])

        # 카테고리 매핑
        keyword_categories = {}
        for category, words in {**BASE_KEYWORDS, **HYMN_KEYWORDS}.items():
            for word in words:
                keyword_categories[word] = category

        for keyword in unique_keywords:
            category = keyword_categories.get(keyword, '찬양')  # 기본 카테고리는 '찬양'
            cur.execute("""
                INSERT INTO keywords (name, category)
                VALUES (%s, %s)
                ON CONFLICT (name) DO NOTHING
            """, (keyword, category))

        # 2. hymn_keywords 매핑 테이블에 관계 추가
        for item in hymn_keywords_data:
            hymn_id = item['hymn_id']

            # 기존 키워드 매핑 삭제
            cur.execute("DELETE FROM hymn_keywords WHERE hymn_id = %s", (hymn_id,))

            # 새로운 키워드 매핑 추가
            for keyword in item['keywords']:
                cur.execute("""
                    INSERT INTO hymn_keywords (hymn_id, keyword_id)
                    SELECT %s, id FROM keywords WHERE name = %s
                    ON CONFLICT DO NOTHING
                """, (hymn_id, keyword))

        # 3. 키워드 사용 횟수 업데이트
        for keyword in unique_keywords:
            cur.execute("""
                UPDATE keywords
                SET hymn_count = (
                    SELECT COUNT(*)
                    FROM hymn_keywords hk
                    JOIN keywords k ON k.id = hk.keyword_id
                    WHERE k.name = %s
                ),
                usage_count = (
                    SELECT COUNT(*)
                    FROM hymn_keywords hk
                    JOIN keywords k ON k.id = hk.keyword_id
                    WHERE k.name = %s
                )
                WHERE name = %s
            """, (keyword, keyword, keyword))

        conn.commit()

        # 통계 출력
        print("\n=== 분석 완료 ===")
        print(f"총 찬송가 수: {len(hymns)}")
        print(f"키워드가 할당된 찬송가: {len(hymn_keywords_data)}")
        print(f"고유 키워드 수: {len(unique_keywords)}")

        print("\n=== 상위 15개 키워드 (기존 시스템과 호환) ===")
        for keyword, count in all_keywords.most_common(15):
            category = keyword_categories.get(keyword, '기타')
            print(f"  {keyword} ({category}): {count}개 찬송가")

        # 분석 결과를 JSON 파일로 저장
        output_file = '/workspace/bibleai/hymn_keywords_analysis.json'
        with open(output_file, 'w', encoding='utf-8') as f:
            json.dump({
                'total_hymns': len(hymns),
                'analyzed_hymns': len(hymn_keywords_data),
                'unique_keywords': list(unique_keywords),
                'keyword_statistics': dict(all_keywords.most_common()),
                'hymn_keywords': hymn_keywords_data[:10]  # 샘플만 저장
            }, f, ensure_ascii=False, indent=2)

        print(f"\n분석 결과가 {output_file}에 저장되었습니다.")

        # SQL 마이그레이션 파일 생성
        migration_file = '/workspace/bibleai/migrations/010_hymn_keywords.sql'
        with open(migration_file, 'w', encoding='utf-8') as f:
            f.write("-- 찬송가 키워드 매핑 업데이트\n")
            f.write("-- 자동 생성된 마이그레이션 파일\n\n")

            # 샘플 SQL 작성 (처음 10개만)
            for item in hymn_keywords_data[:10]:
                f.write(f"-- 찬송가 {item['number']}번: {item['title']}\n")
                f.write(f"-- 키워드: {', '.join(item['keywords'])}\n")
                f.write(f"-- hymn_id: {item['hymn_id']}\n\n")

        print(f"마이그레이션 파일이 {migration_file}에 생성되었습니다.")

        cur.close()
        conn.close()

    except psycopg2.Error as e:
        print(f"데이터베이스 오류: {e}")
    except Exception as e:
        print(f"오류 발생: {e}")

if __name__ == "__main__":
    main()