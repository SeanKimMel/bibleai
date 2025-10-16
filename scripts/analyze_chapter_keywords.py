#!/usr/bin/env python3
"""
성경 각 장의 해석 데이터를 분석하여 연관 키워드를 자동 추출하는 스크립트

분석 대상:
- chapter_title: 장 제목
- chapter_summary: 장 요약
- chapter_themes: 주요 주제들
- chapter_context: 역사적/신학적 배경
- chapter_application: 현대적 적용

키워드 매칭 로직:
1. 키워드가 텍스트에 직접 등장하는지 확인
2. 유사어/동의어 매칭 (예: '사랑' - '사랑하다', '애정')
3. 주제 분석 (chapter_themes JSON 배열)
4. 신뢰도 점수 계산
"""

import psycopg2
import json
import re
from typing import List, Dict, Tuple

# 키워드별 유사어 사전
KEYWORD_SYNONYMS = {
    '사랑': ['사랑', '애정', '자애', '아가페'],
    '믿음': ['믿음', '신앙', '신뢰', '확신'],
    '소망': ['소망', '희망'],
    '기쁨': ['기쁨', '즐거움', '환희', '희락'],
    '감사': ['감사', '감격'],
    '용서': ['용서', '사죄', '용납'],
    '평안': ['평안', '평화', '안식', '평강', '평온'],
    '지혜': ['지혜', '슬기', '통찰'],
    '구원': ['구원', '구속'],
    '은혜': ['은혜', '은총', '은사'],
    '의': ['의롭게', '의로움'],  # '의'는 단독으로는 제외 (하나님의, 이스라엘의 등 너무 많음)
}

# 추가 매핑 규칙
THEME_KEYWORD_MAPPING = {
    '은혜로 구원': ['은혜', '구원', '믿음'],
    '믿음으로 구원': ['믿음', '구원', '은혜'],
    '하나님의 사랑': ['사랑'],
    '평강': ['평안'],
    '회개와 용서': ['용서', '회개'],
    '감사와 찬양': ['감사', '찬양'],
}

def connect_db():
    """데이터베이스 연결"""
    return psycopg2.connect(
        host="localhost",
        database="bibleai",
        user="bibleai",
        password="bibleai"
    )

def get_target_keywords(conn) -> List[str]:
    """keywords 테이블에서 키워드 목록 가져오기"""
    with conn.cursor() as cur:
        cur.execute("SELECT name FROM keywords ORDER BY name")
        return [row[0] for row in cur.fetchall()]

