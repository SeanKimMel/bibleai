#!/usr/bin/env python3
"""
Bible Chapter Keyword Assignment Script
Analyzes all 1,188 Bible chapters and assigns appropriate keywords
based on theological interpretation data.
"""

import os
import sys
import json
import psycopg2
from psycopg2.extras import RealDictCursor
from datetime import datetime

# Database configuration
DB_CONFIG = {
    'host': os.getenv('DB_HOST', 'localhost'),
    'port': os.getenv('DB_PORT', '5432'),
    'user': os.getenv('DB_USER', 'bibleai'),
    'password': os.getenv('DB_PASSWORD', 'bibleai'),
    'dbname': os.getenv('DB_NAME', 'bibleai')
}

# Available keywords mapping (Korean name -> keyword info)
KEYWORDS = {}

# Bible book order (Korean names)
BIBLE_BOOK_ORDER = [
    # 구약 (Old Testament)
    '창', '출', '레', '민', '신',  # 모세오경
    '수', '삿', '룻', '삼상', '삼하', '왕상', '왕하', '대상', '대하',  # 역사서
    '스', '느', '에',  # 역사서 계속
    '욥', '시', '잠', '전', '아',  # 시가서
    '사', '렘', '애', '겔', '단',  # 대선지서
    '호', '욜', '암', '옵', '욘', '미', '나', '합', '습', '학', '슥', '말',  # 소선지서
    # 신약 (New Testament)
    '마', '막', '눅', '요',  # 복음서
    '행',  # 역사서
    '롬', '고전', '고후', '갈', '엡', '빌', '골', '살전', '살후',  # 바울서신
    '딤전', '딤후', '딛', '몬',  # 목회서신
    '히',  # 히브리서
    '약', '벧전', '벧후', '요일', '요이', '요삼', '유',  # 공동서신
    '계'  # 요한계시록
]

def get_db_connection():
    """Create database connection"""
    return psycopg2.connect(**DB_CONFIG)

def load_keywords(conn):
    """Load all available keywords from database"""
    with conn.cursor(cursor_factory=RealDictCursor) as cur:
        cur.execute("SELECT id, name, category FROM keywords ORDER BY name")
        keywords = cur.fetchall()
        for kw in keywords:
            KEYWORDS[kw['name']] = {
                'id': kw['id'],
                'category': kw['category']
            }
    print(f"Loaded {len(KEYWORDS)} keywords")

def get_chapter_data(conn, book, chapter):
    """Get interpretation data for a specific chapter"""
    with conn.cursor(cursor_factory=RealDictCursor) as cur:
        cur.execute("""
            SELECT book, chapter,
                   chapter_title, chapter_summary,
                   chapter_themes, chapter_context,
                   chapter_application
            FROM bible_verses
            WHERE book = %s AND chapter = %s AND verse = 1
              AND chapter_title IS NOT NULL
        """, (book, chapter))
        return cur.fetchone()

