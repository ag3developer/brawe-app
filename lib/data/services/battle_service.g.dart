// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'battle_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(battleService)
final battleServiceProvider = BattleServiceProvider._();

final class BattleServiceProvider
    extends $FunctionalProvider<BattleService, BattleService, BattleService>
    with $Provider<BattleService> {
  BattleServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'battleServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$battleServiceHash();

  @$internal
  @override
  $ProviderElement<BattleService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  BattleService create(Ref ref) {
    return battleService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BattleService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BattleService>(value),
    );
  }
}

String _$battleServiceHash() => r'68ba012f2c64acc62c5669dc573a5c75de5f6fea';
