// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'start_live_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(StartLiveViewModel)
final startLiveViewModelProvider = StartLiveViewModelProvider._();

final class StartLiveViewModelProvider
    extends $NotifierProvider<StartLiveViewModel, StartLiveState> {
  StartLiveViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'startLiveViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$startLiveViewModelHash();

  @$internal
  @override
  StartLiveViewModel create() => StartLiveViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StartLiveState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StartLiveState>(value),
    );
  }
}

String _$startLiveViewModelHash() =>
    r'd812b3136473bef36688047ead5f4cebf1fb1bae';

abstract class _$StartLiveViewModel extends $Notifier<StartLiveState> {
  StartLiveState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<StartLiveState, StartLiveState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<StartLiveState, StartLiveState>,
              StartLiveState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
