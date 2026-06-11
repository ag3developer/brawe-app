import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/constants/app_constants.dart';
import '../../../domain/models/live_room.dart';
import '../../../data/repositories/live_repository.dart';

part 'live_feed_view_model.g.dart';

enum LiveFeedCategory { forYou, allLives }

@riverpod
class LiveFeedViewModel extends _$LiveFeedViewModel {
  LiveFeedCategory _selectedCategory = LiveFeedCategory.forYou;
  Timer? _refreshTimer;

  LiveFeedCategory get selectedCategory => _selectedCategory;

  @override
  Future<List<LiveRoom>> build() async {
    // Auto-refresh a cada 30s — lives encerradas saem automaticamente
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      refresh();
    });
    ref.onDispose(() => _refreshTimer?.cancel());
    return _fetchFeed();
  }

  Future<List<LiveRoom>> _fetchFeed() async {
    final repository = ref.watch(liveRepositoryProvider);

    final List<LiveRoom> rooms;
    switch (_selectedCategory) {
      case LiveFeedCategory.forYou:
        rooms = await repository.getLiveFeed(limit: AppConstants.feedLimit);
      case LiveFeedCategory.allLives:
        rooms = await repository.getRooms(limit: AppConstants.roomsLimit);
    }
    // Filtra localmente qualquer sala que não esteja 'live' —
    // evita mostrar cache de lives já encerradas.
    return rooms.where((r) => r.status == 'live').toList();
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
