// Domain models for the daily quests system.
// Mirrors brawe-connect/backend/app/api/v1/quests.py response shape.

class DailyQuest {
  final String id;
  final String questKey;
  final String title;
  final String description;
  final String icon;
  final String category;
  final String difficulty;
  final String actionType;
  final int currentCount;
  final int targetCount;
  final int progressPercent;
  final bool isCompleted;
  final bool isClaimed;
  final int xpReward;
  final int coinsReward;

  /// `daily` | `weekly` | `event` (servidor antigo = `daily`).
  final String frequency;
  final String? eventId;

  /// Segundos até esta missão reiniciar (diária: meia-noite UTC; semanal:
  /// segunda 03:00 UTC; evento: fim do evento). `null` em servidor antigo.
  final int? resetsInSeconds;

  bool get isWeekly => frequency == 'weekly';
  bool get isEvent => frequency == 'event';

  const DailyQuest({
    required this.id,
    required this.questKey,
    required this.title,
    required this.description,
    required this.icon,
    required this.category,
    required this.difficulty,
    required this.actionType,
    required this.currentCount,
    required this.targetCount,
    required this.progressPercent,
    required this.isCompleted,
    required this.isClaimed,
    required this.xpReward,
    required this.coinsReward,
    this.frequency = 'daily',
    this.eventId,
    this.resetsInSeconds,
  });

  bool get isClaimable => isCompleted && !isClaimed;

