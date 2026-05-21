// API 키는 실행 시 환경변수 또는 --dart-define으로 주입
// flutter run --dart-define=OPENAI_API_KEY=sk-... --dart-define=ANTHROPIC_API_KEY=sk-ant-...
class Env {
  static const String openAiKey =
      String.fromEnvironment('OPENAI_API_KEY', defaultValue: '');
  static const String anthropicKey =
      String.fromEnvironment('ANTHROPIC_API_KEY', defaultValue: '');
}
