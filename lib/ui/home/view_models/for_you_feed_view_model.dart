import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/repositories/for_you_feed_repository.dart';
import '../../../domain/models/feed_item.dart';

part 'for_you_feed_view_model.g.dart';

@riverpod
class ForYouFeedViewModel extends _$ForYouFeedViewModel {
  @override
  FutureOr<List<FeedItem>> build() async {
    return ref.watch(forYouFeedRepositoryProvider).getFeed();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(forYouFeedRepositoryProvider).getFeed(),
    );
  }
}

@riverpod
class FollowingForYouFeedViewModel extends _$FollowingForYouFeedViewModel {
  @override
  FutureOr<List<FeedItem>> build() async {
    return ref.watch(forYouFeedRepositoryProvider).getFollowingFeed();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(forYouFeedRepositoryProvider).getFollowingFeed(),
    );
  }
}
