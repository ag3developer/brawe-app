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
import '../widgets/creator_timeline.dart';

class CreatorApplicationStatusScreen extends ConsumerWidget {
  const CreatorApplicationStatusScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = S.of(context);
    final appAsync = ref.watch(myCreatorApplicationProvider);

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: context.colors.background,
        elevation: 0,
        title: Text(s.creatorProgramTitle),
      ),
      body: appAsync.when(
        loading: () => const CreatorLoadingView(),
        error: (e, _) => CreatorErrorView(
          message: '$e',
          onRetry: () => ref.invalidate(myCreatorApplicationProvider),
        ),
        data: (app) {
          if (app == null) {
            return CreatorEmptyState(
              icon: Icons.send_rounded,
              title: s.creatorActionApplyNow,
              subtitle: s.creatorProgramDescription,
              actionLabel: s.creatorActionApplyNow,
              onAction: () => context.go('/creator/apply'),
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(myCreatorApplicationProvider);
              await ref.read(myCreatorApplicationProvider.future);
            },
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              children: [
                _StatusHeader(status: app.status),
                const SizedBox(height: 18),
                _SectionTitle(label: 'Linha do tempo'),
                const SizedBox(height: 10),
                CreatorTimeline(steps: _buildTimeline(app)),
                const SizedBox(height: 8),
                _SectionTitle(label: 'Sua inscrição'),
                const SizedBox(height: 8),
                _InfoCard(app: app),
                const SizedBox(height: 18),
                _Actions(app: app),
              ],
            ),
          );
        },
      ),
    );
  }

  List<CreatorTimelineStep> _buildTimeline(CreatorApplication app) {
    final st = app.status;
    return [
      CreatorTimelineStep(
        title: 'Inscrição enviada',
        subtitle: _fmt(app.createdAt),
        icon: Icons.send_rounded,
        completed: true,
      ),
      CreatorTimelineStep(
        title: 'Em análise',
        icon: Icons.search_rounded,
        active: st == ApplicationStatus.underAnalysis ||
            st == ApplicationStatus.pendingReview ||
            st == ApplicationStatus.needsMoreInfo,
        completed: st.isTerminal ||
            st == ApplicationStatus.invitedToAmbassador ||
            st == ApplicationStatus.invitedToFoundingCreator,
      ),
      CreatorTimelineStep(
        title: st == ApplicationStatus.rejected
            ? 'Decisão final'
            : 'Resultado',
        icon: st.isPositive
            ? Icons.celebration_rounded
            : st == ApplicationStatus.rejected
                ? Icons.cancel_rounded
                : Icons.flag_rounded,
        color: st.color,
        active: !st.isTerminal && st.needsAction,
        completed: st.isTerminal || st.isPositive,
      ),
    ];
  }

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}

class _StatusHeader extends StatelessWidget {
  const _StatusHeader({required this.status});
  final ApplicationStatus status;
  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: status.color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CreatorStatusChip(status: status, label: status.title(s)),
          const SizedBox(height: 14),
          Text(
            status.body(s),
            style: TextStyle(
              color: context.colors.textPrimary,
              fontSize: 14.5,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _Actions extends ConsumerWidget {
  const _Actions({required this.app});
  final CreatorApplication app;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = S.of(context);
    final st = app.status;
    final children = <Widget>[];

    if (st.needsAction) {
      children.add(FilledButton.icon(
        icon: const Icon(Icons.edit_rounded),
        label: Text(s.creatorStatusUpdateApplication),
        onPressed: () => context.push('/creator/apply'),
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          backgroundColor: context.colors.warning,
        ),
      ));
    }
    if (st.isPositive) {
      children.add(FilledButton.icon(
        icon: const Icon(Icons.rocket_launch_rounded),
        label: Text(s.creatorStatusStartOnboarding),
        onPressed: () => context.go('/creator/onboarding'),
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          backgroundColor: context.colors.success,
        ),
      ));
    }
    if (children.isEmpty) {
      children.add(OutlinedButton.icon(
        icon: const Icon(Icons.home_rounded),
        label: Text(s.creatorSubmittedHome),
        onPressed: () => context.go('/home'),
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
        ),
      ));
    }
    return Column(children: children);
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.app});
  final CreatorApplication app;
  @override
  Widget build(BuildContext context) {
    Widget row(String k, String v) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 120,
                child: Text(k,
                    style: TextStyle(
                      color: context.colors.textSecondary,
                      fontSize: 12.5,
                    )),
              ),
              Expanded(
                child: Text(v,
                    style: TextStyle(
                      color: context.colors.textPrimary,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                    )),
              ),
            ],
          ),
        );
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.colors.border),
      ),
      child: Column(
        children: [
          row('Nome', app.fullName),
          row('Username', '@${app.username}'),
          row('País', app.country),
          row('Nicho', app.niche.name),
          if (app.requestedTier != null)
            row('Tier solicitado', app.requestedTier!.name),
          row('Seguidores', '${app.followersCount}'),
          row('Faz lives', app.doesLive ? 'Sim' : 'Não'),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.label});
  final String label;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(label,
          style: TextStyle(
            color: context.colors.textPrimary,
            fontWeight: FontWeight.w800,
            fontSize: 15,
          )),
    );
  }
}
