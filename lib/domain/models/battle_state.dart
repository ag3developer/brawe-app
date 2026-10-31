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

/// Represents the current state of a live battle between two streamers.
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
    this.lastGiftSender,
    this.lastGiftName,
    this.lastUpdatedSide,
    this.giftsCountA = 0,
    this.giftsCountB = 0,
    this.phase = BattlePhase.waiting,
    this.multiplier = 1.0,
    this.powerMoment = false,
    this.topGifterA,
    this.topGifterB,
    this.topGiftersA = const [],
    this.topGiftersB = const [],
  });

  final String battleId;
  final double scoreA;
  final double scoreB;
  final Duration timeRemaining;
  final String streamerAId;
  final String streamerAName;
  final String streamerBId;
  final String streamerBName;
  final String? streamerAAvatarUrl;
  final String? streamerBAvatarUrl;
  final String? roomAId;
  final String? roomBId;

  /// 🎬 HLS playback URL do streamer A (lado esquerdo do split-screen).
  /// O viewer usa pra montar o vídeo dual. `null` enquanto a sala não
  /// tem provisionamento de stream.
  final String? streamUrlA;

  /// 🎬 HLS playback URL do streamer B (lado direito do split-screen).
  final String? streamUrlB;

  /// 🎬 Mux Playback ID do streamer A (opcional — usado por Mux Data SDK).
  final String? playbackIdA;

  /// 🎬 Mux Playback ID do streamer B.
  final String? playbackIdB;

  final String? winnerId;
  final String? winnerName;
  final String? lastGiftSender;
  final String? lastGiftName;
  final String? lastUpdatedSide;
  final int giftsCountA;
  final int giftsCountB;
  final BattlePhase phase;

  /// 🔥 Multiplicador do último gift (2.0 durante o Power Moment).
  final double multiplier;

  /// 🔥 `true` quando a batalha está na janela de Power Moment (reta final).
  final bool powerMoment;

  /// 🏅 Maior doador (MVP) de cada lado — `null` se ninguém doou ainda.
  final BattleGifter? topGifterA;
  final BattleGifter? topGifterB;

  /// Top 3 apoiadores de cada lado (vazio se o servidor não enviar).
  final List<BattleGifter> topGiftersA;
  final List<BattleGifter> topGiftersB;

  double get progressA {
    final total = scoreA + scoreB;
    if (total == 0) return 0.5;
    return scoreA / total;
  }

  double get progressB => 1 - progressA;
  bool get isOver => phase == BattlePhase.finished;
  bool get isLeadingA => scoreA > scoreB;
  bool get isLeadingB => scoreB > scoreA;
  bool get isDraw => scoreA == scoreB;

  BattleState copyWith({
    double? scoreA,
    double? scoreB,
    Duration? timeRemaining,
    String? winnerId,
    String? winnerName,
    String? lastGiftSender,
    String? lastGiftName,
    String? lastUpdatedSide,
    int? giftsCountA,
    int? giftsCountB,
    BattlePhase? phase,
    double? multiplier,
    bool? powerMoment,
    BattleGifter? topGifterA,
    BattleGifter? topGifterB,
    List<BattleGifter>? topGiftersA,
    List<BattleGifter>? topGiftersB,
    String? streamUrlA,
    String? streamUrlB,
    String? playbackIdA,
    String? playbackIdB,
    String? roomAId,
    String? roomBId,
  }) {
    return BattleState(
      battleId: battleId,
      streamerAId: streamerAId,
      streamerAName: streamerAName,
      streamerBId: streamerBId,
      streamerBName: streamerBName,
      streamerAAvatarUrl: streamerAAvatarUrl,
      streamerBAvatarUrl: streamerBAvatarUrl,
      roomAId: roomAId ?? this.roomAId,
      roomBId: roomBId ?? this.roomBId,
      streamUrlA: streamUrlA ?? this.streamUrlA,
      streamUrlB: streamUrlB ?? this.streamUrlB,
      playbackIdA: playbackIdA ?? this.playbackIdA,
      playbackIdB: playbackIdB ?? this.playbackIdB,
      scoreA: scoreA ?? this.scoreA,
      scoreB: scoreB ?? this.scoreB,
      timeRemaining: timeRemaining ?? this.timeRemaining,
      winnerId: winnerId ?? this.winnerId,
      winnerName: winnerName ?? this.winnerName,
      lastGiftSender: lastGiftSender ?? this.lastGiftSender,
      lastGiftName: lastGiftName ?? this.lastGiftName,
      lastUpdatedSide: lastUpdatedSide ?? this.lastUpdatedSide,
      giftsCountA: giftsCountA ?? this.giftsCountA,
      giftsCountB: giftsCountB ?? this.giftsCountB,
      phase: phase ?? this.phase,
      multiplier: multiplier ?? this.multiplier,
      powerMoment: powerMoment ?? this.powerMoment,
      topGifterA: topGifterA ?? this.topGifterA,
      topGifterB: topGifterB ?? this.topGifterB,
      topGiftersA: topGiftersA ?? this.topGiftersA,
      topGiftersB: topGiftersB ?? this.topGiftersB,
    );
  }

  /// Factory: build initial state from battle invite/API payload.
  /// Aceita tanto o payload de `connect:battle:invite` quanto de
  /// `connect:battle:started` (mais campos) — todos opcionais via `??`.
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
        seconds: json['duration_seconds'] as int? ?? 300,
      ),
      phase: BattlePhase.waiting,
    );
  }
}

/// Helper para tratar strings vazias do backend como `null` (mais ergonômico
/// para `streamUrlA != null ? VideoPlayer(...) : Placeholder`).
String? _nonEmptyString(dynamic value) {
  if (value is String && value.isNotEmpty) return value;
  return null;
}

enum BattlePhase { waiting, countdown, active, finished }
