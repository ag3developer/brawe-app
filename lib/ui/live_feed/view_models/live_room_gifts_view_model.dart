import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../data/repositories/auth_state_provider.dart';
import '../../../data/repositories/live_repository.dart';
import '../../../domain/models/gift_display_type.dart';
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

  /// IDs de transação já processados — o mesmo presente pode chegar mais
  /// de uma vez (reconexão, emissões duplicadas do servidor). Sem isso 1
  /// rosa virava "x3" via combo.
  final Set<String> _seenIds = {};
  static const int _maxSeenIds = 300;

  // ── Faixas de presentes pequenos (centerSmall) — estilo TikTok ──
  // Até 2 avisos ao mesmo tempo, cada um na sua faixa, INDEPENDENTES das
  // animações grandes. Antes tudo passava por uma fila única: um presente
  // pequeno esperava uma animação épica (6-12s) e acabava descartado.
  static const int laneCount = 2;
  final List<String?> _laneKeys = List<String?>.filled(laneCount, null);
  final List<Timer?> _laneTimers = List<Timer?>.filled(laneCount, null);
  final List<String> _smallQueue = [];
  final Map<String, int> _laneByGiftId = {};

  /// Faixa (0 = de baixo, 1 = de cima) em que o presente [giftId] está.
  int? laneOf(String giftId) => _laneByGiftId[giftId];

  // ── Fila das animações grandes (centerLarge / fullscreen) ──
  final List<String> _pendingQueue = []; // combo keys, ordem de chegada
  String? _currentlyAnimatingKey;
  Timer? _animationTimer;

  @override
  List<LiveGift> build(String roomId) {
    final repository = ref.read(liveRepositoryProvider);
    _subscribe();
    unawaited(_connectWithRetry(roomId));
    ref.onDispose(() {
      _subscription?.cancel();
      for (final t in _expiryTimers.values) {
        t.cancel();
      }
      _animationTimer?.cancel();
      for (final t in _laneTimers) {
        t?.cancel();
      }
      _expiryTimers.clear();
      _pendingQueue.clear();
      _smallQueue.clear();
      _currentlyAnimatingKey = null;
      repository.disconnectFromRoom(roomId);
    });
    return [];
  }

  /// Entra na sala do socket com retry — antes uma falha de rede no join
  /// ficava sem tratamento e o criador nunca recebia os presentes.
  Future<void> _connectWithRetry(String roomId) async {
    final repository = ref.read(liveRepositoryProvider);
    for (var attempt = 0; attempt < 5; attempt++) {
      try {
        await repository.connectToRoom(roomId);
        return;
      } catch (e) {
        debugPrint('🎁 [GIFT] connectToRoom falhou (${attempt + 1}/5): $e');
        await Future<void>.delayed(Duration(seconds: 1 << attempt));
        if (!ref.mounted) return;
      }
    }
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
    debugPrint(
      '[GIFT-FX] fila recebeu ${gift.giftName} id=${gift.id} '
      'display=${gift.resolvedDisplayType.name} anim=${gift.animationType} '
      'url=${gift.animationUrl != null}',
    );
    if (gift.id.isNotEmpty && !_seenIds.add(gift.id)) return; // duplicado
    if (_seenIds.length > _maxSeenIds) _seenIds.remove(_seenIds.first);
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
      // Descarta primeiro o mais antigo que NÃO está na tela nem na fila.
      var dropAt = next.indexWhere((g) => !_isBusy(_comboKey(g)));
      if (dropAt < 0) dropAt = 0;
      final dropped = next.removeAt(dropAt);
      final droppedKey = _comboKey(dropped);
      _expiryTimers.remove(droppedKey)?.cancel();
      _pendingQueue.remove(droppedKey);
      _smallQueue.remove(droppedKey);
      final lane = _laneKeys.indexOf(droppedKey);
      if (lane >= 0) _releaseLane(lane, notify: false);
      if (_currentlyAnimatingKey == droppedKey) {
        _currentlyAnimatingKey = null;
        _animationTimer?.cancel();
      }
    }
    state = next;

    // TTL de exibição — prorroga o timer a cada atualização (combo).
    _scheduleExpiry(key);

    // ── Exibição visual (tipo "chat" não anima — só aparece no chat) ──
    final displayType = entry.resolvedDisplayType;
    if (displayType == GiftDisplayType.centerSmall) {
      final lane = _laneKeys.indexOf(key);
      if (lane >= 0) {
        // Combo com o aviso ainda na tela: o "xN" atualiza no próprio
        // aviso e o tempo dele é prorrogado (TikTok).
        _startLaneTimer(lane, key, entry);
      } else if (isNewEntry) {
        _enqueueSmall(key);
      }
      _tryStartSmall();
    } else if (displayType.entersVisualQueue) {
      if (isNewEntry) _enqueueVisual(key);
      _tryStartNext();
    }
  }

  bool _isBusy(String key) =>
      _currentlyAnimatingKey == key ||
      _pendingQueue.contains(key) ||
      _laneKeys.contains(key) ||
      _smallQueue.contains(key);

  LiveGift? _entryFor(String key) {
    for (final g in state) {
      if (_comboKey(g) == key) return g;
    }
    return null;
  }

  void _setAnimating(String key, bool value) {
    state = state
        .map((g) => _comboKey(g) == key ? g.copyWith(isAnimating: value) : g)
        .toList();
  }

  // ── Vez para todos nas faixas ──
  // Meu presente fura a fila (quem envia precisa se ver na tela) e nunca é
  // descartado; ninguém ocupa as duas faixas ao mesmo tempo; com fila
  // grande cada aviso fica menos tempo para todo mundo ter a sua vez.
  bool _isMine(String key) {
    final me = ref.read(authStateProvider).value?.id;
    return me != null && me.isNotEmpty && key.startsWith('$me::');
  }

  String _senderOf(String key) => key.split('::').first;

  void _enqueueSmall(String key) {
    if (_smallQueue.contains(key)) return;
    if (_isMine(key)) {
      _smallQueue.insert(0, key);
    } else {
      _smallQueue.add(key);
    }
    while (_smallQueue.length > _maxVisualQueue) {
      final idx = _smallQueue.indexWhere((k) => !_isMine(k));
      if (idx < 0) break;
      final discarded = _smallQueue.removeAt(idx);
      debugPrint('🎁 [GIFT-LANES] Fila cheia — descartando aviso $discarded');
    }
  }

  /// Próximo da fila: o meu primeiro; senão o primeiro de alguém que ainda
  /// não está numa faixa.
  int _nextSmallIndex() {
    final mine = _smallQueue.indexWhere(_isMine);
    if (mine >= 0) return mine;
    final busy = _laneKeys.whereType<String>().map(_senderOf).toSet();
    final fair = _smallQueue.indexWhere((k) => !busy.contains(_senderOf(k)));
    return fair >= 0 ? fair : 0;
  }

  /// Ocupa as faixas livres com os próximos presentes pequenos da fila.
  void _tryStartSmall() {
    while (_smallQueue.isNotEmpty) {
      final lane = _laneKeys.indexOf(null);
      if (lane < 0) return; // as 2 faixas ocupadas
      final key = _smallQueue.removeAt(_nextSmallIndex());
      final gift = _entryFor(key);
      if (gift == null) continue; // já expirou do state
      _laneKeys[lane] = key;
      _laneByGiftId[gift.id] = lane;
      _setAnimating(key, true);
      _startLaneTimer(lane, key, gift);
    }
  }

  void _startLaneTimer(int lane, String key, LiveGift gift) {
    _laneTimers[lane]?.cancel();
    // Fila grande → passagem mais curta (o meu fica o tempo inteiro).
    final waiting = _smallQueue.length;
    var ms = gift.resolvedDurationMs;
    if (!_isMine(key) && waiting >= 6) {
      ms = ms.clamp(0, 1600);
    } else if (!_isMine(key) && waiting >= 3) {
      ms = ms.clamp(0, 2200);
    }
    _laneTimers[lane] = Timer(
      Duration(milliseconds: ms),
      () {
        if (!ref.mounted || _laneKeys[lane] != key) return;
        _releaseLane(lane);
      },
    );
  }

  void _releaseLane(int lane, {bool notify = true}) {
    final key = _laneKeys[lane];
    _laneTimers[lane]?.cancel();
    _laneTimers[lane] = null;
    _laneKeys[lane] = null;
    if (key == null) return;
    final gift = _entryFor(key);
    if (gift != null) _laneByGiftId.remove(gift.id);
    if (notify) {
      _setAnimating(key, false);
      _tryStartSmall();
    }
  }

  /// TTL de exibição. Nunca remove uma entrada que está animando nem uma
  /// que ainda espera na fila visual — antes o TTL (8s) cortava animações
  /// fullscreen (6-12s) no meio e descartava as que esperavam na fila.
  void _scheduleExpiry(String key, [Duration delay = _displayTtl]) {
    _expiryTimers.remove(key)?.cancel();
    _expiryTimers[key] = Timer(delay, () {
      if (!ref.mounted) return;
      if (_isBusy(key)) {
        _scheduleExpiry(key, const Duration(seconds: 2));
        return;
      }
      debugPrint('🎬 [GIFT] Removido do state (ID: $key)');
      state = state.where((g) => _comboKey(g) != key).toList();
      _expiryTimers.remove(key);
    });
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
    debugPrint('[GIFT-FX] fila: vez de animar $key');
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
