import 'dart:async';

import 'package:brawe_app/data/repositories/live_repository.dart';
import 'package:brawe_app/data/services/live_service.dart';
import 'package:brawe_app/domain/models/failure.dart';
import 'package:brawe_app/domain/models/live_comment.dart';
import 'package:brawe_app/domain/models/live_room.dart';
import 'package:brawe_app/ui/live_feed/view_models/live_room_comments_view_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LiveRoomCommentsViewModel', () {
    test('adds incoming comments and updates viewer count', () async {
      final repository = _FakeCommentsRepository();
      final container = ProviderContainer(
        overrides: [liveRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);

      const room = LiveRoom(
        id: 'room-7',
        title: 'Room',
        liveType: 'solo',
        isPrivate: false,
        status: 'live',
        viewerCount: 10,
        streamerId: 'host-1',
        streamerName: 'Host',
      );

      final subscription = container.listen(
        liveRoomCommentsViewModelProvider(room),
        (_, _) {},
        fireImmediately: true,
      );
      addTearDown(subscription.close);

      container.read(liveRoomCommentsViewModelProvider(room).notifier);
      await Future<void>.delayed(Duration.zero);
      repository.pushComment(
        LiveComment(
          id: 'comment-1',
          userId: 'viewer-1',
          userName: 'Viewer',
          message: 'Lets go',
          timestamp: DateTime.utc(2026, 3, 12, 12),
        ),
      );
      repository.pushViewerCount(88);

      await Future<void>.delayed(Duration.zero);

      final state = container.read(liveRoomCommentsViewModelProvider(room));
      expect(repository.connectedRooms, contains('room-7'));
      expect(state.comments, hasLength(1));
      expect(state.comments.first.message, 'Lets go');
      expect(state.viewerCount, 88);
    });

    test('send failure exposes a displayable error message', () async {
      final repository = _FakeCommentsRepository(
        sendFailure: const Failure.network(),
      );
      final container = ProviderContainer(
        overrides: [liveRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);

      const room = LiveRoom(
        id: 'room-8',
        title: 'Room',
        liveType: 'solo',
        isPrivate: false,
        status: 'live',
        viewerCount: 3,
        streamerId: 'host-2',
        streamerName: 'Host',
      );

      final notifier = container.read(
        liveRoomCommentsViewModelProvider(room).notifier,
      );
      await notifier.sendComment('Hello');

      final state = container.read(liveRoomCommentsViewModelProvider(room));
      expect(state.isSending, false);
      expect(state.errorMessage, 'No internet connection');
    });
  });
}

class _FakeCommentsRepository extends LiveRepository {
  _FakeCommentsRepository({this.sendFailure}) : super(LiveService(Dio()));

  final Failure? sendFailure;
  final StreamController<LiveComment> _commentsController =
      StreamController<LiveComment>.broadcast();
  final StreamController<int> _viewerCountController =
      StreamController<int>.broadcast();
  final Set<String> connectedRooms = <String>{};

  @override
  Future<void> connectToRoom(String roomId) async {
    connectedRooms.add(roomId);
  }

  @override
  void disconnectFromRoom(String roomId) {}

  @override
  Stream<LiveComment> watchComments(String roomId) =>
      _commentsController.stream;

  @override
  Stream<int> watchViewerCount(String roomId) => _viewerCountController.stream;

  @override
  Future<void> sendComment({
    required String roomId,
    required String message,
  }) async {
    if (sendFailure != null) {
      throw sendFailure!;
    }
  }

  void pushComment(LiveComment comment) {
    _commentsController.add(comment);
  }

  void pushViewerCount(int count) {
    _viewerCountController.add(count);
  }
}
