import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/network/dio_provider.dart';

part 'auth_service.g.dart';

@riverpod
AuthService authService(Ref ref) {
  return AuthService(ref.watch(dioProvider));
}

class AuthService {
  final Dio _dio;

  AuthService(this._dio);

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _dio.post(
      '/auth/login',
      data: {
        'email': email,
        'password': password,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> registerAffiliate({
    required String email,
    required String password,
    required String name,
    String? sponsorCode,
  }) async {
    final response = await _dio.post(
      '/auth/register/affiliate',
      data: {
        'email': email,
        'password': password,
        'name': name,
        if (sponsorCode != null && sponsorCode.isNotEmpty) 'sponsor_code': sponsorCode,
      },
    );
    return response.data as Map<String, dynamic>;
  }
}
