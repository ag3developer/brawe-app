import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../data/repositories/settings_repository.dart';

part 'theme_view_model.g.dart';

/// Theme mode controller. Persists user preference locally for instant boot.
/// Backend sync happens via /settings endpoint.
@Riverpod(keepAlive: true)
class ThemeController extends _$ThemeController {
  static const _key = 'brawe_theme_mode';

  @override
  ThemeMode build() {
    _restore();
    // Padrão das redes sociais: seguir a aparência do celular. Quem já
    // escolheu claro/escuro tem a escolha salva (no celular e na conta).
    return ThemeMode.system;
  }

  Future<void> _restore() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    final restored = _parse(raw);
    if (restored != state) state = restored;
  }

  Future<void> setMode(ThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, _serialize(mode));
  }

  /// Troca o tema NA HORA e salva no celular; depois tenta salvar na conta.
  /// Sem internet o tema continua trocado (antes não fazia nada se as
  /// configurações ainda não tinham carregado).
  Future<void> setModeAndSync(ThemeMode mode) async {
    await setMode(mode);
    try {
      await ref
          .read(settingsRepositoryProvider)
          .updateSettings({'theme': _serialize(mode)});
    } catch (_) {}
  }

  String? _syncedFor;

  /// Recupera o tema salvo na CONTA logo após o login / ao abrir o app —
  /// antes só acontecia ao abrir a tela de Configurações, e em celular novo
  /// o app abria no escuro mesmo com "claro" escolhido.
  Future<void> syncFromServer(String userId) async {
    if (_syncedFor == userId) return;
    _syncedFor = userId;
    try {
      final settings = await ref.read(settingsRepositoryProvider).getSettings();
      await applyFromBackend(settings.theme);
    } catch (_) {
      _syncedFor = null; // tenta de novo no próximo login/abertura
    }
  }

  /// Logout: o próximo login busca o tema da nova conta.
  void resetSync() => _syncedFor = null;

  /// Apply a value coming from backend ('system' | 'dark' | 'light').
  Future<void> applyFromBackend(String? theme) async {
    final mode = _parse(theme);
    if (mode != state) {
      state = mode;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, _serialize(mode));
    }
  }

  static ThemeMode _parse(String? raw) {
    switch (raw) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  static String _serialize(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.system:
        return 'system';
      case ThemeMode.dark:
        return 'dark';
    }
  }
}
