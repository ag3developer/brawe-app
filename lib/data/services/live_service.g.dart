// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'live_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(liveService)
final liveServiceProvider = LiveServiceProvider._();

final class LiveServiceProvider
    extends $FunctionalProvider<LiveService, LiveService, LiveService>
    with $Provider<LiveService> {
  LiveServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'liveServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$liveServiceHash();

  @$internal
  @override
  $ProviderElement<LiveService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  LiveService create(Ref ref) {
    return liveService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LiveService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LiveService>(value),
    );
  }
}

String _$liveServiceHash() => r'1d5d2076097ce3468396abcadcde0c4430582952';
