// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'top_streamers_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(TopStreamersViewModel)
final topStreamersViewModelProvider = TopStreamersViewModelProvider._();

final class TopStreamersViewModelProvider
    extends $AsyncNotifierProvider<TopStreamersViewModel, List<Profile>> {
  TopStreamersViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'topStreamersViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$topStreamersViewModelHash();

  @$internal
  @override
  TopStreamersViewModel create() => TopStreamersViewModel();
}

String _$topStreamersViewModelHash() =>
    r'6b0923a7c0ed2d3110bcd8a6c9599a9f1002a7f1';

abstract class _$TopStreamersViewModel extends $AsyncNotifier<List<Profile>> {
  FutureOr<List<Profile>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Profile>>, List<Profile>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Profile>>, List<Profile>>,
              AsyncValue<List<Profile>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
