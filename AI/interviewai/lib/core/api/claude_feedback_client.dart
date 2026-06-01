import 'dart:convert';
import 'package:dio/dio.dart';
import '../constants/env.dart';
import '../errors/app_exception.dart';
import '../../features/feedback/models/feedback_model.dart';

class ClaudeFeedbackClient {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://api.anthropic.com/v1',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 30),
  ));

  static const _model = 'claude-sonnet-4-6';
  static const _maxRetries = 3;

  String _buildSystemPrompt(String jobCategory,
      [InterviewPersona persona = InterviewPersona.standard]) => '''
당신은 채용 컨설팅 전문가이자 $jobCategory 분야의 ${persona.label} 성향의 면접관입니다.
${persona.systemContext}
제시된 면접 질문과 유저의 답변(STT 변환 텍스트)을 분석하여 객관적이고 건설적인 피드백 리포트를 작성하세요.

# 분석 기준:
1. 논리성 (STAR 구조): Situation(상황), Task(과제), Action(행동), Result(결과)가 잘 드러났는가?
2. 직무 적합성: 질문 의도에 맞는 직무 역량이나 키워드가 포함되었는가?
3. 구체성: 수치, 사례, 구체적 행동이 포함되었는가?

# 반드시 다음 JSON 구조로만 응답할 것 (다른 텍스트 없이 JSON만):
{
  "score": 85,
  "strengths": ["잘한 점 한 줄 1", "잘한 점 한 줄 2"],
  "improvements": ["보완할 점 한 줄 1", "보완할 점 한 줄 2"],
  "summary": "전체 답변을 한 문장으로 요약",
  "good_point": "유저가 잘한 부분을 2-3문장으로 구체적으로 칭찬 (어떤 부분이 왜 좋은지)",
  "bad_point": "가장 아쉬운 부분을 2-3문장으로 구체적으로 설명 (어떤 부분이 왜 부족한지)",
  "better_version": "유저의 경험을 바탕으로 STAR 구조에 맞게 재구성한 모범 답변 (3-5문장, 수치 포함)"
}
''';

  Future<FeedbackModel> getFeedback({
    required String question,
    required String answer,
    required String jobCategory,
    String? followUpQuestion,
    String? followUpAnswer,
    InterviewPersona persona = InterviewPersona.standard,
  }) async {
    final userContent = StringBuffer()
      ..writeln('면접 질문: $question')
      ..writeln()
      ..writeln('유저의 답변: $answer');

    if (followUpQuestion != null && followUpQuestion.isNotEmpty) {
      userContent
        ..writeln()
        ..writeln('꼬리 질문: $followUpQuestion')
        ..writeln()
        ..writeln('꼬리 질문 답변: ${followUpAnswer?.isNotEmpty == true ? followUpAnswer : "(건너뜀)"}');
    }

    for (int attempt = 0; attempt < _maxRetries; attempt++) {
      try {
        final response = await _dio.post(
          '/messages',
          options: Options(headers: {
            'x-api-key': Env.anthropicKey,
            'anthropic-version': '2023-06-01',
            'content-type': 'application/json',
          }),
          data: {
            'model': _model,
            'max_tokens': 1000,
            'system': _buildSystemPrompt(jobCategory, persona),
            'messages': [
              {'role': 'user', 'content': userContent.toString()}
            ],
          },
        );

        final content =
            response.data['content']?[0]?['text'] as String? ?? '';
        final jsonStr = _extractJson(content);
        if (jsonStr != null) {
          return FeedbackModel.fromJson(jsonDecode(jsonStr));
        }
      } on DioException catch (e) {
        if (attempt == _maxRetries - 1) {
          if (e.type == DioExceptionType.connectionTimeout) {
            throw const NetworkException();
          }
          throw const FeedbackParseException();
        }
        await Future.delayed(Duration(seconds: attempt + 1));
      } catch (_) {
        if (attempt == _maxRetries - 1) throw const FeedbackParseException();
      }
    }
    return FeedbackModel.fallback();
  }

  String? _extractJson(String text) {
    final start = text.indexOf('{');
    final end = text.lastIndexOf('}');
    if (start == -1 || end == -1 || end <= start) return null;
    return text.substring(start, end + 1);
  }
}
