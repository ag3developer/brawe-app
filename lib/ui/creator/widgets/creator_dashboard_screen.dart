import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../config/feature_flags.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../../core/themes/brawe_colors.dart';
import '../utils/creator_l10n.dart';
import '../view_models/creator_agency_providers.dart';
import '../view_models/creator_header_provider.dart';
import '../view_models/creator_journey_provider.dart';
import '../view_models/creator_network_view_model.dart';
import 'agency/agency_tab.dart';
import 'agency/agency_widgets.dart';
import 'analytics/analytics_format.dart';
import 'creator_panel_scope.dart';
import 'creator_panel_tabs.dart';
import 'creator_state_views.dart';
import 'monetization/monetization_tab.dart';

// ─────────────────────────────────────────────────────────────────────────────
// PAINEL DO CREATOR
// Cabeçalho compacto que recolhe + abas fixas: Início · Monetização ·
// Desempenho · Agência (só com vínculo ou convites) · Benefícios.
// ─────────────────────────────────────────────────────────────────────────────

const _kTabHome = 'home';
const _kTabMonetization = 'monetization';
const _kTabPerformance = 'performance';
const _kTabAgency = 'agency';
const _kTabBenefits = 'benefits';

class CreatorDashboardScreen extends ConsumerWidget {
  const CreatorDashboardScreen({super.key, this.initialTab});

  /// home | monetization | performance | agency | benefits
  final String? initialTab;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = S.of(context);
    final c = context.colors;
    final profileAsync = ref.watch(myCreatorProfileProvider);

    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        backgroundColor: c.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(s.creatorDashboardTitle, style: TextStyle(color: c.textPrimary, fontSize: 17, fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            tooltip: s.creatorDashShortcutSettings,
            icon: Icon(LucideIcons.settings, size: 20, color: c.textSecondary),
            onPressed: () => context.push('/edit-profile'),
          ),
        ],
      ),
      body: profileAsync.when(
        loading: () => const CreatorLoadingView(),
        error: (e, _) => CreatorErrorView(
          message: s.creatorDashErrorTitle,
          onRetry: () => ref.invalidate(myCreatorProfileProvider),
        ),
        data: (profile) {
          if (profile == null) {
            return CreatorEmptyState(
              icon: Icons.workspace_premium_outlined,
              title: s.creatorBadgeLocked,
              subtitle: s.creatorProgramDescription,
              actionLabel: s.creatorActionApplyNow,
              onAction: () => context.go('/creator/apply'),
            );
          }
          return PanelBody(initialTab: initialTab);
        },
      ),
    );
  }
}

/// Corpo do painel: cabeçalho + abas. Público para testes.
class PanelBody extends ConsumerStatefulWidget {
  const PanelBody({super.key, this.initialTab});
  final String? initialTab;
  @override
  ConsumerState<PanelBody> createState() => _PanelBodyState();
}

class _PanelBodyState extends ConsumerState<PanelBody> with TickerProviderStateMixin {
  TabController? _ctrl;
  List<String> _ids = const [];

  /// Aba pedida pela rota que ainda não pôde ser aberta (ex.: Agência carregando).
  String? _pending;

  @override
  void initState() {
    super.initState();
    _pending = widget.initialTab;
  }

  @override
  void didUpdateWidget(PanelBody old) {
    super.didUpdateWidget(old);
    if (old.initialTab != widget.initialTab) _pending = widget.initialTab;
  }

  @override
  void dispose() {
    _ctrl?.dispose();
    super.dispose();
  }

  void _sync(List<String> ids, {required bool agencyKnown}) {
    if (_pending != null) {
      final want = ids.indexOf(_pending!);
      if (want >= 0) {
        _replace(ids, want);
        _pending = null;
        return;
      }
      // Agência ainda carregando: espera; qualquer outra aba inexistente é descartada.
      if (!(_pending == _kTabAgency && !agencyKnown)) _pending = null;
    }
    if (_ctrl != null && listEquals(ids, _ids)) return;
    final currentId = (_ctrl != null && _ids.isNotEmpty) ? _ids[_ctrl!.index.clamp(0, _ids.length - 1)] : null;
    final keep = currentId == null ? 0 : ids.indexOf(currentId);
    _replace(ids, keep < 0 ? 0 : keep);
  }

