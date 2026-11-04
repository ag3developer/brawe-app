// ============================================================================
// BRAWE CREATOR NETWORK — HTTP Service (Dio)
// ============================================================================

import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/network/live_dio_provider.dart';
import '../../domain/models/creator_journey.dart';
import '../../domain/models/creator_network.dart';

part 'creator_network_service.g.dart';

@riverpod
CreatorNetworkService creatorNetworkService(Ref ref) {
  return CreatorNetworkService(ref.watch(liveDioProvider));
}

class CreatorNetworkService {
  final Dio _dio;
  CreatorNetworkService(this._dio);

  Future<NetworkOverview> getNetworkOverview() async {
    final r = await _dio.get<Map<String, dynamic>>('/creator/network');
    return NetworkOverview.fromJson(r.data!);
  }

  Future<CreatorApplication> submitApplication(
    Map<String, dynamic> body,
  ) async {
    final r = await _dio.post<Map<String, dynamic>>(
      '/creator/applications',
      data: body,
    );
    // Backend pode responder com { "success": true, "data": {...} }
    // ou diretamente com o objeto. _unwrap lida com ambos os casos.
    return CreatorApplication.fromJson(_unwrap(r.data!));
  }

  Future<String?> getCreatorTermsVersion() async {
    final r = await _dio.get<Map<String, dynamic>>('/creator/terms/version');
    final v = r.data?['version'];
    return v is String ? v : null;
  }

  Future<CreatorApplication?> getMyApplication() async {
    try {
      final r = await _dio.get<Map<String, dynamic>>(
        '/creator/applications/me',
      );
      if (r.data == null) return null;
      return CreatorApplication.fromJson(_unwrap(r.data!));
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  Future<CreatorApplication> updateMyApplication(
    Map<String, dynamic> body,
  ) async {
    final r = await _dio.patch<Map<String, dynamic>>(
      '/creator/applications/me',
      data: body,
    );
    return CreatorApplication.fromJson(_unwrap(r.data!));
  }

  Future<CreatorProfile?> getMyCreator() async {
    try {
      final r = await _dio.get<Map<String, dynamic>>('/creator/me');
      if (r.data == null) return null;
      return CreatorProfile.fromJson(_unwrap(r.data!));
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  /// Jornada do criador: trilha, metas, semana e benefícios.
  Future<CreatorJourney> getMyJourney() async {
    final r = await _dio.get<Map<String, dynamic>>(
      '/creator/network/me/journey',
    );
    return CreatorJourney.fromJson(r.data!);
  }

  Future<OnboardingChecklist> getOnboarding() async {
    final r = await _dio.get<Map<String, dynamic>>('/creator/onboarding');
    return OnboardingChecklist.fromJson(r.data!);
  }

  Future<OnboardingChecklist> completeOnboardingStep(String key) async {
    final r = await _dio.post<Map<String, dynamic>>(
      '/creator/onboarding/complete',
      data: {'key': key},
    );
    return OnboardingChecklist.fromJson(r.data!);
  }

  Future<PaginatedApplications> adminListApplications(
    AdminApplicationFilter filter,
  ) async {
    final r = await _dio.get<Map<String, dynamic>>(
      '/admin/creator/applications',
      queryParameters: filter.toQuery(),
    );
    return PaginatedApplications.fromJson(r.data!);
  }

  Future<CreatorApplication> adminGetApplication(String id) async {
    final r = await _dio.get<Map<String, dynamic>>(
      '/admin/creator/applications/$id',
    );
    return CreatorApplication.fromJson(r.data!);
  }

  Future<CreatorApplication> adminPatchApplication(
    String id,
    AdminUpdateApplication patch,
  ) async {
    final r = await _dio.patch<Map<String, dynamic>>(
      '/admin/creator/applications/$id',
      data: patch.toJson(),
    );
    return CreatorApplication.fromJson(r.data!);
  }

  Future<CreatorApplication> adminReviewApplication(
    String id,
    AdminReviewRequest review,
  ) async {
    final r = await _dio.post<Map<String, dynamic>>(
      '/admin/creator/applications/$id/review',
      data: review.toJson(),
    );
    return CreatorApplication.fromJson(r.data!);
  }

  Future<CreatorProfile> adminMoveTier(
    String userId,
    CreatorTier newTier,
  ) async {
    final r = await _dio.post<Map<String, dynamic>>(
      '/admin/creator/creators/$userId/move-tier',
      data: {'new_tier': newTier.apiValue},
    );
    return CreatorProfile.fromJson(_unwrap(r.data!));
  }

  /// Desembrulha envelopes de resposta do backend.
  ///
  /// O backend Brawe usa dois formatos possíveis:
  ///   1. Direto:   { "id": "...", "status": "pending_review", ... }
  ///   2. Envelope: { "success": true, "data": { "id": "...", ... } }
  ///
  /// Se não desembrulharmos, o fromJson tentaria parsear o envelope como
  /// se fosse o objeto, resultando em campos vazios/null sem lançar exception
  /// (todos os campos têm defaults), fazendo o submit parecer bem-sucedido
  /// mas entregando um objeto inválido — a UI navega para /creator/submitted
  /// mas o estado fica corrompido.
  static Map<String, dynamic> _unwrap(Map<String, dynamic> raw) {
    // Se tem 'success' + 'data', desembrulha
    if (raw.containsKey('data') && raw['data'] is Map<String, dynamic>) {
      return raw['data'] as Map<String, dynamic>;
    }
    // Se tem 'application' aninhado
    if (raw.containsKey('application') &&
        raw['application'] is Map<String, dynamic>) {
      return raw['application'] as Map<String, dynamic>;
    }
    // Formato direto — retorna como está
    return raw;
  }
}
