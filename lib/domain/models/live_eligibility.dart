// ============================================================================
// BRAWE LIVE — Eligibility model
// ============================================================================

/// Resultado de GET /v1/live/eligibility.
class LiveEligibility {
  final bool canGoLive;
  final String code; // 'ok' | 'profile_incomplete' | 'creator_required'
  final String message;
  final List<String> missing; // 'avatar' and/or 'creator_program'
  final bool hasAvatar;
  final bool isCreator;
  final String? creatorTier; // 'rising' | 'featured' | ... | null

  const LiveEligibility({
    required this.canGoLive,
    required this.code,
    required this.message,
    required this.missing,
    required this.hasAvatar,
    required this.isCreator,
    this.creatorTier,
  });

  bool get needsAvatar => missing.contains('avatar');
  bool get needsCreator => missing.contains('creator_program');

  factory LiveEligibility.fromJson(Map<String, dynamic> j) => LiveEligibility(
        canGoLive: j['can_go_live'] == true,
        code: (j['code'] ?? 'ok').toString(),
        message: (j['message'] ?? '').toString(),
        missing: (j['missing'] as List?)?.cast<String>() ?? const [],
        hasAvatar: j['has_avatar'] == true,
        isCreator: j['is_creator'] == true,
        creatorTier: j['creator_tier'] as String?,
      );
}
