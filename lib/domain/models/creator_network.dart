// ============================================================================
// BRAWE CREATOR NETWORK — Domain models
// ============================================================================

import 'package:flutter/material.dart';

enum CreatorTier { rising, featured, live, ambassador, founding }

CreatorTier? creatorTierFromString(String? s) {
  switch (s) {
    case 'rising':
      return CreatorTier.rising;
    case 'featured':
      return CreatorTier.featured;
    case 'live':
      return CreatorTier.live;
    case 'ambassador':
      return CreatorTier.ambassador;
    case 'founding':
      return CreatorTier.founding;
  }
  return null;
}

String creatorTierToString(CreatorTier t) => t.name;

enum ApplicationStatus {
  pendingReview,
  underAnalysis,
  approved,
  rejected,
  waitlist,
  invitedToAmbassador,
  invitedToFoundingCreator,
  needsMoreInfo,
}

ApplicationStatus? applicationStatusFromString(String? s) {
  switch (s) {
    case 'pending_review':
      return ApplicationStatus.pendingReview;
    case 'under_analysis':
      return ApplicationStatus.underAnalysis;
    case 'approved':
      return ApplicationStatus.approved;
    case 'rejected':
      return ApplicationStatus.rejected;
    case 'waitlist':
      return ApplicationStatus.waitlist;
    case 'invited_to_ambassador':
      return ApplicationStatus.invitedToAmbassador;
    case 'invited_to_founding_creator':
      return ApplicationStatus.invitedToFoundingCreator;
    case 'needs_more_info':
      return ApplicationStatus.needsMoreInfo;
  }
  return null;
}

enum ContentNiche {
  lifestyle,
  games,
  music,
  fashion,
  beauty,
  fitness,
  comedy,
  business,
  tech,
  education,
  travel,
  entertainment,
  sports,
  cooking,
  other,
}

extension ContentNicheX on ContentNiche {
  String get apiValue => name;
}

// ────────────────────────────────────────────────────────────────
// Priority + Status helpers
// ────────────────────────────────────────────────────────────────
enum ApplicationPriority { normal, high, urgent }

ApplicationPriority applicationPriorityFromString(String? s) {
  switch (s) {
    case 'high':
      return ApplicationPriority.high;
    case 'urgent':
      return ApplicationPriority.urgent;
    default:
      return ApplicationPriority.normal;
  }
}

extension CreatorTierX on CreatorTier {
  String get apiValue => name;

  /// Cor temática do tier (usada em chips/badges/gradients).
  Color get color {
    switch (this) {
      case CreatorTier.rising:
        return const Color(0xFF22D3EE); // cyan
      case CreatorTier.featured:
        return const Color(0xFFA855F7); // purple
      case CreatorTier.live:
        return const Color(0xFFEF4444); // red (live)
      case CreatorTier.ambassador:
        return const Color(0xFFF59E0B); // amber
      case CreatorTier.founding:
        return const Color(0xFFFFD700); // gold
    }
  }

  /// Gradiente premium do tier (header/cards aspiracionais).
  List<Color> get gradient {
    switch (this) {
      case CreatorTier.rising:
        return const [Color(0xFF22D3EE), Color(0xFF3B82F6)];
      case CreatorTier.featured:
        return const [Color(0xFFA855F7), Color(0xFF6366F1)];
      case CreatorTier.live:
        return const [Color(0xFFEF4444), Color(0xFFEC4899)];
      case CreatorTier.ambassador:
        return const [Color(0xFFF59E0B), Color(0xFFEF4444)];
      case CreatorTier.founding:
        return const [Color(0xFFFFD700), Color(0xFFFF6B35)];
    }
  }

  IconData get icon {
    switch (this) {
      case CreatorTier.rising:
        return Icons.trending_up_rounded;
      case CreatorTier.featured:
        return Icons.workspace_premium_rounded;
      case CreatorTier.live:
        return Icons.podcasts_rounded;
      case CreatorTier.ambassador:
        return Icons.verified_rounded;
      case CreatorTier.founding:
        return Icons.diamond_rounded;
    }
  }

  String get badgeSlug {
    switch (this) {
      case CreatorTier.rising:
        return 'rising_creator';
      case CreatorTier.featured:
        return 'featured_creator';
      case CreatorTier.live:
        return 'live_creator';
      case CreatorTier.ambassador:
        return 'ambassador';
      case CreatorTier.founding:
        return 'founding_creator';
    }
  }
}

