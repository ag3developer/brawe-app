import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../gen/l10n/app_localizations.dart';
import '../../core/themes/app_colors.dart';
import '../../core/themes/brawe_colors.dart';
import '../view_models/creator_journey_provider.dart';
import '../view_models/creator_network_view_model.dart';
import 'creator_journey_widgets.dart';
import 'creator_state_views.dart';

// ─────────────────────────────────────────────────────────────────────────────
// PAINEL DO CREATOR
// Dados: GET /creator/network/me/journey (nível, trilha, metas, semana,
// benefícios). Seções em creator_journey_widgets.dart.
// ─────────────────────────────────────────────────────────────────────────────

class CreatorDashboardScreen extends ConsumerWidget {
  const CreatorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = S.of(context);
    final profileAsync = ref.watch(myCreatorProfileProvider);

    return Scaffold(
      backgroundColor: context.colors.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: context.colors.background.withValues(alpha: 0.9),
        elevation: 0,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: const SizedBox.expand(),
          ),
        ),
        title: Text(
          s.creatorDashboardTitle,
          style: TextStyle(
            color: context.colors.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              LucideIcons.settings,
              size: 20,
              color: context.colors.textSecondary,
            ),
            onPressed: () => context.push('/creator/profile-settings'),
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
          return const _JourneyBody();
        },
      ),
    );
  }
}

class _JourneyBody extends ConsumerWidget {
  const _JourneyBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = S.of(context);
    final async = ref.watch(creatorJourneyProvider);
    final top = MediaQuery.of(context).padding.top + kToolbarHeight + 12;

    Future<void> refresh() async {
      ref.invalidate(creatorJourneyProvider);
      try {
        await ref.read(creatorJourneyProvider.future);
      } catch (_) {}
    }

    // Erro/carregando dentro de um scroll para o pull-to-refresh funcionar.
    Widget scrollable(Widget child) => RefreshIndicator(
          color: AppColors.braweBlue,
          onRefresh: refresh,
          child: LayoutBuilder(
            builder: (context, box) => SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: EdgeInsets.only(top: top),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: box.maxHeight - top),
                child: child,
              ),
            ),
          ),
        );

    return async.when(
      loading: () => scrollable(const Center(child: CreatorLoadingView())),
      error: (e, _) => scrollable(
        CreatorErrorView(message: s.creatorDashErrorTitle, onRetry: refresh),
      ),
      data: (journey) => RefreshIndicator(
        color: AppColors.braweBlue,
        onRefresh: refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: EdgeInsets.fromLTRB(16, top, 16, 32),
          children: [
            JourneyLevelCard(
              journey: journey,
              onTap: () => context.push('/creator/badge'),
            ),
            const SizedBox(height: 18),
            // Atalhos logo no topo: ganhos, análises, ao vivo, post.
            const JourneyShortcuts(),
            const SizedBox(height: 22),
            JourneyTrail(journey: journey),
            const SizedBox(height: 22),
            if (journey.goals.isNotEmpty) ...[
              JourneyGoalsSection(journey: journey),
              const SizedBox(height: 22),
            ],
            JourneyWeekSection(journey: journey),
            const SizedBox(height: 22),
            JourneyBenefitsSection(journey: journey),
          ],
        ),
      ),
    );
  }
}
