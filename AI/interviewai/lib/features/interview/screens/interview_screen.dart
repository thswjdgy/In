import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/api/whisper_client.dart';
import '../../../core/api/claude_feedback_client.dart';
import '../../../core/api/claude_question_client.dart';
import '../../../core/services/audio_recorder_service.dart';
import '../../../core/services/tts_service.dart';
import '../../../core/errors/app_exception.dart';
import '../../../shared/constants/question_bank.dart';
import '../../../shared/theme/app_theme.dart';
import '../../auth/repositories/auth_repository.dart';
import '../../feedback/models/feedback_model.dart';
import '../repositories/session_repository.dart';
import '../../../core/services/streak_service.dart';

enum _InterviewState {
  loading,      // 자소서/채용공고 기반 질문 생성 중
  ready,        // 답변 대기
  thinking,     // 실전 모드: 30초 준비 시간 카운트다운
  speaking,     // TTS 질문 읽는 중
  recording,    // 메인 답변 녹음 중
  processing,   // STT 변환 + 꼬리 질문 생성 중
  followUp,     // 꼬리 질문 표시 (TTS 완료, 사용자 선택 대기)
  followUpRec,  // 꼬리 질문 답변 녹음 중
  followUpProc, // 꼬리 답변 STT 중
  evaluating,   // 최종 피드백 생성 중
  done
}

class InterviewScreen extends StatefulWidget {
  final String job;
  final String type;
  final int count;
  final String? resume;
  final String? jobPosting;
  final InterviewPersona persona;
  final InterviewMode mode;

  const InterviewScreen({
    super.key,
    required this.job,
    required this.type,
    required this.count,
    this.resume,
    this.jobPosting,
    this.persona = InterviewPersona.standard,
    this.mode = InterviewMode.practice,
  });

  @override
  State<InterviewScreen> createState() => _InterviewScreenState();
}

class _InterviewScreenState extends State<InterviewScreen> {
  List<String> _questions = [];
  late final AudioRecorderService _recorder;
  late final TtsService _tts;
  final WhisperClient _whisper = WhisperClient();
  final ClaudeFeedbackClient _claude = ClaudeFeedbackClient();
  final ClaudeQuestionClient _questionClient = ClaudeQuestionClient();

  int _currentIndex = 0;
  _InterviewState _state = _InterviewState.ready;
  int _elapsedSeconds = 0;
  int _thinkingSeconds = 0; // 실전 모드: 준비 시간 카운트다운
  int _recordingDuration = 0; // 실제 녹음 시간 (말 속도 계산용)
  Timer? _timer;
  Timer? _thinkingTimer;

  String? _transcribedText;
  String? _followUpQuestion;
  String? _errorMessage;

  static const _maxAnswerSeconds = 120; // 실전 모드 최대 답변 시간
  static const _thinkingTotalSeconds = 30; // 실전 모드 준비 시간

  // 말버릇 단어 목록
  static const _fillerPatterns = [
    '어', '음', '아', '그니까', '그래서', '그냥', '사실', '뭔가',
    '이제', '막', '약간', '저기', '일단', '근데',
  ];

  final DateTime _sessionStartedAt = DateTime.now();
  final List<Map<String, dynamic>> _results = [];

  bool get _isFollowUpPhase =>
      _state == _InterviewState.followUp ||
      _state == _InterviewState.followUpRec ||
      _state == _InterviewState.followUpProc;

  String get _loadingMessage {
    final hasResume = widget.resume?.isNotEmpty ?? false;
    final hasPosting = widget.jobPosting?.isNotEmpty ?? false;
    if (hasResume && hasPosting) return 'AI가 자소서와 채용공고를 분석해\n맞춤 질문을 생성 중입니다...';
    if (hasPosting) return 'AI가 채용공고를 분석해\n맞춤 질문을 생성 중입니다...';
    return 'AI가 자소서를 분석해\n맞춤 질문을 생성 중입니다...';
  }

