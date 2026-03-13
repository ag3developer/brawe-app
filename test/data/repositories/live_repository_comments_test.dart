import 'package:brawe_app/data/repositories/live_repository.dart';
import 'package:brawe_app/data/services/live_service.dart';
import 'package:brawe_app/data/services/socket_service.dart';
import 'package:brawe_app/data/services/storage_service.dart';
import 'package:brawe_app/domain/models/failure.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LiveRepository comments', () {
    test('maps new_message payload into live comment stream', () async {
      final socketService = _FakeSocketService();
      final repository = LiveRepository(_FakeLiveService(), socketService);

      final commentFuture = repository.watchComments('room-1').first;

      await repository.connectToRoom('room-1');
      socketService.emitIncoming('new_message', {
        'id': 'comment-1',
        'user_id': 'user-99',
        'name': 'Ana',
        'avatar_url': 'https://example.com/avatar.png',
        'message': 'Hello live',
        'timestamp': '2026-03-12T12:00:00Z',
      });

      final comment = await commentFuture;

      expect(comment.id, 'comment-1');
      expect(comment.userId, 'user-99');
      expect(comment.userName, 'Ana');
      expect(comment.message, 'Hello live');
      expect(comment.avatarUrl, 'https://example.com/avatar.png');
    });

    test('sends chat_message payload through socket api', () async {
      final socketService = _FakeSocketService();
      final repository = LiveRepository(_FakeLiveService(), socketService);

      await repository.sendComment(roomId: 'room-42', message: 'Hi there');

      expect(socketService.joinedRooms, ['room-42']);
      expect(socketService.lastEmittedEvent, 'chat_message');
      expect(socketService.lastEmittedPayload, {
        'room_id': 'room-42',
        'message': 'Hi there',
      });
    });

    test('rejects empty comment before emitting to socket', () async {
      final socketService = _FakeSocketService();
      final repository = LiveRepository(_FakeLiveService(), socketService);

      expect(
        () => repository.sendComment(roomId: 'room-42', message: '   '),
        throwsA(isA<ValidationFailure>()),
      );
      expect(socketService.lastEmittedEvent, isNull);
    });
  });
}

class _FakeLiveService extends LiveService {
  _FakeLiveService() : super(Dio());
}

class _FakeSocketService extends SocketService {
  _FakeSocketService() : super(StorageService(const FlutterSecureStorage()));

  final Map<String, List<Function(dynamic)>> _handlers = {};
  final List<String> joinedRooms = [];
  String? lastEmittedEvent;
  dynamic lastEmittedPayload;
  bool _connected = false;

  @override
  Future<void> connect() async {
    _connected = true;
  }

  @override
  bool get isConnected => _connected;

  @override
  void joinRoom(String roomId) {
    joinedRooms.add(roomId);
  }

  @override
  void on(String event, Function(dynamic) handler) {
    _handlers.putIfAbsent(event, () => []).add(handler);
  }

  @override
  void emit(String event, dynamic data) {
    lastEmittedEvent = event;
    lastEmittedPayload = data;
  }

  void emitIncoming(String event, dynamic data) {
    for (final handler in _handlers[event] ?? const []) {
      handler(data);
    }
  }
}
