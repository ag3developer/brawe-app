import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import '../../../../core/themes/brawe_colors.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/themes/force_dark_theme.dart';
import '../../../../../gen/l10n/app_localizations.dart';

/// Bottom sheet moderno (glassmorphism + dark) que substitui o
/// `PopupMenuButton` material padrão. Mostra ações secundárias da live
/// (compartilhar internamente, denunciar, etc.).
///
/// Uso: `MoreSheet.show(context, onShare: () {...})`.
class MoreSheet extends StatelessWidget {
  const MoreSheet._({required this.onShare});
  final VoidCallback onShare;

  /// Abre o sheet com glassmorphism + dark sobre a live.
  static Future<void> show(
    BuildContext context, {
    required VoidCallback onShare,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      isScrollControlled: true,
      builder: (_) => ForceDarkTheme(child: MoreSheet._(onShare: onShare)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            decoration: BoxDecoration(
              color: context.colors.textPrimary.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: context.colors.textPrimary.withValues(alpha: 0.12),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(top: 10, bottom: 8),
                    decoration: BoxDecoration(
                      color: context.colors.textPrimary.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  _MoreTile(
                    icon: LucideIcons.send,
                    iconColor: context.colors.accentPrimary,
                    title: s.livePlayerShareTitle,
                    subtitle: s.livePlayerShareSubtitle,
                    onTap: () {
                      Navigator.of(context).pop();
                      onShare();
                    },
                  ),
                  Divider(
                    height: 1,
                    color: context.colors.textPrimary.withValues(alpha: 0.08),
                    indent: 64,
                  ),
                  _MoreTile(
                    icon: LucideIcons.flag,
                    iconColor: context.colors.danger,
                    title: s.livePlayerReportTitle,
                    subtitle: s.livePlayerReportSubtitle,
                    onTap: () {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(s.livePlayerReportSubmitted),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 4),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Linha clicável do `MoreSheet` — círculo colorido + título + subtítulo.
/// Privada (uso interno do sheet).
class _MoreTile extends StatelessWidget {
  const _MoreTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: context.colors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: context.colors.textPrimary.withValues(
                          alpha: 0.6,
                        ),
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                LucideIcons.chevronRight,
                color: context.colors.textPrimary.withValues(alpha: 0.35),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
