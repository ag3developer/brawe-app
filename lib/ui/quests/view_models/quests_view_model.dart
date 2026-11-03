import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../config/locale_provider.dart';
import '../../../data/repositories/quests_repository.dart';
import '../../../domain/models/quest.dart';
import '../../../domain/models/quest_journey.dart';

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
    state = await AsyncValue.guard(
      () => ref.read(questsRepositoryProvider).getDailyQuests(lang: _lang),
    );
  }

  /// Marca a missão como coletada na hora (otimista) e devolve o resultado
  /// do servidor (XP, moedas, subiu de nível, emblemas novos).
  /// Em caso de falha, desfaz e relança.
  Future<QuestClaimResult?> claimQuest(String questKey) async {
    final current = state.value;
    if (current == null) return null;

    final idx = current.quests.indexWhere((q) => q.questKey == questKey);
    if (idx < 0) return null;
    final quest = current.quests[idx];
    if (!quest.isClaimable) return null;

    final optimistic = [...current.quests];
    optimistic[idx] = quest.copyWith(isClaimed: true);
    state = AsyncValue.data(current.copyWith(quests: optimistic));

    try {
      final result =
          await ref.read(questsRepositoryProvider).claim(questKey);
      await _syncAfterClaim();
      return result;
    } catch (e) {
      state = AsyncValue.data(current);
      rethrow;
    }
  }

  /// Coleta todas as resgatáveis. Devolve a soma (ou null se nenhuma deu certo).
  Future<QuestClaimResult?> claimAll() async {
    final current = state.value;
    if (current == null) return null;
    final claimable = current.quests.where((q) => q.isClaimable).toList();
    final results = <QuestClaimResult>[];
    for (final q in claimable) {
      try {
        results.add(await ref.read(questsRepositoryProvider).claim(q.questKey));
      } catch (_) {
        // segue para as próximas
      }
    }
    if (results.isEmpty) return null;
    await _syncAfterClaim();
    return QuestClaimResult.merge(results);
  }

  Future<void> _syncAfterClaim() async {
    try {
      final fresh =
          await ref.read(questsRepositoryProvider).getDailyQuests(lang: _lang);
      state = AsyncValue.data(fresh);
    } catch (_) {
      // mantém o estado otimista
    }
    // A jornada (linha do tempo, totais, emblemas) mudou.
    ref.invalidate(questJourneyProvider);
  }
}

/// Jornada do usuário: totais, emblemas, prêmios e linha do tempo.
final questJourneyProvider =
    AsyncNotifierProvider.autoDispose<QuestJourneyNotifier, QuestJourney>(
  QuestJourneyNotifier.new,
);

class QuestJourneyNotifier extends AsyncNotifier<QuestJourney> {
  bool _loadingMore = false;

  String get _lang => ref.read(localeControllerProvider).languageCode;

  @override
  Future<QuestJourney> build() async {
    ref.watch(localeControllerProvider);
    return ref.read(questsRepositoryProvider).getJourney(lang: _lang);
  }

  Future<void> refresh() async {
    state = await AsyncValue.guard(
      () => ref.read(questsRepositoryProvider).getJourney(lang: _lang),
    );
  }

  /// Próxima página da linha do tempo.
  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || !current.hasMore || _loadingMore) return;
    _loadingMore = true;
    try {
      final next = await ref
          .read(questsRepositoryProvider)
          .getJourney(lang: _lang, before: current.nextBefore);
      state = AsyncValue.data(current.appendPage(next));
    } catch (_) {
      // tenta de novo no próximo scroll
    } finally {
      _loadingMore = false;
    }
  }
}