extension ApplicationStatusX on ApplicationStatus {
  String get apiValue {
    switch (this) {
      case ApplicationStatus.pendingReview:
        return 'pending_review';
      case ApplicationStatus.underAnalysis:
        return 'under_analysis';
      case ApplicationStatus.approved:
        return 'approved';
      case ApplicationStatus.rejected:
        return 'rejected';
      case ApplicationStatus.waitlist:
        return 'waitlist';
      case ApplicationStatus.invitedToAmbassador:
        return 'invited_to_ambassador';
      case ApplicationStatus.invitedToFoundingCreator:
        return 'invited_to_founding_creator';
      case ApplicationStatus.needsMoreInfo:
        return 'needs_more_info';
    }
  }

  bool get isTerminal =>
      this == ApplicationStatus.approved ||
      this == ApplicationStatus.rejected;

  bool get isPositive =>
      this == ApplicationStatus.approved ||
      this == ApplicationStatus.invitedToAmbassador ||
      this == ApplicationStatus.invitedToFoundingCreator;

  bool get needsAction => this == ApplicationStatus.needsMoreInfo;

  Color get color {
    switch (this) {
      case ApplicationStatus.pendingReview:
      case ApplicationStatus.underAnalysis:
        return const Color(0xFF60A5FA); // blue
      case ApplicationStatus.approved:
      case ApplicationStatus.invitedToAmbassador:
      case ApplicationStatus.invitedToFoundingCreator:
        return const Color(0xFF22C55E); // green
      case ApplicationStatus.rejected:
        return const Color(0xFFEF4444); // red
      case ApplicationStatus.waitlist:
        return const Color(0xFFA855F7); // purple
      case ApplicationStatus.needsMoreInfo:
        return const Color(0xFFF59E0B); // amber
    }
  }

  IconData get icon {
    switch (this) {
      case ApplicationStatus.pendingReview:
        return Icons.hourglass_top_rounded;
      case ApplicationStatus.underAnalysis:
        return Icons.search_rounded;
      case ApplicationStatus.approved:
        return Icons.check_circle_rounded;
      case ApplicationStatus.rejected:
        return Icons.cancel_rounded;
      case ApplicationStatus.waitlist:
        return Icons.bookmark_rounded;
      case ApplicationStatus.invitedToAmbassador:
        return Icons.verified_rounded;
      case ApplicationStatus.invitedToFoundingCreator:
        return Icons.diamond_rounded;
      case ApplicationStatus.needsMoreInfo:
        return Icons.help_outline_rounded;
    }
  }
}

extension ApplicationPriorityX on ApplicationPriority {
  String get apiValue => name;
  Color get color {
    switch (this) {
      case ApplicationPriority.normal:
        return const Color(0xFF94A3B8);
      case ApplicationPriority.high:
        return const Color(0xFFF59E0B);
      case ApplicationPriority.urgent:
        return const Color(0xFFEF4444);
    }
  }
}

class SocialLinks {
  final String? instagram;
  final String? tiktok;
  final String? youtube;
  final String? twitter;
  final String? twitch;
  final String? website;
  const SocialLinks({
    this.instagram,
    this.tiktok,
    this.youtube,
    this.twitter,
    this.twitch,
    this.website,
  });

  factory SocialLinks.fromJson(Map<String, dynamic> j) => SocialLinks(
        instagram: j['instagram']?.toString(),
        tiktok: j['tiktok']?.toString(),
        youtube: j['youtube']?.toString(),
        twitter: j['twitter']?.toString(),
        twitch: j['twitch']?.toString(),
        website: j['website']?.toString(),
      );

  Map<String, dynamic> toJson() => {
        if (instagram != null && instagram!.isNotEmpty) 'instagram': instagram,
        if (tiktok != null && tiktok!.isNotEmpty) 'tiktok': tiktok,
        if (youtube != null && youtube!.isNotEmpty) 'youtube': youtube,
        if (twitter != null && twitter!.isNotEmpty) 'twitter': twitter,
        if (twitch != null && twitch!.isNotEmpty) 'twitch': twitch,
        if (website != null && website!.isNotEmpty) 'website': website,
      };

  bool get hasAny =>
      [instagram, tiktok, youtube, twitter, twitch, website]
          .any((e) => e != null && e.isNotEmpty);
}

