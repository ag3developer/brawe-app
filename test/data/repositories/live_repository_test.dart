import 'package:flutter_test/flutter_test.dart';
import 'package:brawe_app/data/model/live_room_dto.dart';
import 'package:brawe_app/domain/models/live_room.dart';

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
        streamUrl: 'https://example.com/stream.m3u8',
        thumbnailUrl: 'https://example.com/thumb.jpg',
        streamerId: 'user1',
        streamerName: 'TestUser',
        streamerAvatarUrl: 'https://example.com/avatar.jpg',
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
      expect(domain.thumbnailUrl, 'https://example.com/thumb.jpg');
      expect(domain.streamerId, 'user1');
      expect(domain.streamerName, 'TestUser');
      expect(domain.streamerAvatarUrl, 'https://example.com/avatar.jpg');
    });
  });
}
