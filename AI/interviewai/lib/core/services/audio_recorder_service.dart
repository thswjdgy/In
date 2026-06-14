import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import '../errors/app_exception.dart';

class AudioRecorderService {
  final AudioRecorder _recorder = AudioRecorder();
  String? _currentPath;
  Timer? _maxDurationTimer;

  static const int maxDurationSeconds = 180;

  Future<void> startRecording() async {
    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) throw const PermissionDeniedException();

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    String path;
    AudioEncoder encoder;

    if (kIsWeb) {
      path = 'interview_$timestamp.webm';
      encoder = AudioEncoder.opus;
    } else {
      final dir = await getTemporaryDirectory();
      path = '${dir.path}/interview_$timestamp.m4a';
      encoder = AudioEncoder.aacLc;
    }
    _currentPath = path;

    await _recorder.start(
      RecordConfig(encoder: encoder, sampleRate: 16000, numChannels: 1),
      path: path,
    );

    _maxDurationTimer = Timer(
      const Duration(seconds: maxDurationSeconds),
      stopRecording,
    );
  }

  Future<String?> stopRecording() async {
    _maxDurationTimer?.cancel();
    return await _recorder.stop() ?? _currentPath;
  }

  bool get isRecording => false;

  Future<void> dispose() async {
    _maxDurationTimer?.cancel();
    await _recorder.dispose();
  }

  Future<void> deleteFile(String path) async {
    if (kIsWeb) return;
    final file = File(path);
    if (await file.exists()) await file.delete();
  }
}
