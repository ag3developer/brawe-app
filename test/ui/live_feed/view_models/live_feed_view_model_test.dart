import 'package:brawe_app/data/repositories/live_repository.dart';
import 'package:brawe_app/data/services/live_service.dart';
import 'package:brawe_app/domain/models/live_room.dart';
import 'package:brawe_app/ui/live_feed/view_models/live_feed_view_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LiveFeedViewModel', () {
    test('loads For You feed by default', () async {
      final repository = _FakeLiveRepository();
      final container = ProviderContainer(
        overrides: [liveRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);

      await container.read(liveFeedViewModelProvider.future);

      expect(repository.feedCalls, 1);
      expect(repository.roomsCalls, 0);
    });

    test('switching to all lives loads rooms endpoint', () async {
      final repository = _FakeLiveRepository();
      final container = ProviderContainer(
        overrides: [liveRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);

      await container.read(liveFeedViewModelProvider.future);
      await container
          .read(liveFeedViewModelProvider.notifier)
          .selectCategory(LiveFeedCategory.allLives);

      expect(repository.feedCalls, 1);
      expect(repository.roomsCalls, 1);
    });
  });
}

class _FakeLiveRepository extends LiveRepository {
  _FakeLiveRepository() : super(LiveService(Dio()));

  int feedCalls = 0;
  int roomsCalls = 0;

  @override
  Future<List<LiveRoom>> getLiveFeed({String? cursor, int limit = 10}) async {
    feedCalls++;
    return [
      const LiveRoom(
        id: 'f1',
        title: 'For You Live',
        liveType: 'solo',
        isPrivate: false,
        status: 'live',
        viewerCount: 120,
        streamerId: 'u1',
        streamerName: 'Creator One',
      ),
    ];
  }

  @override
  Future<List<LiveRoom>> getRooms({
    String? status,
    String? category,
    int page = 1,
    int limit = 20,
  }) async {
    roomsCalls++;
    return [
      const LiveRoom(
        id: 'r1',
        title: 'All Lives Room',
        liveType: 'solo',
        isPrivate: false,
        status: 'live',
        viewerCount: 80,
        streamerId: 'u2',
        streamerName: 'Creator Two',
      ),
    ];
  }
}
