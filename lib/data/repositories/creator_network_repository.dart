// ============================================================================
// BRAWE CREATOR NETWORK — Repository
// ----------------------------------------------------------------------------
// Camada de mapping erros + isolamento da UI dos detalhes Dio.
// Convertemos DioException em Failure (mesmo padrão dos outros repositórios).
// ============================================================================

import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/models/creator_journey.dart';
import '../../domain/models/creator_network.dart';
import '../../domain/models/failure.dart';
import '../services/creator_network_service.dart';

part 'creator_network_repository.g.dart';

@riverpod
CreatorNetworkRepository creatorNetworkRepository(Ref ref) {
  return CreatorNetworkRepository(ref.watch(creatorNetworkServiceProvider));
}

class CreatorNetworkRepository {
  final CreatorNetworkService _service;
  CreatorNetworkRepository(this._service);

  // ──────────────────────────────────────────────────────────
  // PUBLIC
  // ──────────────────────────────────────────────────────────
  Future<NetworkOverview> getNetworkOverview() async {
    try {
      return await _service.getNetworkOverview();
    } on DioException catch (e) {
      throw _mapFailure(e);
    } catch (_) {
      throw const Failure.unknown();
    }
  }

  // ──────────────────────────────────────────────────────────
  // USER — Applications
  // ──────────────────────────────────────────────────────────
  Future<CreatorApplication> submitApplication({
    required String fullName,
    required String username,
    required String email,
    String? phone,
    required String country,
    String? city,
    required String language,
    required ContentNiche niche,
    CreatorTier? requestedTier,
    SocialLinks socialLinks = const SocialLinks(),
    int followersCount = 0,
    bool doesLive = false,
    String? bio,
    String? motivation,
    String? goals,
    String? portfolioUrl,
    // Aceite legal — obrigatório pelo backend.
    required bool termsAccepted,
    String? termsVersion,
  }) async {
    try {
      final body = <String, dynamic>{
        'full_name': fullName,
        'username': username,
        'email': email,
        if (phone != null && phone.isNotEmpty) 'phone': phone,
        'country': country,
        if (city != null && city.isNotEmpty) 'city': city,
        'language': language,
        'niche': niche.apiValue,
        if (requestedTier != null) 'requested_tier': requestedTier.apiValue,
        'social_links': socialLinks.toJson(),
        'followers_count': followersCount,
        'does_live': doesLive,
        if (bio != null && bio.isNotEmpty) 'bio': bio,
        if (motivation != null && motivation.isNotEmpty) 'motivation': motivation,
        if (goals != null && goals.isNotEmpty) 'goals': goals,
        if (portfolioUrl != null && portfolioUrl.isNotEmpty)
          'portfolio_url': portfolioUrl,
        'terms_accepted': termsAccepted,
        if (termsVersion != null && termsVersion.isNotEmpty)
          'terms_version': termsVersion,
      };
      return await _service.submitApplication(body);
    } on DioException catch (e) {
      throw _mapFailure(e);
    } catch (_) {
      throw const Failure.unknown();
    }
  }

  /// Versão vigente dos Termos do Brawe Creator Network (ex.: "2026-05-01").
  /// Em caso de falha de rede, retorna null e o form usa a versão default.
  Future<String?> getCreatorTermsVersion() async {
    try {
      return await _service.getCreatorTermsVersion();
    } catch (_) {
      return null;
    }
  }

  Future<CreatorApplication?> getMyApplication() async {
    try {
      return await _service.getMyApplication();
    } on DioException catch (e) {
      throw _mapFailure(e);
    } catch (_) {
      throw const Failure.unknown();
    }
  }

  Future<CreatorApplication> updateMyApplication(
    Map<String, dynamic> body,
  ) async {
    try {
      return await _service.updateMyApplication(body);
    } on DioException catch (e) {
      throw _mapFailure(e);
    } catch (_) {
      throw const Failure.unknown();
    }
  }

  // ──────────────────────────────────────────────────────────
  // USER — Creator
  // ──────────────────────────────────────────────────────────
  Future<CreatorJourney> getMyJourney() async {
    try {
      return await _service.getMyJourney();
    } on DioException catch (e) {
      throw _mapFailure(e);
    } catch (_) {
      throw const Failure.unknown();
    }
  }

  Future<CreatorProfile?> getMyCreator() async {
    try {
      return await _service.getMyCreator();
    } on DioException catch (e) {
      throw _mapFailure(e);
    } catch (_) {
      throw const Failure.unknown();
    }
  }

  // ──────────────────────────────────────────────────────────
  // USER — Onboarding
  // ──────────────────────────────────────────────────────────
  Future<OnboardingChecklist> getOnboarding() async {
    try {
      return await _service.getOnboarding();
    } on DioException catch (e) {
      throw _mapFailure(e);
    } catch (_) {
      throw const Failure.unknown();
    }
  }

  Future<OnboardingChecklist> completeOnboardingStep(String key) async {
    try {
      return await _service.completeOnboardingStep(key);
    } on DioException catch (e) {
      throw _mapFailure(e);
    } catch (_) {
      throw const Failure.unknown();
    }
  }

  // ──────────────────────────────────────────────────────────
  // ADMIN
  // ──────────────────────────────────────────────────────────
  Future<PaginatedApplications> adminListApplications(
    AdminApplicationFilter filter,
  ) async {
    try {
      return await _service.adminListApplications(filter);
    } on DioException catch (e) {
      throw _mapFailure(e);
    } catch (_) {
      throw const Failure.unknown();
    }
  }

  Future<CreatorApplication> adminGetApplication(String id) async {
    try {
      return await _service.adminGetApplication(id);
    } on DioException catch (e) {
      throw _mapFailure(e);
    } catch (_) {
      throw const Failure.unknown();
    }
  }

  Future<CreatorApplication> adminPatchApplication(
    String id,
    AdminUpdateApplication patch,
  ) async {
    try {
      return await _service.adminPatchApplication(id, patch);
    } on DioException catch (e) {
      throw _mapFailure(e);
    } catch (_) {
      throw const Failure.unknown();
    }
  }

  Future<CreatorApplication> adminReviewApplication(
    String id,
    AdminReviewRequest review,
  ) async {
    try {
      return await _service.adminReviewApplication(id, review);
    } on DioException catch (e) {
      throw _mapFailure(e);
    } catch (_) {
      throw const Failure.unknown();
    }
  }

  Future<CreatorProfile> adminMoveTier(
    String userId,
    CreatorTier newTier,
  ) async {
    try {
      return await _service.adminMoveTier(userId, newTier);
    } on DioException catch (e) {
      throw _mapFailure(e);
    } catch (_) {
      throw const Failure.unknown();
    }
  }

  Failure _mapFailure(DioException e) {
    final code = e.response?.statusCode;
    if (code == 401 || code == 403) return const Failure.unauthorized();
    if (code == 409) {
      // Já existe inscrição ativa pro user — sinalizamos via mensagem
      // semântica para que a UI possa redirecionar para /creator/status.
      return const Failure.validation('creator_application_already_active');
    }
    if (code == 422) {
      // Erro de validação do backend (Pydantic). Expomos o detail bruto
      // se disponível para facilitar debugging.
      final detail = e.response?.data is Map
          ? (e.response!.data as Map)['detail']?.toString()
          : null;
      return Failure.validation(detail ?? 'validation_error');
    }
    if (code != null && code >= 500) return const Failure.server();
    return const Failure.network();
  }
}
