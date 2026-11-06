import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../domain/models/creator_agency.dart';
import '../../../../gen/l10n/app_localizations.dart';
import '../../../core/themes/brawe_colors.dart';
import 'agency_goals.dart' show AgencyFilterChip;
import 'agency_l10n.dart';
import 'agency_widgets.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Eventos: filtros Próximos · Em andamento · Encerrados
// ─────────────────────────────────────────────────────────────────────────────

enum AgencyEventFilter { upcoming, live, ended }

/// Estado efetivo: usa `status` do backend e, se faltar, deduz pelas datas.
AgencyEventFilter agencyEventBucket(AgencyEvent e, [DateTime? now]) {
  switch (e.status) {
    case 'live':
      return AgencyEventFilter.live;
    case 'ended':
      return AgencyEventFilter.ended;
    case 'scheduled':
      return AgencyEventFilter.upcoming;
  }
  final n = now ?? DateTime.now();
  if (e.endsAt != null && e.endsAt!.isBefore(n)) return AgencyEventFilter.ended;
  if (e.startsAt != null && e.startsAt!.isAfter(n)) return AgencyEventFilter.upcoming;
  return AgencyEventFilter.live;
}

class AgencyEventsTab extends StatefulWidget {
  const AgencyEventsTab({super.key, required this.events});
  final List<AgencyEvent> events;
  @override
  State<AgencyEventsTab> createState() => _AgencyEventsTabState();
}

class _AgencyEventsTabState extends State<AgencyEventsTab> {
  AgencyEventFilter? _filter;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final c = context.colors;
    final byBucket = <AgencyEventFilter, List<AgencyEvent>>{
      for (final f in AgencyEventFilter.values) f: [],
    };
    for (final e in widget.events) {
      byBucket[agencyEventBucket(e)]!.add(e);
    }
    byBucket[AgencyEventFilter.upcoming]!.sort((a, b) => (a.startsAt ?? DateTime(9999)).compareTo(b.startsAt ?? DateTime(9999)));
    byBucket[AgencyEventFilter.live]!.sort((a, b) => (a.endsAt ?? DateTime(9999)).compareTo(b.endsAt ?? DateTime(9999)));
    byBucket[AgencyEventFilter.ended]!.sort((a, b) => (b.endsAt ?? DateTime(0)).compareTo(a.endsAt ?? DateTime(0)));

    // Filtro padrão: em andamento > próximos > encerrados (o primeiro que tiver itens).
    final filter = _filter ??
        (byBucket[AgencyEventFilter.live]!.isNotEmpty
            ? AgencyEventFilter.live
            : byBucket[AgencyEventFilter.upcoming]!.isNotEmpty
                ? AgencyEventFilter.upcoming
                : AgencyEventFilter.upcoming);
    final list = byBucket[filter]!;
    final labels = {
      AgencyEventFilter.upcoming: s.agencyEventsFilterUpcoming,
      AgencyEventFilter.live: s.agencyEventsFilterLive,
      AgencyEventFilter.ended: s.agencyEventsFilterEnded,
    };
    final empty = {
      AgencyEventFilter.upcoming: s.agencyEventsEmptyUpcoming,
      AgencyEventFilter.live: s.agencyEventsEmptyLive,
      AgencyEventFilter.ended: s.agencyEventsEmptyEnded,
    };

    return AgencyColumns(left: [
      Wrap(spacing: 8, runSpacing: 8, children: [
        for (final f in AgencyEventFilter.values)
          AgencyFilterChip(label: labels[f]!, count: byBucket[f]!.length, selected: f == filter, onTap: () => setState(() => _filter = f)),
      ]),
      if (list.isEmpty)
        AgencyBox(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(children: [
              Icon(LucideIcons.calendarRange, size: 28, color: c.textTertiary),
              const SizedBox(height: 10),
              Text(empty[filter]!, textAlign: TextAlign.center, style: AgencyText.body(context)),
              if (filter == AgencyEventFilter.live || filter == AgencyEventFilter.upcoming) ...[
                const SizedBox(height: 4),
                Text(s.agencyEventsHow, textAlign: TextAlign.center, style: AgencyText.caption(context)),
              ],
            ]),
          ),
        )
      else
        AgencyBox(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(children: [
            for (var i = 0; i < list.length; i++) ...[
              if (i > 0) const AgencyDivider(),
              _EventRow(event: list[i], bucket: filter),
            ],
          ]),
        ),
    ]);
  }
}

class _EventRow extends StatelessWidget {
  const _EventRow({required this.event, required this.bucket});
  final AgencyEvent event;
  final AgencyEventFilter bucket;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final c = context.colors;
    final lang = agencyLang(context);
    final name = event.nameFor(lang);
    final start = event.startsAt;
    final locale = Localizations.localeOf(context).toString();
    final (chipLabel, chipColor) = switch (bucket) {
      AgencyEventFilter.live => (s.agencyEventLive, c.success),
      AgencyEventFilter.upcoming => (s.agencyEventScheduled, c.accentPrimary),
      AgencyEventFilter.ended => (s.agencyEventEnded, c.textTertiary),
    };
    String period() {
      if (start == null && event.endsAt == null) return '';
      final f = DateFormat.MMMd(locale);
      if (start != null && event.endsAt != null) return '${f.format(start)} – ${f.format(event.endsAt!)}';
      return f.format((start ?? event.endsAt)!);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        _DateBlock(date: start ?? event.endsAt),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name.isEmpty ? s.agencySubEvents : name, maxLines: 2, overflow: TextOverflow.ellipsis, style: AgencyText.title(context)),
            const SizedBox(height: 2),
            if (period().isNotEmpty) Text(period(), style: AgencyText.caption(context)),
            if (event.multiplier != null && event.multiplier! > 1) ...[
              const SizedBox(height: 4),
              Row(children: [
                Icon(LucideIcons.zap, size: 12, color: c.accentGold),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(s.agencyEventMultiplier(NumberFormat('0.##', locale).format(event.multiplier)),
                      style: TextStyle(color: c.textSecondary, fontSize: 12, fontWeight: FontWeight.w700)),
                ),
              ]),
            ],
          ]),
        ),
        const SizedBox(width: 8),
        AgencyChip(label: chipLabel, color: chipColor),
      ]),
    );
  }
}

class _DateBlock extends StatelessWidget {
  const _DateBlock({required this.date});
  final DateTime? date;
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      width: 48,
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(color: c.surfaceHighest, borderRadius: BorderRadius.circular(12)),
      child: date == null
          ? Icon(LucideIcons.calendarRange, size: 20, color: c.textTertiary)
          : Column(mainAxisSize: MainAxisSize.min, children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(agencyMonthAbbr(context, date!).replaceAll('.', '').toUpperCase(),
                    style: TextStyle(color: c.accentPrimary, fontSize: 10.5, fontWeight: FontWeight.w800, letterSpacing: .5)),
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text('${date!.day}', style: AgencyText.number(context, size: 19)),
              ),
            ]),
    );
  }
}
