import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../domain/models/creator_agency.dart';
import '../../../../gen/l10n/app_localizations.dart';
import '../../../core/themes/brawe_colors.dart';
import '../../view_models/creator_agency_providers.dart';
import '../creator_state_views.dart';
import 'agency_l10n.dart';
import 'agency_widgets.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Filtro de período (compartilhado entre Resumo e Metas)
// ─────────────────────────────────────────────────────────────────────────────

class AgencyPeriodFilter extends ConsumerWidget {
  const AgencyPeriodFilter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = S.of(context);
    final c = context.colors;
    final selected = ref.watch(agencyMonthProvider);
    final months = agencyRecentMonths();
    final current = months.first;
    return PopupMenuButton<String>(
      tooltip: s.agencyPeriodLabel,
      initialValue: selected,
      onSelected: (m) => ref.read(agencyMonthProvider.notifier).select(m),
      itemBuilder: (_) => [
        for (final m in months)
          PopupMenuItem<String>(value: m, child: Text(agencyPeriodText(context, s, m, current))),
      ],
      child: Container(
        constraints: const BoxConstraints(minHeight: 36),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: c.border),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(LucideIcons.calendarRange, size: 15, color: c.textSecondary),
          const SizedBox(width: 8),
          Flexible(
            child: Text(agencyPeriodText(context, s, selected, current),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: c.textPrimary, fontSize: 13.5, fontWeight: FontWeight.w700)),
          ),
          const SizedBox(width: 4),
          Icon(LucideIcons.chevronDown, size: 16, color: c.textTertiary),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Resumo
// ─────────────────────────────────────────────────────────────────────────────

class AgencySummaryTab extends ConsumerWidget {
  const AgencySummaryTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = S.of(context);
    final month = ref.watch(agencyMonthProvider);
    final perf = ref.watch(agencyPerformanceProvider(month));
    final history = ref.watch(agencyHistoryProvider);

    final header = Align(alignment: Alignment.centerLeft, child: AgencyPeriodFilter());

    final main = perf.when(
      loading: () => const [AgencySkeletonBlock(height: 92), AgencySkeletonBlock(height: 132)],
      error: (_, _) => [
        SizedBox(
          height: 200,
          child: CreatorErrorView(
            message: s.agencyPerfError,
            onRetry: () => ref.invalidate(agencyPerformanceProvider(month)),
          ),
        ),
      ],
      data: (p) {
        final list = history.value;
        int? change;
        if (list != null && p.rank != null) {
          final i = list.indexWhere((e) => e.month == p.month);
          if (i >= 0 && i + 1 < list.length && list[i + 1].rank != null) change = list[i + 1].rank! - p.rank!;
        }
        return [AgencyStatsCard(perf: p), AgencyGoalPositionCard(perf: p, rankChange: change)];
      },
    );

    return AgencyColumns(
      left: [header, ...main],
      right: [AgencyHistoryCard(history: history, onRetry: () => ref.invalidate(agencyHistoryProvider))],
    );
  }
}

/// Os 4 números do mês em UM cartão (grade 2x2; 4 em linha se couber).
class AgencyStatsCard extends StatelessWidget {
  const AgencyStatsCard({super.key, required this.perf});
  final AgencyPerformance perf;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final c = context.colors;
    final cells = <Widget>[
      _StatCell(icon: LucideIcons.clock, label: s.agencyHours, value: '${agencyHoursText(context, perf.hours)} h', color: c.accentPrimary),
      _StatCell(icon: LucideIcons.calendarDays, label: s.agencyDaysLive, value: agencyNumber(context, perf.days), color: c.accentSecondary),
      _StatCell(icon: LucideIcons.gem, label: s.agencyDiamonds, value: agencyNumber(context, perf.diamonds), color: c.accentGold),
      _StatCell(icon: LucideIcons.users, label: s.agencyFollowers, value: agencyNumber(context, perf.followers), color: c.accentPink),
    ];
    return AgencyBox(
      padding: EdgeInsets.zero,
      child: LayoutBuilder(builder: (context, box) {
        if (box.maxWidth >= 520) {
          return IntrinsicHeight(
            child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              for (var i = 0; i < 4; i++) ...[
                if (i > 0) VerticalDivider(width: 1, color: c.divider),
                Expanded(child: cells[i]),
              ],
            ]),
          );
        }
        return Column(children: [
          IntrinsicHeight(
            child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Expanded(child: cells[0]),
              VerticalDivider(width: 1, color: c.divider),
              Expanded(child: cells[1]),
            ]),
          ),
          const AgencyDivider(),
          IntrinsicHeight(
            child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Expanded(child: cells[2]),
              VerticalDivider(width: 1, color: c.divider),
              Expanded(child: cells[3]),
            ]),
          ),
        ]);
      }),
    );
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({required this.icon, required this.label, required this.value, required this.color});
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
        Row(children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 6),
          Expanded(child: Text(label, maxLines: 2, overflow: TextOverflow.ellipsis, style: AgencyText.caption(context))),
        ]),
        const SizedBox(height: 6),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(value, maxLines: 1, style: AgencyText.number(context, size: 22)),
        ),
      ]),
    );
  }
}

