// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'follows_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(FollowsViewModel)
final followsViewModelProvider = FollowsViewModelFamily._();

final class FollowsViewModelProvider
    extends $AsyncNotifierProvider<FollowsViewModel, FollowsState> {
  FollowsViewModelProvider._({
    required FollowsViewModelFamily super.from,
    required (String, FollowsTab) super.argument,
  }) : super(
         retry: null,
         name: r'followsViewModelProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$followsViewModelHash();

  @override
  String toString() {
    return r'followsViewModelProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  FollowsViewModel create() => FollowsViewModel();

  @override
  bool operator ==(Object other) {
    return other is FollowsViewModelProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$followsViewModelHash() => r'c725d687cd7fb05dd99e894022511ad878fbf0a6';

final class FollowsViewModelFamily extends $Family
    with
        $ClassFamilyOverride<
          FollowsViewModel,
          AsyncValue<FollowsState>,
          FollowsState,
          FutureOr<FollowsState>,
          (String, FollowsTab)
        > {
  FollowsViewModelFamily._()
    : super(
        retry: null,
        name: r'followsViewModelProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  FollowsViewModelProvider call(String userId, FollowsTab tab) =>
      FollowsViewModelProvider._(argument: (userId, tab), from: this);

  @override
  String toString() => r'followsViewModelProvider';
}

abstract class _$FollowsViewModel extends $AsyncNotifier<FollowsState> {
  late final _$args = ref.$arg as (String, FollowsTab);
  String get userId => _$args.$1;
  FollowsTab get tab => _$args.$2;

  FutureOr<FollowsState> build(String userId, FollowsTab tab);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<FollowsState>, FollowsState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<FollowsState>, FollowsState>,
              AsyncValue<FollowsState>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args.$1, _$args.$2));
  }
}
