// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(walletTransactions)
final walletTransactionsProvider = WalletTransactionsProvider._();

final class WalletTransactionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<WalletTransaction>>,
          List<WalletTransaction>,
          FutureOr<List<WalletTransaction>>
        >
    with
        $FutureModifier<List<WalletTransaction>>,
        $FutureProvider<List<WalletTransaction>> {
  WalletTransactionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'walletTransactionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$walletTransactionsHash();

  @$internal
  @override
  $FutureProviderElement<List<WalletTransaction>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<WalletTransaction>> create(Ref ref) {
    return walletTransactions(ref);
  }
}

String _$walletTransactionsHash() =>
    r'2ddf9555fda236e36db3a47da19d76dc83e8265c';

@ProviderFor(WalletViewModel)
final walletViewModelProvider = WalletViewModelProvider._();

final class WalletViewModelProvider
    extends $AsyncNotifierProvider<WalletViewModel, Wallet> {
  WalletViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'walletViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$walletViewModelHash();

  @$internal
  @override
  WalletViewModel create() => WalletViewModel();
}

String _$walletViewModelHash() => r'05d5c3f0a530c4faf365f7550b410643a4b4cc1d';

abstract class _$WalletViewModel extends $AsyncNotifier<Wallet> {
  FutureOr<Wallet> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<Wallet>, Wallet>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<Wallet>, Wallet>,
              AsyncValue<Wallet>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
