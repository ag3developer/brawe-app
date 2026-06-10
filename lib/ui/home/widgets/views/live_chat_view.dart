import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../domain/models/feed_item.dart';
import '../../../../domain/models/live_room.dart';
import 'shared/_live_peek.dart';

/// 💬 Card de [LiveChatItem] no For You — "Live Peek".
///
/// Layout reorganizado (sem sobreposições):
/// - Preview do stream ocupa o fundo inteiro; tap em qualquer área entra na live.
/// - Bloco inferior esquerdo coeso, hierarquia de baixo pra cima:
///   1. Comentários reais (fade no topo, max 4 linhas, largura limitada)
///   2. Caption (título da live)
///   3. Identidade compacta: avatar + nome + @username + AO VIVO + viewers
///   4. CTA "Assistir ao Vivo" (pílula, alinhada à esquerda)
/// - Margem direita preservada (~76px) para não colidir com o ActionRail.
class LiveChatView extends StatelessWidget {
  const LiveChatView({super.key, required this.item, this.isActive = true});
  final LiveChatItem item;
  final bool isActive;

  void _enter(BuildContext context) {
    // Passa a LiveRoom já construída com os dados do feed → sem request HTTP
    // no tap. A rota usa o `extra` diretamente, igual ao TikTok.
    final room = LiveRoom(
      id: item.id,
      slug: item.slug ?? item.id,
      title: item.caption,
      liveType: 'chat',
      isPrivate: false,
      status: 'live',
      viewerCount: item.viewerCount,
      totalLikes: item.likesCount,
      thumbnailUrl: item.thumbnailUrl,
      streamUrl: item.streamUrl,
      streamerId: item.author.id,
      streamerName: item.author.name,
      streamerAvatarUrl: item.author.avatarUrl,
      streamerUsername: item.author.username,
      streamerVerified: item.author.isVerified,
    );
    openLiveRoom(context, item.id, room);
  }
  void _openProfile(BuildContext context) {
    if (item.author.id.isEmpty) return;
    context.push('/profile/${item.author.id}');
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // ── Fundo: tap entra na live ──
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _enter(context),
          child: LivePeekBackground(
            roomId: item.id,
            thumbnailUrl: item.thumbnailUrl,
            streamUrl: item.streamUrl,
            isActive: isActive,
          ),
        ),

        // ── Bloco único inferior esquerdo (sem sobreposições) ──
        // Margem direita generosa para o ActionRail (76px) + bottom acima
        // da tab bar do app (~96px).
        Positioned(
          left: 16,
          right: 88,
          bottom: 96,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Comentários reais (faixa estreita, fade no topo)
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 140),
                child: IgnorePointer(
                  child: RealCommentsTicker(
                    roomId: item.id,
                    isActive: isActive,
                    maxLines: 3,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // 2. Caption
              if (item.caption.isNotEmpty) ...[
                Text(
                  item.caption,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 1.25,
                    shadows: [
                      Shadow(color: Colors.black87, blurRadius: 8),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
              ],

              // 3. Identidade compacta: avatar + nome + AO VIVO + viewers
              _StreamerHeader(
                item: item,
                onProfile: () => _openProfile(context),
              ),
              const SizedBox(height: 12),

              // 4. CTA "Assistir ao Vivo" — alinhado à esquerda, não centralizado
              Align(
                alignment: Alignment.centerLeft,
                child: WatchLiveButton(onTap: () => _enter(context)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Linha condensada com identidade do streamer + AO VIVO + viewers numa
/// só altura, para não empilhar verticalmente e roubar espaço.
class _StreamerHeader extends StatelessWidget {
  const _StreamerHeader({required this.item, required this.onProfile});
  final LiveChatItem item;
  final VoidCallback onProfile;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Avatar + nome/@username (clicável → perfil)
        Flexible(
          child: StreamerIdentity(
            userId: item.author.id,
            name: item.author.name,
            username: item.author.username,
            avatarUrl: item.author.avatarUrl,
            isVerified: item.author.isVerified,
            onTap: onProfile,
          ),
        ),
        const SizedBox(width: 8),
        // AO VIVO + viewers num único cluster compacto à direita
        const LiveDotPulse(),
        const SizedBox(width: 6),
        ViewerCountChip(count: item.viewerCount),
      ],
    );
  }
}
