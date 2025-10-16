#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Gemini API를 사용한 블로그 콘텐츠 생성 스크립트
"""

import os
import json
import time
import re
import requests
from datetime import datetime
from dotenv import load_dotenv
from urllib.parse import quote_plus

# .env 파일에서 환경변수 로드
load_dotenv()

# 설정
GEMINI_API_KEY = os.getenv("GEMINI_API_KEY")
GEMINI_API_URL = "https://generativelanguage.googleapis.com/v1/models/gemini-2.5-flash:generateContent"

# 한국어 요일 매핑
WEEKDAYS_KR = ["월요일", "화요일", "수요일", "목요일", "금요일", "토요일", "일요일"]

def load_prompt_template(template_path):
    """프롬프트 템플릿 파일 로드"""
    try:
        with open(template_path, 'r', encoding='utf-8') as f:
            return f.read()
    except FileNotFoundError:
        raise Exception(f"프롬프트 파일을 찾을 수 없습니다: {template_path}")

def render_prompt(template, data):
    """템플릿에 변수 치환"""
    prompt = template
    for key, value in data.items():
        placeholder = f"{{{{{key}}}}}"
        prompt = prompt.replace(placeholder, str(value))
    return prompt

def call_gemini_api(prompt, max_retries=3):
    """
    Gemini API 호출

    Args:
        prompt: 생성 요청 프롬프트
        max_retries: 최대 재시도 횟수

    Returns:
        API 응답 텍스트
    """
    if not GEMINI_API_KEY:
        raise Exception("GEMINI_API_KEY가 설정되지 않았습니다. .env 파일을 확인하세요.")

    headers = {
        "Content-Type": "application/json"
    }

    request_data = {
        "contents": [{
            "parts": [{
                "text": prompt
            }],
            "role": "user"
        }],
        "generationConfig": {
            "temperature": 0.7,
            "topP": 0.95,
            "maxOutputTokens": 8192
        }
    }

    for attempt in range(max_retries):
        try:
            # API 키를 URL 파라미터로 전달
            url = f"{GEMINI_API_URL}?key={GEMINI_API_KEY}"

            response = requests.post(
                url,
                headers=headers,
                json=request_data,
                timeout=60
            )

            # 에러 처리
            if response.status_code == 401:
                raise Exception("Gemini API 인증 실패. API 키를 확인하세요.")
            elif response.status_code == 429:
                wait_time = (2 ** attempt) * 2  # 지수 백오프
                print(f"⚠️  API 할당량 초과. {wait_time}초 후 재시도... ({attempt + 1}/{max_retries})")
                time.sleep(wait_time)
                continue
            elif response.status_code >= 500:
                wait_time = (2 ** attempt) * 2
                print(f"⚠️  서버 오류 발생. {wait_time}초 후 재시도... ({attempt + 1}/{max_retries})")
                time.sleep(wait_time)
                continue

            response.raise_for_status()

            # 응답 파싱
            result = response.json()

            if 'candidates' not in result or len(result['candidates']) == 0:
                raise Exception("API 응답에 candidates가 없습니다.")

            # 텍스트 추출
            content = result['candidates'][0]['content']['parts'][0]['text']

            # ```json ... ``` 코드 블록 제거
            content = content.strip()
            if content.startswith('```json'):
                content = content[7:]  # ```json 제거
            if content.startswith('```'):
                content = content[3:]  # ``` 제거
            if content.endswith('```'):
                content = content[:-3]  # ``` 제거
            content = content.strip()

            return content

        except requests.exceptions.Timeout:
            print(f"⚠️  요청 타임아웃. 재시도... ({attempt + 1}/{max_retries})")
            if attempt < max_retries - 1:
                time.sleep(2 ** attempt)
        except requests.exceptions.RequestException as e:
            print(f"⚠️  API 요청 실패: {e}")
            if attempt < max_retries - 1:
                time.sleep(2 ** attempt)
        except Exception as e:
            raise Exception(f"API 호출 중 오류: {e}")

    raise Exception(f"최대 재시도 횟수({max_retries})를 초과했습니다.")

def generate_blog_content(data):
    """
    블로그 콘텐츠 생성

    Args:
        data: 블로그 생성에 필요한 데이터
            - keyword: 키워드
            - date: 날짜 (YYYY-MM-DD)
            - bible_verses: 성경 구절 데이터
            - hymns: 찬송가 데이터
            - prayers: 기도문 데이터

    Returns:
        생성된 블로그 콘텐츠 (JSON 파싱됨)
    """
    # 날짜 정보 생성
    date_obj = datetime.strptime(data['date'], '%Y-%m-%d')
    day_of_week = WEEKDAYS_KR[date_obj.weekday()]
    current_month = date_obj.month

    # slug 생성 (날짜-키워드 형식)
    slug = f"{data['date']}-{data['keyword']}"

    # 프롬프트 데이터 준비
    prompt_data = {
        'date': data['date'],
        'day_of_week': day_of_week,
        'keyword': data['keyword'],
        'current_month': current_month,
        'slug': slug,
        'bible_verses': json.dumps(data.get('bible_verses', []), ensure_ascii=False, indent=2),
        'hymns': json.dumps(data.get('hymns', []), ensure_ascii=False, indent=2),
        'prayers': json.dumps(data.get('prayers', []), ensure_ascii=False, indent=2)
    }

    # 프롬프트 로드 및 렌더링
    template_path = os.path.join(
        os.path.dirname(__file__),
        '..',
        'prompts',
        'blog_generation.txt'
    )
    template = load_prompt_template(template_path)
    prompt = render_prompt(template, prompt_data)

    # API 호출
    print(f"📝 블로그 생성 중... (키워드: {data['keyword']}, 날짜: {data['date']})")
    response_text = call_gemini_api(prompt)

    # JSON 파싱
    try:
        content = json.loads(response_text)
        print(f"✅ 블로그 생성 완료!")
        return content
    except json.JSONDecodeError as e:
        print(f"❌ JSON 파싱 실패: {e}")
        print(f"응답 내용: {response_text[:500]}...")
        raise Exception("API 응답이 유효한 JSON이 아닙니다.")

def get_youtube_video_id(search_query):
    """
    YouTube 검색으로 비디오 ID 가져오기
    """
    try:
        encoded_query = quote_plus(search_query)
        search_url = f"https://www.youtube.com/results?search_query={encoded_query}"

        headers = {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'
        }

        response = requests.get(search_url, headers=headers, timeout=10)
        html = response.text

        # 비디오 ID 추출
        patterns = [
            r'"videoId":"([a-zA-Z0-9_-]{11})"',
            r'/watch\?v=([a-zA-Z0-9_-]{11})',
        ]

        for pattern in patterns:
            matches = re.findall(pattern, html)
            if matches:
                return matches[0]

        return None
    except:
        return None

def add_youtube_embeds(content):
    """
    찬송가 섹션에 YouTube 임베딩 추가
    """
    # 찬송가 섹션 찾기: ### 찬송가 N장 부터 다음 ## 또는 ``` 까지
    hymn_sections = []
    hymn_pattern = r'(### 찬송가 (\d+)장[:\s]+.*?)(\n```|\n##)'

    for match in re.finditer(hymn_pattern, content, re.DOTALL):
        section_text = match.group(1)
        hymn_number = match.group(2)
        section_end = match.group(3)

        # 이미 iframe이 있으면 스킵
        if '<iframe' in section_text and 'youtube.com/embed/' in section_text:
            continue

        print(f"   🎵 찬송가 {hymn_number}장 유튜브 검색 중...")
        video_id = get_youtube_video_id(f"찬송가 {hymn_number}장")

        if video_id:
            print(f"      ✅ 비디오 ID: {video_id}")

            # iframe 코드 생성
            embed_code = f'\n\n<div style="text-align: center; margin: 20px 0;">\n  <iframe width="560" height="315" src="https://www.youtube.com/embed/{video_id}" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>\n</div>\n'

            # 유튜브 링크 줄 다음에 iframe 추가
            # 패턴: **🎵 [유튜브로 듣기](...) (끝에 별표가 있을 수도 있고 없을 수도 있음)
            youtube_link_pattern = r'(\*\*🎵\s+\[유튜브로.*?\]\(.*?\)(?:\*\*)?)'

            if re.search(youtube_link_pattern, section_text):
                new_section = re.sub(
                    youtube_link_pattern,
                    r'\1' + embed_code,
                    section_text,
                    count=1
                )

                # content에서 원본 섹션을 새 섹션으로 교체
                content = content.replace(section_text, new_section)
            else:
                print(f"      ⚠️  유튜브 링크를 찾을 수 없습니다")
        else:
            print(f"      ⚠️  비디오를 찾지 못했습니다")

    return content

def save_blog_to_file(content, output_path):
    """생성된 블로그를 JSON 파일로 저장"""
    try:
        # YouTube 임베딩 추가
        print(f"🎬 YouTube 임베딩 추가 중...")
        if 'content' in content:
            content['content'] = add_youtube_embeds(content['content'])

        with open(output_path, 'w', encoding='utf-8') as f:
            json.dump(content, f, ensure_ascii=False, indent=2)
        print(f"💾 블로그 저장 완료: {output_path}")
    except Exception as e:
        raise Exception(f"파일 저장 중 오류: {e}")

def main():
    """메인 실행 함수"""
    import sys

    # 명령줄 인자로 데이터 파일과 출력 파일 경로를 받음
    if len(sys.argv) < 3:
        print("사용법: python generate_blog.py <data.json> <output.json>")
        sys.exit(1)

    data_file = sys.argv[1]
    output_file = sys.argv[2]

    try:
        # 데이터 파일 로드
        with open(data_file, 'r', encoding='utf-8') as f:
            data = json.load(f)

        # 블로그 생성
        content = generate_blog_content(data)

        # 파일로 저장
        output_dir = os.path.dirname(output_file)
        if output_dir:
            os.makedirs(output_dir, exist_ok=True)

        save_blog_to_file(content, output_file)

        print("\n🎉 모든 작업 완료!")

    except FileNotFoundError:
        print(f"❌ 파일을 찾을 수 없습니다: {data_file}")
        sys.exit(1)
    except json.JSONDecodeError:
        print(f"❌ JSON 파일 형식이 잘못되었습니다: {data_file}")
        sys.exit(1)
    except Exception as e:
        print(f"\n❌ 오류 발생: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()
