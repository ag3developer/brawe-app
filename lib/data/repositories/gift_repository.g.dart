// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gift_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(giftRepository)
final giftRepositoryProvider = GiftRepositoryProvider._();

final class GiftRepositoryProvider
    extends $FunctionalProvider<GiftRepository, GiftRepository, GiftRepository>
    with $Provider<GiftRepository> {
  GiftRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'giftRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$giftRepositoryHash();

  @$internal
  @override
  $ProviderElement<GiftRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GiftRepository create(Ref ref) {
    return giftRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GiftRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GiftRepository>(value),
    );
  }
}

String _$giftRepositoryHash() => r'39aa018373d3914d344a3875e71e4684db77a29e';
