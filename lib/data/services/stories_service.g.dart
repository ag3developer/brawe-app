// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stories_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(storiesService)
final storiesServiceProvider = StoriesServiceProvider._();

final class StoriesServiceProvider
    extends $FunctionalProvider<StoriesService, StoriesService, StoriesService>
    with $Provider<StoriesService> {
  StoriesServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'storiesServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$storiesServiceHash();

  @$internal
  @override
  $ProviderElement<StoriesService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  StoriesService create(Ref ref) {
    return storiesService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StoriesService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StoriesService>(value),
    );
  }
}

String _$storiesServiceHash() => r'f44b46643f9c4f77157da63b683f70f992620ba6';
