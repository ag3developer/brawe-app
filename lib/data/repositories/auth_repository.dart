import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/models/failure.dart';
import '../../domain/models/user.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';

part 'auth_repository.g.dart';

/// Login arriscado (aparelho novo etc.): o servidor mandou um código por
/// e-mail. Chega como 403 `{detail:{code:"step_up_required", challenge_id,
/// email_masked}}` (ou os campos no topo).
class StepUpRequiredException implements Exception {
  const StepUpRequiredException({
    required this.challengeId,
    required this.emailMasked,
    this.resendIn = 60,
    this.expiresIn = 600,
  });

  final String challengeId;
  final String emailMasked;

  /// Segundos até poder reenviar o código (`resend_in` do servidor).
  final int resendIn;
  final int expiresIn;

  static StepUpRequiredException? fromResponse(Response? res) {
    if (res == null || res.statusCode != 403) return null;
    final data = res.data;
    if (data is! Map) return null;
    final detail = data['detail'];
    final src = detail is Map ? detail : data;
    if (src['code'] != 'step_up_required') return null;
    final id = src['challenge_id'];
    if (id is! String || id.isEmpty) return null;
    return StepUpRequiredException(
      challengeId: id,
      emailMasked: (src['email_masked'] as String?) ?? '',
      resendIn: (src['resend_in'] as num?)?.toInt() ?? 60,
      expiresIn: (src['expires_in'] as num?)?.toInt() ?? 600,
    );
  }
}

/// `retry_after` (segundos) de um 429 `{code:"too_many_attempts", retry_after}`
/// — no topo, dentro de `detail` ou no cabeçalho Retry-After.
int? retryAfterSeconds(Response? res) {
  final data = res?.data;
  num? v;
  if (data is Map) {
    v = data['retry_after'] as num?;
    final d = data['detail'];
    if (v == null && d is Map) v = d['retry_after'] as num?;
  }
  v ??= int.tryParse(res?.headers.value('retry-after') ?? '');
  return v?.toInt();
}

/// "Muitas tentativas. Tente de novo em 2 min." (com contagem quando houver).
String tooManyAttemptsMessage(int? seconds) {
  if (seconds == null || seconds <= 0) {
    return 'Muitas tentativas. Tente novamente em instantes.';
  }
  final text = seconds >= 90
      ? '${(seconds / 60).ceil()} min'
      : '$seconds s';
  return 'Muitas tentativas. Tente novamente em $text.';
}

@riverpod
AuthRepository authRepository(Ref ref) {
  return AuthRepository(
    ref.watch(authServiceProvider),
    ref.watch(storageServiceProvider),
  );
}

class AuthRepository {
  final AuthService _authService;
  final StorageService _storageService;

  AuthRepository(this._authService, this._storageService);

