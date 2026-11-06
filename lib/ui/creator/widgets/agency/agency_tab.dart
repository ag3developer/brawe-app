import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../domain/models/creator_agency.dart';
import '../../../../gen/l10n/app_localizations.dart';
import '../../../core/themes/brawe_colors.dart';
import '../../view_models/creator_agency_providers.dart';
import '../creator_panel_scope.dart';
import '../creator_state_views.dart';
import 'agency_contract.dart';
import 'agency_events.dart';
import 'agency_goals.dart';
import 'agency_invites.dart';
import 'agency_l10n.dart';
import 'agency_summary.dart';
import 'agency_widgets.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Aba "Agência" do painel do criador.
//  • Com vínculo: barra fixa (logo, nome, desde, Falar) + sub-abas.
//  • Só convites: lista objetiva de convites.
// ─────────────────────────────────────────────────────────────────────────────

enum AgencySub { summary, goals, events, contract }

/// Recarrega tudo que a aba usa.
Future<void> refreshAgencyData(WidgetRef ref) async {
  ref.invalidate(creatorAgencyProvider);
  ref.invalidate(agencyHistoryProvider);
  ref.invalidate(agencyPerformanceProvider);
  try {
    await ref.read(creatorAgencyProvider.future);
  } catch (_) {}
}

class AgencyTab extends ConsumerStatefulWidget {
  const AgencyTab({super.key, this.initialSub = AgencySub.summary});
  final AgencySub initialSub;
  @override
  ConsumerState<AgencyTab> createState() => _AgencyTabState();
}

class _AgencyTabState extends ConsumerState<AgencyTab> {
  late AgencySub _sub = widget.initialSub;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final async = ref.watch(creatorAgencyProvider);
    Future<void> refresh() => refreshAgencyData(ref);

    return async.when(
      loading: () => PanelTabScroll(
        onRefresh: refresh,
        slivers: const [SliverToBoxAdapter(child: AgencySkeleton(blocks: [60, 120, 150]))],
      ),
      error: (e, _) => PanelTabScroll(
        onRefresh: refresh,
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: CreatorErrorView(message: s.agencyLoadError, onRetry: refresh),
          ),
        ],
      ),
      data: (state) {
        final link = state.link;
        if (link == null) {
          final invites = state.pendingInvites;
          return PanelTabScroll(
            onRefresh: refresh,
            slivers: [
              SliverToBoxAdapter(
                child: AgencyColumns(left: [
                  if (invites.isEmpty)
                    AgencyBox(child: Text(s.agencyInvitesEmpty, style: AgencyText.body(context)))
                  else
                    AgencyInvitesList(invites: invites),
                ]),
              ),
            ],
          );
        }
        final ts = MediaQuery.textScalerOf(context);
        final barH = agencyBarExtent(ts);
        final chipsH = agencyChipsExtent(ts);
        final pending = state.pendingInvites;
        final Widget content;
        switch (_sub) {
          case AgencySub.summary:
            content = const AgencySummaryTab();
          case AgencySub.goals:
            content = AgencyGoalsTab(state: state);
          case AgencySub.events:
            content = AgencyEventsTab(events: state.events);
          case AgencySub.contract:
            content = AgencyContractTab(link: link);
        }
        return PanelTabScroll(
          onRefresh: refresh,
          slivers: [
            SliverPersistentHeader(
              pinned: true,
              delegate: _FixedHeaderDelegate(
                extent: barH + chipsH + 1,
                child: Column(children: [
                  SizedBox(height: barH, child: AgencyBar(link: link)),
                  SizedBox(
                    height: chipsH,
                    child: AgencySubTabs(selected: _sub, onSelect: (v) => setState(() => _sub = v)),
                  ),
                ]),
              ),
            ),
            if (pending.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: AgencyInvitesBanner(count: pending.length, onTap: () => showAgencyInvitesSheet(context, pending)),
                ),
              ),
            SliverToBoxAdapter(child: content),
          ],
        );
      },
    );
  }
}

double agencyBarExtent(TextScaler ts) {
  final text = ts.scale(15) * 1.25 + ts.scale(12.5) * 1.3 + 4;
  final btn = math.max(40.0, ts.scale(13) * 1.3 + 20);
  return math.max(math.max(44.0, text), btn) + 16;
}

double agencyChipsExtent(TextScaler ts) => math.max(36.0, ts.scale(13) * 1.3 + 14) + 14;

class _FixedHeaderDelegate extends SliverPersistentHeaderDelegate {
  _FixedHeaderDelegate({required this.extent, required this.child});
  final double extent;
  final Widget child;

  @override
  double get minExtent => extent;
  @override
  double get maxExtent => extent;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final c = context.colors;
    return DecoratedBox(
      decoration: BoxDecoration(color: c.background, border: Border(bottom: BorderSide(color: c.border))),
      child: child,
    );
  }

  @override
  bool shouldRebuild(_FixedHeaderDelegate old) => old.extent != extent || old.child != child;
}

/// Barra fina: logo 36, nome, "Agenciado desde …" e botão Falar.
class AgencyBar extends ConsumerWidget {
  const AgencyBar({super.key, required this.link});
  final AgencyLink link;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = S.of(context);
    final c = context.colors;
    final who = link.invitedBy;
    final since = link.acceptedAt ?? link.contract.startedAt;
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1000),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(children: [
            AgencyLogo(name: link.agency.name, url: link.agency.logoUrl, size: 36),
            const SizedBox(width: 10),
            Expanded(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(link.agency.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: AgencyText.title(context)),
                if (since != null)
                  Text(s.agencySince(agencyMonthYear(context, since)),
                      maxLines: 1, overflow: TextOverflow.ellipsis, style: AgencyText.caption(context)),
              ]),
            ),
            if (who != null && who.userId.isNotEmpty) ...[
              const SizedBox(width: 8),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(48, 40),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  foregroundColor: c.accentPrimary,
                  side: BorderSide(color: c.accentPrimary.withValues(alpha: 0.5)),
                ),
                onPressed: () => openAgencyChat(context, ref, who),
                icon: const Icon(LucideIcons.messageCircle, size: 16),
                label: Text(s.agencyTalk, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
              ),
            ],
          ]),
        ),
      ),
    );
  }
}

class AgencySubTabs extends StatelessWidget {
  const AgencySubTabs({super.key, required this.selected, required this.onSelect});
  final AgencySub selected;
  final ValueChanged<AgencySub> onSelect;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final items = <(AgencySub, String, IconData)>[
      (AgencySub.summary, s.agencySubSummary, LucideIcons.chartColumn),
      (AgencySub.goals, s.agencySubGoals, LucideIcons.target),
      (AgencySub.events, s.agencySubEvents, LucideIcons.calendarRange),
      (AgencySub.contract, s.agencySubContract, LucideIcons.fileSignature),
    ];
    return Align(
      alignment: Alignment.centerLeft,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            AgencyFilterChip(label: items[i].$2, icon: items[i].$3, selected: items[i].$1 == selected, onTap: () => onSelect(items[i].$1)),
          ],
        ]),
      ),
    );
  }
}
