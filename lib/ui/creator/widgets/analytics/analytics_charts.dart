import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../gen/l10n/app_localizations.dart';
import '../../../core/themes/brawe_colors.dart';
import 'analytics_format.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Gráficos reutilizáveis das telas de análise (baseados em fl_chart):
//  • AnalyticsLineChart — linha com área em degradê, grade, eixos legíveis,
//    tooltip ao tocar e linha tracejada do período anterior.
//  • AnalyticsBarChart  — barras com tooltip (ex.: lives por dia).
// ─────────────────────────────────────────────────────────────────────────────

/// Uma linha do gráfico. Alinhada por posição com as datas do gráfico.
class ChartLine {
  final String label;
  final Color color;
  final List<double> values;

  /// Linha do período anterior: tracejada, sem área, data deslocada no tooltip.
  final bool isPrevious;

  /// Desenha o degradê sob a linha.
  final bool area;
  const ChartLine({
    required this.label,
    required this.color,
    required this.values,
    this.isPrevious = false,
    this.area = false,
  });
}

/// Passo "bonito" (1, 2, 2.5, 5 × 10^n) para a grade do eixo Y.
double niceInterval(double maxValue, {int ticks = 4}) {
  if (maxValue <= 0) return 1;
  final raw = maxValue / ticks;
  final mag = math.pow(10, (math.log(raw) / math.ln10).floor()).toDouble();
  final norm = raw / mag;
  final step = norm <= 1
      ? 1
      : norm <= 2
      ? 2
      : norm <= 5
      ? 5
      : 10;
  return step * mag;
}

double _maxOf(Iterable<ChartLine> lines) {
  var m = 0.0;
  for (final l in lines) {
    for (final v in l.values) {
      if (v > m) m = v;
    }
  }
  return m;
}

/// Revela o gráfico da esquerda para a direita (animação de "desenho").
class _Reveal extends StatelessWidget {
  final Widget child;
  const _Reveal({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (_, t, c) => ClipRect(
        clipper: _RevealClipper(t),
        child: c,
      ),
      child: child,
    );
  }
}

class _RevealClipper extends CustomClipper<Rect> {
  final double t;
  _RevealClipper(this.t);
  @override
  Rect getClip(Size size) => Rect.fromLTWH(0, -8, size.width * t, size.height + 16);
  @override
  bool shouldReclip(_RevealClipper old) => old.t != t;
}

FlTitlesData _titles(
  BuildContext context, {
  required List<DateTime> dates,
  required String Function(double) axisFmt,
  required double yInterval,
  required AnalyticsFmt fmt,
  bool showLeft = true,
}) {
  final colors = context.colors;
  final n = dates.length;
  final step = n <= 8 ? (n <= 7 ? 2 : 1) : math.max(1, ((n - 1) / 4).round());
  final style = TextStyle(
    color: colors.textTertiary,
    fontSize: 10,
    fontWeight: FontWeight.w500,
  );
  return FlTitlesData(
    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    leftTitles: AxisTitles(
      sideTitles: SideTitles(
        showTitles: showLeft,
        reservedSize: 38,
        interval: yInterval,
        getTitlesWidget: (v, meta) {
          if (v == meta.max && v % yInterval != 0) return const SizedBox();
          return SideTitleWidget(
            meta: meta,
            space: 6,
            child: Text(axisFmt(v), style: style),
          );
        },
      ),
    ),
    bottomTitles: AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        reservedSize: 26,
        interval: step.toDouble(),
        getTitlesWidget: (v, meta) {
          final i = v.round();
          if (i < 0 || i >= n || (v - i).abs() > 0.01) return const SizedBox();
          return SideTitleWidget(
            meta: meta,
            space: 8,
            child: Text(fmt.dayShort(dates[i]), style: style),
          );
        },
      ),
    ),
  );
}

FlGridData _grid(BuildContext context, double interval) => FlGridData(
  show: true,
  drawVerticalLine: false,
  horizontalInterval: interval,
  getDrawingHorizontalLine: (_) => FlLine(
    color: context.colors.border.withValues(alpha: context.isDark ? 0.7 : 0.9),
    strokeWidth: 1,
    dashArray: [4, 4],
  ),
);

/// Gráfico de linhas com área em degradê.
class AnalyticsLineChart extends StatelessWidget {
  final List<DateTime> dates;
  final List<ChartLine> lines;

  /// Formata o valor no tooltip (ex.: moeda ou inteiro).
  final String Function(double) valueFormatter;

  /// Dias de deslocamento do período anterior (para a data no tooltip).
  final int periodDays;
  final double height;

