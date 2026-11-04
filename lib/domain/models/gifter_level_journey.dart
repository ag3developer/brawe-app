import 'gifter_level.dart';

/// Status de uma faixa na jornada do presenteador.
enum GifterTierStatus { achieved, current, locked }

/// Faixa de nível (ex.: níveis 15–19 "Guardião").
class GifterTier {
  final int minLevel;
  final int maxLevel;
  final int xpRequired;
  final Map<String, String> names; // pt/en/es
  final String color; // "#RRGGBB"
  final String? badgeEmoji;
  final String? badgeImageUrl;
  final bool hasEntryEffect;
  final bool vipEntry;
  final bool announceLevelUp;
  final GifterTierStatus status;
  final int xpMissing;

  const GifterTier({
    required this.minLevel,
    required this.maxLevel,
    required this.xpRequired,
    required this.names,
    required this.color,
    this.badgeEmoji,
    this.badgeImageUrl,
    this.hasEntryEffect = false,
    this.vipEntry = false,
    this.announceLevelUp = false,
    required this.status,
    this.xpMissing = 0,
  });

  /// Nome no idioma pedido (cai para pt/en/qualquer um).
  String nameFor(String lang) {
    for (final k in [lang, 'pt', 'en']) {
      final v = names[k];
      if (v != null && v.isNotEmpty) return v;
    }
    return names.values.firstWhere((e) => e.isNotEmpty, orElse: () => '');
  }

  bool get hasBenefits => vipEntry || hasEntryEffect || announceLevelUp;

  factory GifterTier.fromJson(Map<String, dynamic> json) {
    final rawName = (json['name'] as Map?) ?? const {};
    final status = switch (json['status']) {
      'achieved' => GifterTierStatus.achieved,
      'current' => GifterTierStatus.current,
      _ => GifterTierStatus.locked,
    };
    final img = json['badge_image_url'] as String?;
    final emoji = json['badge_emoji'] as String?;
    return GifterTier(
      minLevel: (json['min_level'] as num?)?.toInt() ?? 1,
      maxLevel: (json['max_level'] as num?)?.toInt() ?? 1,
      xpRequired: (json['xp_required'] as num?)?.toInt() ?? 0,
      names: rawName.map((k, v) => MapEntry('$k', '${v ?? ''}')),
      color: (json['color'] as String?) ?? '#AAAAAA',
      badgeEmoji: (emoji == null || emoji.isEmpty) ? null : emoji,
      badgeImageUrl: (img == null || img.trim().isEmpty) ? null : img,
      hasEntryEffect: json['has_entry_effect'] == true,
      vipEntry: json['vip_entry'] == true,
      announceLevelUp: json['announce_level_up'] == true,
      status: status,
      xpMissing: (json['xp_missing'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Regras vigentes de ganho de XP (editáveis no painel admin).
class GifterXpRules {
  final int join;
  final int watchPerMin;
  final int watchCapMin;
  final int chat;
  final String giftMode; // "per_coin" | "flat"
  final int giftPerCoin;
  final int giftCapPerSend;
  final int giftFlat;

  const GifterXpRules({
    this.join = 0,
    this.watchPerMin = 0,
    this.watchCapMin = 0,
    this.chat = 0,
    this.giftMode = 'per_coin',
    this.giftPerCoin = 0,
    this.giftCapPerSend = 0,
    this.giftFlat = 0,
  });

  factory GifterXpRules.fromJson(Map<String, dynamic> json) {
    int i(String k) => (json[k] as num?)?.toInt() ?? 0;
    return GifterXpRules(
      join: i('join'),
      watchPerMin: i('watch_per_min'),
      watchCapMin: i('watch_cap_min'),
      chat: i('chat'),
      giftMode: (json['gift_mode'] as String?) ?? 'per_coin',
      giftPerCoin: i('gift_per_coin'),
      giftCapPerSend: i('gift_cap_per_send'),
      giftFlat: i('gift_flat'),
    );
  }
}

/// Jornada de nível do presenteador — `GET /gifts/me/level/journey`.
class GifterLevelJourney {
  final int level;
  final int xp;
  final int maxLevel;
  final NextLevelProgress? nextLevel;
  final GifterTier? tier;
  final List<GifterTier> tiers;
  final GifterXpRules xpRules;

  const GifterLevelJourney({
    required this.level,
    required this.xp,
    required this.maxLevel,
    this.nextLevel,
    this.tier,
    this.tiers = const [],
    this.xpRules = const GifterXpRules(),
  });

  /// Primeira faixa ainda bloqueada (a "próxima faixa"), se existir.
  GifterTier? get nextTier {
    for (final t in tiers) {
      if (t.status == GifterTierStatus.locked) return t;
    }
    return null;
  }

  factory GifterLevelJourney.fromJson(Map<String, dynamic> json) {
    final tiers = ((json['tiers'] as List?) ?? const [])
        .whereType<Map>()
        .map((e) => GifterTier.fromJson(e.cast<String, dynamic>()))
        .toList()
      ..sort((a, b) => a.minLevel.compareTo(b.minLevel));
    GifterTier? current;
    for (final t in tiers) {
      if (t.status == GifterTierStatus.current) current = t;
    }
    return GifterLevelJourney(
      level: (json['level'] as num?)?.toInt() ?? 1,
      xp: (json['xp'] as num?)?.toInt() ?? 0,
      maxLevel: (json['max_level'] as num?)?.toInt() ?? 50,
      nextLevel: json['next_level'] is Map
          ? NextLevelProgress.fromJson(
              (json['next_level'] as Map).cast<String, dynamic>(),
            )
          : null,
      tier: current,
      tiers: tiers,
      xpRules: GifterXpRules.fromJson(
        ((json['xp_rules'] as Map?) ?? const {}).cast<String, dynamic>(),
      ),
    );
  }
}
