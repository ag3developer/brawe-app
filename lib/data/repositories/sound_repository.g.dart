// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sound_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(soundRepository)
final soundRepositoryProvider = SoundRepositoryProvider._();

final class SoundRepositoryProvider
    extends
        $FunctionalProvider<SoundRepository, SoundRepository, SoundRepository>
    with $Provider<SoundRepository> {
  SoundRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'soundRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$soundRepositoryHash();

  @$internal
  @override
  $ProviderElement<SoundRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SoundRepository create(Ref ref) {
    return soundRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SoundRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SoundRepository>(value),
    );
  }
}

String _$soundRepositoryHash() => r'ba96536c3c3e4e3395a3aef4a306e816c77ad094';
