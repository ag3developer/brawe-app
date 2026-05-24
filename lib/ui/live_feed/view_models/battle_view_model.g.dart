// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'battle_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Drives all battle-related UI state: scores, timer, phase transitions.
///
/// Single source of truth for both [ViewerBattleScreen] and [StreamerBattleScreen].
/// Both screens receive the same events — only widget rendering differs.

@ProviderFor(BattleViewModel)
final battleViewModelProvider = BattleViewModelFamily._();

/// Drives all battle-related UI state: scores, timer, phase transitions.
///
/// Single source of truth for both [ViewerBattleScreen] and [StreamerBattleScreen].
/// Both screens receive the same events — only widget rendering differs.
final class BattleViewModelProvider
    extends $NotifierProvider<BattleViewModel, AsyncValue<BattleState>> {
  /// Drives all battle-related UI state: scores, timer, phase transitions.
  ///
  /// Single source of truth for both [ViewerBattleScreen] and [StreamerBattleScreen].
  /// Both screens receive the same events — only widget rendering differs.
  BattleViewModelProvider._({
    required BattleViewModelFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'battleViewModelProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$battleViewModelHash();

  @override
  String toString() {
    return r'battleViewModelProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  BattleViewModel create() => BattleViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<BattleState> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<BattleState>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is BattleViewModelProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$battleViewModelHash() => r'198bdc6d4d6a7074dc0ed9011d0383796cb78fe0';

/// Drives all battle-related UI state: scores, timer, phase transitions.
///
/// Single source of truth for both [ViewerBattleScreen] and [StreamerBattleScreen].
/// Both screens receive the same events — only widget rendering differs.

final class BattleViewModelFamily extends $Family
    with
        $ClassFamilyOverride<
          BattleViewModel,
          AsyncValue<BattleState>,
          AsyncValue<BattleState>,
          AsyncValue<BattleState>,
          String
        > {
  BattleViewModelFamily._()
    : super(
        retry: null,
        name: r'battleViewModelProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Drives all battle-related UI state: scores, timer, phase transitions.
  ///
  /// Single source of truth for both [ViewerBattleScreen] and [StreamerBattleScreen].
  /// Both screens receive the same events — only widget rendering differs.

  BattleViewModelProvider call(String battleId) =>
      BattleViewModelProvider._(argument: battleId, from: this);

  @override
  String toString() => r'battleViewModelProvider';
}

/// Drives all battle-related UI state: scores, timer, phase transitions.
///
/// Single source of truth for both [ViewerBattleScreen] and [StreamerBattleScreen].
/// Both screens receive the same events — only widget rendering differs.

abstract class _$BattleViewModel extends $Notifier<AsyncValue<BattleState>> {
  late final _$args = ref.$arg as String;
  String get battleId => _$args;

  AsyncValue<BattleState> build(String battleId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<BattleState>, AsyncValue<BattleState>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<BattleState>, AsyncValue<BattleState>>,
              AsyncValue<BattleState>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
