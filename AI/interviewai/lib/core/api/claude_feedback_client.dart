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

  String _buildSystemPrompt(String jobCategory) => '''
당신은 $jobCategory 분야의 시니어 면접관입니다.
지원자의 답변을 아래 기준으로 평가하고, 반드시 JSON 형식으로만 응답하세요.

평가 기준:
- STAR 구조 (Situation, Task, Action, Result)
- 구체성 (수치, 사례 포함 여부)
- 논리성 (흐름이 자연스러운가)
- 직군 적합성

응답 형식 (이 JSON 외 다른 텍스트 금지):
{"score": 0-100 정수, "strengths": ["잘한 점 1", "잘한 점 2"], "improvements": ["보완할 점 1", "보완할 점 2"], "summary": "한 줄 요약"}
''';

  Future<FeedbackModel> getFeedback({
    required String question,
    required String answer,
    required String jobCategory,
  }) async {
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
            'max_tokens': 500,
            'system': _buildSystemPrompt(jobCategory),
            'messages': [
              {
                'role': 'user',
                'content': '질문: $question\n\n답변: $answer',
              }
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