  const AnalyticsLineChart({
    super.key,
    required this.dates,
    required this.lines,
    required this.valueFormatter,
    required this.periodDays,
    this.height = 220,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final fmt = AnalyticsFmt.of(context);
    final maxV = _maxOf(lines);
    final interval = niceInterval(maxV);
    final maxY = maxV <= 0 ? 1.0 : (maxV / interval).ceil() * interval;
    final n = dates.length;
    final curved = n <= 60;

    final bars = <LineChartBarData>[
      for (final l in lines)
        LineChartBarData(
          spots: [for (var i = 0; i < n; i++) FlSpot(i.toDouble(), l.values[i])],
          isCurved: curved,
          curveSmoothness: 0.22,
          preventCurveOverShooting: true,
          color: l.color,
          barWidth: l.isPrevious ? 1.6 : (l.area ? 2.8 : 2),
          isStrokeCapRound: true,
          dashArray: l.isPrevious ? [5, 4] : null,
          dotData: FlDotData(
            show: n <= 31 && !l.isPrevious && l.area,
            getDotPainter: (s, p, b, i) => FlDotCirclePainter(
              radius: 2.6,
              color: colors.background,
              strokeWidth: 2,
              strokeColor: l.color,
            ),
          ),
          belowBarData: BarAreaData(
            show: l.area,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                l.color.withValues(alpha: context.isDark ? 0.32 : 0.26),
                l.color.withValues(alpha: 0),
              ],
            ),
          ),
        ),
    ];

