import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../domain/models/creator_agency.dart';
import '../../../../gen/l10n/app_localizations.dart';
import '../../../core/themes/brawe_colors.dart';
import '../../view_models/creator_agency_providers.dart';
import '../creator_state_views.dart';
import 'agency_l10n.dart';
import 'agency_summary.dart' show AgencyPeriodFilter;
import 'agency_widgets.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Metas: checklist de diretrizes do mês + ocorrências (filtro do mês / 90 dias)
// ─────────────────────────────────────────────────────────────────────────────

class AgencyGoalsTab extends ConsumerStatefulWidget {
  const AgencyGoalsTab({super.key, required this.state});
  final AgencyState state;
  @override
  ConsumerState<AgencyGoalsTab> createState() => _AgencyGoalsTabState();
}

class _AgencyGoalsTabState extends ConsumerState<AgencyGoalsTab> {
  bool _last90 = false;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final month = ref.watch(agencyMonthProvider);
    final perf = ref.watch(agencyPerformanceProvider(month));

    final header = Align(alignment: Alignment.centerLeft, child: AgencyPeriodFilter());

    return perf.when(
      loading: () => AgencyColumns(left: [header, const AgencySkeletonBlock(height: 150), const AgencySkeletonBlock(height: 110)]),
      error: (_, _) => AgencyColumns(left: [
        header,
        SizedBox(
          height: 200,
          child: CreatorErrorView(message: s.agencyPerfError, onRetry: () => ref.invalidate(agencyPerformanceProvider(month))),
        ),
      ]),
      data: (p) {
        final g = p.guidelines;
        final incidents = _last90 ? widget.state.me?.guidelines.incidents ?? const <AgencyIncident>[] : g.incidents;
        return AgencyColumns(
          left: [header, AgencyChecklistCard(perf: p)],
          right: [
            AgencyIncidentsCard(
              incidents: incidents,
              last90: _last90,
              onFilter: (v) => setState(() => _last90 = v),
            ),
          ],
        );
      },
    );
  }
}

class AgencyChecklistCard extends StatelessWidget {
  const AgencyChecklistCard({super.key, required this.perf});
  final AgencyPerformance perf;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final c = context.colors;
    final g = perf.guidelines;
    final rows = <Widget>[
      if (g.minHours > 0)
        _GoalRow(
          icon: LucideIcons.clock,
          label: s.agencyHours,
          value: s.agencyGoalHoursValue(agencyHoursText(context, perf.hours), agencyHoursText(context, g.minHours)),
          progress: g.minHours <= 0 ? 1 : perf.hours / g.minHours,
          missing: perf.hours >= g.minHours ? null : s.agencyMissingHours(agencyHoursText(context, g.minHours - perf.hours)),
        ),
      if (g.minDays > 0)
        _GoalRow(
          icon: LucideIcons.calendarDays,
          label: s.agencyDaysLive,
          value: s.agencyGoalDaysValue(agencyNumber(context, perf.days), agencyNumber(context, g.minDays)),
          progress: g.minDays <= 0 ? 1 : perf.days / g.minDays,
          missing: perf.days >= g.minDays ? null : s.agencyMissingDays(g.minDays - perf.days),
        ),
    ];
    final met = g.met;
    return AgencyBox(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        AgencyBoxTitle(icon: LucideIcons.target, text: s.agencyMonthGoalTitle),
        if (rows.isNotEmpty) ...[
          const SizedBox(height: 8),
          AgencyChip(
            label: met ? s.agencyMonthGoalMet : s.agencyGuidelinesNotMet,
            icon: met ? LucideIcons.circleCheck : LucideIcons.hourglass,
            color: met ? c.success : c.warning,
          ),
        ],
        const SizedBox(height: 12),
        if (rows.isEmpty)
          Text(s.agencyMonthGoalNone, style: AgencyText.caption(context))
        else
          for (var i = 0; i < rows.length; i++) ...[if (i > 0) const SizedBox(height: 16), rows[i]],
      ]),
    );
  }
}

