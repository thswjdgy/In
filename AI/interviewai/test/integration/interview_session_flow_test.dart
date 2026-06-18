import 'package:flutter_test/flutter_test.dart';
import 'package:interviewai/features/feedback/models/feedback_model.dart';
import 'package:interviewai/features/interview/models/session_model.dart';

void main() {
  group('Interview session flow — integration scenario', () {
    test('should_build_session_results_from_multiple_questions_and_compute_average', () {
      final questions = [
        '자기소개를 해주세요.',
        '지원 동기를 말씀해주세요.',
        '가장 어려웠던 프로젝트 경험은?',
      ];
      final answers = [
        '저는 3년차 백엔드 개발자입니다.',
        'AI 기술에 관심이 많아 지원했습니다.',
        'MSA 전환 프로젝트가 가장 어려웠습니다.',
      ];
      final scores = [80, 70, 90];

      final results = List.generate(
        questions.length,
        (i) => QuestionResult(
          question: questions[i],
          answer: answers[i],
          feedback: FeedbackModel(
            score: scores[i],
            strengths: ['강점 $i'],
            improvements: ['약점 $i'],
            summary: '요약 $i',
            createdAt: DateTime(2026, 6, 15),
          ),
          durationSeconds: 60 + i * 10,
        ),
      );

      expect(results.length, 3);

      final avgScore = results.map((r) => r.feedback.score).reduce((a, b) => a + b) ~/ results.length;
      expect(avgScore, 80);

      final totalDuration = results.map((r) => r.durationSeconds).reduce((a, b) => a + b);
      expect(totalDuration, 60 + 70 + 80);
    });

    test('should_serialize_and_deserialize_question_result_without_data_loss', () {
      final original = QuestionResult(
        question: '팀 갈등을 어떻게 해결하셨나요?',
        answer: '직접 대화를 통해 해결했습니다.',
        feedback: FeedbackModel(
          score: 85,
          strengths: ['갈등 해결 능력'],
          improvements: ['구체적 사례 부족'],
          summary: '양호한 답변',
          goodPoint: '논리적',
          badPoint: '수치 부족',
          betterVersion: '수치를 추가하면 더 좋음',
          createdAt: DateTime(2026, 6, 15),
        ),
        durationSeconds: 55,
      );

      final json = original.toJson();
      final restored = QuestionResult.fromJson(json);

      expect(restored.question, original.question);
      expect(restored.answer, original.answer);
      expect(restored.feedback.score, original.feedback.score);
      expect(restored.feedback.strengths, original.feedback.strengths);
      expect(restored.durationSeconds, original.durationSeconds);
    });

    test('should_apply_speech_analysis_to_feedback_after_session', () {
      final feedback = FeedbackModel(
        score: 75,
        strengths: ['명확한 구조'],
        improvements: ['발화 속도'],
        summary: '좋음',
        createdAt: DateTime(2026, 6, 15),
      );

      final enriched = feedback.withSpeechAnalysis(
        speedCpm: 420,
        fillers: {'어': 5, '음': 2},
      );

      expect(enriched.speechSpeedCpm, 420);
      expect(enriched.fillerWords['어'], 5);
      expect(enriched.score, 75);
    });
  });
}