// ────────────────────────────────────────────────────────────────
class CreatorApplication {
  final String id;
  final String fullName;
  final String username;
  final String email;
  final String? phone;
  final String country;
  final String? city;
  final String language;
  final ContentNiche niche;
  final CreatorTier? requestedTier;
  final CreatorTier? suggestedTier;
  final SocialLinks socialLinks;
  final int followersCount;
  final bool doesLive;
  final String? bio;
  final String? motivation;
  final String? goals;
  final String? portfolioUrl;
  final ApplicationStatus status;
  final ApplicationPriority priority;
  final int? classifierScore;
  final String? rejectionReason;
  final DateTime? reviewedAt;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const CreatorApplication({
    required this.id,
    required this.fullName,
    required this.username,
    required this.email,
    this.phone,
    required this.country,
    this.city,
    required this.language,
    required this.niche,
    this.requestedTier,
    this.suggestedTier,
    this.socialLinks = const SocialLinks(),
    required this.followersCount,
    required this.doesLive,
    this.bio,
    this.motivation,
    this.goals,
    this.portfolioUrl,
    required this.status,
    this.priority = ApplicationPriority.normal,
    this.classifierScore,
    this.rejectionReason,
    this.reviewedAt,
    required this.createdAt,
    this.updatedAt,
  });

  factory CreatorApplication.fromJson(Map<String, dynamic> j) {
    return CreatorApplication(
      id: (j['id'] ?? '').toString(),
      fullName: (j['full_name'] ?? '').toString(),
      username: (j['username'] ?? '').toString(),
      email: (j['email'] ?? '').toString(),
      phone: j['phone']?.toString(),
      country: (j['country'] ?? '').toString(),
      city: j['city']?.toString(),
      language: (j['language'] ?? 'pt').toString(),
      niche: ContentNiche.values.firstWhere(
        (e) => e.name == j['niche'],
        orElse: () => ContentNiche.other,
      ),
      requestedTier: creatorTierFromString(j['requested_tier']?.toString()),
      suggestedTier: creatorTierFromString(j['suggested_tier']?.toString()),
      socialLinks: SocialLinks.fromJson(
        (j['social_links'] as Map?)?.cast<String, dynamic>() ?? const {},
      ),
      followersCount: (j['followers_count'] as num?)?.toInt() ?? 0,
      doesLive: j['does_live'] == true,
      bio: j['bio']?.toString(),
      motivation: j['motivation']?.toString(),
      goals: j['goals']?.toString(),
      portfolioUrl: j['portfolio_url']?.toString(),
      status: applicationStatusFromString(j['status']?.toString()) ??
          ApplicationStatus.pendingReview,
      priority: applicationPriorityFromString(j['priority']?.toString()),
      classifierScore: (j['classifier_score'] as num?)?.toInt(),
      rejectionReason: j['rejection_reason']?.toString(),
      reviewedAt: DateTime.tryParse((j['reviewed_at'] ?? '').toString()),
      createdAt: DateTime.tryParse((j['created_at'] ?? '').toString()) ??
          DateTime.now(),
      updatedAt: DateTime.tryParse((j['updated_at'] ?? '').toString()),
    );
  }
}

// ────────────────────────────────────────────────────────────────
class CreatorBadge {
  final String badgeType;
  final bool active;
  final DateTime grantedAt;
  const CreatorBadge({
    required this.badgeType,
    required this.active,
    required this.grantedAt,
  });
  factory CreatorBadge.fromJson(Map<String, dynamic> j) => CreatorBadge(
        badgeType: (j['badge_type'] ?? '').toString(),
        active: j['active'] == true,
        grantedAt:
            DateTime.tryParse((j['granted_at'] ?? '').toString()) ?? DateTime.now(),
      );
}

class CreatorProfile {
  final String id;
  final String userId;
  final CreatorTier tier;
  final String primaryBadge;
  final bool isFeatured;
  final bool isAmbassador;
  final bool isFoundingCreator;
  final DateTime approvedAt;
  final List<CreatorBadge> badges;

  const CreatorProfile({
    required this.id,
    required this.userId,
    required this.tier,
    required this.primaryBadge,
    required this.isFeatured,
    required this.isAmbassador,
    required this.isFoundingCreator,
    required this.approvedAt,
    this.badges = const [],
  });

