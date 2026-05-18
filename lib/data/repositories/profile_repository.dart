import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/models/failure.dart';
import '../../domain/models/profile.dart';
import '../../domain/models/live_room.dart';
import '../model/live_room_dto.dart';
import '../services/profile_service.dart';

part 'profile_repository.g.dart';

@riverpod
ProfileRepository profileRepository(Ref ref) {
  return ProfileRepository(ref.watch(profileServiceProvider));
}

class ProfileRepository {
  final ProfileService _profileService;

  ProfileRepository(this._profileService);

  Future<Profile> getMyProfile() async {
    try {
      final data = await _profileService.getMyProfile();
      return Profile.fromJson(_normalize(data));
    } on DioException catch (e) {
      throw _mapFailure(e);
    } catch (e) {
      throw const Failure.unknown();
    }
  }

  Future<Profile> getUserProfile(String userId) async {
    try {
      final data = await _profileService.getUserProfile(userId);
      return Profile.fromJson(_normalize(data));
    } on DioException catch (e) {
      throw _mapFailure(e);
    } catch (e) {
      throw const Failure.unknown();
    }
  }

  /// Normaliza o payload do backend, aceitando aliases comuns para banner/avatar
  /// (banner, cover, cover_url, profile_banner, header_url, etc.) e mapeando
  /// `user_id` -> `id` (o endpoint /profile/me devolve `user_id`).
  Map<String, dynamic> _normalize(Map<String, dynamic> data) {
    final out = Map<String, dynamic>.from(data);
    // /profile/me devolve `user_id` em vez de `id` -> Profile.fromJson exige `id`.
    out['id'] ??= data['id'] ?? data['user_id'] ?? data['uid'];
    out['banner_url'] ??= data['banner'] ??
        data['cover'] ??
        data['cover_url'] ??
        data['header_url'] ??
        data['profile_banner'] ??
        data['profile_banner_url'];
    out['avatar_url'] ??= data['avatar'] ??
        data['photo_url'] ??
        data['picture'] ??
        data['profile_picture'] ??
        data['profile_picture_url'] ??
        data['profile_photo'] ??
        data['profile_image'] ??
        data['image_url'] ??
        data['thumbnail_url'] ??
        data['photo'];
    return out;
  }

  Future<List<Profile>> getTopStreamers({int limit = 20}) async {
    try {
      final list = await _profileService.getTopStreamers(limit: limit);
      return list.map((json) => Profile.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _mapFailure(e);
    } catch (e) {
      throw const Failure.unknown();
    }
  }

  Future<List<LiveRoom>> getUserLives(
    String userId, {
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final list = await _profileService.getUserLives(
        userId,
        page: page,
        limit: limit,
      );
      return list.map((json) => LiveRoomDto.fromJson(json).toDomain()).toList();
    } on DioException catch (e) {
      throw _mapFailure(e);
    } catch (e) {
      throw const Failure.unknown();
    }
  }

  
  Future<Profile> updateMyProfile({
    String? displayName,
    String? bio,
    Map<String, String>? socialLinks,
  }) async {
    try {
      final data = await _profileService.updateMyProfile(
        displayName: displayName,
        bio: bio,
        socialLinks: socialLinks,
      );
      return Profile.fromJson(_normalize(data));
    } on DioException catch (e) {
      throw _mapFailure(e);
    } catch (e) {
      throw const Failure.unknown();
    }
  }

  Future<String> uploadAvatar(String filePath) async {
    try {
      return await _profileService.uploadAvatar(filePath);
    } on DioException catch (e) {
      throw _mapFailure(e);
    } catch (e) {
      throw const Failure.unknown();
    }
  }

  Future<void> deleteAvatar() async {
    try {
      await _profileService.deleteAvatar();
    } on DioException catch (e) {
      throw _mapFailure(e);
    } catch (e) {
      throw const Failure.unknown();
    }
  }

  Future<String> uploadBanner(String filePath) async {
    try {
      return await _profileService.uploadBanner(filePath);
    } on DioException catch (e) {
      throw _mapFailure(e);
    } catch (e) {
      throw const Failure.unknown();
    }
  }

  Future<void> deleteBanner() async {
    try {
      await _profileService.deleteBanner();
    } on DioException catch (e) {
      throw _mapFailure(e);
    } catch (e) {
      throw const Failure.unknown();
    }
  }

  Failure _mapFailure(DioException exception) {
    final statusCode = exception.response?.statusCode;
    if (statusCode == 401 || statusCode == 403) {
      return const Failure.unauthorized();
    }
    if (statusCode != null && statusCode >= 500) {
      return const Failure.server();
    }
    return const Failure.network();
  }
}
