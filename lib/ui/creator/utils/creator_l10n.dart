// ============================================================================
// BRAWE CREATOR NETWORK — i18n helpers + tier ordering + visual presets
// ----------------------------------------------------------------------------
// Only adds .title(s)/.body(s) extensions for localization, plus tier visuals
// (.color/.gradient/.icon). ApplicationStatus already has .color/.icon defined
// in domain/models/creator_network.dart (ApplicationStatusX), so we don't
// redefine them here.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../domain/models/creator_network.dart';
import '../../../gen/l10n/app_localizations.dart';

/// Official tier order (highest → lowest).
const List<CreatorTier> kCreatorTiersOrder = <CreatorTier>[
  CreatorTier.founding,
  CreatorTier.ambassador,
  CreatorTier.live,
  CreatorTier.featured,
  CreatorTier.rising,
];

extension CreatorTierL10n on CreatorTier {
  String title(S s) {
    switch (this) {
      case CreatorTier.rising:
        return s.creatorTierRisingTitle;
      case CreatorTier.featured:
        return s.creatorTierFeaturedTitle;
      case CreatorTier.live:
        return s.creatorTierLiveTitle;
      case CreatorTier.ambassador:
        return s.creatorTierAmbassadorTitle;
      case CreatorTier.founding:
        return s.creatorTierFoundingTitle;
    }
  }

  String body(S s) {
    switch (this) {
      case CreatorTier.rising:
        return s.creatorTierRisingBody;
      case CreatorTier.featured:
        return s.creatorTierFeaturedBody;
      case CreatorTier.live:
        return s.creatorTierLiveBody;
      case CreatorTier.ambassador:
        return s.creatorTierAmbassadorBody;
      case CreatorTier.founding:
        return s.creatorTierFoundingBody;
    }
  }

  Color get color {
    switch (this) {
      case CreatorTier.rising:
        return const Color(0xFF60A5FA);
      case CreatorTier.featured:
        return const Color(0xFFA855F7);
      case CreatorTier.live:
        return const Color(0xFFEC4899);
      case CreatorTier.ambassador:
        return const Color(0xFFF59E0B);
      case CreatorTier.founding:
        return const Color(0xFFFACC15);
    }
  }

  List<Color> get gradient {
    switch (this) {
      case CreatorTier.rising:
        return const [Color(0xFF60A5FA), Color(0xFF3B82F6)];
      case CreatorTier.featured:
        return const [Color(0xFFA855F7), Color(0xFF7C3AED)];
      case CreatorTier.live:
        return const [Color(0xFFEC4899), Color(0xFFA855F7)];
      case CreatorTier.ambassador:
        return const [Color(0xFFF59E0B), Color(0xFFEF4444)];
      case CreatorTier.founding:
        return const [Color(0xFFFACC15), Color(0xFFF59E0B), Color(0xFFEC4899)];
    }
  }

  IconData get icon {
    switch (this) {
      case CreatorTier.rising:
        return Icons.trending_up_rounded;
      case CreatorTier.featured:
        return Icons.star_rounded;
      case CreatorTier.live:
        return Icons.live_tv_rounded;
      case CreatorTier.ambassador:
        return Icons.workspace_premium_rounded;
      case CreatorTier.founding:
        return Icons.diamond_rounded;
    }
  }
}

extension ApplicationStatusL10n on ApplicationStatus {
  String title(S s) {
    switch (this) {
      case ApplicationStatus.pendingReview:
        return s.creatorStatusPendingTitle;
      case ApplicationStatus.underAnalysis:
        return s.creatorStatusAnalysisTitle;
      case ApplicationStatus.needsMoreInfo:
        return s.creatorStatusNeedsInfoTitle;
      case ApplicationStatus.waitlist:
        return s.creatorStatusWaitlistTitle;
      case ApplicationStatus.invitedToAmbassador:
        return s.creatorStatusInvitedAmbassadorTitle;
      case ApplicationStatus.invitedToFoundingCreator:
        return s.creatorStatusInvitedFoundingTitle;
      case ApplicationStatus.approved:
        return s.creatorStatusApprovedTitle;
      case ApplicationStatus.rejected:
        return s.creatorStatusRejectedTitle;
    }
  }

  String body(S s) {
    switch (this) {
      case ApplicationStatus.pendingReview:
        return s.creatorStatusPendingBody;
      case ApplicationStatus.underAnalysis:
        return s.creatorStatusAnalysisBody;
      case ApplicationStatus.needsMoreInfo:
        return s.creatorStatusNeedsInfoBody;
      case ApplicationStatus.waitlist:
        return s.creatorStatusWaitlistBody;
      case ApplicationStatus.invitedToAmbassador:
        return s.creatorStatusInvitedAmbassadorBody;
      case ApplicationStatus.invitedToFoundingCreator:
        return s.creatorStatusInvitedFoundingBody;
      case ApplicationStatus.approved:
        return s.creatorStatusApprovedBody;
      case ApplicationStatus.rejected:
        return s.creatorStatusRejectedBody;
    }
  }
}

/// Rótulo traduzido e ícone Lucide de cada tipo de criador (nicho).
extension ContentNicheL10n on ContentNiche {
  String label(S s) {
    switch (this) {
      case ContentNiche.lifestyle:
        return s.creatorApplyNicheLifestyle;
      case ContentNiche.games:
        return s.creatorApplyNicheGames;
      case ContentNiche.music:
        return s.creatorApplyNicheMusic;
      case ContentNiche.fashion:
        return s.creatorApplyNicheFashion;
      case ContentNiche.beauty:
        return s.creatorApplyNicheBeauty;
      case ContentNiche.fitness:
        return s.creatorApplyNicheFitness;
      case ContentNiche.comedy:
        return s.creatorApplyNicheComedy;
      case ContentNiche.business:
        return s.creatorApplyNicheBusiness;
      case ContentNiche.tech:
        return s.creatorApplyNicheTech;
      case ContentNiche.education:
        return s.creatorApplyNicheEducation;
      case ContentNiche.travel:
        return s.creatorApplyNicheTravel;
      case ContentNiche.entertainment:
        return s.creatorApplyNicheEntertainment;
      case ContentNiche.sports:
        return s.creatorApplyNicheSports;
      case ContentNiche.cooking:
        return s.creatorApplyNicheCooking;
      case ContentNiche.other:
        return s.creatorApplyNicheOther;
    }
  }

  IconData get lucide {
    switch (this) {
      case ContentNiche.lifestyle:
        return LucideIcons.coffee;
      case ContentNiche.games:
        return LucideIcons.gamepad2;
      case ContentNiche.music:
        return LucideIcons.music;
      case ContentNiche.fashion:
        return LucideIcons.shirt;
      case ContentNiche.beauty:
        return LucideIcons.sparkles;
      case ContentNiche.fitness:
        return LucideIcons.dumbbell;
      case ContentNiche.comedy:
        return LucideIcons.laugh;
      case ContentNiche.business:
        return LucideIcons.briefcase;
      case ContentNiche.tech:
        return LucideIcons.cpu;
      case ContentNiche.education:
        return LucideIcons.graduationCap;
      case ContentNiche.travel:
        return LucideIcons.plane;
      case ContentNiche.entertainment:
        return LucideIcons.clapperboard;
      case ContentNiche.sports:
        return LucideIcons.trophy;
      case ContentNiche.cooking:
        return LucideIcons.chefHat;
      case ContentNiche.other:
        return LucideIcons.shapes;
    }
  }
}
