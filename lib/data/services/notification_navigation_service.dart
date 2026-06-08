import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../repositories/auth_state_provider.dart';
import '../../routing/router.dart';

part 'notification_navigation_service.g.dart';

/// Centraliza a navegação disparada por toque em notificações (push externo
/// ou item da central de notificações).
///
/// Fonte da verdade do destino: o backend envia no payload `data` a chave
/// `route` (um caminho GoRouter já pronto, ex.: `/post/abc/comments?commentId=x`).
/// Como fallback aceitamos `deepLink` (`brawe://...`) e `link_url`.
///
/// Regras:
///   • Se o usuário não estiver autenticado (ou a sessão ainda estiver
///     carregando), o destino é guardado como *pendente* e consumido assim
///     que a sessão resolver para um usuário logado (ver [consumePending]).
///   • Usa `push` para preservar a tela atual (o usuário volta de onde veio).
class NotificationNavigationService {
  NotificationNavigationService(this._ref);

  final Ref _ref;

  /// Rota aguardando para ser aberta após o login / sessão ficar pronta.
  String? _pendingRoute;

  /// Trata o payload `data` de uma RemoteMessage (push) ou de uma notificação
  /// interna. Extrai a rota e navega (ou guarda como pendente).
  void handleData(Map<String, dynamic>? data) {
    if (data == null || data.isEmpty) return;
    final route = routeFromData(data);
    _go(route);
  }

  /// Navega diretamente para uma rota GoRouter (ou guarda como pendente).
  void handleRoute(String? route) => _go(route);

  /// Consome um destino pendente, se houver. Chamado quando a sessão fica
  /// pronta (login ou restauração de sessão no boot).
  void consumePending() {
    final route = _pendingRoute;
    if (route == null) return;
    _pendingRoute = null;
    _navigate(route);
  }

  /// Limpa qualquer destino pendente (ex.: no logout, para não vazar
  /// navegação entre contas).
  void clearPending() => _pendingRoute = null;

  // ── Internos ───────────────────────────────────────────────────────────

  void _go(String? route) {
    if (route == null || !route.startsWith('/')) return;

    // Só navega para destinos protegidos quando há sessão ativa. Enquanto a
    // sessão carrega (boot a partir de push em estado terminado), guardamos.
    final auth = _ref.read(authStateProvider);
    final isAuthenticated = auth.asData?.value != null;
    if (!isAuthenticated) {
      _pendingRoute = route;
      return;
    }
    _navigate(route);
  }

  void _navigate(String route) {
    try {
      _ref.read(routerProvider).push(route);
    } catch (e) {
      debugPrint('NotificationNavigationService.push falhou ($route): $e');
    }
  }

  /// Extrai a rota GoRouter do payload, na ordem de prioridade:
  /// `route` → `deepLink` (brawe://) → `link_url`.
  ///
  /// Estático e puro (sem `Ref`) para ser testável isoladamente — concentra
  /// toda a lógica de parsing/normalização de destino.
  static String? routeFromData(Map<String, dynamic> data) {
    if (data.isEmpty) return null;

    final direct = data['route'];
    if (direct is String && direct.startsWith('/')) return direct;

    final deep = data['deepLink'] ?? data['deep_link'];
    final fromDeep = routeFromDeepLink(deep);
    if (fromDeep != null) return fromDeep;

    final link = data['link_url'] ?? data['linkUrl'];
    if (link is String) {
      if (link.startsWith('/')) return link;
      final fromLink = routeFromDeepLink(link);
      if (fromLink != null) return fromLink;
    }
    return null;
  }

  /// Converte `brawe://post/abc/comments?commentId=x` em
  /// `/post/abc/comments?commentId=x`. Aceita também https://brawe.app/...
  static String? routeFromDeepLink(Object? deepLink) {
    if (deepLink is! String || deepLink.isEmpty) return null;
    Uri? uri;
    try {
      uri = Uri.parse(deepLink);
    } catch (_) {
      return null;
    }

    // brawe://<host>/<path...>  → host faz parte do caminho lógico.
    if (uri.scheme == 'brawe') {
      final segments = [
        uri.host,
        ...uri.pathSegments,
      ].where((s) => s.isNotEmpty);
      if (segments.isEmpty) return null;
      final path = '/${segments.join('/')}';
      return uri.hasQuery ? '$path?${uri.query}' : path;
    }

    // https://brawe.app/<path...> → usa o path diretamente.
    if (uri.scheme == 'http' || uri.scheme == 'https') {
      if (uri.path.isEmpty || uri.path == '/') return null;
      return uri.hasQuery ? '${uri.path}?${uri.query}' : uri.path;
    }

    return null;
  }
}

@Riverpod(keepAlive: true)
NotificationNavigationService notificationNavigationService(Ref ref) {
  return NotificationNavigationService(ref);
}
