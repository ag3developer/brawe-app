import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/themes/app_colors.dart';
import '../../core/themes/brawe_colors.dart';
import '../view_models/creator_analytics_view_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Shared analytics chart — CustomPainter (sem dependência fl_chart)
// ─────────────────────────────────────────────────────────────────────────────

class AnalyticsLineChart extends StatelessWidget {
  final List<AnalyticsDataPoint> points;
  final Color color;
  final bool showSecondary;
  final Color secondaryColor;

  const AnalyticsLineChart({
    super.key,
    required this.points,
    required this.color,
    this.showSecondary = false,
    this.secondaryColor = const Color(0xFFEC4899),
  });

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return Center(
        child: Text(
          'Sem dados para o período',
          style: TextStyle(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
      );
    }
    return CustomPaint(
      painter: _LineChartPainter(
        points: points,
        lineColor: color,
        showSecondary: showSecondary,
        secondaryColor: secondaryColor,
        isDark: Theme.of(context).brightness == Brightness.dark,
      ),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  final List<AnalyticsDataPoint> points;
  final Color lineColor;
  final bool showSecondary;
  final Color secondaryColor;
  final bool isDark;

  _LineChartPainter({
    required this.points,
    required this.lineColor,
    required this.showSecondary,
    required this.secondaryColor,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    const hPad = 12.0;
    const vPad = 16.0;
    final chartW = size.width - hPad * 2;
    final chartH = size.height - vPad * 2;

    final maxVal = points.map((p) => p.value).reduce(math.max);
    final maxSec = showSecondary && points.any((p) => p.secondaryValue != null)
        ? points.map((p) => p.secondaryValue ?? 0).reduce(math.max)
        : 0.0;
    final maxY = math.max(maxVal, maxSec) * 1.1;
    if (maxY == 0) return;

    double x(int i) => hPad + (i / (points.length - 1)) * chartW;
    double y(double v) => vPad + chartH - (v / maxY) * chartH;

    // Gradient fill
    final fillPath = Path();
    fillPath.moveTo(x(0), y(points[0].value));
    for (int i = 1; i < points.length; i++) {
      final cp1x = x(i - 1) + (x(i) - x(i - 1)) / 2;
      fillPath.cubicTo(
        cp1x,
        y(points[i - 1].value),
        cp1x,
        y(points[i].value),
        x(i),
        y(points[i].value),
      );
    }
    fillPath.lineTo(x(points.length - 1), vPad + chartH);
    fillPath.lineTo(x(0), vPad + chartH);
    fillPath.close();

    final gradientFill = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          lineColor.withValues(alpha: isDark ? 0.25 : 0.15),
          lineColor.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, vPad, size.width, chartH));
    canvas.drawPath(fillPath, gradientFill);

    // Main line
    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final linePath = Path();
    linePath.moveTo(x(0), y(points[0].value));
    for (int i = 1; i < points.length; i++) {
      final cp1x = x(i - 1) + (x(i) - x(i - 1)) / 2;
      linePath.cubicTo(
        cp1x,
        y(points[i - 1].value),
        cp1x,
        y(points[i].value),
        x(i),
        y(points[i].value),
      );
    }
    canvas.drawPath(linePath, linePaint);

    // Secondary line (peak_viewers)
    if (showSecondary) {
      final secPaint = Paint()
        ..color = secondaryColor
        ..strokeWidth = 1.5
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      final secPath = Path();
      bool first = true;
      for (int i = 0; i < points.length; i++) {
        final sv = points[i].secondaryValue;
        if (sv == null) continue;
        final px = x(i);
        final py = y(sv);
        if (first) {
          secPath.moveTo(px, py);
          first = false;
        } else {
          final cp1x = x(i - 1) + (x(i) - x(i - 1)) / 2;
          secPath.cubicTo(
            cp1x,
            y(points[i - 1].secondaryValue ?? 0),
            cp1x,
            py,
            px,
            py,
          );
        }
      }
      canvas.drawPath(secPath, secPaint);
    }

    // Dots on last and max
    final maxIdx = points.indexWhere((p) => p.value == maxVal);
    for (final idx in {0, maxIdx, points.length - 1}) {
      canvas.drawCircle(
        Offset(x(idx), y(points[idx].value)),
        4,
        Paint()..color = lineColor,
      );
      canvas.drawCircle(
        Offset(x(idx), y(points[idx].value)),
        3,
        Paint()..color = Colors.white,
      );
    }

    // Horizontal grid lines (4)
    final gridPaint = Paint()
      ..color = (isDark ? Colors.white : Colors.black).withValues(alpha: 0.07)
      ..strokeWidth = 1;
    for (int g = 0; g <= 3; g++) {
      final gy = vPad + (g / 3) * chartH;
      canvas.drawLine(Offset(hPad, gy), Offset(hPad + chartW, gy), gridPaint);
    }
  }

  @override
  bool shouldRepaint(_LineChartPainter old) => old.points != points;
}

// ── Bar chart para gifts / produtos ──────────────────────────────────────────

class AnalyticsBarChart extends StatelessWidget {
  final List<_BarData> bars;
  final Color color;

  const AnalyticsBarChart({super.key, required this.bars, required this.color});

