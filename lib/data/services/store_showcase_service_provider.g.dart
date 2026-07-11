// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'store_showcase_service_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Riverpod provider for [StoreShowcaseService].
/// Uses [dioProvider] (main backend) for marketplace endpoints.

@ProviderFor(storeShowcaseService)
final storeShowcaseServiceProvider = StoreShowcaseServiceProvider._();

/// Riverpod provider for [StoreShowcaseService].
/// Uses [dioProvider] (main backend) for marketplace endpoints.

final class StoreShowcaseServiceProvider
    extends
        $FunctionalProvider<
          StoreShowcaseService,
          StoreShowcaseService,
          StoreShowcaseService
        >
    with $Provider<StoreShowcaseService> {
  /// Riverpod provider for [StoreShowcaseService].
  /// Uses [dioProvider] (main backend) for marketplace endpoints.
  StoreShowcaseServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'storeShowcaseServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$storeShowcaseServiceHash();

  @$internal
  @override
  $ProviderElement<StoreShowcaseService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  StoreShowcaseService create(Ref ref) {
    return storeShowcaseService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StoreShowcaseService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StoreShowcaseService>(value),
    );
  }
}

String _$storeShowcaseServiceHash() =>
    r'67d2aa4d09f813a55b605f59a8ed1d53e79fe8f4';
