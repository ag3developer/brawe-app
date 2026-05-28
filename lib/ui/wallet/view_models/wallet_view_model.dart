import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/repositories/credits_repository.dart';
import '../../../domain/models/gifter_summary.dart';
import '../../../domain/models/wallet.dart';

part 'wallet_view_model.g.dart';

@riverpod
Future<List<WalletTransaction>> walletTransactions(Ref ref) async {
  return ref.read(creditsRepositoryProvider).getTransactions();
}

/// Lista de pessoas agrupadas (estilo TikTok).
///   direction = 'received' (default, quem me presenteou)
///              | 'sent'     (pra quem eu enviei gifts)
@riverpod
Future<List<GifterSummary>> gifters(
  Ref ref, {
  String direction = 'received',
}) async {
  return ref.read(creditsRepositoryProvider).getGifters(direction: direction);
}

@riverpod
Future<GifterDetails> gifterDetails(
  Ref ref, {
  required String userId,
  String direction = 'received',
}) async {
  return ref
      .read(creditsRepositoryProvider)
      .getGifterDetails(otherUserId: userId, direction: direction);
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
