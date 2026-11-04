import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../gen/l10n/app_localizations.dart';
import '../../../core/themes/brawe_colors.dart';
import 'analytics_charts.dart';
import 'analytics_data.dart';
import 'analytics_widgets.dart';

/// Cuida de carregando (skeleton), erro (tentar de novo) e vazio de um
/// gráfico alimentado por [AnalyticsSeries]; troca com animação suave.
class AnalyticsAsyncChart extends StatelessWidget {
  final AsyncValue<AnalyticsSeries> async;
  final VoidCallback onRetry;
  final Widget Function(AnalyticsSeries series) builder;

  /// Permite considerar vazio só a métrica exibida (padrão: série toda).
  final bool Function(AnalyticsSeries series)? isEmpty;

  const AnalyticsAsyncChart({
    super.key,
    required this.async,
    required this.onRetry,
    required this.builder,
    this.isEmpty,
  });

  @override
  Widget build(BuildContext context) {
    final Widget child = async.when(
      loading: () => const AnalyticsSkeleton(key: ValueKey('l')),
      error: (_, _) =>
          AnalyticsErrorView(key: const ValueKey('e'), onRetry: onRetry),
      data: (series) => (isEmpty?.call(series) ?? series.isEmpty)
          ? const AnalyticsEmptyChart(key: ValueKey('empty'))
          : KeyedSubtree(key: ValueKey('d-${series.period}'), child: builder(series)),
    );
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: child,
    );
  }
}

/// Monta um [AnalyticsLineChart] a partir de uma série.
/// [useSecond] usa `second` (e `previousSecond`) em vez do valor principal.
Widget seriesLineChart(
  BuildContext context,
  AnalyticsSeries series, {
  required String label,
  required Color color,
  required String Function(double) format,
  bool useSecond = false,
  bool compare = false,
  List<ChartLine> extra = const [],
}) {
  final dates = [for (final p in series.current) p.date];
  final main = [
    for (final p in series.current) useSecond ? (p.second ?? 0) : p.value,
  ];
  final prevSrc = useSecond ? series.previousSecond : series.previous;
  return AnalyticsLineChart(
    dates: dates,
    periodDays: analyticsPeriodDays(series.period),
    valueFormatter: format,
    lines: [
      if (compare && prevSrc != null)
        ChartLine(
          label: S.of(context).analyticsPreviousPeriod,
          color: context.colors.textTertiary,
          values: [for (final p in prevSrc) p.value],
          isPrevious: true,
        ),
      ...extra,
      ChartLine(label: label, color: color, values: main, area: true),
    ],
  );
}

/// Barras a partir de uma série.
Widget seriesBarChart(
  BuildContext context,
  AnalyticsSeries series, {
  required String label,
  required Color color,
  required String Function(double) format,
  bool useSecond = false,
  bool compare = false,
}) {
  final prevSrc = useSecond ? series.previousSecond : series.previous;
  return AnalyticsBarChart(
    dates: [for (final p in series.current) p.date],
    values: [
      for (final p in series.current) useSecond ? (p.second ?? 0) : p.value,
    ],
    previous: compare && prevSrc != null
        ? [for (final p in prevSrc) p.value]
        : null,
    color: color,
    label: label,
    valueFormatter: format,
    periodDays: analyticsPeriodDays(series.period),
  );
}

/// Legenda padrão: séries do gráfico + "Período anterior" quando comparando.
Widget seriesLegend(
  BuildContext context,
  List<({Color color, String label})> series,
  bool compare,
) {
  return AnalyticsLegend(
    items: [
      for (final it in series) (color: it.color, label: it.label, dashed: false),
      if (compare)
        (
          color: context.colors.textTertiary,
          label: S.of(context).analyticsPreviousPeriod,
          dashed: true,
        ),
    ],
  );
}
