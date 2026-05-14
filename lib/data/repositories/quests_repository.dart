import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/models/failure.dart';
import '../../domain/models/quest.dart';
import '../services/quests_service.dart';

part 'quests_repository.g.dart';

@riverpod
QuestsRepository questsRepository(Ref ref) {
  return QuestsRepository(ref.watch(questsServiceProvider));
}

class QuestsRepository {
  final QuestsService _service;
  QuestsRepository(this._service);

  Future<QuestsData> getDailyQuests() async {
    try {
      final json = await _service.getDailyQuests();
      return QuestsData.fromJson(json);
    } catch (_) {
      throw const Failure.network();
    }
  }

  Future<Map<String, dynamic>> claim(String questKey) async {
    try {
      return await _service.claimQuest(questKey);
    } catch (_) {
      throw const Failure.network();
    }
  }
}