/// Meta do mês (progresso combinado) + posição entre os agenciados.
class AgencyGoalPositionCard extends StatelessWidget {
  const AgencyGoalPositionCard({super.key, required this.perf, this.rankChange});
  final AgencyPerformance perf;

  /// Positivo = subiu posições vs. mês anterior; null = sem comparação.
  final int? rankChange;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final c = context.colors;
    final g = perf.guidelines;
    final hasGoal = g.minHours > 0 || g.minDays > 0;
    final pct = (perf.goalProgress * 100).floor();
    final met = hasGoal && g.met;
    final color = met ? c.success : c.accentPrimary;

    Widget? change;
    if (rankChange != null) {
      final IconData icon;
      final String text;
      final Color col;
      if (rankChange! > 0) {
        icon = LucideIcons.arrowUp;
        text = s.agencyRankUp(rankChange!);
        col = c.success;
      } else if (rankChange! < 0) {
        icon = LucideIcons.arrowDown;
        text = s.agencyRankDown(-rankChange!);
        col = c.danger;
      } else {
        icon = LucideIcons.equal;
        text = s.agencyRankSame;
        col = c.textTertiary;
      }
      change = Row(children: [
        Icon(icon, size: 13, color: col),
        const SizedBox(width: 4),
        Expanded(child: Text(text, style: TextStyle(color: col, fontSize: 12, fontWeight: FontWeight.w700))),
      ]);
    }

    return AgencyBox(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        AgencyBoxTitle(
          icon: LucideIcons.target,
          text: s.agencyMonthGoalTitle,
          trailing: hasGoal
              ? Text(met ? s.agencyMonthGoalMet : s.agencyMonthGoalPercent('$pct'),
                  style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w800, fontFeatures: kTabularFigures))
              : null,
        ),
        const SizedBox(height: 10),
        if (hasGoal)
          AgencyProgressBar(value: perf.goalProgress, color: color)
        else
          Text(s.agencyMonthGoalNone, style: AgencyText.caption(context)),
        if (perf.rank != null && perf.of != null) ...[
          const SizedBox(height: 14),
          const AgencyDivider(),
          const SizedBox(height: 12),
          Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
            Icon(LucideIcons.trophy, size: 16, color: c.accentGold),
            const SizedBox(width: 8),
            Expanded(child: Text(s.agencyPositionLabel, style: AgencyText.caption(context))),
            const SizedBox(width: 8),
            Text(s.agencyRankValue(perf.rank!, perf.of!), style: AgencyText.number(context, size: 20)),
          ]),
          if (change != null) ...[const SizedBox(height: 6), change],
        ],
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Histórico de 6 meses
// ─────────────────────────────────────────────────────────────────────────────

class AgencyHistoryCard extends ConsumerStatefulWidget {
  const AgencyHistoryCard({super.key, required this.history, this.onRetry});
  final AsyncValue<List<AgencyPerformance>> history;
  final VoidCallback? onRetry;
  @override
  ConsumerState<AgencyHistoryCard> createState() => _AgencyHistoryCardState();
}

class _AgencyHistoryCardState extends ConsumerState<AgencyHistoryCard> {
  bool _hours = false;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final selectedMonth = ref.watch(agencyMonthProvider);

    Widget body;
    final data = widget.history.value;
    if (widget.history.hasError && data == null) {
      body = SizedBox(height: 140, child: CreatorErrorView(message: s.agencyPerfError, onRetry: widget.onRetry));
    } else if (data == null) {
      body = const AgencySkeletonBlock(height: 140, radius: 12);
    } else {
      // Mais antigo primeiro (esquerda → direita).
      final months = data.reversed.toList();
      final empty = months.every((m) => (_hours ? m.hours : m.diamonds.toDouble()) == 0);
      if (months.isEmpty || empty) {
        body = SizedBox(
          height: 96,
          child: Center(child: Text(s.agencyChartEmpty, style: AgencyText.caption(context))),
        );
      } else {
        final sel = months.indexWhere((m) => m.month == selectedMonth);
        body = AgencyBarChart(
          values: [for (final m in months) _hours ? m.hours : m.diamonds.toDouble()],
          labels: [for (final m in months) agencyMonthAxis(context, m.monthStart)],
          selected: sel < 0 ? months.length - 1 : sel,
          format: (v) => _hours ? '${agencyHoursText(context, v)} h' : agencyCompact(context, v),
          semanticsLabel: s.agencyChartTitle,
          onSelect: (i) => ref.read(agencyMonthProvider.notifier).select(months[i].month),
        );
      }
    }

