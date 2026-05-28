// ============================================================================
// BRAWE LIVE — Eligibility ViewModel (Riverpod)
// ============================================================================

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/services/live_eligibility_service.dart';
import '../../../domain/models/live_eligibility.dart';

part 'live_eligibility_view_model.g.dart';

@riverpod
Future<LiveEligibility> liveEligibility(Ref ref) {
  return ref.read(liveEligibilityServiceProvider).fetch();
}
