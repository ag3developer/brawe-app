import 'package:flutter/material.dart';
import '../../../../domain/models/feed_item.dart';
import 'shared/_caption_block.dart';
import 'shared/_feed_actions_rail.dart';

/// 📸 View para PhotoPostFeedItem.
/// ⚠️ DEPRECATED — não é mais usado no For You.
/// O For You agora exibe apenas vídeos e lives. Posts de foto/texto
/// são renderizados no `feed_screen.dart` (feed dedicado estilo Instagram).
/// Mantido aqui apenas para satisfazer o switch exaustivo em
/// `for_you_screen.dart` enquanto não removemos `PhotoPostFeedItem` de vez.
class PhotoPostView extends StatelessWidget {
  const PhotoPostView({super.key, required this.item});
  final PhotoPostFeedItem item;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        if (item.imageUrl != null)
          Image.network(
            item.imageUrl!,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => _TextBackground(caption: item.caption),
          )
        else
          _TextBackground(caption: item.caption),

        // Bottom gradient (when has image)
        if (item.imageUrl != null)
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.7),
                ],
                stops: const [0.5, 1.0],
              ),
            ),
          ),

        Positioned(right: 8, bottom: 140, child: FeedActionsRail(item: item)),
        if (item.imageUrl != null)
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

class _TextBackground extends StatelessWidget {
  const _TextBackground({required this.caption});
  final String caption;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0D0D16),
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 80),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.article_outlined, color: Colors.white24, size: 40),
          const SizedBox(height: 20),
          Text(
            caption,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