  String get _currentDisplayQuestion {
    if (_isFollowUpPhase && _followUpQuestion != null) {
      return _followUpQuestion!;
    }
    if (_questions.isEmpty) return '';
    return _questions[_currentIndex];
  }

  @override
  void initState() {
    super.initState();
    _recorder = AudioRecorderService();
    _tts = TtsService();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    final hasAiInput = (widget.resume?.isNotEmpty ?? false) ||
        (widget.jobPosting?.isNotEmpty ?? false);

    if (hasAiInput) {
      setState(() => _state = _InterviewState.loading);
      try {
        final questions = await _questionClient.generateQuestions(
          job: widget.job,
          resume: widget.resume,
          jobPosting: widget.jobPosting,
          persona: widget.persona,
          count: widget.count,
        );
        _questions = questions.isNotEmpty
            ? questions
            : QuestionBank.getQuestions(widget.type, widget.count);
      } catch (_) {
        _questions = QuestionBank.getQuestions(widget.type, widget.count);
      }
    } else {
      _questions = QuestionBank.getQuestions(widget.type, widget.count);
    }

    if (mounted) {
      setState(() => _state = _InterviewState.ready);
      WidgetsBinding.instance.addPostFrameCallback((_) => _speakQuestion());
    }
  }

  Future<void> _speakQuestion() async {
    if (_currentIndex >= _questions.length) return;
    setState(() => _state = _InterviewState.speaking);
    await _tts.speak(_questions[_currentIndex]);
    if (!mounted) return;
    // 실전 모드: TTS 후 30초 준비 시간
    if (widget.mode == InterviewMode.real) {
      _startThinkingTimer();
    } else {
      setState(() => _state = _InterviewState.ready);
    }
  }

