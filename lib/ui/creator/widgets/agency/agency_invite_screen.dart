import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../data/repositories/creator_agency_repository.dart';
import '../../../../domain/models/creator_agency.dart';
import '../../../../gen/l10n/app_localizations.dart';
import '../../../core/themes/brawe_colors.dart';
import '../../view_models/creator_agency_providers.dart';
import '../creator_state_views.dart';
import 'agency_l10n.dart';
import 'agency_terms_screen.dart';
import 'agency_widgets.dart';

const _afterRoute = '/creator/dashboard?tab=agency';

/// Convite aberto pelo cartão do chat ou pela lista: lê, aceita ou recusa.
class AgencyInviteScreen extends ConsumerWidget {
  const AgencyInviteScreen({super.key, required this.inviteId});
  final String inviteId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = S.of(context);
    final c = context.colors;
    final async = ref.watch(agencyInviteProvider(inviteId));
    Future<void> refresh() async {
      ref.invalidate(agencyInviteProvider(inviteId));
      try {
        await ref.read(agencyInviteProvider(inviteId).future);
      } catch (_) {}
    }

    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        backgroundColor: c.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(s.agencyInviteTitle, style: TextStyle(color: c.textPrimary, fontSize: 17, fontWeight: FontWeight.w700)),
      ),
      body: async.when(
        loading: () => const SingleChildScrollView(child: AgencySkeleton(blocks: [96, 72, 120, 160])),
        error: (e, _) => (e is AgencyException && e.code == 'not_found')
            ? CreatorEmptyState(
                icon: LucideIcons.mailOpen,
                title: s.agencyErrNotFound,
                actionLabel: s.creatorPanelTabAgency,
                onAction: () => context.go(_afterRoute),
              )
            : CreatorErrorView(message: agencyErrorText(context, e), onRetry: refresh),
        data: (invite) => RefreshIndicator(onRefresh: refresh, child: AgencyInviteBody(invite: invite)),
      ),
    );
  }
}

class AgencyInviteBody extends ConsumerStatefulWidget {
  const AgencyInviteBody({super.key, required this.invite});
  final AgencyInvite invite;
  @override
  ConsumerState<AgencyInviteBody> createState() => _AgencyInviteBodyState();
}

class _AgencyInviteBodyState extends ConsumerState<AgencyInviteBody> {
  bool _agreed = false;
  bool _busy = false;

