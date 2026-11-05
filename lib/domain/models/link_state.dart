/// Participante de uma conexão entre criadores.
class LinkPeer {
  const LinkPeer({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.roomId,
    this.roomSlug,
    this.winStreak,
  });

  final String id;
  final String name;
  final String? avatarUrl;
  final String? roomId;
  final String? roomSlug;
  final int? winStreak;

  factory LinkPeer.fromJson(dynamic raw) {
    final m = raw is Map ? Map<String, dynamic>.from(raw) : <String, dynamic>{};
    String? s(dynamic v) => v == null || v.toString().isEmpty ? null : v.toString();
    return LinkPeer(
      id: s(m['id']) ?? '',
      name: s(m['name']) ?? '',
      avatarUrl: s(m['avatar_url']),
      roomId: s(m['room_id']),
      roomSlug: s(m['room_slug']),
      winStreak: (m['win_streak'] as num?)?.toInt(),
    );
  }
}

/// Estado de uma conexão ("Conectar", BATTLE_V2_CONTRACT §8).
class LinkState {
  const LinkState({
    required this.linkId,
    required this.status,
    required this.a,
    required this.b,
    this.rtcMode = 'composite',
    this.mutedA = false,
    this.mutedB = false,
    this.playbackA,
    this.playbackB,
    this.ownerLeft = false,
  });

  final String linkId;
  final String status;
  final String rtcMode;

  final LinkPeer a;
  final LinkPeer b;
  final bool mutedA;
  final bool mutedB;

  /// URLs LL-HLS de cada lado (§18.2); `null` = usar a URL normal da sala.
  final String? playbackA;
  final String? playbackB;

  /// §18.1: servidor espelha a composição (dono à esquerda). Ausente = false.
  final bool ownerLeft;

  String? playbackOf(String side) => side == 'a' ? playbackA : playbackB;

  bool get isActive => status == 'active';
  bool mutedOf(String side) => side == 'a' ? mutedA : mutedB;
  LinkPeer peer(String side) => side == 'a' ? a : b;

  /// Lado de uma sala/usuário nesta conexão.
  String? sideOf({String? userId, String? roomId}) {
    if (userId != null && userId.isNotEmpty) {
      if (a.id == userId) return 'a';
      if (b.id == userId) return 'b';
    }
    if (roomId != null && roomId.isNotEmpty) {
      if (a.roomId == roomId) return 'a';
      if (b.roomId == roomId) return 'b';
    }
    return null;
  }

  /// Lê `{a, b}` de um `playback` (link view ou `connect:link:media`).
  static (String?, String?) parsePlayback(dynamic raw) {
    if (raw is! Map) return (null, null);
    String? u(dynamic v) => v is String && v.isNotEmpty ? v : null;
    return (u(raw['a']), u(raw['b']));
  }

  LinkState withPlayback(String? a, String? b) => LinkState(
    linkId: linkId,
    status: status,
    a: this.a,
    b: this.b,
    rtcMode: rtcMode,
    mutedA: mutedA,
    mutedB: mutedB,
    playbackA: a,
    playbackB: b,
    ownerLeft: ownerLeft,
  );

  LinkState copyWith({bool? mutedA, bool? mutedB, String? status}) => LinkState(
    linkId: linkId,
    status: status ?? this.status,
    a: a,
    b: b,
    rtcMode: rtcMode,
    mutedA: mutedA ?? this.mutedA,
    mutedB: mutedB ?? this.mutedB,
    playbackA: playbackA,
    playbackB: playbackB,
    ownerLeft: ownerLeft,
  );

  static LinkState? tryParse(dynamic raw) {
    if (raw is! Map) return null;
    final m = Map<String, dynamic>.from(raw);
    final data = m['data'] is Map ? Map<String, dynamic>.from(m['data'] as Map) : m;
    final id = data['link_id']?.toString();
    if (id == null || id.isEmpty) return null;
    final pb = parsePlayback(data['playback']);
    final muted = data['muted'] is Map ? data['muted'] as Map : const {};
    return LinkState(
      linkId: id,
      status: data['status']?.toString() ?? 'active',
      rtcMode: data['rtc_mode']?.toString() ?? 'composite',
      a: LinkPeer.fromJson(data['streamer_a']),
      b: LinkPeer.fromJson(data['streamer_b']),
      mutedA: muted['a'] == true,
      mutedB: muted['b'] == true,
      playbackA: pb.$1,
      playbackB: pb.$2,
      ownerLeft: data['owner_left'] == true,
    );
  }
}
