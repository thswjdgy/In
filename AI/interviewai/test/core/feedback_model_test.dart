import 'package:flutter_test/flutter_test.dart';
import 'package:interviewai/features/feedback/models/feedback_model.dart';

void main() {
  group('FeedbackModel.fromJson', () {
    test('정상 JSON 파싱', () {
      final json = {
        'score': 75,
        'strengths': ['구체적인 사례를 들었습니다', 'STAR 구조가 명확합니다'],
        'improvements': ['수치 데이터를 추가하면 좋겠습니다'],
        'summary': '전반적으로 좋은 답변이었습니다.',
      };

      final model = FeedbackModel.fromJson(json);

      expect(model.score, 75);
      expect(model.strengths.length, 2);
      expect(model.improvements.length, 1);
      expect(model.summary, '전반적으로 좋은 답변이었습니다.');
    });

    test('score 100 초과 시 100으로 clamp', () {
      final model = FeedbackModel.fromJson({
        'score': 150,
        'strengths': [],
        'improvements': [],
        'summary': '',
      });
      expect(model.score, 100);
    });

    test('score 음수 시 0으로 clamp', () {
      final model = FeedbackModel.fromJson({
        'score': -10,
        'strengths': [],
        'improvements': [],
        'summary': '',
      });
      expect(model.score, 0);
    });

    test('strengths/improvements 누락 시 빈 리스트', () {
      final model = FeedbackModel.fromJson({
        'score': 50,
        'summary': '보통',
      });
      expect(model.strengths, isEmpty);
      expect(model.improvements, isEmpty);
    });

    test('summary 누락 시 빈 문자열', () {
      final model = FeedbackModel.fromJson({'score': 50});
      expect(model.summary, '');
    });
  });

  group('FeedbackModel.fallback', () {
    test('score 0, improvements에 오류 메시지 포함', () {
      final model = FeedbackModel.fallback();
      expect(model.score, 0);
      expect(model.strengths, isEmpty);
      expect(model.improvements, isNotEmpty);
    });
  });

  group('FeedbackModel.toJson', () {
    test('직렬화 후 역직렬화 시 동일한 값', () {
      final original = FeedbackModel(
        score: 80,
        strengths: ['강점1'],
        improvements: ['약점1'],
        summary: '요약',
        createdAt: DateTime(2026, 5, 18),
      );

      final json = original.toJson();
      expect(json['score'], 80);
      expect(json['strengths'], ['강점1']);
      expect(json['improvements'], ['약점1']);
      expect(json['summary'], '요약');
    });
  });
}