def analyze_keywords(chapter_data):
    """
    Analyze chapter data and select 1-5 most appropriate keywords
    Returns: (primary_keyword, [all_keywords])
    """
    if not chapter_data:
        return None, []

    book = chapter_data['book']
    chapter = chapter_data['chapter']
    title = chapter_data['chapter_title'] or ''
    summary = chapter_data['chapter_summary'] or ''
    themes = chapter_data['chapter_themes'] or []
    context = chapter_data['chapter_context'] or ''
    application = chapter_data['chapter_application'] or ''

    # Parse themes if it's a JSON string
    if isinstance(themes, str):
        try:
            themes = json.loads(themes)
        except:
            themes = []

    # Combine all text for analysis
    all_text = f"{title} {summary} {' '.join(themes)} {context} {application}"

    # Keyword selection logic based on theological significance
    selected_keywords = []
    primary = None

    # Special cases - well-known chapters with specific theological themes
    chapter_key = f"{book}{chapter}"

    # Creation and origins
    if book == 'gn' and chapter == 1:
        selected_keywords = ['거룩', '영광', '감사']
        primary = '거룩'
    elif book == 'gn' and chapter == 3:
        selected_keywords = ['구원', '회개', '소망']
        primary = '구원'

    # Exodus and deliverance
    elif book == 'ex' and chapter == 12:
        selected_keywords = ['구속', '구원', '보혈']
        primary = '구속'
    elif book == 'ex' and chapter == 20:
        selected_keywords = ['순종', '거룩', '믿음']
        primary = '순종'

    # Psalms - praise and worship
    elif book == 'ps' and chapter == 23:
        selected_keywords = ['위로', '평안', '사랑']
        primary = '평안'
    elif book == 'ps' and chapter in [100, 150]:
        selected_keywords = ['찬양', '감사', '기쁨']
        primary = '찬양'
    elif book == 'ps' and chapter == 51:
        selected_keywords = ['회개', '용서', '거룩']
        primary = '회개'
    elif book == 'ps' and chapter == 119:
        selected_keywords = ['진리', '순종', '지혜']
        primary = '진리'
    elif book == 'ps' and chapter in [1, 37, 73, 112]:
        selected_keywords = ['지혜', '축복', '믿음']
        primary = '지혜'
    elif book == 'ps' and chapter in [95, 96, 97, 98, 99]:
        selected_keywords = ['찬양', '경배', '영광']
        primary = '찬양'

    # Proverbs - wisdom
    elif book == 'prv':
        selected_keywords = ['지혜', '순종', '겸손']
        primary = '지혜'

    # Isaiah - messianic prophecy
    elif book == 'is' and chapter == 53:
        selected_keywords = ['대속', '구원', '치유']
        primary = '대속'
    elif book == 'is' and chapter == 40:
        selected_keywords = ['위로', '소망', '은혜']
        primary = '위로'
    elif book == 'is' and chapter in [6, 9]:
        selected_keywords = ['영광', '거룩', '찬양']
        primary = '영광'

    # Gospels - Jesus' ministry
    elif book in ['mt', 'mk', 'lk', 'jn']:
        if '십자가' in all_text or '죽음' in all_text or '못 박' in all_text:
            selected_keywords = ['십자가', '대속', '구원']
            primary = '십자가'
        elif '부활' in all_text:
            selected_keywords = ['부활', '영생', '소망']
            primary = '부활'
        elif '영생' in all_text or '거듭' in all_text:
            selected_keywords = ['영생', '거듭남', '구원']
            primary = '영생'
        elif '사랑' in all_text:
            selected_keywords = ['사랑', '은혜', '믿음']
            primary = '사랑'

    # John 3 - born again
    if book == 'jn' and chapter == 3:
        selected_keywords = ['영생', '구원', '사랑']
        primary = '영생'
    elif book == 'jn' and chapter == 14:
        selected_keywords = ['평안', '진리', '성령']
        primary = '평안'
    elif book == 'jn' and chapter == 1:
        selected_keywords = ['은혜', '진리', '영광']
        primary = '은혜'
    elif book == 'jn' and chapter == 17:
        selected_keywords = ['영생', '진리', '사랑']
        primary = '진리'

    # Matthew special chapters
    elif book == 'mt' and chapter == 5:
        selected_keywords = ['겸손', '순종', '사랑']
        primary = '겸손'
    elif book == 'mt' and chapter in [26, 27]:
        selected_keywords = ['십자가', '대속', '구원']
        primary = '십자가'

    # Luke special chapters
    elif book == 'lk' and chapter == 2:
        selected_keywords = ['성탄', '기쁨', '찬양']
        primary = '성탄'
    elif book == 'lk' and chapter == 15:
        selected_keywords = ['회개', '용서', '사랑']
        primary = '회개'

    # Acts - Holy Spirit
    elif book == 'ac' and chapter == 2:
        selected_keywords = ['성령', '구원', '회개']
        primary = '성령'

    # Romans - faith and justification
    elif book == 'rm' and chapter in [3, 4]:
        selected_keywords = ['믿음', '구원', '은혜']
        primary = '믿음'
    elif book == 'rm' and chapter == 5:
        selected_keywords = ['은혜', '평안', '소망']
        primary = '은혜'
    elif book == 'rm' and chapter == 8:
        selected_keywords = ['성령', '사랑', '소망']
        primary = '성령'
    elif book == 'rm' and chapter == 12:
        selected_keywords = ['사랑', '겸손', '순종']
        primary = '사랑'

    # 1 Corinthians
    elif book == '1co' and chapter == 13:
        selected_keywords = ['사랑', '믿음', '소망']
        primary = '사랑'
    elif book == '1co' and chapter == 15:
        selected_keywords = ['부활', '영생', '소망']
        primary = '부활'

    # Galatians
    elif book == 'gl' and chapter == 5:
        selected_keywords = ['성령', '사랑', '기쁨']
        primary = '성령'

    # Ephesians - grace and unity
    elif book == 'ep' and chapter == 2:
        selected_keywords = ['은혜', '구원', '믿음']
        primary = '은혜'
    elif book == 'ep' and chapter in [4, 5]:
        selected_keywords = ['사랑', '순종', '감사']
        primary = '사랑'

    # Philippians - joy
    elif book == 'pp' and chapter == 2:
        selected_keywords = ['겸손', '순종', '사랑']
        primary = '겸손'
    elif book == 'pp' and chapter == 4:
        selected_keywords = ['기쁨', '평안', '감사']
        primary = '기쁨'

    # Colossians
    elif book == 'cl' and chapter == 3:
        selected_keywords = ['사랑', '감사', '평안']
        primary = '사랑'

    # Hebrews - faith
    elif book == 'hb' and chapter == 11:
        selected_keywords = ['믿음', '소망', '인내']
        primary = '믿음'
    elif book == 'hb' and chapter == 12:
        selected_keywords = ['인내', '거룩', '순종']
        primary = '인내'

    # James - faith and works
    elif book == 'jm' and chapter == 1:
        selected_keywords = ['지혜', '인내', '믿음']
        primary = '지혜'
    elif book == 'jm' and chapter == 5:
        selected_keywords = ['인내', '치유', '간구']
        primary = '인내'

    # 1 Peter
    elif book == '1pt' and chapter == 1:
        selected_keywords = ['소망', '거룩', '사랑']
        primary = '소망'

    # 1 John - love
    elif book == '1jn' and chapter in [1]:
        selected_keywords = ['회개', '진리', '사랑']
        primary = '회개'
    elif book == '1jn' and chapter == 4:
        selected_keywords = ['사랑', '믿음', '진리']
        primary = '사랑'

    # Revelation - worship
    elif book == 'rv' and chapter in [4, 5]:
        selected_keywords = ['찬양', '경배', '영광']
        primary = '찬양'
    elif book == 'rv' and chapter == 19:
        selected_keywords = ['할렐루야', '찬양', '영광']
        primary = '할렐루야'
    elif book == 'rv' and chapter in [21, 22]:
        selected_keywords = ['소망', '영생', '기쁨']
        primary = '소망'

    # If not a special case, analyze text content
    if not selected_keywords:
        keyword_scores = {}

        # Check for keyword mentions in text with word boundary consideration
        # Avoid matching Korean particles like "의" (possessive)
        for kw_name in KEYWORDS.keys():
            # Skip single-character keywords that are common particles
            if len(kw_name) == 1 and kw_name in ['의', '을', '를', '이', '가', '은', '는']:
                continue

            # Count exact matches in title and themes (most important)
            title_count = title.count(kw_name)
            theme_count = sum(1 for theme in themes if kw_name in theme)

            # Count in other texts with less weight
            other_count = summary.count(kw_name) + context.count(kw_name)

            if title_count > 0 or theme_count > 0 or other_count > 0:
                # Title mentions are most important
                keyword_scores[kw_name] = (title_count * 5) + (theme_count * 3) + (other_count * 1)

        # Common theological keywords based on context (only if explicitly mentioned)
        theological_keywords = {
            '사랑': ['사랑', '愛'],
            '믿음': ['믿음', '신앙', '신뢰'],
            '구원': ['구원', '구속', '구하', '救'],
            '은혜': ['은혜', '恩惠'],
            '거룩': ['거룩', '성결', '聖潔'],
            '회개': ['회개', '悔改', '돌이'],
            '찬양': ['찬양', '찬송', '찬미', '賛'],
            '간구': ['기도', '간구', '간청', '祈禱'],
            '감사': ['감사', '感謝'],
            '순종': ['순종', '順從', '복종'],
            '지혜': ['지혜', '智慧', '슬기'],
            '평안': ['평안', '평화', '平安'],
            '소망': ['소망', '희망', '盼望'],
            '겸손': ['겸손', '謙遜', '낮춤'],
            '용서': ['용서', '赦免', '사함'],
            '성령': ['성령', '聖靈', '영', '靈'],
        }

        for keyword, patterns in theological_keywords.items():
            if keyword in KEYWORDS:
                for pattern in patterns:
                    if pattern in all_text:
                        keyword_scores[keyword] = keyword_scores.get(keyword, 0) + 2
                        break

        # Sort by score and select top keywords
        if keyword_scores:
            sorted_keywords = sorted(keyword_scores.items(), key=lambda x: x[1], reverse=True)
            selected_keywords = [kw for kw, score in sorted_keywords[:5] if kw in KEYWORDS]
            if selected_keywords:
                primary = selected_keywords[0]

    # Filter to only valid keywords
    valid_keywords = [kw for kw in selected_keywords if kw in KEYWORDS]

    # If still no keywords, assign default based on book genre
    if not valid_keywords:
        if book == '시':
            valid_keywords = ['찬양', '기쁨']
            primary = '찬양'
        elif book in ['잠', '전', '욥']:
            valid_keywords = ['지혜']
            primary = '지혜'
        elif book in ['마', '막', '눅', '요']:
            valid_keywords = ['사랑', '구원']
            primary = '구원'
        elif book in ['롬', '고전', '고후', '갈', '엡', '빌', '골']:
            valid_keywords = ['믿음', '은혜']
            primary = '믿음'
        else:
            valid_keywords = ['믿음']
            primary = '믿음'

    # Ensure primary is in the list
    if primary and primary not in valid_keywords:
        valid_keywords.insert(0, primary)
    elif not primary and valid_keywords:
        primary = valid_keywords[0]

    return primary, valid_keywords[:5]  # Limit to 5 keywords

