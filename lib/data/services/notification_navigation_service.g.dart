// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_navigation_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(notificationNavigationService)
final notificationNavigationServiceProvider =
    NotificationNavigationServiceProvider._();

final class NotificationNavigationServiceProvider
    extends
        $FunctionalProvider<
          NotificationNavigationService,
          NotificationNavigationService,
          NotificationNavigationService
        >
    with $Provider<NotificationNavigationService> {
  NotificationNavigationServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationNavigationServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationNavigationServiceHash();

  @$internal
  @override
  $ProviderElement<NotificationNavigationService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  NotificationNavigationService create(Ref ref) {
    return notificationNavigationService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NotificationNavigationService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NotificationNavigationService>(
        value,
      ),
    );
  }
}

String _$notificationNavigationServiceHash() =>
    r'3b859986003f056564bdbec49e508d56049819a9';
