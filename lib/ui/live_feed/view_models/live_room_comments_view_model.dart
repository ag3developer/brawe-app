import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/repositories/live_repository.dart';
import '../../../data/repositories/auth_state_provider.dart';
import '../../../domain/models/failure.dart';
import '../../../domain/models/live_comment.dart';
import '../../../domain/models/live_gift.dart';
import '../../../domain/models/live_competition_event.dart';
import '../../../domain/models/live_event.dart';
import '../../../domain/models/user_award.dart';
import '../../../domain/models/live_viewer_event.dart';
import '../../../domain/models/live_room.dart';
import '../../../domain/models/live_room_event.dart';
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
    this.rankingTotalPoints = 0,
    this.myRank,
    this.myPoints,
    this.rankingFromServer = false,
    this.overtaken,
    this.newTopGifter,
    this.likerRanking = const <GifterEntry>[],
    this.uniqueLikers = 0,
    this.myLikeRank,
    this.myLikes,
    this.likeMilestone,
    this.myUsername,
    this.chatGifts = const <LiveGift>[],
    this.chatGiftParts = const <String, List<GiftChatPart>>{},
    this.event,
    this.eventLoaded = false,
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

  /// Total de pontos (moedas gastas) da live, do servidor. 0 = desconhecido.
  final int rankingTotalPoints;

  /// Minha posição/pontos no ranking (REST `me`), mesmo fora do top 10.
  final int? myRank;
  final int? myPoints;

  /// True depois de receber snapshot do servidor (`gifter_ranking` ou REST
  /// com `total_points`); a partir daí o acúmulo local otimista é ignorado.
  final bool rankingFromServer;

  /// Último evento `gifter_overtaken` (já com throttle aplicado).
  final GifterOvertakenEvent? overtaken;

  /// Último evento `top_gifter_changed`.
  final TopGifterChangedEvent? newTopGifter;

  /// Ranking de curtidores (curtidas válidas contadas no servidor). Reusa
  /// `GifterEntry`: `totalValue` = curtidas.
  final List<GifterEntry> likerRanking;
  final int uniqueLikers;
  final int? myLikeRank;
  final int? myLikes;

  /// Último marco de curtidas da live (1 mil, 5 mil, 10 mil…).
  final LikeMilestoneEvent? likeMilestone;

  /// Meu @username (aprendido do eco das minhas mensagens) — usado para
  /// destacar mensagens que me mencionam.
  final String? myUsername;

  /// Presentes que aparecem como linha no chat. Separado da fila de
  /// animações (`LiveRoomGiftsViewModel`, que expira em 8s) — no chat o
  /// presente fica no histórico como as mensagens.
  final List<LiveGift> chatGifts;

  /// Linhas de presente que juntaram presentes diferentes da mesma pessoa
  /// ("50× Rosa + 1× Dragão"), por id da linha em [chatGifts].
  final Map<String, List<GiftChatPart>> chatGiftParts;

  /// Evento com prazo em vigor na sala (multiplicador de pontos).
  final LiveEvent? event;

  /// True depois que o servidor informou o estado do evento (sala carregada
  /// ou `event_update`); antes disso a tela usa o evento inicial da sala.
  final bool eventLoaded;

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
    int? rankingTotalPoints,
    int? myRank,
    int? myPoints,
    bool clearMe = false,
    bool? rankingFromServer,
    GifterOvertakenEvent? overtaken,
    TopGifterChangedEvent? newTopGifter,
    List<GifterEntry>? likerRanking,
    int? uniqueLikers,
    int? myLikeRank,
    int? myLikes,
    LikeMilestoneEvent? likeMilestone,
    String? myUsername,
    List<LiveGift>? chatGifts,
    Map<String, List<GiftChatPart>>? chatGiftParts,
    LiveEvent? event,
    bool clearEvent = false,
    bool? eventLoaded,
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
      rankingTotalPoints: rankingTotalPoints ?? this.rankingTotalPoints,
      myRank: clearMe ? null : myRank ?? this.myRank,
      myPoints: clearMe ? null : myPoints ?? this.myPoints,
      rankingFromServer: rankingFromServer ?? this.rankingFromServer,
      overtaken: overtaken ?? this.overtaken,
      newTopGifter: newTopGifter ?? this.newTopGifter,
      likerRanking: likerRanking ?? this.likerRanking,
      uniqueLikers: uniqueLikers ?? this.uniqueLikers,
      myLikeRank: myLikeRank ?? this.myLikeRank,
      myLikes: myLikes ?? this.myLikes,
      likeMilestone: likeMilestone ?? this.likeMilestone,
      myUsername: myUsername ?? this.myUsername,
      chatGifts: chatGifts ?? this.chatGifts,
      chatGiftParts: chatGiftParts ?? this.chatGiftParts,
      event: clearEvent ? null : event ?? this.event,
      eventLoaded: eventLoaded ?? this.eventLoaded,
    );
  }
}

