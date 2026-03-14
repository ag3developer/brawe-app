// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'credits_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(creditsService)
final creditsServiceProvider = CreditsServiceProvider._();

final class CreditsServiceProvider
    extends $FunctionalProvider<CreditsService, CreditsService, CreditsService>
    with $Provider<CreditsService> {
  CreditsServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'creditsServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$creditsServiceHash();

  @$internal
  @override
  $ProviderElement<CreditsService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CreditsService create(Ref ref) {
    return creditsService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CreditsService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CreditsService>(value),
    );
  }
}

String _$creditsServiceHash() => r'f96ac9ce49aafc6c29f858cb2e33b9cf22abbfdb';
