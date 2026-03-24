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

  test('keeps at most five visible gifts in the queue', () async {
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

    for (var i = 1; i <= 6; i++) {
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
    expect(state, hasLength(5));
    expect(state.first.id, 'gift-2');
    expect(state.last.id, 'gift-6');
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
