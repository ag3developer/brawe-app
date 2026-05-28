// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feed_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(FeedViewModel)
final feedViewModelProvider = FeedViewModelProvider._();

final class FeedViewModelProvider
    extends $AsyncNotifierProvider<FeedViewModel, List<Post>> {
  FeedViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'feedViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$feedViewModelHash();

  @$internal
  @override
  FeedViewModel create() => FeedViewModel();
}

String _$feedViewModelHash() => r'd7595cb3d43b3d917d9d21c827f22c37782ed199';

abstract class _$FeedViewModel extends $AsyncNotifier<List<Post>> {
  FutureOr<List<Post>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Post>>, List<Post>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Post>>, List<Post>>,
              AsyncValue<List<Post>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(FollowingFeedViewModel)
final followingFeedViewModelProvider = FollowingFeedViewModelProvider._();

final class FollowingFeedViewModelProvider
    extends $AsyncNotifierProvider<FollowingFeedViewModel, List<Post>> {
  FollowingFeedViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'followingFeedViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$followingFeedViewModelHash();

  @$internal
  @override
  FollowingFeedViewModel create() => FollowingFeedViewModel();
}

String _$followingFeedViewModelHash() =>
    r'a18e3909df775d98f7af53eb7c4d448eeaa09351';

abstract class _$FollowingFeedViewModel extends $AsyncNotifier<List<Post>> {
  FutureOr<List<Post>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Post>>, List<Post>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Post>>, List<Post>>,
              AsyncValue<List<Post>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
