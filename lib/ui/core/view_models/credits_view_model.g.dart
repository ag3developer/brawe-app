// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'credits_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CreditsViewModel)
final creditsViewModelProvider = CreditsViewModelProvider._();

final class CreditsViewModelProvider
    extends $AsyncNotifierProvider<CreditsViewModel, double> {
  CreditsViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'creditsViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$creditsViewModelHash();

  @$internal
  @override
  CreditsViewModel create() => CreditsViewModel();
}

String _$creditsViewModelHash() => r'a3e0968107ec9dee97f8bee93574bab0c7ce0b9c';

abstract class _$CreditsViewModel extends $AsyncNotifier<double> {
  FutureOr<double> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<double>, double>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<double>, double>,
              AsyncValue<double>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
