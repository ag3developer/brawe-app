import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../data/repositories/gift_repository.dart';
import '../../../domain/models/gifter.dart';

part 'top_gifters_view_model.g.dart';

@riverpod
class TopGiftersViewModel extends _$TopGiftersViewModel {
  @override
  FutureOr<List<Gifter>> build(String roomId) async {
    return ref.read(giftRepositoryProvider).getTopGifters(roomId);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => ref.read(giftRepositoryProvider).getTopGifters(roomId));
  }
}
