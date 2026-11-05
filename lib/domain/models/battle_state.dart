/// Doador de um lado da batalha (MVP / top supporters).
///
/// Aceita o formato novo `{user_id, name, avatar_url, points}` e o antigo
/// `{id, total}`.
class BattleGifter {
  const BattleGifter({
    required this.id,
    required this.total,
    this.name,
    this.avatarUrl,
  });

  final String id;

  /// Pontos (moedas gastas) do doador na batalha.
  final double total;
  final String? name;
  final String? avatarUrl;

  factory BattleGifter.fromJson(Map<String, dynamic> json) => BattleGifter(
    id: (json['user_id'] ?? json['id'])?.toString() ?? '',
    total: ((json['points'] ?? json['total']) as num?)?.toDouble() ?? 0,
    name: (json['name'] as String?)?.trim().isEmpty ?? true
        ? null
        : json['name'] as String?,
    avatarUrl: (json['avatar_url'] as String?)?.isEmpty ?? true
        ? null
        : json['avatar_url'] as String?,
  );

  /// Converte uma lista crua (`top_gifters_a/b`) ignorando itens inválidos.
  static List<BattleGifter> listFrom(dynamic raw) {
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((e) => BattleGifter.fromJson(Map<String, dynamic>.from(e)))
        .toList(growable: false);
  }
}

/// Último presente que pontuou na batalha (`last_gift` do `score_update`).
class BattleGiftEvent {
  const BattleGiftEvent({
    required this.seq,
    required this.side,
    required this.senderName,
    required this.giftName,
    this.senderAvatar,
    this.iconUrl,
    this.quantity = 1,
  });

  /// Sequência crescente por batalha — chave de dedupe dos toasts.
  final int seq;

  /// Lado que RECEBEU o presente ('a' | 'b').
  final String side;
  final String senderName;
  final String giftName;
  final String? senderAvatar;
  final String? iconUrl;
  final int quantity;
}

/// Desafio relâmpago (§9) — SEMPRE do lado da sala que recebe o evento.
class BattleFlash {
  const BattleFlash({
    required this.phase,
    required this.giftName,
    required this.giftSlug,
    this.iconUrl,
    this.target = 0,
    this.progress = 0,
    this.challengeEndsAt,
    this.boostEndsAt,
    this.multiplier = 2.0,
  });

  /// 'challenge' | 'boost'
  final String phase;
  final String giftName;
  final String giftSlug;
  final String? iconUrl;
  final int target;
  final int progress;

  /// Prazos já convertidos para o relógio LOCAL (via `server_now`).
  final DateTime? challengeEndsAt;
  final DateTime? boostEndsAt;
  final double multiplier;

  bool get isBoost => phase == 'boost';
}

/// Representa o estado de uma batalha ao vivo entre dois criadores.
class BattleState {
  const BattleState({
    required this.battleId,
    required this.scoreA,
    required this.scoreB,
    required this.timeRemaining,
    required this.streamerAId,
    required this.streamerAName,
    required this.streamerBId,
    required this.streamerBName,
    this.streamerAAvatarUrl,
    this.streamerBAvatarUrl,
    this.roomAId,
    this.roomBId,
    this.streamUrlA,
    this.streamUrlB,
    this.playbackIdA,
    this.playbackIdB,
    this.winnerId,
    this.winnerName,
    this.winner,
    this.endReason,
    this.forfeitBy,
    this.lastGiftSender,
    this.lastGiftName,
    this.lastUpdatedSide,
    this.lastGift,
    this.giftsCountA = 0,
    this.giftsCountB = 0,
    this.phase = BattlePhase.waiting,
    this.multiplier = 1.0,
    this.powerMoment = false,
    this.powerWindowSeconds = 30,
    this.topGifterA,
    this.topGifterB,
    this.topGiftersA = const [],
    this.topGiftersB = const [],
    this.rtcMode = 'dual_hls',
    this.ownerLeft = false,
    this.endsAt,
    this.durationSeconds,
    this.mutedA = false,
    this.mutedB = false,
    this.countdown,
    this.lastSeq = 0,
    this.roomSlugA,
    this.roomSlugB,
    this.mvp,
    this.mvpSide,
    this.winStreakA,
    this.winStreakB,
    this.flash,
    this.assetsVersion,
  });

  final String battleId;
  final double scoreA;
  final double scoreB;

  /// Tempo restante derivado do relógio do servidor (ver `BattleViewModel`).
  final Duration timeRemaining;
  final String streamerAId;
  final String streamerAName;
  final String streamerBId;
  final String streamerBName;
  final String? streamerAAvatarUrl;
  final String? streamerBAvatarUrl;
  final String? roomAId;
  final String? roomBId;

