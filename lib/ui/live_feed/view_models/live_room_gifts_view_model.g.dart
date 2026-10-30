// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'live_room_gifts_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 🎁 ViewModel das animações de presente em tempo real.
///
/// ============================================================================
/// ARQUITETURA PROFISSIONAL DE EXIBIÇÃO (4 modos) — ver
/// GIFT_DISPLAY_ARCHITECTURE_ANALYSIS.md e SVGA_NOT_SUPPORTED.md
/// ============================================================================
///
/// Cada [LiveGift] resolve seu tipo via `LiveGift.resolvedDisplayType`
/// (fallback retrocompatível baseado em `isFullscreen` se o backend não
/// enviar `display_type`).
///
/// **Chat imediato**: TODO presente aparece IMEDIATAMENTE em `state` assim
/// que chega — o chat (`ChatTicker`) não espera nenhuma animação terminar.
/// Isso elimina o atraso histórico onde a mensagem só aparecia depois da
/// animação (~3s de espera desnecessária).
///
/// **Fila visual com prioridade**: apenas presentes com
/// `displayType.entersVisualQueue == true` (center_small, center_large,
/// fullscreen — NUNCA chat) entram na fila de animações do overlay:
///   - Processa **1 animação por vez** — trivialmente garante que nunca
///     há dois fullscreen (ou dois de qualquer tipo) simultâneos.
///   - Sempre escolhe a MAIOR prioridade pendente primeiro
///     (fullscreen=30 > center_large=20 > center_small=10).
///   - Dentro da mesma prioridade, respeita FIFO (ordem de chegada).
///   - Tem tamanho máximo (`_maxVisualQueue`) — em overflow, descarta a
///     entrada mais antiga da fila VISUAL (nunca a transação/chat).
///
/// **Combo**: mesmo sender+gift dentro da janela de 4s atualiza a entrada
/// existente (soma quantity, atualiza timestamp) SEM reiniciar uma
/// animação já em andamento ou já finalizada — o contador (`x5`, `x10`)
/// simplesmente reflete o `quantity` atualizado do mesmo objeto.
///
/// **Duração dinâmica**: cada gift usa `LiveGift.resolvedDurationMs`, já
/// clampado nos limites seguros do `resolvedDisplayType` — nunca confia
/// só no valor da rede, mesmo que o backend já valide (defesa em
/// profundidade).

@ProviderFor(LiveRoomGiftsViewModel)
final liveRoomGiftsViewModelProvider = LiveRoomGiftsViewModelFamily._();

