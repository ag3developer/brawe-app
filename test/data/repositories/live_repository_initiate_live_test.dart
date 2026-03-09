import 'package:brawe_app/data/model/create_live_room_request_dto.dart';
import 'package:brawe_app/data/repositories/live_repository.dart';
import 'package:brawe_app/data/services/live_service.dart';
import 'package:brawe_app/domain/models/failure.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LiveRepository initiateLive', () {
    test('creates and starts live room from nested room payload', () async {
      final repository = LiveRepository(_SuccessLiveService());

      final room = await repository.initiateLive(
        const CreateLiveRoomRequestDto(
          title: 'Night Chill Session',
          category: 'Music',
        ),
      );

      expect(room.id, 'room-123');
      expect(room.title, 'Night Chill Session');
      expect(room.status, 'live');
      expect(room.streamUrl, 'https://cdn.example.com/live/room-123.m3u8');
    });

    test('uses fallback id when API returns room_id only', () async {
      final repository = LiveRepository(_FallbackIdLiveService());

      final room = await repository.initiateLive(
        const CreateLiveRoomRequestDto(title: 'Q&A'),
      );

      expect(room.id, 'room-fallback');
      expect(room.title, 'Q&A');
      expect(room.status, 'live');
      expect(room.streamUrl, 'https://cdn.example.com/fallback.m3u8');
    });

    test('maps 422 response to validation failure', () async {
      final repository = LiveRepository(_ValidationErrorLiveService());

      await expectLater(
        () => repository.initiateLive(
          const CreateLiveRoomRequestDto(title: 'ab'),
        ),
        throwsA(isA<ValidationFailure>()),
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
      },
    };
  }

  @override
  Future<Map<String, dynamic>> startLive(String roomId) async {
    return {
      'live': {
        'id': roomId,
        'title': 'Night Chill Session',
        'status': 'live',
        'stream_url': 'https://cdn.example.com/live/$roomId.m3u8',
        'live_type': 'solo',
        'is_private': false,
        'streamer_name': 'Streamer',
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
    return {'room_id': 'room-fallback', 'status': 'scheduled'};
  }

  @override
  Future<Map<String, dynamic>> startLive(String roomId) async {
    return {
      'status': 'live',
      'playback_url': 'https://cdn.example.com/fallback.m3u8',
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
