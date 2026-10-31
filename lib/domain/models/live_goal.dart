/// Meta da live definida pelo criador: N unidades de um presente
/// ("10 Rosas") ou N curtidas. O progresso conta a partir da criação.
class LiveGoal {
  const LiveGoal({
    required this.id,
    required this.type,
    required this.target,
    this.progress = 0,
    this.reached = false,
    this.giftSlug,
    this.giftName,
    this.giftIconUrl,
  });

  static const typeGift = 'gift';
  static const typeLikes = 'likes';

  final String id;
  final String type;
  final int target;
  final int progress;
  final bool reached;
  final String? giftSlug;
  final String? giftName;
  final String? giftIconUrl;

  bool get isGift => type == typeGift;
  bool get isLikes => type == typeLikes;
  double get ratio => target <= 0 ? 0 : (progress / target).clamp(0.0, 1.0);

  static LiveGoal? fromMap(Object? raw) {
    if (raw is! Map) return null;
    final id = raw['id']?.toString() ?? '';
    final type = raw['type']?.toString() ?? '';
    final target = (raw['target'] as num?)?.toInt() ?? 0;
    if (id.isEmpty || target <= 0 || (type != typeGift && type != typeLikes)) {
      return null;
    }
    String? str(String k) {
      final v = raw[k]?.toString();
      return (v == null || v.isEmpty) ? null : v;
    }

    return LiveGoal(
      id: id,
      type: type,
      target: target,
      progress: (raw['progress'] as num?)?.toInt() ?? 0,
      reached: raw['reached'] == true,
      giftSlug: str('gift_slug'),
      giftName: str('gift_name'),
      giftIconUrl: str('gift_icon_url'),
    );
  }

  static List<LiveGoal> listFrom(Object? raw) => raw is List
      ? raw.map(LiveGoal.fromMap).whereType<LiveGoal>().toList()
      : const [];
}

/// Pedido do criador ao salvar as metas.
class LiveGoalDraft {
  const LiveGoalDraft.gift({required String slug, required this.target, this.id})
    : type = LiveGoal.typeGift,
      giftSlug = slug;
  const LiveGoalDraft.likes({required this.target, this.id})
    : type = LiveGoal.typeLikes,
      giftSlug = null;

  /// Meta já no ar: o servidor mantém (e o progresso não zera).
  final String? id;
  final String type;
  final String? giftSlug;
  final int target;

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'type': type,
    'target': target,
    if (giftSlug != null) 'gift_slug': giftSlug,
  };
}
