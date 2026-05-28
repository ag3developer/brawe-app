// ============================================================================
// BRAWE LIVE — Eligibility Service
// ----------------------------------------------------------------------------
// Consulta /v1/live/eligibility para saber se o usuário logado pode iniciar
// uma transmissão ao vivo. Backend responde sempre 200 com:
//   {
//     "can_go_live": bool,
//     "code": "ok" | "profile_incomplete" | "creator_required",
//     "message": "...",
//     "missing": ["avatar"?, "creator_program"?],
//     "has_avatar": bool,
//     "is_creator": bool,
//     "creator_tier": "rising"|...|null
//   }
// ============================================================================

import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/network/live_dio_provider.dart';
import '../../domain/models/live_eligibility.dart';

part 'live_eligibility_service.g.dart';

@riverpod
LiveEligibilityService liveEligibilityService(Ref ref) {
  return LiveEligibilityService(ref.watch(liveDioProvider));
}

class LiveEligibilityService {
  final Dio _dio;
  LiveEligibilityService(this._dio);

  Future<LiveEligibility> fetch() async {
    final r = await _dio.get<Map<String, dynamic>>('/live/eligibility');
    return LiveEligibility.fromJson(r.data!);
  }
}
