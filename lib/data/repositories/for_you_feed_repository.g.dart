// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'for_you_feed_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(forYouFeedRepository)
final forYouFeedRepositoryProvider = ForYouFeedRepositoryProvider._();

final class ForYouFeedRepositoryProvider
    extends
        $FunctionalProvider<
          ForYouFeedRepository,
          ForYouFeedRepository,
          ForYouFeedRepository
        >
    with $Provider<ForYouFeedRepository> {
  ForYouFeedRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'forYouFeedRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$forYouFeedRepositoryHash();

  @$internal
  @override
  $ProviderElement<ForYouFeedRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ForYouFeedRepository create(Ref ref) {
    return forYouFeedRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ForYouFeedRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ForYouFeedRepository>(value),
    );
  }
}

String _$forYouFeedRepositoryHash() =>
    r'66beb3a2b55a92aed6a74d8c532a76e09731db4a';
