import 'package:flutter/material.dart';
import '../../../domain/models/feed_item.dart';
import '../../core/themes/app_colors.dart';
import '../../core/themes/brawe_colors.dart';
import 'package:brawe_app/ui/core/ui/image_decode.dart';

/// Right-side rail with social actions, shared by every For You view.
class ActionRail extends StatelessWidget {
  const ActionRail({
    super.key,
    required this.item,
    required this.onLike,
    required this.onComment,
    required this.onShare,
    required this.onFollow,
    required this.onProfile,
    this.onLikeLongPress,
    this.onLikeCountTap,
    this.onShareLongPress,
  });

  final FeedItem item;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onShare;
  final VoidCallback onFollow;
  final VoidCallback onProfile;
  final VoidCallback? onLikeLongPress;
  final VoidCallback? onLikeCountTap;
  final VoidCallback? onShareLongPress;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Avatar with follow (+)
        _AvatarFollow(
          author: item.author,
          isFollowing: item.userFollowingAuthor,
          onProfile: onProfile,
          onFollow: onFollow,
        ),
        const SizedBox(height: 22),
        _RailButton(
          icon: item.userLiked ? Icons.favorite : Icons.favorite_border,
          label: _format(item.likesCount + (item.userLiked ? 1 : 0)),
          color: item.userLiked ? Colors.red : Colors.white,
          onTap: onLike,
          onLongPress: onLikeLongPress,
          onLabelTap: onLikeCountTap,
        ),
        const SizedBox(height: 18),
        _RailButton(
          icon: Icons.mode_comment_outlined,
          label: _format(item.commentsCount),
          onTap: onComment,
        ),
        const SizedBox(height: 18),
        // Toque: compartilhar. Toque longo: repostar/desfazer — quando já
        // repostado, o ícone vira "repetir" em verde.
        _RailButton(
          icon: item.userReposted ? Icons.repeat_rounded : Icons.send_rounded,
          color: item.userReposted ? AppColors.success : Colors.white,
          label: _format(item.sharesCount),
          onTap: onShare,
          onLongPress: onShareLongPress,
        ),
        if (item.viewsCount > 0) ...[
          const SizedBox(height: 14),
          _ViewsLabel(count: item.viewsCount, formatter: _format),
        ],
        const SizedBox(height: 18),
        // Animated audio disc (signature)
        _SpinningDisc(avatarUrl: item.author.avatarUrl),
      ],
    );
  }

  static String _format(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return '$n';
  }
}

class _AvatarFollow extends StatelessWidget {
  const _AvatarFollow({
    required this.author,
    required this.isFollowing,
    required this.onProfile,
    required this.onFollow,
  });
  final FeedAuthor author;
  final bool isFollowing;
  final VoidCallback onProfile;
  final VoidCallback onFollow;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56,
      height: 64,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          GestureDetector(
            onTap: onProfile,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: ClipOval(
                child: author.avatarUrl != null
                    ? Image.network(cacheWidth: context.decodePx(50), author.avatarUrl!, fit: BoxFit.cover)
                    : Container(
                        color: context.colors.surfaceElevated,
                        child: Center(
                          child: Text(
                            author.name[0].toUpperCase(),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
              ),
            ),
          ),
          if (!isFollowing)
            Positioned(
              bottom: 0,
              child: GestureDetector(
                onTap: onFollow,
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: const BoxDecoration(
                    color: AppColors.braweBlue,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 14),
                ),
              ),
            )
          else
            Positioned(
              bottom: 0,
              child: Container(
                width: 22,
                height: 22,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 14),
              ),
            ),
        ],
      ),
    );
  }
}

class _RailButton extends StatelessWidget {
  const _RailButton({
    required this.icon,
    required this.label,
    this.color = Colors.white,
    required this.onTap,
    this.onLongPress,
    this.onLabelTap,
  });
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onLabelTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          onLongPress: onLongPress,
          behavior: HitTestBehavior.opaque,
          child: Icon(
            icon,
            color: color,
            size: 32,
            shadows: const [Shadow(color: Colors.black54, blurRadius: 6)],
          ),
        ),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: onLabelTap ?? onTap,
          behavior: HitTestBehavior.opaque,
          child: Text(
            label,
            style: TextStyle(
              color: context.colors.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
            ),
          ),
        ),
      ],
    );
  }
}

class _ViewsLabel extends StatelessWidget {
  const _ViewsLabel({required this.count, required this.formatter});
  final int count;
  final String Function(int) formatter;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.bar_chart_rounded,
          color: Colors.white70,
          size: 18,
          shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
        ),
        const SizedBox(height: 2),
        Text(
          formatter(count),
          style: TextStyle(
            color: context.colors.textSecondary,
            fontSize: 10,
            fontWeight: FontWeight.w500,
            shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
          ),
        ),
      ],
    );
  }
}

class _SpinningDisc extends StatefulWidget {
  const _SpinningDisc({this.avatarUrl});
  final String? avatarUrl;

  @override
  State<_SpinningDisc> createState() => _SpinningDiscState();
}

class _SpinningDiscState extends State<_SpinningDisc>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _ctrl,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white24, width: 5),
          color: Colors.black,
        ),
        child: ClipOval(
          child: widget.avatarUrl != null
              ? Image.network(cacheWidth: context.decodePx(36), widget.avatarUrl!, fit: BoxFit.cover)
              : Container(color: context.colors.surfaceElevated),
        ),
      ),
    );
  }
}
