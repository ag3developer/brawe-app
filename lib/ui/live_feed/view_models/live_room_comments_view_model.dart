import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/repositories/live_repository.dart';
import '../../../data/repositories/auth_state_provider.dart';
import '../../../domain/models/failure.dart';
import '../../../domain/models/live_comment.dart';
import '../../../domain/models/live_gift.dart';
import '../../../domain/models/live_viewer_event.dart';
import '../../../domain/models/user.dart';

part 'live_room_comments_view_model.g.dart';

class LiveRoomCommentsState {
  const LiveRoomCommentsState({
    this.comments = const <LiveComment>[],
    this.viewerCount = 0,
    this.likeCount = 0,
    this.totalComments = 0,
    this.totalGiftsValue = 0,
    this.isSending = false,
    this.errorMessage,
    this.recentViewerAvatars = const <String>[],
    this.gifterRanking = const <GifterEntry>[],
    this.myUsername,
    this.chatGifts = const <LiveGift>[],
  });

  final List<LiveComment> comments;
  final int viewerCount;
  final int likeCount;
  final int totalComments;

  /// 💎 Total acumulado em USDT (aproximado) de gifts recebidos na sala.
  final double totalGiftsValue;
  final bool isSending;
  final String? errorMessage;

  /// Avatares reais dos últimos viewers que entraram (máx. 3, FIFO).
  /// Alimentado pelo evento `viewer_joined` do socket.
  final List<String> recentViewerAvatars;

  /// Ranking de presenteadores acumulado em tempo real via socket.
  /// Ordenado por `totalValue` desc. Máx. 10 entradas (só Top 3 é exibido).
  final List<GifterEntry> gifterRanking;

  /// Meu @username (aprendido do eco das minhas mensagens) — usado para
  /// destacar mensagens que me mencionam.
  final String? myUsername;

  /// Presentes que aparecem como linha no chat. Separado da fila de
  /// animações (`LiveRoomGiftsViewModel`, que expira em 8s) — no chat o
  /// presente fica no histórico como as mensagens.
  final List<LiveGift> chatGifts;

  LiveRoomCommentsState copyWith({
    List<LiveComment>? comments,
    int? viewerCount,
    int? likeCount,
    int? totalComments,
    double? totalGiftsValue,
    bool? isSending,
    String? errorMessage,
    bool clearErrorMessage = false,
    List<String>? recentViewerAvatars,
    List<GifterEntry>? gifterRanking,
    String? myUsername,
    List<LiveGift>? chatGifts,
  }) {
    return LiveRoomCommentsState(
      comments: comments ?? this.comments,
      viewerCount: viewerCount ?? this.viewerCount,
      likeCount: likeCount ?? this.likeCount,
      totalComments: totalComments ?? this.totalComments,
      totalGiftsValue: totalGiftsValue ?? this.totalGiftsValue,
      isSending: isSending ?? this.isSending,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
      recentViewerAvatars: recentViewerAvatars ?? this.recentViewerAvatars,
      gifterRanking: gifterRanking ?? this.gifterRanking,
      myUsername: myUsername ?? this.myUsername,
      chatGifts: chatGifts ?? this.chatGifts,
    );
  }
}

/// Entrada no ranking de presenteadores (acumulado em tempo real).
class GifterEntry {
  const GifterEntry({
    required this.userId,
    required this.name,
    this.avatarUrl,
    required this.totalValue,
    required this.giftCount,
  });

  final String userId;
  final String name;
  final String? avatarUrl;

  /// Soma total de `value` (coins) dos gifts enviados nesta sessão.
  final int totalValue;

  /// Quantidade de gifts enviados.
  final int giftCount;

  GifterEntry addGift(int value) => GifterEntry(
    userId: userId,
    name: name,
    avatarUrl: avatarUrl,
    totalValue: totalValue + value,
    giftCount: giftCount + 1,
  );
}

@riverpod
class LiveRoomCommentsViewModel extends _$LiveRoomCommentsViewModel {
  late final String _roomId;
  StreamSubscription<LiveComment>? _commentsSubscription;
  StreamSubscription<int>? _viewerCountSubscription;
  StreamSubscription<int>? _likeCountSubscription;
  StreamSubscription<int>? _commentCountSubscription;
  StreamSubscription<double>? _giftTotalSubscription;
  StreamSubscription<LiveViewerEvent>? _viewerEventSubscription;
  StreamSubscription<LiveGift>? _giftsRankingSubscription;
  final Set<String> _seenGiftIds = {};

