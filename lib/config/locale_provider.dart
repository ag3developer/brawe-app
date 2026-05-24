import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'locale_provider.g.dart';

/// Controla o idioma do app. Persiste em SharedPreferences (instant boot)
/// e expõe o Locale atual para o MaterialApp.
///
/// Idiomas suportados: pt_BR, es, en
@Riverpod(keepAlive: true)
class LocaleController extends _$LocaleController {
  static const _key = 'brawe_app_locale';

  /// Locale padrão quando não há nada salvo ainda.
  static const Locale defaultLocale = Locale('pt', 'BR');

  /// Lista canônica de locales suportados.
  static const List<Locale> supportedLocales = [
    Locale('pt', 'BR'),
    Locale('es'),
    Locale('en'),
  ];

  @override
  Locale build() {
    _restore();
    return defaultLocale;
  }

  Future<void> _restore() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    final restored = _parse(raw);
    if (restored != null && restored != state) {
      state = restored;
    }
  }

  Future<void> setLocale(Locale locale) async {
    if (state == locale) return;
    state = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, _serialize(locale));
  }

  static String _serialize(Locale locale) {
    final country = locale.countryCode;
    if (country == null || country.isEmpty) return locale.languageCode;
    return '${locale.languageCode}_$country';
  }

  static Locale? _parse(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    final parts = raw.split('_');
    if (parts.length >= 2) return Locale(parts[0], parts[1]);
    return Locale(parts[0]);
  }
}
