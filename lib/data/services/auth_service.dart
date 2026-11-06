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

  /// POST /auth/logout — revoga a sessão atual no servidor.
  Future<void> logoutServer() async {
    await _dio.post<dynamic>('/auth/logout');
  }

  AuthService(this._dio);

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _dio.post(
      '/auth/login',
      data: {'email': email, 'password': password},
    );
    return response.data as Map<String, dynamic>;
  }

  /// Segundo passo do login arriscado: `{challenge_id, code}` → login normal.
  Future<Map<String, dynamic>> loginStepUp(
    String challengeId,
    String code,
  ) async {
    final response = await _dio.post(
      '/auth/login/step-up',
      data: {'challenge_id': challengeId, 'code': code},
    );
    return response.data as Map<String, dynamic>;
  }

  /// Reenvia o código do desafio de step-up. Devolve `resend_in` (s).
  Future<int> loginStepUpResend(String challengeId) async {
    final response = await _dio.post(
      '/auth/login/step-up/resend',
      data: {'challenge_id': challengeId},
    );
    final d = response.data;
    return d is Map ? (d['resend_in'] as num?)?.toInt() ?? 60 : 60;
  }

  Future<Map<String, dynamic>> registerAffiliate({
    required String email,
    required String password,
    required String name,
    String? sponsorCode,
    bool termsAccepted = false,
    bool privacyAccepted = false,
    String? emailVerificationToken,
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
        if (emailVerificationToken != null)
          'email_verification_token': emailVerificationToken,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  /// Cadastro: envia o código de 6 dígitos para o e-mail (a conta ainda
  /// NÃO existe). 409 = e-mail já cadastrado; 429 = reenvio cedo demais.
  Future<Map<String, dynamic>> sendRegisterCode(
    String email, {
    String? language,
  }) async {
    final response = await _dio.post(
      '/auth/register/send-code',
      data: {'email': email, 'language': ?language},
    );
    return response.data as Map<String, dynamic>;
  }

  /// Confere o código. Devolve o passe (`verification_token`) usado para
  /// criar a conta com o e-mail já confirmado.
  Future<String> verifyRegisterCode(String email, String code) async {
    final response = await _dio.post(
      '/auth/register/verify-code',
      data: {'email': email, 'code': code},
    );
    return (response.data as Map)['verification_token'] as String;
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
  /// Devolve o `access_token` novo, se o servidor mandou (a troca de senha
  /// encerra as outras sessões e renova a atual).
  Future<String?> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final response = await _dio.put(
      '/auth/me/password',
      data: {
        'current_password': currentPassword,
        'new_password': newPassword,
      },
    );
    final data = response.data;
    final token = data is Map ? data['access_token'] : null;
    return token is String && token.trim().isNotEmpty ? token : null;
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
