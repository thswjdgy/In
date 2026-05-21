import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../interview/repositories/session_repository.dart';
import '../../interview/models/session_model.dart';
import '../../../shared/theme/app_theme.dart';

class SessionDetailScreen extends StatelessWidget {
  final String userId;
  final String sessionId;
  final String job;
  final int score;

  const SessionDetailScreen({
    super.key,
    required this.userId,
    required this.sessionId,
    required this.job,
    required this.score,
  });

  @override
  Widget build(BuildContext context) {
    final repo = SessionRepository();
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(job),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: FutureBuilder<List<QuestionResult>>(
        future: repo.getQuestionResults(userId, sessionId),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError || snap.data == null) {
            return const Center(
              child: Text('불러오기 실패', style: TextStyle(color: AppTheme.error)),
            );
          }
          final results = snap.data!;
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Column(
                    children: [
                      _ScoreCard(score: score, count: results.length),
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '질문별 피드백',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _QuestionCard(
                        index: i + 1,
                        result: results[i],
                      ),
                    ),
                    childCount: results.length,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
                  child: OutlinedButton.icon(
                    onPressed: () => context.go('/'),
                    icon: const Icon(Icons.replay_rounded),
                    label: const Text('다시 연습하기'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                      foregroundColor: AppTheme.primary,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ScoreCard extends StatelessWidget {
  final int score;
  final int count;
  const _ScoreCard({required this.score, required this.count});

  Color get _color {
    if (score >= 80) return AppTheme.success;
    if (score >= 60) return AppTheme.warning;
    return AppTheme.error;
  }

  String get _label {
    if (score >= 80) return '훌륭한 면접이었습니다!';
    if (score >= 60) return '준수한 면접이었습니다.';
    return '더 연습이 필요합니다.';
  }

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 72,
              height: 72,
              child: CustomPaint(
                painter: _CirclePainter(score: score, color: _color),
                child: Center(
                  child: Text(
                    '$score',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: _color,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _label,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$count문제 완료',
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
}

class _CirclePainter extends CustomPainter {
  final int score;
  final Color color;
  const _CirclePainter({required this.score, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 6;
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = color.withValues(alpha: 0.12)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8,
    );
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
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
  bool shouldRepaint(_CirclePainter old) =>
      old.score != score || old.color != color;
}

class _QuestionCard extends StatelessWidget {
  final int index;
  final QuestionResult result;
  const _QuestionCard({required this.index, required this.result});

  Color _scoreColor(int s) {
    if (s >= 80) return AppTheme.success;
    if (s >= 60) return AppTheme.warning;
    return AppTheme.error;
  }

  @override
  Widget build(BuildContext context) {
    final color = _scoreColor(result.feedback.score);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          leading: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$index',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ),
          title: Text(
            result.question,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1E293B),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${result.feedback.score}점',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
          children: [
            if (result.answer.isNotEmpty) ...[
              _FeedbackRow(
                  label: '내 답변', color: const Color(0xFF64748B), text: result.answer),
              const SizedBox(height: 8),
            ],
            if (result.feedback.strengths.isNotEmpty) ...[
              _FeedbackRow(
                label: '잘한 점',
                color: AppTheme.success,
                text: result.feedback.strengths.map((s) => '• $s').join('\n'),
              ),
              const SizedBox(height: 8),
            ],
            if (result.feedback.improvements.isNotEmpty)
              _FeedbackRow(
                label: '보완할 점',
                color: AppTheme.warning,
                text: result.feedback.improvements.map((s) => '• $s').join('\n'),
              ),
          ],
        ),
      ),
    );
  }
}

class _FeedbackRow extends StatelessWidget {
  final String label;
  final Color color;
  final String text;
  const _FeedbackRow(
      {required this.label, required this.color, required this.text});

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