  void _replace(List<String> ids, int index) {
    final old = _ctrl;
    _ctrl = TabController(length: ids.length, vsync: this, initialIndex: index);
    _ids = ids;
    if (old != null) WidgetsBinding.instance.addPostFrameCallback((_) => old.dispose());
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final c = context.colors;
    final agency = ref.watch(creatorAgencyProvider);
    final state = agency.value;
    final pendingCount = state?.pendingInvites.length ?? 0;
    final hasAgencyTab = state != null && (state.link != null || pendingCount > 0);
    final ids = [
      _kTabHome,
      if (kEnableMonetization) _kTabMonetization,
      _kTabPerformance,
      if (hasAgencyTab) _kTabAgency,
      _kTabBenefits,
    ];
    _sync(ids, agencyKnown: !agency.isLoading || state != null);
    final ctrl = _ctrl!;

    Widget label(String id) {
      switch (id) {
        case _kTabHome:
          return Tab(text: s.creatorPanelTabHome);
        case _kTabMonetization:
          return Tab(text: s.creatorPanelTabMonetization);
        case _kTabPerformance:
          return Tab(text: s.creatorPanelTabPerformance);
        case _kTabBenefits:
          return Tab(text: s.creatorPanelTabBenefits);
        default:
          return Tab(
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Text(s.creatorPanelTabAgency),
              if (pendingCount > 0) ...[
                const SizedBox(width: 6),
                Container(
                  constraints: const BoxConstraints(minWidth: 18),
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(color: c.accentPink, borderRadius: BorderRadius.circular(10)),
                  child: Text('$pendingCount',
                      textAlign: TextAlign.center,
                      semanticsLabel: s.agencyPendingInvites(pendingCount),
                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800, height: 1.3)),
                ),
              ],
            ]),
          );
      }
    }

    Widget page(String id) {
      switch (id) {
        case _kTabHome:
          return const PanelHomeTab();
        case _kTabMonetization:
          return const PanelMonetizationTab();
        case _kTabPerformance:
          return const PanelPerformanceTab();
        case _kTabBenefits:
          return const PanelBenefitsTab();
        default:
          return const AgencyTab();
      }
    }

    final tabBar = TabBar(
      controller: ctrl,
      isScrollable: true,
      tabAlignment: TabAlignment.start,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      dividerColor: Colors.transparent,
      indicatorColor: c.accentPrimary,
      indicatorSize: TabBarIndicatorSize.label,
      labelColor: c.textPrimary,
      unselectedLabelColor: c.textTertiary,
      labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
      unselectedLabelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      tabs: [for (final id in ids) label(id)],
    );

    return NestedScrollView(
      headerSliverBuilder: (ctx, inner) => [
        const SliverToBoxAdapter(child: PanelHeader()),
        SliverOverlapAbsorber(
          handle: NestedScrollView.sliverOverlapAbsorberHandleFor(ctx),
          sliver: SliverPersistentHeader(
            pinned: true,
            delegate: _TabBarDelegate(tabBar: tabBar, color: c.background, border: c.border),
          ),
        ),
      ],
      body: CreatorPanelScope(
        nested: true,
        selectTab: (id) {
          final i = _ids.indexOf(id);
          if (i < 0 || _ctrl == null) return false;
          _ctrl!.animateTo(i);
          return true;
        },
        child: TabBarView(
          controller: ctrl,
          children: [for (final id in ids) KeyedSubtree(key: ValueKey(id), child: page(id))],
        ),
      ),
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  _TabBarDelegate({required this.tabBar, required this.color, required this.border});
  final TabBar tabBar;
  final Color color;
  final Color border;

  @override
  double get minExtent => tabBar.preferredSize.height + 1;
  @override
  double get maxExtent => tabBar.preferredSize.height + 1;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return DecoratedBox(
      decoration: BoxDecoration(color: color, border: Border(bottom: BorderSide(color: border))),
      child: Align(alignment: Alignment.centerLeft, child: tabBar),
    );
  }

  @override
  bool shouldRebuild(_TabBarDelegate old) => true;
}

/// Cabeçalho compacto: avatar, nome, chip do nível e ganhos em uma linha.
class PanelHeader extends ConsumerWidget {
  const PanelHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = S.of(context);
    final c = context.colors;
    final header = ref.watch(creatorHeaderProvider).value;
    final journey = ref.watch(creatorJourneyProvider).value;
    final earnings = ref.watch(creatorMonthEarningsProvider).value;
    final tier = journey?.currentTier;
    final name = (header?.name.trim().isNotEmpty ?? false) ? header!.name.trim() : s.creatorPanelProfileFallback;

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1000),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
          child: Row(children: [
            AgencyPersonAvatar(url: header?.avatarUrl, size: 44),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: c.textPrimary, fontSize: 17, fontWeight: FontWeight.w800, height: 1.2)),
                const SizedBox(height: 4),
                Wrap(spacing: 10, runSpacing: 4, crossAxisAlignment: WrapCrossAlignment.center, children: [
                  if (tier != null)
                    InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => context.push('/creator/badge'),
                      child: Container(
                        constraints: const BoxConstraints(minHeight: 28),
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(color: tier.color.withValues(alpha: 0.16), borderRadius: BorderRadius.circular(12)),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(tier.icon, size: 13, color: tier.color),
                          const SizedBox(width: 5),
                          Flexible(
                            child: Text(tier.title(s),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(color: c.textPrimary, fontSize: 12, fontWeight: FontWeight.w800)),
                          ),
                          const SizedBox(width: 2),
                          Icon(LucideIcons.chevronRight, size: 13, color: c.textTertiary),
                        ]),
                      ),
                    ),
                  if (kEnableMonetization && earnings != null)
                    Text.rich(
                      TextSpan(children: [
                        TextSpan(text: '${s.creatorPanelEarnings30}  ', style: TextStyle(color: c.textSecondary, fontSize: 12)),
                        TextSpan(
                            text: AnalyticsFmt.of(context).money(earnings),
                            style: TextStyle(color: c.textPrimary, fontSize: 13, fontWeight: FontWeight.w800, fontFeatures: kTabularFigures)),
                      ]),
                    ),
                ]),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}
