import 'package:brawe_app/data/repositories/live_repository.dart';
import 'package:brawe_app/data/services/live_service.dart';
import 'package:brawe_app/data/services/socket_service.dart';
import 'package:brawe_app/data/services/storage_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LiveRepository viewer count', () {
    test('updates viewer count from viewer_count_update event', () async {
      final socketService = _FakeSocketService();
      final repository = LiveRepository(_FakeLiveService(), socketService);

      final countFuture = repository.watchViewerCount('room-1').first;

      await repository.connectToRoom('room-1');
      socketService.emitIncoming('viewer_count_update', {
        'room_id': 'room-1',
        'count': 150,
      });

      final count = await countFuture;
      expect(count, 150);
    });

    test('updates viewer count from viewer_joined event', () async {
      final socketService = _FakeSocketService();
      final repository = LiveRepository(_FakeLiveService(), socketService);

      final countFuture = repository.watchViewerCount('room-1').first;

      await repository.connectToRoom('room-1');
      socketService.emitIncoming('viewer_joined', {
        'room_id': 'room-1',
        'viewer_count': 88,
      });

      final count = await countFuture;
      expect(count, 88);
    });

    test('updates viewer count from viewer_left event', () async {
      final socketService = _FakeSocketService();
      final repository = LiveRepository(_FakeLiveService(), socketService);

      final countFuture = repository.watchViewerCount('room-1').first;

      await repository.connectToRoom('room-1');
      socketService.emitIncoming('viewer_left', {
        'room_id': 'room-1',
        'viewer_count': 87,
      });

      final count = await countFuture;
      expect(count, 87);
    });

    test('manual updateViewerCount triggers stream', () async {
      final socketService = _FakeSocketService();
      final repository = LiveRepository(_FakeLiveService(), socketService);

      final countFuture = repository.watchViewerCount('room-1').first;

      repository.updateViewerCount('room-1', 500);

      final count = await countFuture;
      expect(count, 500);
    });

    test(
      'connectToRoom requests the current viewer count for the room',
      () async {
        final socketService = _FakeSocketService();
        final repository = LiveRepository(_FakeLiveService(), socketService);

        await repository.connectToRoom('room-1');

        expect(socketService.emittedEvents, isNotEmpty);
        final request = socketService.emittedEvents.last;
        expect(request.$1, 'get_live_viewers');
        expect(request.$2, {'room_id': 'room-1'});
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
  final List<(String, dynamic)> emittedEvents = <(String, dynamic)>[];
  bool _connected = false;

  @override
  Future<void> connect() async {
    _connected = true;
  }

  @override
  bool get isConnected => _connected;

  @override
  void joinRoom(String roomId) {}

  @override
  void on(String event, Function(dynamic) handler) {
    _handlers.putIfAbsent(event, () => []).add(handler);
  }

  @override
  void emit(String event, dynamic data) {
    emittedEvents.add((event, data));
  }

  void emitIncoming(String event, dynamic data) {
    for (final handler in _handlers[event] ?? const []) {
      handler(data);
    }
  }
}
