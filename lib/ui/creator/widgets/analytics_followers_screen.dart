import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'dart:math' as math;

import '../../../gen/l10n/app_localizations.dart';
import '../../core/themes/app_colors.dart';
import '../../core/themes/brawe_colors.dart';
import '../view_models/creator_analytics_view_model.dart';
import 'analytics_chart_painter.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ANALYTICS — SEGUIDORES / CRESCIMENTO
// GET /social/stats/:userId → followers_count, following_count
// GET /analytics/viewers   → proxy de tendência de engajamento
// ─────────────────────────────────────────────────────────────────────────────

class AnalyticsFollowersScreen extends ConsumerWidget {
  const AnalyticsFollowersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = S.of(context);
    final period = ref.watch(analyticsPeriodProvider);
    final socialAsync = ref.watch(creatorSocialStatsProvider);
    final viewersAsync = ref.watch(viewersHistoryProvider(period));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: context.colors.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: context.colors.background.withValues(alpha: 0.88),
        elevation: 0,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: const SizedBox.expand(),
          ),
        ),
        leading: IconButton(
          icon: Icon(
            LucideIcons.arrowLeft,
            size: 20,
            color: context.colors.textPrimary,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          s.analyticsFollowersTitle,
          style: TextStyle(
            color: context.colors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 17,
          ),
        ),
        actions: [
          AnalyticsPeriodPicker(
            selected: period,
            onChanged: (p) => ref.read(analyticsPeriodProvider.notifier).set(p),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + kToolbarHeight + 16,
              left: 16,
              right: 16,
              bottom: 32,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // KPI banners
                socialAsync.when(
                  loading: () => const AnalyticsKpiRow(items: null),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (d) => AnalyticsKpiRow(
                    items: [
                      AnalyticsKpiItem(
                        icon: LucideIcons.users,
                        color: const Color(0xFF8B5CF6),
                        label: 'Seguidores',
                        value: analyticsFormatCount(
                          (d['followers_count'] as num?)?.toInt() ?? 0,
                        ),
                      ),
                      AnalyticsKpiItem(
                        icon: LucideIcons.userPlus,
                        color: const Color(0xFF10B981),
                        label: 'Seguindo',
                        value: analyticsFormatCount(
                          (d['following_count'] as num?)?.toInt() ?? 0,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  s.analyticsFollowersTrendTitle,
                  style: TextStyle(
                    color: context.colors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                Text(
                  s.analyticsFollowersTrendSubtitle,
                  style: TextStyle(
                    color: context.colors.textSecondary,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 10),
                AnalyticsLegendDot(color: const Color(0xFF8B5CF6), label: s.analyticsFollowersLegendEngagement),
                const SizedBox(height: 8),

                viewersAsync.when(
                  loading: () => const AnalyticsChartSkeleton(),
                  error: (e, _) => AnalyticsChartError(message: '$e'),
                  data: (points) => AnalyticsChartCard(
                    child: CustomPaint(
                      painter: _GrowthChartPainter(
                        points: points,
                        color: const Color(0xFF8B5CF6),
                        isDark: isDark,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Breakdown
                socialAsync.when(
                  loading: () => const AnalyticsListSkeleton(count: 3),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (d) => _FollowerBreakdown(data: d, isDark: isDark),
                ),

                const SizedBox(height: 24),
                _GrowthTips(),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ── GrowthChartPainter ────────────────────────────────────────────────────────

class _GrowthChartPainter extends CustomPainter {
  final List<AnalyticsDataPoint> points;
  final Color color;
  final bool isDark;

  _GrowthChartPainter({
    required this.points,
    required this.color,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    const hPad = 12.0;
    const vPad = 16.0;
    final chartW = size.width - hPad * 2;
    final chartH = size.height - vPad * 2;

    double cumulative = 0;
    final cumPoints = points.map((p) {
      cumulative += p.value;
      return cumulative;
    }).toList();

    final maxVal = cumPoints.isEmpty ? 1.0 : cumPoints.last * 1.1;

    double x(int i) => hPad + (i / (points.length - 1)) * chartW;
    double y(double v) => vPad + chartH - (v / maxVal) * chartH;

    final fillPath = Path();
    fillPath.moveTo(x(0), y(cumPoints[0]));
    for (int i = 1; i < cumPoints.length; i++) {
      final cp1x = x(i - 1) + (x(i) - x(i - 1)) / 2;
      fillPath.cubicTo(
        cp1x,
        y(cumPoints[i - 1]),
        cp1x,
        y(cumPoints[i]),
        x(i),
        y(cumPoints[i]),
      );
    }
    fillPath.lineTo(x(cumPoints.length - 1), vPad + chartH);
    fillPath.lineTo(x(0), vPad + chartH);
    fillPath.close();

    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            color.withValues(alpha: isDark ? 0.3 : 0.18),
            color.withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromLTWH(0, vPad, size.width, chartH)),
    );

    final linePath = Path();
    linePath.moveTo(x(0), y(cumPoints[0]));
    for (int i = 1; i < cumPoints.length; i++) {
      final cp1x = x(i - 1) + (x(i) - x(i - 1)) / 2;
      linePath.cubicTo(
        cp1x,
        y(cumPoints[i - 1]),
        cp1x,
        y(cumPoints[i]),
        x(i),
        y(cumPoints[i]),
      );
    }
    canvas.drawPath(
      linePath,
      Paint()
        ..color = color
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke,
    );

    final gridPaint = Paint()
      ..color = (isDark ? Colors.white : Colors.black).withValues(alpha: 0.06)
      ..strokeWidth = 1;
    for (int g = 0; g <= 3; g++) {
      final gy = vPad + (g / 3) * chartH;
      canvas.drawLine(Offset(hPad, gy), Offset(hPad + chartW, gy), gridPaint);
    }
  }

  @override
  bool shouldRepaint(_GrowthChartPainter old) => old.points != points;
}

// ── Breakdown ─────────────────────────────────────────────────────────────────

class _FollowerBreakdown extends StatelessWidget {
  final Map<String, dynamic> data;
  final bool isDark;
  const _FollowerBreakdown({required this.data, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final followers = (data['followers_count'] as num?)?.toInt() ?? 0;
    final following = (data['following_count'] as num?)?.toInt() ?? 0;
    final totalLives = (data['total_lives'] as num?)?.toInt() ?? 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.04)
            : Colors.black.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.07)
              : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.of(context).analyticsFollowersSummaryTitle,
            style: TextStyle(
              color: context.colors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 12),
          _StatRow(
            label: S.of(context).analyticsFollowersSummaryFollowers,
            value: analyticsFormatCount(followers),
            icon: LucideIcons.users,
            color: const Color(0xFF8B5CF6),
          ),
          const Divider(height: 16),
          _StatRow(
            label: S.of(context).analyticsFollowersSummaryFollowing,
            value: analyticsFormatCount(following),
            icon: LucideIcons.userCheck,
            color: const Color(0xFF3B82F6),
          ),
          const Divider(height: 16),
          _StatRow(
            label: S.of(context).analyticsFollowersSummaryLives,
            value: analyticsFormatCount(totalLives),
            icon: LucideIcons.radio,
            color: const Color(0xFFEC4899),
          ),
          const Divider(height: 16),
          _StatRow(
            label: S.of(context).analyticsFollowersSummaryRatio,
            value: totalLives > 0
                ? (followers / totalLives).toStringAsFixed(1)
                : '—',
            icon: LucideIcons.activity,
            color: const Color(0xFF10B981),
          ),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _StatRow({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(7),
          ),
          child: Icon(icon, size: 14, color: color),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: TextStyle(color: context.colors.textSecondary, fontSize: 13),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: context.colors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ],
    );
  }
}

// ── Dicas ─────────────────────────────────────────────────────────────────────

class _GrowthTips extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tips = [
      (LucideIcons.radio, s.analyticsFollowersTip1Title, s.analyticsFollowersTip1Subtitle),
      (LucideIcons.messageCircle, s.analyticsFollowersTip2Title, s.analyticsFollowersTip2Subtitle),
      (LucideIcons.share2, s.analyticsFollowersTip3Title, s.analyticsFollowersTip3Subtitle),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          s.analyticsFollowersTipsTitle,
          style: TextStyle(
            color: context.colors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        ...tips.map(
          (t) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.04)
                  : Colors.black.withValues(alpha: 0.02),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : Colors.black.withValues(alpha: 0.04),
              ),
            ),
            child: Row(
              children: [
                Icon(t.$1, size: 18, color: AppColors.electricPurple),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t.$2,
                        style: TextStyle(
                          color: context.colors.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        t.$3,
                        style: TextStyle(
                          color: context.colors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
