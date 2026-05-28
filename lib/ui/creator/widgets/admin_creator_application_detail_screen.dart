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

class AdminCreatorApplicationDetailScreen extends ConsumerStatefulWidget {
  const AdminCreatorApplicationDetailScreen({super.key, required this.id});
  final String id;
  @override
  ConsumerState<AdminCreatorApplicationDetailScreen> createState() =>
      _AdminCreatorApplicationDetailScreenState();
}

class _AdminCreatorApplicationDetailScreenState
    extends ConsumerState<AdminCreatorApplicationDetailScreen> {
  final _notes = TextEditingController();
  CreatorTier? _assignedTier;

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  Future<void> _decide(ApplicationStatus decision) async {
    final s = S.of(context);
    try {
      await ref
          .read(adminApplicationReviewControllerProvider.notifier)
          .review(
            widget.id,
            AdminReviewRequest(
              decision: decision,
              assignedTier: _assignedTier,
              internalNotes: _notes.text.trim().isEmpty
                  ? null
                  : _notes.text.trim(),
            ),
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(s.adminCreatorReviewSuccess)),
      );
      ref.invalidate(adminCreatorApplicationProvider(id: widget.id));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(s.adminCreatorReviewError)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final async = ref.watch(adminCreatorApplicationProvider(id: widget.id));

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: context.colors.background,
        elevation: 0,
        title: Text(s.adminCreatorAppDetailTitle),
      ),
      body: async.when(
        loading: () => const CreatorLoadingView(),
        error: (e, _) => CreatorErrorView(message: '$e'),
        data: (app) {
          _assignedTier ??= app.suggestedTier ?? app.requestedTier;
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(app.fullName,
                        style: TextStyle(
                          color: context.colors.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        )),
                  ),
                  CreatorStatusChip(
                      status: app.status, label: app.status.title(s)),
                ],
              ),
              Text('@${app.username} · ${app.email}',
                  style: TextStyle(
                    color: context.colors.textSecondary,
                    fontSize: 13,
                  )),
              const SizedBox(height: 20),
              _section(s.adminCreatorSectionInfo, [
                _row('País', app.country),
                _row('Cidade', app.city ?? '—'),
                _row('Idioma', app.language),
                _row('Telefone', app.phone ?? '—'),
                _row('Faz lives', app.doesLive ? 'Sim' : 'Não'),
                _row('Seguidores', '${app.followersCount}'),
                if (app.classifierScore != null)
                  _row('Score do classificador', '${app.classifierScore}'),
              ]),
              _section(s.adminCreatorSectionSocial, [
                if (app.socialLinks.instagram != null)
                  _row('Instagram', app.socialLinks.instagram!),
                if (app.socialLinks.tiktok != null)
                  _row('TikTok', app.socialLinks.tiktok!),
                if (app.socialLinks.youtube != null)
                  _row('YouTube', app.socialLinks.youtube!),
                if (!app.socialLinks.hasAny) _row('—', 'Sem redes informadas'),
              ]),
              _section(s.adminCreatorSectionNiche, [
                _row('Nicho', app.niche.name),
                if (app.requestedTier != null)
                  _row('Tier solicitado', app.requestedTier!.name),
                if (app.suggestedTier != null)
                  _row('Tier sugerido', app.suggestedTier!.name),
              ]),
              if (app.motivation != null && app.motivation!.isNotEmpty)
                _section(s.adminCreatorSectionMotivation,
                    [Text(app.motivation!, style: _bodyStyle(context))]),
              if (app.goals != null && app.goals!.isNotEmpty)
                _section(s.adminCreatorSectionGoals,
                    [Text(app.goals!, style: _bodyStyle(context))]),

              const SizedBox(height: 20),
              Text(s.adminCreatorSectionSuggestedTier,
                  style: _labelStyle(context)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8, runSpacing: 8,
                children: kCreatorTiersOrder.map((t) {
                  final selected = _assignedTier == t;
                  return GestureDetector(
                    onTap: () => setState(
                        () => _assignedTier = selected ? null : t),
                    child: Opacity(
                      opacity: selected ? 1 : 0.6,
                      child: CreatorTierBadge(
                        tier: t, size: 22, showLabel: true,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 18),
              Text(s.adminCreatorSectionNotes, style: _labelStyle(context)),
              const SizedBox(height: 6),
              TextField(
                controller: _notes,
                minLines: 3, maxLines: 6,
                style: TextStyle(color: context.colors.textPrimary),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: context.colors.surface,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: context.colors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                        color: context.colors.accentPrimary, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              _actions(s),
            ],
          );
        },
      ),
    );
  }

  Widget _actions(S s) {
    return Wrap(
      spacing: 8, runSpacing: 8,
      children: [
        FilledButton.icon(
          icon: const Icon(Icons.check_rounded),
          label: Text(s.adminCreatorActionApprove),
          onPressed: () => _decide(ApplicationStatus.approved),
          style: FilledButton.styleFrom(backgroundColor: context.colors.success),
        ),
        FilledButton.icon(
          icon: const Icon(Icons.close_rounded),
          label: Text(s.adminCreatorActionReject),
          onPressed: () => _decide(ApplicationStatus.rejected),
          style: FilledButton.styleFrom(backgroundColor: context.colors.danger),
        ),
        OutlinedButton.icon(
          icon: const Icon(Icons.bookmark_outline),
          label: Text(s.adminCreatorActionWaitlist),
          onPressed: () => _decide(ApplicationStatus.waitlist),
        ),
        OutlinedButton.icon(
          icon: const Icon(Icons.help_outline),
          label: Text(s.adminCreatorActionRequestInfo),
          onPressed: () => _decide(ApplicationStatus.needsMoreInfo),
        ),
        OutlinedButton.icon(
          icon: const Icon(Icons.verified_outlined),
          label: Text(s.adminCreatorActionInviteAmbassador),
          onPressed: () => _decide(ApplicationStatus.invitedToAmbassador),
        ),
        OutlinedButton.icon(
          icon: const Icon(Icons.diamond_outlined),
          label: Text(s.adminCreatorActionInviteFounding),
          onPressed: () =>
              _decide(ApplicationStatus.invitedToFoundingCreator),
        ),
      ],
    );
  }

  Widget _section(String title, List<Widget> children) => Padding(
        padding: const EdgeInsets.only(top: 18),
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
              Text(title, style: _labelStyle(context)),
              const SizedBox(height: 8),
              ...children,
            ],
          ),
        ),
      );

  Widget _row(String k, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 120,
              child: Text(k, style: _secondaryStyle(context)),
            ),
            Expanded(
              child: Text(v, style: _bodyStyle(context)),
            ),
          ],
        ),
      );

  TextStyle _labelStyle(BuildContext c) => TextStyle(
        color: c.colors.textPrimary,
        fontWeight: FontWeight.w800,
        fontSize: 14,
      );
  TextStyle _bodyStyle(BuildContext c) => TextStyle(
        color: c.colors.textPrimary,
        fontSize: 13.5,
        height: 1.4,
      );
  TextStyle _secondaryStyle(BuildContext c) => TextStyle(
        color: c.colors.textSecondary,
        fontSize: 12.5,
      );
}
