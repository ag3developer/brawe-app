// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_status_sheet.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(UserStatusNotifier)
final userStatusProvider = UserStatusNotifierProvider._();

final class UserStatusNotifierProvider
    extends $NotifierProvider<UserStatusNotifier, UserStatus> {
  UserStatusNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userStatusProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userStatusNotifierHash();

  @$internal
  @override
  UserStatusNotifier create() => UserStatusNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UserStatus value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UserStatus>(value),
    );
  }
}

String _$userStatusNotifierHash() =>
    r'5900376bf8c378c5291d3f5a099900b7e8d2d385';

abstract class _$UserStatusNotifier extends $Notifier<UserStatus> {
  UserStatus build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<UserStatus, UserStatus>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<UserStatus, UserStatus>,
              UserStatus,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
