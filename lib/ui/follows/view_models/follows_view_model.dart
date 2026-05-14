import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/repositories/social_repository.dart';
import '../../../domain/models/follow_user.dart';

part 'follows_view_model.g.dart';

enum FollowsTab { followers, following }

class FollowsState {
  final List<FollowUser> items;
  final int total;
  final int page;
  final bool isLoadingMore;
  final bool hasMore;

  const FollowsState({
    this.items = const [],
    this.total = 0,
    this.page = 1,
    this.isLoadingMore = false,
    this.hasMore = true,
  });

  FollowsState copyWith({
    List<FollowUser>? items,
    int? total,
    int? page,
    bool? isLoadingMore,
    bool? hasMore,
  }) {
    return FollowsState(
      items: items ?? this.items,
      total: total ?? this.total,
      page: page ?? this.page,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

@riverpod
class FollowsViewModel extends _$FollowsViewModel {
  static const int _pageSize = 30;

  @override
  Future<FollowsState> build(String userId, FollowsTab tab) async {
    return _fetch(page: 1);
  }

  Future<FollowsState> _fetch({required int page}) async {
    final repo = ref.read(socialRepositoryProvider);
    final res = tab == FollowsTab.followers
        ? await repo.getUserFollowers(userId, page: page, limit: _pageSize)
        : await repo.getUserFollowing(userId, page: page, limit: _pageSize);

    return FollowsState(
      items: res.items,
      total: res.total,
      page: page,
      isLoadingMore: false,
      hasMore: res.items.length >= _pageSize,
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetch(page: 1));
  }

  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || current.isLoadingMore || !current.hasMore) return;

    state = AsyncValue.data(current.copyWith(isLoadingMore: true));
    try {
      final nextPage = current.page + 1;
      final repo = ref.read(socialRepositoryProvider);
      final res = tab == FollowsTab.followers
          ? await repo.getUserFollowers(userId, page: nextPage, limit: _pageSize)
          : await repo.getUserFollowing(userId, page: nextPage, limit: _pageSize);

      state = AsyncValue.data(
        current.copyWith(
          items: [...current.items, ...res.items],
          page: nextPage,
          total: res.total,
          isLoadingMore: false,
          hasMore: res.items.length >= _pageSize,
        ),
      );
    } catch (_) {
      state = AsyncValue.data(current.copyWith(isLoadingMore: false));
    }
  }

  Future<void> toggleFollow(String targetUserId) async {
    final current = state.value;
    if (current == null) return;

    final idx = current.items.indexWhere((u) => u.userId == targetUserId);
    if (idx == -1) return;

    final user = current.items[idx];
    final next = user.copyWith(isFollowing: !user.isFollowing);
    final updated = [...current.items]..[idx] = next;
    state = AsyncValue.data(current.copyWith(items: updated));

    try {
      final repo = ref.read(socialRepositoryProvider);
      if (user.isFollowing) {
        await repo.unfollowUser(targetUserId);
      } else {
        await repo.followUser(targetUserId);
      }
    } catch (_) {
      final rollback = [...state.value!.items]..[idx] = user;
      state = AsyncValue.data(state.value!.copyWith(items: rollback));
    }
  }
}
