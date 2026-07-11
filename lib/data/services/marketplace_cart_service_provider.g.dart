// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'marketplace_cart_service_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Riverpod provider for [MarketplaceCartService].
/// Uses [dioProvider] (main backend) for marketplace cart endpoints.
///
/// ⭐ CRÍTICO: Tracks affiliate commissions through CartItem metadata.

@ProviderFor(marketplaceCartService)
final marketplaceCartServiceProvider = MarketplaceCartServiceProvider._();

/// Riverpod provider for [MarketplaceCartService].
/// Uses [dioProvider] (main backend) for marketplace cart endpoints.
///
/// ⭐ CRÍTICO: Tracks affiliate commissions through CartItem metadata.

final class MarketplaceCartServiceProvider
    extends
        $FunctionalProvider<
          MarketplaceCartService,
          MarketplaceCartService,
          MarketplaceCartService
        >
    with $Provider<MarketplaceCartService> {
  /// Riverpod provider for [MarketplaceCartService].
  /// Uses [dioProvider] (main backend) for marketplace cart endpoints.
  ///
  /// ⭐ CRÍTICO: Tracks affiliate commissions through CartItem metadata.
  MarketplaceCartServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'marketplaceCartServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$marketplaceCartServiceHash();

  @$internal
  @override
  $ProviderElement<MarketplaceCartService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  MarketplaceCartService create(Ref ref) {
    return marketplaceCartService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MarketplaceCartService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MarketplaceCartService>(value),
    );
  }
}

String _$marketplaceCartServiceHash() =>
    r'96cbff972e1cb6734f9c399e670c8a852e30e42a';
