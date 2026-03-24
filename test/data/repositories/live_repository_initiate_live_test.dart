import 'package:brawe_app/data/model/create_live_room_request_dto.dart';
import 'package:brawe_app/data/repositories/live_repository.dart';
import 'package:brawe_app/data/services/live_service.dart';
import 'package:brawe_app/domain/models/failure.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LiveRepository initiateLive', () {
    test('creates live room from nested room payload', () async {
      final repository = LiveRepository(_SuccessLiveService());

      final room = await repository.initiateLive(
        const CreateLiveRoomRequestDto(
          title: 'Night Chill Session',
          category: 'Music',
        ),
      );

      expect(room.id, 'room-123');
      expect(room.title, 'Night Chill Session');
      expect(room.status, 'scheduled');
      expect(room.streamUrl, 'https://cdn.example.com/live/room-123.m3u8');
      expect(room.rtmpUrl, 'rtmp://global-live.mux.com:5222/app');
      expect(room.streamKey, 'sk_live_room_123');
    });

    test('uses fallback id when API returns room_id only', () async {
      final repository = LiveRepository(_FallbackIdLiveService());

      final room = await repository.initiateLive(
        const CreateLiveRoomRequestDto(title: 'Q&A'),
      );

      expect(room.id, 'room-fallback');
      expect(room.title, 'Q&A');
      expect(room.status, 'scheduled');
      expect(room.streamUrl, 'https://cdn.example.com/fallback.m3u8');
      expect(room.rtmpUrl, 'rtmp://global-live.mux.com:5222/app');
      expect(room.streamKey, 'sk_live_fallback');
    });

    test(
      'merges top-level stream credentials into nested room payload',
      () async {
        final repository = LiveRepository(_SplitCredentialsLiveService());

        final room = await repository.initiateLive(
          const CreateLiveRoomRequestDto(title: 'Split payload live'),
        );

        expect(room.id, 'room-split');
        expect(room.title, 'Split payload live');
        expect(room.status, 'scheduled');
        expect(room.rtmpUrl, 'rtmp://global-live.mux.com:5222/app');
        expect(room.streamKey, 'sk_live_split');
        expect(room.streamUrl, 'https://cdn.example.com/live/split.m3u8');
      },
    );

    test('maps 422 response to validation failure', () async {
      final repository = LiveRepository(_ValidationErrorLiveService());

      await expectLater(
        () => repository.initiateLive(
          const CreateLiveRoomRequestDto(title: 'ab'),
        ),
        throwsA(isA<ValidationFailure>()),
      );
    });

    test('maps create request timeout to network failure', () async {
      final repository = LiveRepository(_TimeoutLiveService());

      await expectLater(
        () => repository.initiateLive(
          const CreateLiveRoomRequestDto(title: 'Long request'),
        ),
        throwsA(isA<NetworkFailure>()),
      );
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
      'room': {
        'id': 'room-123',
        'title': request.title,
        'status': 'scheduled',
        'live_type': 'solo',
        'is_private': false,
        'streamer_name': 'Streamer',
        'stream_config': {
          'rtmp_url': 'rtmp://global-live.mux.com:5222/app',
          'stream_key': 'sk_live_room_123',
          'playback_url': 'https://cdn.example.com/live/room-123.m3u8',
        },
      },
    };
  }
}

class _FallbackIdLiveService extends LiveService {
  _FallbackIdLiveService() : super(Dio());

  @override
  Future<Map<String, dynamic>> createLiveRoom(
    CreateLiveRoomRequestDto request,
  ) async {
    return {
      'room_id': 'room-fallback',
      'status': 'scheduled',
      'stream_config': {
        'rtmp_url': 'rtmp://global-live.mux.com:5222/app',
        'stream_key': 'sk_live_fallback',
        'playback_url': 'https://cdn.example.com/fallback.m3u8',
      },
    };
  }
}

class _ValidationErrorLiveService extends LiveService {
  _ValidationErrorLiveService() : super(Dio());

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

class _SplitCredentialsLiveService extends LiveService {
  _SplitCredentialsLiveService() : super(Dio());

  @override
  Future<Map<String, dynamic>> createLiveRoom(
    CreateLiveRoomRequestDto request,
  ) async {
    return {
      'room': {'id': 'room-split', 'title': request.title},
      'status': 'scheduled',
      'rtmp_url': 'rtmp://global-live.mux.com:5222/app',
      'stream_key': 'sk_live_split',
      'playback_url': 'https://cdn.example.com/live/split.m3u8',
    };
  }
}

class _TimeoutLiveService extends LiveService {
  _TimeoutLiveService() : super(Dio());

  @override
  Future<Map<String, dynamic>> createLiveRoom(
    CreateLiveRoomRequestDto request,
  ) async {
    await Future<void>.delayed(const Duration(seconds: 21));
    return {'id': 'late-room', 'title': request.title, 'status': 'scheduled'};
  }
}