  /// HLS playback URL do streamer A (modo `dual_hls`, metade esquerda).
  final String? streamUrlA;

  /// HLS playback URL do streamer B (modo `dual_hls`, metade direita).
  final String? streamUrlB;

  final String? playbackIdA;
  final String? playbackIdB;

  final String? winnerId;
  final String? winnerName;

  /// 'a' | 'b' | 'draw' (contrato). `null` até a batalha acabar.
  final String? winner;

  /// 'time' | 'forfeit' | 'live_ended'.
  final String? endReason;

  /// 'a' | 'b' — quem desistiu (só em `forfeit`).
  final String? forfeitBy;

  // Legado (campos planos do `score_update` antigo).
  final String? lastGiftSender;
  final String? lastGiftName;
  final String? lastUpdatedSide;

  /// Último presente com `seq` — usado nos toasts.
  final BattleGiftEvent? lastGift;
  final int giftsCountA;
  final int giftsCountB;
  final BattlePhase phase;

  /// 🔥 Multiplicador do último gift (2.0 durante o Power Moment).
  final double multiplier;

  /// 🔥 `true` quando a batalha está na janela de Power Moment (reta final).
  final bool powerMoment;

  /// Duração da janela do Power Moment (`power_window_seconds`).
  final int powerWindowSeconds;

  /// 🏅 Maior doador (MVP) de cada lado — `null` se ninguém doou ainda.
  final BattleGifter? topGifterA;
  final BattleGifter? topGifterB;

  /// Top 3 apoiadores de cada lado (vazio se o servidor não enviar).
  final List<BattleGifter> topGiftersA;
  final List<BattleGifter> topGiftersB;

  /// 'composite' (LiveKit + composição) | 'dual_hls' (fallback).
  final String rtcMode;

  /// §18.1: o servidor espelha a composição (dono à esquerda). `false` = A
  /// à esquerda, como no app antigo.
  final bool ownerLeft;

  /// Fim da batalha no relógio do servidor.
  final DateTime? endsAt;
  final int? durationSeconds;

  /// `muted[x] == true`: o lado x silenciou o adversário no próprio lado.
  final bool mutedA;
  final bool mutedB;

  /// 3, 2, 1 (dirigido pelo servidor) ou `null` fora da contagem.
  final int? countdown;

  /// Maior `seq` já aplicado (descarta eventos fora de ordem).
  final int lastSeq;

  /// Slugs das salas (para abrir a live do adversário).
  final String? roomSlugA;
  final String? roomSlugB;

  /// MVP geral do resultado (`mvp` do contrato: maior apoiador dos 2 lados).
  final BattleGifter? mvp;
  final String? mvpSide;

  /// Sequência de vitórias de cada criador (`null` = o servidor não enviou).
  final BattleFlash? flash;

  /// Versão do manifesto de mídia (`assets_version`, Batalha v3).
  final int? assetsVersion;
  final int? winStreakA;
  final int? winStreakB;
  int? winStreakOf(String side) => side == 'a' ? winStreakA : winStreakB;

  bool get isComposite => rtcMode == 'composite';

  double get progressA {
    final total = scoreA + scoreB;
    if (total == 0) return 0.5;
    return scoreA / total;
  }

  double get progressB => 1 - progressA;
  bool get isOver => phase == BattlePhase.finished;
  bool get isCancelled => phase == BattlePhase.cancelled;
  bool get isLeadingA => scoreA > scoreB;
  bool get isLeadingB => scoreB > scoreA;
  bool get isDraw => winner != null ? winner == 'draw' : scoreA == scoreB;

  /// §15: terminou sem vencedor (saiu, live caiu, conexão caiu).
  bool get endedWithoutWinner =>
      isOver &&
      (winner == null || winner!.isEmpty) &&
      const ['left', 'live_ended', 'rtc_failed', 'forfeit'].contains(endReason);

  /// Lado vencedor ('a' | 'b') ou `null` em empate / sem resultado.
  String? get winnerSide {
    if (endedWithoutWinner) return null;
    if (winner == 'a' || winner == 'b') return winner;
    if (winner == 'draw') return null;
    if (winnerId != null && winnerId!.isNotEmpty) {
      if (winnerId == streamerAId) return 'a';
      if (winnerId == streamerBId) return 'b';
    }
    if (scoreA == scoreB) return null;
    return scoreA > scoreB ? 'a' : 'b';
  }

