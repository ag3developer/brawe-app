import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/repositories/live_repository.dart';
import '../../../data/repositories/auth_state_provider.dart';
import '../../../domain/models/failure.dart';
import '../../../domain/models/live_comment.dart';
import '../../../domain/models/user.dart';

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
    
    // Check if we already have a room with a viewer count in a list somewhere
    // For now we just start at 0, but _initialize will catch up soon.
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
      if (!ref.mounted) {
        return;
      }

      // Fetch initial room data to get initial viewer count
      final room = await repository.getRoom(roomId);
      if (!ref.mounted) {
        return;
      }

      if (room != null) {
        state = state.copyWith(viewerCount: room.viewerCount);
      }
    } on Failure catch (failure) {
      if (!ref.mounted) {
        return;
      }
      state = state.copyWith(errorMessage: failure.toDisplayMessage());
    } catch (_) {
      if (!ref.mounted) {
        return;
      }
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

    final optimisticComment = _buildOptimisticComment(trimmedMessage);
    _appendComment(optimisticComment);
    state = state.copyWith(isSending: true, clearErrorMessage: true);

    try {
      await ref
          .read(liveRepositoryProvider)
          .sendComment(roomId: _roomId, message: trimmedMessage);
      _markCommentAsSent(optimisticComment.id);
      state = state.copyWith(isSending: false);
    } on Failure catch (failure) {
      _removeComment(optimisticComment.id);
      state = state.copyWith(
        isSending: false,
        errorMessage: failure.toDisplayMessage(),
      );
    } catch (_) {
      _removeComment(optimisticComment.id);
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
    final comments = [...state.comments];
    final optimisticIndex = comments.indexWhere(
      (existingComment) =>
          _isMatchingOptimisticComment(existingComment, comment),
    );

    if (optimisticIndex >= 0) {
      comments[optimisticIndex] = comment;
    } else if (!comments.any(
      (existingComment) => existingComment.id == comment.id,
    )) {
      comments.add(comment);
    }

    state = state.copyWith(
      comments: _trimComments(comments),
      clearErrorMessage: true,
    );
  }

  LiveComment _buildOptimisticComment(String message) {
    final authState = ref.read(authStateProvider);
    final currentUser = authState is AsyncData<User?> ? authState.value : null;
    final timestamp = DateTime.now();
    return LiveComment(
      id: 'local-${timestamp.microsecondsSinceEpoch}',
      userId: currentUser?.id ?? 'current-user',
      userName: _resolveCurrentUserName(currentUser),
      avatarUrl: currentUser?.avatarUrl,
      message: message,
      timestamp: timestamp,
      isPending: true,
    );
  }

  String _resolveCurrentUserName(User? currentUser) {
    final name = currentUser?.name.trim();
    if (name != null && name.isNotEmpty) {
      return name;
    }

    final email = currentUser?.email.trim();
    if (email != null && email.isNotEmpty) {
      return email.split('@').first;
    }

    return 'You';
  }

  void _appendComment(LiveComment comment) {
    state = state.copyWith(
      comments: _trimComments([...state.comments, comment]),
      clearErrorMessage: true,
    );
  }

  void _markCommentAsSent(String commentId) {
    state = state.copyWith(
      comments: state.comments
          .map(
            (comment) => comment.id == commentId
                ? comment.copyWith(isPending: false)
                : comment,
          )
          .toList(growable: false),
    );
  }

  void _removeComment(String commentId) {
    state = state.copyWith(
      comments: state.comments
          .where((comment) => comment.id != commentId)
          .toList(growable: false),
    );
  }

  bool _isMatchingOptimisticComment(
    LiveComment existingComment,
    LiveComment incomingComment,
  ) {
    if (!existingComment.id.startsWith('local-')) {
      return false;
    }

    final sameUser =
        existingComment.userId == incomingComment.userId ||
        existingComment.userName == incomingComment.userName;
    if (!sameUser || existingComment.message != incomingComment.message) {
      return false;
    }

    final secondsBetween = incomingComment.timestamp
        .difference(existingComment.timestamp)
        .inSeconds
        .abs();
    return secondsBetween <= 10;
  }

  List<LiveComment> _trimComments(List<LiveComment> comments) {
    if (comments.length <= 30) {
      return comments;
    }

    return comments.sublist(comments.length - 30);
  }
}
