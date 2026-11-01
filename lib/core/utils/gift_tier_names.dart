// ============================================================================
// GIFT TIER NAMES — Localização das categorias (tabs) de presentes
// ----------------------------------------------------------------------------
// O backend retorna o nome do tier em inglês (ex.: "free", "basic", "premium",
// "luxury", "legendary"). Este helper traduz a label exibida nas TABS de
// presentes (story_gift_sheet + gifts_overlay da live) usando os arbs.
//
// Decisão de produto (09-jun-2026): a aba "Free" foi renomeada para "Cofre"
// (PT) / "Vault" (EN) / "Bóveda" (ES) — comunica que são presentes pagos com
// moedas/XP de quests acumuladas, não com dinheiro real. Para o usuário fica
// MUITO mais claro que ele tem um "cofrinho" que enche conforme participa.
//
// Slug recebido do backend é case-insensitive — comparamos sempre em lowercase.
// Tiers desconhecidos caem no fallback (capitalize do nome original) — assim
// se o backend introduzir um tier novo (ex.: "mythic") a UI não quebra.
// ============================================================================

import 'package:flutter/widgets.dart';

import '../../gen/l10n/app_localizations.dart';

class GiftTierNames {
  GiftTierNames._();

  /// Resolve a label localizada de um tier de presente.
  ///
  /// [tierName] é o `name` cru vindo do backend (ex.: "free", "FREE",
  /// "Free", "basic"). Retorna a string localizada do arb. Se o tier
  /// não tiver entrada, retorna o nome capitalizado como fallback.
  ///
  /// Uso:
  /// ```dart
  /// Tab(text: GiftTierNames.of(context, tier.name))
  /// ```
  static String of(BuildContext context, String tierName) {
    final s = S.of(context);
    final key = tierName.trim().toLowerCase();
    switch (key) {
      case 'free':
        return s.giftTierFree;
      case 'basic':
        return s.giftTierBasic;
      case 'premium':
        return s.giftTierPremium;
      case 'luxury':
        return s.giftTierLuxury;
      case 'legendary':
        return s.giftTierLegendary;
      default:
        return _capitalize(tierName);
    }
  }

  /// Versão UPPERCASE — usada na sacola da live (gifts_overlay) que
  /// historicamente exibe os tabs em CAIXA ALTA estilo TikTok. A
  /// localização é resolvida primeiro e só depois capitalizada toda.
  static String ofUpper(BuildContext context, String tierName) {
    return of(context, tierName).toUpperCase();
  }

  /// Nome da aba: categoria temática do admin no idioma do usuário (com
  /// português como reserva); senão o nome do tier.
  static String label(BuildContext context, String tierName, Map<String, String> names) {
    if (names.isNotEmpty) {
      final lang = Localizations.localeOf(context).languageCode;
      final n = names[lang] ?? names['pt'] ?? names.values.first;
      if (n.trim().isNotEmpty) return n.trim();
    }
    return of(context, tierName);
  }

  static String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1).toLowerCase();
}
