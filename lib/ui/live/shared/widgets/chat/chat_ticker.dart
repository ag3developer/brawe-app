import 'package:flutter/material.dart';

import '../../../../../domain/models/live_comment.dart';
import '../../../../../domain/models/live_gift.dart';
import 'chat_line.dart';
import 'gift_chat_line.dart';
import 'ticker_item.dart';

/// Ticker do chat da live: mescla comentários + presentes em uma única
/// timeline ordenada por timestamp e mostra as últimas 6 entradas, com
/// fade-out no topo via `ShaderMask`.
class ChatTicker extends StatelessWidget {
  const ChatTicker({
    super.key,
    required this.comments,
    required this.gifts,
  });
  final List<LiveComment> comments;
  final List<LiveGift> gifts;

  @override
  Widget build(BuildContext context) {
    final items = <TickerItem>[
      for (final c in comments)
        TickerItem(timestamp: c.timestamp, comment: c),
      for (final g in gifts) TickerItem(timestamp: g.timestamp, gift: g),
    ]..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    if (items.isEmpty) return const SizedBox.shrink();
    final visible = items.length > 6
        ? items.sublist(items.length - 6)
        : items;

    return ShaderMask(
      shaderCallback: (rect) => const LinearGradient(
        colors: [Colors.transparent, Colors.black, Colors.black],
        stops: [0, 0.25, 1],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(rect),
      blendMode: BlendMode.dstIn,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final it in visible)
            if (it.comment != null)
              ChatLine(comment: it.comment!)
            else if (it.gift != null)
              GiftChatLine(gift: it.gift!),
        ],
      ),
    );
  }
}
