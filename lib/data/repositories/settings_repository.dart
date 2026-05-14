import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/models/failure.dart';
import '../../domain/models/user_settings.dart';
import '../services/settings_service.dart';

part 'settings_repository.g.dart';

@riverpod
SettingsRepository settingsRepository(Ref ref) {
  return SettingsRepository(ref.watch(settingsServiceProvider));
}

class SettingsRepository {
  final SettingsService _service;

  SettingsRepository(this._service);

  Future<UserSettings> getSettings() async {
    try {
      final json = await _service.getSettings();
      return UserSettings.fromJson(json);
    } catch (e) {
      throw Failure.network();
    }
  }

  Future<UserSettings> updateSettings(Map<String, dynamic> patch) async {
    try {
      final json = await _service.updateSettings(patch);
      return UserSettings.fromJson(json);
    } catch (e) {
      throw Failure.network();
    }
  }
}
