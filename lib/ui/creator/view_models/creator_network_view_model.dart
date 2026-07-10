// ============================================================================
// BRAWE CREATOR NETWORK — Riverpod providers
// ----------------------------------------------------------------------------
// Camada que conecta as telas Flutter ao repository:
//
//   • networkOverviewProvider      — landing data (público)
//   • myCreatorApplicationProvider — minha inscrição (ou null)
//   • myCreatorProfileProvider     — meu creator ativo (ou null)
//   • creatorOnboardingProvider    — checklist
//
//   • adminCreatorApplicationsProvider(filter) — lista paginada
//   • adminCreatorApplicationProvider(id)      — detalhe
//
//   • CreatorApplicationFormController — submit/edit
//   • AdminApplicationReviewController — aprovar/rejeitar/waitlist/etc
// ============================================================================

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/repositories/creator_network_repository.dart';
import '../../../domain/models/creator_network.dart';

part 'creator_network_view_model.g.dart';

// ──────────────────────────────────────────────────────────────
// PUBLIC
// ──────────────────────────────────────────────────────────────
@riverpod
Future<NetworkOverview> networkOverview(Ref ref) {
  return ref.read(creatorNetworkRepositoryProvider).getNetworkOverview();
}

// ──────────────────────────────────────────────────────────────
// USER
// ──────────────────────────────────────────────────────────────
@riverpod
Future<CreatorApplication?> myCreatorApplication(Ref ref) {
  return ref.read(creatorNetworkRepositoryProvider).getMyApplication();
}

@riverpod
Future<CreatorProfile?> myCreatorProfile(Ref ref) {
  return ref.read(creatorNetworkRepositoryProvider).getMyCreator();
}

@riverpod
Future<OnboardingChecklist> creatorOnboarding(Ref ref) {
  return ref.read(creatorNetworkRepositoryProvider).getOnboarding();
}

/// Versão vigente dos Termos do Brawe Creator Network (ex.: "2026-05-01").
/// Cacheada por sessão; usada pelo form para enviar `terms_version` no submit.
@riverpod
Future<String?> creatorTermsVersion(Ref ref) {
  return ref.read(creatorNetworkRepositoryProvider).getCreatorTermsVersion();
}

// ──────────────────────────────────────────────────────────────
// FORM CONTROLLER (submit + update)
// ──────────────────────────────────────────────────────────────
@riverpod
class CreatorApplicationFormController
    extends _$CreatorApplicationFormController {
  @override
  AsyncValue<CreatorApplication?> build() => const AsyncValue.data(null);

  Future<CreatorApplication> submit({
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
    required bool termsAccepted,
    String? termsVersion,
  }) async {
    state = const AsyncValue.loading();
    try {
      final app = await ref
          .read(creatorNetworkRepositoryProvider)
          .submitApplication(
            fullName: fullName,
            username: username,
            email: email,
            phone: phone,
            country: country,
            city: city,
            language: language,
            niche: niche,
            requestedTier: requestedTier,
            socialLinks: socialLinks,
            followersCount: followersCount,
            doesLive: doesLive,
            bio: bio,
            motivation: motivation,
            goals: goals,
            portfolioUrl: portfolioUrl,
            termsAccepted: termsAccepted,
            termsVersion: termsVersion,
          );
      state = AsyncValue.data(app);
      // invalida cache para refletir nova inscrição na próxima leitura
      ref.invalidate(myCreatorApplicationProvider);
      return app;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<CreatorApplication> updateMine(Map<String, dynamic> body) async {
    state = const AsyncValue.loading();
    try {
      final app = await ref
          .read(creatorNetworkRepositoryProvider)
          .updateMyApplication(body);
      state = AsyncValue.data(app);
      ref.invalidate(myCreatorApplicationProvider);
      return app;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

// ──────────────────────────────────────────────────────────────
// ONBOARDING CONTROLLER
// ──────────────────────────────────────────────────────────────
@riverpod
class OnboardingController extends _$OnboardingController {
  @override
  AsyncValue<OnboardingChecklist?> build() => const AsyncValue.data(null);

  Future<void> completeStep(String key) async {
    state = const AsyncValue.loading();
    try {
      final updated = await ref
          .read(creatorNetworkRepositoryProvider)
          .completeOnboardingStep(key);
      state = AsyncValue.data(updated);
      ref.invalidate(creatorOnboardingProvider);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

// ──────────────────────────────────────────────────────────────
// ADMIN — list
// ──────────────────────────────────────────────────────────────
/// Filtro atual usado na tela de admin (state local).
@riverpod
class AdminApplicationsFilter extends _$AdminApplicationsFilter {
  @override
  AdminApplicationFilter build() => const AdminApplicationFilter();

  void update(AdminApplicationFilter filter) => state = filter;
  void reset() => state = const AdminApplicationFilter();
  void setStatus(ApplicationStatus? s) =>
      state = state.copyWith(status: s, page: 1);
  void setTier(CreatorTier? t) => state = state.copyWith(tier: t, page: 1);
  void setNiche(ContentNiche? n) => state = state.copyWith(niche: n, page: 1);
  void setCountry(String? c) => state = state.copyWith(country: c, page: 1);
  void setPriority(ApplicationPriority? p) =>
      state = state.copyWith(priority: p, page: 1);
  void setSearch(String? s) => state = state.copyWith(search: s, page: 1);
  void nextPage() => state = state.copyWith(page: state.page + 1);
}

@riverpod
Future<PaginatedApplications> adminCreatorApplications(Ref ref) {
  final filter = ref.watch(adminApplicationsFilterProvider);
  return ref
      .read(creatorNetworkRepositoryProvider)
      .adminListApplications(filter);
}

@riverpod
Future<CreatorApplication> adminCreatorApplication(
  Ref ref, {
  required String id,
}) {
  return ref.read(creatorNetworkRepositoryProvider).adminGetApplication(id);
}

// ──────────────────────────────────────────────────────────────
// ADMIN — review controller
// ──────────────────────────────────────────────────────────────
@riverpod
class AdminApplicationReviewController
    extends _$AdminApplicationReviewController {
  @override
  AsyncValue<CreatorApplication?> build() => const AsyncValue.data(null);

  Future<CreatorApplication> review(
    String applicationId,
    AdminReviewRequest review,
  ) async {
    state = const AsyncValue.loading();
    try {
      final app = await ref
          .read(creatorNetworkRepositoryProvider)
          .adminReviewApplication(applicationId, review);
      state = AsyncValue.data(app);
      ref.invalidate(adminCreatorApplicationsProvider);
      ref.invalidate(adminCreatorApplicationProvider);
      return app;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<CreatorApplication> patch(
    String applicationId,
    AdminUpdateApplication patch,
  ) async {
    try {
      final app = await ref
          .read(creatorNetworkRepositoryProvider)
          .adminPatchApplication(applicationId, patch);
      ref.invalidate(adminCreatorApplicationsProvider);
      ref.invalidate(adminCreatorApplicationProvider);
      return app;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<CreatorProfile> moveTier(String userId, CreatorTier newTier) async {
    try {
      final profile = await ref
          .read(creatorNetworkRepositoryProvider)
          .adminMoveTier(userId, newTier);
      ref.invalidate(adminCreatorApplicationsProvider);
      return profile;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}
