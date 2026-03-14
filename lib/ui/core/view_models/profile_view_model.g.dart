// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ProfileViewModel)
final profileViewModelProvider = ProfileViewModelFamily._();

final class ProfileViewModelProvider
    extends $NotifierProvider<ProfileViewModel, ProfileState> {
  ProfileViewModelProvider._({
    required ProfileViewModelFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'profileViewModelProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$profileViewModelHash();

  @override
  String toString() {
    return r'profileViewModelProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ProfileViewModel create() => ProfileViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProfileState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProfileState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ProfileViewModelProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$profileViewModelHash() => r'70d10dad96d6cd76e4e27173e388b29c5c7b62e8';

final class ProfileViewModelFamily extends $Family
    with
        $ClassFamilyOverride<
          ProfileViewModel,
          ProfileState,
          ProfileState,
          ProfileState,
          String
        > {
  ProfileViewModelFamily._()
    : super(
        retry: null,
        name: r'profileViewModelProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ProfileViewModelProvider call(String userId) =>
      ProfileViewModelProvider._(argument: userId, from: this);

  @override
  String toString() => r'profileViewModelProvider';
}

abstract class _$ProfileViewModel extends $Notifier<ProfileState> {
  late final _$args = ref.$arg as String;
  String get userId => _$args;

  ProfileState build(String userId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<ProfileState, ProfileState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ProfileState, ProfileState>,
              ProfileState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