  factory CreatorProfile.fromJson(Map<String, dynamic> j) => CreatorProfile(
        id: (j['id'] ?? '').toString(),
        userId: (j['user_id'] ?? '').toString(),
        tier: creatorTierFromString(j['creator_tier']?.toString()) ??
            CreatorTier.rising,
        primaryBadge: (j['primary_badge'] ?? '').toString(),
        isFeatured: j['is_featured'] == true,
        isAmbassador: j['is_ambassador'] == true,
        isFoundingCreator: j['is_founding_creator'] == true,
        approvedAt:
            DateTime.tryParse((j['approved_at'] ?? '').toString()) ?? DateTime.now(),
        badges: (j['badges'] as List? ?? [])
            .whereType<Map<String, dynamic>>()
            .map(CreatorBadge.fromJson)
            .toList(),
      );
}

// ────────────────────────────────────────────────────────────────
class NetworkTierInfo {
  final CreatorTier slug;
  final String name;
  final String description;
  final List<String> perks;
  const NetworkTierInfo({
    required this.slug,
    required this.name,
    required this.description,
    required this.perks,
  });
  factory NetworkTierInfo.fromJson(Map<String, dynamic> j) => NetworkTierInfo(
        slug: creatorTierFromString(j['slug']?.toString()) ?? CreatorTier.rising,
        name: (j['name'] ?? '').toString(),
        description: (j['description'] ?? '').toString(),
        perks: (j['perks'] as List? ?? []).map((e) => e.toString()).toList(),
      );
}

class NetworkOverview {
  final List<NetworkTierInfo> tiers;
  final int totalCreators;
  final List<String> benefits;
  const NetworkOverview({
    required this.tiers,
    required this.totalCreators,
    required this.benefits,
  });
  factory NetworkOverview.fromJson(Map<String, dynamic> j) => NetworkOverview(
        tiers: (j['tiers'] as List? ?? [])
            .whereType<Map<String, dynamic>>()
            .map(NetworkTierInfo.fromJson)
            .toList(),
        totalCreators: (j['total_creators'] as num?)?.toInt() ?? 0,
        benefits: (j['benefits'] as List? ?? []).map((e) => e.toString()).toList(),
      );
}

// ────────────────────────────────────────────────────────────────
class OnboardingStep {
  final String key;
  final String title;
  final String description;
  final bool completed;
  const OnboardingStep({
    required this.key,
    required this.title,
    required this.description,
    required this.completed,
  });
  factory OnboardingStep.fromJson(Map<String, dynamic> j) => OnboardingStep(
        key: (j['key'] ?? '').toString(),
        title: (j['title'] ?? '').toString(),
        description: (j['description'] ?? '').toString(),
        completed: j['completed'] == true,
      );
}

class OnboardingChecklist {
  final int progress;
  final List<OnboardingStep> steps;
  const OnboardingChecklist({required this.progress, required this.steps});
  factory OnboardingChecklist.fromJson(Map<String, dynamic> j) =>
      OnboardingChecklist(
        progress: (j['progress'] as num?)?.toInt() ?? 0,
        steps: (j['steps'] as List? ?? [])
            .whereType<Map<String, dynamic>>()
            .map(OnboardingStep.fromJson)
            .toList(),
      );
}

// ────────────────────────────────────────────────────────────────
// ADMIN models
// ────────────────────────────────────────────────────────────────
class AdminApplicationListItem {
  final String id;
  final String userId;
  final String fullName;
  final String username;
  final String country;
  final ContentNiche niche;
  final CreatorTier? suggestedTier;
  final CreatorTier? requestedTier;
  final ApplicationStatus status;
  final ApplicationPriority priority;
  final int followersCount;
  final int? classifierScore;
  final DateTime createdAt;

  const AdminApplicationListItem({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.username,
    required this.country,
    required this.niche,
    this.suggestedTier,
    this.requestedTier,
    required this.status,
    required this.priority,
    required this.followersCount,
    this.classifierScore,
    required this.createdAt,
  });

  factory AdminApplicationListItem.fromJson(Map<String, dynamic> j) =>
      AdminApplicationListItem(
        id: (j['id'] ?? '').toString(),
        userId: (j['user_id'] ?? '').toString(),
        fullName: (j['full_name'] ?? '').toString(),
        username: (j['username'] ?? '').toString(),
        country: (j['country'] ?? '').toString(),
        niche: ContentNiche.values.firstWhere(
          (e) => e.name == j['niche'],
          orElse: () => ContentNiche.other,
        ),
        suggestedTier: creatorTierFromString(j['suggested_tier']?.toString()),
        requestedTier: creatorTierFromString(j['requested_tier']?.toString()),
        status: applicationStatusFromString(j['status']?.toString()) ??
            ApplicationStatus.pendingReview,
        priority: applicationPriorityFromString(j['priority']?.toString()),
        followersCount: (j['followers_count'] as num?)?.toInt() ?? 0,
        classifierScore: (j['classifier_score'] as num?)?.toInt(),
        createdAt: DateTime.tryParse((j['created_at'] ?? '').toString()) ??
            DateTime.now(),
      );
}

