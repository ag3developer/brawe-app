// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'live_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(liveRepository)
final liveRepositoryProvider = LiveRepositoryProvider._();

final class LiveRepositoryProvider
    extends $FunctionalProvider<LiveRepository, LiveRepository, LiveRepository>
    with $Provider<LiveRepository> {
  LiveRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'liveRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$liveRepositoryHash();

  @$internal
  @override
  $ProviderElement<LiveRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  LiveRepository create(Ref ref) {
    return liveRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LiveRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LiveRepository>(value),
    );
  }
}

String _$liveRepositoryHash() => r'557e5a47ac65cdc11923880d5a71e5bd09fd0846';
