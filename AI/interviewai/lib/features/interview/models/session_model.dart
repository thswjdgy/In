import '../../feedback/models/feedback_model.dart';

class QuestionResult {
  final String question;
  final String answer;
  final FeedbackModel feedback;
  final int durationSeconds;

  const QuestionResult({
    required this.question,
    required this.answer,
    required this.feedback,
    required this.durationSeconds,
  });

  Map<String, dynamic> toJson() => {
        'question': question,
        'answer': answer,
        'score': feedback.score,
        'strengths': feedback.strengths,
        'improvements': feedback.improvements,
        'summary': feedback.summary,
        'durationSeconds': durationSeconds,
      };

  factory QuestionResult.fromJson(Map<String, dynamic> json) => QuestionResult(
        question: json['question'] as String,
        answer: json['answer'] as String,
        feedback: FeedbackModel(
          score: (json['score'] as num).toInt(),
          strengths: List<String>.from(json['strengths'] ?? []),
          improvements: List<String>.from(json['improvements'] ?? []),
          summary: json['summary'] as String? ?? '',
          createdAt: DateTime.now(),
        ),
        durationSeconds: (json['durationSeconds'] as num?)?.toInt() ?? 0,
      );
}

class SessionSummary {
  final String sessionId;
  final String job;
  final String type;
  final int totalScore;
  final int questionCount;
  final List<String> weakAreas;
  final DateTime startedAt;
  final DateTime endedAt;

  const SessionSummary({
    required this.sessionId,
    required this.job,
    required this.type,
    required this.totalScore,
    required this.questionCount,
    required this.weakAreas,
    required this.startedAt,
    required this.endedAt,
  });

  factory SessionSummary.fromFirestore(
      String id, Map<String, dynamic> data) =>
      SessionSummary(
        sessionId: id,
        job: data['jobCategory'] as String? ?? '',
        type: data['interviewType'] as String? ?? '',
        totalScore: (data['totalScore'] as num?)?.toInt() ?? 0,
        questionCount: (data['questionCount'] as num?)?.toInt() ?? 0,
        weakAreas: List<String>.from(data['weakAreas'] ?? []),
        startedAt: (data['startedAt'] as dynamic)?.toDate() ?? DateTime.now(),
        endedAt: (data['endedAt'] as dynamic)?.toDate() ?? DateTime.now(),
      );
}
