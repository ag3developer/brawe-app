// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'social_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(socialService)
final socialServiceProvider = SocialServiceProvider._();

final class SocialServiceProvider
    extends $FunctionalProvider<SocialService, SocialService, SocialService>
    with $Provider<SocialService> {
  SocialServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'socialServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$socialServiceHash();

  @$internal
  @override
  $ProviderElement<SocialService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SocialService create(Ref ref) {
    return socialService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SocialService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SocialService>(value),
    );
  }
}

String _$socialServiceHash() => r'5180e0a4471653aae9eeef3dcbd2d456cf9c3f02';
