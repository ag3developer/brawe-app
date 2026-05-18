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
      data: {'email': email, 'password': password},
    );
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> registerAffiliate({
    required String email,
    required String password,
    required String name,
    String? sponsorCode,
    bool termsAccepted = false,
    bool privacyAccepted = false,
  }) async {
    final response = await _dio.post(
      '/auth/register/affiliate',
      data: {
        'email': email,
        'password': password,
        'name': name,
        if (sponsorCode != null && sponsorCode.isNotEmpty)
          'sponsor_code': sponsorCode,
        'terms_accepted': termsAccepted,
        'privacy_accepted': privacyAccepted,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getCurrentUser() async {
    final response = await _dio.get('/auth/me');
    return response.data as Map<String, dynamic>;
  }

  /// Inicia recuperação de senha. Backend sempre responde 200 (não vaza
  /// se o email existe). Se existir, dispara email com token JWT (15min).
  Future<void> forgotPassword(String email) async {
    await _dio.post('/auth/forgot-password', data: {'email': email});
  }

  /// Conclui recuperação de senha via token recebido por email.
  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    await _dio.post(
      '/auth/reset-password',
      data: {'token': token, 'new_password': newPassword},
    );
  }

  /// Altera a senha do usuário autenticado.
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _dio.put(
      '/auth/me/password',
      data: {
        'current_password': currentPassword,
        'new_password': newPassword,
      },
    );
  }

  /// Exclui (soft delete + anonimização LGPD) a conta do usuário.
  /// Requer a senha atual para confirmação.
  Future<void> deleteAccount(String password) async {
    await _dio.delete(
      '/auth/me/account',
      data: {'password': password},
    );
  }
}
