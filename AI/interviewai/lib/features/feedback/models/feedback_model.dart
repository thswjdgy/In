class FeedbackModel {
  final int score;
  final List<String> strengths;
  final List<String> improvements;
  final String summary;
  final String goodPoint;
  final String badPoint;
  final String betterVersion;
  // 로컬 음성 분석 (Claude 아님, InterviewScreen에서 계산)
  final int speechSpeedCpm;          // chars per minute (0 = 미측정)
  final Map<String, int> fillerWords; // {'어': 3, '그니까': 2}
  final DateTime createdAt;

  const FeedbackModel({
    required this.score,
    required this.strengths,
    required this.improvements,
    required this.summary,
    this.goodPoint = '',
    this.badPoint = '',
    this.betterVersion = '',
    this.speechSpeedCpm = 0,
    this.fillerWords = const {},
    required this.createdAt,
  });

  FeedbackModel withSpeechAnalysis({
    required int speedCpm,
    required Map<String, int> fillers,
  }) => FeedbackModel(
        score: score,
        strengths: strengths,
        improvements: improvements,
        summary: summary,
        goodPoint: goodPoint,
        badPoint: badPoint,
        betterVersion: betterVersion,
        speechSpeedCpm: speedCpm,
        fillerWords: fillers,
        createdAt: createdAt,
      );

  factory FeedbackModel.fromJson(Map<String, dynamic> json) => FeedbackModel(
        score: (json['score'] as num).clamp(0, 100).toInt(),
        strengths: List<String>.from(json['strengths'] ?? []),
        improvements: List<String>.from(json['improvements'] ?? []),
        summary: json['summary'] as String? ?? '',
        goodPoint: json['good_point'] as String? ?? '',
        badPoint: json['bad_point'] as String? ?? '',
        betterVersion: json['better_version'] as String? ?? '',
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
        'good_point': goodPoint,
        'bad_point': badPoint,
        'better_version': betterVersion,
        'createdAt': createdAt.toIso8601String(),
      };
}

// 페르소나 면접관 정의
enum InterviewPersona {
  standard('기본 면접관', '균형 잡힌 평가자', '객관적이고 균형 잡힌 면접관입니다.'),
  executive('깐깐한 임원', '날카로운 검증', '성과와 결과를 집요하게 파고드는 깐깐한 임원 면접관입니다. 구체적 수치와 근거를 강하게 요구하세요.'),
  practitioner('친근한 실무자', '실무 중심 협업 체크', '함께 일할 동료를 뽑는 친근한 실무자 면접관입니다. 실제 업무 상황 적합성에 집중하세요.'),
  pressure('압박 면접관', '논리 허점 집요하게 파기', '논리 허점과 모호한 표현을 집요하게 추궁하는 압박 면접관입니다. 단호하고 직설적으로 평가하세요.');

  final String label;
  final String desc;
  final String systemContext;

  const InterviewPersona(this.label, this.desc, this.systemContext);
}

// 면접 모드
enum InterviewMode {
  practice('연습 모드', '힌트 제공, 시간 제한 없음'),
  real('실전 모드', '30초 준비, 2분 답변 제한');

  final String label;
  final String desc;

  const InterviewMode(this.label, this.desc);
}
