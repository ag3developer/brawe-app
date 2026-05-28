// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'creator_network_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(creatorNetworkService)
final creatorNetworkServiceProvider = CreatorNetworkServiceProvider._();

final class CreatorNetworkServiceProvider
    extends
        $FunctionalProvider<
          CreatorNetworkService,
          CreatorNetworkService,
          CreatorNetworkService
        >
    with $Provider<CreatorNetworkService> {
  CreatorNetworkServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'creatorNetworkServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$creatorNetworkServiceHash();

  @$internal
  @override
  $ProviderElement<CreatorNetworkService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CreatorNetworkService create(Ref ref) {
    return creatorNetworkService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CreatorNetworkService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CreatorNetworkService>(value),
    );
  }
}

String _$creatorNetworkServiceHash() =>
    r'adc94d831315ef885ff753a3b6963234e06846ee';
