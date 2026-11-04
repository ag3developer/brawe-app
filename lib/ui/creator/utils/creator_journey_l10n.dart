// ============================================================================
// BRAWE CREATOR NETWORK — textos e ícones da jornada (metas, semana,
// benefícios e badges). Nenhuma chave crua do backend chega à tela.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../domain/models/creator_network.dart';
import '../../../gen/l10n/app_localizations.dart';
import 'creator_l10n.dart';

/// Métrica (meta ou semana) → rótulo, ícone, cor e frase do que falta.
class JourneyMetricInfo {
  const JourneyMetricInfo(this.icon, this.color);
  final IconData icon;
  final Color color;

  static JourneyMetricInfo of(String metric) {
    switch (metric) {
      case 'followers':
        return const JourneyMetricInfo(LucideIcons.users, Color(0xFF3B82F6));
      case 'lives':
        return const JourneyMetricInfo(LucideIcons.radio, Color(0xFFEC4899));
      case 'live_minutes':
        return const JourneyMetricInfo(LucideIcons.clock, Color(0xFFA855F7));
      case 'posts':
        return const JourneyMetricInfo(LucideIcons.squarePen, Color(0xFF10B981));
      case 'gift_credits':
        return const JourneyMetricInfo(LucideIcons.gift, Color(0xFFF59E0B));
      case 'active_days':
        return const JourneyMetricInfo(LucideIcons.calendarDays, Color(0xFF06B6D4));
      case 'viewers':
        return const JourneyMetricInfo(LucideIcons.eye, Color(0xFF6366F1));
      default:
        return const JourneyMetricInfo(LucideIcons.star, Color(0xFF94A3B8));
    }
  }
}

String journeyMetricLabel(S s, String metric, {bool week = false}) {
  switch (metric) {
    case 'followers':
      return week ? s.creatorDashWeekNewFollowers : s.creatorJourneyMetricFollowers;
    case 'lives':
      return s.creatorJourneyMetricLives;
    case 'live_minutes':
      return s.creatorJourneyMetricLiveMinutes;
    case 'posts':
      return s.creatorJourneyMetricPosts;
    case 'gift_credits':
      return s.creatorJourneyMetricGiftCredits;
    case 'active_days':
      return s.creatorJourneyMetricActiveDays;
    case 'viewers':
      return s.creatorJourneyMetricViewers;
    default:
      return metric;
  }
}

/// "Faltam 12 seguidores" etc.
String journeyRemaining(S s, String metric, int n) {
  switch (metric) {
    case 'followers':
      return s.creatorJourneyRemainingFollowers(n);
    case 'lives':
      return s.creatorJourneyRemainingLives(n);
    case 'live_minutes':
      return s.creatorJourneyRemainingLiveMinutes(n);
    case 'posts':
      return s.creatorJourneyRemainingPosts(n);
    case 'gift_credits':
      return s.creatorJourneyRemainingGiftCredits(n);
    case 'active_days':
      return s.creatorJourneyRemainingActiveDays(n);
    default:
      return '$n';
  }
}

/// Rota da tela de análise ligada à métrica (ou null).
String? journeyMetricRoute(String metric) {
  switch (metric) {
    case 'followers':
      return '/creator/analytics?tab=followers';
    case 'viewers':
      return '/creator/analytics?tab=audience';
    case 'lives':
    case 'live_minutes':
      return '/creator/analytics?tab=lives';
    case 'gift_credits':
    case 'posts':
      return '/creator/analytics?tab=earnings';
    default:
      return null;
  }
}

/// 12345 → "12,3k".
String journeyCompact(int n) {
  if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
  if (n >= 10000) return '${(n / 1000).toStringAsFixed(1)}k';
  return '$n';
}

String journeyMonthYear(BuildContext context, DateTime d) =>
    DateFormat.yMMMM(Localizations.localeOf(context).toLanguageTag()).format(d);

String journeyFullDate(BuildContext context, DateTime d) =>
    DateFormat.yMMMMd(Localizations.localeOf(context).toLanguageTag()).format(d);

/// Nome traduzido do badge (`rising_creator` → "Rising Creator").
String journeyBadgeName(S s, String badgeType) {
  switch (badgeType) {
    case 'rising_creator':
      return CreatorTier.rising.title(s);
    case 'featured_creator':
      return CreatorTier.featured.title(s);
    case 'live_creator':
      return CreatorTier.live.title(s);
    case 'ambassador':
      return CreatorTier.ambassador.title(s);
    case 'founding_creator':
      return CreatorTier.founding.title(s);
    default:
      return s.creatorJourneyBadgeGeneric;
  }
}

