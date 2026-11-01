import 'package:brawe_app/data/services/notification_navigation_service.dart';
import 'package:flutter_test/flutter_test.dart';

/// Testes da lógica PURA de resolução de destino do
/// NotificationNavigationService (parsing de payload `data` → rota GoRouter).
///
/// Espelha o que o backend (app/core/deeplink.py) envia: a chave `route` já
/// vem pronta, com `deepLink` (brawe://) e `link_url` como fallbacks.
void main() {
  group('routeFromData — prioridade de chaves', () {
    test('usa `route` diretamente quando presente', () {
      final r = NotificationNavigationService.routeFromData({
        'route': '/post/p1/comments?commentId=c5',
        'deepLink': 'brawe://post/p1',
      });
      expect(r, '/post/p1/comments?commentId=c5');
    });

    test('cai para `deepLink` quando não há `route`', () {
      final r = NotificationNavigationService.routeFromData({
        'deepLink': 'brawe://user/u1',
      });
      expect(r, '/user/u1');
    });

    test('cai para `link_url` quando não há `route` nem `deepLink`', () {
      final r = NotificationNavigationService.routeFromData({
        'link_url': '/profile/u9',
      });
      expect(r, '/profile/u9');
    });

    test('payload vazio retorna null', () {
      expect(NotificationNavigationService.routeFromData({}), isNull);
    });

    test('payload sem chaves de navegação retorna null', () {
      final r = NotificationNavigationService.routeFromData({
        'type': 'system',
        'title': 'Olá',
      });
      expect(r, isNull);
    });

    test('ignora `route` que não começa com / e tenta o próximo fallback', () {
      final r = NotificationNavigationService.routeFromData({
        'route': 'post/p1', // inválido (sem barra)
        'deepLink': 'brawe://post/p1',
      });
      expect(r, '/post/p1');
    });
  });

  group('routeFromDeepLink — esquema brawe://', () {
    test('converte host + path em caminho lógico', () {
      expect(
        NotificationNavigationService.routeFromDeepLink('brawe://post/abc'),
        '/post/abc',
      );
    });

    test('preserva query string (commentId)', () {
      expect(
        NotificationNavigationService.routeFromDeepLink(
          'brawe://post/abc/comments?commentId=x',
        ),
        '/post/abc/comments?commentId=x',
      );
    });

    test('chat com conversationId', () {
      expect(
        NotificationNavigationService.routeFromDeepLink('brawe://chat/conv1'),
        '/chat/conv1',
      );
    });

    test('live room', () {
      expect(
        NotificationNavigationService.routeFromDeepLink('brawe://live/l1'),
        '/live/l1',
      );
    });
  });

  group('routeFromDeepLink — esquema https (App Links)', () {
    test('usa o path do link https://brawe.app/...', () {
      expect(
        NotificationNavigationService.routeFromDeepLink(
          'https://brawe.app/post/abc',
        ),
        '/post/abc',
      );
    });

    test('preserva query no https', () {
      expect(
        NotificationNavigationService.routeFromDeepLink(
          'https://brawe.app/post/abc/comments?commentId=z',
        ),
        '/post/abc/comments?commentId=z',
      );
    });

    test('raiz https sem path retorna null (nada para navegar)', () {
      expect(
        NotificationNavigationService.routeFromDeepLink('https://brawe.app/'),
        isNull,
      );
    });
  });

  group('routeFromDeepLink — entradas inválidas', () {
    test('null retorna null', () {
      expect(NotificationNavigationService.routeFromDeepLink(null), isNull);
    });

    test('string vazia retorna null', () {
      expect(NotificationNavigationService.routeFromDeepLink(''), isNull);
    });

    test('tipo não-string retorna null', () {
      expect(NotificationNavigationService.routeFromDeepLink(42), isNull);
    });

    test('esquema desconhecido retorna null', () {
      expect(
        NotificationNavigationService.routeFromDeepLink('ftp://x/y'),
        isNull,
      );
    });

    test('brawe:// sem host/path retorna null', () {
      expect(NotificationNavigationService.routeFromDeepLink('brawe://'), isNull);
    });
  });

  group('AWARD_RECEIVED', () {
    test('abre o perfil na seção de prêmios', () {
      expect(
        NotificationNavigationService.routeFromData({
          'type': 'AWARD_RECEIVED',
          'route': '/profile/u1',
        }),
        '/profile/u1?section=awards',
      );
      expect(
        NotificationNavigationService.routeFromData({
          'type': 'award_received',
          'link_url': 'brawe://user/u1',
        }),
        '/user/u1?section=awards',
      );
      expect(
        NotificationNavigationService.routeFromData({
          'type': 'AWARD_RECEIVED',
          'user_id': 'u9',
        }),
        '/profile/u9?section=awards',
      );
    });

    test('não mexe em outras rotas nem duplica section', () {
      expect(
        NotificationNavigationService.routeFromData({
          'type': 'AWARD_RECEIVED',
          'route': '/profile/u1?section=awards',
        }),
        '/profile/u1?section=awards',
      );
      expect(
        NotificationNavigationService.routeFromData({
          'type': 'gift_received',
          'route': '/profile/u1',
        }),
        '/profile/u1',
      );
    });
  });
}
