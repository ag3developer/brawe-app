import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../../../core/themes/app_colors.dart';
import 'action_btn.dart';

/// Bottom floating glass pill with the main broadcaster actions
/// (Pause/Resume, Battle, Co-host, More, End live).
class LiveActionBar extends StatelessWidget {
  const LiveActionBar({
    super.key,
    required this.isPaused,
    required this.isTogglingPause,
    required this.isTogglingStream,
    required this.hasBattle,
    required this.onBattle,
    required this.onCoHost,
    required this.onPauseResume,
    required this.onEnd,
    required this.onMoreOptions,
  });

  final bool isPaused;
  final bool isTogglingPause;
  final bool isTogglingStream;
  final bool hasBattle;
  final VoidCallback onBattle;
  final VoidCallback onCoHost;
  final VoidCallback onPauseResume;
  final VoidCallback onEnd;
  final VoidCallback onMoreOptions;

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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Pause / Resume
              ActionBtn(
                icon: isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                label: isPaused ? 'Retomar' : 'Pausar',
                color: isPaused ? const Color(0xFF22C55E) : Colors.orange,
                loading: isTogglingPause,
                onTap: onPauseResume,
              ),
              // ⚔ Batalha — destaque especial
              ActionBtn(
                icon: Icons.sports_kabaddi_rounded,
                label: hasBattle ? 'Em batalha' : 'Batalha',
                color: AppColors.electricPurple,
                glow: !hasBattle,
                badge: hasBattle ? '⚔' : null,
                onTap: hasBattle ? null : onBattle,
              ),
              // 👥 Co-host
              ActionBtn(
                icon: Icons.people_alt_rounded,
                label: 'Co-host',
                color: const Color(0xFF0EA5E9),
                onTap: onCoHost,
              ),
              // ···
              ActionBtn(
                icon: Icons.more_horiz_rounded,
                label: 'Mais',
                color: Colors.white24,
                onTap: onMoreOptions,
                flat: true,
              ),
              // ⏹ Encerrar
              ActionBtn(
                icon: Icons.stop_rounded,
                label: 'Encerrar',
                color: const Color(0xFFEF4444),
                glow: true,
                loading: isTogglingStream,
                onTap: onEnd,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
