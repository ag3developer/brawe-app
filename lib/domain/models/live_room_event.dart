/// Evento de gamificação da live (level-up, meta etc.) — só UI, não persistido.
///
/// [type] é o nome do evento do socket: `viewer_level_up`,
/// `viewer_level_up_public` ou `live_goal_update`.
class LiveRoomEvent {
  const LiveRoomEvent({required this.type, required this.data});

  final String type;
  final Map<String, dynamic> data;

  static const levelUp = 'viewer_level_up';
  static const levelUpPublic = 'viewer_level_up_public';
  static const goalUpdate = 'live_goal_update';
  static const goalsUpdate = 'live_goals_update';

  /// Evento com prazo começou/terminou na sala (`{room_id, event|null}`).
  static const eventUpdate = 'event_update';

  /// Combo de presente cruzou um degrau (Fase 3) — todos na sala veem.
  static const giftComboTier = 'gift_combo_tier';

  /// Moderação (Fase 4): rejeição só para quem escreveu, modo lento, mensagem
  /// fixada e aviso de silêncio (para o usuário alvo).
  static const chatError = 'chat_error';
  static const slowMode = 'slow_mode';
  static const chatPinned = 'chat_pinned';
  static const chatMuted = 'chat_muted';

  /// Prêmio concedido ao usuário (sala pessoal, sem `room_id`).
  static const awardGranted = 'award_granted';
}
