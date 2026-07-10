import 'package:flutter/material.dart';
import '../../../../domain/models/feed_item.dart';
import '../../../../domain/models/live_room.dart';
import '../../../../gen/l10n/app_localizations.dart';
import '../../../core/themes/app_colors.dart';
import 'shared/_live_overlay.dart';
import 'shared/_live_peek.dart';

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

          // ── Botão presente misterioso (centro-bottom) ────────────────
          Positioned(
            bottom: 56,
            left: 0,
            right: 0,
            child: Center(child: _GiftButton()),
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
        ? AppColors.electricPurple
        : AppColors.coolCyan;

    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(
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
                    color: AppColors.electricPurple,
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
                    colors: [AppColors.electricPurple, AppColors.mutedRed],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.electricPurple.withValues(alpha: 0.55),
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
                    color: AppColors.coolCyan,
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
                    child: Container(color: AppColors.electricPurple),
                  ),
                  Expanded(
                    flex: (b.progressB * 1000).round(),
                    child: Container(color: AppColors.coolCyan),
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
    final color = side == 'A' ? AppColors.electricPurple : AppColors.coolCyan;
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
                ? NetworkImage(author.avatarUrl!)
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

// ── Botão Presente Misterioso ────────────────────────────────────────────────
class _GiftButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showGiftSheet(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFF9500), Color(0xFFFF5A6B)],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF9500).withValues(alpha: 0.5),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.card_giftcard_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              S.of(context).liveBattleMysteryGift,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showGiftSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const _GiftSheet(),
    );
  }
}

// ── Sheet de presente ────────────────────────────────────────────────────────
class _GiftSheet extends StatefulWidget {
  const _GiftSheet();

  @override
  State<_GiftSheet> createState() => _GiftSheetState();
}

class _GiftSheetState extends State<_GiftSheet> {
  bool _anonymous = false;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.slate,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Ícone
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF9500), Color(0xFFFF5A6B)],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF9500).withValues(alpha: 0.4),
                  blurRadius: 16,
                ),
              ],
            ),
            child: const Icon(
              Icons.card_giftcard_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            s.giftMysteryTitle,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            s.giftMysterySubtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.coolGray,
              fontSize: 13,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          // Toggle anônimo
          Container(
            decoration: BoxDecoration(
              color: AppColors.nearBlack,
              borderRadius: BorderRadius.circular(12),
            ),
            child: SwitchListTile(
              value: _anonymous,
              onChanged: (v) => setState(() => _anonymous = v),
              activeThumbColor: AppColors.electricPurple,
              activeTrackColor: AppColors.electricPurple.withValues(alpha: 0.4),
              title: Text(
                s.giftSendAnonymous,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
              subtitle: Text(
                _anonymous ? s.giftAnonNameHidden : s.giftAnonNameVisible,
                style: const TextStyle(color: AppColors.coolGray, fontSize: 12),
              ),
              secondary: Icon(
                _anonymous ? Icons.visibility_off : Icons.visibility,
                color: AppColors.coolGray,
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Botão enviar
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF9500),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.send_rounded, color: Colors.white),
              label: Text(
                _anonymous ? s.giftSendButtonAnon : s.giftSendButton,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(_anonymous ? s.giftSentAnon : s.giftSent),
                    backgroundColor: const Color(0xFFFF9500),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