    return SizedBox(
      height: height,
      child: _Reveal(
        key: ValueKey(Object.hashAll([n, lines.length, dates.first])),
        child: LineChart(
          LineChartData(
            minX: 0,
            maxX: math.max(1, n - 1).toDouble(),
            minY: 0,
            maxY: maxY,
            gridData: _grid(context, interval),
            borderData: FlBorderData(show: false),
            titlesData: _titles(
              context,
              dates: dates,
              axisFmt: fmt.axis,
              yInterval: interval,
              fmt: fmt,
            ),
            lineBarsData: bars,
            lineTouchData: LineTouchData(
              handleBuiltInTouches: true,
              getTouchedSpotIndicator: (data, indexes) => [
                for (final _ in indexes)
                  TouchedSpotIndicatorData(
                    FlLine(
                      color: colors.textTertiary.withValues(alpha: 0.5),
                      strokeWidth: 1,
                      dashArray: [3, 3],
                    ),
                    FlDotData(
                      getDotPainter: (s, p, b, i) => FlDotCirclePainter(
                        radius: 4.5,
                        color: b.color ?? colors.accentPrimary,
                        strokeWidth: 2.5,
                        strokeColor: colors.background,
                      ),
                    ),
                  ),
              ],
              touchTooltipData: LineTouchTooltipData(
                maxContentWidth: 220,
                tooltipBorderRadius: BorderRadius.circular(12),
                tooltipPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                getTooltipColor: (_) => colors.surfaceElevated,
                fitInsideHorizontally: true,
                fitInsideVertically: true,
                getTooltipItems: (spots) {
                  return [
                    for (final s in spots)
                      () {
                        final line = lines[s.barIndex];
                        final base = dates[s.x.round().clamp(0, n - 1)];
                        final d = line.isPrevious
                            ? base.subtract(Duration(days: periodDays))
                            : base;
                        return LineTooltipItem(
                          '${fmt.dayLong(d)}\n',
                          TextStyle(
                            color: colors.textTertiary,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w500,
                          ),
                          children: [
                            TextSpan(
                              text: valueFormatter(s.y),
                              style: TextStyle(
                                color: line.isPrevious
                                    ? colors.textSecondary
                                    : colors.textPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            TextSpan(
                              text: '  ${line.label}',
                              style: TextStyle(
                                color: line.color,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        );
                      }(),
                  ];
                },
              ),
            ),
          ),
          duration: const Duration(milliseconds: 450),
          curve: Curves.easeOutCubic,
        ),
      ),
    );
  }
}

/// Gráfico de barras (ex.: lives por dia).
class AnalyticsBarChart extends StatelessWidget {
  final List<DateTime> dates;
  final List<double> values;
  final List<double>? previous;
  final Color color;
  final String label;
  final String Function(double) valueFormatter;
  final int periodDays;
  final double height;

  const AnalyticsBarChart({
    super.key,
    required this.dates,
    required this.values,
    required this.color,
    required this.label,
    required this.valueFormatter,
    required this.periodDays,
    this.previous,
    this.height = 220,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final fmt = AnalyticsFmt.of(context);
    final n = dates.length;
    var maxV = values.fold(0.0, math.max);
    if (previous != null) maxV = previous!.fold(maxV, math.max);
    final interval = niceInterval(maxV);
    final maxY = maxV <= 0 ? 1.0 : (maxV / interval).ceil() * interval;
    final w = n > 45 ? 4.0 : (n > 20 ? 6.0 : (n > 8 ? 9.0 : 16.0));

    return SizedBox(
      height: height,
      child: _Reveal(
        key: ValueKey(Object.hashAll([n, previous != null, dates.first])),
        child: BarChart(
          BarChartData(
            maxY: maxY,
            minY: 0,
            alignment: BarChartAlignment.spaceAround,
            gridData: _grid(context, interval),
            borderData: FlBorderData(show: false),
            titlesData: _titles(
              context,
              dates: dates,
              axisFmt: fmt.axis,
              yInterval: interval,
              fmt: fmt,
            ),
            barGroups: [
              for (var i = 0; i < n; i++)
                BarChartGroupData(
                  x: i,
                  barsSpace: 2,
                  barRods: [
                    if (previous != null)
                      BarChartRodData(
                        toY: previous![i],
                        width: w * 0.7,
                        color: colors.textTertiary.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    BarChartRodData(
                      toY: values[i],
                      width: w,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(w / 2.2),
                        bottom: const Radius.circular(2),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [color, color.withValues(alpha: 0.55)],
                      ),
                    ),
                  ],
                ),
            ],
            barTouchData: BarTouchData(
              touchTooltipData: BarTouchTooltipData(
                tooltipBorderRadius: BorderRadius.circular(12),
                tooltipPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                getTooltipColor: (_) => colors.surfaceElevated,
                fitInsideHorizontally: true,
                fitInsideVertically: true,
                getTooltipItem: (group, gi, rod, ri) {
                  final isPrev = previous != null && ri == 0;
                  final base = dates[group.x];
                  final d = isPrev
                      ? base.subtract(Duration(days: periodDays))
                      : base;
                  return BarTooltipItem(
                    '${fmt.dayLong(d)}\n',
                    TextStyle(
                      color: colors.textTertiary,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w500,
                    ),
                    children: [
                      TextSpan(
                        text: valueFormatter(rod.toY),
                        style: TextStyle(
                          color: isPrev
                              ? colors.textSecondary
                              : colors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      TextSpan(
                        text:
                            '  ${isPrev ? S.of(context).analyticsPreviousPeriod : label}',
                        style: TextStyle(
                          color: isPrev ? colors.textTertiary : color,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          duration: const Duration(milliseconds: 450),
          curve: Curves.easeOutCubic,
        ),
      ),
    );
  }
}

/// Legenda (bolinha ou traço tracejado + rótulo).
class AnalyticsLegend extends StatelessWidget {
  final List<({Color color, String label, bool dashed})> items;
  const AnalyticsLegend({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 14,
      runSpacing: 4,
      children: [
        for (final it in items)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (it.dashed)
                SizedBox(
                  width: 16,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      for (var i = 0; i < 3; i++)
                        Container(width: 3.5, height: 2, color: it.color),
                    ],
                  ),
                )
              else
                Container(
                  width: 9,
                  height: 9,
                  decoration: BoxDecoration(
                    color: it.color,
                    shape: BoxShape.circle,
                  ),
                ),
              const SizedBox(width: 5),
              Text(
                it.label,
                style: TextStyle(
                  fontSize: 11,
                  color: context.colors.textSecondary,
                ),
              ),
            ],
          ),
      ],
    );
  }
}

/// Estado vazio do gráfico: linha fantasma + mensagem.
class AnalyticsEmptyChart extends StatelessWidget {
  final double height;
  final IconData icon;
  const AnalyticsEmptyChart({
    super.key,
    this.height = 220,
    this.icon = LucideIcons.chartLine,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final s = S.of(context);
    return SizedBox(
      height: height,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: CustomPaint(painter: _GhostPainter(colors.border)),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: colors.surfaceHighest,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 22, color: colors.textTertiary),
              ),
              const SizedBox(height: 10),
              Text(
                s.analyticsNoDataTitle,
                style: TextStyle(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                s.analyticsNoDataSubtitle,
                textAlign: TextAlign.center,
                style: TextStyle(color: colors.textSecondary, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GhostPainter extends CustomPainter {
  final Color color;
  _GhostPainter(this.color);
  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()
      ..color = color.withValues(alpha: 0.6)
      ..strokeWidth = 1;
    for (var i = 0; i < 4; i++) {
      final y = size.height * (i / 3) * 0.9 + 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }
    final p = Path()..moveTo(0, size.height * 0.7);
    p.cubicTo(size.width * 0.25, size.height * 0.4, size.width * 0.4,
        size.height * 0.8, size.width * 0.6, size.height * 0.5);
    p.cubicTo(size.width * 0.8, size.height * 0.25, size.width * 0.9,
        size.height * 0.55, size.width, size.height * 0.35);
    canvas.drawPath(
      p,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_GhostPainter old) => old.color != color;
}