/// Um presente dentro de uma linha de chat agrupada.
class GiftChatPart {
  const GiftChatPart({
    required this.key,
    required this.giftName,
    this.iconUrl,
    required this.quantity,
  });

  final String key;
  final String giftName;
  final String? iconUrl;
  final int quantity;

  GiftChatPart add(int n) =>
      GiftChatPart(key: key, giftName: giftName, iconUrl: iconUrl, quantity: quantity + n);
}

class _ChatBurst {
  _ChatBurst(this.first);

  final LiveGift first;
  final List<GiftChatPart> parts = [];
  Timer? timer;
}

/// Marco de curtidas da live (evento `like_milestone`).
class LikeMilestoneEvent {
  const LikeMilestoneEvent({required this.id, required this.milestone});

  final int id;
  final int milestone;
}

/// Entrada no ranking de presenteadores (acumulado em tempo real).
class GifterEntry {
  const GifterEntry({
    required this.userId,
    required this.name,
    this.avatarUrl,
    required this.totalValue,
    required this.giftCount,
    this.level,
    this.award,
  });

  /// Parse tolerante de um item do ranking (socket ou REST).
  static GifterEntry? fromMap(Map raw) {
    final id = raw['user_id']?.toString() ?? '';
    if (id.isEmpty) return null;
    return GifterEntry(
      userId: id,
      name:
          raw['display_name']?.toString() ??
          raw['user_name']?.toString() ??
          raw['name']?.toString() ??
          'Alguém',
      avatarUrl: _nonEmpty(raw['avatar_url']),
      // Pontos = moedas gastas. Servidor antigo só mandava USDT.
      totalValue:
          (raw['points'] as num?)?.toInt() ??
          (((raw['total_usdt'] as num?) ?? 0).toDouble() * 100).toInt(),
      giftCount:
          (raw['gift_count'] as num?)?.toInt() ??
          (raw['total_gifts'] as num?)?.toInt() ??
          0,
      level: (raw['level'] as num?)?.toInt(),
      award: UserAward.tryParse(raw['award']),
    );
  }

  static String? _nonEmpty(dynamic v) {
    final s = v?.toString();
    return (s == null || s.isEmpty) ? null : s;
  }

  final int? level;

  /// Prêmio ativo (moldura/badge) — ausente em servidor antigo.
  final UserAward? award;
  final String userId;
  final String name;
  final String? avatarUrl;

  /// Soma total de `value` (coins) dos gifts enviados nesta sessão.
  final int totalValue;

  /// Quantidade de gifts enviados.
  final int giftCount;

  GifterEntry addGift(int value, {int count = 1}) => GifterEntry(
    userId: userId,
    name: name,
    avatarUrl: avatarUrl,
    totalValue: totalValue + value,
    giftCount: giftCount + count,
    level: level,
    award: award,
  );
}

/// Alguém passou o usuário no ranking (`gifter_overtaken`).
class GifterOvertakenEvent {
  const GifterOvertakenEvent({
    required this.id,
    required this.byName,
    this.byAvatarUrl,
    required this.gapPoints,
    required this.previousRank,
    this.yourRank,
    this.multiplier,
  });

  /// Identificador crescente — permite à UI detectar evento novo.
  final int id;
  final String byName;
  final String? byAvatarUrl;
  final int gapPoints;
  final int previousRank;
  final int? yourRank;

  /// Multiplicador de evento em vigor (ex.: 2.0); `null` = sem evento.
  final double? multiplier;
}

/// Novo #1 da live (`top_gifter_changed`).
class TopGifterChangedEvent {
  const TopGifterChangedEvent({
    required this.id,
    required this.userId,
    required this.name,
    this.avatarUrl,
    required this.points,
  });

  final int id;
  final String userId;
  final String name;
  final String? avatarUrl;
  final int points;
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
  StreamSubscription<LiveCompetitionEvent>? _competitionSubscription;
  StreamSubscription<void>? _reconnectSubscription;
  StreamSubscription<LiveRoomEvent>? _roomEventSubscription;
  int _eventSeq = 0;
  DateTime? _lastOvertakenAt;
  final Set<String> _seenGiftIds = {};

