// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'signup_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SignupViewModel)
final signupViewModelProvider = SignupViewModelProvider._();

final class SignupViewModelProvider
    extends $NotifierProvider<SignupViewModel, SignupState> {
  SignupViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'signupViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$signupViewModelHash();

  @$internal
  @override
  SignupViewModel create() => SignupViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SignupState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SignupState>(value),
    );
  }
}

String _$signupViewModelHash() => r'9170c82a996d1c3c9757ab080a628547fc94f92f';

abstract class _$SignupViewModel extends $Notifier<SignupState> {
  SignupState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<SignupState, SignupState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SignupState, SignupState>,
              SignupState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
