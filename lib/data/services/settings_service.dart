import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/network/live_dio_provider.dart';

part 'settings_service.g.dart';

@riverpod
SettingsService settingsService(Ref ref) {
  return SettingsService(ref.watch(liveDioProvider));
}

class SettingsService {
  final Dio _dio;

  SettingsService(this._dio);

  Future<Map<String, dynamic>> getSettings() async {
    final response = await _dio.get('/settings');
    final data = response.data;
    if (data is Map<String, dynamic>) {
      return (data['data'] as Map<String, dynamic>?) ?? data;
    }
    return <String, dynamic>{};
  }

  Future<Map<String, dynamic>> updateSettings(
    Map<String, dynamic> patch,
  ) async {
    final response = await _dio.put('/settings', data: patch);
    final data = response.data;
    if (data is Map<String, dynamic>) {
      return (data['data'] as Map<String, dynamic>?) ?? data;
    }
    return <String, dynamic>{};
  }
}
