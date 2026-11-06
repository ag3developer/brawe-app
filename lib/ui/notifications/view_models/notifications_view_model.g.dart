// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notifications_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(NotificationsViewModel)
final notificationsViewModelProvider = NotificationsViewModelProvider._();

final class NotificationsViewModelProvider
    extends $AsyncNotifierProvider<NotificationsViewModel, NotificationsPage> {
  NotificationsViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationsViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationsViewModelHash();

  @$internal
  @override
  NotificationsViewModel create() => NotificationsViewModel();
}

String _$notificationsViewModelHash() =>
    r'e2cadf6d43be0e7d689b05f1cbe5777b2225bf27';

abstract class _$NotificationsViewModel
    extends $AsyncNotifier<NotificationsPage> {
  FutureOr<NotificationsPage> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<NotificationsPage>, NotificationsPage>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<NotificationsPage>, NotificationsPage>,
              AsyncValue<NotificationsPage>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Lightweight unread count provider.

@ProviderFor(notificationsUnreadCount)
final notificationsUnreadCountProvider = NotificationsUnreadCountProvider._();

/// Lightweight unread count provider.

final class NotificationsUnreadCountProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  /// Lightweight unread count provider.
  NotificationsUnreadCountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationsUnreadCountProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationsUnreadCountHash();

  @$internal
  @override
  $FutureProviderElement<int> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int> create(Ref ref) {
    return notificationsUnreadCount(ref);
  }
}

String _$notificationsUnreadCountHash() =>
    r'b7acbe209d9244d78f878b722525de3b8a356a09';
