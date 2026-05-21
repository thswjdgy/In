import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../feedback/models/feedback_model.dart';
import '../../../shared/theme/app_theme.dart';

class ResultScreen extends StatelessWidget {
  final String job;
  final List<Map<String, dynamic>> results;

  const ResultScreen({
    super.key,
    required this.job,
    required this.results,
  });

  int get _avgScore {
    if (results.isEmpty) return 0;
    final total = results.fold<int>(
      0,
      (sum, r) => sum + ((r['feedback'] as FeedbackModel).score),
    );
    return (total / results.length).round();
  }

  Color _scoreColor(int score) {
    if (score >= 80) return AppTheme.success;
    if (score >= 60) return const Color(0xFFF59E0B);
    return AppTheme.error;
  }

  String _overallLabel(int score) {
    if (score >= 80) return '훌륭한 면접이었습니다!';
    if (score >= 60) return '준수한 면접이었습니다.';
    return '더 연습이 필요합니다.';
  }

  @override
  Widget build(BuildContext context) {
    final avg = _avgScore;
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Column(
                  children: [
                    _buildTopBar(context),
                    const SizedBox(height: 28),
                    _buildSummaryCard(avg),
                    const SizedBox(height: 28),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '문항별 결과',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _QuestionResultCard(
                      index: i + 1,
                      question: results[i]['question'] as String,
                      answer: results[i]['answer'] as String,
                      feedback: results[i]['feedback'] as FeedbackModel,
                      scoreColor: _scoreColor(
                          (results[i]['feedback'] as FeedbackModel).score),
                    ),
                  ),
                  childCount: results.length,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                child: _buildButtons(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) => Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '면접 결과',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  job,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded, color: Color(0xFF94A3B8)),
            onPressed: () => context.go('/'),
          ),
        ],
      );

  Widget _buildSummaryCard(int avg) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              _scoreColor(avg).withValues(alpha: 0.08),
              _scoreColor(avg).withValues(alpha: 0.03),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _scoreColor(avg).withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            _LargeGauge(score: avg, color: _scoreColor(avg)),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '평균 점수',
                    style: TextStyle(
                      fontSize: 12,
                      color: _scoreColor(avg).withValues(alpha: 0.8),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _overallLabel(avg),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${results.length}문제 완료',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _buildButtons(BuildContext context) => Column(
        children: [
          GestureDetector(
            onTap: () => context.go('/'),
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4F46E5), Color(0xFF6366F1)],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.replay_rounded, color: Colors.white, size: 18),
                  SizedBox(width: 8),
                  Text(
                    '다시 연습하기',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => context.push('/history'),
            icon: const Icon(Icons.history_rounded),
            label: const Text('면접 기록 보기'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 52),
              side: const BorderSide(color: Color(0xFFE2E8F0)),
              foregroundColor: const Color(0xFF64748B),
            ),
          ),
        ],
      );
}

// ── 큰 원형 게이지 ────────────────────────────────────────────

class _LargeGauge extends StatelessWidget {
  final int score;
  final Color color;

  const _LargeGauge({required this.score, required this.color});

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 90,
        height: 90,
        child: CustomPaint(
          painter: _GaugePainter(score: score, color: color),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$score',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  '점',
                  style: TextStyle(
                    fontSize: 11,
                    color: color.withValues(alpha: 0.7),
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
    final radius = size.width / 2 - 7;

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = color.withValues(alpha: 0.12)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 9,
    );

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * (score / 100),
      false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 9
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_GaugePainter old) =>
      old.score != score || old.color != color;
}

// ── 문항별 결과 카드 ──────────────────────────────────────────

class _QuestionResultCard extends StatelessWidget {
  final int index;
  final String question;
  final String answer;
  final FeedbackModel feedback;
  final Color scoreColor;

  const _QuestionResultCard({
    required this.index,
    required this.question,
    required this.answer,
    required this.feedback,
    required this.scoreColor,
  });

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            childrenPadding:
                const EdgeInsets.fromLTRB(16, 0, 16, 16),
            leading: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: scoreColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '$index',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: scoreColor,
                  ),
                ),
              ),
            ),
            title: Text(
              question,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1E293B),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: scoreColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${feedback.score}점',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: scoreColor,
                ),
              ),
            ),
            children: [
              if (answer.isNotEmpty) ...[
                _ExpandedRow(
                  label: '내 답변',
                  color: const Color(0xFF64748B),
                  text: answer,
                ),
                const SizedBox(height: 10),
              ],
              if (feedback.strengths.isNotEmpty)
                _ExpandedRow(
                  label: '잘한 점',
                  color: AppTheme.success,
                  text: feedback.strengths.map((s) => '• $s').join('\n'),
                ),
              if (feedback.improvements.isNotEmpty) ...[
                const SizedBox(height: 10),
                _ExpandedRow(
                  label: '보완할 점',
                  color: const Color(0xFFF59E0B),
                  text:
                      feedback.improvements.map((s) => '• $s').join('\n'),
                ),
              ],
            ],
          ),
        ),
      );
}

class _ExpandedRow extends StatelessWidget {
  final String label;
  final Color color;
  final String text;

  const _ExpandedRow({
    required this.label,
    required this.color,
    required this.text,
  });

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              height: 1.5,
              color: Color(0xFF475569),
            ),
          ),
        ],
      );
}
