// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'battle_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Drives all battle-related UI state: scores, timer, phase transitions.
///
/// Single source of truth for both battle overlays — `ViewerBattleHud`
/// (sobreposto à live do espectador) and `StreamerBattleHud` (HUD do
/// transmissor). Both receive the same socket events — only widget
/// rendering differs.
///
/// Batalha v2 (BATTLE_V2_CONTRACT):
/// - Cronômetro pelo relógio do servidor: `offset = server_now − agora local`
///   e `restante = ends_at − (agora + offset)`, recalculado a cada tick e
///   ressincronizado ao voltar do background e ao reconectar o socket.
/// - Contagem 3·2·1 dirigida por `connect:battle:countdown`.
/// - `seq` descarta `score_update` fora de ordem; `connect:battle:mute`,
///   `rtc_fallback` atualizam o modo de transmissão.
/// - Tolerante a backend antigo (campos novos ausentes).

@ProviderFor(BattleViewModel)
final battleViewModelProvider = BattleViewModelFamily._();

/// Drives all battle-related UI state: scores, timer, phase transitions.
///
/// Single source of truth for both battle overlays — `ViewerBattleHud`
/// (sobreposto à live do espectador) and `StreamerBattleHud` (HUD do
/// transmissor). Both receive the same socket events — only widget
/// rendering differs.
///
/// Batalha v2 (BATTLE_V2_CONTRACT):
/// - Cronômetro pelo relógio do servidor: `offset = server_now − agora local`
///   e `restante = ends_at − (agora + offset)`, recalculado a cada tick e
///   ressincronizado ao voltar do background e ao reconectar o socket.
/// - Contagem 3·2·1 dirigida por `connect:battle:countdown`.
/// - `seq` descarta `score_update` fora de ordem; `connect:battle:mute`,
///   `rtc_fallback` atualizam o modo de transmissão.
/// - Tolerante a backend antigo (campos novos ausentes).
final class BattleViewModelProvider
    extends $NotifierProvider<BattleViewModel, AsyncValue<BattleState>> {
  /// Drives all battle-related UI state: scores, timer, phase transitions.
  ///
  /// Single source of truth for both battle overlays — `ViewerBattleHud`
  /// (sobreposto à live do espectador) and `StreamerBattleHud` (HUD do
  /// transmissor). Both receive the same socket events — only widget
  /// rendering differs.
  ///
  /// Batalha v2 (BATTLE_V2_CONTRACT):
  /// - Cronômetro pelo relógio do servidor: `offset = server_now − agora local`
  ///   e `restante = ends_at − (agora + offset)`, recalculado a cada tick e
  ///   ressincronizado ao voltar do background e ao reconectar o socket.
  /// - Contagem 3·2·1 dirigida por `connect:battle:countdown`.
  /// - `seq` descarta `score_update` fora de ordem; `connect:battle:mute`,
  ///   `rtc_fallback` atualizam o modo de transmissão.
  /// - Tolerante a backend antigo (campos novos ausentes).
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

String _$battleViewModelHash() => r'18629d596d173f84aef4b8abe6ffaf9d4a8dcd71';

/// Drives all battle-related UI state: scores, timer, phase transitions.
///
/// Single source of truth for both battle overlays — `ViewerBattleHud`
/// (sobreposto à live do espectador) and `StreamerBattleHud` (HUD do
/// transmissor). Both receive the same socket events — only widget
/// rendering differs.
///
/// Batalha v2 (BATTLE_V2_CONTRACT):
/// - Cronômetro pelo relógio do servidor: `offset = server_now − agora local`
///   e `restante = ends_at − (agora + offset)`, recalculado a cada tick e
///   ressincronizado ao voltar do background e ao reconectar o socket.
/// - Contagem 3·2·1 dirigida por `connect:battle:countdown`.
/// - `seq` descarta `score_update` fora de ordem; `connect:battle:mute`,
///   `rtc_fallback` atualizam o modo de transmissão.
/// - Tolerante a backend antigo (campos novos ausentes).

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
  /// Single source of truth for both battle overlays — `ViewerBattleHud`
  /// (sobreposto à live do espectador) and `StreamerBattleHud` (HUD do
  /// transmissor). Both receive the same socket events — only widget
  /// rendering differs.
  ///
  /// Batalha v2 (BATTLE_V2_CONTRACT):
  /// - Cronômetro pelo relógio do servidor: `offset = server_now − agora local`
  ///   e `restante = ends_at − (agora + offset)`, recalculado a cada tick e
  ///   ressincronizado ao voltar do background e ao reconectar o socket.
  /// - Contagem 3·2·1 dirigida por `connect:battle:countdown`.
  /// - `seq` descarta `score_update` fora de ordem; `connect:battle:mute`,
  ///   `rtc_fallback` atualizam o modo de transmissão.
  /// - Tolerante a backend antigo (campos novos ausentes).

  BattleViewModelProvider call(String battleId) =>
      BattleViewModelProvider._(argument: battleId, from: this);

  @override
  String toString() => r'battleViewModelProvider';
}

/// Drives all battle-related UI state: scores, timer, phase transitions.
///
/// Single source of truth for both battle overlays — `ViewerBattleHud`
/// (sobreposto à live do espectador) and `StreamerBattleHud` (HUD do
/// transmissor). Both receive the same socket events — only widget
/// rendering differs.
///
/// Batalha v2 (BATTLE_V2_CONTRACT):
/// - Cronômetro pelo relógio do servidor: `offset = server_now − agora local`
///   e `restante = ends_at − (agora + offset)`, recalculado a cada tick e
///   ressincronizado ao voltar do background e ao reconectar o socket.
/// - Contagem 3·2·1 dirigida por `connect:battle:countdown`.
/// - `seq` descarta `score_update` fora de ordem; `connect:battle:mute`,
///   `rtc_fallback` atualizam o modo de transmissão.
/// - Tolerante a backend antigo (campos novos ausentes).

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
