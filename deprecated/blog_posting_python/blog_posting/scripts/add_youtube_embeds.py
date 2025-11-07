#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
블로그 JSON 파일에 유튜브 임베딩 추가하는 스크립트
"""

import json
import sys
import re
import subprocess

def get_youtube_video_id(search_query):
    """
    검색어로 유튜브 비디오 ID 가져오기
    """
    try:
        # bash 스크립트 실행
        result = subprocess.run(
            ['bash', '../archive/old_scripts/get_youtube_video_id.sh', search_query],
            capture_output=True,
            text=True,
            timeout=30
        )

        # 출력에서 비디오 ID 추출
        for line in result.stdout.split('\n'):
            if '찾은 비디오 ID:' in line:
                video_id = line.split(':')[1].strip()
                return video_id

        return None
    except Exception as e:
        print(f"⚠️  비디오 ID 검색 실패: {e}")
        return None

def add_youtube_embed_to_content(content):
    """
    content에서 찬송가 섹션을 찾아서 유튜브 임베딩 추가
    """
    # 찬송가 번호 추출 (예: "찬송가 325장" 또는 "찬송가 [번호]장")
    hymn_pattern = r'###\s+찬송가\s+(\d+)장[:\s]+(.*?)(?:\n|$)'
    matches = list(re.finditer(hymn_pattern, content))

    if not matches:
        print("⚠️  찬송가 섹션을 찾을 수 없습니다")
        return content

    # 각 찬송가에 대해 처리
    offset = 0
    for match in matches:
        hymn_number = match.group(1)
        hymn_title = match.group(2).strip()

        print(f"📝 찬송가 {hymn_number}장 처리 중...")

        # 이미 iframe이 있는지 확인
        section_start = match.start() + offset
        section_end = content.find('##', section_start + 10)
        if section_end == -1:
            section_end = len(content)

        section_content = content[section_start:section_end]

        if '<iframe' in section_content and 'youtube.com/embed/' in section_content:
            print(f"   ✅ 이미 임베딩이 있습니다")
            continue

        # 유튜브 비디오 ID 검색
        search_query = f"찬송가 {hymn_number}장 {hymn_title}"
        video_id = get_youtube_video_id(search_query)

        if not video_id:
            print(f"   ⚠️  비디오를 찾지 못했습니다")
            continue

        print(f"   ✅ 비디오 ID: {video_id}")

        # 임베딩 코드 생성
        embed_code = f'\n\n<div style="text-align: center; margin: 20px 0;">\n  <iframe width="560" height="315" src="https://www.youtube.com/embed/{video_id}" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>\n</div>\n'

        # 유튜브 링크 줄 다음에 임베딩 추가
        youtube_link_pattern = r'\*\*🎵\s+\[유튜브로.*?\]\(.*?\)\*\*'
        youtube_link_match = re.search(youtube_link_pattern, section_content)

        if youtube_link_match:
            insert_pos = section_start + youtube_link_match.end()
            content = content[:insert_pos] + embed_code + content[insert_pos:]
            offset += len(embed_code)
        else:
            print(f"   ⚠️  유튜브 링크를 찾지 못했습니다")

    return content

def main():
    """메인 실행 함수"""
    if len(sys.argv) < 2:
        print("사용법: python add_youtube_embeds.py <blog.json>")
        sys.exit(1)

    json_file = sys.argv[1]

    try:
        # JSON 파일 읽기
        with open(json_file, 'r', encoding='utf-8') as f:
            data = json.load(f)

        print(f"📖 파일 읽기: {json_file}")
        print(f"   제목: {data.get('title', 'N/A')}")
        print()

        # content에 유튜브 임베딩 추가
        if 'content' in data:
            original_content = data['content']
            updated_content = add_youtube_embed_to_content(original_content)

            if original_content != updated_content:
                data['content'] = updated_content

                # 파일 저장
                with open(json_file, 'w', encoding='utf-8') as f:
                    json.dump(data, f, ensure_ascii=False, indent=2)

                print()
                print(f"✅ 유튜브 임베딩이 추가되었습니다: {json_file}")
            else:
                print()
                print("ℹ️  변경사항이 없습니다")
        else:
            print("❌ content 필드를 찾을 수 없습니다")
            sys.exit(1)

    except FileNotFoundError:
        print(f"❌ 파일을 찾을 수 없습니다: {json_file}")
        sys.exit(1)
    except json.JSONDecodeError:
        print(f"❌ JSON 파일 형식이 잘못되었습니다: {json_file}")
        sys.exit(1)
    except Exception as e:
        print(f"❌ 오류 발생: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()