def analyze_chapter(chapter_data: Dict, keywords: List[str]) -> Tuple[List[str], str, int]:
    """
    장 데이터를 분석하여 관련 키워드 추출

    Returns:
        (키워드 리스트, 주요 키워드, 신뢰도 점수)
    """
    title = chapter_data.get('chapter_title', '')
    summary = chapter_data.get('chapter_summary', '')
    themes_json = chapter_data.get('chapter_themes', '[]')
    context = chapter_data.get('chapter_context', '')
    application = chapter_data.get('chapter_application', '')

    # JSON 배열 파싱
    try:
        themes = json.loads(themes_json) if themes_json else []
    except:
        themes = []

    # 전체 텍스트 결합
    full_text = f"{title} {summary} {' '.join(themes)} {context} {application}".lower()

    # 키워드별 점수 계산
    keyword_scores = {}

    for keyword in keywords:
        score = 0
        synonyms = KEYWORD_SYNONYMS.get(keyword, [keyword])

        # 1. 제목에 등장 (가중치 높음)
        for syn in synonyms:
            if syn.lower() in title.lower():
                score += 30
                break

        # 2. 주요 주제에 등장
        for theme in themes:
            for syn in synonyms:
                if syn.lower() in theme.lower():
                    score += 20
                    break
            # 테마-키워드 매핑 확인
            if theme in THEME_KEYWORD_MAPPING:
                if keyword in THEME_KEYWORD_MAPPING[theme]:
                    score += 25

        # 3. 요약에 등장 (빈도 계산)
        for syn in synonyms:
            count = summary.lower().count(syn.lower())
            score += count * 5

        # 4. 전체 텍스트에 등장
        for syn in synonyms:
            count = full_text.count(syn.lower())
            score += count * 2

        if score > 0:
            keyword_scores[keyword] = score

    # 상위 키워드 선택 (점수 10 이상)
    matched_keywords = [k for k, v in sorted(keyword_scores.items(), key=lambda x: -x[1]) if v >= 10]

    # 주요 키워드 (최고 점수)
    primary_keyword = matched_keywords[0] if matched_keywords else None

    # 신뢰도 점수 (1-10)
    confidence = min(10, max(1, keyword_scores.get(primary_keyword, 0) // 10)) if primary_keyword else 0

    return matched_keywords[:5], primary_keyword, confidence  # 최대 5개 키워드

def main():
    """메인 실행 함수"""
    conn = connect_db()

    try:
        # 키워드 목록 가져오기
        keywords = get_target_keywords(conn)
        print(f"분석 대상 키워드 ({len(keywords)}개): {', '.join(keywords)}")
        print()

        # 모든 장의 해석 데이터 가져오기
        with conn.cursor() as cur:
            cur.execute("""
                SELECT book_id, chapter,
                       chapter_title, chapter_summary,
                       chapter_themes, chapter_context,
                       chapter_application
                FROM bible_verses
                WHERE verse = 1 AND chapter_title IS NOT NULL
                ORDER BY book_id, chapter
            """)

            results = []
            total_chapters = 0
            matched_chapters = 0

            for row in cur.fetchall():
                total_chapters += 1
                book_id, chapter = row[0], row[1]

                chapter_data = {
                    'chapter_title': row[2],
                    'chapter_summary': row[3],
                    'chapter_themes': row[4],
                    'chapter_context': row[5],
                    'chapter_application': row[6],
                }

                # 키워드 분석
                matched_kws, primary_kw, confidence = analyze_chapter(chapter_data, keywords)

                if matched_kws:
                    matched_chapters += 1
                    results.append({
                        'book': book_id,
                        'chapter': chapter,
                        'keywords': matched_kws,
                        'primary': primary_kw,
                        'confidence': confidence,
                        'title': chapter_data['chapter_title']
                    })

                    # 진행 상황 출력 (10장마다)
                    if total_chapters % 10 == 0:
                        print(f"진행: {total_chapters}/1188 장 분석 완료...")

            print(f"\n분석 완료: 총 {total_chapters}장 중 {matched_chapters}장에서 키워드 매칭됨\n")

            # 결과 샘플 출력
            print("=== 분석 결과 샘플 (처음 20개) ===\n")
            for i, result in enumerate(results[:20], 1):
                print(f"{i}. {result['book']}:{result['chapter']} - {result['title']}")
                print(f"   주요 키워드: {result['primary']} (신뢰도: {result['confidence']}/10)")
                print(f"   관련 키워드: {', '.join(result['keywords'])}")
                print()

            # 키워드별 통계
            print("\n=== 키워드별 매칭 통계 ===\n")
            keyword_counts = {}
            for result in results:
                for kw in result['keywords']:
                    keyword_counts[kw] = keyword_counts.get(kw, 0) + 1

            for kw in sorted(keyword_counts.keys()):
                print(f"{kw}: {keyword_counts[kw]}개 장")

            # SQL INSERT 문 생성
            print("\n=== SQL INSERT 문 생성 ===\n")
            with open('/tmp/chapter_keywords_insert.sql', 'w', encoding='utf-8') as f:
                f.write("-- 자동 생성된 장별 키워드 매핑 데이터\n\n")
                f.write("-- 1. 테이블 생성\n")
                f.write("""
CREATE TABLE IF NOT EXISTS chapter_primary_keywords (
    book VARCHAR(10),
    chapter INTEGER,
    keywords TEXT[],
    primary_keyword VARCHAR(50),
    confidence_score INTEGER,
    source VARCHAR(20) DEFAULT 'auto_analysis',
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    PRIMARY KEY (book, chapter)
);

CREATE INDEX IF NOT EXISTS idx_chapter_keywords ON chapter_primary_keywords USING GIN(keywords);
CREATE INDEX IF NOT EXISTS idx_primary_keyword ON chapter_primary_keywords(primary_keyword);

-- 2. 데이터 삽입
""")

                for result in results:
                    keywords_array = '{' + ','.join(result['keywords']) + '}'
                    f.write(f"INSERT INTO chapter_primary_keywords (book, chapter, keywords, primary_keyword, confidence_score) VALUES ('{result['book']}', {result['chapter']}, '{keywords_array}', '{result['primary']}', {result['confidence']}) ON CONFLICT (book, chapter) DO UPDATE SET keywords = EXCLUDED.keywords, primary_keyword = EXCLUDED.primary_keyword, confidence_score = EXCLUDED.confidence_score, updated_at = NOW();\n")

                f.write("\n-- 3. 통계 확인\n")
                f.write("SELECT primary_keyword, COUNT(*) FROM chapter_primary_keywords GROUP BY primary_keyword ORDER BY COUNT(*) DESC;\n")

            print("SQL 파일 생성 완료: /tmp/chapter_keywords_insert.sql")
            print("\n실행 방법:")
            print("  psql -h localhost -U bibleai -d bibleai -f /tmp/chapter_keywords_insert.sql")

    finally:
        conn.close()

if __name__ == '__main__':
    main()