  void _snack(String m) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  Future<void> _accept() async {
    final s = S.of(context);
    final inv = widget.invite;
    final version = inv.terms.version;
    if (version == null) return;
    final ok = await showAgencyConfirm(
      context,
      icon: LucideIcons.handshake,
      title: s.agencyAcceptConfirmTitle(inv.agency.name),
      body: s.agencyAcceptConfirmBody,
      action: s.agencyAcceptButton,
    );
    if (!ok || !mounted) return;
    setState(() => _busy = true);
    try {
      await ref.read(creatorAgencyRepositoryProvider).accept(inv.inviteId, version);
      ref.invalidate(creatorAgencyProvider);
      if (!mounted) return;
      _snack(S.of(context).agencyAcceptedSnack(inv.agency.name));
      context.go(_afterRoute);
    } catch (e) {
      if (!mounted) return;
      _snack(agencyErrorText(context, e));
      if (e is AgencyException && e.code == 'terms_version_mismatch') {
        setState(() => _agreed = false);
        ref.invalidate(agencyInviteProvider(inv.inviteId)); // recarrega os termos atuais
      } else if (e is AgencyException && (e.code == 'invite_not_pending' || e.code == 'creator_already_in_agency')) {
        ref.invalidate(creatorAgencyProvider);
        ref.invalidate(agencyInviteProvider(inv.inviteId));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _decline() async {
    final s = S.of(context);
    final inv = widget.invite;
    final ok = await showAgencyConfirm(
        context, title: s.agencyDeclineConfirmTitle, body: s.agencyDeclineConfirmBody, action: s.agencyDeclineButton, danger: true);
    if (!ok || !mounted) return;
    setState(() => _busy = true);
    try {
      await ref.read(creatorAgencyRepositoryProvider).decline(inv.inviteId);
      ref.invalidate(creatorAgencyProvider);
      if (!mounted) return;
      _snack(S.of(context).agencyDeclinedSnack);
      context.go(_afterRoute);
    } catch (e) {
      if (!mounted) return;
      _snack(agencyErrorText(context, e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final inv = widget.invite;

    if (!inv.isPending) {
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: AgencyColumns(left: [
          AgencyInviteHero(agency: inv.agency),
          AgencyBox(
            child: Row(children: [
              Icon(LucideIcons.mailOpen, size: 18, color: context.colors.textTertiary),
              const SizedBox(width: 10),
              Expanded(child: Text(s.agencyInviteUnavailable, style: AgencyText.body(context))),
            ]),
          ),
        ]),
      );
    }

    final canAccept = _agreed && !_busy && inv.terms.version != null;
    return Column(children: [
      Expanded(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: AgencyColumns(
            left: [
              AgencyInviteHero(agency: inv.agency),
              AgencyBox(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  AgencyBoxTitle(icon: LucideIcons.userCheck, text: s.agencyInvitedByTitle),
                  const SizedBox(height: 12),
                  AgencyInviterRow(who: inv.invitedBy),
                  if (inv.invitedAt != null) ...[
                    const SizedBox(height: 8),
                    Text(s.agencyInvitedOn(agencyDate(context, inv.invitedAt)), style: AgencyText.caption(context)),
                  ],
                  if (inv.contractMonths != null) ...[
                    const SizedBox(height: 4),
                    const AgencyDivider(),
                    AgencyInfoRow(
                        icon: LucideIcons.calendarRange,
                        label: s.agencyContractLength,
                        value: agencyMonthsText(s, inv.contractMonths)),
                  ],
                ]),
              ),
              if (inv.message != null)
                AgencyBox(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    AgencyBoxTitle(icon: LucideIcons.messageSquareText, text: s.agencyMessageTitle),
                    const SizedBox(height: 8),
                    Text(inv.message!, style: AgencyText.body(context)),
                  ]),
                ),
            ],
            right: [
              const AgencyPerksGrid(),
              AgencyTermsCollapsible(terms: inv.terms),
            ],
          ),
        ),
      ),
      _AcceptBar(
        agreed: _agreed,
        busy: _busy,
        canAccept: canAccept,
        version: inv.terms.version,
        onAgree: (v) => setState(() => _agreed = v),
        onAccept: _accept,
        onDecline: _decline,
      ),
    ]);
  }
}

/// Hero compacto: logo + nome + só o que a agência deixou público.
class AgencyInviteHero extends StatelessWidget {
  const AgencyInviteHero({super.key, required this.agency});
  final AgencyCard agency;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final c = context.colors;
    final facts = <(IconData, String)>[
      if (agency.country != null) (LucideIcons.mapPin, agency.country!),
      if (agency.creatorsCount != null) (LucideIcons.users, s.agencyCreatorsCount(agency.creatorsCount!)),
      if (agency.partnerSince != null) (LucideIcons.handshake, s.agencyPartnerSince(agencyMonthYear(context, agency.partnerSince))),
    ];
    final website = agency.website?.replaceFirst(RegExp(r'^https?://'), '').replaceFirst(RegExp(r'/$'), '');
    return AgencyBox(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          AgencyLogo(name: agency.name, url: agency.logoUrl, size: 56),
          const SizedBox(width: 14),
          Expanded(
            child: Text(agency.name,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: c.textPrimary, fontSize: 19, fontWeight: FontWeight.w800, height: 1.15)),
          ),
        ]),
        if (facts.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(spacing: 14, runSpacing: 6, children: [
            for (final f in facts)
              Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(f.$1, size: 14, color: c.textTertiary),
                const SizedBox(width: 5),
                Flexible(child: Text(f.$2, style: AgencyText.caption(context))),
              ]),
          ]),
        ],
        if (website != null || agency.socials.isNotEmpty || agency.niches.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(spacing: 6, runSpacing: 6, children: [
            if (website != null)
              AgencyChip(label: website, icon: LucideIcons.globe, color: c.accentPrimary, onTap: () => openAgencyUrl(agency.website!)),
            for (final e in agency.socials.entries) AgencyChip(label: e.value, icon: LucideIcons.atSign, color: c.accentSecondary),
            for (final n in agency.niches) AgencyChip(label: n),
          ]),
        ],
      ]),
    );
  }
}

