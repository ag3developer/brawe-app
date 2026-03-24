import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/models/live_gift.dart';
import '../../core/themes/app_colors.dart';
import '../view_models/live_room_gifts_view_model.dart';

class GiftAnimationOverlay extends ConsumerWidget {
  final String roomId;

  const GiftAnimationOverlay({super.key, required this.roomId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeGifts = ref.watch(liveRoomGiftsViewModelProvider(roomId));
    if (activeGifts.isEmpty) {
      return const SizedBox.shrink();
    }

    final visibleGifts = activeGifts.reversed.toList(growable: false);

    return Positioned(
      top: 100,
      left: 16,
      right: 80,
      child: IgnorePointer(
        child: Align(
          alignment: Alignment.topLeft,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 320, maxWidth: 280),
            child: ListView.separated(
              key: const ValueKey('gift-toast-list'),
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              physics: const BouncingScrollPhysics(),
              itemCount: visibleGifts.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final gift = visibleGifts[index];
                return _GiftToast(
                  key: ValueKey('gift-toast-${gift.id}'),
                  gift: gift,
                  isHighlighted: index == 0,
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _GiftToast extends StatelessWidget {
  final LiveGift gift;
  final bool isHighlighted;

  const _GiftToast({
    super.key,
    required this.gift,
    required this.isHighlighted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 280),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          colors: isHighlighted
              ? const [Color(0xD91B2B6B), Color(0xD92E1248)]
              : const [Color(0xB31B2B6B), Color(0xB32E1248)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        border: Border.all(
          color: isHighlighted ? AppColors.coolCyan : Colors.white24,
        ),
        boxShadow: [
          BoxShadow(
            color: isHighlighted
                ? const Color(0x663BB8FF)
                : const Color(0x33000000),
            blurRadius: isHighlighted ? 20 : 12,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.coolCyan.withValues(alpha: 0.65),
              ),
            ),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.nearBlack,
              backgroundImage: gift.senderAvatarUrl != null
                  ? NetworkImage(gift.senderAvatarUrl!)
                  : null,
              child: gift.senderAvatarUrl == null
                  ? const Icon(Icons.person, size: 18, color: Colors.white70)
                  : null,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  gift.senderName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isHighlighted ? 13 : 12,
                    fontWeight: isHighlighted
                        ? FontWeight.w800
                        : FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: isHighlighted ? 12 : 11,
                      fontWeight: FontWeight.w500,
                    ),
                    children: [
                      const TextSpan(text: 'sent '),
                      TextSpan(
                        text: gift.giftName,
                        style: const TextStyle(
                          color: AppColors.coolCyan,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (gift.quantity > 1)
                        TextSpan(
                          text: ' x${gift.quantity}',
                          style: const TextStyle(
                            color: AppColors.electricPurple,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(12),
            ),
            clipBehavior: Clip.antiAlias,
            child: gift.giftIconUrl != null
                ? Image.network(gift.giftIconUrl!, fit: BoxFit.cover)
                : const Icon(
                    Icons.card_giftcard,
                    color: Colors.white,
                    size: 22,
                  ),
          ),
        ],
      ),
    );
  }
}
