import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/session_model.dart';
import '../../feedback/models/feedback_model.dart';

class SessionRepository {
  static const _kLocalSessions = 'local_sessions_';

  FirebaseFirestore get _db => FirebaseFirestore.instance;

  bool get _firestoreAvailable {
    try {
      FirebaseFirestore.instance;
      return true;
    } catch (_) {
      return false;
    }
  }

  // ── 세션 저장 ─────────────────────────────────────────────────

  Future<String> saveSession({
    required String userId,
    required String job,
    required String type,
    required List<Map<String, dynamic>> results,
    required DateTime startedAt,
  }) async {
    final sessionId = await _saveLocal(
      userId: userId,
      job: job,
      type: type,
      results: results,
      startedAt: startedAt,
    );

    if (_firestoreAvailable) {
      try {
        await _saveFirestore(
          userId: userId,
          job: job,
          type: type,
          results: results,
          startedAt: startedAt,
        );
      } catch (_) {}
    }

    return sessionId;
  }

  Future<String> _saveLocal({
    required String userId,
    required String job,
    required String type,
    required List<Map<String, dynamic>> results,
    required DateTime startedAt,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_kLocalSessions$userId';
    final raw = prefs.getString(key);
    final List<dynamic> list = raw != null ? jsonDecode(raw) as List : [];

    final scores = results
        .map((r) => (r['feedback'] as FeedbackModel).score)
        .toList();
    final totalScore = scores.isEmpty
        ? 0
        : (scores.reduce((a, b) => a + b) / scores.length).round();
    final weakAreas = results
        .expand((r) => (r['feedback'] as FeedbackModel).improvements)
        .toSet()
        .take(5)
        .toList();

    final sessionId = 'local_${DateTime.now().millisecondsSinceEpoch}';
    list.insert(0, {
      'sessionId': sessionId,
      'jobCategory': job,
      'interviewType': type,
      'totalScore': totalScore,
      'questionCount': results.length,
      'weakAreas': weakAreas,
      'startedAt': startedAt.toIso8601String(),
      'endedAt': DateTime.now().toIso8601String(),
      'answers': results
          .map((r) {
            final fb = r['feedback'] as FeedbackModel;
            return {
              'question': r['question'],
              'userAnswer': r['answer'],
              'score': fb.score,
              'strengths': fb.strengths,
              'improvements': fb.improvements,
              'summary': fb.summary,
            };
          })
          .toList(),
    });

    await prefs.setString(key, jsonEncode(list));
    return sessionId;
  }

  Future<void> _saveFirestore({
    required String userId,
    required String job,
    required String type,
    required List<Map<String, dynamic>> results,
    required DateTime startedAt,
  }) async {
    final endedAt = DateTime.now();
    final scores =
        results.map((r) => (r['feedback'] as FeedbackModel).score).toList();
    final totalScore = scores.isEmpty
        ? 0
        : (scores.reduce((a, b) => a + b) / scores.length).round();
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
      final fb = r['feedback'] as FeedbackModel;
      batch.set(answerRef, {
        'question': r['question'] as String,
        'userAnswer': r['answer'] as String,
        'score': fb.score,
        'strengths': fb.strengths,
        'improvements': fb.improvements,
        'summary': fb.summary,
      });
    }
    await batch.commit();
  }

  // ── 세션 조회 ─────────────────────────────────────────────────

  Future<List<SessionSummary>> getLocalSessions(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_kLocalSessions$userId';
    final raw = prefs.getString(key);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => SessionSummary.fromLocal(e as Map<String, dynamic>))
        .toList();
  }

  Stream<List<SessionSummary>> getSessions(String userId) {
    if (!_firestoreAvailable) {
      return Stream.fromFuture(getLocalSessions(userId));
    }
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
    // 로컬 세션에서 먼저 찾기
    if (sessionId.startsWith('local_')) {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_kLocalSessions$userId';
      final raw = prefs.getString(key);
      if (raw != null) {
        final list = jsonDecode(raw) as List<dynamic>;
        final session = list.firstWhere(
          (e) => e['sessionId'] == sessionId,
          orElse: () => null,
        );
        if (session != null) {
          final answers = session['answers'] as List<dynamic>? ?? [];
          return answers
              .map((a) => QuestionResult.fromJson(a as Map<String, dynamic>))
              .toList();
        }
      }
      return [];
    }

    // Firestore
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
