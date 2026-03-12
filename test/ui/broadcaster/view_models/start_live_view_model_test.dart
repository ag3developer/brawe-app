import 'package:brawe_app/data/model/create_live_room_request_dto.dart';
import 'package:brawe_app/data/repositories/live_repository.dart';
import 'package:brawe_app/data/services/live_service.dart';
import 'package:brawe_app/ui/broadcaster/view_models/start_live_view_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StartLiveViewModel', () {
    test('submit success transitions to data state', () async {
      final container = ProviderContainer(
        overrides: [
          liveRepositoryProvider.overrideWithValue(
            LiveRepository(_SuccessLiveService()),
          ),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(startLiveViewModelProvider.notifier);
      notifier.updateTitle('Stream with me');
      notifier.updateCategory('Talk');

      final success = await notifier.submit();
      final state = container.read(startLiveViewModelProvider);

      expect(success, true);
      expect(state.status.value?.id, 'room-42');
      expect(state.status.value?.status, 'waiting');
      expect(
        state.status.value?.rtmpUrl,
        'rtmp://global-live.mux.com:5222/app',
      );
      expect(state.status.value?.streamKey, 'sk_live_room_42');
    });

    test('submit failure exposes validation message', () async {
      final container = ProviderContainer(
        overrides: [
          liveRepositoryProvider.overrideWithValue(
            LiveRepository(_ValidationLiveService()),
          ),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(startLiveViewModelProvider.notifier);
      notifier.updateTitle('Stream with me');
      notifier.updateCategory('Gaming');

      final success = await notifier.submit();

      final state = container.read(startLiveViewModelProvider);

      expect(success, false);
      expect(state.status.hasError, true);
      expect(state.errorMessage, contains('Please review'));
    });
  });
}

class _SuccessLiveService extends LiveService {
  _SuccessLiveService() : super(Dio());

  @override
  Future<Map<String, dynamic>> createLiveRoom(
    CreateLiveRoomRequestDto request,
  ) async {
    return {
      'id': 'room-42',
      'title': request.title,
      'status': 'waiting',
      'live_type': 'solo',
      'is_private': false,
      'streamer_name': 'You',
      'stream_config': {
        'rtmp_url': 'rtmp://global-live.mux.com:5222/app',
        'stream_key': 'sk_live_room_42',
        'playback_url': 'https://cdn.example.com/live/room-42.m3u8',
      },
    };
  }
}

class _ValidationLiveService extends LiveService {
  _ValidationLiveService() : super(Dio());

  @override
  Future<Map<String, dynamic>> createLiveRoom(
    CreateLiveRoomRequestDto request,
  ) async {
    throw DioException(
      requestOptions: RequestOptions(path: '/live/rooms'),
      response: Response(
        requestOptions: RequestOptions(path: '/live/rooms'),
        statusCode: 422,
      ),
      type: DioExceptionType.badResponse,
    );
  }
}
