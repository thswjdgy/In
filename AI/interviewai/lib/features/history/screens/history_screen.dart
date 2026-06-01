import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../auth/repositories/auth_repository.dart';
import '../../interview/repositories/session_repository.dart';
import '../../interview/models/session_model.dart';
import '../../../shared/theme/app_theme.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          '면접 기록',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 20, color: Color(0xFF0F172A)),
          onPressed: () => context.go('/'),
        ),
      ),
      body: StreamBuilder<LocalUser?>(
        stream: AuthRepository().localAuthChanges,
        builder: (context, snap) {
          final user = snap.data;
          if (user == null) return _buildLoginPrompt(context);
          return _HistoryBody(userId: user.uid);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/'),
        backgroundColor: AppTheme.primary,
        icon: const Icon(Icons.mic_rounded, color: Colors.white),
        label: const Text('면접 시작',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildLoginPrompt(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.history_rounded,
                    size: 36, color: AppTheme.primary),
              ),
              const SizedBox(height: 20),
              const Text(
                '면접 기록을 저장하려면\n로그인이 필요합니다',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '로그인하면 모든 세션이 자동 저장됩니다',
                style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
              ),
              const SizedBox(height: 28),
              FilledButton.icon(
                onPressed: () => context.push('/login'),
                icon: const Icon(Icons.login_rounded),
                label: const Text('로그인하기'),
                style: FilledButton.styleFrom(
                    minimumSize: const Size(200, 48)),
              ),
            ],
          ),
        ),
      );
}

// ── 히스토리 본문 ─────────────────────────────────────────────

class _HistoryBody extends StatefulWidget {
  final String userId;
  const _HistoryBody({required this.userId});

  @override
  State<_HistoryBody> createState() => _HistoryBodyState();
}

class _HistoryBodyState extends State<_HistoryBody> {
  late Future<List<SessionSummary>> _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _future = SessionRepository().getLocalSessions(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<SessionSummary>>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final sessions = snap.data ?? [];
        if (sessions.isEmpty) {
          return _buildEmpty(context);
        }
        return RefreshIndicator(
          onRefresh: () async => setState(() => _load()),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Column(
                    children: [
                      _StatsCard(sessions: sessions),
                      const SizedBox(height: 16),
                      if (sessions.length > 1) ...[
                        _ScoreChart(sessions: sessions),
                        const SizedBox(height: 16),
                      ],
                      _WeakAreaTags(sessions: sessions),
                      const SizedBox(height: 16),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '세션 목록',
                          style: TextStyle(
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
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _SessionTile(
                        session: sessions[i],
                        onTap: () => context.push('/session-detail', extra: {
                          'userId': widget.userId,
                          'sessionId': sessions[i].sessionId,
                          'job': sessions[i].job,
                          'score': sessions[i].totalScore,
                        }),
                      ),
                    ),
                    childCount: sessions.length,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmpty(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.inbox_rounded,
                size: 56, color: Color(0xFFCBD5E1)),
            const SizedBox(height: 16),
            const Text('아직 면접 기록이 없습니다',
                style: TextStyle(
                    fontSize: 16, color: Color(0xFF94A3B8))),
            const SizedBox(height: 6),
            const Text('첫 번째 면접을 시작해보세요!',
                style: TextStyle(
                    fontSize: 13, color: Color(0xFFCBD5E1))),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => context.go('/'),
              icon: const Icon(Icons.mic_rounded),
              label: const Text('면접 시작하기'),
              style: FilledButton.styleFrom(
                  minimumSize: const Size(180, 46)),
            ),
          ],
        ),
      );
}

// ── 통계 카드 ─────────────────────────────────────────────────

class _StatsCard extends StatelessWidget {
  final List<SessionSummary> sessions;
  const _StatsCard({required this.sessions});

