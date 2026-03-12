// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'live_feed_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(LiveFeedViewModel)
final liveFeedViewModelProvider = LiveFeedViewModelProvider._();

final class LiveFeedViewModelProvider
    extends $AsyncNotifierProvider<LiveFeedViewModel, List<LiveRoom>> {
  LiveFeedViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'liveFeedViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$liveFeedViewModelHash();

  @$internal
  @override
  LiveFeedViewModel create() => LiveFeedViewModel();
}

String _$liveFeedViewModelHash() => r'a8af80cd4bb4ca70238c19b8dd338fd45c6e6a2c';

abstract class _$LiveFeedViewModel extends $AsyncNotifier<List<LiveRoom>> {
  FutureOr<List<LiveRoom>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<LiveRoom>>, List<LiveRoom>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<LiveRoom>>, List<LiveRoom>>,
              AsyncValue<List<LiveRoom>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
