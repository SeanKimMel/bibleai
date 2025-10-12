#!/usr/bin/env python3
"""
wiki.michaelhan.net에서 찬송가 645곡의 작사가, 작곡가 정보를 스크래핑하는 스크립트
"""

import requests
from bs4 import BeautifulSoup
import json
import time
import sys

def scrape_hymns_data():
    """wiki.michaelhan.net에서 찬송가 데이터 스크래핑"""

    url = "https://wiki.michaelhan.net/찬송가_목록"

    print(f"🌐 데이터 수집 중: {url}")

    try:
        # 웹 페이지 가져오기
        headers = {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
        }
        response = requests.get(url, headers=headers, timeout=30)
        response.raise_for_status()
        response.encoding = 'utf-8'

        # HTML 파싱
        soup = BeautifulSoup(response.text, 'html.parser')

        # 테이블 찾기
        table = soup.find('table', {'class': 'wikitable'})
        if not table:
            print("❌ 테이블을 찾을 수 없습니다.")
            return None

        hymns_data = []
        rows = table.find_all('tr')[1:]  # 헤더 제외

        print(f"📊 총 {len(rows)}개의 행 발견")

        for idx, row in enumerate(rows, 1):
            cols = row.find_all('td')
            if len(cols) < 7:  # 최소 7개 컬럼 필요
                continue

            try:
                # 데이터 추출
                # 컬럼 순서: 새찬송, 구찬송, 한글제목, 영어제목, 분류大, 분류小, 작시자, 작시연대, 속도, 곡조명, 운율, 작곡자, 작곡연대
                number = cols[0].get_text(strip=True)
                if not number.isdigit():
                    continue

                number = int(number)
                title_korean = cols[2].get_text(strip=True)
                title_english = cols[3].get_text(strip=True) if len(cols) > 3 else ""
                theme_major = cols[4].get_text(strip=True) if len(cols) > 4 else ""  # 분류大
                theme_minor = cols[5].get_text(strip=True) if len(cols) > 5 else ""  # 분류小
                lyricist = cols[6].get_text(strip=True) if len(cols) > 6 else ""      # 작시자
                lyricist_year = cols[7].get_text(strip=True) if len(cols) > 7 else ""  # 작시 연대
                tempo = cols[8].get_text(strip=True) if len(cols) > 8 else ""         # 속도
                tune_name = cols[9].get_text(strip=True) if len(cols) > 9 else ""     # 곡조명
                meter = cols[10].get_text(strip=True) if len(cols) > 10 else ""       # 운율
                composer = cols[11].get_text(strip=True) if len(cols) > 11 else ""    # 작곡자
                composer_year = cols[12].get_text(strip=True) if len(cols) > 12 else ""  # 작곡 연대

                # 주제 결합 (분류大 + 분류小)
                theme = f"{theme_major}/{theme_minor}" if theme_major and theme_minor else (theme_major or theme_minor)

                hymn_info = {
                    'number': number,
                    'title_korean': title_korean,
                    'title_english': title_english,
                    'theme': theme,
                    'lyricist': lyricist,
                    'lyricist_year': lyricist_year,
                    'composer': composer,
                    'composer_year': composer_year,
                    'tempo': tempo,
                    'tune_name': tune_name,
                    'meter': meter
                }

                hymns_data.append(hymn_info)

                if idx % 50 == 0:
                    print(f"  진행 중... {idx}/{len(rows)}")

            except Exception as e:
                print(f"⚠️  행 {idx} 처리 중 오류: {e}")
                continue

        print(f"✅ 총 {len(hymns_data)}곡 수집 완료")
        return hymns_data

    except requests.RequestException as e:
        print(f"❌ 웹 요청 오류: {e}")
        return None
    except Exception as e:
        print(f"❌ 예상치 못한 오류: {e}")
        return None

def save_to_json(data, output_path):
    """수집한 데이터를 JSON 파일로 저장"""
    try:
        with open(output_path, 'w', encoding='utf-8') as f:
            json.dump(data, f, ensure_ascii=False, indent=2)
        print(f"💾 JSON 파일 저장 완료: {output_path}")
        return True
    except Exception as e:
        print(f"❌ 파일 저장 오류: {e}")
        return False

def generate_update_sql(hymns_data, output_sql_path):
    """수집한 데이터로 UPDATE SQL 생성"""
    try:
        with open(output_sql_path, 'w', encoding='utf-8') as f:
            f.write("-- Migration: 찬송가 작사가, 작곡가 정보 업데이트\n")
            f.write("-- 데이터 소스: wiki.michaelhan.net\n")
            f.write(f"-- 생성일: {time.strftime('%Y-%m-%d %H:%M:%S')}\n\n")

            f.write("BEGIN;\n\n")

            # 각 찬송가에 대해 UPDATE 문 생성
            for hymn in hymns_data:
                number = hymn['number']
                title = hymn['title_korean'].replace("'", "''")
                composer = hymn.get('composer', '').replace("'", "''")
                lyricist = hymn.get('lyricist', '').replace("'", "''")
                theme = hymn.get('theme', '').replace("'", "''")
                tempo = hymn.get('tempo', '').replace("'", "''")

                # 빈 문자열 처리 (未知, 無名, - 등은 NULL 처리)
                composer_val = f"'{composer}'" if composer and composer not in ['-', '未知', '無名', ''] else 'NULL'
                lyricist_val = f"'{lyricist}'" if lyricist and lyricist not in ['-', '未知', '無名', ''] else 'NULL'
                theme_val = f"'{theme}'" if theme and theme not in ['-', ''] else 'NULL'
                tempo_val = f"'{tempo}'" if tempo and tempo not in ['-', ''] else 'NULL'

                f.write(f"""UPDATE hymns SET
    title = '{title}',
    composer = {composer_val},
    author = {lyricist_val},
    theme = {theme_val},
    tempo = {tempo_val},
    updated_at = NOW()
WHERE number = {number};

""")

            f.write("COMMIT;\n\n")

            f.write("-- 업데이트 결과 확인\n")
            f.write("""SELECT
    COUNT(*) as total_hymns,
    COUNT(composer) as has_composer,
    COUNT(author) as has_author,
    COUNT(theme) as has_theme,
    COUNT(tempo) as has_tempo
FROM hymns;

-- 샘플 데이터 확인
SELECT number, title, composer, author, theme, tempo
FROM hymns
WHERE number IN (1, 50, 100, 200, 300, 400, 500, 645)
ORDER BY number;
""")

        print(f"📝 SQL 파일 생성 완료: {output_sql_path}")
        return True

    except Exception as e:
        print(f"❌ SQL 생성 오류: {e}")
        return False

if __name__ == "__main__":
    print("=" * 60)
    print("찬송가 데이터 스크래핑 시작")
    print("=" * 60)

    # 데이터 스크래핑
    hymns_data = scrape_hymns_data()

    if not hymns_data:
        print("❌ 데이터 수집 실패")
        sys.exit(1)

    # JSON 저장
    json_output = "/workspace/bibleai/hymns_complete_data.json"
    if not save_to_json(hymns_data, json_output):
        sys.exit(1)

    # SQL 생성
    sql_output = "/workspace/bibleai/migrations/008_update_hymns_complete.sql"
    if not generate_update_sql(hymns_data, sql_output):
        sys.exit(1)

    print("\n" + "=" * 60)
    print("✅ 모든 작업 완료!")
    print(f"   - JSON: {json_output}")
    print(f"   - SQL:  {sql_output}")
    print("=" * 60)

    sys.exit(0)