  void _startThinkingTimer() {
    _thinkingSeconds = _thinkingTotalSeconds;
    setState(() => _state = _InterviewState.thinking);
    _thinkingTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      setState(() => _thinkingSeconds--);
      if (_thinkingSeconds <= 0) {
        t.cancel();
        setState(() => _state = _InterviewState.ready);
      }
    });
  }

  Future<void> _startRecording() async {
    _thinkingTimer?.cancel();
    try {
      setState(() {
        _state = _InterviewState.recording;
        _elapsedSeconds = 0;
        _recordingDuration = 0;
        _errorMessage = null;
      });
      await _recorder.startRecording();
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted) return;
        setState(() {
          _elapsedSeconds++;
          _recordingDuration++;
        });
        // 실전 모드: 2분 초과 시 자동 종료
        if (widget.mode == InterviewMode.real &&
            _elapsedSeconds >= _maxAnswerSeconds) {
          _stopAndProcess();
        }
      });
    } on PermissionDeniedException catch (e) {
      setState(() {
        _state = _InterviewState.ready;
        _errorMessage = e.message;
      });
    }
  }

  Future<void> _stopAndProcess() async {
    _timer?.cancel();
    final duration = _recordingDuration;
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
      _transcribedText = text;

      final followUp = await _questionClient.generateFollowUp(
        originalQuestion: _questions[_currentIndex],
        userAnswer: text,
        persona: widget.persona,
      );

      if (mounted && followUp.isNotEmpty) {
        setState(() {
          _followUpQuestion = followUp;
          _state = _InterviewState.speaking;
        });
        await _tts.speak(followUp);
        if (mounted) setState(() => _state = _InterviewState.followUp);
      } else {
        await _generateFeedback(text, null, null, duration);
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

  Future<void> _startFollowUpRecording() async {
    try {
      setState(() {
        _state = _InterviewState.followUpRec;
        _elapsedSeconds = 0;
      });
      await _recorder.startRecording();
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() => _elapsedSeconds++);
      });
    } on PermissionDeniedException catch (e) {
      setState(() {
        _state = _InterviewState.followUp;
        _errorMessage = e.message;
      });
    }
  }

  Future<void> _stopFollowUpAndEvaluate() async {
    _timer?.cancel();
    setState(() => _state = _InterviewState.followUpProc);

    final path = await _recorder.stopRecording();
    if (path == null) {
      setState(() => _state = _InterviewState.followUp);
      return;
    }

    try {
      final followUpText = await _whisper.transcribe(path);
      await _recorder.deleteFile(path);
      await _generateFeedback(
          _transcribedText!, _followUpQuestion, followUpText, _recordingDuration);
    } on AppException catch (e) {
      if (mounted) {
        setState(() {
          _state = _InterviewState.followUp;
          _errorMessage = e.message;
        });
      }
    }
  }

  void _skipFollowUp() {
    _generateFeedback(_transcribedText!, _followUpQuestion, null, _recordingDuration);
  }

  // 말버릇 감지
  Map<String, int> _detectFillerWords(String text) {
    final result = <String, int>{};
    for (final word in _fillerPatterns) {
      final count = RegExp('(?<![가-힣])$word(?![가-힣])').allMatches(text).length;
      if (count > 0) result[word] = count;
    }
    return result;
  }

  // 발화 속도 (분당 글자 수)
  int _computeSpeedCpm(String text, int durationSeconds) {
    if (durationSeconds <= 0) return 0;
    final chars = text.replaceAll(' ', '').length;
    return (chars / durationSeconds * 60).round();
  }

  Future<void> _generateFeedback(
    String answer,
    String? followUpQ,
    String? followUpA,
    int durationSeconds,
  ) async {
    setState(() => _state = _InterviewState.evaluating);

    // 로컬 말하기 분석 (API 불필요)
    final fillers = _detectFillerWords(answer);
    final speedCpm = _computeSpeedCpm(answer, durationSeconds);

    try {
      final rawFeedback = await _claude.getFeedback(
        question: _questions[_currentIndex],
        answer: answer,
        jobCategory: widget.job,
        followUpQuestion: followUpQ,
        followUpAnswer: followUpA,
        persona: widget.persona,
      );

      final feedback = rawFeedback.withSpeechAnalysis(
        speedCpm: speedCpm,
        fillers: fillers,
      );

      _results.add({
        'question': _questions[_currentIndex],
        'answer': answer,
        'followUpQuestion': followUpQ,
        'followUpAnswer': followUpA,
        'feedback': feedback,
      });

      if (mounted) {
        setState(() => _state = _InterviewState.done);
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
      'followUpQuestion': _followUpQuestion,
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
      final user = await AuthRepository().currentLocalUser;
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
    _timer?.cancel();
    _thinkingTimer?.cancel();
    setState(() {
      _currentIndex++;
      _state = _InterviewState.ready;
      _elapsedSeconds = 0;
      _transcribedText = null;
      _followUpQuestion = null;
      _errorMessage = null;
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
    _thinkingTimer?.cancel();
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
              _questions.isEmpty
                  ? '질문 생성 중...'
                  : '${_currentIndex + 1} / ${_questions.length}문제',
              style: const TextStyle(
                  fontSize: 12, color: Color(0xFF94A3B8)),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.pop(),
        ),
        bottom: _questions.isEmpty
            ? null
            : PreferredSize(
                preferredSize: const Size.fromHeight(4),
                child: LinearProgressIndicator(
                  value: (_currentIndex + 1) / _questions.length,
                  backgroundColor: const Color(0xFFE2E8F0),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                      AppTheme.primary),
                ),
              ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 16),
              _buildQuestionCard(),
              const SizedBox(height: 24),
              Expanded(child: _buildStateArea()),
              if (_errorMessage != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(_errorMessage!,
                      style: const TextStyle(
                          color: AppTheme.error, fontSize: 14)),
                ),
              _buildActionButtons(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionCard() {
    final isFollowUp = _isFollowUpPhase && _followUpQuestion != null;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isFollowUp
                      ? Icons.reply_rounded
                      : Icons.record_voice_over_rounded,
                  color: isFollowUp
                      ? const Color(0xFFF59E0B)
                      : AppTheme.primary,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  isFollowUp ? '꼬리 질문' : '면접 질문',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isFollowUp
                        ? const Color(0xFFF59E0B)
                        : AppTheme.primary,
                  ),
                ),
                const Spacer(),
                if (!isFollowUp)
                  IconButton(
                    icon: const Icon(Icons.volume_up_rounded, size: 20),
                    onPressed: _state == _InterviewState.ready
                        ? _speakQuestion
                        : null,
                    color: const Color(0xFF94A3B8),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _currentDisplayQuestion,
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
    );
  }

  Widget _buildStateArea() {
    return switch (_state) {
      _InterviewState.loading => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.auto_awesome_rounded,
                    size: 32, color: AppTheme.primary),
              ),
              const SizedBox(height: 16),
              Text(
                _loadingMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 15, color: Color(0xFF64748B), height: 1.6),
              ),
              const SizedBox(height: 20),
              const CircularProgressIndicator(),
            ],
          ),
        ),
      _InterviewState.thinking => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 90,
                    height: 90,
                    child: CircularProgressIndicator(
                      value: _thinkingSeconds / _thinkingTotalSeconds,
                      strokeWidth: 6,
                      backgroundColor: const Color(0xFFE2E8F0),
                      color: _thinkingSeconds <= 10
                          ? AppTheme.error
                          : AppTheme.primary,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$_thinkingSeconds',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: _thinkingSeconds <= 10
                              ? AppTheme.error
                              : AppTheme.primary,
                        ),
                      ),
                      const Text('초',
                          style: TextStyle(
                              fontSize: 12, color: Color(0xFF94A3B8))),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text('준비 시간',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B))),
              const SizedBox(height: 4),
              const Text('준비되면 지금 바로 답변을 시작할 수 있습니다',
                  style:
                      TextStyle(fontSize: 13, color: Color(0xFF94A3B8))),
            ],
          ),
        ),
      _InterviewState.ready => widget.mode == InterviewMode.practice
          ? const _StarHintCard()
          : const Center(
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
      _InterviewState.speaking => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                _isFollowUpPhase
                    ? '꼬리 질문을 읽고 있습니다...'
                    : '질문을 읽고 있습니다...',
                style: const TextStyle(color: Color(0xFF64748B)),
              ),
            ],
          ),
        ),
      _InterviewState.recording ||
      _InterviewState.followUpRec =>
        Center(
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
              Text(
                _state == _InterviewState.followUpRec
                    ? '꼬리 질문 답변 중'
                    : '녹음 중',
                style: const TextStyle(color: Color(0xFF64748B)),
              ),
              // 실전 모드: 남은 시간 표시
              if (widget.mode == InterviewMode.real &&
                  _state == _InterviewState.recording) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: (_maxAnswerSeconds - _elapsedSeconds) <= 30
                        ? AppTheme.error.withValues(alpha: 0.1)
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '남은 시간 $_remainingTimeLabel',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: (_maxAnswerSeconds - _elapsedSeconds) <= 30
                          ? AppTheme.error
                          : const Color(0xFF64748B),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      _InterviewState.processing ||
      _InterviewState.followUpProc =>
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                _state == _InterviewState.processing
                    ? '꼬리 질문을 생성하는 중...'
                    : 'AI가 답변을 분석 중입니다...',
                style:
                    const TextStyle(color: Color(0xFF64748B)),
              ),
            ],
          ),
        ),
      _InterviewState.evaluating => const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('AI가 피드백을 작성 중입니다...',
                  style: TextStyle(color: Color(0xFF64748B))),
            ],
          ),
        ),
      _InterviewState.followUp => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7ED),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.reply_rounded,
                    size: 32, color: Color(0xFFF59E0B)),
              ),
              const SizedBox(height: 16),
              const Text(
                '면접관이 꼬리 질문을 드립니다\n답변하거나 건너뛸 수 있습니다',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 14, color: Color(0xFF64748B), height: 1.6),
              ),
            ],
          ),
        ),
      _InterviewState.done => const Center(
          child: Icon(Icons.check_circle_rounded,
              size: 64, color: AppTheme.success),
        ),
    };
  }

  // 실전 모드 녹음 중 남은 시간 표시
  String get _remainingTimeLabel {
    final remaining = _maxAnswerSeconds - _elapsedSeconds;
    final m = (remaining ~/ 60).toString().padLeft(2, '0');
    final s = (remaining % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Widget _buildActionButtons() {
    return switch (_state) {
      _InterviewState.thinking => FilledButton.icon(
          onPressed: _startRecording,
          icon: const Icon(Icons.mic_rounded),
          label: const Text('지금 바로 답변 시작'),
          style: FilledButton.styleFrom(
            minimumSize: const Size(double.infinity, 52),
            backgroundColor: AppTheme.primary.withValues(alpha: 0.7),
          ),
        ),
      _InterviewState.ready => FilledButton.icon(
          onPressed: _startRecording,
          icon: const Icon(Icons.mic_rounded),
          label: const Text('답변 시작'),
          style: FilledButton.styleFrom(
              minimumSize: const Size(double.infinity, 52)),
        ),
      _InterviewState.recording => FilledButton.icon(
          onPressed: _stopAndProcess,
          icon: const Icon(Icons.stop_rounded),
          label: const Text('답변 완료'),
          style: FilledButton.styleFrom(
            backgroundColor: AppTheme.error,
            minimumSize: const Size(double.infinity, 52),
          ),
        ),
      _InterviewState.followUp => Column(
          children: [
            FilledButton.icon(
              onPressed: _startFollowUpRecording,
              icon: const Icon(Icons.mic_rounded),
              label: const Text('꼬리 질문 답변하기'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFF59E0B),
                minimumSize: const Size(double.infinity, 52),
              ),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: _skipFollowUp,
              icon: const Icon(Icons.skip_next_rounded),
              label: const Text('건너뛰기'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                foregroundColor: const Color(0xFF64748B),
                side: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
            ),
          ],
        ),
      _InterviewState.followUpRec => FilledButton.icon(
          onPressed: _stopFollowUpAndEvaluate,
          icon: const Icon(Icons.stop_rounded),
          label: const Text('꼬리 답변 완료'),
          style: FilledButton.styleFrom(
            backgroundColor: AppTheme.error,
            minimumSize: const Size(double.infinity, 52),
          ),
        ),
      _ => const SizedBox.shrink(),
    };
  }
}

// ── 연습 모드 STAR 힌트 카드 ──────────────────────────────────

class _StarHintCard extends StatelessWidget {
  const _StarHintCard();

  static const _steps = [
    (Icons.circle_outlined, 'S — Situation', '관련 배경·상황을 간략히 설명', Color(0xFF6366F1)),
    (Icons.task_alt_rounded, 'T — Task', '내 역할과 해결해야 할 과제', Color(0xFF3B82F6)),
    (Icons.bolt_rounded, 'A — Action', '내가 취한 구체적 행동·방법', Color(0xFF10B981)),
    (Icons.bar_chart_rounded, 'R — Result', '결과·성과 (수치 포함 시 +점수)', Color(0xFFF59E0B)),
  ];

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.lightbulb_rounded,
                    size: 16, color: Color(0xFF94A3B8)),
                const SizedBox(width: 6),
                const Text(
                  'STAR 답변 구조 힌트 (연습 모드)',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ..._steps.map((s) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: s.$4.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child:
                            Icon(s.$1, size: 14, color: s.$4),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              s.$2,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: s.$4,
                              ),
                            ),
                            Text(
                              s.$3,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF64748B),
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: 4),
            const Center(
              child: Text(
                '버튼을 눌러 답변을 시작하세요',
                style:
                    TextStyle(fontSize: 13, color: Color(0xFFCBD5E1)),
              ),
            ),
          ],
        ),
      );
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
          child:
              const Icon(Icons.mic_rounded, size: 40, color: AppTheme.error),
        ),
      );
}
