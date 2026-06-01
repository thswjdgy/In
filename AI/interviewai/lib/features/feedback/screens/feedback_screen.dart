import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../feedback/models/feedback_model.dart';
import '../../../shared/theme/app_theme.dart';

class FeedbackScreen extends StatelessWidget {
  final FeedbackModel feedback;
  final String question;
  final String answer;
  final String? followUpQuestion;
  final bool isLast;
  final VoidCallback? onNext;
  final VoidCallback? onFinish;

  const FeedbackScreen({
    super.key,
    required this.feedback,
    required this.question,
    required this.answer,
    this.followUpQuestion,
    required this.isLast,
    this.onNext,
    this.onFinish,
  });

  Color _scoreColor(int score) {
    if (score >= 80) return AppTheme.success;
    if (score >= 60) return const Color(0xFFF59E0B);
    return AppTheme.error;
  }

  String _scoreLabel(int score) {
    if (score >= 80) return '우수';
    if (score >= 60) return '양호';
    return '보완 필요';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('AI 피드백'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ScoreCard(
                score: feedback.score,
                color: _scoreColor(feedback.score),
                label: _scoreLabel(feedback.score),
                summary: feedback.summary,
              ),
              const SizedBox(height: 16),
              _Section(
                icon: Icons.help_outline_rounded,
                title: '면접 질문',
                color: AppTheme.primary,
                child: Text(
                  question,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.6,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _Section(
                icon: Icons.mic_rounded,
                title: '내 답변',
                color: const Color(0xFF64748B),
                child: Text(
                  answer.isEmpty ? '(답변 없음)' : answer,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.6,
                    color: Color(0xFF475569),
                  ),
                ),
              ),
              // 잘한 점
              const SizedBox(height: 12),
              _Section(
                icon: Icons.thumb_up_rounded,
                title: '잘한 점',
                color: AppTheme.success,
                child: feedback.goodPoint.isNotEmpty
                    ? Text(
                        feedback.goodPoint,
                        style: const TextStyle(
                            fontSize: 14, height: 1.6, color: Color(0xFF334155)),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: feedback.strengths
                            .map((s) => _BulletItem(
                                text: s, color: AppTheme.success))
                            .toList(),
                      ),
              ),
              // 아쉬운 점
              const SizedBox(height: 12),
              _Section(
                icon: Icons.lightbulb_rounded,
                title: '아쉬운 점',
                color: const Color(0xFFF59E0B),
                child: feedback.badPoint.isNotEmpty
                    ? Text(
                        feedback.badPoint,
                        style: const TextStyle(
                            fontSize: 14, height: 1.6, color: Color(0xFF334155)),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: feedback.improvements
                            .map((s) => _BulletItem(
                                text: s,
                                color: const Color(0xFFF59E0B)))
                            .toList(),
                      ),
              ),
              // AI 모범 답변
              if (feedback.betterVersion.isNotEmpty) ...[
                const SizedBox(height: 12),
                _BetterVersionCard(text: feedback.betterVersion),
              ],
              // 말하기 분석 (측정값이 있을 때만)
              if (feedback.speechSpeedCpm > 0 ||
                  feedback.fillerWords.isNotEmpty) ...[
                const SizedBox(height: 12),
                _SpeechAnalysisCard(
                  speedCpm: feedback.speechSpeedCpm,
                  fillerWords: feedback.fillerWords,
                ),
              ],
              // 꼬리 질문 (있을 때만)
              if (followUpQuestion != null && followUpQuestion!.isNotEmpty) ...[
                const SizedBox(height: 12),
                _FollowUpCard(question: followUpQuestion!),
              ],
              const SizedBox(height: 12),
              _HintButton(question: question, improvements: feedback.improvements),
              const SizedBox(height: 28),
              if (isLast) ...[
                _ActionButton(
                  label: '전체 결과 보기',
                  icon: Icons.bar_chart_rounded,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4F46E5), Color(0xFF6366F1)],
                  ),
                  onTap: () {
                    context.pop();
                    onFinish?.call();
                  },
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => context.go('/'),
                  icon: const Icon(Icons.home_rounded),
                  label: const Text('처음으로'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 52),
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                    foregroundColor: const Color(0xFF64748B),
                  ),
                ),
              ] else
                _ActionButton(
                  label: '다음 질문',
                  icon: Icons.arrow_forward_rounded,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4F46E5), Color(0xFF6366F1)],
                  ),
                  onTap: () {
                    context.pop();
                    onNext?.call();
                  },
                ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

// ── 점수 카드 (원형 게이지) ───────────────────────────────────

class _ScoreCard extends StatelessWidget {
  final int score;
  final Color color;
  final String label;
  final String summary;

