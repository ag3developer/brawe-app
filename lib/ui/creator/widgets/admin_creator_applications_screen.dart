import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/models/creator_network.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../../core/themes/brawe_colors.dart';
import '../utils/creator_l10n.dart';
import '../view_models/creator_network_view_model.dart';
import '../widgets/creator_state_views.dart';
import '../widgets/creator_status_chip.dart';
import '../widgets/creator_tier_badge.dart';

class AdminCreatorApplicationsScreen extends ConsumerWidget {
  const AdminCreatorApplicationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = S.of(context);
    final filter = ref.watch(adminApplicationsFilterProvider);
    final async = ref.watch(adminCreatorApplicationsProvider);

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: context.colors.background,
        elevation: 0,
        title: Text(s.adminCreatorAppsTitle),
      ),
      body: Column(
        children: [
          _Filters(current: filter, l10n: s),
          Expanded(
            child: async.when(
              loading: () => const CreatorLoadingView(),
              error: (e, _) => CreatorErrorView(
                message: s.adminCreatorAppsLoadError,
                onRetry: () => ref.invalidate(adminCreatorApplicationsProvider),
              ),
              data: (page) {
                if (page.items.isEmpty) {
                  return CreatorEmptyState(
                    icon: Icons.inbox_outlined,
                    title: s.adminCreatorAppsEmpty,
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(adminCreatorApplicationsProvider);
                    await ref.read(adminCreatorApplicationsProvider.future);
                  },
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                    itemCount: page.items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) => _ApplicationTile(
                      item: page.items[i],
                      onTap: () => context.push(
                        '/admin/creator/applications/${page.items[i].id}',
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Filters extends ConsumerWidget {
  const _Filters({required this.current, required this.l10n});
  final AdminApplicationFilter current;
  final S l10n;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(adminApplicationsFilterProvider.notifier);
    final entries = <(ApplicationStatus?, String)>[
      (null, l10n.adminCreatorAppsFilterAll),
      (ApplicationStatus.pendingReview, l10n.adminCreatorAppsFilterPending),
      (ApplicationStatus.underAnalysis, l10n.adminCreatorAppsFilterAnalysis),
      (ApplicationStatus.approved, l10n.adminCreatorAppsFilterApproved),
      (ApplicationStatus.rejected, l10n.adminCreatorAppsFilterRejected),
      (ApplicationStatus.waitlist, l10n.adminCreatorAppsFilterWaitlist),
      (ApplicationStatus.needsMoreInfo, l10n.adminCreatorAppsFilterNeedsInfo),
    ];
    return SizedBox(
      height: 46,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemBuilder: (_, i) {
          final (status, label) = entries[i];
          final selected = current.status == status;
          return ChoiceChip(
            label: Text(label),
            selected: selected,
            onSelected: (_) => notifier.setStatus(status),
            selectedColor: context.colors.accentPrimary,
            backgroundColor: context.colors.surface,
            labelStyle: TextStyle(
              color: selected
                  ? context.colors.textOnAccent
                  : context.colors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 12.5,
            ),
            side: BorderSide(color: context.colors.border),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemCount: entries.length,
      ),
    );
  }
}

class _ApplicationTile extends StatelessWidget {
  const _ApplicationTile({required this.item, required this.onTap});
  final AdminApplicationListItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: context.colors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(item.fullName,
                        style: TextStyle(
                          color: context.colors.textPrimary,
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        )),
                  ),
                  CreatorStatusChip(
                    status: item.status,
                    label: item.status.title(s),
                    dense: true,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text('@${item.username} · ${item.country} · ${item.niche.name}',
                  style: TextStyle(
                    color: context.colors.textSecondary,
                    fontSize: 12.5,
                  )),
              const SizedBox(height: 10),
              Row(
                children: [
                  if (item.suggestedTier != null)
                    CreatorTierBadge(
                      tier: item.suggestedTier!, size: 18, showLabel: true,
                    ),
                  const Spacer(),
                  Icon(Icons.person_outline,
                      size: 14, color: context.colors.textTertiary),
                  const SizedBox(width: 4),
                  Text('${item.followersCount}',
                      style: TextStyle(
                        color: context.colors.textSecondary,
                        fontSize: 12,
                      )),
                  if (item.classifierScore != null) ...[
                    const SizedBox(width: 14),
                    Icon(Icons.analytics_outlined,
                        size: 14, color: context.colors.textTertiary),
                    const SizedBox(width: 4),
                    Text('${item.classifierScore}',
                        style: TextStyle(
                          color: context.colors.textSecondary,
                          fontSize: 12,
                        )),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
