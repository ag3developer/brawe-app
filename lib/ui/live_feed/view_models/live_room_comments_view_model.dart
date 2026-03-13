import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/repositories/live_repository.dart';
import '../../../domain/models/failure.dart';
import '../../../domain/models/live_comment.dart';
import '../../../domain/models/live_room.dart';

part 'live_room_comments_view_model.g.dart';

class LiveRoomCommentsState {
  const LiveRoomCommentsState({
    this.comments = const <LiveComment>[],
    this.viewerCount = 0,
    this.isSending = false,
    this.errorMessage,
  });

  final List<LiveComment> comments;
  final int viewerCount;
  final bool isSending;
  final String? errorMessage;

  LiveRoomCommentsState copyWith({
    List<LiveComment>? comments,
    int? viewerCount,
    bool? isSending,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return LiveRoomCommentsState(
      comments: comments ?? this.comments,
      viewerCount: viewerCount ?? this.viewerCount,
      isSending: isSending ?? this.isSending,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }
}

@riverpod
class LiveRoomCommentsViewModel extends _$LiveRoomCommentsViewModel {
  late final String _roomId;
  StreamSubscription<LiveComment>? _commentsSubscription;
  StreamSubscription<int>? _viewerCountSubscription;

  @override
  LiveRoomCommentsState build(String roomId) {
    _roomId = roomId;
    final repository = ref.read(liveRepositoryProvider);

    ref.onDispose(() {
      _commentsSubscription?.cancel();
      _viewerCountSubscription?.cancel();
      repository.disconnectFromRoom(_roomId);
    });

    _initialize(roomId);
    return const LiveRoomCommentsState();
  }

  Future<void> _initialize(String roomId) async {
    final repository = ref.read(liveRepositoryProvider);

    _commentsSubscription = repository
        .watchComments(roomId)
        .listen(_handleIncomingComment);
    _viewerCountSubscription = repository
        .watchViewerCount(roomId)
        .listen((count) => state = state.copyWith(viewerCount: count));

    try {
      await repository.connectToRoom(roomId);
    } on Failure catch (failure) {
      state = state.copyWith(errorMessage: failure.toDisplayMessage());
    } catch (_) {
      state = state.copyWith(
        errorMessage: const Failure.unknown().toDisplayMessage(),
      );
    }
  }

  Future<void> sendComment(String message) async {
    final trimmedMessage = message.trim();
    if (trimmedMessage.isEmpty) {
      return;
    }

    state = state.copyWith(isSending: true, clearErrorMessage: true);

    try {
      await ref
          .read(liveRepositoryProvider)
          .sendComment(roomId: _roomId, message: trimmedMessage);
      state = state.copyWith(isSending: false);
    } on Failure catch (failure) {
      state = state.copyWith(
        isSending: false,
        errorMessage: failure.toDisplayMessage(),
      );
    } catch (_) {
      state = state.copyWith(
        isSending: false,
        errorMessage: const Failure.unknown().toDisplayMessage(),
      );
    }
  }

  void clearError() {
    if (state.errorMessage == null) {
      return;
    }

    state = state.copyWith(clearErrorMessage: true);
  }

  void _handleIncomingComment(LiveComment comment) {
    final updatedComments = <LiveComment>[...state.comments, comment];
    if (updatedComments.length > 30) {
      updatedComments.removeRange(0, updatedComments.length - 30);
    }

    state = state.copyWith(comments: updatedComments, clearErrorMessage: true);
  }
}
