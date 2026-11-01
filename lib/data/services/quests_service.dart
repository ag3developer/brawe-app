import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/network/live_dio_provider.dart';

part 'quests_service.g.dart';

@riverpod
QuestsService questsService(Ref ref) {
  return QuestsService(ref.watch(liveDioProvider));
}

class QuestsService {
  final Dio _dio;
  QuestsService(this._dio);

  /// [lang] (`pt` | `en` | `es`): o servidor devolve título/descrição já
  /// localizados.
  Future<Map<String, dynamic>> getDailyQuests({String? lang}) async {
    final r = await _dio.get(
      '/quests',
      queryParameters: {if (lang != null && lang.isNotEmpty) 'lang': lang},
    );
    final data = r.data;
    if (data is Map<String, dynamic>) return data;
    return <String, dynamic>{};
  }

  Future<Map<String, dynamic>> claimQuest(String questKey) async {
    final r = await _dio.post('/quests/$questKey/claim');
    final data = r.data;
    if (data is Map<String, dynamic>) return data;
    return <String, dynamic>{};
  }

  Future<Map<String, dynamic>> updateProgress(
    String questKey, {
    int increment = 1,
  }) async {
    final r = await _dio.post(
      '/quests/$questKey/progress',
      data: {'increment': increment},
    );
    final data = r.data;
    if (data is Map<String, dynamic>) return data;
    return <String, dynamic>{};
  }
}
