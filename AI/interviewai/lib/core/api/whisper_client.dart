import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http_parser/http_parser.dart';
import '../constants/env.dart';
import '../errors/app_exception.dart';

class WhisperClient {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://api.openai.com/v1',
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 60),
  ));

  Future<String> transcribe(String audioFilePath) async {
    try {
      MultipartFile audioFile;

      if (kIsWeb &&
          (audioFilePath.startsWith('blob:') ||
              audioFilePath.startsWith('data:'))) {
        // 웹: blob URL을 XHR로 가져와 바이트로 변환
        final blobDio = Dio();
        final res = await blobDio.get<List<int>>(
          audioFilePath,
          options: Options(responseType: ResponseType.bytes),
        );
        audioFile = MultipartFile.fromBytes(
          res.data ?? [],
          filename: 'audio.webm',
          contentType: MediaType('audio', 'webm'),
        );
      } else {
        audioFile = await MultipartFile.fromFile(
          audioFilePath,
          filename: 'audio.m4a',
        );
      }

      final formData = FormData.fromMap({
        'file': audioFile,
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
