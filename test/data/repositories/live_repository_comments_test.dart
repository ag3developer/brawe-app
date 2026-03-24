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
    test('maps live_chat payload into live comment stream', () async {
      final socketService = _FakeSocketService();
      final repository = LiveRepository(_FakeLiveService(), socketService);

      final commentFuture = repository.watchComments('room-1').first;

      await repository.connectToRoom('room-1');
      socketService.emitIncoming('live_chat', {
        'id': 'comment-1',
        'user_id': 'user-99',
        'sender_name': 'Ana',
        'sender_avatar': 'https://example.com/avatar.png',
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

    test(
      'delivers live_chat payload to active listeners when room_id is missing',
      () async {
        final socketService = _FakeSocketService();
        final repository = LiveRepository(_FakeLiveService(), socketService);

        final commentFuture = repository.watchComments('room-active').first;

        await repository.connectToRoom('room-active');
        socketService.emitIncoming('live_chat', {
          'user_id': '581e54ac-3c14-4238-adf5-f3543b3edceb',
          'sender_name': 'Brawe',
          'sender_avatar': 'https://example.com/brawe.webp',
          'message': 'Ola Gui Boi',
          'timestamp': '2026-03-24T00:53:00.264992',
        });

        final comment = await commentFuture;

        expect(comment.userName, 'Brawe');
        expect(comment.message, 'Ola Gui Boi');
        expect(comment.avatarUrl, 'https://example.com/brawe.webp');
      },
    );

    test('sends live_chat_message payload through socket api', () async {
      final socketService = _FakeSocketService();
      final repository = LiveRepository(_FakeLiveService(), socketService);

      await repository.sendComment(roomId: 'room-42', message: 'Hi there');

      expect(socketService.joinedRooms, ['room-42']);
      expect(socketService.lastEmittedEvent, 'live_chat_message');
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

    test(
      'shared room connection stays alive until the last listener disconnects',
      () async {
        final socketService = _FakeSocketService();
        final repository = LiveRepository(_FakeLiveService(), socketService);

        final commentFuture = repository.watchComments('room-1').first;

        await repository.connectToRoom('room-1');
        await repository.connectToRoom('room-1');

        repository.disconnectFromRoom('room-1');
        expect(socketService.leftRooms, isEmpty);

        socketService.emitIncoming('live_chat', {
          'room_id': 'room-1',
          'id': 'comment-2',
          'user_id': 'user-77',
          'sender_name': 'Jo',
          'message': 'Still connected',
          'timestamp': '2026-03-24T02:00:00Z',
        });

        final comment = await commentFuture;
        expect(comment.message, 'Still connected');

        repository.disconnectFromRoom('room-1');
        expect(socketService.leftRooms, ['room-1']);
      },
    );
  });
}

class _FakeLiveService extends LiveService {
  _FakeLiveService() : super(Dio());
}

class _FakeSocketService extends SocketService {
  _FakeSocketService() : super(StorageService(const FlutterSecureStorage()));

  final Map<String, List<Function(dynamic)>> _handlers = {};
  final List<String> joinedRooms = [];
  final List<String> leftRooms = [];
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
  void leaveRoom(String roomId) {
    leftRooms.add(roomId);
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
