import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/models/live_room.dart';
import '../../core/themes/force_dark_theme.dart';
import '../../core/view_models/follow_view_model.dart';
import '../../live/shared/widgets/hud/streamer_identity_bar.dart';

/// Gaveta do perfil do adversário/parceiro (a mesma da identidade do criador):
/// Ver perfil, Seguir e — quando [onViewLive] existe — "Ver a live".
void showPartnerSheet(
  BuildContext context,
  WidgetRef ref, {
  required String userId,
  required String name,
  String? avatarUrl,
  String? roomId,
  VoidCallback? onViewLive,
}) {
  if (userId.isEmpty) return;
  final isFollowing = ref.read(followViewModelProvider(userId)).value ?? false;
  final room = LiveRoom(
    id: roomId ?? '',
    slug: roomId ?? '',
    title: '',
    liveType: 'solo',
    isPrivate: false,
    status: 'live',
    viewerCount: 0,
    totalLikes: 0,
    streamerId: userId,
    streamerName: name,
    streamerAvatarUrl: avatarUrl,
  );
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.5),
    builder: (_) => ForceDarkTheme(
      child: StreamerQuickSheet(
        room: room,
        displayName: name,
        isFollowing: isFollowing,
        onToggleFollow: () =>
            ref.read(followViewModelProvider(userId).notifier).toggleFollow(),
        onViewLive: onViewLive,
      ),
    ),
  );
}

/// Foto redonda do parceiro/adversário — fica na faixa escura logo ABAIXO da
/// metade dele (fora do vídeo). Minimalista: só a foto, sem nome nem link;
/// o toque abre a gaveta (Seguir / Ver a live).
class PartnerAvatarButton extends StatelessWidget {
  const PartnerAvatarButton({
    super.key,
    required this.name,
    required this.avatarUrl,
    required this.onTap,
    this.size = 36,
    this.muted = false,
  });

  /// Áudio do parceiro silenciado para quem assiste: selo de microfone.
  final bool muted;
  final String name;
  final String? avatarUrl;
  final VoidCallback onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    final url = avatarUrl ?? '';
    return Semantics(
      button: true,
      label: name,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Padding(
          // alvo de toque ≥ 44 px
          padding: const EdgeInsets.all(4),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              _photo(url),
              if (muted)
                Positioned(
                  right: -2,
                  bottom: -2,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF0B0E14),
                      border: Border.all(color: const Color(0x33FFFFFF)),
                    ),
                    child: const Icon(
                      Icons.mic_off_rounded,
                      size: 10,
                      color: Colors.white70,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _photo(String url) {
    return Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF1C2230),
              border: Border.all(color: const Color(0x33FFFFFF), width: 1.5),
              image: url.isEmpty
                  ? null
                  : DecorationImage(
                      image: NetworkImage(url),
                      fit: BoxFit.cover,
                    ),
            ),
            alignment: Alignment.center,
            child: url.isEmpty
                ? Text(
                    name.trim().isEmpty
                        ? '?'
                        : name.trim().characters.first.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      decoration: TextDecoration.none,
                    ),
                  )
                : null,
          );
  }
}
