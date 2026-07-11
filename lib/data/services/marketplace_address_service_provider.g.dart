// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'marketplace_address_service_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Riverpod provider for [MarketplaceAddressService].
/// Uses [dioProvider] (main backend) for shipping address endpoints.
///
/// **MVP NOTE:** This provider is optional for Fase 0.
/// Address data can be collected directly in checkout form if needed.

@ProviderFor(marketplaceAddressService)
final marketplaceAddressServiceProvider = MarketplaceAddressServiceProvider._();

/// Riverpod provider for [MarketplaceAddressService].
/// Uses [dioProvider] (main backend) for shipping address endpoints.
///
/// **MVP NOTE:** This provider is optional for Fase 0.
/// Address data can be collected directly in checkout form if needed.

final class MarketplaceAddressServiceProvider
    extends
        $FunctionalProvider<
          MarketplaceAddressService,
          MarketplaceAddressService,
          MarketplaceAddressService
        >
    with $Provider<MarketplaceAddressService> {
  /// Riverpod provider for [MarketplaceAddressService].
  /// Uses [dioProvider] (main backend) for shipping address endpoints.
  ///
  /// **MVP NOTE:** This provider is optional for Fase 0.
  /// Address data can be collected directly in checkout form if needed.
  MarketplaceAddressServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'marketplaceAddressServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$marketplaceAddressServiceHash();

  @$internal
  @override
  $ProviderElement<MarketplaceAddressService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  MarketplaceAddressService create(Ref ref) {
    return marketplaceAddressService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MarketplaceAddressService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MarketplaceAddressService>(value),
    );
  }
}

String _$marketplaceAddressServiceHash() =>
    r'833dc1b41c4439f6441cb0de8d29fe41be3bccf2';