def insert_chapter_keywords(conn, book, chapter, primary_keyword, keywords):
    """Insert or update chapter keywords"""
    with conn.cursor() as cur:
        cur.execute("""
            INSERT INTO chapter_primary_keywords
                (book, chapter, keywords, primary_keyword, confidence_score, source, reviewed_by)
            VALUES (%s, %s, %s, %s, 10, 'claude_analysis', 'Claude 2025-10-16')
            ON CONFLICT (book, chapter)
            DO UPDATE SET
                keywords = EXCLUDED.keywords,
                primary_keyword = EXCLUDED.primary_keyword,
                confidence_score = EXCLUDED.confidence_score,
                source = EXCLUDED.source,
                reviewed_by = EXCLUDED.reviewed_by,
                updated_at = now()
        """, (book, chapter, keywords, primary_keyword))

def process_batch(conn, chapters_batch):
    """Process a batch of chapters"""
    results = []
    for book, chapter in chapters_batch:
        chapter_data = get_chapter_data(conn, book, chapter)
        if chapter_data:
            primary, keywords = analyze_keywords(chapter_data)
            if primary and keywords:
                insert_chapter_keywords(conn, book, chapter, primary, keywords)
                results.append({
                    'book': book,
                    'chapter': chapter,
                    'title': chapter_data['chapter_title'],
                    'primary': primary,
                    'keywords': keywords
                })
    return results

