import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/models/creator_network.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../../core/themes/brawe_colors.dart';
import '../utils/creator_l10n.dart';
import '../view_models/creator_network_view_model.dart';
import '../widgets/creator_benefit_tile.dart';
import '../widgets/creator_hero_card.dart';
import '../widgets/creator_state_views.dart';
import '../widgets/creator_tier_card.dart';

class CreatorProgramIntroScreen extends ConsumerWidget {
  const CreatorProgramIntroScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = S.of(context);
    final overviewAsync = ref.watch(networkOverviewProvider);
    final applicationAsync = ref.watch(myCreatorApplicationProvider);
    final creatorAsync = ref.watch(myCreatorProfileProvider);

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: context.colors.background,
        elevation: 0,
        title: Text(s.creatorProgramTitle),
      ),
      body: overviewAsync.when(
        loading: () => const CreatorLoadingView(),
        error: (e, _) => CreatorErrorView(
          message: '$e',
          onRetry: () => ref.invalidate(networkOverviewProvider),
        ),
        data: (overview) {
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(networkOverviewProvider);
              ref.invalidate(myCreatorApplicationProvider);
              ref.invalidate(myCreatorProfileProvider);
              await ref.read(networkOverviewProvider.future);
            },
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
              children: [
                CreatorHeroCard(
                  title: s.creatorProgramSubtitle,
                  subtitle: s.creatorProgramDescription,
                  actionLabel: _ctaLabel(s, applicationAsync, creatorAsync),
                  onAction: () => _onCta(context, applicationAsync, creatorAsync),
                ),
                const SizedBox(height: 18),
                _StatPill(
                  label: s.creatorTotalCreators(overview.totalCreators),
                ),
                const SizedBox(height: 22),
                _SectionTitle(s.creatorBenefitsHeader),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _benefit(context, Icons.visibility_rounded, s.creatorBenefit1),
                    _benefit(context, Icons.person_pin_rounded, s.creatorBenefit2),
                    _benefit(context, Icons.verified_rounded, s.creatorBenefit3),
                    _benefit(context, Icons.podcasts_rounded, s.creatorBenefit4),
                    _benefit(context, Icons.diversity_3_rounded, s.creatorBenefit5),
                  ],
                ),
                const SizedBox(height: 22),
                _SectionTitle(s.creatorLevelsTitle),
                const SizedBox(height: 4),
                Text(s.creatorLevelsSubtitle,
                    style: TextStyle(
                      color: context.colors.textSecondary,
                      fontSize: 13.5,
                    )),
                const SizedBox(height: 12),
                ...kCreatorTiersOrder.take(3).map(
                      (t) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: CreatorTierCard(
                          tier: t,
                          title: t.title(s),
                          description: t.body(s),
                          compact: true,
                          onTap: () => context.push('/creator/levels'),
                        ),
                      ),
                    ),
                TextButton(
                  onPressed: () => context.push('/creator/levels'),
                  child: Text(s.creatorActionViewLevels),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () => _onCta(context, applicationAsync, creatorAsync),
                  icon: const Icon(Icons.bolt_rounded),
                  label: Text(_ctaLabel(s, applicationAsync, creatorAsync)),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    backgroundColor: context.colors.accentPrimary,
                    foregroundColor: context.colors.textOnAccent,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _benefit(BuildContext context, IconData icon, String label) {
    return SizedBox(
      width: (MediaQuery.of(context).size.width - 16 * 2 - 10) / 2,
      child: CreatorBenefitTile(icon: icon, label: label),
    );
  }

  String _ctaLabel(
    S s,
    AsyncValue<CreatorApplication?> appAsync,
    AsyncValue<CreatorProfile?> creatorAsync,
  ) {
    if (creatorAsync.value != null) return s.creatorDashboardTitle;
    if (appAsync.value != null) return s.creatorActionCheckStatus;
    return s.creatorActionApplyNow;
  }

  void _onCta(
    BuildContext context,
    AsyncValue<CreatorApplication?> appAsync,
    AsyncValue<CreatorProfile?> creatorAsync,
  ) {
    if (creatorAsync.value != null) {
      context.push('/creator/dashboard');
    } else if (appAsync.value != null) {
      context.push('/creator/status');
    } else {
      context.push('/creator/apply');
    }
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: context.colors.textPrimary,
        fontWeight: FontWeight.w800,
        fontSize: 17,
        letterSpacing: -0.2,
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({required this.label});
  final String label;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: context.colors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.people_alt_rounded,
              size: 16, color: context.colors.accentPrimary),
          const SizedBox(width: 8),
          Text(label,
              style: TextStyle(
                color: context.colors.textPrimary,
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
              )),
        ],
      ),
    );
  }
}
