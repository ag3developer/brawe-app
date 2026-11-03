import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/services/social_actions_service.dart';
import '../../../gen/l10n/app_localizations.dart';
import '../themes/brawe_colors.dart';

/// Motivo de segurança infantil — valor aceito por POST /messages/reports.
const String kReportReasonChildSafety = 'child_safety';

/// Folha de denúncia reaproveitável (chat, live e onde mais precisar).
///
/// Mostra os motivos, envia ao backend e avisa o resultado com um SnackBar.
/// [targetType] precisa ser um dos aceitos pelo backend:
/// user | message | conversation | post | product | story | live | comment.
Future<void> showReportSheet(
  BuildContext context, {
  required String targetType,
  required String targetId,
}) async {
  // Capturados antes do await: o contexto de quem chamou pode morrer.
  final container = ProviderScope.containerOf(context, listen: false);
  final messenger = ScaffoldMessenger.maybeOf(context);
  final s = S.of(context);

  final reason = await showModalBottomSheet<String>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    backgroundColor: context.colors.surfaceElevated,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetCtx) => SafeArea(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: sheetCtx.colors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  s.viewerReportPrompt,
                  style: TextStyle(
                    color: sheetCtx.colors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
            ReportChildSafetyTile(
              onTap: () => Navigator.pop(sheetCtx, kReportReasonChildSafety),
            ),
            for (final (value, label) in <(String, String)>[
              ('spam', s.viewerReportSpam),
              ('harassment', s.viewerReportHarassment),
              ('inappropriate', s.viewerReportInappropriate),
              ('impersonation', s.viewerReportImpersonation),
              ('other', s.viewerReportOther),
            ])
              ListTile(
                title: Text(
                  label,
                  style: TextStyle(color: sheetCtx.colors.textPrimary),
                ),
                trailing: Icon(
                  Icons.chevron_right,
                  color: sheetCtx.colors.textTertiary,
                ),
                onTap: () => Navigator.pop(sheetCtx, value),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    ),
  );
  if (reason == null) return;

  try {
    await container
        .read(socialActionsServiceProvider)
        .report(targetType: targetType, targetId: targetId, reason: reason);
    messenger?.showSnackBar(SnackBar(content: Text(s.viewerReportSent)));
  } catch (_) {
    messenger?.showSnackBar(SnackBar(content: Text(s.viewerReportError)));
  }
}

/// Linha "Abuso ou exploração de menores" — em destaque, com o aviso
/// para procurar as autoridades em caso de perigo imediato.
class ReportChildSafetyTile extends StatelessWidget {
  const ReportChildSafetyTile({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return ListTile(
      leading: Icon(Icons.shield_outlined, color: context.colors.danger),
      title: Text(
        s.reportReasonChildSafety,
        style: TextStyle(
          color: context.colors.danger,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        s.reportChildSafetyNote,
        style: TextStyle(color: context.colors.textTertiary, fontSize: 12),
      ),
      trailing: Icon(Icons.chevron_right, color: context.colors.textTertiary),
      onTap: onTap,
    );
  }
}
