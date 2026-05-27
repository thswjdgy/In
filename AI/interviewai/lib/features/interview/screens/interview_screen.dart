import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/api/whisper_client.dart';
import '../../../core/api/claude_feedback_client.dart';
import '../../../core/services/audio_recorder_service.dart';
import '../../../core/services/tts_service.dart';
import '../../../core/errors/app_exception.dart';
import '../../../shared/constants/question_bank.dart';
import '../../../shared/theme/app_theme.dart';
import '../../feedback/models/feedback_model.dart';
import '../repositories/session_repository.dart';
import '../../../core/services/streak_service.dart';

enum _InterviewState { ready, speaking, recording, processing, done }

class InterviewScreen extends StatefulWidget {
  final String job;
  final String type;
  final int count;

  const InterviewScreen({
    super.key,
    required this.job,
    required this.type,
    required this.count,
  });

  @override
  State<InterviewScreen> createState() => _InterviewScreenState();
}

class _InterviewScreenState extends State<InterviewScreen> {
  late final List<String> _questions;
  late final AudioRecorderService _recorder;
  late final TtsService _tts;
  final WhisperClient _whisper = WhisperClient();
  final ClaudeFeedbackClient _claude = ClaudeFeedbackClient();

  int _currentIndex = 0;
  _InterviewState _state = _InterviewState.ready;
  int _elapsedSeconds = 0;
  Timer? _timer;
  String? _transcribedText;
  String? _errorMessage;
  final DateTime _sessionStartedAt = DateTime.now();

  final List<Map<String, dynamic>> _results = [];

  @override
  void initState() {
    super.initState();
    _recorder = AudioRecorderService();
    _tts = TtsService();
    _questions = QuestionBank.getQuestions(
      widget.type,
      widget.count,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _speakQuestion());
  }

  Future<void> _speakQuestion() async {
    if (_currentIndex >= _questions.length) return;
    setState(() => _state = _InterviewState.speaking);
    await _tts.speak(_questions[_currentIndex]);
    if (mounted) setState(() => _state = _InterviewState.ready);
  }

