import 'user_award.dart';

int _i(dynamic v) => (v as num?)?.toInt() ?? 0;

DateTime? _dt(dynamic v) =>
    v == null ? null : DateTime.tryParse(v.toString())?.toLocal();

String? _s(dynamic v) {
  final t = v?.toString().trim();
  return (t == null || t.isEmpty || t == 'null') ? null : t;
}

/// Resultado do resgate de uma missão (POST /quests/{key}/claim).
class QuestClaimResult {
  const QuestClaimResult({
    required this.xp,
    required this.coins,
    required this.levelUp,
    required this.newLevel,
    required this.newBadgeKeys,
    required this.streakIncreased,
    required this.streak,
  });

  final int xp;
  final int coins;
  final bool levelUp;
  final int newLevel;
  final List<String> newBadgeKeys;
  final bool streakIncreased;
  final int streak;

  factory QuestClaimResult.fromJson(Map<String, dynamic> json) {
    final rewards = (json['rewards'] as Map?) ?? const {};
    final streak = (json['streak'] as Map?) ?? const {};
    final badges = (json['new_badges'] as List?) ?? const [];
    return QuestClaimResult(
      xp: _i(rewards['xp']),
      coins: _i(rewards['coins']),
      levelUp: json['level_up'] == true,
      newLevel: _i(json['new_level']),
      newBadgeKeys: badges
          .map((b) => b is Map ? _s(b['key']) : _s(b))
          .whereType<String>()
          .toList(),
      streakIncreased: streak['increased'] == true,
      streak: _i(streak['current']),
    );
  }

  /// Soma vários resgates (botão "Coletar tudo").
  static QuestClaimResult merge(List<QuestClaimResult> all) {
    var levelUp = false;
    var level = 0;
    var streakUp = false;
    var streak = 0;
    final badges = <String>[];
    for (final r in all) {
      levelUp |= r.levelUp;
      if (r.newLevel > level) level = r.newLevel;
      streakUp |= r.streakIncreased;
      if (r.streak > streak) streak = r.streak;
      for (final b in r.newBadgeKeys) {
        if (!badges.contains(b)) badges.add(b);
      }
    }
    return QuestClaimResult(
      xp: all.fold(0, (a, r) => a + r.xp),
      coins: all.fold(0, (a, r) => a + r.coins),
      levelUp: levelUp,
      newLevel: level,
      newBadgeKeys: badges,
      streakIncreased: streakUp,
      streak: streak,
    );
  }
}

/// Totais da vida toda do usuário nas missões.
class JourneyStats {
  const JourneyStats({
    this.level = 1,
    this.xpTotal = 0,
    this.totalQuestsCompleted = 0,
    this.totalXpEarned = 0,
    this.totalCoinsEarned = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.badgesUnlocked = 0,
    this.badgesTotal = 0,
    this.awardsTotal = 0,
    this.awardsActive = 0,
  });

  final int level;
  final int xpTotal;
  final int totalQuestsCompleted;
  final int totalXpEarned;
  final int totalCoinsEarned;
  final int currentStreak;
  final int longestStreak;
  final int badgesUnlocked;
  final int badgesTotal;
  final int awardsTotal;
  final int awardsActive;

  factory JourneyStats.fromJson(Map<String, dynamic> j) => JourneyStats(
        level: _i(j['level']) == 0 ? 1 : _i(j['level']),
        xpTotal: _i(j['xp_total']),
        totalQuestsCompleted: _i(j['total_quests_completed']),
        totalXpEarned: _i(j['total_xp_earned']),
        totalCoinsEarned: _i(j['total_coins_earned']),
        currentStreak: _i(j['current_streak']),
        longestStreak: _i(j['longest_streak']),
        badgesUnlocked: _i(j['badges_unlocked']),
        badgesTotal: _i(j['badges_total']),
        awardsTotal: _i(j['awards_total']),
        awardsActive: _i(j['awards_active']),
      );
}

/// Emblema de sequência (streak_3 … streak_100).
class JourneyBadge {
  const JourneyBadge({
    required this.key,
    required this.threshold,
    required this.emoji,
    required this.unlocked,
    this.earnedAt,
  });

  final String key;
  final int threshold;
  final String emoji;
  final bool unlocked;
  final DateTime? earnedAt;

  factory JourneyBadge.fromJson(Map<String, dynamic> j) => JourneyBadge(
        key: _s(j['key']) ?? '',
        threshold: _i(j['threshold']),
        emoji: _s(j['emoji']) ?? '🏅',
        unlocked: j['unlocked'] == true,
        earnedAt: _dt(j['earned_at']),
      );
}

