import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/models/live_gift.dart';
import '../view_models/live_room_gifts_view_model.dart';
import '../../core/themes/app_colors.dart';

class GiftAnimationOverlay extends ConsumerWidget {
  final String roomId;

  const GiftAnimationOverlay({super.key, required this.roomId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeGifts = ref.watch(liveRoomGiftsViewModelProvider(roomId));

    if (activeGifts.isEmpty) return const SizedBox.shrink();

    return Positioned(
      top: 100,
      left: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: activeGifts.map((gift) => _GiftBubble(gift: gift)).toList(),
      ),
    );
  }
}

class _GiftBubble extends StatelessWidget {
  final LiveGift gift;

  const _GiftBubble({required this.gift});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundImage: gift.senderAvatarUrl != null ? NetworkImage(gift.senderAvatarUrl!) : null,
            child: gift.senderAvatarUrl == null ? const Icon(Icons.person, size: 16) : null,
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                gift.senderName,
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
              ),
              Text(
                'Sent ${gift.giftName}',
                style: const TextStyle(color: AppColors.coolCyan, fontSize: 10),
              ),
            ],
          ),
          const SizedBox(width: 8),
          if (gift.giftIconUrl != null)
            Image.network(gift.giftIconUrl!, width: 24, height: 24)
          else
            const Icon(Icons.card_giftcard, color: Colors.white, size: 20),
          const SizedBox(width: 4),
          Text(
            'x${gift.quantity}',
            style: const TextStyle(
              color: AppColors.electricPurple,
              fontSize: 18,
              fontWeight: FontWeight.w900,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}
