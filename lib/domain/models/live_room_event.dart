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
}
