import 'package:flutter/material.dart';
import '../../../../domain/models/feed_item.dart';
import '../../../../domain/models/live_room.dart';
import '../../../../gen/l10n/app_localizations.dart';
import '../../../core/themes/app_colors.dart';
import 'shared/_live_overlay.dart';
import 'shared/_live_peek.dart';
import 'package:brawe_app/ui/core/ui/image_decode.dart';

/// ⚔️ Preview de LiveBattle — split HORIZONTAL, tap para entrar na live.
/// Só exibe: thumbnails lado a lado, placar VS, timer, tags dos streamers
/// e o botão de presente misterioso. Sem likes/comentários/share.
class LiveBattleView extends StatelessWidget {
  const LiveBattleView({super.key, required this.item});
  final LiveBattleItem item;

  @override
  Widget build(BuildContext context) {
    final battle = item.battleState;

    return GestureDetector(
      // Tap em qualquer lugar entra na live — passa LiveRoom com os dados do
      // feed para navegação instantânea (sem request HTTP, igual TikTok).
      onTap: () {
        final room = LiveRoom(
          id: item.id,
          slug: item.id,
          title: item.caption,
          liveType: 'battle',
          isPrivate: false,
          status: 'live',
          viewerCount: item.viewerCount,
          totalLikes: item.likesCount,
          thumbnailUrl: item.thumbnailUrlA,
          streamerId: item.author.id,
          streamerName: item.author.name,
          streamerAvatarUrl: item.author.avatarUrl,
          streamerUsername: item.author.username,
          streamerVerified: item.author.isVerified,
        );
        openLiveRoom(context, item.id, room);
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          // ── Thumbnails lado a lado ──────────────────────────────────
          Row(
            children: [
              Expanded(
                child: _HalfPreview(
                  imageUrl: item.thumbnailUrlA,
                  isLeading: battle.isLeadingA,
                  side: _Side.left,
                ),
              ),
              // Divisória central de 2px
              Container(width: 2, color: Colors.black),
              Expanded(
                child: _HalfPreview(
                  imageUrl: item.thumbnailUrlB,
                  isLeading: battle.isLeadingB,
                  side: _Side.right,
                ),
              ),
            ],
          ),

          // ── Overlay escuro no rodapé para legibilidade ──────────────
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 200,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black87],
                ),
              ),
            ),
          ),

          // ── LIVE badge + viewers (top-left) ─────────────────────────
          Positioned(
            top: 52,
            left: 16,
            child: LiveBadge(
              viewerCount: item.viewerCount,
              label: S.of(context).liveBadgeBattle,
            ),
          ),

          // ── Timer (top-right) ────────────────────────────────────────
          Positioned(
            top: 52,
            right: 16,
            child: _TimerPill(remaining: battle.timeRemaining),
          ),

          // ── Placar + VS + barra de progresso (centro) ───────────────
          Positioned(
            left: 0,
            right: 0,
            bottom: 130,
            child: _BattleBar(item: item),
          ),

          // ── Tag streamer A (bottom-left) ─────────────────────────────
          Positioned(
            bottom: 72,
            left: 12,
            child: _StreamerTag(author: item.author, side: 'A'),
          ),

          // ── Tag streamer B (bottom-right) ────────────────────────────
          Positioned(
            bottom: 72,
            right: 12,
            child: _StreamerTag(author: item.opponent, side: 'B'),
          ),

          // ── "Toque para assistir" hint ───────────────────────────────
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  S.of(context).liveBattleTapToWatch,
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Enum interno ────────────────────────────────────────────────────────────
enum _Side { left, right }

// ── Metade da tela ──────────────────────────────────────────────────────────
class _HalfPreview extends StatelessWidget {
  const _HalfPreview({
    required this.imageUrl,
    required this.isLeading,
    required this.side,
  });
  final String imageUrl;
  final bool isLeading;
  final _Side side;

  @override
  Widget build(BuildContext context) {
    final glowColor = side == _Side.left
        ? AppColors.braweBlue
        : AppColors.braweSky;

    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(
          cacheWidth: context.decodeScreenPx,
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => Container(
            color: AppColors.slate,
            child: const Icon(
              Icons.videocam_off,
              color: AppColors.coolGray,
              size: 40,
            ),
          ),
        ),
        // Gradiente lateral suave
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: side == _Side.left
                  ? Alignment.centerLeft
                  : Alignment.centerRight,
              end: side == _Side.left
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
              colors: [
                Colors.black.withValues(alpha: 0.18),
                Colors.transparent,
              ],
            ),
          ),
        ),
        // Borda de glow no líder
        if (isLeading)
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: glowColor, width: 2),
                  bottom: BorderSide(color: glowColor, width: 2),
                  left: side == _Side.left
                      ? BorderSide(color: glowColor, width: 2)
                      : BorderSide.none,
                  right: side == _Side.right
                      ? BorderSide(color: glowColor, width: 2)
                      : BorderSide.none,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ── Placar + VS + barra ─────────────────────────────────────────────────────
class _BattleBar extends StatelessWidget {
  const _BattleBar({required this.item});
  final LiveBattleItem item;

  @override
  Widget build(BuildContext context) {
    final b = item.battleState;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              // Score A
              Expanded(
                child: Text(
                  '${b.scoreA}',
                  textAlign: TextAlign.left,
                  style: const TextStyle(
                    color: AppColors.braweBlue,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    shadows: [Shadow(color: Colors.black87, blurRadius: 8)],
                  ),
                ),
              ),
              // VS pill
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.braweBlue, AppColors.mutedRed],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.braweBlue.withValues(alpha: 0.55),
                      blurRadius: 14,
                    ),
                  ],
                ),
                child: const Text(
                  'VS',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    letterSpacing: 2,
                  ),
                ),
              ),
              // Score B
              Expanded(
                child: Text(
                  '${b.scoreB}',
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    color: AppColors.braweSky,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    shadows: [Shadow(color: Colors.black87, blurRadius: 8)],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Barra de progresso
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 6,
              child: Row(
                children: [
                  Expanded(
                    flex: (b.progressA * 1000).round(),
                    child: Container(color: AppColors.braweBlue),
                  ),
                  Expanded(
                    flex: (b.progressB * 1000).round(),
                    child: Container(color: AppColors.braweSky),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Timer ───────────────────────────────────────────────────────────────────
class _TimerPill extends StatelessWidget {
  const _TimerPill({required this.remaining});
  final Duration remaining;

  @override
  Widget build(BuildContext context) {
    final m = remaining.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = remaining.inSeconds.remainder(60).toString().padLeft(2, '0');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.timer_outlined, color: Colors.amber, size: 14),
          const SizedBox(width: 4),
          Text(
            '$m:$s',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Tag do streamer ──────────────────────────────────────────────────────────
class _StreamerTag extends StatelessWidget {
  const _StreamerTag({required this.author, required this.side});
  final FeedAuthor author;
  final String side;

  @override
  Widget build(BuildContext context) {
    final color = side == 'A' ? AppColors.braweBlue : AppColors.braweSky;
    return Container(
      padding: const EdgeInsets.fromLTRB(4, 4, 10, 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Avatar ou inicial
          CircleAvatar(
            radius: 13,
            backgroundColor: color.withValues(alpha: 0.3),
            backgroundImage: author.avatarUrl != null
                ? ResizeImage(NetworkImage(author.avatarUrl!), width: context.decodePx(26))
                : null,
            child: author.avatarUrl == null
                ? Text(
                    author.name[0].toUpperCase(),
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 6),
          Text(
            author.name,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
