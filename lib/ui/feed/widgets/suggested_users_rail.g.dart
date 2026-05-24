// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'suggested_users_rail.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(suggestedUsers)
final suggestedUsersProvider = SuggestedUsersProvider._();

final class SuggestedUsersProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Map<String, dynamic>>>,
          List<Map<String, dynamic>>,
          FutureOr<List<Map<String, dynamic>>>
        >
    with
        $FutureModifier<List<Map<String, dynamic>>>,
        $FutureProvider<List<Map<String, dynamic>>> {
  SuggestedUsersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'suggestedUsersProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$suggestedUsersHash();

  @$internal
  @override
  $FutureProviderElement<List<Map<String, dynamic>>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Map<String, dynamic>>> create(Ref ref) {
    return suggestedUsers(ref);
  }
}

String _$suggestedUsersHash() => r'99937f4c5ef8c169d484e4c2b6ae535c0c1b0ee9';

/// Tracks which users the user already followed (local optimistic state).

@ProviderFor(FollowedNotifier)
final followedProvider = FollowedNotifierProvider._();

/// Tracks which users the user already followed (local optimistic state).
final class FollowedNotifierProvider
    extends $NotifierProvider<FollowedNotifier, Set<String>> {
  /// Tracks which users the user already followed (local optimistic state).
  FollowedNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'followedProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$followedNotifierHash();

  @$internal
  @override
  FollowedNotifier create() => FollowedNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Set<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Set<String>>(value),
    );
  }
}

String _$followedNotifierHash() => r'959cc3297bac0df3b99e666b16771b0c3c6c849b';

/// Tracks which users the user already followed (local optimistic state).

abstract class _$FollowedNotifier extends $Notifier<Set<String>> {
  Set<String> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<Set<String>, Set<String>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Set<String>, Set<String>>,
              Set<String>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
