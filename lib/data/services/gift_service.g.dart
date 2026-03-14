// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gift_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(giftService)
final giftServiceProvider = GiftServiceProvider._();

final class GiftServiceProvider
    extends $FunctionalProvider<GiftService, GiftService, GiftService>
    with $Provider<GiftService> {
  GiftServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'giftServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$giftServiceHash();

  @$internal
  @override
  $ProviderElement<GiftService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GiftService create(Ref ref) {
    return giftService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GiftService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GiftService>(value),
    );
  }
}

String _$giftServiceHash() => r'4037a03a84a485785dbcd90afaf50aaafa233d3b';