  /// Lado ('a'|'b') de um criador pelo id (usuário ou sala); `null` se
  /// não participa (ex.: espectador).
  String? sideOf({String? userId, String? roomId}) {
    if (userId != null && userId.isNotEmpty) {
      if (userId == streamerAId) return 'a';
      if (userId == streamerBId) return 'b';
    }
    if (roomId != null && roomId.isNotEmpty) {
      if (roomId == roomAId) return 'a';
      if (roomId == roomBId) return 'b';
    }
    return null;
  }

  String? roomIdOf(String side) => side == 'a' ? roomAId : roomBId;
  String? roomSlugOf(String side) => side == 'a' ? roomSlugA : roomSlugB;

  String nameOf(String side) => side == 'a' ? streamerAName : streamerBName;
  String? avatarOf(String side) =>
      side == 'a' ? streamerAAvatarUrl : streamerBAvatarUrl;
  double scoreOf(String side) => side == 'a' ? scoreA : scoreB;
  List<BattleGifter> gifters(String side) =>
      side == 'a' ? topGiftersA : topGiftersB;
  bool mutedOf(String side) => side == 'a' ? mutedA : mutedB;

  /// MVP do lado (campo dedicado ou 1º da lista de apoiadores).
  BattleGifter? mvpOf(String side) {
    if (mvp != null && mvpSide == side && mvp!.total > 0) return mvp;
    final direct = side == 'a' ? topGifterA : topGifterB;
    if (direct != null && direct.total > 0) return direct;
    final list = gifters(side);
    return list.isNotEmpty && list.first.total > 0 ? list.first : null;
  }

  BattleState copyWith({
    double? scoreA,
    double? scoreB,
    Duration? timeRemaining,
    Object? winnerId = _unset,
    Object? winnerName = _unset,
    Object? winner = _unset,
    Object? endReason = _unset,
    Object? forfeitBy = _unset,
    Object? lastGiftSender = _unset,
    Object? lastGiftName = _unset,
    Object? lastUpdatedSide = _unset,
    Object? lastGift = _unset,
    int? giftsCountA,
    int? giftsCountB,
    BattlePhase? phase,
    double? multiplier,
    bool? powerMoment,
    int? powerWindowSeconds,
    Object? topGifterA = _unset,
    Object? topGifterB = _unset,
    List<BattleGifter>? topGiftersA,
    List<BattleGifter>? topGiftersB,
    Object? streamUrlA = _unset,
    Object? streamUrlB = _unset,
    Object? playbackIdA = _unset,
    Object? playbackIdB = _unset,
    Object? roomAId = _unset,
    Object? roomBId = _unset,
    String? streamerAName,
    String? streamerBName,
    String? streamerAId,
    String? streamerBId,
    Object? streamerAAvatarUrl = _unset,
    Object? streamerBAvatarUrl = _unset,
    String? rtcMode,
    bool? ownerLeft,
    Object? endsAt = _unset,
    Object? durationSeconds = _unset,
    bool? mutedA,
    bool? mutedB,
    Object? countdown = _unset,
    int? lastSeq,
    Object? roomSlugA = _unset,
    Object? roomSlugB = _unset,
    Object? mvp = _unset,
    Object? mvpSide = _unset,
    Object? winStreakA = _unset,
    Object? winStreakB = _unset,
    Object? flash = _unset,
    Object? assetsVersion = _unset,
  }) {
    return BattleState(
      battleId: battleId,
      streamerAId: streamerAId ?? this.streamerAId,
      streamerAName: streamerAName ?? this.streamerAName,
      streamerBId: streamerBId ?? this.streamerBId,
      streamerBName: streamerBName ?? this.streamerBName,
      streamerAAvatarUrl: identical(streamerAAvatarUrl, _unset)
          ? this.streamerAAvatarUrl
          : streamerAAvatarUrl as String?,
      streamerBAvatarUrl: identical(streamerBAvatarUrl, _unset)
          ? this.streamerBAvatarUrl
          : streamerBAvatarUrl as String?,
      roomAId: identical(roomAId, _unset) ? this.roomAId : roomAId as String?,
      roomBId: identical(roomBId, _unset) ? this.roomBId : roomBId as String?,
      streamUrlA: identical(streamUrlA, _unset)
          ? this.streamUrlA
          : streamUrlA as String?,
      streamUrlB: identical(streamUrlB, _unset)
          ? this.streamUrlB
          : streamUrlB as String?,
      playbackIdA: identical(playbackIdA, _unset)
          ? this.playbackIdA
          : playbackIdA as String?,
      playbackIdB: identical(playbackIdB, _unset)
          ? this.playbackIdB
          : playbackIdB as String?,
      scoreA: scoreA ?? this.scoreA,
      scoreB: scoreB ?? this.scoreB,
      timeRemaining: timeRemaining ?? this.timeRemaining,
      winnerId: identical(winnerId, _unset)
          ? this.winnerId
          : winnerId as String?,
      winnerName: identical(winnerName, _unset)
          ? this.winnerName
          : winnerName as String?,
      winner: identical(winner, _unset) ? this.winner : winner as String?,
      endReason: identical(endReason, _unset)
          ? this.endReason
          : endReason as String?,
      forfeitBy: identical(forfeitBy, _unset)
          ? this.forfeitBy
          : forfeitBy as String?,
      lastGiftSender: identical(lastGiftSender, _unset)
          ? this.lastGiftSender
          : lastGiftSender as String?,
      lastGiftName: identical(lastGiftName, _unset)
          ? this.lastGiftName
          : lastGiftName as String?,
      lastUpdatedSide: identical(lastUpdatedSide, _unset)
          ? this.lastUpdatedSide
          : lastUpdatedSide as String?,
      lastGift: identical(lastGift, _unset)
          ? this.lastGift
          : lastGift as BattleGiftEvent?,
      giftsCountA: giftsCountA ?? this.giftsCountA,
      giftsCountB: giftsCountB ?? this.giftsCountB,
      phase: phase ?? this.phase,
      multiplier: multiplier ?? this.multiplier,
      powerMoment: powerMoment ?? this.powerMoment,
      powerWindowSeconds: powerWindowSeconds ?? this.powerWindowSeconds,
      topGifterA: identical(topGifterA, _unset)
          ? this.topGifterA
          : topGifterA as BattleGifter?,
      topGifterB: identical(topGifterB, _unset)
          ? this.topGifterB
          : topGifterB as BattleGifter?,
      topGiftersA: topGiftersA ?? this.topGiftersA,
      topGiftersB: topGiftersB ?? this.topGiftersB,
      rtcMode: rtcMode ?? this.rtcMode,
      ownerLeft: ownerLeft ?? this.ownerLeft,
      endsAt: identical(endsAt, _unset) ? this.endsAt : endsAt as DateTime?,
      durationSeconds: identical(durationSeconds, _unset)
          ? this.durationSeconds
          : durationSeconds as int?,
      mutedA: mutedA ?? this.mutedA,
      mutedB: mutedB ?? this.mutedB,
      countdown: identical(countdown, _unset)
          ? this.countdown
          : countdown as int?,
      lastSeq: lastSeq ?? this.lastSeq,
      roomSlugA: identical(roomSlugA, _unset) ? this.roomSlugA : roomSlugA as String?,
      roomSlugB: identical(roomSlugB, _unset) ? this.roomSlugB : roomSlugB as String?,
      mvp: identical(mvp, _unset) ? this.mvp : mvp as BattleGifter?,
      mvpSide: identical(mvpSide, _unset) ? this.mvpSide : mvpSide as String?,
      flash: identical(flash, _unset) ? this.flash : flash as BattleFlash?,
      assetsVersion: identical(assetsVersion, _unset)
          ? this.assetsVersion
          : assetsVersion as int?,
      winStreakA: identical(winStreakA, _unset) ? this.winStreakA : winStreakA as int?,
      winStreakB: identical(winStreakB, _unset) ? this.winStreakB : winStreakB as int?,
    );
  }

