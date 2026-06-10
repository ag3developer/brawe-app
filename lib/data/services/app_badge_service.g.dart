// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_badge_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(appBadgeService)
final appBadgeServiceProvider = AppBadgeServiceProvider._();

final class AppBadgeServiceProvider
    extends
        $FunctionalProvider<AppBadgeService, AppBadgeService, AppBadgeService>
    with $Provider<AppBadgeService> {
  AppBadgeServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appBadgeServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appBadgeServiceHash();

  @$internal
  @override
  $ProviderElement<AppBadgeService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AppBadgeService create(Ref ref) {
    return appBadgeService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppBadgeService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppBadgeService>(value),
    );
  }
}

String _$appBadgeServiceHash() => r'fbf0feb9be75b103c999d5fb7bac8fc2f964b4a0';
