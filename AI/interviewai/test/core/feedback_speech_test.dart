import 'package:flutter_test/flutter_test.dart';
import 'package:interviewai/features/feedback/models/feedback_model.dart';

void main() {
  group('FeedbackModel.withSpeechAnalysis', () {
    late FeedbackModel base;

    setUp(() {
      base = FeedbackModel(
        score: 80,
        strengths: ['강점'],
        improvements: ['약점'],
        summary: '요약',
        createdAt: DateTime(2026, 1, 1),
      );
    });

    test('should_set_speechSpeedCpm_and_fillerWords', () {
      final result = base.withSpeechAnalysis(
        speedCpm: 350,
        fillers: {'어': 3, '그니까': 1},
      );
      expect(result.speechSpeedCpm, 350);
      expect(result.fillerWords, {'어': 3, '그니까': 1});
    });

    test('should_preserve_original_score_and_summary', () {
      final result = base.withSpeechAnalysis(speedCpm: 200, fillers: {});
      expect(result.score, base.score);
      expect(result.summary, base.summary);
      expect(result.strengths, base.strengths);
    });

    test('should_return_empty_fillerWords_when_no_fillers', () {
      final result = base.withSpeechAnalysis(speedCpm: 0, fillers: {});
      expect(result.fillerWords, isEmpty);
      expect(result.speechSpeedCpm, 0);
    });
  });

  group('FeedbackModel.fromJson — extended fields', () {
    test('should_parse_good_point_and_bad_point', () {
      final model = FeedbackModel.fromJson({
        'score': 70,
        'strengths': [],
        'improvements': [],
        'summary': '보통',
        'good_point': '논리적 구성',
        'bad_point': '발화 속도 빠름',
        'better_version': '더 나은 답변 예시',
      });
      expect(model.goodPoint, '논리적 구성');
      expect(model.badPoint, '발화 속도 빠름');
      expect(model.betterVersion, '더 나은 답변 예시');
    });

    test('should_default_empty_string_when_fields_missing', () {
      final model = FeedbackModel.fromJson({'score': 50});
      expect(model.goodPoint, '');
      expect(model.badPoint, '');
      expect(model.betterVersion, '');
    });
  });

  group('InterviewPersona', () {
    test('should_have_four_personas', () {
      expect(InterviewPersona.values.length, 4);
    });

    test('should_have_non_empty_systemContext', () {
      for (final p in InterviewPersona.values) {
        expect(p.systemContext, isNotEmpty);
      }
    });
  });

  group('InterviewMode', () {
    test('should_have_two_modes', () {
      expect(InterviewMode.values.length, 2);
    });

    test('should_distinguish_practice_and_real', () {
      expect(InterviewMode.practice.label, '연습 모드');
      expect(InterviewMode.real.label, '실전 모드');
    });
  });
}
