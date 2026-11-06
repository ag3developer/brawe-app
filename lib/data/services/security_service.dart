import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/dio_provider.dart';
import '../../domain/models/account_security.dart';
import 'storage_service.dart';

enum SecurityErrorKind { unavailable, network, unauthorized, server }

/// Erro tratado das chamadas de segurança. `unavailable` = 404/501 (o
/// servidor ainda não publicou o endpoint): a tela mostra um aviso amigável.
class SecurityException implements Exception {
  const SecurityException(this.kind);
  final SecurityErrorKind kind;

  static SecurityException from(Object e) {
    if (e is SecurityException) return e;
    if (e is DioException) {
      final code = e.response?.statusCode;
      if (code == 404 || code == 501) {
        return const SecurityException(SecurityErrorKind.unavailable);
      }
      if (code == 401) {
        return const SecurityException(SecurityErrorKind.unauthorized);
      }
      if (code == null) {
        return const SecurityException(SecurityErrorKind.network);
      }
    }
    return const SecurityException(SecurityErrorKind.server);
  }

  @override
  String toString() => 'SecurityException($kind)';
}

/// Resultado de "Proteger conta".
class SecureAccountResult {
  const SecureAccountResult({required this.accessToken, this.mustChange = true});
  final String accessToken;
  final bool mustChange;
}

/// Resposta de `DELETE /auth/sessions/{id}`: `{revoked, current}`.
class RevokeResult {
  const RevokeResult({required this.revoked, required this.current});
  final bool revoked;

  /// Era a sessão deste aparelho: o app precisa sair localmente.
  final bool current;
}

class SecurityService {
  SecurityService(this._dio, this._storage);
  final Dio _dio;
  final StorageService _storage;

  Future<T> _run<T>(Future<T> Function() f) async {
    try {
      return await f();
    } catch (e) {
      throw SecurityException.from(e);
    }
  }

  Future<SessionsData> sessions() => _run(() async {
    final r = await _dio.get('/auth/sessions');
    return SessionsData.fromJson(Map<String, dynamic>.from(r.data as Map));
  });

  Future<RevokeResult> revokeSession(String id) => _run(() async {
    final r = await _dio.delete('/auth/sessions/$id');
    final d = r.data;
    return RevokeResult(
      revoked: d is Map ? d['revoked'] != false : true,
      current: d is Map && d['current'] == true,
    );
  });

  /// `POST /auth/sessions/revoke-others` → `{revoked:n}`.
  Future<int> revokeOthers() => _run(() async {
    final r = await _dio.post('/auth/sessions/revoke-others');
    final d = r.data;
    return d is Map ? (d['revoked'] as num?)?.toInt() ?? 0 : 0;
  });

  Future<void> logout() => _run(() => _dio.post('/auth/logout'));

  Future<SecurityEventsPage> events({int page = 1, int pageSize = 20}) =>
      _run(() async {
        final r = await _dio.get(
          '/auth/security-events',
          queryParameters: {'page': page, 'page_size': pageSize},
        );
        return SecurityEventsPage.fromJson(
          Map<String, dynamic>.from(r.data as Map),
        );
      });

  /// Encerra todas as outras sessões e devolve um token novo; o token
  /// guardado é trocado antes de a tela de nova senha abrir.
  Future<SecureAccountResult> secureAccount() => _run(() async {
    final r = await _dio.post('/auth/secure-account');
    final data = Map<String, dynamic>.from(r.data as Map);
    final token = data['access_token'];
    if (token is! String || token.trim().isEmpty) {
      throw const SecurityException(SecurityErrorKind.server);
    }
    await _storage.saveToken(token);
    return SecureAccountResult(
      accessToken: token,
      mustChange: data['must_change_password'] != false,
    );
  });
}

final securityServiceProvider = Provider<SecurityService>(
  (ref) => SecurityService(ref.watch(dioProvider), ref.watch(storageServiceProvider)),
);
