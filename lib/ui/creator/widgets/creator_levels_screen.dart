import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../gen/l10n/app_localizations.dart';
import '../../core/themes/brawe_colors.dart';
import '../utils/creator_l10n.dart';
import '../view_models/creator_network_view_model.dart';
import '../widgets/creator_state_views.dart';
import '../widgets/creator_tier_card.dart';

class CreatorLevelsScreen extends ConsumerWidget {
  const CreatorLevelsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = S.of(context);
    final overviewAsync = ref.watch(networkOverviewProvider);

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: context.colors.background,
        elevation: 0,
        title: Text(s.creatorLevelsTitle),
      ),
      body: overviewAsync.when(
        loading: () => const CreatorLoadingView(),
        error: (e, _) => CreatorErrorView(message: '$e'),
        data: (overview) {
          // Mescla os tiers do backend (descrições + perks reais) com o nosso
          // fallback ordenado (case-of). Se o backend não trouxer um tier,
          // usamos o ARB local.
          final byTier = {for (final t in overview.tiers) t.slug: t};

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
            children: [
              Text(s.creatorLevelsSubtitle,
                  style: TextStyle(
                    color: context.colors.textSecondary,
                    fontSize: 14,
                    height: 1.4,
                  )),
              const SizedBox(height: 18),
              for (final tier in kCreatorTiersOrder) ...[
                CreatorTierCard(
                  tier: tier,
                  title: byTier[tier]?.name.isNotEmpty == true
                      ? byTier[tier]!.name
                      : tier.title(s),
                  description: byTier[tier]?.description.isNotEmpty == true
                      ? byTier[tier]!.description
                      : tier.body(s),
                  perks: byTier[tier]?.perks ?? const [],
                ),
                const SizedBox(height: 12),
              ],
              const SizedBox(height: 12),
              FilledButton.icon(
                icon: const Icon(Icons.bolt_rounded),
                label: Text(s.creatorTierApplyCta),
                onPressed: () => context.push('/creator/apply'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  backgroundColor: context.colors.accentPrimary,
                  foregroundColor: context.colors.textOnAccent,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
