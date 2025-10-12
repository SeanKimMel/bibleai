#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
찬송가 성경구절 스크레이핑 스크립트
hbible.co.kr에서 645개 찬송가의 성경구절 정보 수집
"""

import requests
from bs4 import BeautifulSoup
import time
import json
import re

def scrape_hymn_bible_reference(number):
    """특정 찬송가 번호의 성경구절 정보 가져오기"""
    url = f"https://www.hbible.co.kr/hb/hymn/view/{number}/"

    try:
        response = requests.get(url, timeout=10)
        response.raise_for_status()

        soup = BeautifulSoup(response.content, 'html.parser')
        text = soup.get_text()

        # 성경 구절 패턴 매칭 (우선순위 순서)
        # 한국어 성경책 이름 목록
        books = '창세기|출애굽기|레위기|민수기|신명기|여호수아|사사기|룻기|사무엘상|사무엘하|열왕기상|열왕기하|역대상|역대하|에스라|느헤미야|에스더|욥기|시편|잠언|전도서|아가|이사야|예레미야|예레미야애가|에스겔|다니엘|호세아|요엘|아모스|오바댜|요나|미가|나훔|하박국|스바냐|학개|스가랴|말라기|마태복음|마가복음|누가복음|요한복음|사도행전|로마서|고린도전서|고린도후서|갈라디아서|에베소서|빌립보서|골로새서|데살로니가전서|데살로니가후서|디모데전서|디모데후서|디도서|빌레몬서|히브리서|야고보서|베드로전서|베드로후서|요한1서|요한2서|요한3서|유다서|요한계시록'

        patterns = [
            # (요한계시록 4장 6~8절) 형식 (가장 구체적)
            (rf'\(({books})\s+(\d+)장\s+(\d+)(?:~|-)(\d+)절\)',
             lambda m: f"{m.group(1)} {m.group(2)}:{m.group(3)}-{m.group(4)}"),
            # (요한계시록 4장 6절) 형식
            (rf'\(({books})\s+(\d+)장\s+(\d+)절\)',
             lambda m: f"{m.group(1)} {m.group(2)}:{m.group(3)}"),
            # 시편 100편 형식
            (r'시편\s+(\d+)편',
             lambda m: f"시편 {m.group(1)}"),
            # 요한계시록 4:6-8 형식
            (rf'({books})\s+(\d+):(\d+)(?:-(\d+))?',
             lambda m: f"{m.group(1)} {m.group(2)}:{m.group(3)}" + (f"-{m.group(4)}" if m.group(4) else "")),
        ]

        for pattern, formatter in patterns:
            match = re.search(pattern, text)
            if match:
                result = formatter(match)
                # 중복된 책 이름 제거 (예: "시편 시편:100" -> "시편 100")
                # book_name이 결과에 두 번 나오는 경우 처리
                return result

        return None

    except requests.RequestException as e:
        print(f"  ⚠️  네트워크 오류 (찬송가 {number}번): {e}")
        return None
    except Exception as e:
        print(f"  ❌ 파싱 오류 (찬송가 {number}번): {e}")
        return None

def main():
    print("="*60)
    print("찬송가 성경구절 스크레이핑")
    print("="*60)
    print()

    results = {}
    success_count = 0
    fail_count = 0

    # 전체 모드 설정 (TEST_MODE = False로 변경하면 전체 645개 스크레이핑)
    TEST_MODE = False  # False로 변경하면 전체 스크레이핑

    if TEST_MODE:
        numbers = [1, 8, 305, 10, 50, 100, 200, 300, 400, 500]  # 테스트용
        print("🧪 테스트 모드: 샘플 찬송가만 스크레이핑")
        print(f"테스트 대상: {numbers}")
    else:
        numbers = range(1, 646)  # 전체 645개
        print("🚀 전체 모드: 645개 찬송가 스크레이핑")
        print("⏰ 예상 소요 시간: 약 15-20분")

    print()

    for number in numbers:
        print(f"📖 찬송가 {number}번 조회 중...")

        bible_ref = scrape_hymn_bible_reference(number)

        if bible_ref:
            results[number] = bible_ref
            success_count += 1
            print(f"  ✅ 성경구절: {bible_ref}")
        else:
            fail_count += 1
            print(f"  ❌ 성경구절 없음")

        print()

        # 서버 부하 방지를 위한 딜레이
        time.sleep(1)

    # 결과 저장
    output_file = '/workspace/bibleai/hymn_bible_references.json'
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(results, f, ensure_ascii=False, indent=2)

    print("-"*60)
    print(f"📊 처리 결과:")
    print(f"   ✅ 성공: {success_count}개")
    print(f"   ❌ 실패: {fail_count}개")
    print(f"   📁 저장 위치: {output_file}")
    print()
    print("💡 테스트 결과 확인 후 전체 645개 스크레이핑 진행하세요.")
    print("="*60)

if __name__ == '__main__':
    main()
