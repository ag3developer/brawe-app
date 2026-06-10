// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sound_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(soundHttpService)
final soundHttpServiceProvider = SoundHttpServiceProvider._();

final class SoundHttpServiceProvider
    extends
        $FunctionalProvider<
          SoundHttpService,
          SoundHttpService,
          SoundHttpService
        >
    with $Provider<SoundHttpService> {
  SoundHttpServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'soundHttpServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$soundHttpServiceHash();

  @$internal
  @override
  $ProviderElement<SoundHttpService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SoundHttpService create(Ref ref) {
    return soundHttpService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SoundHttpService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SoundHttpService>(value),
    );
  }
}

String _$soundHttpServiceHash() => r'cedb058acd1eba6b885a1be667dc1a170c48437d';