class PaginatedApplications {
  final int total;
  final int page;
  final int limit;
  final List<AdminApplicationListItem> items;
  const PaginatedApplications({
    required this.total,
    required this.page,
    required this.limit,
    required this.items,
  });

  bool get hasMore => page * limit < total;

  factory PaginatedApplications.fromJson(Map<String, dynamic> j) =>
      PaginatedApplications(
        total: (j['total'] as num?)?.toInt() ?? 0,
        page: (j['page'] as num?)?.toInt() ?? 1,
        limit: (j['limit'] as num?)?.toInt() ?? 20,
        items: (j['items'] as List? ?? [])
            .whereType<Map<String, dynamic>>()
            .map(AdminApplicationListItem.fromJson)
            .toList(),
      );
}

/// Filtros usados na listagem admin.
class AdminApplicationFilter {
  final ApplicationStatus? status;
  final CreatorTier? tier;
  final ContentNiche? niche;
  final String? country;
  final ApplicationPriority? priority;
  final int? minFollowers;
  final String? search;
  final int page;
  final int limit;

  const AdminApplicationFilter({
    this.status,
    this.tier,
    this.niche,
    this.country,
    this.priority,
    this.minFollowers,
    this.search,
    this.page = 1,
    this.limit = 20,
  });

  Map<String, dynamic> toQuery() => {
        if (status != null) 'status': status!.apiValue,
        if (tier != null) 'tier': tier!.apiValue,
        if (niche != null) 'niche': niche!.apiValue,
        if (country != null && country!.isNotEmpty) 'country': country,
        if (priority != null) 'priority': priority!.apiValue,
        if (minFollowers != null) 'min_followers': minFollowers,
        if (search != null && search!.isNotEmpty) 'search': search,
        'page': page,
        'limit': limit,
      };

  AdminApplicationFilter copyWith({
    Object? status = _undef,
    Object? tier = _undef,
    Object? niche = _undef,
    Object? country = _undef,
    Object? priority = _undef,
    Object? minFollowers = _undef,
    Object? search = _undef,
    int? page,
    int? limit,
  }) =>
      AdminApplicationFilter(
        status: status == _undef ? this.status : status as ApplicationStatus?,
        tier: tier == _undef ? this.tier : tier as CreatorTier?,
        niche: niche == _undef ? this.niche : niche as ContentNiche?,
        country: country == _undef ? this.country : country as String?,
        priority: priority == _undef
            ? this.priority
            : priority as ApplicationPriority?,
        minFollowers: minFollowers == _undef
            ? this.minFollowers
            : minFollowers as int?,
        search: search == _undef ? this.search : search as String?,
        page: page ?? this.page,
        limit: limit ?? this.limit,
      );
}

const Object _undef = Object();

/// Payload pra POST /admin/creator/applications/{id}/review
class AdminReviewRequest {
  final ApplicationStatus decision;
  final CreatorTier? assignedTier;
  final String? internalNotes;
  final String? rejectionReason;

  const AdminReviewRequest({
    required this.decision,
    this.assignedTier,
    this.internalNotes,
    this.rejectionReason,
  });

  Map<String, dynamic> toJson() => {
        'decision': decision.apiValue,
        if (assignedTier != null) 'assigned_tier': assignedTier!.apiValue,
        if (internalNotes != null && internalNotes!.isNotEmpty)
          'internal_notes': internalNotes,
        if (rejectionReason != null && rejectionReason!.isNotEmpty)
          'rejection_reason': rejectionReason,
      };
}

/// Payload pra PATCH /admin/creator/applications/{id}
class AdminUpdateApplication {
  final ApplicationPriority? priority;
  final String? internalNotes;
  final CreatorTier? suggestedTier;

  const AdminUpdateApplication({
    this.priority,
    this.internalNotes,
    this.suggestedTier,
  });

  Map<String, dynamic> toJson() => {
        if (priority != null) 'priority': priority!.apiValue,
        if (internalNotes != null) 'internal_notes': internalNotes,
        if (suggestedTier != null) 'suggested_tier': suggestedTier!.apiValue,
      };
}
