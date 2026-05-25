import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../data/repositories/gift_repository.dart';
import '../../../data/repositories/live_repository.dart';
import '../../../domain/models/gifter.dart';
import '../../../domain/models/live_gift.dart';

part 'top_gifters_view_model.g.dart';

/// 🏆 Top‑gifters do MVP (pódio 1‑2‑3 no header da live).
///
/// Em tempo real: ao receber um novo `gift_received` via Socket.IO, aplicamos
/// um *patch otimista* (soma direto no ranking local sem ida ao backend) e
/// agendamos um refetch de fundo a cada 8s para reconciliar com o servidor
/// (ranking real considera `is_processed` + agregação por `sender_id`).
@riverpod
class TopGiftersViewModel extends _$TopGiftersViewModel {
  StreamSubscription<LiveGift>? _giftSub;
  Timer? _refetchDebounce;

  @override
  FutureOr<List<Gifter>> build(String roomId) async {
    final repo = ref.read(giftRepositoryProvider);
    final liveRepo = ref.read(liveRepositoryProvider);

    ref.onDispose(() {
      _giftSub?.cancel();
      _refetchDebounce?.cancel();
    });

    // Escuta cada gift que chega na sala e atualiza o ranking ao vivo.
    _giftSub = liveRepo.watchGifts(roomId).listen(_onIncomingGift);

    return repo.getTopGifters(roomId);
  }

  void _onIncomingGift(LiveGift gift) {
    // Só gifts monetários contam no ranking (backend filtra por
    // `total_usdt > 0`). `value` aqui vem em USDT do payload do servidor.
    final spent = (gift.value * gift.quantity).toDouble();
    if (spent <= 0) return;

    final current = state.valueOrNull ?? const <Gifter>[];
    final idx = current.indexWhere((g) => g.id == gift.senderId);

    final List<Gifter> updated;
    if (idx >= 0) {
      final existing = current[idx];
      final patched = Gifter(
        id: existing.id,
        name: existing.name,
        avatarUrl: existing.avatarUrl,
        totalSpent: existing.totalSpent + spent,
        rank: existing.rank,
      );
      updated = [...current]..[idx] = patched;
    } else {
      updated = [
        ...current,
        Gifter(
          id: gift.senderId,
          name: gift.senderName,
          avatarUrl: gift.senderAvatarUrl,
          totalSpent: spent,
        ),
      ];
    }

    updated.sort((a, b) => b.totalSpent.compareTo(a.totalSpent));
    // Re‑numera os ranks (1‑based) — o pódio usa para mostrar 🥇🥈🥉
    final ranked = <Gifter>[
      for (var i = 0; i < updated.length; i++)
        Gifter(
          id: updated[i].id,
          name: updated[i].name,
          avatarUrl: updated[i].avatarUrl,
          totalSpent: updated[i].totalSpent,
          rank: i + 1,
        ),
    ];
    state = AsyncValue.data(ranked);

    // Reconciliação com o servidor (debounced — agrega vários gifts num só fetch).
    _refetchDebounce?.cancel();
    _refetchDebounce = Timer(const Duration(seconds: 5), () {
      if (!ref.mounted) return;
      _silentRefetch();
    });
  }

  Future<void> _silentRefetch() async {
    try {
      final fresh =
          await ref.read(giftRepositoryProvider).getTopGifters(roomId);
      if (!ref.mounted) return;
      state = AsyncValue.data(fresh);
    } catch (_) {
      // Mantém o estado otimista — próximo gift dispara nova tentativa.
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(giftRepositoryProvider).getTopGifters(roomId),
    );
  }
}

