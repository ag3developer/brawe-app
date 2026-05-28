// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'live_eligibility_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(liveEligibility)
final liveEligibilityProvider = LiveEligibilityProvider._();

final class LiveEligibilityProvider
    extends
        $FunctionalProvider<
          AsyncValue<LiveEligibility>,
          LiveEligibility,
          FutureOr<LiveEligibility>
        >
    with $FutureModifier<LiveEligibility>, $FutureProvider<LiveEligibility> {
  LiveEligibilityProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'liveEligibilityProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$liveEligibilityHash();

  @$internal
  @override
  $FutureProviderElement<LiveEligibility> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<LiveEligibility> create(Ref ref) {
    return liveEligibility(ref);
  }
}

String _$liveEligibilityHash() => r'ea111576f1059d8203a7d9cfc3c240495fd6b717';
