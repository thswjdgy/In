import 'dart:async';
import 'dart:io';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import '../errors/app_exception.dart';

class AudioRecorderService {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  bool _isInitialized = false;
  String? _currentPath;
  Timer? _maxDurationTimer;

  static const int maxDurationSeconds = 180;

  Future<void> _init() async {
    if (_isInitialized) return;
    final status = await Permission.microphone.request();
    if (!status.isGranted) throw const PermissionDeniedException();
    await _recorder.openRecorder();
    _isInitialized = true;
  }

  Future<void> startRecording() async {
    await _init();
    final dir = await getTemporaryDirectory();
    _currentPath =
        '${dir.path}/interview_${DateTime.now().millisecondsSinceEpoch}.m4a';
    await _recorder.startRecorder(
      toFile: _currentPath,
      codec: Codec.aacMP4,
    );
    _maxDurationTimer = Timer(
      const Duration(seconds: maxDurationSeconds),
      stopRecording,
    );
  }

  Future<String?> stopRecording() async {
    _maxDurationTimer?.cancel();
    await _recorder.stopRecorder();
    return _currentPath;
  }

  bool get isRecording => _recorder.isRecording;

  Stream<RecordingDisposition> get onProgress =>
      _recorder.onProgress ?? const Stream.empty();

  Future<void> dispose() async {
    _maxDurationTimer?.cancel();
    await _recorder.closeRecorder();
    _isInitialized = false;
  }

  Future<void> deleteFile(String path) async {
    final file = File(path);
    if (await file.exists()) await file.delete();
  }
}
