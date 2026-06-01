import 'dart:convert';
import 'package:dio/dio.dart';
import '../constants/env.dart';
import '../errors/app_exception.dart';
import '../../features/feedback/models/feedback_model.dart';

class ClaudeQuestionClient {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://api.anthropic.com/v1',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 30),
  ));

  static const _model = 'claude-sonnet-4-6';

  Options get _headers => Options(headers: {
        'x-api-key': Env.anthropicKey,
        'anthropic-version': '2023-06-01',
        'content-type': 'application/json',
      });

  // ── 맞춤 질문 생성 (자소서 / 채용공고 / 혼합) ─────────────────

  Future<List<String>> generateQuestions({
    required String job,
    String? resume,
    String? jobPosting,
    InterviewPersona persona = InterviewPersona.standard,
    int count = 5,
  }) async {
    final personaDesc = persona.label;

    final context = StringBuffer();
    if (resume != null && resume.isNotEmpty) {
      context.writeln('## 자기소개서\n$resume\n');
    }
    if (jobPosting != null && jobPosting.isNotEmpty) {
      context.writeln('## 채용공고\n$jobPosting\n');
    }

    final system = '''
당신은 $personaDesc 성향의 대기업 면접관입니다. ${persona.systemContext}
제공된 데이터(자기소개서/채용공고)를 분석하여 지원자의 역량을 검증하는 날카롭고 현실적인 면접 질문 $count개를 생성하세요.

# 조건:
1. 자기소개서가 있으면: 질문의 60%는 자기소개서 내용의 진위/구체적 성과를 검증하는 경험 면접 질문이어야 합니다.
2. 채용공고가 있으면: 채용공고의 하드스킬/소프트스킬 요구사항에 맞는 직무 역량 질문을 포함하세요.
3. ${persona.systemContext}
4. 면접관 어조로 작성 (예: "~하셨는데, 구체적으로 어떤 역할을 하셨나요?")
5. 반드시 JSON으로만 응답: {"questions": ["질문1", "질문2", ...]}
''';

    final contextStr = context.toString();
    final userContent =
        '지원 직무: $job\n\n${contextStr.isEmpty ? "일반 직무 면접 질문 $count개를 생성해주세요." : contextStr}';

    for (int attempt = 0; attempt < 3; attempt++) {
      try {
        final response = await _dio.post(
          '/messages',
          options: _headers,
          data: {
            'model': _model,
            'max_tokens': 800,
            'system': system,
            'messages': [
              {'role': 'user', 'content': userContent}
            ],
          },
        );

        final text =
            response.data['content']?[0]?['text'] as String? ?? '';
        final json = _extractJson(text);
        if (json != null) {
          final decoded = jsonDecode(json) as Map<String, dynamic>;
          final questions =
              List<String>.from(decoded['questions'] as List? ?? []);
          if (questions.isNotEmpty) return questions.take(count).toList();
        }
      } on DioException catch (e) {
        if (attempt == 2) {
          if (e.type == DioExceptionType.connectionTimeout) {
            throw const NetworkException();
          }
        }
        await Future.delayed(Duration(seconds: attempt + 1));
      } catch (_) {
        if (attempt == 2) rethrow;
      }
    }
    return [];
  }

  // ── 꼬리 질문 생성 ────────────────────────────────────────────

  Future<String> generateFollowUp({
    required String originalQuestion,
    required String userAnswer,
    InterviewPersona persona = InterviewPersona.standard,
  }) async {
    final system = '''
당신은 ${persona.label} 성향의 면접관입니다. ${persona.systemContext}
유저의 답변에서 논리적 허점이나 모호한 부분을 짚어 꼬리 질문(Follow-up) 1개만 생성하세요.

# 조건:
1. 답변에서 기술 설명 부족, 모호한 표현, 결과 미언급 등을 정확히 짚어내야 합니다.
2. 한 문장 이내, 간결하고 명확하게 작성하세요.
3. 반드시 JSON으로만 응답: {"follow_up": "꼬리 질문"}
''';

    try {
      final response = await _dio.post(
        '/messages',
        options: _headers,
        data: {
          'model': _model,
          'max_tokens': 200,
          'system': system,
          'messages': [
            {
              'role': 'user',
              'content': '원본 질문: $originalQuestion\n\n답변: $userAnswer'
            }
          ],
        },
      );

      final text = response.data['content']?[0]?['text'] as String? ?? '';
      final json = _extractJson(text);
      if (json != null) {
        final decoded = jsonDecode(json) as Map<String, dynamic>;
        final followUp = decoded['follow_up'] as String? ?? '';
        if (followUp.isNotEmpty) return followUp;
      }
    } catch (_) {}
    return '';
  }

  String? _extractJson(String text) {
    final start = text.indexOf('{');
    final end = text.lastIndexOf('}');
    if (start == -1 || end == -1 || end <= start) return null;
    return text.substring(start, end + 1);
  }
}
