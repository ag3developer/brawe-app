/// Criador ao vivo que pode ser convidado para uma batalha.
///
/// Vem de `GET /live/battle/candidates` — o backend já exclui o próprio
/// usuário, quem está em batalha/convite pendente, lives privadas e
/// streamers sem elegibilidade.
class BattleCandidate {
  const BattleCandidate({
    required this.roomId,
    required this.userId,
    required this.displayName,
    this.username,
    this.avatarUrl,
    this.title = '',
    this.viewerCount = 0,
    this.isFollowing = false,
  });

  final String roomId;
  final String userId;
  final String displayName;
  final String? username;
  final String? avatarUrl;
  final String title;
  final int viewerCount;
  final bool isFollowing;

  factory BattleCandidate.fromJson(Map<String, dynamic> json) {
    final username = (json['username'] as String?)?.trim();
    final display = (json['display_name'] as String?)?.trim();
    return BattleCandidate(
      roomId: json['room_id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      displayName: display != null && display.isNotEmpty
          ? display
          : (username != null && username.isNotEmpty
                ? '@$username'
                : 'Criador'),
      username: username,
      avatarUrl: _nonEmpty(json['avatar_url']),
      title: json['title']?.toString() ?? '',
      viewerCount: (json['viewer_count'] as num?)?.toInt() ?? 0,
      isFollowing: json['is_following'] as bool? ?? false,
    );
  }
}

String? _nonEmpty(dynamic v) => v is String && v.isNotEmpty ? v : null;
