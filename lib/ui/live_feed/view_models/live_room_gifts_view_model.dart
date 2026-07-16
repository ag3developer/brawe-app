import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../data/repositories/live_repository.dart';
import '../../../domain/models/live_gift.dart';

part 'live_room_gifts_view_model.g.dart';

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
@riverpod
class LiveRoomGiftsViewModel extends _$LiveRoomGiftsViewModel {
  static const Duration _comboWindow = Duration(seconds: 4);
  // Tempo total que uma entrada permanece visível no chat/state após a
  // última atualização (combo prorroga o timer). Chat aparece imediato —
  // este TTL controla só quando a entrada finalmente desaparece.
  static const Duration _displayTtl = Duration(seconds: 8);
  static const int _maxVisible = 8; // Cap da lista total (chat + overlay)
  static const int _maxVisualQueue = 10; // Cap da fila visual (Fase 8)

  StreamSubscription<LiveGift>? _subscription;
  final Map<String, Timer> _expiryTimers = {};

  // ── Fila visual com prioridade (apenas displayType.entersVisualQueue) ──
  final List<String> _pendingQueue = []; // combo keys, ordem de chegada
  String? _currentlyAnimatingKey;
  Timer? _animationTimer;

  @override
  List<LiveGift> build(String roomId) {
    final repository = ref.read(liveRepositoryProvider);
    _subscribe();
    unawaited(repository.connectToRoom(roomId));
    ref.onDispose(() {
      _subscription?.cancel();
      for (final t in _expiryTimers.values) {
        t.cancel();
      }
      _animationTimer?.cancel();
      _expiryTimers.clear();
      _pendingQueue.clear();
      _currentlyAnimatingKey = null;
      repository.disconnectFromRoom(roomId);
    });
    return [];
  }

  void _subscribe() {
    _subscription?.cancel();
    _subscription = ref
        .read(liveRepositoryProvider)
        .watchGifts(roomId)
        .listen(_handleIncoming);
  }

  String _comboKey(LiveGift gift) => '${gift.senderId}::${gift.giftId}';

  void _handleIncoming(LiveGift gift) {
    final key = _comboKey(gift);
    final now = DateTime.now();

    final existingIndex = state.indexWhere(
      (g) => _comboKey(g) == key && now.difference(g.timestamp) <= _comboWindow,
    );
    final isNewEntry = existingIndex < 0;

    final List<LiveGift> next;
    final LiveGift entry;
    if (!isNewEntry) {
      final existing = state[existingIndex];
      // 🎯 Combo: soma quantidade, atualiza timestamp, preserva
      // `isAnimating` como está — NÃO reinicia animação em andamento nem
      // relança uma já finalizada (Fase 10: "não reiniciar animação a
      // cada incremento"). A UI lê `quantity` do mesmo objeto, então o
      // badge "xN" atualiza sozinho sem replay.
      entry = existing.copyWith(
        quantity: existing.quantity + gift.quantity,
        timestamp: now,
        value: existing.value > gift.value ? existing.value : gift.value,
      );
      next = [...state]..removeAt(existingIndex);
      next.add(entry);
    } else {
      // Chat imediato: entra na lista já visível, isAnimating começa
      // false — só vira true quando (e se) a fila visual escalar este
      // item pra animar (ver `_tryStartNext`). Presentes tipo `chat`
      // nunca entram na fila, então nunca ficam com isAnimating=true.
      entry = gift.copyWith(timestamp: now, isAnimating: false);
      next = [...state, entry];
    }

    if (next.length > _maxVisible) {
      final dropped = next.removeAt(0);
      final droppedKey = _comboKey(dropped);
      _expiryTimers.remove(droppedKey)?.cancel();
      _pendingQueue.remove(droppedKey);
      if (_currentlyAnimatingKey == droppedKey) {
        _currentlyAnimatingKey = null;
        _animationTimer?.cancel();
      }
    }
    state = next;

    // TTL de exibição — prorroga o timer a cada atualização (combo).
    _expiryTimers.remove(key)?.cancel();
    _expiryTimers[key] = Timer(_displayTtl, () {
      if (!ref.mounted) return;
      debugPrint('🎬 [GIFT] Removido do state (ID: $key)');
      state = state.where((g) => _comboKey(g) != key).toList();
      _expiryTimers.remove(key);
      _pendingQueue.remove(key);
      if (_currentlyAnimatingKey == key) {
        _currentlyAnimatingKey = null;
        _animationTimer?.cancel();
        _tryStartNext();
      }
    });

    // ── Fila visual (apenas para tipos diferentes de "chat") ──
    final displayType = entry.resolvedDisplayType;
    if (displayType.entersVisualQueue && isNewEntry) {
      _enqueueVisual(key);
    }
    _tryStartNext();
  }

  void _enqueueVisual(String key) {
    if (_pendingQueue.contains(key) || _currentlyAnimatingKey == key) return;
    _pendingQueue.add(key);
    if (_pendingQueue.length > _maxVisualQueue) {
      // Overflow: descarta o item mais antigo da FILA VISUAL (não afeta
      // o chat/transação — a entrada continua em `state` e visível no
      // chat, só não vai animar no overlay).
      final discarded = _pendingQueue.removeAt(0);
      debugPrint(
        '🎁 [GIFT-QUEUE] Fila visual cheia — descartando animação de $discarded (chat preservado)',
      );
    }
  }

  int? _priorityOf(String key) {
    for (final g in state) {
      if (_comboKey(g) == key) return g.resolvedPriority;
    }
    return null;
  }

  /// Escala a próxima animação se não houver nenhuma rodando.
  /// Sempre escolhe a MAIOR prioridade pendente; em caso de empate,
  /// respeita a ordem de chegada (primeiro da lista com aquela prioridade).
  void _tryStartNext() {
    if (_currentlyAnimatingKey != null) return; // slot ocupado
    if (_pendingQueue.isEmpty) return;

    String? bestKey;
    int bestPriority = -1;
    for (final k in _pendingQueue) {
      final p = _priorityOf(k);
      if (p == null) continue; // entrada já expirou do state — ignora
      if (p > bestPriority) {
        bestPriority = p;
        bestKey = k;
      }
    }
    if (bestKey == null) {
      // Fila só tinha entradas órfãs (já expiraram) — limpa.
      _pendingQueue.clear();
      return;
    }

    _pendingQueue.remove(bestKey);
    _startAnimating(bestKey);
  }

  void _startAnimating(String key) {
    _currentlyAnimatingKey = key;
    state = state
        .map((g) => _comboKey(g) == key ? g.copyWith(isAnimating: true) : g)
        .toList();

    LiveGift? gift;
    for (final g in state) {
      if (_comboKey(g) == key) {
        gift = g;
        break;
      }
    }
    if (gift == null) {
      // Item desapareceu entre o enqueue e o start (raro, mas defensivo).
      _currentlyAnimatingKey = null;
      _tryStartNext();
      return;
    }

    // 🎯 Duração dinâmica — vem do backend (já clampada lá) e é
    // reclampada aqui via `resolvedDisplayType.clampDuration()` como
    // defesa em profundidade (Fase 7 — nunca confiar só na rede).
    final durationMs = gift.resolvedDurationMs;
    _animationTimer?.cancel();
    _animationTimer = Timer(Duration(milliseconds: durationMs), () {
      if (!ref.mounted) return;
      state = state
          .map((g) => _comboKey(g) == key ? g.copyWith(isAnimating: false) : g)
          .toList();
      if (_currentlyAnimatingKey == key) {
        _currentlyAnimatingKey = null;
      }
      _tryStartNext();
    });
  }
}
