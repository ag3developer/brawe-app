import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../domain/models/live_room.dart';
import '../../../data/repositories/live_repository.dart';

part 'live_feed_view_model.g.dart';

enum LiveFeedCategory { forYou, allLives }

@riverpod
class LiveFeedViewModel extends _$LiveFeedViewModel {
  LiveFeedCategory _selectedCategory = LiveFeedCategory.forYou;

  LiveFeedCategory get selectedCategory => _selectedCategory;

  @override
  Future<List<LiveRoom>> build() async {
    return _fetchFeed();
  }

  Future<List<LiveRoom>> _fetchFeed() async {
    final repository = ref.watch(liveRepositoryProvider);

    switch (_selectedCategory) {
      case LiveFeedCategory.forYou:
        return repository.getLiveFeed(limit: 10);
      case LiveFeedCategory.allLives:
        return repository.getRooms(limit: 10);
    }
  }

  Future<void> selectCategory(LiveFeedCategory category) async {
    if (_selectedCategory == category) {
      return;
    }

    _selectedCategory = category;
    await refresh();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchFeed());
  }
}