  Future<User> login(String email, String password) async {
    try {
      final data = await _authService.login(email, password);

      // Persist the token first so the follow-up /auth/me (fallback) call is
      // authenticated even when the inline user payload can't be parsed.
      final token = _extractToken(data);
      if (token != null) {
        await _storageService.saveToken(token);
      }

      User user;
      try {
        final userData = data['user'] as Map<String, dynamic>;
        user = User.fromJson(userData);
      } catch (_) {
        user = await getCurrentUser();
      }

      await _storageService.saveUser(user);
      return user;
    } on DioException catch (e) {
      final stepUp = StepUpRequiredException.fromResponse(e.response);
      if (stepUp != null) throw stepUp;
      // 401 during login attempt means invalid credentials (not an expired
      // session). Surface a clear message to the user instead of the generic
      // "Session expired" wording used for already-authenticated requests.
      if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
        throw const Failure.validation('E-mail ou senha incorretos.');
      }
      if (e.response?.statusCode == 422 || e.response?.statusCode == 400) {
        throw Failure.validation(_extractServerMessage(e.response?.data) ??
            'Dados inválidos. Confira e tente novamente.');
      }
      if (e.response?.statusCode == 404) {
        throw const Failure.validation('Conta não encontrada.');
      }
      if (e.response?.statusCode == 429) {
        throw Failure.validation(
          tooManyAttemptsMessage(retryAfterSeconds(e.response)),
        );
      }
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw const Failure.network();
      }
      throw const Failure.server();
    } on StepUpRequiredException {
      rethrow;
    } on Failure {
      rethrow;
    } catch (_) {
      throw const Failure.unknown();
    }
  }

  /// Conclui um login que pediu verificação (`step_up_required`): troca o
  /// código recebido por e-mail pela sessão normal.
  Future<User> stepUp(String challengeId, String code) async {
    final data = await _authService.loginStepUp(challengeId, code);
    return _finishLogin(data);
  }

  /// Reenvia o código do mesmo desafio (`POST /auth/login/step-up/resend`),
  /// sem repetir o login com senha. Devolve `resend_in` (segundos).
  Future<int> resendStepUp(String challengeId) =>
      _authService.loginStepUpResend(challengeId);

  Future<User> _finishLogin(Map<String, dynamic> data) async {
    final token = _extractToken(data);
    if (token != null) await _storageService.saveToken(token);
    User user;
    try {
      user = User.fromJson(data['user'] as Map<String, dynamic>);
    } catch (_) {
      user = await getCurrentUser();
    }
    await _storageService.saveUser(user);
    return user;
  }

  Future<User> registerAffiliate({
    required String email,
    required String password,
    required String name,
    String? sponsorCode,
    bool termsAccepted = false,
    bool privacyAccepted = false,
    String? emailVerificationToken,
  }) async {
    try {
      final data = await _authService.registerAffiliate(
        email: email,
        password: password,
        name: name,
        sponsorCode: sponsorCode,
        termsAccepted: termsAccepted,
        privacyAccepted: privacyAccepted,
        emailVerificationToken: emailVerificationToken,
      );

      // Persist the token first so any follow-up calls are authenticated even
      // if parsing the inline user object fails.
      final token = _extractToken(data);
      if (token != null) {
        await _storageService.saveToken(token);
      }

      User user;
      try {
        final userData = data['user'] as Map<String, dynamic>;
        user = User.fromJson(userData);
      } catch (_) {
        // Backend may return a minimal user payload that doesn't match our
        // strict schema. Fall back to /auth/me to get the canonical profile.
        user = await getCurrentUser();
      }

      await _storageService.saveUser(user);
      return user;
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final serverMsg = _extractServerMessage(e.response?.data);
      if (status == 409) {
        throw const Failure.validation(
            'Este e-mail já está cadastrado. Tente entrar.');
      }
      if (status == 422 || status == 400) {
        throw Failure.validation(
            serverMsg ?? 'Dados inválidos. Confira e tente novamente.');
      }
      if (status == 401 || status == 403) {
        throw Failure.validation(
            serverMsg ?? 'Não foi possível criar a conta.');
      }
      if (status == 429) {
        throw const Failure.validation(
            'Muitas tentativas. Tente novamente em instantes.');
      }
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw const Failure.network();
      }
      // Any other server-side error: surface backend message when available.
      throw Failure.validation(
          serverMsg ?? 'Não foi possível criar a conta. Tente novamente.');
    } on Failure {
      rethrow;
    } catch (_) {
      throw const Failure.unknown();
    }
  }

  Future<User?> getSession() async {
    final user = await _storageService.getUser();
    final token = await _storageService.getToken();

    if (token != null) {
      // If we have a token, we should try to refresh the user from the API
      try {
        final apiUser = await getCurrentUser();
        await _storageService.saveUser(apiUser);
        return apiUser;
      } on UnauthorizedFailure {
        // Token recusado (sessão revogada): não mantém um login fantasma.
        await _storageService.clearAll();
        return null;
      } catch (_) {
        // If API call fails, fallback to local storage
        return user;
      }
    }
    return user;
  }

  Future<User> getCurrentUser() async {
    try {
      final userData = await _authService.getCurrentUser();
      return User.fromJson(userData);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw const Failure.unauthorized();
      }
      throw const Failure.server();
    } catch (e) {
      throw const Failure.unknown();
    }
  }

  Future<void> logout() async {
    // Encerra a sessão também no servidor (melhor esforço: sem rede ou com
    // servidor antigo, o logout local acontece do mesmo jeito).
    try {
      await _authService.logoutServer().timeout(const Duration(seconds: 4));
    } catch (_) {}
    await _storageService.clearAll();
  }

  /// Troca o token guardado (ex.: depois de "Proteger conta" ou de trocar a
  /// senha, quando o servidor devolve um `access_token` novo).
  Future<void> replaceToken(String token) => _storageService.saveToken(token);

  String? _extractToken(Map<String, dynamic> payload) {
    final directToken = payload['access_token'] ?? payload['token'];
    if (directToken is String && directToken.trim().isNotEmpty) {
      return directToken;
    }

    final nestedData = payload['data'];
    if (nestedData is Map) {
      final nestedToken = nestedData['access_token'] ?? nestedData['token'];
      if (nestedToken is String && nestedToken.trim().isNotEmpty) {
        return nestedToken;
      }
    }

    return null;
  }

  /// Attempts to extract a human-friendly error message from a FastAPI/Dio
  /// response body. Supports {detail: "msg"}, {detail: [{msg: ...}]} and
  /// {message: ...} shapes returned by our backend.
  String? _extractServerMessage(dynamic data) {
    if (data is Map) {
      final detail = data['detail'];
      if (detail is String && detail.trim().isNotEmpty) return detail;
      if (detail is List && detail.isNotEmpty) {
        final first = detail.first;
        if (first is Map) {
          final msg = first['msg'];
          if (msg is String && msg.trim().isNotEmpty) return msg;
        }
      }
      final message = data['message'];
      if (message is String && message.trim().isNotEmpty) return message;
      final error = data['error'];
      if (error is String && error.trim().isNotEmpty) return error;
    }
    return null;
  }
}
