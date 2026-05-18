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
    this.likeCount = 0,
    this.totalComments = 0,
    this.isSending = false,
    this.errorMessage,
  });

  final List<LiveComment> comments;
  final int viewerCount;
  final int likeCount;
  final int totalComments;
  final bool isSending;
  final String? errorMessage;

  LiveRoomCommentsState copyWith({
    List<LiveComment>? comments,
    int? viewerCount,
    int? likeCount,
    int? totalComments,
    bool? isSending,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return LiveRoomCommentsState(
      comments: comments ?? this.comments,
      viewerCount: viewerCount ?? this.viewerCount,
      likeCount: likeCount ?? this.likeCount,
      totalComments: totalComments ?? this.totalComments,
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
  StreamSubscription<int>? _likeCountSubscription;

  @override
  LiveRoomCommentsState build(String roomId) {
    _roomId = roomId;
    final repository = ref.read(liveRepositoryProvider);

    ref.onDispose(() {
      _commentsSubscription?.cancel();
      _viewerCountSubscription?.cancel();
      _likeCountSubscription?.cancel();
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

      // Fetch initial room data to get initial viewer count.
      // Retry once on 404 (room may have just been created — DB visibility race).
      final room = await _fetchRoomWithRetry(repository, roomId);
      if (!ref.mounted) {
        return;
      }

      if (room != null) {
        state = state.copyWith(
          viewerCount: room.viewerCount,
          likeCount: room.totalLikes,
        );
      }
    } on Failure catch (failure) {
      if (!ref.mounted) {
        return;
      }
      // Sala recém-criada pode não estar visível ainda (caso de uso: broadcaster).
      // Não polui a UI com erro — viewerCount fica 0 e é atualizado via socket.
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

  Future<dynamic> _fetchRoomWithRetry(
    dynamic repository,
    String roomId,
  ) async {
    try {
      return await repository.getRoom(roomId);
    } on Failure catch (failure) {
      // Em caso de "not found"/network bem cedo no ciclo, esperar 600ms e tentar 1x.
      final isNotFound =
          failure.toDisplayMessage().toLowerCase().contains('not found') ||
              failure.toDisplayMessage().toLowerCase().contains('internet');
      if (!isNotFound) rethrow;
      await Future<void>.delayed(const Duration(milliseconds: 600));
      if (!ref.mounted) return null;
      return await repository.getRoom(roomId);
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
    } else if (!_isDuplicate(comments, comment)) {
      comments.add(comment);
      // Incrementar total acumulado (não é afetado pelo trim do overlay)
      state = state.copyWith(totalComments: state.totalComments + 1);
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
    // Comentários otimistas (`local-*`) são sempre do usuário atual.
    // Casar por mensagem + janela curta de tempo evita duplicados quando
    // o backend devolve `userId`/`userName` diferentes do snapshot otimista
    // (ex.: auth ainda carregando, email vs nome completo).
    if (existingComment.message != incomingComment.message) {
      return false;
    }
    final secondsBetween = incomingComment.timestamp
        .difference(existingComment.timestamp)
        .inSeconds
        .abs();
    return secondsBetween <= 15;
  }

  /// Considera duplicado se o backend reemitiu o mesmo comentário
  /// (mesmo id, OU mesmo user+mensagem dentro de 5s).
  bool _isDuplicate(List<LiveComment> comments, LiveComment incoming) {
    for (final c in comments) {
      if (c.id == incoming.id) return true;
      if (c.userId.isNotEmpty &&
          c.userId == incoming.userId &&
          c.message == incoming.message &&
          incoming.timestamp.difference(c.timestamp).inSeconds.abs() <= 5) {
        return true;
      }
    }
    return false;
  }

  List<LiveComment> _trimComments(List<LiveComment> comments) {
    if (comments.length <= 30) {
      return comments;
    }

    return comments.sublist(comments.length - 30);
  }
}
