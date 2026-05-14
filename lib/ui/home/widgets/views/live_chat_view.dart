import 'package:flutter/material.dart';
import '../../../../domain/models/feed_item.dart';
import '../../../core/themes/app_colors.dart';
import '../action_rail.dart';
import 'shared/_live_overlay.dart';
import 'shared/_caption_block.dart';

/// 💬 View para LiveChatItem — fullscreen + tópico.
class LiveChatView extends StatelessWidget {
  const LiveChatView({super.key, required this.item});
  final LiveChatItem item;

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
        // Bottom gradient
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.35),
                Colors.transparent,
                Colors.black.withValues(alpha: 0.7),
              ],
              stops: const [0.0, 0.4, 1.0],
            ),
          ),
        ),
        Positioned(
          top: 60,
          left: 16,
          child: LiveBadge(viewerCount: item.viewerCount),
        ),
        // Topic chip
        Positioned(
          top: 110,
          left: 16,
          right: 90,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.electricPurple.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.tag, color: Colors.white, size: 14),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      item.topic,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
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
