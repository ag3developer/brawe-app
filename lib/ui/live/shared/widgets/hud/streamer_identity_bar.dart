import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../domain/models/live_room.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/ui/follow_button.dart';
import '../../../../core/view_models/follow_view_model.dart';

/// Pílula glass com avatar + nome do streamer.
///
/// Comportamento:
/// - Avatar + nome SEMPRE visíveis (essencial para viewer novo conhecer
///   quem está transmitindo).
/// - Botão "Seguir" só aparece quando o viewer ainda NÃO segue — limpa o
///   HUD de quem já é fã.
/// - Tap no avatar/nome abre um bottom-sheet rápido ("Ver perfil" /
///   "Seguir") sem tirar o usuário da live.
class StreamerIdentityBar extends ConsumerWidget {
  const StreamerIdentityBar({super.key, required this.room});
  final LiveRoom room;

  static String displayStreamerName(LiveRoom r) {
    // Prioridade: streamerName real → @username → fallback @id6 → 'Streamer'.
    // ⚠️ NUNCA cair para `r.title` (título da live) — o título só faz
    // sentido no card de descoberta (For You), não no header da live.
    final name = r.streamerName.trim();
    final looksGeneric = name.isEmpty ||
        name.toLowerCase() == 'streamer' ||
        RegExp(r'^streamer-?[0-9a-f]{0,8}$', caseSensitive: false)
            .hasMatch(name);
    if (!looksGeneric) return name;
    final username = (r.streamerUsername ?? '').trim();
    if (username.isNotEmpty) {
      return username.startsWith('@') ? username : '@$username';
    }
    final id = r.streamerId;
    if (id.length >= 6) return '@${id.substring(0, 6)}';
    return 'Streamer';
  }

  void _openQuickSheet(BuildContext context, WidgetRef ref, bool isFollowing) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (_) => StreamerQuickSheet(
        room: room,
        displayName: displayStreamerName(room),
        isFollowing: isFollowing,
        onToggleFollow: () => ref
            .read(followViewModelProvider(room.streamerId).notifier)
            .toggleFollow(),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final followAsync = ref.watch(followViewModelProvider(room.streamerId));
    final isFollowing = followAsync.value ?? false;

    return GestureDetector(
      onTap: () => _openQuickSheet(context, ref, isFollowing),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            padding: const EdgeInsets.fromLTRB(3, 3, 3, 3),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.32),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.10),
                width: 0.6,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: AppColors.electricPurple,
                  backgroundImage: room.streamerAvatarUrl != null
                      ? NetworkImage(room.streamerAvatarUrl!)
                      : null,
                  child: room.streamerAvatarUrl == null
                      ? const Icon(Icons.person, size: 14, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 7),
                Flexible(
                  child: Text(
                    displayStreamerName(room),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 12.5,
                      letterSpacing: 0.1,
                    ),
                  ),
                ),
                if (room.streamerVerified) ...[
                  const SizedBox(width: 3),
                  const Icon(Icons.verified,
                      color: Color(0xFFB6A6FF), size: 13),
                ],
                // Botão "Seguir" só aparece se NÃO segue (HUD limpo para fãs).
                if (!isFollowing) ...[
                  const SizedBox(width: 8),
                  FollowButton(userId: room.streamerId, compact: true),
                ] else
                  const SizedBox(width: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Bottom sheet rápido ao tocar no avatar/nome do streamer.
/// Permite seguir/ver perfil sem sair da live.
class StreamerQuickSheet extends StatelessWidget {
  const StreamerQuickSheet({
    super.key,
    required this.room,
    required this.displayName,
    required this.isFollowing,
    required this.onToggleFollow,
  });

  final LiveRoom room;
  final String displayName;
  final bool isFollowing;
  final VoidCallback onToggleFollow;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF0A0B14).withValues(alpha: 0.86),
              border: Border(
                top: BorderSide(
                  color: Colors.white.withValues(alpha: 0.08),
                  width: 0.6,
                ),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 18),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                CircleAvatar(
                  radius: 36,
                  backgroundColor: AppColors.electricPurple,
                  backgroundImage: room.streamerAvatarUrl != null
                      ? NetworkImage(room.streamerAvatarUrl!)
                      : null,
                  child: room.streamerAvatarUrl == null
                      ? const Icon(Icons.person, size: 36, color: Colors.white)
                      : null,
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    if (room.streamerVerified) ...[
                      const SizedBox(width: 6),
                      const Icon(Icons.verified,
                          color: Color(0xFFB6A6FF), size: 18),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  room.title,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.65),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _QuickSheetButton(
                        icon: Icons.person_outline_rounded,
                        label: 'Ver perfil',
                        filled: false,
                        onTap: () {
                          Navigator.of(context).pop();
                          context.push('/profile/${room.streamerId}');
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _QuickSheetButton(
                        icon: isFollowing
                            ? Icons.check_rounded
                            : Icons.add_rounded,
                        label: isFollowing ? 'Seguindo' : 'Seguir',
                        filled: !isFollowing,
                        onTap: () {
                          onToggleFollow();
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickSheetButton extends StatelessWidget {
  const _QuickSheetButton({
    required this.icon,
    required this.label,
    required this.filled,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final bool filled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          gradient: filled
              ? const LinearGradient(
                  colors: [Color(0xFF7C3AED), Color(0xFFB44CF0)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: filled ? null : Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: filled
              ? null
              : Border.all(color: Colors.white.withValues(alpha: 0.12)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
