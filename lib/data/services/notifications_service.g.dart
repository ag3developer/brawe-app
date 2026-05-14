// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notifications_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(notificationsService)
final notificationsServiceProvider = NotificationsServiceProvider._();

final class NotificationsServiceProvider
    extends
        $FunctionalProvider<
          NotificationsService,
          NotificationsService,
          NotificationsService
        >
    with $Provider<NotificationsService> {
  NotificationsServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationsServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationsServiceHash();

  @$internal
  @override
  $ProviderElement<NotificationsService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  NotificationsService create(Ref ref) {
    return notificationsService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NotificationsService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NotificationsService>(value),
    );
  }
}

String _$notificationsServiceHash() =>
    r'1adb54cf50114eb1dc4122afe79d87eba0ca6eff';