  @override
  Widget build(BuildContext context) {
    final avg = sessions.isEmpty
        ? 0
        : (sessions.map((s) => s.totalScore).reduce((a, b) => a + b) /
                sessions.length)
            .round();
    final best = sessions.isEmpty
        ? 0
        : sessions.map((s) => s.totalScore).reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primary.withValues(alpha: 0.08),
            AppTheme.primary.withValues(alpha: 0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: AppTheme.primary.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          _StatItem(label: '총 세션', value: '${sessions.length}회'),
          _Divider(),
          _StatItem(label: '평균 점수', value: '$avg점'),
          _Divider(),
          _StatItem(label: '최고 점수', value: '$best점'),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Expanded(
        child: Column(
          children: [
            Text(value,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primary,
                )),
            const SizedBox(height: 2),
            Text(label,
                style: const TextStyle(
                    fontSize: 11, color: Color(0xFF94A3B8))),
          ],
        ),
      );
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        width: 1,
        height: 32,
        color: AppTheme.primary.withValues(alpha: 0.15),
      );
}

// ── 점수 추이 차트 ────────────────────────────────────────────

class _ScoreChart extends StatelessWidget {
  final List<SessionSummary> sessions;
  const _ScoreChart({required this.sessions});

  @override
  Widget build(BuildContext context) {
    final recent = sessions.take(10).toList().reversed.toList();
    final spots = recent.asMap().entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.totalScore.toDouble()))
        .toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('점수 추이 (최근 10회)',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B))),
          const SizedBox(height: 16),
          SizedBox(
            height: 140,
            child: LineChart(LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (_) =>
                    FlLine(color: const Color(0xFFE2E8F0), strokeWidth: 1),
              ),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 32,
                    interval: 25,
                    getTitlesWidget: (v, _) => Text('${v.toInt()}',
                        style: const TextStyle(
                            fontSize: 10, color: Color(0xFF94A3B8))),
                  ),
                ),
                bottomTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
                rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
                topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              minY: 0,
              maxY: 100,
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  color: AppTheme.primary,
                  barWidth: 2.5,
                  dotData: FlDotData(
                    getDotPainter: (_, _, _, _) => FlDotCirclePainter(
                      radius: 4,
                      color: AppTheme.primary,
                      strokeWidth: 2,
                      strokeColor: Colors.white,
                    ),
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    color: AppTheme.primary.withValues(alpha: 0.08),
                  ),
                ),
              ],
            )),
          ),
        ],
      ),
    );
  }
}

// ── 취약 영역 태그 ────────────────────────────────────────────

class _WeakAreaTags extends StatelessWidget {
  final List<SessionSummary> sessions;
  const _WeakAreaTags({required this.sessions});

  @override
  Widget build(BuildContext context) {
    final allWeak = sessions.expand((s) => s.weakAreas).toList();
    if (allWeak.isEmpty) return const SizedBox.shrink();

    final freq = <String, int>{};
    for (final w in allWeak) {
      freq[w] = (freq[w] ?? 0) + 1;
    }
    final tags = (freq.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value)))
        .take(8)
        .map((e) => e.key)
        .toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('자주 나온 취약 영역',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B))),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: tags
                .map((t) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.warning.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: AppTheme.warning.withValues(alpha: 0.3)),
                      ),
                      child: Text('# $t',
                          style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.warning,
                              fontWeight: FontWeight.w500)),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}

// ── 세션 타일 ─────────────────────────────────────────────────

class _SessionTile extends StatelessWidget {
  final SessionSummary session;
  final VoidCallback onTap;
  const _SessionTile({required this.session, required this.onTap});

  Color _scoreColor(int s) {
    if (s >= 80) return AppTheme.success;
    if (s >= 60) return AppTheme.warning;
    return AppTheme.error;
  }

  @override
  Widget build(BuildContext context) {
    final color = _scoreColor(session.totalScore);
    final dateStr =
        DateFormat('yyyy.MM.dd HH:mm').format(session.startedAt);
    final typeLabel =
        session.type == 'technical' ? '직무 면접' : '인성 면접';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${session.totalScore}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    session.job,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _Tag(label: typeLabel),
                      const SizedBox(width: 6),
                      _Tag(label: '${session.questionCount}문제'),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dateStr,
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF94A3B8)),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: Color(0xFFCBD5E1), size: 20),
          ],
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  const _Tag({required this.label});

  @override
  Widget build(BuildContext context) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(label,
            style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w500)),
      );
}
