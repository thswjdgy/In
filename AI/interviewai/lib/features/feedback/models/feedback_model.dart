class FeedbackModel {
  final int score;
  final List<String> strengths;
  final List<String> improvements;
  final String summary;
  final DateTime createdAt;

  const FeedbackModel({
    required this.score,
    required this.strengths,
    required this.improvements,
    required this.summary,
    required this.createdAt,
  });

  factory FeedbackModel.fromJson(Map<String, dynamic> json) => FeedbackModel(
        score: (json['score'] as num).clamp(0, 100).toInt(),
        strengths: List<String>.from(json['strengths'] ?? []),
        improvements: List<String>.from(json['improvements'] ?? []),
        summary: json['summary'] as String? ?? '',
        createdAt: DateTime.now(),
      );

  factory FeedbackModel.fallback() => FeedbackModel(
        score: 0,
        strengths: [],
        improvements: ['피드백을 불러오지 못했습니다. 다시 시도해주세요.'],
        summary: '분석 실패',
        createdAt: DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'score': score,
        'strengths': strengths,
        'improvements': improvements,
        'summary': summary,
        'createdAt': createdAt.toIso8601String(),
      };
}
