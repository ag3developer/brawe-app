import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../data/repositories/social_repository.dart';
import '../../../data/services/privacy_ux_service.dart';

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
      final isFollowing = await ref
          .read(socialRepositoryProvider)
          .isFollowing(userId);
      state = AsyncValue.data(isFollowing);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// [sourceRoomId]: id da live onde o follow aconteceu (só ao seguir).
  Future<void> toggleFollow({String? sourceRoomId}) async {
    final isCurrentlyFollowing = state.value ?? false;
    final requestedProvider = followRequestedProvider(userId);

    // Optimistic UI update
    state = AsyncValue.data(!isCurrentlyFollowing);

    try {
      if (isCurrentlyFollowing) {
        await ref.read(socialRepositoryProvider).unfollowUser(userId);
      } else {
        final status = await ref
            .read(socialRepositoryProvider)
            .followUser(userId, sourceRoomId: sourceRoomId);
        if (status == 'requested') {
          // Conta privada: vira "Solicitado", ainda não segue.
          state = const AsyncValue.data(false);
          ref.read(requestedProvider.notifier).set(true);
        }
      }
    } catch (e) {
      // Revert on error
      state = AsyncValue.data(isCurrentlyFollowing);
      // Optional: communicate error to UI via another mechanism if needed
    }
  }
}
