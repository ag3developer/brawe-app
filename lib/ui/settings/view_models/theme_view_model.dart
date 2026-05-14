import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'theme_view_model.g.dart';

/// Theme mode controller. Persists user preference locally for instant boot.
/// Backend sync happens via /settings endpoint.
@Riverpod(keepAlive: true)
class ThemeController extends _$ThemeController {
  static const _key = 'brawe_theme_mode';

  @override
  ThemeMode build() {
    _restore();
    return ThemeMode.dark;
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
      case 'system':
        return ThemeMode.system;
      case 'dark':
      default:
        return ThemeMode.dark;
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
