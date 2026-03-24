import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../data/repositories/live_repository.dart';
import '../../../domain/models/live_gift.dart';

part 'live_room_gifts_view_model.g.dart';

@riverpod
class LiveRoomGiftsViewModel extends _$LiveRoomGiftsViewModel {
  StreamSubscription<LiveGift>? _subscription;

  @override
  List<LiveGift> build(String roomId) {
    final repository = ref.read(liveRepositoryProvider);
    _subscribe();
    unawaited(repository.connectToRoom(roomId));
    ref.onDispose(() {
      _subscription?.cancel();
      repository.disconnectFromRoom(roomId);
    });
    return [];
  }

  void _subscribe() {
    _subscription?.cancel();
    _subscription = ref.read(liveRepositoryProvider).watchGifts(roomId).listen((
      gift,
    ) {
      final nextState = [...state, gift];
      if (nextState.length > 5) {
        state = nextState.sublist(nextState.length - 5);
      } else {
        state = nextState;
      }

      // Auto-remove after 5 seconds
      Future.delayed(const Duration(seconds: 5), () {
        if (!ref.mounted) {
          return;
        }

        state = state.where((g) => g.id != gift.id).toList();
      });
    });
  }
}
