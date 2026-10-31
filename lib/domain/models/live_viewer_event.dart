/// Evento de viewer entrando/saindo da live (não persistido — só UI).
class LiveViewerEvent {
  const LiveViewerEvent({
    required this.userId,
    required this.viewerName,
    this.viewerAvatar,
    this.viewerCount = 0,
    required this.joined,
    this.level = 1,
    this.badgeEmoji,
    this.badgeColor,
    this.badgeImageUrl,
    this.entryEffect,
    this.rankingPosition,
  });

  final String userId;
  final String viewerName;
  final String? viewerAvatar;
  final int viewerCount;
  final bool joined; // true=joined, false=left

  /// Nível/badge/efeito de entrada do viewer (ausentes em servidor antigo).
  final int level;
  final String? badgeEmoji;
  final String? badgeColor; // hex "#FFD700"
  final String? badgeImageUrl;
  final String? entryEffect;

  /// Posição (1-based) no ranking da live; `null` se fora do ranking.
  final int? rankingPosition;

  /// Entrada "especial": nível >= 10 ou top 3 do ranking.
  bool get isSpecialEntry =>
      joined && (level >= 10 || (rankingPosition != null && rankingPosition! <= 3));

  factory LiveViewerEvent.fromSocket(Map<String, dynamic> data, {required bool joined}) {
    return LiveViewerEvent(
      userId: data['user_id']?.toString() ?? '',
      viewerName: data['viewer_name']?.toString() ?? 'Alguém',
      viewerAvatar: data['viewer_avatar']?.toString(),
      viewerCount: (data['viewer_count'] is int)
          ? data['viewer_count'] as int
          : int.tryParse('${data['viewer_count']}') ?? 0,
      joined: joined,
      level: int.tryParse('${data['level']}') ?? 1,
      badgeEmoji: _badgeField(data['badge'], 'badge'),
      badgeColor: _badgeField(data['badge'], 'color'),
      badgeImageUrl: _badgeField(data['badge'], 'image_url'),
      entryEffect: _str(data['entry_effect']),
      rankingPosition: int.tryParse('${data['ranking_position']}'),
    );
  }

  /// `badge` chega como objeto ({badge,label,color,image_url,...}) ou como
  /// emoji solto, dependendo da versão do servidor.
  static String? _badgeField(dynamic badge, String key) {
    if (badge is Map) return _str(badge[key]);
    return key == 'badge' ? _str(badge) : null;
  }

  static String? _str(dynamic v) {
    final s = v?.toString();
    return (s == null || s.isEmpty || s == 'null') ? null : s;
  }
}
