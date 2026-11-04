import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/network/live_dio_provider.dart';

part 'social_service.g.dart';

@riverpod
SocialService socialService(Ref ref) {
  return SocialService(ref.watch(liveDioProvider));
}

class SocialService {
  final Dio _dio;

  SocialService(this._dio);

  Future<void> followUser(String userId) async {
    await _dio.post('/social/follow/$userId');
  }

  Future<void> unfollowUser(String userId) async {
    await _dio.delete('/social/follow/$userId');
  }

  Future<bool> isFollowing(String userId) async {
    final response = await _dio.get('/social/is-following/$userId');
    return response.data['is_following'] ?? false;
  }

  Future<Map<String, dynamic>> getSocialStats(String userId) async {
    final response = await _dio.get('/social/stats/$userId');
    return response.data['data'] ?? response.data;
  }

  Future<List<Map<String, dynamic>>> getFollowers({int page = 1, int limit = 20}) async {
    final response = await _dio.get(
      '/social/followers',
      queryParameters: {'page': page, 'limit': limit},
    );
    final data = response.data['data'] ?? response.data;
    if (data is List) return List<Map<String, dynamic>>.from(data);
    if (data is Map && data['items'] != null) return List<Map<String, dynamic>>.from(data['items']);
    return [];
  }

  Future<List<Map<String, dynamic>>> getFollowing({int page = 1, int limit = 20}) async {
    final response = await _dio.get(
      '/social/following',
      queryParameters: {'page': page, 'limit': limit},
    );
    final data = response.data['data'] ?? response.data;
    if (data is List) return List<Map<String, dynamic>>.from(data);
    if (data is Map && data['items'] != null) return List<Map<String, dynamic>>.from(data['items']);
    return [];
  }

  Future<({List<Map<String, dynamic>> items, int total})> getUserFollowers(
    String userId, {
    int page = 1,
    int limit = 30,
  }) async {
    final response = await _dio.get(
      '/social/followers/$userId',
      queryParameters: {'page': page, 'limit': limit},
    );
    final data = response.data;
    final list = data['data'];
    final items = (list is List)
        ? List<Map<String, dynamic>>.from(list)
        : <Map<String, dynamic>>[];
    final total = (data['total'] as num?)?.toInt() ?? items.length;
    return (items: items, total: total);
  }

  Future<({List<Map<String, dynamic>> items, int total})> getUserFollowing(
    String userId, {
    int page = 1,
    int limit = 30,
  }) async {
    final response = await _dio.get(
      '/social/following/$userId',
      queryParameters: {'page': page, 'limit': limit},
    );
    final data = response.data;
    final list = data['data'];
    final items = (list is List)
        ? List<Map<String, dynamic>>.from(list)
        : <Map<String, dynamic>>[];
    final total = (data['total'] as num?)?.toInt() ?? items.length;
    return (items: items, total: total);
  }

  Future<List<Map<String, dynamic>>> getSuggestions({int limit = 12}) async {
    final response = await _dio.get(
      '/social/suggestions',
      queryParameters: {'limit': limit},
    );
    final data = response.data;
    if (data is List) return List<Map<String, dynamic>>.from(data);
    final list = data['data'] ?? data['users'] ?? data['items'];
    if (list is List) return List<Map<String, dynamic>>.from(list);
    return [];
  }

  /// Busca pessoas por nome ou @usuário.
  Future<List<Map<String, dynamic>>> searchUsers(String query, {int limit = 20}) async {
    final response = await _dio.get(
      '/social/users/search',
      queryParameters: {'q': query, 'limit': limit},
    );
    final list = response.data is Map ? response.data['data'] : response.data;
    if (list is List) return List<Map<String, dynamic>>.from(list);
    return [];
  }
}
