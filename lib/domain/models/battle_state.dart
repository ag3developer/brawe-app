/// Representa o estado atual de uma live de batalha entre dois streamers.
class BattleState {
  const BattleState({
    required this.scoreA,
    required this.scoreB,
    required this.timeRemaining,
    this.winnerId,
  });

  final int scoreA;
  final int scoreB;
  final Duration timeRemaining;
  final String? winnerId;

  double get progressA {
    final total = scoreA + scoreB;
    if (total == 0) return 0.5;
    return scoreA / total;
  }

  double get progressB => 1 - progressA;
  bool get isOver => winnerId != null || timeRemaining == Duration.zero;
  bool get isLeadingA => scoreA > scoreB;
  bool get isLeadingB => scoreB > scoreA;
}
