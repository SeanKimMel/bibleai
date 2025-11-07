#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
YouTube에서 찬송가 비디오 ID 검색
"""

import re
import sys
import requests
from urllib.parse import quote_plus

def get_youtube_video_id(search_query):
    """
    YouTube 검색으로 비디오 ID 가져오기
    """
    try:
        # URL 인코딩
        encoded_query = quote_plus(search_query)
        search_url = f"https://www.youtube.com/results?search_query={encoded_query}"

        # User-Agent 헤더 추가 (필수)
        headers = {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'
        }

        print(f"🔍 검색 중: {search_query}")
        print(f"   URL: {search_url}")

        # 검색 결과 가져오기
        response = requests.get(search_url, headers=headers, timeout=10)
        html = response.text

        # 여러 패턴으로 비디오 ID 추출 시도
        patterns = [
            r'"videoId":"([a-zA-Z0-9_-]{11})"',
            r'/watch\?v=([a-zA-Z0-9_-]{11})',
            r'watch\?v=([a-zA-Z0-9_-]{11})'
        ]

        for pattern in patterns:
            matches = re.findall(pattern, html)
            if matches:
                # 첫 번째 결과 반환
                video_id = matches[0]
                print(f"   ✅ 비디오 ID 발견: {video_id}")
                return video_id

        print(f"   ❌ 비디오를 찾을 수 없습니다")
        return None

    except Exception as e:
        print(f"   ❌ 오류: {e}")
        return None

def main():
    if len(sys.argv) < 2:
        print("사용법: python get_youtube_id.py \"찬송가 305장\"")
        sys.exit(1)

    search_query = sys.argv[1]
    video_id = get_youtube_video_id(search_query)

    if video_id:
        print()
        print(f"일반 URL: https://www.youtube.com/watch?v={video_id}")
        print(f"임베드 URL: https://www.youtube.com/embed/{video_id}")
        print()
        print("📝 임베드 코드:")
        print('<div style="text-align: center; margin: 20px 0;">')
        print(f'  <iframe width="560" height="315" src="https://www.youtube.com/embed/{video_id}" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>')
        print('</div>')
        sys.exit(0)
    else:
        print()
        print("❌ 비디오 ID를 찾을 수 없습니다")
        sys.exit(1)

if __name__ == "__main__":
    main()
