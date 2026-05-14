import 'package:flutter/material.dart';
import '../../../../domain/models/feed_item.dart';
import '../../../core/themes/app_colors.dart';
import '../action_rail.dart';
import 'shared/_caption_block.dart';

/// 🎥 View para VideoFeedItem.
class VideoView extends StatelessWidget {
  const VideoView({super.key, required this.item});
  final VideoFeedItem item;

  String get _durationText {
    final m = item.duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = item.duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(
          item.thumbnailUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(color: AppColors.slate),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withValues(alpha: 0.65),
              ],
              stops: const [0.5, 1.0],
            ),
          ),
        ),
        // Play icon centered
        Center(
          child: Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.45),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.play_arrow,
                color: Colors.white, size: 44),
          ),
        ),
        Positioned(
          top: 60,
          right: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.play_circle_outline,
                    color: Colors.white, size: 14),
                const SizedBox(width: 4),
                Text(_durationText,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
        Positioned(
          right: 8,
          bottom: 140,
          child: ActionRail(
            item: item,
            onLike: () {},
            onComment: () {},
            onShare: () {},
            onFollow: () {},
            onGift: () {},
            onProfile: () {},
          ),
        ),
        Positioned(
          left: 16,
          right: 90,
          bottom: 100,
          child: CaptionBlock(author: item.author, caption: item.caption),
        ),
      ],
    );
  }
}
