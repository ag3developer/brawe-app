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

String _$feedViewModelHash() => r'7c393788dc59b78fe47f2863074fd515068a5ecf';

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
