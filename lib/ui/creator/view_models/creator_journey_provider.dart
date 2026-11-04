// Provider da jornada do criador (escrito à mão para não depender de codegen).

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/repositories/creator_network_repository.dart';
import '../../../domain/models/creator_journey.dart';

/// GET /creator/network/me/journey — trilha, metas, semana e benefícios.
final creatorJourneyProvider = FutureProvider.autoDispose<CreatorJourney>((
  ref,
) {
  return ref.read(creatorNetworkRepositoryProvider).getMyJourney();
});
