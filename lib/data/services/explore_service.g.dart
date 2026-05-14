// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'explore_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(exploreService)
final exploreServiceProvider = ExploreServiceProvider._();

final class ExploreServiceProvider
    extends $FunctionalProvider<ExploreService, ExploreService, ExploreService>
    with $Provider<ExploreService> {
  ExploreServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'exploreServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$exploreServiceHash();

  @$internal
  @override
  $ProviderElement<ExploreService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ExploreService create(Ref ref) {
    return exploreService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ExploreService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ExploreService>(value),
    );
  }
}

String _$exploreServiceHash() => r'b5fa42098b0d1e2a9bd6ccf45a51ebd4805d42bd';