    return AgencyBox(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        AgencyBoxTitle(icon: LucideIcons.chartColumn, text: s.agencyChartTitle),
        const SizedBox(height: 10),
        Wrap(spacing: 8, runSpacing: 6, children: [
          _MetricChip(label: s.agencyDiamonds, selected: !_hours, onTap: () => setState(() => _hours = false)),
          _MetricChip(label: s.agencyHours, selected: _hours, onTap: () => setState(() => _hours = true)),
        ]),
        const SizedBox(height: 14),
        body,
      ]),
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      button: true,
      selected: selected,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 32),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: selected ? c.accentPrimary.withValues(alpha: 0.14) : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: selected ? c.accentPrimary : c.border),
          ),
          child: Text(label,
              style: TextStyle(
                  color: selected ? c.accentPrimary : c.textSecondary, fontSize: 12.5, fontWeight: FontWeight.w700)),
        ),
      ),
    );
  }
}

/// Gráfico de barras simples: matiz único, topos arredondados, barras finas.
/// Toque numa barra para ver o valor (e escolher o mês).
class AgencyBarChart extends StatelessWidget {
  const AgencyBarChart({
    super.key,
    required this.values,
    required this.labels,
    required this.selected,
    required this.format,
    required this.onSelect,
    this.semanticsLabel,
  });
  final List<double> values;
  final List<String> labels;
  final int selected;
  final String Function(double) format;
  final ValueChanged<int> onSelect;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final ts = MediaQuery.textScalerOf(context);
    final labelH = ts.scale(11) * 1.3 + 8;
    const plotH = 112.0;
    return Semantics(
      label: semanticsLabel,
      child: LayoutBuilder(builder: (context, box) {
        final slot = box.maxWidth / values.length;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (d) {
            final i = (d.localPosition.dx / slot).floor().clamp(0, values.length - 1);
            onSelect(i);
          },
          child: CustomPaint(
            size: Size(box.maxWidth, plotH + labelH),
            painter: _BarPainter(
              values: values,
              labels: labels,
              selected: selected,
              valueText: format(values[selected.clamp(0, values.length - 1)]),
              color: c.accentPrimary,
              axisColor: c.border,
              textColor: c.textSecondary,
              selectedTextColor: c.textPrimary,
              plotHeight: plotH,
              textScaler: ts,
              baseStyle: DefaultTextStyle.of(context).style,
            ),
          ),
        );
      }),
    );
  }
}

class _BarPainter extends CustomPainter {
  _BarPainter({
    required this.values,
    required this.labels,
    required this.selected,
    required this.valueText,
    required this.color,
    required this.axisColor,
    required this.textColor,
    required this.selectedTextColor,
    required this.plotHeight,
    required this.textScaler,
    required this.baseStyle,
  });
  final TextStyle baseStyle;
  final List<double> values;
  final List<String> labels;
  final int selected;
  final String valueText;
  final Color color;
  final Color axisColor;
  final Color textColor;
  final Color selectedTextColor;
  final double plotHeight;
  final TextScaler textScaler;

  TextPainter _tp(String t, TextStyle st, double maxW) =>
      TextPainter(text: TextSpan(text: t, style: baseStyle.merge(st)), textDirection: TextDirection.ltr, textScaler: textScaler, maxLines: 1, ellipsis: '…')
        ..layout(maxWidth: maxW);

  @override
  void paint(Canvas canvas, Size size) {
    final n = values.length;
    if (n == 0) return;
    final slot = size.width / n;
    final barW = (slot * 0.38).clamp(6.0, 18.0);
    final maxV = values.reduce((a, b) => a > b ? a : b);
    const topPad = 20.0;
    final plot = plotHeight - topPad;
    final base = plotHeight;

    canvas.drawLine(Offset(0, base), Offset(size.width, base), Paint()..color = axisColor..strokeWidth = 1);

    for (var i = 0; i < n; i++) {
      final cx = slot * i + slot / 2;
      final h = maxV <= 0 ? 2.0 : (values[i] / maxV * plot).clamp(2.0, plot);
      final isSel = i == selected;
      final r = Radius.circular(barW / 2.5);
      final rect = RRect.fromLTRBAndCorners(cx - barW / 2, base - h, cx + barW / 2, base, topLeft: r, topRight: r);
      canvas.drawRRect(rect, Paint()..color = isSel ? color : color.withValues(alpha: 0.32));

      final lab = _tp(labels[i], TextStyle(fontSize: 11, fontWeight: isSel ? FontWeight.w800 : FontWeight.w600, color: isSel ? selectedTextColor : textColor), slot);
      lab.paint(canvas, Offset(cx - lab.width / 2, base + 6));

      if (isSel) {
        final v = _tp(valueText, TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: selectedTextColor, fontFeatures: kTabularFigures), slot * 2.4);
        final dx = (cx - v.width / 2).clamp(0.0, size.width - v.width);
        v.paint(canvas, Offset(dx, (base - h - v.height - 4).clamp(0.0, plotHeight)));
      }
    }
  }

  @override
  bool shouldRepaint(_BarPainter o) =>
      o.values != values || o.selected != selected || o.color != color || o.valueText != valueText || o.textScaler != textScaler;
}
