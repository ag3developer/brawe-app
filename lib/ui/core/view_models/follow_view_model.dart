import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../data/repositories/social_repository.dart';

part 'follow_view_model.g.dart';

@riverpod
class FollowViewModel extends _$FollowViewModel {
  @override
  AsyncValue<bool> build(String userId) {
    _initStatus();
    return const AsyncValue.loading();
  }

  Future<void> _initStatus() async {
    try {
      final isFollowing = await ref.read(socialRepositoryProvider).isFollowing(userId);
      state = AsyncValue.data(isFollowing);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> toggleFollow() async {
    final isCurrentlyFollowing = state.value ?? false;
    
    // Optimistic UI update
    state = AsyncValue.data(!isCurrentlyFollowing);

    try {
      if (isCurrentlyFollowing) {
        await ref.read(socialRepositoryProvider).unfollowUser(userId);
      } else {
        await ref.read(socialRepositoryProvider).followUser(userId);
      }
    } catch (e) {
      // Revert on error
      state = AsyncValue.data(isCurrentlyFollowing);
      // Optional: communicate error to UI via another mechanism if needed
    }
  }
}
