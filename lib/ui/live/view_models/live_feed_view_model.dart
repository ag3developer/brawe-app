import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../domain/models/live_room.dart';
import '../../../data/repositories/live_repository.dart';

part 'live_feed_view_model.g.dart';

@riverpod
class LiveFeedViewModel extends _$LiveFeedViewModel {
  @override
  Future<List<LiveRoom>> build() async {
    return _fetchFeed();
  }

  Future<List<LiveRoom>> _fetchFeed() async {
    final repository = ref.watch(liveRepositoryProvider);
    return repository.getLiveFeed(limit: 10);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchFeed());
  }
}
