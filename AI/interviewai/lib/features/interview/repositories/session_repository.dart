import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/session_model.dart';
import '../../feedback/models/feedback_model.dart';

class SessionRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<String> saveSession({
    required String userId,
    required String job,
    required String type,
    required List<Map<String, dynamic>> results,
    required DateTime startedAt,
  }) async {
    final endedAt = DateTime.now();
    final scores = results
        .map((r) => (r['feedback'] as FeedbackModel).score)
        .toList();
    final totalScore =
        scores.isEmpty ? 0 : (scores.reduce((a, b) => a + b) / scores.length).round();

    final weakAreas = results
        .expand((r) => (r['feedback'] as FeedbackModel).improvements)
        .toSet()
        .take(5)
        .toList();

    final sessionRef = _db
        .collection('users')
        .doc(userId)
        .collection('sessions')
        .doc();

    final batch = _db.batch();

    batch.set(sessionRef, {
      'jobCategory': job,
      'interviewType': type,
      'totalScore': totalScore,
      'questionCount': results.length,
      'weakAreas': weakAreas,
      'startedAt': Timestamp.fromDate(startedAt),
      'endedAt': Timestamp.fromDate(endedAt),
    });

    for (final r in results) {
      final answerRef = sessionRef.collection('questionAnswers').doc();
      final feedback = r['feedback'] as FeedbackModel;
      batch.set(answerRef, {
        'question': r['question'] as String,
        'userAnswer': r['answer'] as String,
        'score': feedback.score,
        'strengths': feedback.strengths,
        'improvements': feedback.improvements,
        'summary': feedback.summary,
      });
    }

    await batch.commit();
    return sessionRef.id;
  }

  Stream<List<SessionSummary>> getSessions(String userId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('sessions')
        .orderBy('startedAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => SessionSummary.fromFirestore(d.id, d.data()))
            .toList());
  }

  Future<List<QuestionResult>> getQuestionResults(
      String userId, String sessionId) async {
    final snap = await _db
        .collection('users')
        .doc(userId)
        .collection('sessions')
        .doc(sessionId)
        .collection('questionAnswers')
        .get();
    return snap.docs
        .map((d) => QuestionResult.fromJson(d.data()))
        .toList();
  }
}
