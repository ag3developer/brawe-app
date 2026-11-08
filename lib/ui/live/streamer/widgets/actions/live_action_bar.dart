import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../../gen/l10n/app_localizations.dart';

import '../../../../core/themes/app_colors.dart';
import 'action_btn.dart';

/// Bottom floating glass pill with the main broadcaster actions
/// (Pause/Resume, Battle, Co-host, Chat, More, End live).
class LiveActionBar extends StatelessWidget {
  const LiveActionBar({
    super.key,
    required this.isPaused,
    required this.isTogglingPause,
    required this.isTogglingStream,
    required this.hasBattle,
    required this.onBattle,
    this.onCoHost,
    this.coHostLabel,
    this.coHostIcon,
    this.battleLabel,
    this.battleIcon,
    required this.onPauseResume,
    required this.onEnd,
    required this.onMoreOptions,
    this.onGoals,
    this.showChat = false,
    this.onChatToggle,
  });

  final bool isPaused;
  final bool isTogglingPause;
  final bool isTogglingStream;
  final bool hasBattle;
  final VoidCallback onBattle;

  /// `null` esconde o botão (co-host ainda sem mídia em tempo real).
  final VoidCallback? onCoHost;

  /// Rótulo/ícone do botão de conexão ("Conectar" ou "Desconectar").
  final String? coHostLabel;
  final IconData? coHostIcon;

  /// Rótulo/ícone do botão de batalha ("Revanche" após o fim).
  final String? battleLabel;
  final IconData? battleIcon;
  final VoidCallback onPauseResume;
  final VoidCallback onEnd;
  final VoidCallback onMoreOptions;

  /// Metas da live (presente × quantidade ou curtidas).
  final VoidCallback? onGoals;
  final bool showChat;
  final VoidCallback? onChatToggle;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.32),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          // Cada botão ganha uma fatia igual e encolhe só se faltar espaço
          // (6 botões no iPhone SE).
          child: Row(
            children: [
              for (final btn in <Widget>[
                // Pause / Resume
                ActionBtn(
                  icon: isPaused ? LucideIcons.play : LucideIcons.pause,
                  label: isPaused ? 'Retomar' : 'Pausar',
                  color: isPaused ? const Color(0xFF22C55E) : Colors.orange,
                  loading: isTogglingPause,
                  onTap: onPauseResume,
                ),
                // ⚔ Batalha — destaque especial
                ActionBtn(
                  icon: battleIcon ?? LucideIcons.swords,
                  label:
                      battleLabel ??
                      (hasBattle
                          ? S.of(context).battleActionActive
                          : S.of(context).battleActionLabel),
                  color: AppColors.braweBlue,
                  glow: !hasBattle,
                  badge: hasBattle ? '⚔' : null,
                  onTap: hasBattle ? null : onBattle,
                ),
                // 👥 Co-host
                if (onCoHost != null)
                  ActionBtn(
                    icon: coHostIcon ?? LucideIcons.link,
                    label: coHostLabel ?? S.of(context).linkConnect,
                    color: const Color(0xFF0EA5E9),
                    onTap: onCoHost,
                  ),
                if (onGoals != null)
                  ActionBtn(
                    icon: LucideIcons.target,
                    label: S.of(context).goalsButton,
                    color: const Color(0xFFFFC53D),
                    onTap: onGoals,
                  ),
                // 💬 Chat
                ActionBtn(
                  icon: LucideIcons.messageCircle,
                  label: S.of(context).navChat,
                  color: showChat ? AppColors.braweBlue : Colors.white24,
                  onTap: onChatToggle,
                  flat: !showChat,
                ),
                // ···
                ActionBtn(
                  icon: LucideIcons.ellipsis,
                  label: S.of(context).broadcasterTooltipMore,
                  color: Colors.white24,
                  onTap: onMoreOptions,
                  flat: true,
                ),
                // ⏹ Encerrar
                ActionBtn(
                  icon: LucideIcons.square,
                  label: S.of(context).broadcasterEnd,
                  color: const Color(0xFFEF4444),
                  glow: true,
                  loading: isTogglingStream,
                  onTap: onEnd,
                ),
              ])
                Expanded(
                  child: FittedBox(fit: BoxFit.scaleDown, child: btn),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
