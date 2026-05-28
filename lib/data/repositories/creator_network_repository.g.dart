// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'creator_network_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(creatorNetworkRepository)
final creatorNetworkRepositoryProvider = CreatorNetworkRepositoryProvider._();

final class CreatorNetworkRepositoryProvider
    extends
        $FunctionalProvider<
          CreatorNetworkRepository,
          CreatorNetworkRepository,
          CreatorNetworkRepository
        >
    with $Provider<CreatorNetworkRepository> {
  CreatorNetworkRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'creatorNetworkRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$creatorNetworkRepositoryHash();

  @$internal
  @override
  $ProviderElement<CreatorNetworkRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CreatorNetworkRepository create(Ref ref) {
    return creatorNetworkRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CreatorNetworkRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CreatorNetworkRepository>(value),
    );
  }
}

String _$creatorNetworkRepositoryHash() =>
    r'458f15363c9779dbe82b69a8aae2eca742f0f8dc';
