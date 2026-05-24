import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../data/repositories/live_repository.dart';
import '../../../domain/models/live_gift.dart';

part 'live_room_gifts_view_model.g.dart';

/// 🎁 ViewModel das animações de presente em tempo real.
///
/// Faz *combo* no estilo TikTok: presentes do mesmo `senderId+giftId`
/// recebidos numa janela de 4s viram um único item com `quantity` somado
/// (ex.: 10 rosas em rajada → "Jose Carlos enviou 🌹 x10").
///
/// O state é uma lista das últimas 6 entradas; cada uma fica visível por
/// ~5s após a última atualização — combos prorrogam o timer.
@riverpod
class LiveRoomGiftsViewModel extends _$LiveRoomGiftsViewModel {
  static const Duration _comboWindow = Duration(seconds: 4);
  static const Duration _displayTtl = Duration(seconds: 5);
  static const int _maxVisible = 6;

  StreamSubscription<LiveGift>? _subscription;
  final Map<String, Timer> _expiryTimers = {};

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
      _expiryTimers.clear();
      repository.disconnectFromRoom(roomId);
    });
    return [];
  }

  void _subscribe() {
    _subscription?.cancel();
    _subscription = ref.read(liveRepositoryProvider).watchGifts(roomId).listen(
      _handleIncoming,
    );
  }

  String _comboKey(LiveGift gift) => '${gift.senderId}::${gift.giftId}';

  void _handleIncoming(LiveGift gift) {
    final key = _comboKey(gift);
    final now = DateTime.now();

    final existingIndex = state.indexWhere(
      (g) => _comboKey(g) == key && now.difference(g.timestamp) <= _comboWindow,
    );

    final List<LiveGift> next;
    final LiveGift entry;
    if (existingIndex >= 0) {
      final existing = state[existingIndex];
      entry = existing.copyWith(
        quantity: existing.quantity + gift.quantity,
        timestamp: now,
        // Preserve highest value (for premium detection)
        value: existing.value > gift.value ? existing.value : gift.value,
      );
      next = [...state]..removeAt(existingIndex);
      next.add(entry);
    } else {
      entry = gift.copyWith(timestamp: now);
      next = [...state, entry];
    }

    // Cap visible queue
    if (next.length > _maxVisible) {
      final dropped = next.removeAt(0);
      _expiryTimers.remove(_comboKey(dropped))?.cancel();
    }
    state = next;

    // (Re)schedule expiry for this combo
    _expiryTimers.remove(key)?.cancel();
    _expiryTimers[key] = Timer(_displayTtl, () {
      if (!ref.mounted) return;
      state = state.where((g) => _comboKey(g) != key).toList();
      _expiryTimers.remove(key);
    });
  }
}
