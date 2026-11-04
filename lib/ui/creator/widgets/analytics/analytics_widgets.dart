import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../gen/l10n/app_localizations.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/themes/brawe_colors.dart';
import '../../../quests/widgets/quest_visuals.dart';
import '../../view_models/creator_analytics_view_model.dart';
import 'analytics_format.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Peças compartilhadas pelas 4 telas de análise.
// ─────────────────────────────────────────────────────────────────────────────

/// Corpo rolável de uma aba: pull-to-refresh + lista de seções.
class AnalyticsTabScroll extends StatelessWidget {
  final Future<void> Function() onRefresh;
  final List<Widget> children;
  const AnalyticsTabScroll({
    super.key,
    required this.onRefresh,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.braweBlue,
      onRefresh: onRefresh,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
        itemCount: children.length,
        itemBuilder: (_, i) => StaggerIn(index: i, child: children[i]),
      ),
    );
  }
}

/// Segmento compacto de período: 7D / 30D / 3M / 1A.
class AnalyticsPeriodSegment extends ConsumerWidget {
  const AnalyticsPeriodSegment({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = S.of(context);
    final colors = context.colors;
    final selected = ref.watch(analyticsPeriodProvider);
    final options = <(String, String)>[
      ('7d', s.analyticsPeriod7d),
      ('30d', s.analyticsPeriod30d),
      ('90d', s.analyticsPeriod90d),
      ('365d', s.analyticsPeriod365d),
    ];
    final idx = options.indexWhere((o) => o.$1 == selected).clamp(0, 3);

    return Container(
      height: 38,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: colors.surfaceHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: LayoutBuilder(
        builder: (context, c) {
          final w = c.maxWidth / options.length;
          return Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOutCubic,
                left: idx * w,
                top: 0,
                bottom: 0,
                width: w,
                child: Container(
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(9),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(
                          alpha: context.isDark ? 0.35 : 0.08,
                        ),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                children: [
                  for (final o in options)
                    Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => ref
                            .read(analyticsPeriodProvider.notifier)
                            .set(o.$1),
                        child: Center(
                          child: AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 200),
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                              color: o.$1 == selected
                                  ? colors.textPrimary
                                  : colors.textSecondary,
                            ),
                            child: Text(o.$2),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Seletor de métrica do gráfico (chips).
class AnalyticsChipToggle extends StatelessWidget {
  final List<String> labels;
  final int selected;
  final Color color;
  final ValueChanged<int> onChanged;
  const AnalyticsChipToggle({
    super.key,
    required this.labels,
    required this.selected,
    required this.color,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Wrap(
      spacing: 8,
      children: [
        for (var i = 0; i < labels.length; i++)
          GestureDetector(
            onTap: () => onChanged(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: i == selected
                    ? color.withValues(alpha: 0.16)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: i == selected ? color : colors.border,
                  width: 1.2,
                ),
              ),
              child: Text(
                labels[i],
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: i == selected ? color : colors.textSecondary,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Selo de variação: ↑ verde / ↓ vermelho; null mostra um traço neutro.
class AnalyticsDelta extends StatelessWidget {
  final double? pct;
  final bool showLabel;
  const AnalyticsDelta({super.key, required this.pct, this.showLabel = false});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final fmt = AnalyticsFmt.of(context);
    final v = pct;
    final Color c;
    final IconData icon;
    final String text;
    if (v == null) {
      c = colors.textTertiary;
      icon = LucideIcons.minus;
      text = '—';
    } else if (v == 0) {
      c = colors.textTertiary;
      icon = LucideIcons.minus;
      text = fmt.percent(0);
    } else if (v > 0) {
      c = AppColors.success;
      icon = LucideIcons.arrowUp;
      text = fmt.percent(v);
    } else {
      c = AppColors.mutedRed;
      icon = LucideIcons.arrowDown;
      text = fmt.percent(v);
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: c.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 11, color: c),
              const SizedBox(width: 2),
              Text(
                text,
                style: TextStyle(
                  color: c,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        if (showLabel) ...[
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              S.of(context).analyticsVsPrevious,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: colors.textTertiary, fontSize: 10.5),
            ),
          ),
        ],
      ],
    );
  }
}

/// Dados de um KPI. [value] é o número bruto; [format] o formata com contagem animada.
class AnalyticsKpi {
  final IconData icon;
  final Color color;
  final String label;
  final double value;
  final String Function(double) format;
  final double? deltaPct;
  final bool hasDelta;
  const AnalyticsKpi({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
    required this.format,
    this.deltaPct,
    this.hasDelta = true,
  });
}

/// Grade de KPIs (2 por linha) com variação % vs. período anterior.
/// [kpis] null = carregando (skeleton).
class AnalyticsKpiGrid extends StatelessWidget {
  final List<AnalyticsKpi>? kpis;
  final int skeletonCount;
  const AnalyticsKpiGrid({super.key, required this.kpis, this.skeletonCount = 2});

  @override
  Widget build(BuildContext context) {
    final count = kpis?.length ?? skeletonCount;
    final rows = <Widget>[];
    for (var i = 0; i < count; i += 2) {
      rows.add(
        Padding(
          padding: EdgeInsets.only(bottom: i + 2 < count ? 10 : 0),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var j = i; j < i + 2; j++) ...[
                  if (j > i) const SizedBox(width: 10),
                  Expanded(
                    child: j < count
                        ? (kpis == null
                              ? const AnalyticsSkeleton(height: 104, radius: 18)
                              : _KpiCard(kpi: kpis![j]))
                        : const SizedBox(),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    }
    return Column(children: rows);
  }
}

class _KpiCard extends StatelessWidget {
  final AnalyticsKpi kpi;
  const _KpiCard({required this.kpi});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GameTile(
      tint: kpi.color,
      depth: 4,
      radius: 18,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: kpi.color.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(kpi.icon, size: 14, color: kpi.color),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  kpi.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: CountUpText(
              // contagem animada em centésimos para preservar casas decimais
              value: (kpi.value * 100).round(),
              format: (n) => kpi.format(n / 100),
              style: TextStyle(
                color: colors.textPrimary,
                fontWeight: FontWeight.w800,
                fontSize: 22,
                height: 1.1,
              ),
            ),
          ),
          const SizedBox(height: 6),
          if (kpi.hasDelta)
            AnalyticsDelta(pct: kpi.deltaPct, showLabel: true)
          else
            const SizedBox(height: 18),
        ],
      ),
    );
  }
}

/// Título de seção.
class AnalyticsSectionTitle extends StatelessWidget {
  final String title;
  final String? subtitle;
  const AnalyticsSectionTitle({super.key, required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: colors.textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
          if (subtitle != null)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                subtitle!,
                style: TextStyle(color: colors.textSecondary, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }
}

/// Cartão que envolve um gráfico, com título, métricas e opção de comparar.
/// [builder] recebe o estado atual de "comparar com período anterior".
class AnalyticsChartPanel extends StatefulWidget {
  final String title;
  final Widget? toolbar;
  final bool canCompare;
  final Widget Function(bool compare) builder;
  final Widget Function(bool compare)? legendBuilder;
  const AnalyticsChartPanel({
    super.key,
    required this.title,
    required this.builder,
    this.toolbar,
    this.legendBuilder,
    this.canCompare = true,
  });

  @override
  State<AnalyticsChartPanel> createState() => _AnalyticsChartPanelState();
}

class _AnalyticsChartPanelState extends State<AnalyticsChartPanel> {
  bool _compare = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final s = S.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.title,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
              ),
              if (widget.canCompare)
                GestureDetector(
                  onTap: () => setState(() => _compare = !_compare),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: _compare
                          ? AppColors.braweBlue.withValues(alpha: 0.14)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: _compare ? AppColors.braweBlue : colors.border,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          LucideIcons.gitCompare,
                          size: 12,
                          color: _compare
                              ? AppColors.braweBlue
                              : colors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          s.analyticsCompare,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: _compare
                                ? AppColors.braweBlue
                                : colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          if (widget.toolbar != null) ...[
            const SizedBox(height: 10),
            widget.toolbar!,
          ],
          const SizedBox(height: 14),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 280),
            child: KeyedSubtree(
              key: ValueKey(_compare),
              child: widget.builder(_compare),
            ),
          ),
          if (widget.legendBuilder != null) ...[
            const SizedBox(height: 10),
            widget.legendBuilder!(_compare),
          ],
        ],
      ),
    );
  }
}

/// Bloco "esqueleto" pulsante para carregamento.
class AnalyticsSkeleton extends StatefulWidget {
  final double height;
  final double radius;
  const AnalyticsSkeleton({super.key, this.height = 220, this.radius = 16});

  @override
  State<AnalyticsSkeleton> createState() => _AnalyticsSkeletonState();
}

class _AnalyticsSkeletonState extends State<AnalyticsSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AnimatedBuilder(
      animation: _c,
      builder: (_, _) => Container(
        height: widget.height,
        decoration: BoxDecoration(
          color: Color.lerp(
            colors.shimmerBase,
            colors.shimmerHighlight,
            Curves.easeInOut.transform(_c.value),
          ),
          borderRadius: BorderRadius.circular(widget.radius),
        ),
      ),
    );
  }
}

/// Erro com botão "Tentar novamente".
class AnalyticsErrorView extends StatelessWidget {
  final VoidCallback onRetry;
  final double height;
  const AnalyticsErrorView({super.key, required this.onRetry, this.height = 200});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final s = S.of(context);
    return SizedBox(
      height: height,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.cloudOff, size: 30, color: colors.textTertiary),
            const SizedBox(height: 10),
            Text(
              s.analyticsErrorTitle,
              style: TextStyle(
                color: colors.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(LucideIcons.refreshCw, size: 14),
              label: Text(s.analyticsRetry),
            ),
          ],
        ),
      ),
    );
  }
}

/// Cartão genérico (lista/resumo).
class AnalyticsCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  const AnalyticsCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.border),
      ),
      child: child,
    );
  }
}

/// "nos últimos 30 dias" etc., para mensagens de estado vazio.
String analyticsRangeLabel(S s, String period) => switch (period) {
  '7d' => s.analyticsRange7d,
  '90d' => s.analyticsRange90d,
  '365d' => s.analyticsRange365d,
  _ => s.analyticsRange30d,
};
