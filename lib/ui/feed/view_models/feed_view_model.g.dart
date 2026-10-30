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

String _$feedViewModelHash() => r'1a3f3efeea891ceb04e25318d651dfb2e923a5cf';

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
    r'c87f6a926149931617d70ec0accb7df4083d08c8';

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
