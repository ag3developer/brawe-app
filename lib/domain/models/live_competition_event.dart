/// Tipos de evento da competição de presentes (ranking ao vivo).
enum LiveCompetitionEventType {
  ranking,
  topGifterChanged,
  overtaken,
  likerRanking,
  likeMilestone,
}

/// Evento de socket da competição de presentes, já associado a uma sala.
///
/// Mantém o payload bruto (`data`) — o view model faz o parse tolerante,
/// assim campos novos/ausentes do servidor não quebram o app.
class LiveCompetitionEvent {
  const LiveCompetitionEvent(this.type, this.data);

  final LiveCompetitionEventType type;
  final Map<String, dynamic> data;
}
