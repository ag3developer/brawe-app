import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/models/failure.dart';
import '../../domain/models/social_stats.dart';
import '../../domain/models/profile.dart';
import '../../domain/models/follow_user.dart';
import '../services/social_service.dart';

part 'social_repository.g.dart';

@riverpod
SocialRepository socialRepository(Ref ref) {
  return SocialRepository(ref.watch(socialServiceProvider));
}

class SocialRepository {
  final SocialService _socialService;

  SocialRepository(this._socialService);

  Future<void> followUser(String userId, {String? sourceRoomId}) async {
    try {
      await _socialService.followUser(userId, sourceRoomId: sourceRoomId);
    } on DioException catch (e) {
      throw _mapFailure(e);
    } catch (e) {
      throw const Failure.unknown();
    }
  }

  Future<void> unfollowUser(String userId) async {
    try {
      await _socialService.unfollowUser(userId);
    } on DioException catch (e) {
      throw _mapFailure(e);
    } catch (e) {
      throw const Failure.unknown();
    }
  }

  Future<bool> isFollowing(String userId) async {
    try {
      return await _socialService.isFollowing(userId);
    } on DioException catch (e) {
      throw _mapFailure(e);
    } catch (e) {
      throw const Failure.unknown();
    }
  }

  Future<SocialStats> getSocialStats(String userId) async {
    try {
      final data = await _socialService.getSocialStats(userId);
      return SocialStats.fromJson(data);
    } on DioException catch (e) {
      throw _mapFailure(e);
    } catch (e) {
      throw const Failure.unknown();
    }
  }

  Future<List<Profile>> getFollowers({int page = 1, int limit = 20}) async {
    try {
      final list = await _socialService.getFollowers(page: page, limit: limit);
      return list.map((json) => Profile.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _mapFailure(e);
    } catch (e) {
      throw const Failure.unknown();
    }
  }

  Future<List<Profile>> getFollowing({int page = 1, int limit = 20}) async {
    try {
      final list = await _socialService.getFollowing(page: page, limit: limit);
      return list.map((json) => Profile.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _mapFailure(e);
    } catch (e) {
      throw const Failure.unknown();
    }
  }

  
  Future<({List<FollowUser> items, int total})> getUserFollowers(
    String userId, {
    int page = 1,
    int limit = 30,
  }) async {
    try {
      final res = await _socialService.getUserFollowers(userId, page: page, limit: limit);
      return (
        items: res.items.map(FollowUser.fromJson).toList(),
        total: res.total,
      );
    } on DioException catch (e) {
      throw _mapFailure(e);
    } catch (e) {
      throw const Failure.unknown();
    }
  }

  Future<({List<FollowUser> items, int total})> getUserFollowing(
    String userId, {
    int page = 1,
    int limit = 30,
  }) async {
    try {
      final res = await _socialService.getUserFollowing(userId, page: page, limit: limit);
      return (
        items: res.items.map(FollowUser.fromJson).toList(),
        total: res.total,
      );
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
