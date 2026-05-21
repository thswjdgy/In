import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  final FlutterTts _tts = FlutterTts();
  bool _isInitialized = false;

  Future<void> _init() async {
    if (_isInitialized) return;
    await _tts.setLanguage('ko-KR');
    await _tts.setSpeechRate(0.9);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
    _isInitialized = true;
  }

  Future<void> speak(String text) async {
    await _init();
    await _tts.stop();
    await _tts.speak(text);
  }

  Future<void> stop() async => _tts.stop();

  void setCompletionHandler(VoidCallback handler) {
    _tts.setCompletionHandler(handler);
  }

  Future<void> dispose() async => _tts.stop();
}

typedef VoidCallback = void Function();
