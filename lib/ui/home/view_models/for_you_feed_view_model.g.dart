// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'for_you_feed_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ForYouFeedViewModel)
final forYouFeedViewModelProvider = ForYouFeedViewModelProvider._();

final class ForYouFeedViewModelProvider
    extends $AsyncNotifierProvider<ForYouFeedViewModel, List<FeedItem>> {
  ForYouFeedViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'forYouFeedViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$forYouFeedViewModelHash();

  @$internal
  @override
  ForYouFeedViewModel create() => ForYouFeedViewModel();
}

String _$forYouFeedViewModelHash() =>
    r'a147c6834632bdfed40e1bf78d0584f47624447e';

abstract class _$ForYouFeedViewModel extends $AsyncNotifier<List<FeedItem>> {
  FutureOr<List<FeedItem>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<FeedItem>>, List<FeedItem>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<FeedItem>>, List<FeedItem>>,
              AsyncValue<List<FeedItem>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(FollowingForYouFeedViewModel)
final followingForYouFeedViewModelProvider =
    FollowingForYouFeedViewModelProvider._();

final class FollowingForYouFeedViewModelProvider
    extends
        $AsyncNotifierProvider<FollowingForYouFeedViewModel, List<FeedItem>> {
  FollowingForYouFeedViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'followingForYouFeedViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$followingForYouFeedViewModelHash();

  @$internal
  @override
  FollowingForYouFeedViewModel create() => FollowingForYouFeedViewModel();
}

String _$followingForYouFeedViewModelHash() =>
    r'f2342dfd678ef22980267f08cfd4348acd8572f7';

abstract class _$FollowingForYouFeedViewModel
    extends $AsyncNotifier<List<FeedItem>> {
  FutureOr<List<FeedItem>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<FeedItem>>, List<FeedItem>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<FeedItem>>, List<FeedItem>>,
              AsyncValue<List<FeedItem>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