  const _ScoreCard({
    required this.score,
    required this.color,
    required this.label,
    required this.summary,
  });

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            _ScoreGauge(score: score, color: color),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    summary,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: Color(0xFF475569),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}

class _ScoreGauge extends StatelessWidget {
  final int score;
  final Color color;

  const _ScoreGauge({required this.score, required this.color});

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 80,
        height: 80,
        child: CustomPaint(
          painter: _GaugePainter(score: score, color: color),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$score',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  '/ 100',
                  style: TextStyle(
                    fontSize: 10,
                    color: color.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}

class _GaugePainter extends CustomPainter {
  final int score;
  final Color color;

  const _GaugePainter({required this.score, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 6;

    // 배경 원
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = color.withValues(alpha: 0.1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8,
    );

    // 점수 호
    final rect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawArc(
      rect,
      -pi / 2,
      2 * pi * (score / 100),
      false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_GaugePainter old) =>
      old.score != score || old.color != color;
}

// ── 섹션 카드 ─────────────────────────────────────────────────

class _Section extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final Widget child;

  const _Section({
    required this.icon,
    required this.title,
    required this.color,
    required this.child,
  });

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 16),
                const SizedBox(width: 6),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            child,
          ],
        ),
      );
}

class _BulletItem extends StatelessWidget {
  final String text;
  final Color color;

  const _BulletItem({required this.text, required this.color});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 7),
              child: CircleAvatar(radius: 3, backgroundColor: color),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: Color(0xFF334155),
                ),
              ),
            ),
          ],
        ),
      );
}

// ── AI 모범 답변 카드 ─────────────────────────────────────────

class _BetterVersionCard extends StatefulWidget {
  final String text;
  const _BetterVersionCard({required this.text});

  @override
  State<_BetterVersionCard> createState() => _BetterVersionCardState();
}

class _BetterVersionCardState extends State<_BetterVersionCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () => setState(() => _expanded = !_expanded),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF0FDF4),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: AppTheme.success.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.auto_awesome_rounded,
                      size: 16, color: AppTheme.success),
                  const SizedBox(width: 6),
                  const Text(
                    'AI 모범 답변',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.success,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    size: 18,
                    color: AppTheme.success,
                  ),
                ],
              ),
              if (_expanded) ...[
                const SizedBox(height: 10),
                const Divider(color: Color(0xFFBBF7D0), height: 1),
                const SizedBox(height: 10),
                Text(
                  widget.text,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.7,
                    color: Color(0xFF166534),
                  ),
                ),
              ] else ...[
                const SizedBox(height: 6),
                Text(
                  widget.text.length > 60
                      ? '${widget.text.substring(0, 60)}...'
                      : widget.text,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF4ADE80),
                    height: 1.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      );
}

// ── 말하기 분석 카드 ──────────────────────────────────────────

class _SpeechAnalysisCard extends StatelessWidget {
  final int speedCpm;
  final Map<String, int> fillerWords;

  const _SpeechAnalysisCard({
    required this.speedCpm,
    required this.fillerWords,
  });

  // 한국어 기준 적정 발화 속도: 분당 200~350자
  String get _speedLabel {
    if (speedCpm < 150) return '너무 느림';
    if (speedCpm < 200) return '약간 느림';
    if (speedCpm <= 350) return '적정 속도';
    if (speedCpm <= 450) return '약간 빠름';
    return '너무 빠름';
  }

