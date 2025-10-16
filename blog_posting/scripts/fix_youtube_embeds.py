#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
기존 블로그 파일에 YouTube 임베딩 추가
"""

import sys
import os
sys.path.insert(0, os.path.dirname(__file__))

from generate_blog import add_youtube_embeds
import json

def main():
    if len(sys.argv) < 2:
        print("사용법: python fix_youtube_embeds.py <blog.json>")
        sys.exit(1)

    json_file = sys.argv[1]

    try:
        with open(json_file, 'r', encoding='utf-8') as f:
            data = json.load(f)

        print(f"📖 파일: {json_file}")
        print(f"   제목: {data.get('title', 'N/A')}")
        print()
        print("🎬 YouTube 임베딩 추가 중...")

        if 'content' in data:
            data['content'] = add_youtube_embeds(data['content'])

            with open(json_file, 'w', encoding='utf-8') as f:
                json.dump(data, f, ensure_ascii=False, indent=2)

            print()
            print(f"✅ 완료: {json_file}")
        else:
            print("❌ content 필드를 찾을 수 없습니다")
            sys.exit(1)

    except Exception as e:
        print(f"❌ 오류: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)

if __name__ == "__main__":
    main()
