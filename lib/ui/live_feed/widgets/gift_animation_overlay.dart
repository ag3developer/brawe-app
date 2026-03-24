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

    final stackHeight = _stackHeight(activeGifts.length);

    return Positioned(
      top: 100,
      left: 16,
      right: 80,
      child: IgnorePointer(
        child: Align(
          alignment: Alignment.topLeft,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 320, maxWidth: 280),
            child: SingleChildScrollView(
              key: const ValueKey('gift-toast-stack-scroll'),
              padding: EdgeInsets.zero,
              physics: const BouncingScrollPhysics(),
              child: SizedBox(
                key: const ValueKey('gift-toast-stack'),
                width: 280,
                height: stackHeight,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    for (var index = 0; index < activeGifts.length; index++)
                      _StackedGiftToast(
                        gift: activeGifts[index],
                        visualIndex: activeGifts.length - 1 - index,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  double _stackHeight(int itemCount) {
    const cardHeight = 74.0;
    const verticalOffset = 18.0;
    if (itemCount <= 1) {
      return cardHeight;
    }

    return cardHeight + ((itemCount - 1) * verticalOffset);
  }
}

class _StackedGiftToast extends StatelessWidget {
  final LiveGift gift;
  final int visualIndex;

  const _StackedGiftToast({required this.gift, required this.visualIndex});

  @override
  Widget build(BuildContext context) {
    final scale = 1 - (visualIndex * 0.06);
    final opacity = 1 - (visualIndex * 0.14);

    return Positioned(
      top: visualIndex * 18,
      left: visualIndex * 6,
      right: 0,
      child: Opacity(
        opacity: opacity.clamp(0.45, 1),
        child: Transform.scale(
          alignment: Alignment.topLeft,
          scale: scale.clamp(0.78, 1),
          child: _GiftToast(key: ValueKey('gift-toast-${gift.id}'), gift: gift),
        ),
      ),
    );
  }
}

class _GiftToast extends StatelessWidget {
  final LiveGift gift;

  const _GiftToast({super.key, required this.gift});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 280),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [Color(0xE61B2B6B), Color(0xE62E1248)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        border: Border.all(color: Colors.white24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x55000000),
            blurRadius: 18,
            offset: Offset(0, 8),
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
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
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