def get_all_chapters(conn):
    """Get all chapters with interpretation data in Bible book order"""
    with conn.cursor() as cur:
        cur.execute("""
            SELECT DISTINCT book, chapter
            FROM bible_verses
            WHERE verse = 1 AND chapter_title IS NOT NULL
            ORDER BY book, chapter
        """)
        all_chapters = cur.fetchall()

    # Sort by Bible book order
    def get_book_order(item):
        book, chapter = item
        try:
            return (BIBLE_BOOK_ORDER.index(book), chapter)
        except ValueError:
            return (999, chapter)  # Unknown books at the end

    sorted_chapters = sorted(all_chapters, key=get_book_order)
    return sorted_chapters

def main():
    print("=" * 80)
    print("Bible Chapter Keyword Assignment")
    print("=" * 80)
    print()

    # Connect to database
    conn = get_db_connection()
    print("Connected to database")

    # Load available keywords
    load_keywords(conn)
    print()

    # Get all chapters
    all_chapters = get_all_chapters(conn)
    total_chapters = len(all_chapters)
    print(f"Found {total_chapters} chapters with interpretation data")
    print()

    # Process in batches of 50
    batch_size = 50
    all_results = []
    keyword_stats = {}

    for i in range(0, total_chapters, batch_size):
        batch = all_chapters[i:i+batch_size]
        batch_num = i // batch_size + 1
        total_batches = (total_chapters + batch_size - 1) // batch_size

        # Get book range for this batch
        first_book, first_ch = batch[0]
        last_book, last_ch = batch[-1]

        print(f"Processing batch {batch_num}/{total_batches}: {first_book} {first_ch} - {last_book} {last_ch} ({len(batch)} chapters)")

        results = process_batch(conn, batch)
        all_results.extend(results)

        # Update statistics
        for result in results:
            for kw in result['keywords']:
                keyword_stats[kw] = keyword_stats.get(kw, 0) + 1

        # Commit after each batch
        conn.commit()
        print(f"  ✓ Completed {len(results)} chapters")
        print()

    print("=" * 80)
    print("FINAL REPORT")
    print("=" * 80)
    print()
    print(f"Total chapters analyzed: {len(all_results)}")
    print()

    print("Keyword Usage Statistics:")
    print("-" * 40)
    sorted_stats = sorted(keyword_stats.items(), key=lambda x: x[1], reverse=True)
    for kw, count in sorted_stats:
        print(f"  {kw:15s} : {count:4d} chapters")
    print()

    print("Notable Chapter Assignments:")
    print("-" * 40)
    notable_chapters = [
        ('창', 1, '천지창조'),
        ('출', 20, '십계명'),
        ('시', 23, '여호와는 나의 목자'),
        ('사', 53, '고난 받는 종'),
        ('요', 3, '거듭남과 영생'),
        ('롬', 8, '성령의 법'),
        ('고전', 13, '사랑의 장'),
        ('히', 11, '믿음의 장')
    ]

    for book, chapter, title in notable_chapters:
        result = next((r for r in all_results if r['book'] == book and r['chapter'] == chapter), None)
        if result:
            print(f"  {book} {chapter:3d} ({title:20s}): {result['primary']} - {', '.join(result['keywords'][:3])}")
    print()

    # Save detailed results to file
    output_file = '/workspace/bibleai/scripts/chapter_keywords_report.json'
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump({
            'total_chapters': len(all_results),
            'timestamp': datetime.now().isoformat(),
            'keyword_statistics': keyword_stats,
            'all_assignments': all_results
        }, f, ensure_ascii=False, indent=2)

    print(f"Detailed report saved to: {output_file}")
    print()

    # Close connection
    conn.close()
    print("✓ All chapters processed successfully!")
    print()

if __name__ == '__main__':
    try:
        main()
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        import traceback
        traceback.print_exc()
        sys.exit(1)
