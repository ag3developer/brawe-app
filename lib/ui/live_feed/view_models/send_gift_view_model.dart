import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../data/repositories/gift_repository.dart';

part 'send_gift_view_model.g.dart';

@riverpod
class SendGiftViewModel extends _$SendGiftViewModel {
  @override
  AsyncValue<void> build() {
    return const AsyncValue.data(null);
  }

  Future<bool> sendGift({
    required String roomId,
    required String giftId,
    int quantity = 1,
    String? battleId,
  }) async {
    state = const AsyncValue.loading();
    
    try {
      await ref.read(giftRepositoryProvider).sendGift(
        roomId: roomId,
        giftId: giftId,
        quantity: quantity,
        battleId: battleId,
      );
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}
