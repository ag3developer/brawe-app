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
      return Profile.fromJson(data);
    } on DioException catch (e) {
      throw _mapFailure(e);
    } catch (e) {
      throw const Failure.unknown();
    }
  }

  Future<Profile> getUserProfile(String userId) async {
    try {
      final data = await _profileService.getUserProfile(userId);
      return Profile.fromJson(data);
    } on DioException catch (e) {
      throw _mapFailure(e);
    } catch (e) {
      throw const Failure.unknown();
    }
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
