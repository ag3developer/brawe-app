// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'edit_profile_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(EditProfileViewModel)
final editProfileViewModelProvider = EditProfileViewModelProvider._();

final class EditProfileViewModelProvider
    extends $AsyncNotifierProvider<EditProfileViewModel, EditProfileState> {
  EditProfileViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'editProfileViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$editProfileViewModelHash();

  @$internal
  @override
  EditProfileViewModel create() => EditProfileViewModel();
}

String _$editProfileViewModelHash() =>
    r'e8c42aa9cb3946872cc38cb43218ec3fac7f38c0';

abstract class _$EditProfileViewModel extends $AsyncNotifier<EditProfileState> {
  FutureOr<EditProfileState> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<EditProfileState>, EditProfileState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<EditProfileState>, EditProfileState>,
              AsyncValue<EditProfileState>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
