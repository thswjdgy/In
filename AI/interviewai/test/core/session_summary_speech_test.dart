import 'package:flutter_test/flutter_test.dart';
import 'package:interviewai/features/interview/models/session_model.dart';

void main() {
  group('SessionSummary.speech fields', () {
    test('should_default_to_zero_when_not_provided', () {
      final s = SessionSummary(
        sessionId: 's1',
        job: '개발자',
        type: 'technical',
        totalScore: 80,
        questionCount: 3,
        weakAreas: [],
        startedAt: DateTime(2026, 6, 21),
        endedAt: DateTime(2026, 6, 21),
      );
      expect(s.avgSpeechSpeedCpm, 0);
      expect(s.totalFillerCount, 0);
    });

    test('should_store_speech_speed_and_filler_count', () {
      final s = SessionSummary(
        sessionId: 's2',
        job: '기획자',
        type: 'behavioral',
        totalScore: 75,
        questionCount: 5,
        weakAreas: ['논리성'],
        startedAt: DateTime(2026, 6, 21),
        endedAt: DateTime(2026, 6, 21),
        avgSpeechSpeedCpm: 280,
        totalFillerCount: 4,
      );
      expect(s.avgSpeechSpeedCpm, 280);
      expect(s.totalFillerCount, 4);
    });

    test('fromLocal_should_parse_speech_fields', () {
      final s = SessionSummary.fromLocal({
        'sessionId': 's3',
        'jobCategory': '디자이너',
        'interviewType': 'technical',
        'totalScore': 90,
        'questionCount': 3,
        'weakAreas': [],
        'startedAt': '2026-06-21T10:00:00.000',
        'endedAt': '2026-06-21T10:30:00.000',
        'avgSpeechSpeedCpm': 310,
        'totalFillerCount': 2,
      });
      expect(s.avgSpeechSpeedCpm, 310);
      expect(s.totalFillerCount, 2);
    });

    test('fromLocal_should_default_zero_when_speech_fields_missing', () {
      final s = SessionSummary.fromLocal({
        'sessionId': 's4',
        'jobCategory': '마케터',
        'interviewType': 'behavioral',
        'totalScore': 65,
        'questionCount': 3,
        'weakAreas': [],
        'startedAt': '2026-06-21T10:00:00.000',
        'endedAt': '2026-06-21T10:30:00.000',
      });
      expect(s.avgSpeechSpeedCpm, 0);
      expect(s.totalFillerCount, 0);
    });
  });
}
