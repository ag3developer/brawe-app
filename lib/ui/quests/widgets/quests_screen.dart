import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/repositories/auth_state_provider.dart';
import '../../../data/services/feedback_service.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../../core/themes/brawe_colors.dart';
import '../../settings/view_models/settings_view_model.dart';
import '../view_models/quests_view_model.dart';
import 'quest_achievements_tab.dart';
import 'quest_missions_tab.dart';
import 'quest_timeline_tab.dart';
import 'quest_visuals.dart';

/// Tela de missões em formato de jogo: Missões · Conquistas · Jornada.
///
/// [highlightQuest] vem da notificação (`/quests?quest=KEY`): a tela abre
/// na aba Missões, rola até a missão e a destaca.
/// [initialTab]: 0 missões, 1 conquistas, 2 jornada ("/quests?tab=journey").
class QuestsScreen extends ConsumerStatefulWidget {
  const QuestsScreen({super.key, this.highlightQuest, this.initialTab = 0});

  final String? highlightQuest;
  final int initialTab;

  @override
  ConsumerState<QuestsScreen> createState() => _QuestsScreenState();
}

class _QuestsScreenState extends ConsumerState<QuestsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(
    length: 3,
    vsync: this,
    initialIndex: widget.initialTab.clamp(0, 2),
  );

  @override
  void initState() {
    super.initState();
    _tabs.addListener(() {
      if (_tabs.indexIsChanging) {
        final fb = ref.read(feedbackServiceProvider);
        fb.setSoundsEnabled(
          ref.read(settingsViewModelProvider).value?.soundsEnabled ?? true,
        );
        fb.questTap();
      }
    });
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final colors = context.colors;
    final async = ref.watch(questsViewModelProvider);
    final user = ref.watch(authStateProvider).asData?.value;

    return Scaffold(
      backgroundColor: colors.background,
      body: Stack(
        children: [
          const Positioned.fill(child: QuestBackdrop()),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                // ── Topo ────────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 4, 16, 0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: colors.textPrimary,
                        ),
                        onPressed: () => Navigator.maybePop(context),
                      ),
                      Expanded(
                        child: Text(
                          s.questsTitle,
                          style: TextStyle(
                            color: colors.textPrimary,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.4,
                          ),
                        ),
                      ),
                      if (async.value != null)
                        _CoinsCounter(
                          coins: async.value!.streak.totalCoinsEarned,
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                // ── Abas ────────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _GameTabBar(
                    controller: _tabs,
                    labels: [
                      (s.questsTabMissions, Icons.flag_rounded),
                      (s.questsTabAchievements, Icons.emoji_events_rounded),
                      (s.questsTabJourney, Icons.timeline_rounded),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabs,
                    children: [
                      async.when(
                        loading: () => const QuestJourneyLoading(),
                        error: (_, _) => QuestJourneyError(
                          onRetry: () => ref
                              .read(questsViewModelProvider.notifier)
                              .refresh(),
                        ),
                        data: (data) => QuestMissionsTab(
                          data: data,
                          avatarUrl: user?.avatarUrl,
                          highlightKey: widget.highlightQuest,
                        ),
                      ),
                      const QuestAchievementsTab(),
                      const QuestTimelineTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Abas em formato de "botões de jogo": a aba ativa vira um bloco colorido
/// que desliza entre as opções.
class _GameTabBar extends StatelessWidget {
  const _GameTabBar({required this.controller, required this.labels});

  final TabController controller;
  final List<(String, IconData)> labels;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      height: 50,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Color.alphaBlend(
          colors.accentPrimary.withValues(alpha: context.isDark ? 0.10 : 0.06),
          colors.surface,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.border),
      ),
      child: TabBar(
        controller: controller,
        dividerColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.tab,
        splashBorderRadius: BorderRadius.circular(14),
        indicator: BoxDecoration(
          gradient: LinearGradient(
            colors: [colors.accentPrimary, colors.accentSecondary],
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: colors.accentPrimary.withValues(alpha: 0.45),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        labelColor: Colors.white,
        unselectedLabelColor: colors.textSecondary,
        labelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
        unselectedLabelStyle:
            const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
        labelPadding: EdgeInsets.zero,
        tabs: [
          for (final (label, icon) in labels)
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 17),
                  const SizedBox(width: 5),
                  Flexible(
                    child: Text(label, overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Moedas ganhas nas missões (canto superior direito, estilo jogo).
class _CoinsCounter extends StatelessWidget {
  const _CoinsCounter({required this.coins});
  final int coins;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(4, 4, 12, 4),
      decoration: BoxDecoration(
        color: const Color(0xFFFFB800).withValues(
          alpha: context.isDark ? 0.18 : 0.14,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFFFB800).withValues(alpha: 0.45),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Floating(
            amplitude: 2,
            tilt: 0.12,
            child: Image.asset(
              'assets/images/quests/coin_brc.png',
              width: 26,
              height: 26,
              errorBuilder: (_, _, _) => const Icon(
                Icons.monetization_on_rounded,
                color: Color(0xFFFFB800),
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 5),
          CountUpText(
            value: coins,
            style: TextStyle(
              color: context.colors.textPrimary,
              fontWeight: FontWeight.w900,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
