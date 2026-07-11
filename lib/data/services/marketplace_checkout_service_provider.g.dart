// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'marketplace_checkout_service_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Riverpod provider for [MarketplaceCheckoutService].
/// Coordinates between Main Backend and Connect Backend.
///
/// - **Main Backend** ([dioProvider]): POST /marketplace/orders (checkout)
/// - **Connect Backend** ([liveDioProvider]): POST /shopping/payments (payment)
///
/// ⭐ CRÍTICO: This is the primary transaction flow for Fase 0.
/// Handles affiliate commission tracking and order fulfillment.

@ProviderFor(marketplaceCheckoutService)
final marketplaceCheckoutServiceProvider =
    MarketplaceCheckoutServiceProvider._();

/// Riverpod provider for [MarketplaceCheckoutService].
/// Coordinates between Main Backend and Connect Backend.
///
/// - **Main Backend** ([dioProvider]): POST /marketplace/orders (checkout)
/// - **Connect Backend** ([liveDioProvider]): POST /shopping/payments (payment)
///
/// ⭐ CRÍTICO: This is the primary transaction flow for Fase 0.
/// Handles affiliate commission tracking and order fulfillment.

final class MarketplaceCheckoutServiceProvider
    extends
        $FunctionalProvider<
          MarketplaceCheckoutService,
          MarketplaceCheckoutService,
          MarketplaceCheckoutService
        >
    with $Provider<MarketplaceCheckoutService> {
  /// Riverpod provider for [MarketplaceCheckoutService].
  /// Coordinates between Main Backend and Connect Backend.
  ///
  /// - **Main Backend** ([dioProvider]): POST /marketplace/orders (checkout)
  /// - **Connect Backend** ([liveDioProvider]): POST /shopping/payments (payment)
  ///
  /// ⭐ CRÍTICO: This is the primary transaction flow for Fase 0.
  /// Handles affiliate commission tracking and order fulfillment.
  MarketplaceCheckoutServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'marketplaceCheckoutServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$marketplaceCheckoutServiceHash();

  @$internal
  @override
  $ProviderElement<MarketplaceCheckoutService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  MarketplaceCheckoutService create(Ref ref) {
    return marketplaceCheckoutService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MarketplaceCheckoutService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MarketplaceCheckoutService>(value),
    );
  }
}

String _$marketplaceCheckoutServiceHash() =>
    r'182b18044ad05374ef3a6caf4644221311dfe38e';
