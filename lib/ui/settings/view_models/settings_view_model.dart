import 'package:flutter/material.dart' show ThemeMode;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/repositories/settings_repository.dart';
import '../../../domain/models/user_settings.dart';
import 'theme_view_model.dart';

part 'settings_view_model.g.dart';

@riverpod
class SettingsViewModel extends _$SettingsViewModel {
  @override
  Future<UserSettings> build() async {
    final repo = ref.read(settingsRepositoryProvider);
    final settings = await repo.getSettings();
    // Sync theme controller with backend value on first load.
    ref.read(themeControllerProvider.notifier).applyFromBackend(settings.theme);
    return settings;
  }

  /// Patch a single field with optimistic update. Rolls back on failure.
  Future<void> patch(Map<String, dynamic> change, UserSettings optimistic) async {
    final previous = state.value;
    state = AsyncValue.data(optimistic);

    // Reflect theme change instantly in UI when applicable.
    if (change.containsKey('theme')) {
      ref
          .read(themeControllerProvider.notifier)
          .applyFromBackend(change['theme'] as String?);
    }

    try {
      final updated =
          await ref.read(settingsRepositoryProvider).updateSettings(change);
      state = AsyncValue.data(updated);
    } catch (e, st) {
      if (previous != null) {
        state = AsyncValue.data(previous);
        if (change.containsKey('theme')) {
          ref
              .read(themeControllerProvider.notifier)
              .applyFromBackend(previous.theme);
        }
      }
      state = AsyncValue.error(e, st);
      // Restore data so the page is still usable.
      if (previous != null) state = AsyncValue.data(previous);
      rethrow;
    }
  }

  Future<void> setTheme(String theme) async {
    final current = state.value;
    if (current == null) {
      // Configurações ainda não carregaram (ex.: sem internet): troca e
      // salva no celular mesmo assim e tenta mandar para a conta.
      final mode = switch (theme) {
        'light' => ThemeMode.light,
        'system' => ThemeMode.system,
        _ => ThemeMode.dark,
      };
      await ref.read(themeControllerProvider.notifier).setModeAndSync(mode);
      return;
    }
    await patch({'theme': theme}, current.copyWith(theme: theme));
  }

  Future<void> setBool(String key, bool value) async {
    final current = state.value;
    if (current == null) return;
    final updated = switch (key) {
      'notifications_live_start' =>
        current.copyWith(notificationsLiveStart: value),
      'notifications_gifts' => current.copyWith(notificationsGifts: value),
      'notifications_followers' =>
        current.copyWith(notificationsFollowers: value),
      'notifications_messages' => current.copyWith(notificationsMessages: value),
      'privacy_show_earnings' => current.copyWith(privacyShowEarnings: value),
      'privacy_show_viewers' => current.copyWith(privacyShowViewers: value),
      'sounds_enabled' => current.copyWith(soundsEnabled: value),
      _ => current,
    };
    await patch({key: value}, updated);
  }

  Future<void> setLanguage(String lang) async {
    final current = state.value;
    if (current == null) return;
    await patch({'language': lang}, current.copyWith(language: lang));
  }
}
