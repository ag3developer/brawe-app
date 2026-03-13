import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../view_models/follow_view_model.dart';

class FollowButton extends ConsumerWidget {
  final String userId;
  final bool compact;

  const FollowButton({
    super.key,
    required this.userId,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final followState = ref.watch(followViewModelProvider(userId));

    return followState.when(
      data: (isFollowing) {
        if (isFollowing) {
          return const SizedBox.shrink(); // Don't show if already following in the feed context
        }
        
        return GestureDetector(
          onTap: () => ref.read(followViewModelProvider(userId).notifier).toggleFollow(),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 8 : 12,
              vertical: compact ? 4 : 6,
            ),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.white, width: 1),
            ),
            child: Text(
              'FOLLOW',
              style: TextStyle(
                color: Colors.white,
                fontSize: compact ? 10 : 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
      loading: () => const SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
      ),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}
