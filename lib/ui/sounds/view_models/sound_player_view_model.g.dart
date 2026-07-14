// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sound_player_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SoundPlayerViewModel)
final soundPlayerViewModelProvider = SoundPlayerViewModelProvider._();

final class SoundPlayerViewModelProvider
    extends $NotifierProvider<SoundPlayerViewModel, SoundPlayerState> {
  SoundPlayerViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'soundPlayerViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$soundPlayerViewModelHash();

  @$internal
  @override
  SoundPlayerViewModel create() => SoundPlayerViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SoundPlayerState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SoundPlayerState>(value),
    );
  }
}

String _$soundPlayerViewModelHash() =>
    r'09e69c4270e6b84a3a367ef0f0956bd7b873729f';

abstract class _$SoundPlayerViewModel extends $Notifier<SoundPlayerState> {
  SoundPlayerState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<SoundPlayerState, SoundPlayerState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SoundPlayerState, SoundPlayerState>,
              SoundPlayerState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
