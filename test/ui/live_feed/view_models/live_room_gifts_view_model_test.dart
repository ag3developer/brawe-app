import 'dart:async';

import 'package:brawe_app/data/repositories/live_repository.dart';
import 'package:brawe_app/data/services/live_service.dart';
import 'package:brawe_app/domain/models/live_gift.dart';
import 'package:brawe_app/ui/live_feed/view_models/live_room_gifts_view_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('connects to the room and exposes incoming gifts', () async {
    final repository = _FakeGiftsRepository();
    final container = ProviderContainer(
      overrides: [liveRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    final subscription = container.listen(
      liveRoomGiftsViewModelProvider('room-1'),
      (_, _) {},
      fireImmediately: true,
    );
    addTearDown(subscription.close);

    await Future<void>.delayed(Duration.zero);
    expect(repository.connectedRooms, contains('room-1'));

    repository.pushGift(
      LiveGift(
        id: 'gift-1',
        senderId: 'user-1',
        senderName: 'Alice',
        giftId: 'rose',
        giftName: 'Rose',
        quantity: 2,
        timestamp: DateTime.utc(2026, 3, 24, 2),
      ),
    );

    await Future<void>.delayed(Duration.zero);

    final state = container.read(liveRoomGiftsViewModelProvider('room-1'));
    expect(state, hasLength(1));
    expect(state.single.giftName, 'Rose');
    expect(state.single.quantity, 2);
  });

  test('ignora o mesmo presente recebido mais de uma vez (sem "x3")', () async {
    final repository = _FakeGiftsRepository();
    final container = ProviderContainer(
      overrides: [liveRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    final subscription = container.listen(
      liveRoomGiftsViewModelProvider('room-1'),
      (_, _) {},
      fireImmediately: true,
    );
    addTearDown(subscription.close);
    await Future<void>.delayed(Duration.zero);

    final rose = LiveGift(
      id: 'tx-1',
      senderId: 'user-1',
      senderName: 'Alice',
      giftId: 'rose',
      giftName: 'Rose',
      quantity: 1,
      timestamp: DateTime.utc(2026, 3, 24, 2),
    );
    // Mesmo evento chegando 3× (emissões duplicadas / reconexão).
    repository
      ..pushGift(rose)
      ..pushGift(rose)
      ..pushGift(rose);
    await Future<void>.delayed(Duration.zero);

    final state = container.read(liveRoomGiftsViewModelProvider('room-1'));
    expect(state, hasLength(1));
    expect(state.single.quantity, 1);
  });

  group('faixas de presentes pequenos (estilo TikTok)', () {
    late _FakeGiftsRepository repository;
    late ProviderContainer container;

    setUp(() async {
      repository = _FakeGiftsRepository();
      container = ProviderContainer(
        overrides: [liveRepositoryProvider.overrideWithValue(repository)],
      );
      final sub = container.listen(
        liveRoomGiftsViewModelProvider('room-1'),
        (_, _) {},
        fireImmediately: true,
      );
      addTearDown(() {
        sub.close();
        container.dispose();
      });
      await Future<void>.delayed(Duration.zero);
    });

    LiveGift small(String id, String sender) => LiveGift(
      id: id,
      senderId: sender,
      senderName: sender,
      giftId: 'star',
      giftName: 'Estrela',
      quantity: 1,
      timestamp: DateTime.utc(2026, 3, 24, 2),
    );

    test('mostra até 2 ao mesmo tempo, em faixas diferentes', () async {
      repository
        ..pushGift(small('a', 'u1'))
        ..pushGift(small('b', 'u2'))
        ..pushGift(small('c', 'u3'));
      await Future<void>.delayed(Duration.zero);

      final state = container.read(liveRoomGiftsViewModelProvider('room-1'));
      final animating = state.where((g) => g.isAnimating).map((g) => g.id);
      expect(animating, unorderedEquals(['a', 'b']));

      final vm = container.read(
        liveRoomGiftsViewModelProvider('room-1').notifier,
      );
      expect({vm.laneOf('a'), vm.laneOf('b')}, {0, 1});
      expect(vm.laneOf('c'), isNull); // aguardando faixa livre
    });

    test('animação grande não bloqueia os presentes pequenos', () async {
      repository
        ..pushGift(
          LiveGift(
            id: 'big',
            senderId: 'u9',
            senderName: 'u9',
            giftId: 'dragon',
            giftName: 'Dragão',
            quantity: 1,
            isFullscreen: true,
            timestamp: DateTime.utc(2026, 3, 24, 2),
          ),
        )
        ..pushGift(small('s1', 'u1'));
      await Future<void>.delayed(Duration.zero);

      final state = container.read(liveRoomGiftsViewModelProvider('room-1'));
      expect(state.firstWhere((g) => g.id == 'big').isAnimating, isTrue);
      expect(state.firstWhere((g) => g.id == 's1').isAnimating, isTrue);
    });
  });

  test('keeps at most eight visible gifts in the list', () async {
    final repository = _FakeGiftsRepository();
    final container = ProviderContainer(
      overrides: [liveRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    final subscription = container.listen(
      liveRoomGiftsViewModelProvider('room-1'),
      (_, _) {},
      fireImmediately: true,
    );
    addTearDown(subscription.close);

    await Future<void>.delayed(Duration.zero);

    for (var i = 1; i <= 10; i++) {
      repository.pushGift(
        LiveGift(
          id: 'gift-$i',
          senderId: 'user-$i',
          senderName: 'Sender $i',
          giftId: 'gift-type-$i',
          giftName: 'Gift $i',
          quantity: i,
          timestamp: DateTime.utc(2026, 3, 24, 2, 0, i),
        ),
      );
    }

    await Future<void>.delayed(Duration.zero);

    final state = container.read(liveRoomGiftsViewModelProvider('room-1'));
    expect(state, hasLength(8));
    // Presentes já na tela/fila visual são protegidos; o excedente que
    // chega com o cap cheio (e ainda sem animação) é o que é descartado.
    expect(state.first.id, 'gift-1');
    expect(state.last.id, 'gift-8');
  });
}

class _FakeGiftsRepository extends LiveRepository {
  _FakeGiftsRepository() : super(LiveService(Dio()));

  final StreamController<LiveGift> _giftsController =
      StreamController<LiveGift>.broadcast();
  final Set<String> connectedRooms = <String>{};

  @override
  Future<void> connectToRoom(String roomId) async {
    connectedRooms.add(roomId);
  }

  @override
  void disconnectFromRoom(String roomId) {
    connectedRooms.remove(roomId);
  }

  @override
  Stream<LiveGift> watchGifts(String roomId) => _giftsController.stream;

  void pushGift(LiveGift gift) {
    _giftsController.add(gift);
  }
}
