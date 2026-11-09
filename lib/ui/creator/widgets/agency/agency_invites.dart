import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../domain/models/creator_agency.dart';
import '../../../../gen/l10n/app_localizations.dart';
import '../../../core/themes/brawe_colors.dart';
import 'agency_l10n.dart';
import 'agency_widgets.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Convites pendentes: lista objetiva (logo, nome, quem convidou, contrato, data)
// ─────────────────────────────────────────────────────────────────────────────

String agencyInviteRoute(String id) => '/creator/agency/invite/$id';

class AgencyInviteRowTile extends StatelessWidget {
  const AgencyInviteRowTile({super.key, required this.invite, this.onOpen});
  final AgencyInvite invite;

  /// Para testes; por padrão navega com go_router.
  final void Function(String id)? onOpen;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final c = context.colors;
    final who = invite.invitedBy;
    final by = who == null || who.displayName.isEmpty
        ? agencyRoleLabel(s, who)
        : s.agencyInviteRowBy(who.displayName, agencyRoleLabel(s, who));
    final meta = [
      if (invite.contractMonths != null)
        agencyMonthsText(s, invite.contractMonths),
      if (invite.invitedAt != null) agencyDateShort(context, invite.invitedAt),
    ].join(' · ');
    return AgencyBox(
      padding: const EdgeInsets.all(14),
      onTap: () => onOpen != null
          ? onOpen!(invite.inviteId)
          : context.push(agencyInviteRoute(invite.inviteId)),
      child: Row(
        children: [
          AgencyLogo(
            name: invite.agency.name,
            url: invite.agency.logoUrl,
            size: 44,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  invite.agency.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AgencyText.title(context),
                ),
                const SizedBox(height: 2),
                Text(
                  by,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AgencyText.caption(context),
                ),
                if (meta.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    meta,
                    style: AgencyText.caption(
                      context,
                    ).copyWith(color: c.textTertiary),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(LucideIcons.chevronRight, size: 18, color: c.textTertiary),
        ],
      ),
    );
  }
}

/// Lista de convites (aba Agência sem vínculo, ou folha quando já há vínculo).
class AgencyInvitesList extends StatelessWidget {
  const AgencyInvitesList({super.key, required this.invites, this.onOpen});
  final List<AgencyInvite> invites;
  final void Function(String id)? onOpen;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              Icon(LucideIcons.mail, size: 16, color: c.textSecondary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  s.agencyInvitesTitle,
                  style: AgencyText.title(context),
                ),
              ),
            ],
          ),
        ),
        for (var i = 0; i < invites.length; i++) ...[
          if (i > 0) const SizedBox(height: 10),
          AgencyInviteRowTile(invite: invites[i], onOpen: onOpen),
        ],
      ],
    );
  }
}

/// Faixa discreta quando há convites e o criador já está numa agência.
class AgencyInvitesBanner extends StatelessWidget {
  const AgencyInvitesBanner({
    super.key,
    required this.count,
    required this.onTap,
  });
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final c = context.colors;
    return Material(
      color: c.accentPrimary.withValues(alpha: 0.10),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Row(
              children: [
                Icon(LucideIcons.megaphone, size: 16, color: c.accentPrimary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    s.agencyInvitesBanner(count),
                    style: TextStyle(
                      color: c.textPrimary,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  s.agencyInvitesView,
                  style: TextStyle(
                    color: c.accentPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Icon(
                  LucideIcons.chevronRight,
                  size: 16,
                  color: c.accentPrimary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> showAgencyInvitesSheet(
  BuildContext context,
  List<AgencyInvite> invites,
) {
  return showModalBottomSheet<void>(
    useRootNavigator: true,
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (ctx) => SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        16,
        0,
        16,
        24 + MediaQuery.paddingOf(ctx).bottom,
      ),
      child: AgencyInvitesList(
        invites: invites,
        onOpen: (id) {
          Navigator.of(ctx).pop();
          context.push(agencyInviteRoute(id));
        },
      ),
    ),
  );
}
