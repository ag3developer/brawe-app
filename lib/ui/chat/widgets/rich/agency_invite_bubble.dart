import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../domain/models/conversation.dart';
import '../../../../gen/l10n/app_localizations.dart';
import '../../../core/themes/brawe_colors.dart';
import '../../../creator/widgets/agency/agency_l10n.dart';
import '../../../creator/widgets/agency/agency_widgets.dart';

/// Cartão do convite de agência no chat (`message_type == "agency_invite"`).
/// content = {type, invite_id, agency_id, agency_name, agency_logo_url,
/// contract_months, message}. Quem recebe abre a tela do convite; quem enviou
/// vê o cartão como confirmação (sem botão).
class AgencyInviteBubble extends StatelessWidget {
  const AgencyInviteBubble({super.key, required this.message, required this.isMe, this.onOpen});
  final ChatMessage message;
  final bool isMe;

  /// Para testes/overrides; por padrão navega com go_router.
  final void Function(String inviteId)? onOpen;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final c = context.colors;
    final p = message.payload ?? const <String, dynamic>{};
    final inviteId = p['invite_id']?.toString();
    final name = (p['agency_name']?.toString().trim().isNotEmpty ?? false) ? p['agency_name'].toString().trim() : s.agencyTitle;
    final logo = p['agency_logo_url']?.toString();
    final months = p['contract_months'] is num ? (p['contract_months'] as num).toInt() : int.tryParse('${p['contract_months']}');
    final note = p['message']?.toString().trim();
    final canOpen = !isMe && inviteId != null && inviteId.isNotEmpty && !message.isPending;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 320, minWidth: 220),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: c.accentPrimary.withValues(alpha: 0.5)),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            AgencyLogo(name: name, url: (logo != null && logo.isNotEmpty) ? logo : null, size: 46),
            const SizedBox(width: 10),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(name, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: c.textPrimary, fontSize: 15, fontWeight: FontWeight.w800, height: 1.15)),
                const SizedBox(height: 2),
                Text(isMe ? s.agencyChatInviteSent : s.agencyChatInvitedYou,
                    maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: c.textSecondary, fontSize: 12.5, height: 1.25)),
              ]),
            ),
          ]),
          if (months != null) ...[
            const SizedBox(height: 10),
            AgencyChip(label: s.agencyContractOf(agencyMonthsText(s, months)), icon: LucideIcons.calendarRange, color: c.accentPrimary),
          ],
          if (note != null && note.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(note, maxLines: 5, overflow: TextOverflow.ellipsis, style: TextStyle(color: c.textPrimary, fontSize: 13.5, height: 1.4)),
          ],
          if (canOpen) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => onOpen != null ? onOpen!(inviteId) : context.push('/creator/agency/invite/$inviteId'),
                icon: const Icon(LucideIcons.mailOpen, size: 16),
                label: Text(s.agencyChatOpen),
              ),
            ),
          ],
        ]),
      ),
    );
  }
}
