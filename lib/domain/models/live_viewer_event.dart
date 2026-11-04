import 'user_award.dart';

/// Efeito de entrada do tier do viewer (`viewer_joined.entry`).
///
/// Só VAP e Lottie tocam; qualquer outro tipo (ou URL vazia) vira `null`
/// no parser — servidor antigo simplesmente não manda o campo.
class ViewerEntryEffect {
  const ViewerEntryEffect({
    required this.type,
    required this.url,
    this.presentation,
    this.soundEnabled = true,
  });

  /// `vap` ou `lottie`.
  final String type;
  final String url;

  /// Receita crua (mesmo formato de `GiftPresentation`); `null` = padrão.
  final Map<String, dynamic>? presentation;
  final bool soundEnabled;

  bool get isVap => type == 'vap';

  static ViewerEntryEffect? tryParse(dynamic raw) {
    if (raw is! Map) return null;
    final type = raw['type']?.toString().toLowerCase().trim();
    final url = raw['url']?.toString().trim();
    if ((type != 'vap' && type != 'lottie') || url == null || url.isEmpty) {
      return null;
    }
    final pr = raw['presentation'];
    final sound = raw['sound_enabled'];
    return ViewerEntryEffect(
      type: type!,
      url: url,
      presentation: pr is Map ? Map<String, dynamic>.from(pr) : null,
      soundEnabled: sound is bool ? sound : sound?.toString() != 'false',
    );
  }
}

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
    this.entry,
    this.tierName,
    this.award,
    this.isModerator = false,
    this.isVerified = false,
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

  /// Efeito de entrada do tier (ausente em servidor antigo ou sem VIP).
  final ViewerEntryEffect? entry;

  /// Nome do tier por idioma (`{pt,en,es}`), se o servidor enviar.
  final Map<String, String>? tierName;

  /// Prêmio ativo mais prestigioso (ausente em servidor antigo).
  final UserAward? award;

  /// Quem entrou é moderador do criador da live.
  final bool isModerator;

  /// Quem entrou tem conta verificada.
  final bool isVerified;

  /// Nome do tier no idioma [lang] (cai para pt e depois para qualquer um).
  String? localizedTierName(String lang) {
    final n = tierName;
    if (n == null || n.isEmpty) return null;
    return n[lang] ?? n['pt'] ?? n.values.first;
  }

  /// Entrada "especial": nível >= 10, top 3 do ranking ou tier com efeito
  /// de entrada (o servidor só manda `entry` para tiers VIP / #1).
  bool get isSpecialEntry =>
      joined &&
      (level >= 10 ||
          entry != null ||
          (rankingPosition != null && rankingPosition! <= 3));

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
      entry: ViewerEntryEffect.tryParse(data['entry']),
      award: UserAward.tryParse(data['award']),
      isModerator: data['is_moderator'] == true,
      isVerified: data['is_verified'] == true,
      tierName: _names(data['tier_name'] ?? data['name'] ?? _badgeRaw(data['badge'], 'name')),
    );
  }

  static dynamic _badgeRaw(dynamic badge, String key) =>
      badge is Map ? badge[key] : null;

  static Map<String, String>? _names(dynamic raw) {
    if (raw is! Map) return null;
    final out = <String, String>{};
    raw.forEach((k, v) {
      final s = _str(v);
      if (s != null) out[k.toString()] = s;
    });
    return out.isEmpty ? null : out;
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
