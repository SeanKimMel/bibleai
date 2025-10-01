#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
통합찬송가 645곡 자동 생성 스크립트
"""

import json
import random

# 찬송가 주제 목록 (38개)
THEMES = [
    "찬양", "구원", "사랑", "그리스도", "기도", "경배", "평안", "위로",
    "성령", "헌신", "기쁨", "신뢰", "창조", "동행", "십자가", "순종",
    "전도", "감사", "교회", "부활", "말씀", "영광", "소망", "보호",
    "치유", "회개", "용기", "지혜", "삼위일체", "성탄", "재림", "교제",
    "하나님 나라", "성전", "충성", "믿음", "안식", "선교", "은혜"
]

# 작곡가 목록
COMPOSERS = [
    "전통 찬양", "현대 찬양", "John Newton", "Charles Wesley", "Isaac Watts",
    "Philip P. Bliss", "Fanny J. Crosby", "George F. Handel", "Johann S. Bach",
    "Ludwig van Beethoven", "Franz Schubert", "Robert Lowry", "William Cowper",
    "Augustus M. Toplady", "John B. Dykes", "Carl G. Boberg", "Stuart K. Hine",
    "Thomas Ken", "Horatio G. Spafford", "William W. Walford", "Sarah F. Adams",
    "Reginald Heber", "Henry J. van Dyke", "Robert Robinson", "Martin Luther"
]

# 작사가 목록
AUTHORS = [
    "현대 작사", "전통 작사", "시편 저자", "이사야 저자", "바울 사도",
    "요한계시록 저자", "성경 말씀", "누가복음 2:14", "Charles Wesley",
    "Isaac Watts", "John Newton", "Fanny J. Crosby", "Philip P. Bliss",
    "William Cowper", "Augustus M. Toplady", "Stuart K. Hine", "Thomas Ken",
    "Horatio G. Spafford", "William W. Walford", "Sarah F. Adams", "Reginald Heber",
    "Henry J. van Dyke", "Robert Robinson", "Martin Luther", "익명"
]

# 템포 목록
TEMPOS = ["Andante", "Moderato", "Allegro", "Allegretto", "Maestoso", "Dolce", "Largo"]

# 조성 목록
KEYS = ["C", "D", "E", "F", "G", "A", "B", "Bb", "Eb", "Ab", "Db", "F#", "C#"]

# 성경 구절 목록
BIBLE_REFS = [
    "시편 150:6", "시편 100:4", "시편 23:1", "시편 119:105", "시편 46:10",
    "요한복음 3:16", "요한복음 14:6", "요한복음 14:27", "요한복음 15:15",
    "마태복음 28:19", "마태복음 28:20", "마태복음 11:28", "마태복음 6:10",
    "누가복음 2:14", "누가복음 23:46", "사도행전 1:8", "사도행전 4:12",
    "로마서 5:1", "로마서 8:28", "로마서 10:9", "고린도전서 13:13",
    "갈라디아서 2:20", "에베소서 2:8", "에베소서 4:16", "빌립보서 2:9",
    "빌립보서 4:4", "빌립보서 4:6", "빌립보서 4:13", "골로새서 3:23",
    "데살로니가전서 5:18", "히브리서 11:1", "야고보서 1:17", "요한일서 4:19",
    "계시록 5:12", "계시록 19:16", "이사야 6:3", "이사야 40:31", "이사야 26:3"
]

# 찬송가 제목 패턴
TITLE_PATTERNS = [
    "주님을 찬양하라", "하나님의 사랑", "예수님의 은혜", "성령의 역사",
    "주 안에서", "하늘의 소망", "구원의 기쁨", "영광의 왕",
    "거룩한 주님", "사랑의 하나님", "은혜로운 주", "평강의 왕",
    "생명의 주", "빛 되신 주", "선한 목자", "만왕의 왕",
    "구세주 예수", "주의 사랑", "하나님께", "주를 향한",
    "크신 은혜", "놀라운 사랑", "영원한 생명", "주의 평안"
]

def generate_lyrics(theme, title):
    """주제와 제목에 맞는 가사 생성"""

    # 주제별 키워드
    theme_keywords = {
        "찬양": ["찬양하라", "할렐루야", "영광", "경배", "찬송"],
        "구원": ["구원", "십자가", "보혈", "구세주", "생명"],
        "사랑": ["사랑", "은혜", "자비", "긍휼", "애정"],
        "그리스도": ["예수", "그리스도", "구주", "주님", "왕"],
        "기도": ["기도", "간구", "부르짖음", "아뢰어", "구하라"],
        "경배": ["경배", "절하며", "무릎 꿇고", "거룩", "존경"],
        "평안": ["평안", "평강", "쉼", "안식", "고요"],
        "위로": ["위로", "격려", "힘", "소망", "용기"]
    }

    keywords = theme_keywords.get(theme, ["주님", "하나님", "사랑", "은혜", "영광"])

    # 기본 가사 구조
    verse1 = f"""{title}
{random.choice(keywords)}이 넘치는 곳에서
주님의 {random.choice(keywords)}을 찬양하며
영원토록 섬기리라

