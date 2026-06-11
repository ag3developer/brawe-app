// ============================================================================
// BRAWE LIVE — Eligibility ViewModel (Riverpod)
// Cached: se canGoLive=true numa sessão, não re-verifica até logout/restart.
// ============================================================================

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/services/live_eligibility_service.dart';
import '../../../domain/models/live_eligibility.dart';

part 'live_eligibility_view_model.g.dart';

// Cache em memória válido durante a sessão.
// Zerado apenas com app restart ou logout explícito.
LiveEligibility? _cachedEligibility;

@riverpod
Future<LiveEligibility> liveEligibility(Ref ref) async {
  // Se já sabe que pode fazer live, não precisa bater no backend de novo.
  if (_cachedEligibility != null && _cachedEligibility!.canGoLive) {
    return _cachedEligibility!;
  }
  final result = await ref.read(liveEligibilityServiceProvider).fetch();
  _cachedEligibility = result;
  return result;
}

/// Invalida o cache (chamar no logout ou quando dados do perfil mudarem).
void clearLiveEligibilityCache() => _cachedEligibility = null;

/// Força re-verificação mesmo que já esteja cacheado (ex: após adicionar avatar).
void invalidateLiveEligibilityCache() => _cachedEligibility = null;
