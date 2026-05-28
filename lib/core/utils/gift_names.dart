// ============================================================================
// GIFT NAMES — Traduções localizadas dos presentes Brawe Connect
// ----------------------------------------------------------------------------
// O backend retorna `name` em português (ex.: "Castelo", "Tsunami"). Esta
// utility traduz o nome pra qualquer locale suportado, usando o `slug`
// (estável, nunca muda) como chave. Caso o slug não esteja mapeado, faz
// fallback pro nome original vindo do servidor.
//
// Para adicionar um novo gift: incluir o slug nos 3 maps (pt/en/es).
// ============================================================================

import 'package:flutter/widgets.dart';

class GiftNames {
  GiftNames._();

  /// Resolve o nome localizado de um gift pelo slug.
  /// Se [locale] não for fornecido, usa `Localizations.localeOf(context)`.
  static String of(
    BuildContext context,
    String slug, {
    String? fallback,
  }) {
    final lang = Localizations.localeOf(context).languageCode;
    final map = _byLanguage(lang);
    return map[slug] ?? fallback ?? slug;
  }

  /// Versão sem context, usando código de idioma direto.
  static String forLanguage(
    String languageCode,
    String slug, {
    String? fallback,
  }) {
    final map = _byLanguage(languageCode);
    return map[slug] ?? fallback ?? slug;
  }

  static Map<String, String> _byLanguage(String lang) {
    switch (lang) {
      case 'en':
        return _en;
      case 'es':
        return _es;
      case 'pt':
      default:
        return _pt;
    }
  }

  // ---- PT (Brasil) ---------------------------------------------------------
  static const Map<String, String> _pt = {
    // FREE
    'clap': 'Aplauso',
    'fire': 'Fogo',
    'heart': 'Coração',
    // BASIC
    'rose': 'Rosa',
    'star': 'Estrela',
    'kiss': 'Beijo',
    'butterfly': 'Borboleta',
    'headphones': 'Fone',
    'moon': 'Lua',
    'microphone': 'Microfone',
    'diamond': 'Diamante',
    // PREMIUM
    'energy': 'Energia',
    'rocket': 'Foguete',
    'gamepad': 'Gamepad',
    'mini-crown': 'Mini Coroa',
    'bear': 'Urso',
    'galaxy': 'Galáxia',
    'coin-rain': 'Chuva de Moedas',
    // LUXURY
    'crown': 'Coroa',
    'sports-car': 'Carro Esportivo',
    'yacht': 'Lancha',
    'private-jet': 'Jato Privado',
    'titan': 'Titã',
    'tsunami': 'Tsunami',
    // LEGENDARY
    'castle': 'Castelo',
    'dragon': 'Dragão',
    'lion': 'Leão',
    'phoenix': 'Fênix',
    'supernova': 'Supernova',
    'universe': 'Universo',
  };

  // ---- EN ------------------------------------------------------------------
  static const Map<String, String> _en = {
    'clap': 'Clap',
    'fire': 'Fire',
    'heart': 'Heart',
    'rose': 'Rose',
    'star': 'Star',
    'kiss': 'Kiss',
    'butterfly': 'Butterfly',
    'headphones': 'Headphones',
    'moon': 'Moon',
    'microphone': 'Microphone',
    'diamond': 'Diamond',
    'energy': 'Energy',
    'rocket': 'Rocket',
    'gamepad': 'Gamepad',
    'mini-crown': 'Mini Crown',
    'bear': 'Bear',
    'galaxy': 'Galaxy',
    'coin-rain': 'Coin Rain',
    'crown': 'Crown',
    'sports-car': 'Sports Car',
    'yacht': 'Yacht',
    'private-jet': 'Private Jet',
    'titan': 'Titan',
    'tsunami': 'Tsunami',
    'castle': 'Castle',
    'dragon': 'Dragon',
    'lion': 'Lion',
    'phoenix': 'Phoenix',
    'supernova': 'Supernova',
    'universe': 'Universe',
  };

  // ---- ES ------------------------------------------------------------------
  static const Map<String, String> _es = {
    'clap': 'Aplauso',
    'fire': 'Fuego',
    'heart': 'Corazón',
    'rose': 'Rosa',
    'star': 'Estrella',
    'kiss': 'Beso',
    'butterfly': 'Mariposa',
    'headphones': 'Auriculares',
    'moon': 'Luna',
    'microphone': 'Micrófono',
    'diamond': 'Diamante',
    'energy': 'Energía',
    'rocket': 'Cohete',
    'gamepad': 'Mando',
    'mini-crown': 'Mini Corona',
    'bear': 'Oso',
    'galaxy': 'Galaxia',
    'coin-rain': 'Lluvia de Monedas',
    'crown': 'Corona',
    'sports-car': 'Coche Deportivo',
    'yacht': 'Yate',
    'private-jet': 'Jet Privado',
    'titan': 'Titán',
    'tsunami': 'Tsunami',
    'castle': 'Castillo',
    'dragon': 'Dragón',
    'lion': 'León',
    'phoenix': 'Fénix',
    'supernova': 'Supernova',
    'universe': 'Universo',
  };
}