  /// Factory: estado inicial a partir do payload de convite/API.
  factory BattleState.fromInviteJson(Map<String, dynamic> json) {
    return BattleState(
      battleId: json['battle_id'] as String? ?? '',
      streamerAId: json['streamer_a_id'] as String? ?? '',
      streamerAName: json['streamer_a_name'] as String? ?? '',
      streamerBId: json['streamer_b_id'] as String? ?? '',
      streamerBName: json['streamer_b_name'] as String? ?? '',
      streamerAAvatarUrl: json['streamer_a_avatar'] as String?,
      streamerBAvatarUrl: json['streamer_b_avatar'] as String?,
      roomAId: json['room_a_id'] as String?,
      roomBId: json['room_b_id'] as String?,
      streamUrlA: _nonEmptyString(json['stream_url_a']),
      streamUrlB: _nonEmptyString(json['stream_url_b']),
      playbackIdA: _nonEmptyString(json['playback_id_a']),
      playbackIdB: _nonEmptyString(json['playback_id_b']),
      scoreA: 0,
      scoreB: 0,
      timeRemaining: Duration(
        seconds: (json['duration_seconds'] as num?)?.toInt() ?? 300,
      ),
      phase: BattlePhase.waiting,
    );
  }
}

const Object _unset = Object();

String? _nonEmptyString(dynamic value) {
  if (value is String && value.isNotEmpty) return value;
  return null;
}

enum BattlePhase { waiting, countdown, active, finished, cancelled }