  @override
  LiveRoomCommentsState build(String roomId) {
    _roomId = roomId;
    final repository = ref.read(liveRepositoryProvider);

    ref.onDispose(() {
      _commentsSubscription?.cancel();
      _viewerCountSubscription?.cancel();
      _likeCountSubscription?.cancel();
      _commentCountSubscription?.cancel();
      _giftTotalSubscription?.cancel();
      _viewerEventSubscription?.cancel();
      _giftsRankingSubscription?.cancel();
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
    _likeCountSubscription = repository
        .watchLikeCount(roomId)
        .listen((count) => state = state.copyWith(likeCount: count));
    _commentCountSubscription = repository.watchCommentCount(roomId).listen((
      count,
    ) {
      // Sempre adota o valor do servidor (fonte de verdade), exceto
      // se já estivermos com um valor maior local (otimismo recente).
      if (count > state.totalComments) {
        state = state.copyWith(totalComments: count);
      }
    });
    _giftTotalSubscription = repository
        .watchGiftTotal(roomId)
        .listen((total) => state = state.copyWith(totalGiftsValue: total));

    // Avatares reais dos viewers: mantém os 3 mais recentes (FIFO).
    // Alimenta o ViewersStack no top bar — substitui os placeholders coloridos.
    _viewerEventSubscription = repository.watchViewerEvents(roomId).listen((
      event,
    ) {
      final avatar = event.viewerAvatar;
      if (avatar == null || avatar.isEmpty) return;
      if (!event.joined) return; // só adiciona quando entra
      final current = List<String>.from(state.recentViewerAvatars);
      current.remove(avatar); // evita duplicatas se mesmo user reconectar
      current.insert(0, avatar);
      if (current.length > 3) current.length = 3;
      state = state.copyWith(recentViewerAvatars: current);
    });

    // Ranking de presenteadores: acumula value de cada gift em tempo real.
    // Ordenado por totalValue desc, mantém máx 10 entradas para não crescer
    // indefinidamente. O sheet exibe só os Top 3.
    _giftsRankingSubscription = repository.watchGifts(roomId).listen((gift) {
      // Mesmo presente pode chegar 2× (reconexão) — conta uma vez só.
      if (gift.id.isNotEmpty && !_seenGiftIds.add(gift.id)) return;
      if (gift.showInChat) {
        final chat = [...state.chatGifts, gift];
        state = state.copyWith(
          chatGifts: chat.length > 30 ? chat.sublist(chat.length - 30) : chat,
        );
      }
      if (gift.senderId.isEmpty) return;
      final ranking = List<GifterEntry>.from(state.gifterRanking);
      final idx = ranking.indexWhere((e) => e.userId == gift.senderId);
      if (idx >= 0) {
        ranking[idx] = ranking[idx].addGift(gift.value * gift.quantity);
      } else {
        ranking.add(
          GifterEntry(
            userId: gift.senderId,
            name: gift.senderName,
            avatarUrl: gift.senderAvatarUrl,
            totalValue: gift.value * gift.quantity,
            giftCount: gift.quantity,
          ),
        );
      }
      ranking.sort((a, b) => b.totalValue.compareTo(a.totalValue));
      if (ranking.length > 10) ranking.length = 10;
      state = state.copyWith(gifterRanking: ranking);
    });

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
          totalComments: room.totalMessages,
        );
      }

      // 🏆 Busca ranking inicial de gifters da API (dados persistidos).
      // Carrega antes das atualizações em tempo real chegarem pelo socket,
      // para quem entrou no meio da live já ver o ranking histórico correto.
      final topGifters = await repository.getTopGifters(roomId, limit: 10);
      if (!ref.mounted) return;
      if (topGifters.isNotEmpty) {
        final initialRanking = topGifters
            .map((raw) {
              return GifterEntry(
                userId: raw['user_id']?.toString() ?? '',
                name:
                    raw['display_name']?.toString() ??
                    raw['name']?.toString() ??
                    'Alguém',
                avatarUrl: raw['avatar_url']?.toString(),
                totalValue:
                    (raw['total_coins'] as num?)?.toInt() ??
                    (raw['total_value'] as num?)?.toInt() ??
                    0,
                giftCount: (raw['gift_count'] as num?)?.toInt() ?? 0,
              );
            })
            .where((e) => e.userId.isNotEmpty)
            .toList();
        // O socket pode já ter adicionado entradas — merge: API tem precedência
        // para entradas existentes (histórico > streaming parcial).
        final merged = List<GifterEntry>.from(state.gifterRanking);
        for (final entry in initialRanking) {
          final idx = merged.indexWhere((e) => e.userId == entry.userId);
          if (idx < 0) {
            merged.add(entry); // novo viewer na lista da API
          }
          // Se já existe via socket, mantém o valor do socket (mais atual).
        }
        merged.sort((a, b) => b.totalValue.compareTo(a.totalValue));
        if (merged.length > 10) merged.length = 10;
        state = state.copyWith(gifterRanking: merged);
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

  Future<dynamic> _fetchRoomWithRetry(dynamic repository, String roomId) async {
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

  /// Envia um comentário com eco otimista (aparece na hora no chat).
  /// Retorna `false` se o envio falhou — a tela devolve o texto ao input
  /// para o usuário não perder o que digitou.
  Future<bool> sendComment(String message) async {
    final trimmedMessage = message.trim();
    if (trimmedMessage.isEmpty) {
      return false;
    }

    final optimisticComment = _buildOptimisticComment(trimmedMessage);
    _appendComment(optimisticComment);
    state = state.copyWith(isSending: true, clearErrorMessage: true);

    try {
      await ref
          .read(liveRepositoryProvider)
          .sendComment(roomId: _roomId, message: trimmedMessage);
      // Usuário pode ter saído da live durante o request.
      if (!ref.mounted) return true;
      _markCommentAsSent(optimisticComment.id);
      state = state.copyWith(isSending: false);
      return true;
    } on Failure catch (failure) {
      if (!ref.mounted) return false;
      _removeComment(optimisticComment.id);
      state = state.copyWith(
        isSending: false,
        errorMessage: failure.toDisplayMessage(),
      );
      return false;
    } catch (_) {
      if (!ref.mounted) return false;
      _removeComment(optimisticComment.id);
      state = state.copyWith(
        isSending: false,
        errorMessage: const Failure.unknown().toDisplayMessage(),
      );
      return false;
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
      myUsername: state.myUsername == null && _isMine(comment)
          ? comment.username
          : null,
    );
  }

  bool _isMine(LiveComment comment) {
    final authState = ref.read(authStateProvider);
    final me = authState is AsyncData<User?> ? authState.value : null;
    return me != null && comment.userId == me.id;
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
    // Casar por mensagem + (mesmo user_id OU janela de tempo) evita
    // duplicados. A janela é generosa (60s) porque o backend emitia
    // `datetime.utcnow().isoformat()` SEM o sufixo `Z`, fazendo o
    // Flutter parsear como hora local — diferença de fuso (até 12h)
    // estourava qualquer janela curta e o eco do servidor virava um
    // segundo comentário.
    if (existingComment.message != incomingComment.message) {
      return false;
    }
    // Se o user_id bate, é match imediato (mais robusto que tempo).
    if (incomingComment.userId.isNotEmpty &&
        existingComment.userId.isNotEmpty &&
        existingComment.userId == incomingComment.userId) {
      return true;
    }
    final secondsBetween = incomingComment.timestamp
        .difference(existingComment.timestamp)
        .inSeconds
        .abs();
    return secondsBetween <= 60;
  }

  /// Considera duplicado se o backend reemitiu o mesmo comentário
  /// (mesmo id, OU mesmo user+mensagem dentro de 60s — janela generosa
  /// para tolerar timestamps sem fuso vindos de versões antigas do server).
  bool _isDuplicate(List<LiveComment> comments, LiveComment incoming) {
    for (final c in comments) {
      if (c.id == incoming.id) return true;
      if (c.userId.isNotEmpty &&
          c.userId == incoming.userId &&
          c.message == incoming.message &&
          incoming.timestamp.difference(c.timestamp).inSeconds.abs() <= 60) {
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
