// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'iap_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(iapService)
final iapServiceProvider = IapServiceProvider._();

final class IapServiceProvider
    extends $FunctionalProvider<IapService, IapService, IapService>
    with $Provider<IapService> {
  IapServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'iapServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$iapServiceHash();

  @$internal
  @override
  $ProviderElement<IapService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  IapService create(Ref ref) {
    return iapService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(IapService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<IapService>(value),
    );
  }
}

String _$iapServiceHash() => r'a0ddefaa010edc15dd2d9f15328dfc138d17d9cf';
