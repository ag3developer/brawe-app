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
    _subscribe();
    ref.onDispose(() => _subscription?.cancel());
    return [];
  }

  void _subscribe() {
    _subscription?.cancel();
    _subscription = ref.read(liveRepositoryProvider).watchGifts(roomId).listen((gift) {
      // Add to list and keep only last 5 for animation queue
      final currentGifts = state;
      state = [...currentGifts, gift];
      
      // Auto-remove after 5 seconds
      Future.delayed(const Duration(seconds: 5), () {
        if (ref.exists(liveRoomGiftsViewModelProvider(roomId))) {
          state = state.where((g) => g.id != gift.id).toList();
        }
      });
    });
  }
}
