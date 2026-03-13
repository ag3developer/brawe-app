// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'follow_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(FollowViewModel)
final followViewModelProvider = FollowViewModelFamily._();

final class FollowViewModelProvider
    extends $NotifierProvider<FollowViewModel, AsyncValue<bool>> {
  FollowViewModelProvider._({
    required FollowViewModelFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'followViewModelProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$followViewModelHash();

  @override
  String toString() {
    return r'followViewModelProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  FollowViewModel create() => FollowViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<bool> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<bool>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is FollowViewModelProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$followViewModelHash() => r'aa3bac7cd9520b1d15ea367c65e6efdcb9035f51';

final class FollowViewModelFamily extends $Family
    with
        $ClassFamilyOverride<
          FollowViewModel,
          AsyncValue<bool>,
          AsyncValue<bool>,
          AsyncValue<bool>,
          String
        > {
  FollowViewModelFamily._()
    : super(
        retry: null,
        name: r'followViewModelProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  FollowViewModelProvider call(String userId) =>
      FollowViewModelProvider._(argument: userId, from: this);

  @override
  String toString() => r'followViewModelProvider';
}

abstract class _$FollowViewModel extends $Notifier<AsyncValue<bool>> {
  late final _$args = ref.$arg as String;
  String get userId => _$args;

  AsyncValue<bool> build(String userId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<bool>, AsyncValue<bool>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<bool>, AsyncValue<bool>>,
              AsyncValue<bool>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
