import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../gen/l10n/app_localizations.dart';
import '../../core/themes/app_colors.dart';
import '../../core/themes/brawe_colors.dart';
import 'analytics/analytics_widgets.dart';
import 'analytics_audience_tab.dart';
import 'analytics_earnings_tab.dart';
import 'analytics_followers_tab.dart';
import 'analytics_lives_tab.dart';
import 'analytics_overview_tab.dart';

// ─────────────────────────────────────────────────────────────────────────────
// HUB DE ANÁLISES DO CRIADOR
// Rota: /creator/analytics?tab=overview|followers|audience|lives|earnings
// Período único (7D/30D/3M/1A) + abas rolável. Cada aba mantém seu estado
// (e os providers por período ficam em cache), então trocar é instantâneo.
// ─────────────────────────────────────────────────────────────────────────────

class CreatorAnalyticsHubScreen extends StatefulWidget {
  /// overview | followers | audience | lives | earnings
  final String? initialTab;
  const CreatorAnalyticsHubScreen({super.key, this.initialTab});

  @override
  State<CreatorAnalyticsHubScreen> createState() =>
      _CreatorAnalyticsHubScreenState();
}

class _CreatorAnalyticsHubScreenState extends State<CreatorAnalyticsHubScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(
    length: AnalyticsTabs.keys.length,
    vsync: this,
    initialIndex: AnalyticsTabs.fromKey(widget.initialTab),
  );

  @override
  void didUpdateWidget(CreatorAnalyticsHubScreen old) {
    super.didUpdateWidget(old);
    if (old.initialTab != widget.initialTab) {
      _tabs.animateTo(AnalyticsTabs.fromKey(widget.initialTab));
    }
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  void _select(int i) => _tabs.animateTo(i);

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final colors = context.colors;
    final labels = [
      s.analyticsTabOverview,
      s.analyticsTabFollowers,
      s.analyticsTabAudience,
      s.analyticsTabLives,
      s.analyticsTabEarnings,
    ];

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: Icon(LucideIcons.arrowLeft, size: 20, color: colors.textPrimary),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          s.analyticsHubTitle,
          style: TextStyle(
            color: colors.textPrimary,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: AnalyticsPeriodSegment(),
          ),
          TabBar(
            controller: _tabs,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            dividerColor: colors.border,
            indicatorColor: AppColors.braweBlue,
            indicatorWeight: 3,
            indicatorSize: TabBarIndicatorSize.label,
            labelColor: colors.textPrimary,
            unselectedLabelColor: colors.textSecondary,
            labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            tabs: [for (final l in labels) Tab(text: l, height: 40)],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: [
                _KeepAlive(child: AnalyticsOverviewBody(onSelectTab: _select)),
                const _KeepAlive(child: AnalyticsFollowersBody()),
                const _KeepAlive(child: AnalyticsAudienceBody()),
                const _KeepAlive(child: AnalyticsLivesBody()),
                const _KeepAlive(child: AnalyticsEarningsBody()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Mantém o estado da aba (rolagem, métrica escolhida) ao trocar de aba.
class _KeepAlive extends StatefulWidget {
  final Widget child;
  const _KeepAlive({required this.child});

  @override
  State<_KeepAlive> createState() => _KeepAliveState();
}

class _KeepAliveState extends State<_KeepAlive>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}
