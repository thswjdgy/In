import 'package:flutter_test/flutter_test.dart';
import 'package:interviewai/features/interview/models/session_model.dart';
import 'package:interviewai/features/feedback/models/feedback_model.dart';

void main() {
  group('QuestionResult', () {
    test('fromJson / toJson 왕복 직렬화', () {
      final json = {
        'question': '자기소개를 해주세요.',
        'answer': '저는 3년차 백엔드 개발자입니다.',
        'score': 72,
        'strengths': ['명확한 경력 소개'],
        'improvements': ['구체적인 수치 부족'],
        'summary': '기본적인 소개는 잘 됨',
        'durationSeconds': 45,
      };

      final result = QuestionResult.fromJson(json);

      expect(result.question, '자기소개를 해주세요.');
      expect(result.answer, '저는 3년차 백엔드 개발자입니다.');
      expect(result.feedback.score, 72);
      expect(result.feedback.strengths, ['명확한 경력 소개']);
      expect(result.durationSeconds, 45);
    });

    test('durationSeconds 누락 시 0 기본값', () {
      final result = QuestionResult.fromJson({
        'question': 'Q',
        'answer': 'A',
        'score': 50,
        'strengths': [],
        'improvements': [],
        'summary': '',
      });
      expect(result.durationSeconds, 0);
    });

    test('toJson 키 목록 검증', () {
      final result = QuestionResult(
        question: 'Q',
        answer: 'A',
        feedback: FeedbackModel(
          score: 60,
          strengths: [],
          improvements: [],
          summary: '',
          createdAt: DateTime.now(),
        ),
        durationSeconds: 30,
      );

      final json = result.toJson();
      expect(json.containsKey('question'), isTrue);
      expect(json.containsKey('answer'), isTrue);
      expect(json.containsKey('score'), isTrue);
      expect(json.containsKey('durationSeconds'), isTrue);
    });
  });
}
