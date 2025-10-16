#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Gemini API를 사용한 블로그 콘텐츠 품질 평가 스크립트
"""

import os
import json
import sys
from dotenv import load_dotenv
from generate_blog import load_prompt_template, render_prompt, call_gemini_api

# .env 파일에서 환경변수 로드
load_dotenv()

# 설정
QUALITY_THRESHOLD = float(os.getenv("QUALITY_THRESHOLD", "7.0"))

def evaluate_content(content):
    """
    생성된 블로그 콘텐츠를 평가

    Args:
        content: 평가할 블로그 콘텐츠 (dict)

    Returns:
        평가 결과 (JSON 파싱됨)
    """
    # 평가 프롬프트 로드
    template_path = os.path.join(
        os.path.dirname(__file__),
        '..',
        'prompts',
        'quality_evaluation.txt'
    )
    template = load_prompt_template(template_path)

    # 평가할 콘텐츠를 JSON 문자열로 변환
    content_json = json.dumps(content, ensure_ascii=False, indent=2)

    # 프롬프트 렌더링
    prompt_data = {
        'generated_content': content_json
    }
    prompt = render_prompt(template, prompt_data)

    # API 호출
    print(f"\n📊 콘텐츠 품질 평가 중...")
    response_text = call_gemini_api(prompt)

    # JSON 파싱
    try:
        evaluation = json.loads(response_text)
        print(f"✅ 평가 완료!")
        return evaluation
    except json.JSONDecodeError as e:
        print(f"❌ JSON 파싱 실패: {e}")
        print(f"응답 내용: {response_text[:500]}...")
        raise Exception("API 응답이 유효한 JSON이 아닙니다.")

def print_evaluation_summary(evaluation):
    """평가 결과를 보기 좋게 출력"""
    print("\n" + "="*60)
    print("📈 평가 결과 요약")
    print("="*60)

    # 점수 출력
    scores = evaluation.get('scores', {})
    print("\n📊 항목별 점수:")
    print(f"  - 신학적 정확성: {scores.get('theological_accuracy', 0)}/10")
    print(f"  - 콘텐츠 구조: {scores.get('content_structure', 0)}/10")
    print(f"  - 독자 참여도: {scores.get('engagement', 0)}/10")
    print(f"  - 기술적 품질: {scores.get('technical_quality', 0)}/10")
    print(f"  - SEO 최적화: {scores.get('seo_optimization', 0)}/10")

    # 가중치 적용 점수
    weighted = evaluation.get('weighted_breakdown', {})
    print("\n⚖️  가중치 적용 점수:")
    print(f"  - 신학적 정확성 (30%): {weighted.get('theological_accuracy', 0):.2f}")
    print(f"  - 콘텐츠 구조 (25%): {weighted.get('content_structure', 0):.2f}")
    print(f"  - 독자 참여도 (20%): {weighted.get('engagement', 0):.2f}")
    print(f"  - 기술적 품질 (15%): {weighted.get('technical_quality', 0):.2f}")
    print(f"  - SEO 최적화 (10%): {weighted.get('seo_optimization', 0):.2f}")

    # 총점
    total_score = evaluation.get('total_score', 0)
    print(f"\n🎯 총점: {total_score:.1f}/10.0")
    print(f"   최소 기준: {QUALITY_THRESHOLD}/10.0")

    # 피드백
    feedback = evaluation.get('feedback', {})

    if feedback.get('strengths'):
        print("\n✅ 장점:")
        for strength in feedback['strengths']:
            print(f"  • {strength}")

    if feedback.get('improvements'):
        print("\n📝 개선사항:")
        for improvement in feedback['improvements']:
            print(f"  • {improvement}")

    if feedback.get('critical_issues'):
        print("\n🚨 치명적 문제:")
        for issue in feedback['critical_issues']:
            print(f"  • {issue}")

    # 권장사항
    recommendation = evaluation.get('recommendation', 'unknown')
    confidence = evaluation.get('confidence', 'unknown')

    print(f"\n💡 권장사항: {recommendation}")
    print(f"   신뢰도: {confidence}")

    print("="*60 + "\n")

def should_publish(evaluation):
    """
    발행 여부 판단

    Args:
        evaluation: 평가 결과

    Returns:
        (should_publish: bool, reason: str)
    """
    total_score = evaluation.get('total_score', 0)
    scores = evaluation.get('scores', {})
    feedback = evaluation.get('feedback', {})
    recommendation = evaluation.get('recommendation', 'reject')

    # 치명적 문제 체크
    if feedback.get('critical_issues'):
        return False, f"치명적 문제 발견: {len(feedback['critical_issues'])}개"

    # 필수 통과 기준 체크
    theological_accuracy = scores.get('theological_accuracy', 0)
    technical_quality = scores.get('technical_quality', 0)

    if theological_accuracy < 6.0:
        return False, f"신학적 정확성 미달: {theological_accuracy}/10 (최소 6.0 필요)"

    if technical_quality < 7.0:
        return False, f"기술적 품질 미달: {technical_quality}/10 (최소 7.0 필요)"

    # 총점 체크
    if total_score < QUALITY_THRESHOLD:
        return False, f"총점 미달: {total_score:.1f}/10 (최소 {QUALITY_THRESHOLD} 필요)"

    # 권장사항 체크
    if recommendation != "publish":
        return False, f"권장사항: {recommendation}"

    return True, "모든 기준 통과"

def main():
    """메인 실행 함수"""
    # 명령줄 인자로 평가할 파일 경로를 받음
    if len(sys.argv) < 2:
        print("사용법: python evaluate_quality.py <content.json>")
        sys.exit(1)

    content_file = sys.argv[1]

    try:
        # 콘텐츠 로드
        with open(content_file, 'r', encoding='utf-8') as f:
            content = json.load(f)

        # 품질 평가
        evaluation = evaluate_content(content)

        # 결과 출력
        print_evaluation_summary(evaluation)

        # 발행 여부 판단
        can_publish, reason = should_publish(evaluation)

        if can_publish:
            print("✅ 발행 승인! 품질 기준을 모두 충족합니다.")
            exit(0)
        else:
            print(f"❌ 발행 거부: {reason}")
            print("   콘텐츠를 수정하거나 재생성해야 합니다.")
            exit(1)

    except FileNotFoundError:
        print(f"❌ 파일을 찾을 수 없습니다: {content_file}")
        exit(1)
    except json.JSONDecodeError:
        print(f"❌ JSON 파일 형식이 잘못되었습니다: {content_file}")
        exit(1)
    except Exception as e:
        print(f"❌ 오류 발생: {e}")
        exit(1)

if __name__ == "__main__":
    main()
