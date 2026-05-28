import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../gen/l10n/app_localizations.dart';
import '../../core/themes/brawe_colors.dart';
import '../view_models/creator_network_view_model.dart';
import '../widgets/creator_checklist_item.dart';
import '../widgets/creator_hero_card.dart';
import '../widgets/creator_state_views.dart';

class CreatorOnboardingScreen extends ConsumerWidget {
  const CreatorOnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = S.of(context);
    final async = ref.watch(creatorOnboardingProvider);

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: context.colors.background,
        elevation: 0,
        title: Text(s.creatorOnboardingTitle),
      ),
      body: async.when(
        loading: () => const CreatorLoadingView(),
        error: (e, _) => CreatorErrorView(
          message: '$e',
          onRetry: () => ref.invalidate(creatorOnboardingProvider),
        ),
        data: (checklist) {
          final done = checklist.steps.where((e) => e.completed).length;
          final total = checklist.steps.length;

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(creatorOnboardingProvider);
              await ref.read(creatorOnboardingProvider.future);
            },
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
              children: [
                CreatorHeroCard(
                  title: s.creatorOnboardingTitle,
                  subtitle: s.creatorOnboardingSubtitle,
                  icon: Icons.rocket_launch_rounded,
                  gradient: const [
                    Color(0xFF22C55E),
                    Color(0xFF14B8A6),
                    Color(0xFF3B82F6),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          value: total == 0 ? 0 : done / total,
                          minHeight: 10,
                          backgroundColor: context.colors.surfaceHighest,
                          valueColor: AlwaysStoppedAnimation(
                              context.colors.accentPrimary),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(s.creatorOnboardingProgress(done, total),
                        style: TextStyle(
                          color: context.colors.textSecondary,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                        )),
                  ],
                ),
                const SizedBox(height: 18),
                ...checklist.steps.map(
                  (step) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: CreatorChecklistItem(
                      title: step.title,
                      description: step.description,
                      completed: step.completed,
                      onTap: step.completed
                          ? null
                          : () async {
                              await ref
                                  .read(onboardingControllerProvider.notifier)
                                  .completeStep(step.key);
                            },
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                if (done == total && total > 0)
                  FilledButton.icon(
                    icon: const Icon(Icons.dashboard_rounded),
                    label: Text(s.creatorDashboardTitle),
                    onPressed: () => context.go('/creator/dashboard'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                      backgroundColor: context.colors.accentPrimary,
                      foregroundColor: context.colors.textOnAccent,
                    ),
                  )
                else
                  TextButton(
                    onPressed: () => context.go('/home'),
                    child: Text(s.creatorOnboardingSkip),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
