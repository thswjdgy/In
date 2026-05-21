import 'package:dio/dio.dart';
import '../constants/env.dart';
import '../errors/app_exception.dart';

class WhisperClient {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://api.openai.com/v1',
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 30),
  ));

  Future<String> transcribe(String audioFilePath) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          audioFilePath,
          filename: 'audio.m4a',
        ),
        'model': 'whisper-1',
        'language': 'ko',
        'response_format': 'json',
      });

      final response = await _dio.post(
        '/audio/transcriptions',
        data: formData,
        options: Options(headers: {
          'Authorization': 'Bearer ${Env.openAiKey}',
        }),
      );

      final text = response.data['text'] as String? ?? '';
      if (text.trim().isEmpty) return '답변을 인식하지 못했습니다.';
      return text.trim();
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw const NetworkException();
      }
      throw WhisperException(
        e.response?.data?['error']?['message'] ?? '음성 변환에 실패했습니다.',
        statusCode: e.response?.statusCode,
      );
    }
  }
}
