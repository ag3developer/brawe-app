import 'package:brawe_app/data/repositories/notifications_repository.dart';
import 'package:brawe_app/data/services/app_badge_service.dart';
import 'package:brawe_app/data/services/notifications_service.dart';
import 'package:brawe_app/ui/chat/view_models/unread_count_provider.dart';
import 'package:brawe_app/ui/core/view_models/app_badge_controller.dart';
import 'package:brawe_app/ui/notifications/view_models/notifications_view_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Testes do AppBadgeController — o badge do ícone deve ser SEMPRE a soma das
/// fontes de "não lidos" que já existem no projeto (notificações + DMs), sem
/// criar contadores paralelos.
void main() {
  /// Monta um container com as duas fontes de não-lidos e o badge service
  /// "fakeados" para que possamos inspecionar o que foi enviado ao SO.
  ProviderContainer makeContainer({
    required _FakeNotificationsRepo notifRepo,
    required int dmCount,
    required _RecordingBadgeService badge,
  }) {
    final container = ProviderContainer(
      overrides: [
        notificationsRepositoryProvider.overrideWithValue(notifRepo),
        unreadCountProvider.overrideWith(() => _FakeUnreadCount(dmCount)),
        appBadgeServiceProvider.overrideWithValue(badge),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  group('AppBadgeController — soma das fontes', () {
    test('soma notificações + DMs e envia o total ao badge do SO', () async {
      final badge = _RecordingBadgeService();
      final container = makeContainer(
        notifRepo: _FakeNotificationsRepo(3),
        dmCount: 5,
        badge: badge,
      );

      // Instancia o controller (dispara o primeiro build).
      container.read(appBadgeControllerProvider);
      // Aguarda a contagem assíncrona de notificações resolver e o rebuild.
      await container.read(notificationsUnreadCountProvider.future);
      await pumpEventQueue();

      expect(container.read(appBadgeControllerProvider), 8);
      expect(badge.calls.last, 8);
    });

    test('apenas DMs (notificações = 0)', () async {
      final badge = _RecordingBadgeService();
      final container = makeContainer(
        notifRepo: _FakeNotificationsRepo(0),
        dmCount: 4,
        badge: badge,
      );

      container.read(appBadgeControllerProvider);
      await container.read(notificationsUnreadCountProvider.future);
      await pumpEventQueue();

      expect(container.read(appBadgeControllerProvider), 4);
      expect(badge.calls.last, 4);
    });

    test('apenas notificações (DMs = 0)', () async {
      final badge = _RecordingBadgeService();
      final container = makeContainer(
        notifRepo: _FakeNotificationsRepo(7),
        dmCount: 0,
        badge: badge,
      );

      container.read(appBadgeControllerProvider);
      await container.read(notificationsUnreadCountProvider.future);
      await pumpEventQueue();

      expect(container.read(appBadgeControllerProvider), 7);
      expect(badge.calls.last, 7);
    });

    test('zero não-lidos limpa o badge (envia 0)', () async {
      final badge = _RecordingBadgeService();
      final container = makeContainer(
        notifRepo: _FakeNotificationsRepo(0),
        dmCount: 0,
        badge: badge,
      );

      container.read(appBadgeControllerProvider);
      await container.read(notificationsUnreadCountProvider.future);
      await pumpEventQueue();

      expect(container.read(appBadgeControllerProvider), 0);
      expect(badge.calls.last, 0);
    });
  });

  group('AppBadgeController.refresh', () {
    test('recalcula o badge após a contagem de notificações mudar', () async {
      final badge = _RecordingBadgeService();
      final repo = _FakeNotificationsRepo(2);
      final container = makeContainer(
        notifRepo: repo,
        dmCount: 1,
        badge: badge,
      );

      container.read(appBadgeControllerProvider);
      await container.read(notificationsUnreadCountProvider.future);
      await pumpEventQueue();
      expect(container.read(appBadgeControllerProvider), 3); // 2 + 1

      // Simula novas notificações chegando no backend.
      repo.count = 6;
      container.read(appBadgeControllerProvider.notifier).refresh();
      await container.read(notificationsUnreadCountProvider.future);
      await pumpEventQueue();

      expect(container.read(appBadgeControllerProvider), 7); // 6 + 1
      expect(badge.calls.last, 7);
    });
  });

  group('AppBadgeService — guarda de plataforma', () {
    // No host de teste (macOS/CI) o serviço deve ser no-op silencioso, sem
    // chamar o plugin nativo nem lançar exceção.
    test('setCount não lança em plataforma não suportada', () async {
      const service = AppBadgeService();
      await expectLater(service.setCount(5), completes);
      await expectLater(service.clear(), completes);
    });

    test('setCount normaliza valores negativos para 0 sem lançar', () async {
      const service = AppBadgeService();
      await expectLater(service.setCount(-3), completes);
    });
  });
}

/// Repositório de notificações fake com contagem mutável (mantém o serviço real
/// com um Dio descartável, como o padrão `_FakeLiveRepository` do projeto).
class _FakeNotificationsRepo extends NotificationsRepository {
  _FakeNotificationsRepo(this.count) : super(NotificationsService(Dio()));

  int count;

  @override
  Future<int> unreadCount() async => count;
}

/// Notifier de DMs fake: retorna um valor fixo sem conectar sockets/HTTP.
class _FakeUnreadCount extends UnreadCount {
  _FakeUnreadCount(this._value);

  final int _value;

  @override
  int build() => _value;

  @override
  Future<void> refresh() async => state = _value;
}

/// Badge service que grava as chamadas em vez de tocar o plugin nativo.
class _RecordingBadgeService extends AppBadgeService {
  _RecordingBadgeService() : super();

  final List<int> calls = [];

  @override
  Future<void> setCount(int count) async => calls.add(count);
}
