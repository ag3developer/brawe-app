// ============================================================================
// BRAWE CREATOR NETWORK — Jornada do criador
// GET /creator/network/me/journey
// ============================================================================

import 'creator_network.dart';

enum JourneyLevelStatus { achieved, current, next, locked }

class JourneyLevel {
  final CreatorTier tier;
  final JourneyLevelStatus status;
  final DateTime? achievedAt;
  final bool inviteOnly;
  const JourneyLevel({
    required this.tier,
    required this.status,
    required this.achievedAt,
    required this.inviteOnly,
  });

  factory JourneyLevel.fromJson(Map<String, dynamic> j) => JourneyLevel(
        tier: creatorTierFromString(j['tier']?.toString()) ?? CreatorTier.rising,
        status: switch (j['status']) {
          'achieved' => JourneyLevelStatus.achieved,
          'current' => JourneyLevelStatus.current,
          'next' => JourneyLevelStatus.next,
          _ => JourneyLevelStatus.locked,
        },
        achievedAt: DateTime.tryParse('${j['achieved_at'] ?? ''}')?.toLocal(),
        inviteOnly: j['invite_only'] == true,
      );
}

class JourneyBadge {
  final String badgeType;
  final CreatorTier? tier;
  final bool active;
  final DateTime? grantedAt;
  const JourneyBadge({
    required this.badgeType,
    required this.tier,
    required this.active,
    required this.grantedAt,
  });

  factory JourneyBadge.fromJson(Map<String, dynamic> j) => JourneyBadge(
        badgeType: '${j['badge_type'] ?? ''}',
        tier: creatorTierFromString(j['tier']?.toString()),
        active: j['active'] == true,
        grantedAt: DateTime.tryParse('${j['granted_at'] ?? ''}')?.toLocal(),
      );
}

class JourneyGoal {
  /// followers | lives | live_minutes | posts | gift_credits | active_days
  final String metric;
  final int current;
  final int target;
  final double progress;
  final int remaining;
  final bool done;
  const JourneyGoal({
    required this.metric,
    required this.current,
    required this.target,
    required this.progress,
    required this.remaining,
    required this.done,
  });

  factory JourneyGoal.fromJson(Map<String, dynamic> j) => JourneyGoal(
        metric: '${j['metric'] ?? ''}',
        current: (j['current'] as num?)?.toInt() ?? 0,
        target: (j['target'] as num?)?.toInt() ?? 0,
        progress: (j['progress'] as num?)?.toDouble() ?? 0,
        remaining: (j['remaining'] as num?)?.toInt() ?? 0,
        done: j['done'] == true,
      );
}

enum JourneyTrend { up, down, flat }

class JourneyWeekMetric {
  /// followers | viewers | lives | live_minutes | posts | gift_credits
  final String metric;
  final int current;
  final int previous;
  final int delta;
  final JourneyTrend trend;
  const JourneyWeekMetric({
    required this.metric,
    required this.current,
    required this.previous,
    required this.delta,
    required this.trend,
  });

  factory JourneyWeekMetric.fromJson(Map<String, dynamic> j) =>
      JourneyWeekMetric(
        metric: '${j['metric'] ?? ''}',
        current: (j['current'] as num?)?.toInt() ?? 0,
        previous: (j['previous'] as num?)?.toInt() ?? 0,
        delta: (j['delta'] as num?)?.toInt() ?? 0,
        trend: switch (j['trend']) {
          'up' => JourneyTrend.up,
          'down' => JourneyTrend.down,
          _ => JourneyTrend.flat,
        },
      );
}

class JourneyBenefit {
  final String key;
  final CreatorTier tier;
  final bool unlocked;
  const JourneyBenefit({
    required this.key,
    required this.tier,
    required this.unlocked,
  });

  factory JourneyBenefit.fromJson(Map<String, dynamic> j) => JourneyBenefit(
        key: '${j['key'] ?? ''}',
        tier: creatorTierFromString(j['tier']?.toString()) ?? CreatorTier.rising,
        unlocked: j['unlocked'] == true,
      );
}

class CreatorJourney {
  final CreatorTier currentTier;
  final DateTime creatorSince;
  final int activeDays;
  final CreatorTier? nextTier;
  final bool nextTierInviteOnly;

  /// 0..1; null quando o próximo nível é por convite ou não existe.
  final double? overallProgress;
  final List<JourneyLevel> levels;
  final List<JourneyBadge> badges;
  final List<JourneyGoal> goals;
  final List<JourneyWeekMetric> week;
  final List<JourneyBenefit> benefits;

  const CreatorJourney({
    required this.currentTier,
    required this.creatorSince,
    required this.activeDays,
    required this.nextTier,
    required this.nextTierInviteOnly,
    required this.overallProgress,
    required this.levels,
    required this.badges,
    required this.goals,
    required this.week,
    required this.benefits,
  });

  bool get allGoalsDone => goals.isNotEmpty && goals.every((g) => g.done);

  List<JourneyBenefit> get activeBenefits =>
      benefits.where((b) => b.unlocked).toList();

  /// Benefícios do próximo nível (bloqueados).
  List<JourneyBenefit> get nextBenefits =>
      benefits.where((b) => !b.unlocked && b.tier == nextTier).toList();

  /// Data de conquista de um nível (ou null).
  DateTime? achievedAt(CreatorTier t) {
    for (final l in levels) {
      if (l.tier == t) return l.achievedAt;
    }
    return null;
  }

  factory CreatorJourney.fromJson(Map<String, dynamic> j) {
    List<T> list<T>(String k, T Function(Map<String, dynamic>) f) =>
        (j[k] as List? ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(f)
            .toList();
    final week = j['week'] as Map<String, dynamic>? ?? const {};
    return CreatorJourney(
      currentTier:
          creatorTierFromString(j['current_tier']?.toString()) ??
              CreatorTier.rising,
      creatorSince:
          DateTime.tryParse('${j['creator_since'] ?? ''}')?.toLocal() ??
              DateTime.now(),
      activeDays: (j['active_days'] as num?)?.toInt() ?? 0,
      nextTier: creatorTierFromString(j['next_tier']?.toString()),
      nextTierInviteOnly: j['next_tier_invite_only'] == true,
      overallProgress: (j['overall_progress'] as num?)?.toDouble(),
      levels: list('levels', JourneyLevel.fromJson),
      badges: list('badges', JourneyBadge.fromJson),
      goals: list('goals', JourneyGoal.fromJson),
      benefits: list('benefits', JourneyBenefit.fromJson),
      week: (week['metrics'] as List? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(JourneyWeekMetric.fromJson)
          .toList(),
    );
  }
}
