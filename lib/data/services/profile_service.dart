import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/network/live_dio_provider.dart';
import '../../core/network/dio_provider.dart';

part 'profile_service.g.dart';

@riverpod
ProfileService profileService(Ref ref) {
  return ProfileService(
    ref.watch(liveDioProvider),
    ref.watch(dioProvider),
  );
}

class ProfileService {
  final Dio _dio;        // connect API  (profile/me, avatar, etc.)
  final Dio _braweApi;   // main Brawe API (users/me/username, check-username)

  ProfileService(this._dio, this._braweApi);

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
    String? accountType,
  }) async {
    final body = <String, dynamic>{};
    if (displayName != null) body['display_name'] = displayName;
    if (bio != null) body['bio'] = bio;
    if (socialLinks != null) body['social_links'] = socialLinks;
    // tipo de conta não vai mais aqui: troca pelo POST /profile/me/account-type (com regras)
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

  /// Verifica se o username está disponível.
  /// Retorna `null` se disponível, ou uma mensagem de erro se não estiver.
  /// Salva a data de nascimento (cadastro). O servidor recusa menores de
  /// 18 anos (422 "underage").
  Future<void> updateBirthDate(DateTime date) async {
    final d = '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
    await _dio.put('/profile/me', data: {'birth_date': d});
  }

  /// Interesses do cadastro (nichos: games, music, fashion…).
  Future<void> updateInterests(List<String> interests) async {
    await _dio.put('/profile/me', data: {'interests': interests});
  }

  /// "Sobre você": gênero, país e cidade (Brasil: município do IBGE; outros países: nome da cidade).
  Future<void> updateAbout({required String gender, required String country, String? cityId, String? city}) async {
    await _dio.put('/profile/me', data: {
      'gender': gender,
      'country': country,
      if (cityId != null) 'city_id': cityId,
      if (city != null) 'city': city,
    });
  }

  /// Atualiza só a bio.
  Future<void> updateBio(String bio) async {
    await _dio.put('/profile/me', data: {'bio': bio});
  }

  Future<String?> checkUsernameAvailability(String username) async {
    try {
      final response = await _braweApi.get('/users/check-username/$username');
      final data = response.data;
      final available = data['available'] as bool? ?? false;
      if (available) return null;
      return (data['reason'] as String?) ?? 'Username indisponível';
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        return (e.response?.data['detail'] as String?) ?? 'Username inválido';
      }
      return 'Erro ao verificar username';
    }
  }

  /// Atualiza o username do usuário autenticado.
  /// Lança [DioException] em caso de erro (409 = já em uso, 400 = inválido).
  Future<String> updateUsername(String username) async {
    final response = await _braweApi.put(
      '/users/me/username',
      data: {'username': username.toLowerCase().trim()},
    );
    return response.data['new_username'] as String;
  }
}
