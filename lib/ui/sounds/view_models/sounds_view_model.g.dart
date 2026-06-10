// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sounds_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(soundsTrending)
final soundsTrendingProvider = SoundsTrendingProvider._();

final class SoundsTrendingProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Sound>>,
          List<Sound>,
          FutureOr<List<Sound>>
        >
    with $FutureModifier<List<Sound>>, $FutureProvider<List<Sound>> {
  SoundsTrendingProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'soundsTrendingProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$soundsTrendingHash();

  @$internal
  @override
  $FutureProviderElement<List<Sound>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Sound>> create(Ref ref) {
    return soundsTrending(ref);
  }
}

String _$soundsTrendingHash() => r'8e587948a8687c7352d8538578bd1ee58373adc4';

@ProviderFor(SoundsCatalogViewModel)
final soundsCatalogViewModelProvider = SoundsCatalogViewModelProvider._();

final class SoundsCatalogViewModelProvider
    extends $NotifierProvider<SoundsCatalogViewModel, SoundsCatalogState> {
  SoundsCatalogViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'soundsCatalogViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$soundsCatalogViewModelHash();

  @$internal
  @override
  SoundsCatalogViewModel create() => SoundsCatalogViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SoundsCatalogState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SoundsCatalogState>(value),
    );
  }
}

String _$soundsCatalogViewModelHash() =>
    r'37bb18e7de7d4c2d515eafe9ab2f78c81ad2a5bd';

abstract class _$SoundsCatalogViewModel extends $Notifier<SoundsCatalogState> {
  SoundsCatalogState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<SoundsCatalogState, SoundsCatalogState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SoundsCatalogState, SoundsCatalogState>,
              SoundsCatalogState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
