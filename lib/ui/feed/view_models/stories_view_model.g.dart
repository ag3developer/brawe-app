// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stories_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(StoriesViewModel)
final storiesViewModelProvider = StoriesViewModelProvider._();

final class StoriesViewModelProvider
    extends $AsyncNotifierProvider<StoriesViewModel, List<UserStoriesGroup>> {
  StoriesViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'storiesViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$storiesViewModelHash();

  @$internal
  @override
  StoriesViewModel create() => StoriesViewModel();
}

String _$storiesViewModelHash() => r'578db00bcd93113e055a527aa8fa498c296f2a16';

abstract class _$StoriesViewModel
    extends $AsyncNotifier<List<UserStoriesGroup>> {
  FutureOr<List<UserStoriesGroup>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<List<UserStoriesGroup>>, List<UserStoriesGroup>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<UserStoriesGroup>>,
                List<UserStoriesGroup>
              >,
              AsyncValue<List<UserStoriesGroup>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