  Future<void> _startRecording() async {
    try {
      setState(() {
        _state = _InterviewState.recording;
        _elapsedSeconds = 0;
        _transcribedText = null;
        _errorMessage = null;
      });
      await _recorder.startRecording();
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() => _elapsedSeconds++);
      });
    } on PermissionDeniedException catch (e) {
      setState(() {
        _state = _InterviewState.ready;
        _errorMessage = e.message;
      });
    }
  }

  Future<void> _stopAndEvaluate() async {
    _timer?.cancel();
    setState(() => _state = _InterviewState.processing);

    final path = await _recorder.stopRecording();
    if (path == null) {
      setState(() {
        _state = _InterviewState.ready;
        _errorMessage = '녹음 파일을 찾을 수 없습니다.';
      });
      return;
    }

    try {
      final text = await _whisper.transcribe(path);
      await _recorder.deleteFile(path);

      final feedback = await _claude.getFeedback(
        question: _questions[_currentIndex],
        answer: text,
        jobCategory: widget.job,
      );

      _results.add({
        'question': _questions[_currentIndex],
        'answer': text,
        'feedback': feedback,
      });

      if (mounted) {
        setState(() {
          _transcribedText = text;
          _state = _InterviewState.done;
        });
        _navigateToFeedback(feedback);
      }
    } on AppException catch (e) {
      if (mounted) {
        setState(() {
          _state = _InterviewState.ready;
          _errorMessage = e.message;
        });
      }
    }
  }

  void _navigateToFeedback(FeedbackModel feedback) {
    final isLast = _currentIndex >= _questions.length - 1;
    context.push('/feedback', extra: {
      'feedback': feedback,
      'question': _questions[_currentIndex],
      'answer': _transcribedText ?? '',
      'isLast': isLast,
      'onNext': isLast ? null : _nextQuestion,
      'onFinish': isLast ? _navigateToResult : null,
    });
  }

  void _navigateToResult() {
    _saveSession();
    context.go('/result', extra: {
      'job': widget.job,
      'results': _results,
    });
  }

  Future<void> _saveSession() async {
    await StreakService().recordToday();
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      await SessionRepository().saveSession(
        userId: user.uid,
        job: widget.job,
        type: widget.type,
        results: _results,
        startedAt: _sessionStartedAt,
      );
    } catch (_) {}
  }

  void _nextQuestion() {
    setState(() {
      _currentIndex++;
      _state = _InterviewState.ready;
      _transcribedText = null;
    });
    _speakQuestion();
  }

  String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  void dispose() {
    _timer?.cancel();
    _recorder.dispose();
    _tts.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Text(
              widget.job,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
            ),
            Text(
              '${_currentIndex + 1} / ${_questions.length}문제',
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.pop(),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: (_currentIndex + 1) / _questions.length,
            backgroundColor: const Color(0xFFE2E8F0),
            valueColor:
                const AlwaysStoppedAnimation<Color>(AppTheme.primary),
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 16),

              // 질문 카드
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.record_voice_over_rounded,
                            color: AppTheme.primary,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            '면접 질문',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primary,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.volume_up_rounded,
                                size: 20),
                            onPressed: _state == _InterviewState.ready
                                ? _speakQuestion
                                : null,
                            color: const Color(0xFF94A3B8),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _questions.isNotEmpty
                            ? _questions[_currentIndex]
                            : '',
                        style: const TextStyle(
                          fontSize: 18,
                          height: 1.6,
                          color: Color(0xFF1E293B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // 상태 표시
              Expanded(child: _buildStateArea()),

              // 에러
              if (_errorMessage != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(
                        color: AppTheme.error, fontSize: 14),
                  ),
                ),

              // 녹음 버튼
              _buildActionButton(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStateArea() {
    return switch (_state) {
      _InterviewState.ready => const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.mic_none_rounded,
                  size: 64, color: Color(0xFFCBD5E1)),
              SizedBox(height: 16),
              Text(
                '답변 준비가 되면\n버튼을 눌러 시작하세요',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 16, color: Color(0xFF94A3B8)),
              ),
            ],
          ),
        ),
      _InterviewState.speaking => const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('질문을 읽고 있습니다...',
                  style: TextStyle(color: Color(0xFF64748B))),
            ],
          ),
        ),
      _InterviewState.recording => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const _PulsingMic(),
              const SizedBox(height: 20),
              Text(
                _formatTime(_elapsedSeconds),
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.error,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '녹음 중',
                style: TextStyle(color: Color(0xFF64748B)),
              ),
            ],
          ),
        ),
      _InterviewState.processing => const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('AI가 답변을 분석 중입니다...',
                  style: TextStyle(color: Color(0xFF64748B))),
            ],
          ),
        ),
      _InterviewState.done => const Center(
          child: Icon(Icons.check_circle_rounded,
              size: 64, color: AppTheme.success),
        ),
    };
  }

  Widget _buildActionButton() {
    return switch (_state) {
      _InterviewState.ready => FilledButton.icon(
          onPressed: _startRecording,
          icon: const Icon(Icons.mic_rounded),
          label: const Text('답변 시작'),
        ),
      _InterviewState.recording => FilledButton.icon(
          onPressed: _stopAndEvaluate,
          icon: const Icon(Icons.stop_rounded),
          label: const Text('답변 완료'),
          style: FilledButton.styleFrom(
            backgroundColor: AppTheme.error,
          ),
        ),
      _ => const SizedBox.shrink(),
    };
  }
}

class _PulsingMic extends StatefulWidget {
  const _PulsingMic();

  @override
  State<_PulsingMic> createState() => _PulsingMicState();
}

class _PulsingMicState extends State<_PulsingMic>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _animation = Tween(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ScaleTransition(
        scale: _animation,
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppTheme.error.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.mic_rounded,
              size: 40, color: AppTheme.error),
        ),
      );
}
