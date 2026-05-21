sealed class AppException implements Exception {
  final String message;
  const AppException(this.message);
}

class PermissionDeniedException extends AppException {
  const PermissionDeniedException() : super('마이크 권한이 필요합니다.');
}

class WhisperException extends AppException {
  final int? statusCode;
  const WhisperException(super.message, {this.statusCode});
}

class FeedbackParseException extends AppException {
  const FeedbackParseException() : super('피드백 분석에 실패했습니다. 다시 시도해주세요.');
}

class NetworkException extends AppException {
  const NetworkException() : super('인터넷 연결을 확인해주세요.');
}