  @override
  LiveRoomCommentsState build(String roomId) {
    _roomId = roomId;
    final repository = ref.read(liveRepositoryProvider);

    ref.onDispose(() {
      for (final b in _chatBursts.values) {
        b.timer?.cancel();
      }
      _chatBursts.clear();
      _commentsSubscription?.cancel();
      _viewerCountSubscription?.cancel();
      _likeCountSubscription?.cancel();
      _commentCountSubscription?.cancel();
      _giftTotalSubscription?.cancel();
      _viewerEventSubscription?.cancel();
      _giftsRankingSubscription?.cancel();
      _competitionSubscription?.cancel();
      _reconnectSubscription?.cancel();
      _roomEventSubscription?.cancel();
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
      if (gift.showInChat) _addToChatBurst(gift);
      // Com snapshot do servidor (`gifter_ranking`) o ranking é dele; o
      // acúmulo local abaixo é só fallback para servidor antigo.
      if (state.rankingFromServer) return;
      if (gift.senderId.isEmpty) return;
      final ranking = List<GifterEntry>.from(state.gifterRanking);
      final idx = ranking.indexWhere((e) => e.userId == gift.senderId);
      if (idx >= 0) {
        ranking[idx] = ranking[idx].addGift(
          gift.value * gift.quantity,
          count: gift.quantity,
        );
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

    _competitionSubscription = repository
        .watchCompetition(roomId)
        .listen(_handleCompetitionEvent);
    // Socket reconectou: pode ter perdido eventos — refaz o snapshot.
    _reconnectSubscription = repository.watchReconnects().listen((_) {
      _refreshRanking();
      _refreshEvent();
    });
    // Evento com prazo começou/terminou (servidor antigo nunca emite).
    _roomEventSubscription = repository.watchRoomEvents(roomId).listen((e) {
      if (e.type == LiveRoomEvent.chatError) {
        _dropRejectedOptimistic();
        return;
      }
      if (e.type != LiveRoomEvent.eventUpdate) return;
      _applyEvent(LiveEvent.tryParse(e.data['event']));
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
        if (room is LiveRoom) _applyEvent(room.event);
      }

      // 🏆 Busca ranking inicial de gifters da API (dados persistidos).
      await _refreshRanking();
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

  void _applyEvent(LiveEvent? e) {
    if (!ref.mounted) return;
    state = e == null
        ? state.copyWith(clearEvent: true, eventLoaded: true)
        : state.copyWith(event: e, eventLoaded: true);
  }

  Future<void> _refreshEvent() async {
    final res = await ref.read(liveRepositoryProvider).getActiveEvent(_roomId);
    if (res.ok) _applyEvent(res.event);
  }

  /// Aplica um snapshot do servidor (socket ou REST) como fonte de verdade.
  void _applyServerRanking(
    List<GifterEntry> entries, {
    int? totalPoints,
    Map? me,
  }) {
    final sorted = List<GifterEntry>.from(entries)
      ..sort((a, b) => b.totalValue.compareTo(a.totalValue));
    if (sorted.length > 10) sorted.length = 10;
    final myRank = (me?['rank'] as num?)?.toInt();
    final myPoints = (me?['points'] as num?)?.toInt();
    state = state.copyWith(
      gifterRanking: sorted,
      rankingTotalPoints: totalPoints,
      rankingFromServer: true,
      clearMe: me == null,
      myRank: myRank,
      myPoints: myPoints,
    );
  }

  /// Busca o top-gifters via REST (inicial, reconexão). Com servidor novo
  /// (`total_points` presente) substitui a lista; senão faz merge com o que
  /// o socket já acumulou (servidor antigo).
  Future<void> _refreshRanking() async {
    final repository = ref.read(liveRepositoryProvider);
    unawaited(_refreshLikers());
    final full = await repository.getTopGiftersFull(_roomId, limit: 10);
    if (!ref.mounted) return;
    final raw = full['data'] ?? full['top_gifters'];
    if (raw is! List) return;
    final initialRanking = raw
        .whereType<Map>()
        .map(GifterEntry.fromMap)
        .whereType<GifterEntry>()
        .toList();
    final total = (full['total_points'] as num?)?.toInt();
    if (total != null) {
      _applyServerRanking(
        initialRanking,
        totalPoints: total,
        me: full['me'] is Map ? full['me'] as Map : null,
      );
      return;
    }
    if (initialRanking.isEmpty) return;
    // O socket pode já ter adicionado entradas — merge: fica o maior total
    // (o parcial do socket não apaga o histórico da API).
    final merged = List<GifterEntry>.from(state.gifterRanking);
    for (final entry in initialRanking) {
      final idx = merged.indexWhere((e) => e.userId == entry.userId);
      if (idx < 0) {
        merged.add(entry);
      } else if (entry.totalValue > merged[idx].totalValue) {
        merged[idx] = GifterEntry(
          userId: entry.userId,
          name: entry.name,
          avatarUrl: entry.avatarUrl ?? merged[idx].avatarUrl,
          totalValue: entry.totalValue,
          giftCount: entry.giftCount,
          level: entry.level,
          award: entry.award,
        );
      }
    }
    merged.sort((a, b) => b.totalValue.compareTo(a.totalValue));
    if (merged.length > 10) merged.length = 10;
    state = state.copyWith(gifterRanking: merged);
  }

  // ── Presentes no chat: uma linha por "rajada" ──────────────────────────
  //
  // Quem manda sem parar (rosa atrás de rosa, combos) não vira 50 linhas no
  // chat: a soma aparece ao vivo no combo, e quando a pessoa PARA (sem
  // presente novo por [_chatBurstIdle]) entra UMA linha: "João enviou
  // 50× Rosa + 1× Dragão".
  static const _chatBurstIdle = Duration(milliseconds: 4500);
  final Map<String, _ChatBurst> _chatBursts = {};

  void _addToChatBurst(LiveGift gift) {
    final key = gift.senderId.isNotEmpty ? gift.senderId : gift.senderName;
    final burst = _chatBursts.putIfAbsent(key, () => _ChatBurst(gift));
    final giftKey = (gift.giftSlug?.isNotEmpty ?? false) ? gift.giftSlug! : gift.giftName;
    final idx = burst.parts.indexWhere((p) => p.key == giftKey);
    if (idx >= 0) {
      burst.parts[idx] = burst.parts[idx].add(gift.quantity);
    } else {
      burst.parts.add(
        GiftChatPart(
          key: giftKey,
          giftName: gift.giftName,
          iconUrl: gift.giftIconUrl,
          quantity: gift.quantity,
        ),
      );
    }
    burst.timer?.cancel();
    burst.timer = Timer(_chatBurstIdle, () => _flushChatBurst(key));
  }

  void _flushChatBurst(String key) {
    final burst = _chatBursts.remove(key);
    if (burst == null || !ref.mounted || burst.parts.isEmpty) return;
    final main = burst.parts.first;
    final line = burst.first.copyWith(
      giftName: main.giftName,
      giftIconUrl: main.iconUrl,
      quantity: main.quantity,
      // Entra no fim do chat quando a pessoa para de enviar.
      timestamp: DateTime.now(),
    );
    final parts = Map<String, List<GiftChatPart>>.from(state.chatGiftParts);
    if (burst.parts.length > 1) parts[line.id] = List.unmodifiable(burst.parts);
    final chat = [...state.chatGifts, line];
    final trimmed = chat.length > 30 ? chat.sublist(chat.length - 30) : chat;
    parts.removeWhere((id, _) => !trimmed.any((g) => g.id == id));
    state = state.copyWith(chatGifts: trimmed, chatGiftParts: parts);
  }

  /// Ranking de curtidores via REST (entrada / reconexão).
  Future<void> _refreshLikers() async {
    final full = await ref.read(liveRepositoryProvider).getTopLikers(_roomId);
    if (!ref.mounted || full.isEmpty) return;
    _applyLikers(full['data'], full);
    final me = full['me'];
    if (me is Map) {
      state = state.copyWith(
        myLikeRank: (me['rank'] as num?)?.toInt(),
        myLikes: (me['likes'] as num?)?.toInt(),
      );
    }
  }

  void _applyLikers(Object? raw, Map<String, dynamic> d) {
    if (raw is! List) return;
    final entries = raw
        .whereType<Map>()
        .map((m) => GifterEntry.fromMap({...m, 'points': m['likes']}))
        .whereType<GifterEntry>()
        .toList();
    final myId = ref.read(authStateProvider).value?.id;
    final idx = myId == null ? -1 : entries.indexWhere((e) => e.userId == myId);
    final total = (d['total_likes'] as num?)?.toInt();
    state = state.copyWith(
      likerRanking: entries,
      uniqueLikers: (d['unique_likers'] as num?)?.toInt(),
      likeCount: total != null && total > state.likeCount ? total : null,
      myLikeRank: idx >= 0 ? idx + 1 : null,
      myLikes: idx >= 0 ? entries[idx].totalValue : null,
    );
  }

  void _handleCompetitionEvent(LiveCompetitionEvent event) {
    final d = event.data;
    switch (event.type) {
      case LiveCompetitionEventType.likerRanking:
        _applyLikers(d['ranking'], d);
      case LiveCompetitionEventType.likeMilestone:
        final m = (d['milestone'] as num?)?.toInt() ?? 0;
        if (m <= 0) return;
        state = state.copyWith(
          likeMilestone: LikeMilestoneEvent(id: ++_eventSeq, milestone: m),
        );
      case LiveCompetitionEventType.ranking:
        final list = d['ranking'];
        if (list is! List) return;
        final entries = list
            .whereType<Map>()
            .map(GifterEntry.fromMap)
            .whereType<GifterEntry>()
            .toList();
        // `me` vem só do REST; recalcula a minha posição se estou no top 10.
        _applyServerRanking(
          entries,
          totalPoints: (d['total_points'] as num?)?.toInt(),
          me: _meFromSnapshot(entries),
        );
      case LiveCompetitionEventType.topGifterChanged:
        final userId = d['user_id']?.toString() ?? '';
        if (userId.isEmpty) return;
        state = state.copyWith(
          newTopGifter: TopGifterChangedEvent(
            id: ++_eventSeq,
            userId: userId,
            name: d['name']?.toString() ?? 'Alguém',
            avatarUrl: GifterEntry.fromMap({
              'user_id': userId,
              'avatar_url': d['avatar_url'],
            })?.avatarUrl,
            points: (d['points'] as num?)?.toInt() ?? 0,
          ),
        );
      case LiveCompetitionEventType.overtaken:
        // Throttle: no máximo um aviso a cada 20s (ultrapassagens em rajada).
        final now = DateTime.now();
        final last = _lastOvertakenAt;
        if (last != null && now.difference(last) < const Duration(seconds: 20)) {
          return;
        }
        final gap = (d['gap_points'] as num?)?.toInt() ?? 0;
        if (gap <= 0) return;
        _lastOvertakenAt = now;
        final av = d['by_avatar_url']?.toString();
        state = state.copyWith(
          overtaken: GifterOvertakenEvent(
            id: ++_eventSeq,
            byName: d['by_name']?.toString() ?? 'Alguém',
            byAvatarUrl: (av == null || av.isEmpty) ? null : av,
            gapPoints: gap,
            previousRank: (d['previous_rank'] as num?)?.toInt() ?? 1,
            yourRank: (d['your_rank'] as num?)?.toInt(),
            multiplier: activeMultiplier(d['multiplier']),
          ),
        );
    }
  }

  /// Minha posição a partir de um snapshot do socket (quando estou no top 10);
  /// senão mantém o `me` anterior do REST.
  Map<String, dynamic>? _meFromSnapshot(List<GifterEntry> entries) {
    final me = ref.read(authStateProvider).value;
    final myId = me?.id;
    if (myId == null) return null;
    final idx = entries.indexWhere((e) => e.userId == myId);
    if (idx >= 0) return {'rank': idx + 1, 'points': entries[idx].totalValue};
    // Fora do top 10: mantém a posição do REST (só se já era > 10).
    final prev = state.myRank;
    if (prev != null && prev > 10) {
      return {'rank': prev, 'points': state.myPoints};
    }
    return null;
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

  /// `chat_error`: o servidor recusou a mensagem que acabei de mandar — tira
  /// o eco otimista mais recente (sem eco real, ele ficaria no chat).
  void _dropRejectedOptimistic() {
    final now = DateTime.now();
    for (var i = state.comments.length - 1; i >= 0; i--) {
      final c = state.comments[i];
      if (c.id.startsWith('local-') &&
          now.difference(c.timestamp).inSeconds.abs() <= 10) {
        _removeComment(c.id);
        return;
      }
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

  /// Linha de sistema no chat (ex.: "fulano subiu para o nível 10").
  void addSystemMessage(String message) {
    final now = DateTime.now();
    final line = LiveComment(
      id: 'sys-${now.microsecondsSinceEpoch}',
      userId: '',
      userName: '',
      message: message,
      timestamp: now,
      isSystem: true,
    );
    state = state.copyWith(comments: _trimComments([...state.comments, line]));
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
