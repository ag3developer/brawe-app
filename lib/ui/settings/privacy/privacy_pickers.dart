// Folhas de escolha da Privacidade: "quem pode…" e "Limitar interações".

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../gen/l10n/app_localizations.dart';
import '../../core/themes/brawe_colors.dart';
import '../../../data/repositories/privacy_repository.dart';
import 'privacy_common.dart';

class _Option extends StatelessWidget {
  const _Option({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              selected ? LucideIcons.circleCheck : LucideIcons.circle,
              size: 22,
              color: selected ? colors.accentPrimary : colors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}

/// Escolha de "quem pode" — devolve o valor escolhido (ou null se fechar).
Future<String?> pickWho(
  BuildContext context, {
  required String title,
  required String description,
  required String current,
  required List<String> options,
}) {
  return showPrivacySheet<String>(
    context,
    builder: (ctx) {
      final s = S.of(ctx);
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PrivacySheetHeader(title: title, body: description),
          for (final o in options)
            _Option(
              label: whoLabel(s, o),
              selected: o == current,
              onTap: () => Navigator.pop(ctx, o),
            ),
          const SizedBox(height: 8),
        ],
      );
    },
  );
}

/// Limitar interações — devolve 0 | 24 | 72 | 168.
Future<int?> pickLimit(BuildContext context, PrivacySettings st) {
  return showPrivacySheet<int>(
    context,
    builder: (ctx) {
      final s = S.of(ctx);
      final left = limitRemainingText(s, st);
      final active = st.limitActive;
      final opts = <(int, String)>[
        (0, s.privacyLimitOff),
        (24, s.privacyLimit24h),
        (72, s.privacyLimit3d),
        (168, s.privacyLimit7d),
      ];
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PrivacySheetHeader(
            title: s.privacyLimitTitle,
            body: s.privacyLimitExplain,
          ),
          if (active && left != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Text(
                left,
                style: TextStyle(
                  color: ctx.colors.accentPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          for (final o in opts)
            _Option(
              label: o.$2,
              selected: active ? false : o.$1 == 0,
              onTap: () => Navigator.pop(ctx, o.$1),
            ),
          const SizedBox(height: 8),
        ],
      );
    },
  );
}

/// "Faltam 2 dias" / "Faltam 5 horas" (null se desligado).
String? limitRemainingText(S s, PrivacySettings st) {
  if (!st.limitActive) return null;
  final d = st.limitUntil!.difference(DateTime.now());
  if (d.inHours >= 24) {
    return s.privacyLimitLeftDays((d.inHours / 24).ceil());
  }
  return s.privacyLimitLeftHours(
    d.inMinutes <= 60 ? 1 : (d.inMinutes / 60).ceil(),
  );
}
