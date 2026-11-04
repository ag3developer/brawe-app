import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/repositories/gift_repository.dart';
import '../../../domain/models/gifter_level_journey.dart';

/// Jornada de nível do presenteador (tela "Meu nível").
/// Escrito à mão (sem build_runner), no mesmo modelo de `questJourneyProvider`.
final gifterLevelJourneyProvider = AsyncNotifierProvider.autoDispose<
    GifterLevelJourneyNotifier, GifterLevelJourney>(
  GifterLevelJourneyNotifier.new,
);

class GifterLevelJourneyNotifier extends AsyncNotifier<GifterLevelJourney> {
  @override
  Future<GifterLevelJourney> build() {
    return ref.read(giftRepositoryProvider).getMyGifterLevelJourney();
  }

  Future<void> refresh() async {
    state = await AsyncValue.guard(
      () => ref.read(giftRepositoryProvider).getMyGifterLevelJourney(),
    );
  }
}
