import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../data/services/storage_service.dart';

/// Sessão encerrada pelo servidor (revogada em "Aparelhos conectados", pelo
/// admin ou por "Proteger conta"). Qualquer 401 de uma requisição autenticada
/// do core ou do Connect liga este aviso; o `AuthState` limpa os tokens e a
/// tela de login mostra "Sua sessão foi encerrada. Entre novamente.".
class SessionEnded extends ChangeNotifier {
  SessionEnded._();

  static final SessionEnded instance = SessionEnded._();

  bool _messagePending = false;
  bool _handling = false;

  /// A tela de login ainda precisa mostrar o aviso?
  bool get messagePending => _messagePending;

  /// Lê e zera o aviso (a tela mostra uma única vez).
  bool takeMessage() {
    final v = _messagePending;
    _messagePending = false;
    return v;
  }

  /// Chamado pelo interceptor. Ignora repetições enquanto trata (evita laço
  /// quando várias requisições falham juntas).
  void trigger() {
    if (_handling) return;
    _handling = true;
    _messagePending = true;
    notifyListeners();
  }

  /// O `AuthState` terminou de limpar a sessão.
  void handled() => _handling = false;

  /// Rotas em que 401 significa "credencial errada", não "sessão encerrada".
  static bool isCredentialPath(String path) {
    final p = path.toLowerCase();
    return p.contains('/auth/login') ||
        p.contains('/auth/logout') ||
        p.contains('/auth/me/password') ||
        p.contains('/auth/me/account') ||
        p.contains('/auth/forgot-password') ||
        p.contains('/auth/reset-password') ||
        p.contains('/auth/register');
  }

  static Interceptor interceptor(StorageService storage) => InterceptorsWrapper(
    onError: (err, handler) async {
      if (err.response?.statusCode == 401 &&
          !isCredentialPath(err.requestOptions.path)) {
        final sent = (err.requestOptions.headers['Authorization'] as String?)
            ?.replaceFirst(RegExp(r'^Bearer\s+', caseSensitive: false), '');
        if (sent != null && sent.isNotEmpty) {
          final current = await storage.getToken();
          // Só encerra se o token recusado ainda é o atual (uma requisição
          // antiga, de antes de "Proteger conta", não derruba a sessão nova).
          if (current != null && current == sent) instance.trigger();
        }
      }
      handler.next(err);
    },
  );
}
