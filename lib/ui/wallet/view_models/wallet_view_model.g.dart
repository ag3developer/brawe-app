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

/// Lista de pessoas agrupadas (estilo TikTok).
///   direction = 'received' (default, quem me presenteou)
///              | 'sent'     (pra quem eu enviei gifts)

@ProviderFor(gifters)
final giftersProvider = GiftersFamily._();

/// Lista de pessoas agrupadas (estilo TikTok).
///   direction = 'received' (default, quem me presenteou)
///              | 'sent'     (pra quem eu enviei gifts)

final class GiftersProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<GifterSummary>>,
          List<GifterSummary>,
          FutureOr<List<GifterSummary>>
        >
    with
        $FutureModifier<List<GifterSummary>>,
        $FutureProvider<List<GifterSummary>> {
  /// Lista de pessoas agrupadas (estilo TikTok).
  ///   direction = 'received' (default, quem me presenteou)
  ///              | 'sent'     (pra quem eu enviei gifts)
  GiftersProvider._({
    required GiftersFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'giftersProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$giftersHash();

  @override
  String toString() {
    return r'giftersProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<GifterSummary>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<GifterSummary>> create(Ref ref) {
    final argument = this.argument as String;
    return gifters(ref, direction: argument);
  }

  @override
  bool operator ==(Object other) {
    return other is GiftersProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$giftersHash() => r'1934039031c836086529886e34ceb70b7a7179e5';

/// Lista de pessoas agrupadas (estilo TikTok).
///   direction = 'received' (default, quem me presenteou)
///              | 'sent'     (pra quem eu enviei gifts)

final class GiftersFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<GifterSummary>>, String> {
  GiftersFamily._()
    : super(
        retry: null,
        name: r'giftersProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Lista de pessoas agrupadas (estilo TikTok).
  ///   direction = 'received' (default, quem me presenteou)
  ///              | 'sent'     (pra quem eu enviei gifts)

  GiftersProvider call({String direction = 'received'}) =>
      GiftersProvider._(argument: direction, from: this);

  @override
  String toString() => r'giftersProvider';
}

@ProviderFor(gifterDetails)
final gifterDetailsProvider = GifterDetailsFamily._();

final class GifterDetailsProvider
    extends
        $FunctionalProvider<
          AsyncValue<GifterDetails>,
          GifterDetails,
          FutureOr<GifterDetails>
        >
    with $FutureModifier<GifterDetails>, $FutureProvider<GifterDetails> {
  GifterDetailsProvider._({
    required GifterDetailsFamily super.from,
    required ({String userId, String direction}) super.argument,
  }) : super(
         retry: null,
         name: r'gifterDetailsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$gifterDetailsHash();

  @override
  String toString() {
    return r'gifterDetailsProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<GifterDetails> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<GifterDetails> create(Ref ref) {
    final argument = this.argument as ({String userId, String direction});
    return gifterDetails(
      ref,
      userId: argument.userId,
      direction: argument.direction,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is GifterDetailsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$gifterDetailsHash() => r'9f354a4be4b4a883875099b94a19e0e6044829cd';

final class GifterDetailsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<GifterDetails>,
          ({String userId, String direction})
        > {
  GifterDetailsFamily._()
    : super(
        retry: null,
        name: r'gifterDetailsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  GifterDetailsProvider call({
    required String userId,
    String direction = 'received',
  }) => GifterDetailsProvider._(
    argument: (userId: userId, direction: direction),
    from: this,
  );

  @override
  String toString() => r'gifterDetailsProvider';
}

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
