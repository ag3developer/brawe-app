import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../data/repositories/credits_repository.dart';

part 'credits_view_model.g.dart';

@riverpod
class CreditsViewModel extends _$CreditsViewModel {
  @override
  FutureOr<double> build() async {
    return ref.read(creditsRepositoryProvider).getBalance();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => ref.read(creditsRepositoryProvider).getBalance());
  }
}
