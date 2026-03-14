// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'credits_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(creditsRepository)
final creditsRepositoryProvider = CreditsRepositoryProvider._();

final class CreditsRepositoryProvider
    extends
        $FunctionalProvider<
          CreditsRepository,
          CreditsRepository,
          CreditsRepository
        >
    with $Provider<CreditsRepository> {
  CreditsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'creditsRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$creditsRepositoryHash();

  @$internal
  @override
  $ProviderElement<CreditsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CreditsRepository create(Ref ref) {
    return creditsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CreditsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CreditsRepository>(value),
    );
  }
}

String _$creditsRepositoryHash() => r'20ee75a643dca324607c5eea92d964d9d24ade01';
