// ============================================================================
// EARNINGS VIEW MODEL
// ============================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/repositories/credits_repository.dart';
import '../../../domain/models/wallet.dart';

/// Moeda de exibição selecionada pelo usuário (default: USD).
/// Riverpod 3.x removeu StateProvider — usamos um Notifier simples.
final displayCurrencyProvider =
    NotifierProvider<DisplayCurrencyNotifier, String>(
  DisplayCurrencyNotifier.new,
);

class DisplayCurrencyNotifier extends Notifier<String> {
  @override
  String build() => 'USD';

  void set(String currency) => state = currency;
}

/// Saldo consolidado (coins + diamonds) na moeda escolhida.
final earningsViewModelProvider =
    AsyncNotifierProvider<EarningsViewModel, Earnings>(
  EarningsViewModel.new,
);

class EarningsViewModel extends AsyncNotifier<Earnings> {
  @override
  Future<Earnings> build() async {
    final currency = ref.watch(displayCurrencyProvider);
    return ref
        .read(creditsRepositoryProvider)
        .getEarnings(currency: currency);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(creditsRepositoryProvider).getEarnings(
            currency: ref.read(displayCurrencyProvider),
          ),
    );
  }
}

/// Histórico de pedidos de compra de coins.
final purchaseOrdersProvider =
    FutureProvider<List<PurchaseOrder>>((ref) async {
  return ref.read(creditsRepositoryProvider).getPurchaseOrders();
});
