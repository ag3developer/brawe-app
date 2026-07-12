// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'marketplace_product_service_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Riverpod provider for [MarketplaceProductService].
/// Uses [dioProvider] (app.brawe.io) - all marketplace endpoints are here.

@ProviderFor(marketplaceProductService)
final marketplaceProductServiceProvider = MarketplaceProductServiceProvider._();

/// Riverpod provider for [MarketplaceProductService].
/// Uses [dioProvider] (app.brawe.io) - all marketplace endpoints are here.

final class MarketplaceProductServiceProvider
    extends
        $FunctionalProvider<
          MarketplaceProductService,
          MarketplaceProductService,
          MarketplaceProductService
        >
    with $Provider<MarketplaceProductService> {
  /// Riverpod provider for [MarketplaceProductService].
  /// Uses [dioProvider] (app.brawe.io) - all marketplace endpoints are here.
  MarketplaceProductServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'marketplaceProductServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$marketplaceProductServiceHash();

  @$internal
  @override
  $ProviderElement<MarketplaceProductService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  MarketplaceProductService create(Ref ref) {
    return marketplaceProductService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MarketplaceProductService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MarketplaceProductService>(value),
    );
  }
}

String _$marketplaceProductServiceHash() =>
    r'aee31cef0ff353029350984665006d974813ae85';
