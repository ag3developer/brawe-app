// ============================================================================
// BRAWE CREATOR NETWORK — HTTP Service (Dio)
// ============================================================================

import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/network/live_dio_provider.dart';
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
    return CreatorApplication.fromJson(r.data!);
  }

  Future<String?> getCreatorTermsVersion() async {
    final r = await _dio.get<Map<String, dynamic>>(
      '/creator/terms/version',
    );
    final v = r.data?['version'];
    return v is String ? v : null;
  }

  Future<CreatorApplication?> getMyApplication() async {
    try {
      final r = await _dio.get<Map<String, dynamic>>(
        '/creator/applications/me',
      );
      if (r.data == null) return null;
      return CreatorApplication.fromJson(r.data!);
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
    return CreatorApplication.fromJson(r.data!);
  }

  Future<CreatorProfile?> getMyCreator() async {
    try {
      final r = await _dio.get<Map<String, dynamic>>('/creator/me');
      if (r.data == null) return null;
      return CreatorProfile.fromJson(r.data!);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
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
    return CreatorProfile.fromJson(r.data!);
  }
}
