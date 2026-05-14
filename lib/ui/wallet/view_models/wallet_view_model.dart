import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/repositories/credits_repository.dart';
import '../../../domain/models/wallet.dart';

part 'wallet_view_model.g.dart';

@riverpod
Future<List<WalletTransaction>> walletTransactions(Ref ref) async {
  return ref.read(creditsRepositoryProvider).getTransactions();
}

@riverpod
class WalletViewModel extends _$WalletViewModel {
  @override
  Future<Wallet> build() async {
    return ref.read(creditsRepositoryProvider).getWallet();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(creditsRepositoryProvider).getWallet(),
    );
  }
}
