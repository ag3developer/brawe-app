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
    return _unwrap(response.data);
  }

  Future<Map<String, dynamic>> getUserProfile(String userId) async {
    final response = await _dio.get('/profile/$userId');
    return _unwrap(response.data);
  }

  /// Unwraps common backend envelope structures:
  ///   { "data": {...} }  /  { "profile": {...} }  /  { "user": {...} }
  /// Falls back to the raw body when none of those keys exist.
  static Map<String, dynamic> _unwrap(dynamic raw) {
    if (raw is! Map<String, dynamic>) return {};
    final inner = raw['data'] ?? raw['profile'] ?? raw['user'];
    if (inner is Map<String, dynamic>) return inner;
    return raw;
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

  Future<Map<String, dynamic>> updateMyProfile({
    String? displayName,
    String? bio,
    Map<String, String>? socialLinks,
  }) async {
    final body = <String, dynamic>{};
    if (displayName != null) body['display_name'] = displayName;
    if (bio != null) body['bio'] = bio;
    if (socialLinks != null) body['social_links'] = socialLinks;
    final response = await _dio.put('/profile/me', data: body);
    return response.data['data'] ?? response.data;
  }

  Future<String> uploadAvatar(String filePath) async {
    final form = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath),
    });
    final response = await _dio.post(
      '/profile/me/avatar',
      data: form,
      options: Options(contentType: 'multipart/form-data'),
    );
    return response.data['avatar_url'] as String;
  }

  Future<void> deleteAvatar() async {
    await _dio.delete('/profile/me/avatar');
  }

  Future<String> uploadBanner(String filePath) async {
    final form = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath),
    });
    final response = await _dio.post(
      '/profile/me/banner',
      data: form,
      options: Options(contentType: 'multipart/form-data'),
    );
    return response.data['banner_url'] as String;
  }

  Future<void> deleteBanner() async {
    await _dio.delete('/profile/me/banner');
  }

}
