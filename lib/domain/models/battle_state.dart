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
    this.winnerId,
    this.winnerName,
    this.lastGiftSender,
    this.lastGiftName,
    this.lastUpdatedSide,
    this.giftsCountA = 0,
    this.giftsCountB = 0,
    this.phase = BattlePhase.waiting,
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
  final String? winnerId;
  final String? winnerName;
  final String? lastGiftSender;
  final String? lastGiftName;
  final String? lastUpdatedSide;
  final int giftsCountA;
  final int giftsCountB;
  final BattlePhase phase;

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
  }) {
    return BattleState(
      battleId: battleId,
      streamerAId: streamerAId,
      streamerAName: streamerAName,
      streamerBId: streamerBId,
      streamerBName: streamerBName,
      streamerAAvatarUrl: streamerAAvatarUrl,
      streamerBAvatarUrl: streamerBAvatarUrl,
      roomAId: roomAId,
      roomBId: roomBId,
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
    );
  }

  /// Factory: build initial state from battle invite/API payload.
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
      scoreA: 0,
      scoreB: 0,
      timeRemaining: Duration(
        seconds: json['duration_seconds'] as int? ?? 300,
      ),
      phase: BattlePhase.waiting,
    );
  }
}

enum BattlePhase { waiting, countdown, active, finished }
