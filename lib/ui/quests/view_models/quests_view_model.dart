import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../config/locale_provider.dart';
import '../../../data/repositories/quests_repository.dart';
import '../../../domain/models/quest.dart';

part 'quests_view_model.g.dart';

@riverpod
class QuestsViewModel extends _$QuestsViewModel {
  /// Idioma do app (o servidor localiza título/descrição por `?lang=`).
  String get _lang => ref.read(localeControllerProvider).languageCode;

  @override
  Future<QuestsData> build() async {
    // Trocar o idioma do app rebusca as missões já traduzidas.
    ref.watch(localeControllerProvider);
    return ref.read(questsRepositoryProvider).getDailyQuests(lang: _lang);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(questsRepositoryProvider).getDailyQuests(lang: _lang),
    );
  }

  /// Optimistically marks quest claimed and increments XP/coins.
  /// On failure: rolls back and rethrows.
  Future<void> claimQuest(String questKey) async {
    final current = state.value;
    if (current == null) return;

    final idx = current.quests.indexWhere((q) => q.questKey == questKey);
    if (idx < 0) return;
    final quest = current.quests[idx];
    if (!quest.isClaimable) return;

    final optimistic = [...current.quests];
    optimistic[idx] = quest.copyWith(isClaimed: true);
    state = AsyncValue.data(current.copyWith(quests: optimistic));

    try {
      await ref.read(questsRepositoryProvider).claim(questKey);
      // Silently refetch to sync XP/coins/level
      final fresh =
          await ref.read(questsRepositoryProvider).getDailyQuests(lang: _lang);
      state = AsyncValue.data(fresh);
    } catch (e) {
      state = AsyncValue.data(current);
      rethrow;
    }
  }

  Future<int> claimAll() async {
    final current = state.value;
    if (current == null) return 0;
    final claimable = current.quests.where((q) => q.isClaimable).toList();
    int ok = 0;
    for (final q in claimable) {
      try {
        await ref.read(questsRepositoryProvider).claim(q.questKey);
        ok++;
      } catch (_) {
        // continue
      }
    }
    if (ok > 0) {
      final fresh =
          await ref.read(questsRepositoryProvider).getDailyQuests(lang: _lang);
      state = AsyncValue.data(fresh);
    }
    return ok;
  }
}