  @override
  Widget build(BuildContext context) {
    if (bars.isEmpty) {
      return Center(
        child: Text(
          'Sem dados',
          style: TextStyle(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
      );
    }
    return CustomPaint(
      painter: _BarChartPainter(
        bars: bars,
        color: color,
        isDark: Theme.of(context).brightness == Brightness.dark,
      ),
    );
  }
}

class _BarData {
  final String label;
  final double value;
  const _BarData(this.label, this.value);
}

class _BarChartPainter extends CustomPainter {
  final List<_BarData> bars;
  final Color color;
  final bool isDark;

  _BarChartPainter({
    required this.bars,
    required this.color,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (bars.isEmpty) return;
    const vPad = 8.0;
    const hPad = 8.0;
    final maxVal = bars.map((b) => b.value).reduce(math.max);
    if (maxVal == 0) return;

    final barW = (size.width - hPad * 2) / bars.length * 0.65;
    final gap = (size.width - hPad * 2) / bars.length;
    final chartH = size.height - vPad * 2 - 20;

    for (int i = 0; i < bars.length; i++) {
      final barH = (bars[i].value / maxVal) * chartH;
      final cx = hPad + i * gap + gap / 2;
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(cx - barW / 2, vPad + chartH - barH, barW, barH),
        const Radius.circular(4),
      );
      canvas.drawRRect(
        rect,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [color, color.withValues(alpha: 0.5)],
          ).createShader(rect.outerRect),
      );

      // label
      final tp = TextPainter(
        text: TextSpan(
          text: bars[i].label,
          style: TextStyle(
            fontSize: 9,
            color: (isDark ? Colors.white : Colors.black).withValues(
              alpha: 0.5,
            ),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: gap);
      tp.paint(canvas, Offset(cx - tp.width / 2, vPad + chartH + 4));
    }
  }

  @override
  bool shouldRepaint(_BarChartPainter old) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// Widgets compartilhados entre as telas de analytics
// ─────────────────────────────────────────────────────────────────────────────

/// Seletor de período (7D / 30D / 3M / 1A).
class AnalyticsPeriodPicker extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  const AnalyticsPeriodPicker({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    const options = ['7d', '30d', '90d', '365d'];
    const labels = ['7D', '30D', '3M', '1A'];
    return Row(
      children: List.generate(options.length, (i) {
        final active = selected == options[i];
        return GestureDetector(
          onTap: () => onChanged(options[i]),
          child: Container(
            margin: const EdgeInsets.only(right: 4),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: active ? AppColors.electricPurple : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              labels[i],
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: active ? Colors.white : context.colors.textSecondary,
              ),
            ),
          ),
        );
      }),
    );
  }
}

/// Container para o gráfico com borda e fundo.
class AnalyticsChartCard extends StatelessWidget {
  final Widget child;
  const AnalyticsChartCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.04)
            : Colors.black.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.07)
              : Colors.black.withValues(alpha: 0.06),
        ),
      ),
      padding: const EdgeInsets.all(12),
      child: child,
    );
  }
}

/// Skeleton do gráfico enquanto carrega.
class AnalyticsChartSkeleton extends StatelessWidget {
  const AnalyticsChartSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.black.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
    );
  }
}

/// Erro ao carregar dados do gráfico.
class AnalyticsChartError extends StatelessWidget {
  final String message;
  const AnalyticsChartError({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(LucideIcons.alertCircle, color: context.colors.textTertiary),
          const SizedBox(height: 6),
          Text(
            'Erro ao carregar dados',
            style: TextStyle(color: context.colors.textSecondary, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

/// Dados de um KPI para o AnalyticsKpiRow.
class AnalyticsKpiItem {
  final IconData icon;
  final Color color;
  final String label;
  final String value;
  const AnalyticsKpiItem({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });
}

/// Linha de 2 cards de KPI.
class AnalyticsKpiRow extends StatelessWidget {
  /// Null = skeleton loading
  final List<AnalyticsKpiItem>? items;
  const AnalyticsKpiRow({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (items == null) {
      return Row(
        children: List.generate(
          2,
          (_) => Expanded(
            child: Container(
              height: 72,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.black.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      );
    }
    return Row(
      children: items!.asMap().entries.map((e) {
        final item = e.value;
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: e.key < items!.length - 1 ? 8 : 0),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: item.color.withValues(alpha: isDark ? 0.12 : 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(item.icon, color: item.color, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.value,
                        style: TextStyle(
                          color: context.colors.textPrimary,
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        item.label,
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
        );
      }).toList(),
    );
  }
}

/// Ponto de legenda colorida.
class AnalyticsLegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const AnalyticsLegendDot({
    super.key,
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: context.colors.textSecondary),
        ),
      ],
    );
  }
}

/// Skeleton de lista enquanto carrega.
class AnalyticsListSkeleton extends StatelessWidget {
  final int count;
  const AnalyticsListSkeleton({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: List.generate(
        count,
        (i) => Container(
          height: 52,
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.black.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

/// Formata número grande (1.5k, 2.3M).
String analyticsFormatCount(int n) {
  if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
  if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}k';
  return '$n';
}