  Color get _speedColor {
    if (speedCpm >= 200 && speedCpm <= 350) return AppTheme.success;
    if (speedCpm >= 150 && speedCpm <= 450) return const Color(0xFFF59E0B);
    return AppTheme.error;
  }

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.graphic_eq_rounded,
                    size: 16, color: Color(0xFF6366F1)),
                SizedBox(width: 6),
                Text(
                  '말하기 분석',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6366F1),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            // 발화 속도
            if (speedCpm > 0) ...[
              Row(
                children: [
                  const Icon(Icons.speed_rounded,
                      size: 14, color: Color(0xFF94A3B8)),
                  const SizedBox(width: 6),
                  const Text('발화 속도',
                      style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w500)),
                  const Spacer(),
                  Text(
                    '$speedCpm자/분',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: _speedColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: _speedColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      _speedLabel,
                      style: TextStyle(
                          fontSize: 11,
                          color: _speedColor,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: (speedCpm / 500).clamp(0.0, 1.0),
                  backgroundColor: const Color(0xFFE2E8F0),
                  color: _speedColor,
                  minHeight: 6,
                ),
              ),
              const SizedBox(height: 4),
              const Text('적정 범위: 200~350자/분 (한국어 기준)',
                  style: TextStyle(
                      fontSize: 10, color: Color(0xFFCBD5E1))),
            ],
            // 말버릇
            if (fillerWords.isNotEmpty) ...[
              const SizedBox(height: 14),
              const Divider(color: Color(0xFFF1F5F9), height: 1),
              const SizedBox(height: 14),
              Row(
                children: [
                  const Icon(Icons.record_voice_over_rounded,
                      size: 14, color: Color(0xFF94A3B8)),
                  const SizedBox(width: 6),
                  const Text('감지된 말버릇',
                      style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w500)),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: (fillerWords.entries.toList()
                      ..sort((a, b) => b.value.compareTo(a.value)))
                    .map((e) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: e.value >= 3
                                ? AppTheme.error.withValues(alpha: 0.08)
                                : const Color(0xFFFFF7ED),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: e.value >= 3
                                  ? AppTheme.error.withValues(alpha: 0.3)
                                  : const Color(0xFFF59E0B)
                                      .withValues(alpha: 0.3),
                            ),
                          ),
                          child: Text(
                            '"${e.key}" ${e.value}회',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: e.value >= 3
                                  ? AppTheme.error
                                  : const Color(0xFFF59E0B),
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ] else if (speedCpm > 0) ...[
              const SizedBox(height: 10),
              const Row(
                children: [
                  Icon(Icons.check_circle_rounded,
                      size: 14, color: AppTheme.success),
                  SizedBox(width: 6),
                  Text('말버릇 없음 — 깔끔한 답변이었습니다!',
                      style: TextStyle(
                          fontSize: 12, color: AppTheme.success)),
                ],
              ),
            ],
          ],
        ),
      );
}

// ── 꼬리 질문 카드 ─────────────────────────────────────────────

class _FollowUpCard extends StatelessWidget {
  final String question;
  const _FollowUpCard({required this.question});

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFBEB),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: const Color(0xFFF59E0B).withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.reply_rounded,
                    size: 16, color: Color(0xFFF59E0B)),
                SizedBox(width: 6),
                Text(
                  '예상 꼬리 질문',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFF59E0B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              question,
              style: const TextStyle(
                fontSize: 14,
                height: 1.6,
                color: Color(0xFF78350F),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
}

// ── 모범 답변 힌트 ────────────────────────────────────────────

class _HintButton extends StatelessWidget {
  final String question;
  final List<String> improvements;

  const _HintButton({required this.question, required this.improvements});

  void _show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ModelAnswerSheet(
        question: question,
        improvements: improvements,
      ),
    );
  }

  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
        onPressed: () => _show(context),
        icon: const Icon(Icons.tips_and_updates_rounded, size: 16),
        label: const Text('모범 답변 구조 보기'),
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, 46),
          side: BorderSide(color: AppTheme.primary.withValues(alpha: 0.4)),
          foregroundColor: AppTheme.primary,
        ),
      );
}

class _ModelAnswerSheet extends StatelessWidget {
  final String question;
  final List<String> improvements;

  const _ModelAnswerSheet({required this.question, required this.improvements});

  static const _steps = [
    ('S', 'Situation', '관련 상황이나 배경을 구체적으로 설명하세요.'),
    ('T', 'Task', '당신의 역할과 해결해야 할 과제를 명확히 하세요.'),
    ('A', 'Action', '어떤 행동을 취했는지 단계별로 설명하세요.'),
    ('R', 'Result', '행동의 결과와 배운 점을 수치로 표현하면 좋습니다.'),
  ];

  @override
  Widget build(BuildContext context) => DraggableScrollableSheet(
        initialChildSize: 0.65,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        builder: (_, controller) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: controller,
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                  children: [
                    Row(
                      children: [
                        Icon(Icons.tips_and_updates_rounded,
                            color: AppTheme.primary, size: 18),
                        const SizedBox(width: 8),
                        const Text(
                          'STAR 답변 구조',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      question,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF64748B),
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 16),
                    ..._steps.map((s) => _StarStep(
                          letter: s.$1,
                          title: s.$2,
                          guide: s.$3,
                        )),
                    if (improvements.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFBEB),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: const Color(0xFFF59E0B).withValues(alpha: 0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.lightbulb_rounded,
                                    size: 14, color: Color(0xFFF59E0B)),
                                SizedBox(width: 6),
                                Text(
                                  '이번 답변에서 보완하면 좋을 점',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFFF59E0B),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ...improvements.map((imp) => Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Text(
                                    '• $imp',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      height: 1.5,
                                      color: Color(0xFF78350F),
                                    ),
                                  ),
                                )),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}

class _StarStep extends StatelessWidget {
  final String letter;
  final String title;
  final String guide;

  const _StarStep({
    required this.letter,
    required this.title,
    required this.guide,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  letter,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    guide,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.5,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}

// ── 액션 버튼 ─────────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Gradient gradient;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
}
