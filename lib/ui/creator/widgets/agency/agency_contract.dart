import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../domain/models/creator_agency.dart';
import '../../../../gen/l10n/app_localizations.dart';
import '../../../core/themes/brawe_colors.dart';
import 'agency_l10n.dart';
import 'agency_leave.dart';
import 'agency_terms_screen.dart';
import 'agency_widgets.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Contrato: período, aceite, termos, quem convidou e saída.
// ─────────────────────────────────────────────────────────────────────────────

class AgencyContractTab extends StatelessWidget {
  const AgencyContractTab({super.key, required this.link});
  final AgencyLink link;

  @override
  Widget build(BuildContext context) {
    return AgencyColumns(
      left: [
        AgencyContractCard(link: link),
        if (link.invitedBy != null) AgencyInvitedByCard(who: link.invitedBy),
      ],
      right: [AgencyLeaveSection(link: link)],
    );
  }
}

class AgencyContractCard extends StatelessWidget {
  const AgencyContractCard({super.key, required this.link});
  final AgencyLink link;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final c = context.colors;
    final ct = link.contract;
    final hasPeriod = ct.startedAt != null && ct.endsAt != null;
    final progress = ct.progress ??
        (hasPeriod
            ? (DateTime.now().difference(ct.startedAt!).inSeconds / ct.endsAt!.difference(ct.startedAt!).inSeconds).clamp(0.0, 1.0)
            : null);
    final accepted = link.acceptedAt ?? ct.startedAt;
    final version = link.termsVersion ?? link.terms.version;

    return AgencyBox(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        AgencyBoxTitle(
          icon: LucideIcons.fileSignature,
          text: s.agencyContractTitle,
          trailing: link.isTrial ? AgencyChip(label: s.agencyTrialBadge, color: c.warning) : null,
        ),
        const SizedBox(height: 12),
        if (hasPeriod) ...[
          Row(children: [
            Expanded(
              child: Text(s.agencyContractPeriod(agencyDate(context, ct.startedAt), agencyDate(context, ct.endsAt)),
                  style: AgencyText.body(context).copyWith(fontWeight: FontWeight.w700)),
            ),
            if (ct.months != null) ...[
              const SizedBox(width: 8),
              Text(agencyMonthsText(s, ct.months), style: AgencyText.caption(context)),
            ],
          ]),
          if (progress != null) ...[
            const SizedBox(height: 10),
            AgencyProgressBar(value: progress),
            const SizedBox(height: 6),
            Wrap(alignment: WrapAlignment.spaceBetween, spacing: 8, runSpacing: 2, children: [
              Text(s.agencyContractProgress((progress * 100).floor()), style: AgencyText.caption(context)),
              if (ct.daysLeft != null)
                Text(s.agencyDaysLeft(ct.daysLeft!),
                    style: TextStyle(color: c.textPrimary, fontSize: 12.5, fontWeight: FontWeight.w700, fontFeatures: kTabularFigures)),
            ]),
          ],
        ] else
          Text(s.agencyContractUnknown, style: AgencyText.caption(context)),
        const SizedBox(height: 8),
        const AgencyDivider(),
        AgencyInfoRow(icon: LucideIcons.circleCheck, label: s.agencyAcceptedLabel, value: agencyDate(context, accepted)),
        const AgencyDivider(),
        AgencyInfoRow(
          icon: LucideIcons.scrollText,
          label: s.agencyContractViewTerms,
          value: version != null ? s.agencyTermsVersion(version) : null,
          trailing: Icon(LucideIcons.chevronRight, size: 16, color: c.accentPrimary),
          onTap: () => openAgencyTerms(context, link.terms, version: version),
        ),
      ]),
    );
  }
}

class AgencyInvitedByCard extends StatelessWidget {
  const AgencyInvitedByCard({super.key, required this.who});
  final AgencyInviter? who;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return AgencyBox(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        AgencyBoxTitle(icon: LucideIcons.userCheck, text: s.agencyInvitedByTitle),
        const SizedBox(height: 12),
        AgencyInviterRow(who: who),
      ]),
    );
  }
}
