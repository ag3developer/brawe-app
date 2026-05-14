// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'social_actions_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(socialActionsService)
final socialActionsServiceProvider = SocialActionsServiceProvider._();

final class SocialActionsServiceProvider
    extends
        $FunctionalProvider<
          SocialActionsService,
          SocialActionsService,
          SocialActionsService
        >
    with $Provider<SocialActionsService> {
  SocialActionsServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'socialActionsServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$socialActionsServiceHash();

  @$internal
  @override
  $ProviderElement<SocialActionsService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SocialActionsService create(Ref ref) {
    return socialActionsService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SocialActionsService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SocialActionsService>(value),
    );
  }
}

String _$socialActionsServiceHash() =>
    r'd25d41f02b1942c5ac652f8663cdece1c1163cc4';
