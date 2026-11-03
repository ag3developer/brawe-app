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
      final router = _ref.read(routerProvider);
      final current = router.routerDelegate.currentConfiguration.uri.path;
      final target = Uri.parse(route).path;
      // Conversa: não abre a mesma tela duas vezes e não empilha uma conversa
      // em cima de outra (antes, responder pela notificação abria uma cópia
      // "sem dados" da conversa já aberta).
      if (target.startsWith('/chat/') && target != '/chat/new') {
        if (current == target) return;
        if (current.startsWith('/chat/') && current != '/chat/new') {
          router.pushReplacement(route);
          return;
        }
      }
      router.push(route);
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

    return _awardsSection(data, _baseRoute(data));
  }

  /// `AWARD_RECEIVED` abre o perfil já na seção de prêmios.
  static String? _awardsSection(Map<String, dynamic> data, String? route) {
    final type = (data['type'] ?? data['notification_type'])
        ?.toString()
        .toLowerCase();
    if (type != 'award_received') return route;
    var target = route;
    if (target == null) {
      final uid = data['user_id']?.toString();
      if (uid == null || uid.isEmpty) return null;
      target = '/profile/$uid';
    }
    final isProfile =
        target.startsWith('/profile/') ||
        target.startsWith('/connect/u/') ||
        target.startsWith('/user/');
    if (!isProfile || target.contains('section=')) return target;
    return target.contains('?')
        ? '$target&section=awards'
        : '$target?section=awards';
  }

  static String? _baseRoute(Map<String, dynamic> data) {
    final direct = data['route'];
    if (direct is String && direct.startsWith('/')) return direct;

    final deep = data['deepLink'] ?? data['deep_link'];
    final fromDeep = routeFromDeepLink(deep);
    if (fromDeep != null) return fromDeep;

    final link = data['link_url'] ?? data['linkUrl'];
    if (link is String) {
      if (link.startsWith('/')) return _withQuest(link, data);
      final fromLink = routeFromDeepLink(link);
      if (fromLink != null) return _withQuest(fromLink, data);
    }

    // Missões: abre a tela mesmo sem rota/link (notificações antigas).
    final kind = (data['kind'] ?? data['type'] ?? data['notification_type'])
        ?.toString()
        .toLowerCase();
    if (kind != null && kind.contains('quest')) {
      return _withQuest('/quests', data);
    }
    return null;
  }

  /// "/quests" + `quest_key` dos dados → `/quests?quest=KEY` (destaca a
  /// missão ao abrir).
  static String _withQuest(String route, Map<String, dynamic> data) {
    final key = data['quest_key']?.toString();
    if (key == null || key.isEmpty) return route;
    if (Uri.parse(route).path != '/quests' || route.contains('quest=')) {
      return route;
    }
    return route.contains('?') ? '$route&quest=$key' : '$route?quest=$key';
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
