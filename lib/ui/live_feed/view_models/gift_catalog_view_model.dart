import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../data/repositories/gift_repository.dart';
import '../../../domain/models/gift.dart';

part 'gift_catalog_view_model.g.dart';

@riverpod
class GiftCatalogViewModel extends _$GiftCatalogViewModel {
  @override
  FutureOr<List<GiftTier>> build() async {
    return ref.read(giftRepositoryProvider).getGiftCatalog();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => ref.read(giftRepositoryProvider).getGiftCatalog());
  }
}
