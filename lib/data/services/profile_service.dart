import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/network/live_dio_provider.dart';

part 'profile_service.g.dart';

@riverpod
ProfileService profileService(Ref ref) {
  return ProfileService(ref.watch(liveDioProvider));
}

class ProfileService {
  final Dio _dio;

  ProfileService(this._dio);

  Future<Map<String, dynamic>> getMyProfile() async {
    final response = await _dio.get('/profile/me');
    return response.data['data'] ?? response.data;
  }

  Future<Map<String, dynamic>> getUserProfile(String userId) async {
    final response = await _dio.get('/profile/$userId');
    return response.data['data'] ?? response.data;
  }

  Future<List<Map<String, dynamic>>> getTopStreamers({int limit = 20}) async {
    final response = await _dio.get(
      '/profile/top-streamers',
      queryParameters: {'limit': limit},
    );
    final data = response.data['data'] ?? response.data;
    if (data is List) {
      return List<Map<String, dynamic>>.from(data);
    }
    return [];
  }

  Future<List<Map<String, dynamic>>> getUserLives(
    String userId, {
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _dio.get(
      '/profile/$userId/lives',
      queryParameters: {'page': page, 'limit': limit},
    );
    final data = response.data['data'] ?? response.data;
    if (data is List) {
      return List<Map<String, dynamic>>.from(data);
    }
    if (data is Map && (data['rooms'] != null || data['items'] != null)) {
      return List<Map<String, dynamic>>.from(data['rooms'] ?? data['items']);
    }
    return [];
  }
}