class _GoalRow extends StatelessWidget {
  const _GoalRow({required this.icon, required this.label, required this.value, required this.progress, this.missing});
  final IconData icon;
  final String label;
  final String value;
  final double progress;
  final String? missing;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final c = context.colors;
    final done = missing == null;
    final color = done ? c.success : c.accentPrimary;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Icon(done ? LucideIcons.circleCheck : icon, size: 16, color: color),
        const SizedBox(width: 8),
        Expanded(child: Text(label, style: AgencyText.title(context))),
        const SizedBox(width: 8),
        Flexible(
          child: Text(value,
              textAlign: TextAlign.end,
              style: TextStyle(color: c.textSecondary, fontSize: 13, fontWeight: FontWeight.w700, fontFeatures: kTabularFigures)),
        ),
      ]),
      const SizedBox(height: 8),
      AgencyProgressBar(value: progress, color: color),
      const SizedBox(height: 6),
      Text(done ? s.agencyGoalDone : missing!,
          style: TextStyle(color: done ? c.success : c.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
    ]);
  }
}

class AgencyIncidentsCard extends StatelessWidget {
  const AgencyIncidentsCard({super.key, required this.incidents, required this.last90, required this.onFilter});
  final List<AgencyIncident> incidents;
  final bool last90;
  final ValueChanged<bool> onFilter;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final c = context.colors;
    return AgencyBox(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        AgencyBoxTitle(icon: LucideIcons.triangleAlert, text: s.agencyIncidentsTitleShort),
        const SizedBox(height: 10),
        Wrap(spacing: 8, runSpacing: 6, children: [
          AgencyFilterChip(label: s.agencyIncFilterMonth, selected: !last90, onTap: () => onFilter(false)),
          AgencyFilterChip(label: s.agencyIncFilter90, selected: last90, onTap: () => onFilter(true)),
        ]),
        const SizedBox(height: 10),
        if (incidents.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(children: [
              Icon(LucideIcons.shieldCheck, size: 18, color: c.success),
              const SizedBox(width: 8),
              Expanded(child: Text(s.agencyNoIncidents, style: AgencyText.body(context))),
            ]),
          )
        else
          for (var i = 0; i < incidents.length; i++) ...[
            if (i > 0) const AgencyDivider(),
            _IncidentRow(incident: incidents[i]),
          ],
      ]),
    );
  }
}

String agencyIncidentKindLabel(S s, String kind) {
  switch (kind) {
    case 'warning':
      return s.agencyIncidentWarning;
    case 'suspension':
      return s.agencyIncidentSuspension;
    case 'ban':
      return s.agencyIncidentBan;
    case 'fraud':
      return s.agencyIncidentFraud;
    default:
      return kind;
  }
}

class _IncidentRow extends StatelessWidget {
  const _IncidentRow({required this.incident});
  final AgencyIncident incident;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final c = context.colors;
    final severe = incident.kind == 'ban' || incident.kind == 'fraud' || incident.kind == 'suspension';
    final col = severe ? c.danger : c.warning;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(LucideIcons.circleAlert, size: 16, color: col),
        const SizedBox(width: 10),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(agencyIncidentKindLabel(s, incident.kind), style: AgencyText.title(context)),
            if (incident.note != null) Text(incident.note!, style: AgencyText.caption(context)),
          ]),
        ),
        const SizedBox(width: 8),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(agencyDateShort(context, incident.startsAt), style: AgencyText.caption(context)),
          if (incident.points > 0)
            Text(s.agencyIncidentPoints(incident.points), style: TextStyle(color: col, fontSize: 12, fontWeight: FontWeight.w700)),
        ]),
      ]),
    );
  }
}

/// Chip de filtro (seleção única) — 32dp de altura mínima, alvo de toque amplo.
class AgencyFilterChip extends StatelessWidget {
  const AgencyFilterChip({super.key, required this.label, required this.selected, required this.onTap, this.icon, this.count});
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;
  final int? count;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final fg = selected ? c.accentPrimary : c.textSecondary;
    return Semantics(
      button: true,
      selected: selected,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 36),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: selected ? c.accentPrimary.withValues(alpha: 0.14) : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: selected ? c.accentPrimary : c.border),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            if (icon != null) ...[Icon(icon, size: 14, color: fg), const SizedBox(width: 6)],
            Flexible(
              child: Text(label,
                  maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: fg, fontSize: 13, fontWeight: FontWeight.w700)),
            ),
            if (count != null) ...[
              const SizedBox(width: 6),
              Text('$count', style: TextStyle(color: fg, fontSize: 12.5, fontWeight: FontWeight.w800, fontFeatures: kTabularFigures)),
            ],
          ]),
        ),
      ),
    );
  }
}
