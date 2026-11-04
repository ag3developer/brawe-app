import 'package:flutter/material.dart';
import '../../../../../domain/models/feed_item.dart';
import 'package:brawe_app/ui/core/ui/verified_badge.dart';

/// Caption bottom-left: nome + texto.
class CaptionBlock extends StatelessWidget {
  const CaptionBlock({super.key, required this.author, required this.caption});
  final FeedAuthor author;
  final String caption;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Text(
              '@${author.username}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
                shadows: [Shadow(color: Colors.black54, blurRadius: 6)],
              ),
            ),
            if (author.isVerified) const VerifiedBadge(size: 16, gap: 4),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          caption,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            shadows: [Shadow(color: Colors.black54, blurRadius: 6)],
          ),
        ),
      ],
    );
  }
}