/// Título/descrição/ícone de cada benefício (chave vem do backend).
class JourneyBenefitText {
  const JourneyBenefitText(this.title, this.desc, this.icon);
  final String title;
  final String desc;
  final IconData icon;
}

JourneyBenefitText journeyBenefit(S s, String key) {
  switch (key) {
    case 'rising_badge':
      return JourneyBenefitText(s.creatorJourneyBenefitRisingBadgeTitle,
          s.creatorJourneyBenefitRisingBadgeDesc, LucideIcons.badgeCheck);
    case 'creator_profile':
      return JourneyBenefitText(s.creatorJourneyBenefitCreatorProfileTitle,
          s.creatorJourneyBenefitCreatorProfileDesc, LucideIcons.userRound);
    case 'discovery_suggestions':
      return JourneyBenefitText(
          s.creatorJourneyBenefitDiscoverySuggestionsTitle,
          s.creatorJourneyBenefitDiscoverySuggestionsDesc,
          LucideIcons.compass);
    case 'analytics':
      return JourneyBenefitText(s.creatorJourneyBenefitAnalyticsTitle,
          s.creatorJourneyBenefitAnalyticsDesc, LucideIcons.chartColumn);
    case 'featured_badge':
      return JourneyBenefitText(s.creatorJourneyBenefitFeaturedBadgeTitle,
          s.creatorJourneyBenefitFeaturedBadgeDesc, LucideIcons.star);
    case 'editorial_highlight':
      return JourneyBenefitText(s.creatorJourneyBenefitEditorialHighlightTitle,
          s.creatorJourneyBenefitEditorialHighlightDesc, LucideIcons.newspaper);
    case 'more_reach':
      return JourneyBenefitText(s.creatorJourneyBenefitMoreReachTitle,
          s.creatorJourneyBenefitMoreReachDesc, LucideIcons.megaphone);
    case 'live_badge':
      return JourneyBenefitText(s.creatorJourneyBenefitLiveBadgeTitle,
          s.creatorJourneyBenefitLiveBadgeDesc, LucideIcons.radio);
    case 'advanced_live':
      return JourneyBenefitText(s.creatorJourneyBenefitAdvancedLiveTitle,
          s.creatorJourneyBenefitAdvancedLiveDesc, LucideIcons.sliders);
    case 'live_battles':
      return JourneyBenefitText(s.creatorJourneyBenefitLiveBattlesTitle,
          s.creatorJourneyBenefitLiveBattlesDesc, LucideIcons.swords);
    case 'live_ranking':
      return JourneyBenefitText(s.creatorJourneyBenefitLiveRankingTitle,
          s.creatorJourneyBenefitLiveRankingDesc, LucideIcons.trophy);
    case 'ambassador_badge':
      return JourneyBenefitText(s.creatorJourneyBenefitAmbassadorBadgeTitle,
          s.creatorJourneyBenefitAmbassadorBadgeDesc, LucideIcons.award);
    case 'ambassador_page':
      return JourneyBenefitText(s.creatorJourneyBenefitAmbassadorPageTitle,
          s.creatorJourneyBenefitAmbassadorPageDesc, LucideIcons.layoutTemplate);
    case 'official_campaigns':
      return JourneyBenefitText(s.creatorJourneyBenefitOfficialCampaignsTitle,
          s.creatorJourneyBenefitOfficialCampaignsDesc, LucideIcons.handshake);
    case 'premium_highlight':
      return JourneyBenefitText(s.creatorJourneyBenefitPremiumHighlightTitle,
          s.creatorJourneyBenefitPremiumHighlightDesc, LucideIcons.sparkles);
    case 'founding_badge':
      return JourneyBenefitText(s.creatorJourneyBenefitFoundingBadgeTitle,
          s.creatorJourneyBenefitFoundingBadgeDesc, LucideIcons.gem);
    case 'founding_seal':
      return JourneyBenefitText(s.creatorJourneyBenefitFoundingSealTitle,
          s.creatorJourneyBenefitFoundingSealDesc, LucideIcons.shieldCheck);
    case 'early_access':
      return JourneyBenefitText(s.creatorJourneyBenefitEarlyAccessTitle,
          s.creatorJourneyBenefitEarlyAccessDesc, LucideIcons.rocket);
    case 'roadmap_voice':
      return JourneyBenefitText(s.creatorJourneyBenefitRoadmapVoiceTitle,
          s.creatorJourneyBenefitRoadmapVoiceDesc, LucideIcons.messageSquareHeart);
    default:
      return JourneyBenefitText(key, '', LucideIcons.star);
  }
}
