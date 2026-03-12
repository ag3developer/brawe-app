import 'package:flutter_test/flutter_test.dart';
import 'package:brawe_app/data/model/live_room_dto.dart';
import 'package:brawe_app/data/repositories/live_repository.dart';
import 'package:brawe_app/data/services/live_service.dart';
import 'package:dio/dio.dart';

void main() {
  group('LiveRoomDto to Domain Mapping', () {
    test('should map LiveRoomDto to LiveRoom correctly', () {
      const dto = LiveRoomDto(
        id: '123',
        title: 'Test Stream',
        description: 'Test Description',
        category: 'Gaming',
        liveType: 'solo',
        isPrivate: false,
        status: 'live',
        viewerCount: 150,
        playbackUrl: 'https://example.com/stream.m3u8',
        streamConfig: StreamConfigDto(
          rtmpUrl: 'rtmp://global-live.mux.com:5222/app',
          streamKey: 'sk_live_abc123',
          playbackUrl: 'https://example.com/stream.m3u8',
        ),
        thumbnailUrl: 'https://example.com/thumb.jpg',
        host: HostDto(
          id: 'user1',
          name: 'TestUser',
          avatarUrl: 'https://example.com/avatar.jpg',
        ),
      );

      final domain = dto.toDomain();

      expect(domain.id, '123');
      expect(domain.title, 'Test Stream');
      expect(domain.description, 'Test Description');
      expect(domain.category, 'Gaming');
      expect(domain.liveType, 'solo');
      expect(domain.isPrivate, false);
      expect(domain.status, 'live');
      expect(domain.viewerCount, 150);
      expect(domain.streamUrl, 'https://example.com/stream.m3u8');
      expect(domain.rtmpUrl, 'rtmp://global-live.mux.com:5222/app');
      expect(domain.streamKey, 'sk_live_abc123');
      expect(domain.thumbnailUrl, 'https://example.com/thumb.jpg');
      expect(domain.streamerId, 'user1');
      expect(domain.streamerName, 'TestUser');
      expect(domain.streamerAvatarUrl, 'https://example.com/avatar.jpg');
    });
  });

  group('LiveRepository getRoom', () {
    test('returns hydrated room details', () async {
      final repository = LiveRepository(_GetRoomLiveService());

      final room = await repository.getRoom('room-123');

      expect(room, isNotNull);
      expect(room?.id, 'room-123');
      expect(room?.rtmpUrl, 'rtmp://global-live.mux.com:5222/app');
      expect(room?.streamKey, 'sk_live_room_123');
      expect(room?.streamUrl, 'https://example.com/stream.m3u8');
    });
  });
}

class _GetRoomLiveService extends LiveService {
  _GetRoomLiveService() : super(Dio());

  @override
  Future<LiveRoomDto?> getRoom(String idOrSlug) async {
    return const LiveRoomDto(
      id: 'room-123',
      title: 'Hydrated Stream',
      status: 'waiting',
      playbackUrl: 'https://example.com/stream.m3u8',
      streamConfig: StreamConfigDto(
        rtmpUrl: 'rtmp://global-live.mux.com:5222/app',
        streamKey: 'sk_live_room_123',
      ),
      host: HostDto(id: 'host-1', name: 'Host'),
    );
  }
}