/// 🎁 ViewModel das animações de presente em tempo real.
///
/// ============================================================================
/// ARQUITETURA PROFISSIONAL DE EXIBIÇÃO (4 modos) — ver
/// GIFT_DISPLAY_ARCHITECTURE_ANALYSIS.md e SVGA_NOT_SUPPORTED.md
/// ============================================================================
///
/// Cada [LiveGift] resolve seu tipo via `LiveGift.resolvedDisplayType`
/// (fallback retrocompatível baseado em `isFullscreen` se o backend não
/// enviar `display_type`).
///
/// **Chat imediato**: TODO presente aparece IMEDIATAMENTE em `state` assim
/// que chega — o chat (`ChatTicker`) não espera nenhuma animação terminar.
/// Isso elimina o atraso histórico onde a mensagem só aparecia depois da
/// animação (~3s de espera desnecessária).
///
/// **Fila visual com prioridade**: apenas presentes com
/// `displayType.entersVisualQueue == true` (center_small, center_large,
/// fullscreen — NUNCA chat) entram na fila de animações do overlay:
///   - Processa **1 animação por vez** — trivialmente garante que nunca
///     há dois fullscreen (ou dois de qualquer tipo) simultâneos.
///   - Sempre escolhe a MAIOR prioridade pendente primeiro
///     (fullscreen=30 > center_large=20 > center_small=10).
///   - Dentro da mesma prioridade, respeita FIFO (ordem de chegada).
///   - Tem tamanho máximo (`_maxVisualQueue`) — em overflow, descarta a
///     entrada mais antiga da fila VISUAL (nunca a transação/chat).
///
/// **Combo**: mesmo sender+gift dentro da janela de 4s atualiza a entrada
/// existente (soma quantity, atualiza timestamp) SEM reiniciar uma
/// animação já em andamento ou já finalizada — o contador (`x5`, `x10`)
/// simplesmente reflete o `quantity` atualizado do mesmo objeto.
///
/// **Duração dinâmica**: cada gift usa `LiveGift.resolvedDurationMs`, já
/// clampado nos limites seguros do `resolvedDisplayType` — nunca confia
/// só no valor da rede, mesmo que o backend já valide (defesa em
/// profundidade).
final class LiveRoomGiftsViewModelProvider
    extends $NotifierProvider<LiveRoomGiftsViewModel, List<LiveGift>> {
  /// 🎁 ViewModel das animações de presente em tempo real.
  ///
  /// ============================================================================
  /// ARQUITETURA PROFISSIONAL DE EXIBIÇÃO (4 modos) — ver
  /// GIFT_DISPLAY_ARCHITECTURE_ANALYSIS.md e SVGA_NOT_SUPPORTED.md
  /// ============================================================================
  ///
  /// Cada [LiveGift] resolve seu tipo via `LiveGift.resolvedDisplayType`
  /// (fallback retrocompatível baseado em `isFullscreen` se o backend não
  /// enviar `display_type`).
  ///
  /// **Chat imediato**: TODO presente aparece IMEDIATAMENTE em `state` assim
  /// que chega — o chat (`ChatTicker`) não espera nenhuma animação terminar.
  /// Isso elimina o atraso histórico onde a mensagem só aparecia depois da
  /// animação (~3s de espera desnecessária).
  ///
  /// **Fila visual com prioridade**: apenas presentes com
  /// `displayType.entersVisualQueue == true` (center_small, center_large,
  /// fullscreen — NUNCA chat) entram na fila de animações do overlay:
  ///   - Processa **1 animação por vez** — trivialmente garante que nunca
  ///     há dois fullscreen (ou dois de qualquer tipo) simultâneos.
  ///   - Sempre escolhe a MAIOR prioridade pendente primeiro
  ///     (fullscreen=30 > center_large=20 > center_small=10).
  ///   - Dentro da mesma prioridade, respeita FIFO (ordem de chegada).
  ///   - Tem tamanho máximo (`_maxVisualQueue`) — em overflow, descarta a
  ///     entrada mais antiga da fila VISUAL (nunca a transação/chat).
  ///
  /// **Combo**: mesmo sender+gift dentro da janela de 4s atualiza a entrada
  /// existente (soma quantity, atualiza timestamp) SEM reiniciar uma
  /// animação já em andamento ou já finalizada — o contador (`x5`, `x10`)
  /// simplesmente reflete o `quantity` atualizado do mesmo objeto.
  ///
  /// **Duração dinâmica**: cada gift usa `LiveGift.resolvedDurationMs`, já
  /// clampado nos limites seguros do `resolvedDisplayType` — nunca confia
  /// só no valor da rede, mesmo que o backend já valide (defesa em
  /// profundidade).
  LiveRoomGiftsViewModelProvider._({
    required LiveRoomGiftsViewModelFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'liveRoomGiftsViewModelProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$liveRoomGiftsViewModelHash();

  @override
  String toString() {
    return r'liveRoomGiftsViewModelProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  LiveRoomGiftsViewModel create() => LiveRoomGiftsViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<LiveGift> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<LiveGift>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is LiveRoomGiftsViewModelProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$liveRoomGiftsViewModelHash() =>
    r'a1943a1a79a887ffb1d1f271f854cb5f39a439d5';

/// 🎁 ViewModel das animações de presente em tempo real.
///
/// ============================================================================
/// ARQUITETURA PROFISSIONAL DE EXIBIÇÃO (4 modos) — ver
/// GIFT_DISPLAY_ARCHITECTURE_ANALYSIS.md e SVGA_NOT_SUPPORTED.md
/// ============================================================================
///
/// Cada [LiveGift] resolve seu tipo via `LiveGift.resolvedDisplayType`
/// (fallback retrocompatível baseado em `isFullscreen` se o backend não
/// enviar `display_type`).
///
/// **Chat imediato**: TODO presente aparece IMEDIATAMENTE em `state` assim
/// que chega — o chat (`ChatTicker`) não espera nenhuma animação terminar.
/// Isso elimina o atraso histórico onde a mensagem só aparecia depois da
/// animação (~3s de espera desnecessária).
///
/// **Fila visual com prioridade**: apenas presentes com
/// `displayType.entersVisualQueue == true` (center_small, center_large,
/// fullscreen — NUNCA chat) entram na fila de animações do overlay:
///   - Processa **1 animação por vez** — trivialmente garante que nunca
///     há dois fullscreen (ou dois de qualquer tipo) simultâneos.
///   - Sempre escolhe a MAIOR prioridade pendente primeiro
///     (fullscreen=30 > center_large=20 > center_small=10).
///   - Dentro da mesma prioridade, respeita FIFO (ordem de chegada).
///   - Tem tamanho máximo (`_maxVisualQueue`) — em overflow, descarta a
///     entrada mais antiga da fila VISUAL (nunca a transação/chat).
///
/// **Combo**: mesmo sender+gift dentro da janela de 4s atualiza a entrada
/// existente (soma quantity, atualiza timestamp) SEM reiniciar uma
/// animação já em andamento ou já finalizada — o contador (`x5`, `x10`)
/// simplesmente reflete o `quantity` atualizado do mesmo objeto.
///
/// **Duração dinâmica**: cada gift usa `LiveGift.resolvedDurationMs`, já
/// clampado nos limites seguros do `resolvedDisplayType` — nunca confia
/// só no valor da rede, mesmo que o backend já valide (defesa em
/// profundidade).

final class LiveRoomGiftsViewModelFamily extends $Family
    with
        $ClassFamilyOverride<
          LiveRoomGiftsViewModel,
          List<LiveGift>,
          List<LiveGift>,
          List<LiveGift>,
          String
        > {
  LiveRoomGiftsViewModelFamily._()
    : super(
        retry: null,
        name: r'liveRoomGiftsViewModelProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 🎁 ViewModel das animações de presente em tempo real.
  ///
  /// ============================================================================
  /// ARQUITETURA PROFISSIONAL DE EXIBIÇÃO (4 modos) — ver
  /// GIFT_DISPLAY_ARCHITECTURE_ANALYSIS.md e SVGA_NOT_SUPPORTED.md
  /// ============================================================================
  ///
  /// Cada [LiveGift] resolve seu tipo via `LiveGift.resolvedDisplayType`
  /// (fallback retrocompatível baseado em `isFullscreen` se o backend não
  /// enviar `display_type`).
  ///
  /// **Chat imediato**: TODO presente aparece IMEDIATAMENTE em `state` assim
  /// que chega — o chat (`ChatTicker`) não espera nenhuma animação terminar.
  /// Isso elimina o atraso histórico onde a mensagem só aparecia depois da
  /// animação (~3s de espera desnecessária).
  ///
  /// **Fila visual com prioridade**: apenas presentes com
  /// `displayType.entersVisualQueue == true` (center_small, center_large,
  /// fullscreen — NUNCA chat) entram na fila de animações do overlay:
  ///   - Processa **1 animação por vez** — trivialmente garante que nunca
  ///     há dois fullscreen (ou dois de qualquer tipo) simultâneos.
  ///   - Sempre escolhe a MAIOR prioridade pendente primeiro
  ///     (fullscreen=30 > center_large=20 > center_small=10).
  ///   - Dentro da mesma prioridade, respeita FIFO (ordem de chegada).
  ///   - Tem tamanho máximo (`_maxVisualQueue`) — em overflow, descarta a
  ///     entrada mais antiga da fila VISUAL (nunca a transação/chat).
  ///
  /// **Combo**: mesmo sender+gift dentro da janela de 4s atualiza a entrada
  /// existente (soma quantity, atualiza timestamp) SEM reiniciar uma
  /// animação já em andamento ou já finalizada — o contador (`x5`, `x10`)
  /// simplesmente reflete o `quantity` atualizado do mesmo objeto.
  ///
  /// **Duração dinâmica**: cada gift usa `LiveGift.resolvedDurationMs`, já
  /// clampado nos limites seguros do `resolvedDisplayType` — nunca confia
  /// só no valor da rede, mesmo que o backend já valide (defesa em
  /// profundidade).

  LiveRoomGiftsViewModelProvider call(String roomId) =>
      LiveRoomGiftsViewModelProvider._(argument: roomId, from: this);

  @override
  String toString() => r'liveRoomGiftsViewModelProvider';
}

/// 🎁 ViewModel das animações de presente em tempo real.
///
/// ============================================================================
/// ARQUITETURA PROFISSIONAL DE EXIBIÇÃO (4 modos) — ver
/// GIFT_DISPLAY_ARCHITECTURE_ANALYSIS.md e SVGA_NOT_SUPPORTED.md
/// ============================================================================
///
/// Cada [LiveGift] resolve seu tipo via `LiveGift.resolvedDisplayType`
/// (fallback retrocompatível baseado em `isFullscreen` se o backend não
/// enviar `display_type`).
///
/// **Chat imediato**: TODO presente aparece IMEDIATAMENTE em `state` assim
/// que chega — o chat (`ChatTicker`) não espera nenhuma animação terminar.
/// Isso elimina o atraso histórico onde a mensagem só aparecia depois da
/// animação (~3s de espera desnecessária).
///
/// **Fila visual com prioridade**: apenas presentes com
/// `displayType.entersVisualQueue == true` (center_small, center_large,
/// fullscreen — NUNCA chat) entram na fila de animações do overlay:
///   - Processa **1 animação por vez** — trivialmente garante que nunca
///     há dois fullscreen (ou dois de qualquer tipo) simultâneos.
///   - Sempre escolhe a MAIOR prioridade pendente primeiro
///     (fullscreen=30 > center_large=20 > center_small=10).
///   - Dentro da mesma prioridade, respeita FIFO (ordem de chegada).
///   - Tem tamanho máximo (`_maxVisualQueue`) — em overflow, descarta a
///     entrada mais antiga da fila VISUAL (nunca a transação/chat).
///
/// **Combo**: mesmo sender+gift dentro da janela de 4s atualiza a entrada
/// existente (soma quantity, atualiza timestamp) SEM reiniciar uma
/// animação já em andamento ou já finalizada — o contador (`x5`, `x10`)
/// simplesmente reflete o `quantity` atualizado do mesmo objeto.
///
/// **Duração dinâmica**: cada gift usa `LiveGift.resolvedDurationMs`, já
/// clampado nos limites seguros do `resolvedDisplayType` — nunca confia
/// só no valor da rede, mesmo que o backend já valide (defesa em
/// profundidade).

abstract class _$LiveRoomGiftsViewModel extends $Notifier<List<LiveGift>> {
  late final _$args = ref.$arg as String;
  String get roomId => _$args;

  List<LiveGift> build(String roomId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<List<LiveGift>, List<LiveGift>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<LiveGift>, List<LiveGift>>,
              List<LiveGift>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