/// Prêmio recebido (vigente, expirado, revogado ou agendado).
class JourneyAward {
  const JourneyAward({
    required this.award,
    required this.status,
    this.rank,
    this.startsAt,
    this.createdAt,
    this.revokedAt,
    this.freeCoins = 0,
    this.hasEntry = false,
  });

  final UserAward award;

  /// active | expired | revoked | scheduled
  final String status;
  final int? rank;
  final DateTime? startsAt;
  final DateTime? createdAt;
  final DateTime? revokedAt;
  final int freeCoins;
  final bool hasEntry;

  bool get isActive => status == 'active';

  static JourneyAward? tryParse(dynamic raw) {
    if (raw is! Map) return null;
    final award = UserAward.tryParse(raw);
    if (award == null) return null;
    return JourneyAward(
      award: award,
      status: _s(raw['status']) ?? 'active',
      rank: (raw['rank'] as num?)?.toInt(),
      startsAt: _dt(raw['starts_at']),
      createdAt: _dt(raw['created_at']),
      revokedAt: _dt(raw['revoked_at']),
      freeCoins: _i(raw['free_coins']),
      hasEntry: raw['entry'] is Map,
    );
  }
}

/// Item da linha do tempo.
class JourneyEvent {
  const JourneyEvent({
    required this.id,
    required this.kind,
    required this.at,
    this.title,
    this.questKey,
    this.icon,
    this.category,
    this.actionType,
    this.frequency,
    this.xp = 0,
    this.coins = 0,
    this.award,
    this.badgeKey,
    this.emoji,
    this.level,
  });

  final String id;

  /// quest | award | badge | level_up
  final String kind;
  final DateTime at;
  final String? title;
  final String? questKey;
  final String? icon;
  final String? category;
  final String? actionType;
  final String? frequency;
  final int xp;
  final int coins;
  final JourneyAward? award;
  final String? badgeKey;
  final String? emoji;
  final int? level;

  static JourneyEvent? tryParse(dynamic raw) {
    if (raw is! Map) return null;
    final at = _dt(raw['at']);
    final kind = _s(raw['kind']);
    if (at == null || kind == null) return null;
    return JourneyEvent(
      id: _s(raw['id']) ?? '$kind-${at.millisecondsSinceEpoch}',
      kind: kind,
      at: at,
      title: _s(raw['title']),
      questKey: _s(raw['quest_key']),
      icon: _s(raw['icon']),
      category: _s(raw['category']),
      actionType: _s(raw['action_type']),
      frequency: _s(raw['frequency']),
      xp: _i(raw['xp']),
      coins: _i(raw['coins']),
      award: JourneyAward.tryParse(raw['award']),
      badgeKey: _s(raw['badge_key']),
      emoji: _s(raw['emoji']),
      level: (raw['level'] as num?)?.toInt(),
    );
  }
}

/// GET /quests/journey
class QuestJourney {
  const QuestJourney({
    required this.stats,
    required this.badges,
    required this.awards,
    required this.timeline,
    required this.hasMore,
    this.nextBefore,
  });

  final JourneyStats stats;
  final List<JourneyBadge> badges;
  final List<JourneyAward> awards;
  final List<JourneyEvent> timeline;
  final bool hasMore;
  final String? nextBefore;

  factory QuestJourney.fromJson(Map<String, dynamic> json) {
    final d = (json['data'] is Map ? json['data'] : json) as Map;
    return QuestJourney(
      stats: JourneyStats.fromJson(
        Map<String, dynamic>.from((d['stats'] as Map?) ?? const {}),
      ),
      badges: ((d['badges'] as List?) ?? const [])
          .whereType<Map>()
          .map((b) => JourneyBadge.fromJson(Map<String, dynamic>.from(b)))
          .toList(),
      awards: ((d['awards'] as List?) ?? const [])
          .map(JourneyAward.tryParse)
          .whereType<JourneyAward>()
          .toList(),
      timeline: ((d['timeline'] as List?) ?? const [])
          .map(JourneyEvent.tryParse)
          .whereType<JourneyEvent>()
          .toList(),
      hasMore: d['has_more'] == true,
      nextBefore: _s(d['next_before']),
    );
  }

  /// Junta a próxima página da linha do tempo.
  QuestJourney appendPage(QuestJourney next) => QuestJourney(
        stats: stats,
        badges: badges,
        awards: awards,
        timeline: [
          ...timeline,
          ...next.timeline.where((e) => !timeline.any((o) => o.id == e.id)),
        ],
        hasMore: next.hasMore,
        nextBefore: next.nextBefore,
      );

}