/// "O que muda para você": grade 2x2 de ícone + frase curta.
class AgencyPerksGrid extends StatelessWidget {
  const AgencyPerksGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final c = context.colors;
    final items = <(IconData, String)>[
      (LucideIcons.wallet, s.agencyPerkEarnings),
      (LucideIcons.ban, s.agencyPerkNoCharges),
      (LucideIcons.userRound, s.agencyPerkAccount),
      (LucideIcons.doorOpen, s.agencyPerkExit),
    ];
    return AgencyBox(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        AgencyBoxTitle(icon: LucideIcons.shieldCheck, text: s.agencyWhatChangesTitle, color: c.success),
        const SizedBox(height: 12),
        LayoutBuilder(builder: (context, box) {
          const gap = 10.0;
          final w = (box.maxWidth - gap) / 2;
          return Wrap(spacing: gap, runSpacing: gap, children: [
            for (final it in items)
              SizedBox(
                width: w,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: c.surfaceHighest.withValues(alpha: 0.6), borderRadius: BorderRadius.circular(12)),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Icon(it.$1, size: 20, color: c.success),
                    const SizedBox(height: 8),
                    Text(it.$2, style: TextStyle(color: c.textPrimary, fontSize: 12.5, fontWeight: FontWeight.w600, height: 1.3)),
                  ]),
                ),
              ),
          ]);
        }),
      ]),
    );
  }
}

class _AcceptBar extends StatelessWidget {
  const _AcceptBar({
    required this.agreed,
    required this.busy,
    required this.canAccept,
    required this.version,
    required this.onAgree,
    required this.onAccept,
    required this.onDecline,
  });
  final bool agreed;
  final bool busy;
  final bool canAccept;
  final String? version;
  final ValueChanged<bool> onAgree;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final c = context.colors;
    final maxH = MediaQuery.sizeOf(context).height * 0.5;
    return Material(
      color: c.surface,
      elevation: 0,
      child: DecoratedBox(
        decoration: BoxDecoration(border: Border(top: BorderSide(color: c.border))),
        child: SafeArea(
          top: false,
          child: Center(
            heightFactor: 1,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 720, maxHeight: maxH),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: busy ? null : () => onAgree(!agreed),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 44),
                      child: Row(children: [
                        SizedBox(
                          width: 32,
                          child: Checkbox(value: agreed, onChanged: busy ? null : (v) => onAgree(v ?? false)),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(s.agencyAcceptCheckbox(version ?? '—'),
                              style: TextStyle(color: c.textPrimary, fontSize: 13, height: 1.3)),
                        ),
                      ]),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(children: [
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(foregroundColor: c.danger, minimumSize: const Size(48, 48)),
                      onPressed: busy ? null : onDecline,
                      child: Text(s.agencyDeclineButton),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(minimumSize: const Size(48, 48)),
                        onPressed: canAccept ? onAccept : null,
                        icon: busy
                            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Icon(LucideIcons.handshake, size: 17),
                        label: Text(s.agencyAcceptButton, textAlign: TextAlign.center),
                      ),
                    ),
                  ]),
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