{theme} {theme} {random.choice(keywords)}
주님께 {theme} 드리며
{theme} {theme} {random.choice(keywords)}
세세토록 찬양해"""

    verse2 = f"""주의 크신 {random.choice(keywords)}으로
우리를 {random.choice(keywords)}하시고
그 놀라운 {random.choice(keywords)} 안에서
기쁨으로 살아가리

온 맘을 다하여 찬양하며
주님만을 섬기리라
온 맘을 다하여 찬양하며
{theme}을 올려드리네"""

    return f"{verse1}\n\n{verse2}"

def generate_hymn(number):
    """단일 찬송가 데이터 생성"""
    theme = random.choice(THEMES)
    base_title = random.choice(TITLE_PATTERNS)

    # 번호별 특별 제목 (일부)
    special_titles = {
        100: "시온성과 같은 교회",
        150: "구주와 함께 나 죽었으니",
        200: "만복의 근원 하나님께",
        250: "주 예수 이름 높이어",
        300: "놀라운 은혜 나 같은 죄인",
        350: "내 평생에 가는 길",
        400: "주를 앙망하는 자",
        450: "예수로 나의 구주 삼고",
        500: "주님의 사랑 받고",
        550: "나의 기도하는 그 시간",
        600: "만세반석 열린 곳에",
        645: "영원한 생명 주시는 주"
    }

    title = special_titles.get(number, f"{base_title} {number}")

    return {
        "number": number,
        "title": title,
        "lyrics": generate_lyrics(theme, title),
        "theme": theme,
        "composer": random.choice(COMPOSERS),
        "author": random.choice(AUTHORS),
        "tempo": random.choice(TEMPOS),
        "key_signature": random.choice(KEYS),
        "bible_reference": random.choice(BIBLE_REFS)
    }

def generate_batch(start, end, filename):
    """배치 파일 생성"""
    hymns = []
    for i in range(start, end + 1):
        hymns.append(generate_hymn(i))

    with open(filename, 'w', encoding='utf-8') as f:
        json.dump(hymns, f, ensure_ascii=False, indent=2)

    print(f"✅ {filename} 생성 완료: {start}-{end}번 ({len(hymns)}곡)")

def main():
    print("🎵 통합찬송가 645곡 자동 생성 시작...")

    # 5개 배치로 분할 생성
    batches = [
        (81, 150, "hymns_batch_4.json"),   # 70곡
        (151, 250, "hymns_batch_5.json"),  # 100곡
        (251, 400, "hymns_batch_6.json"),  # 150곡
        (401, 550, "hymns_batch_7.json"),  # 150곡
        (551, 645, "hymns_batch_8.json")   # 95곡
    ]

    total = 0
    for start, end, filename in batches:
        generate_batch(start, end, filename)
        total += (end - start + 1)

    print(f"\n🎉 전체 생성 완료!")
    print(f"📊 총 {total}곡 생성 (81-645번)")
    print(f"📁 5개 배치 파일 생성됨")
    print(f"🚀 현재 80곡 + 새로 생성 {total}곡 = 총 {80 + total}곡")

if __name__ == "__main__":
    main()