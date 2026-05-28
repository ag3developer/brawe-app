// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'live_eligibility_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(liveEligibilityService)
final liveEligibilityServiceProvider = LiveEligibilityServiceProvider._();

final class LiveEligibilityServiceProvider
    extends
        $FunctionalProvider<
          LiveEligibilityService,
          LiveEligibilityService,
          LiveEligibilityService
        >
    with $Provider<LiveEligibilityService> {
  LiveEligibilityServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'liveEligibilityServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$liveEligibilityServiceHash();

  @$internal
  @override
  $ProviderElement<LiveEligibilityService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  LiveEligibilityService create(Ref ref) {
    return liveEligibilityService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LiveEligibilityService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LiveEligibilityService>(value),
    );
  }
}

String _$liveEligibilityServiceHash() =>
    r'0ec35eb524a58f963bca99fad183c885fb5f5244';