  factory DailyQuest.fromJson(Map<String, dynamic> json) {
    return DailyQuest(
      id: (json['id'] ?? '').toString(),
      questKey: (json['quest_key'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      icon: (json['icon'] ?? 'star').toString(),
      category: (json['category'] ?? 'general').toString(),
      difficulty: (json['difficulty'] ?? 'easy').toString(),
      actionType: (json['action_type'] ?? '').toString(),
      currentCount: (json['current_count'] as num?)?.toInt() ?? 0,
      targetCount: (json['target_count'] as num?)?.toInt() ?? 1,
      progressPercent: (json['progress_percent'] as num?)?.toInt() ?? 0,
      isCompleted: json['is_completed'] as bool? ?? false,
      isClaimed: json['is_claimed'] as bool? ?? false,
      xpReward: (json['xp_reward'] as num?)?.toInt() ?? 0,
      coinsReward: (json['coins_reward'] as num?)?.toInt() ?? 0,
      frequency: _frequency(json['frequency']),
      eventId: _nonEmpty(json['event_id']),
      resetsInSeconds: (json['resets_in_seconds'] as num?)?.toInt(),
    );
  }

  static String _frequency(dynamic v) {
    final s = v?.toString().toLowerCase().trim();
    return (s == 'weekly' || s == 'event') ? s! : 'daily';
  }

  static String? _nonEmpty(dynamic v) {
    final s = v?.toString().trim();
    return (s == null || s.isEmpty || s == 'null') ? null : s;
  }

  DailyQuest copyWith({
    int? currentCount,
    int? progressPercent,
    bool? isCompleted,
    bool? isClaimed,
  }) {
    return DailyQuest(
      id: id,
      questKey: questKey,
      title: title,
      description: description,
      icon: icon,
      category: category,
      difficulty: difficulty,
      actionType: actionType,
      currentCount: currentCount ?? this.currentCount,
      targetCount: targetCount,
      progressPercent: progressPercent ?? this.progressPercent,
      isCompleted: isCompleted ?? this.isCompleted,
      isClaimed: isClaimed ?? this.isClaimed,
      xpReward: xpReward,
      coinsReward: coinsReward,
      frequency: frequency,
      eventId: eventId,
      resetsInSeconds: resetsInSeconds,
    );
  }
}

class QuestSummary {
  final int totalQuests;
  final int completed;
  final int totalXpToday;
  final int totalCoinsToday;
  final bool allCompleted;

  const QuestSummary({
    required this.totalQuests,
    required this.completed,
    required this.totalXpToday,
    required this.totalCoinsToday,
    required this.allCompleted,
  });

  factory QuestSummary.fromJson(Map<String, dynamic> json) {
    return QuestSummary(
      totalQuests: (json['total_quests'] as num?)?.toInt() ?? 0,
      completed: (json['completed'] as num?)?.toInt() ?? 0,
      totalXpToday: (json['total_xp_today'] as num?)?.toInt() ?? 0,
      totalCoinsToday: (json['total_coins_today'] as num?)?.toInt() ?? 0,
      allCompleted: json['all_completed'] as bool? ?? false,
    );
  }
}

class QuestProfile {
  final int level;
  final int xpTotal;
  final int xpIntoLevel;
  final int xpToNextLevel;
  final int levelProgressPercent;

  const QuestProfile({
    required this.level,
    required this.xpTotal,
    required this.xpIntoLevel,
    required this.xpToNextLevel,
    required this.levelProgressPercent,
  });

  factory QuestProfile.fromJson(Map<String, dynamic> json) {
    return QuestProfile(
      level: (json['level'] as num?)?.toInt() ?? 1,
      xpTotal: (json['xp_total'] as num?)?.toInt() ?? 0,
      xpIntoLevel: (json['xp_into_level'] as num?)?.toInt() ?? 0,
      xpToNextLevel: (json['xp_to_next_level'] as num?)?.toInt() ?? 500,
      levelProgressPercent:
          (json['level_progress_percent'] as num?)?.toInt() ?? 0,
    );
  }
}

class QuestStreak {
  final int current;
  final int longest;
  final double multiplier;
  final String? multiplierLabel;
  final int? nextBonusAt;
  final int totalXpEarned;
  final int totalCoinsEarned;
  final List<String> badges;

  const QuestStreak({
    required this.current,
    required this.longest,
    required this.multiplier,
    this.multiplierLabel,
    this.nextBonusAt,
    required this.totalXpEarned,
    required this.totalCoinsEarned,
    required this.badges,
  });

  factory QuestStreak.fromJson(Map<String, dynamic> json) {
    return QuestStreak(
      current: (json['current'] as num?)?.toInt() ?? 0,
      longest: (json['longest'] as num?)?.toInt() ?? 0,
      multiplier: (json['multiplier'] as num?)?.toDouble() ?? 1.0,
      multiplierLabel: json['multiplier_label'] as String?,
      nextBonusAt: (json['next_bonus_at'] as num?)?.toInt(),
      totalXpEarned: (json['total_xp_earned'] as num?)?.toInt() ?? 0,
      totalCoinsEarned: (json['total_coins_earned'] as num?)?.toInt() ?? 0,
      badges: (json['badges'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }
}

class QuestsData {
  final List<DailyQuest> quests;
  final QuestSummary summary;
  final QuestProfile profile;
  final QuestStreak streak;
  final int resetInSeconds;

  const QuestsData({
    required this.quests,
    required this.summary,
    required this.profile,
    required this.streak,
    required this.resetInSeconds,
  });

  factory QuestsData.fromJson(Map<String, dynamic> json) {
    return QuestsData(
      quests: ((json['quests'] as List?) ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(DailyQuest.fromJson)
          .toList(),
      summary: QuestSummary.fromJson(
        (json['summary'] as Map<String, dynamic>?) ?? const {},
      ),
      profile: QuestProfile.fromJson(
        (json['profile'] as Map<String, dynamic>?) ?? const {},
      ),
      streak: QuestStreak.fromJson(
        (json['streak'] as Map<String, dynamic>?) ?? const {},
      ),
      resetInSeconds: (json['reset_in_seconds'] as num?)?.toInt() ?? 0,
    );
  }

  QuestsData copyWith({
    List<DailyQuest>? quests,
    QuestSummary? summary,
    QuestProfile? profile,
    QuestStreak? streak,
  }) {
    return QuestsData(
      quests: quests ?? this.quests,
      summary: summary ?? this.summary,
      profile: profile ?? this.profile,
      streak: streak ?? this.streak,
      resetInSeconds: resetInSeconds,
    );
  }
}
