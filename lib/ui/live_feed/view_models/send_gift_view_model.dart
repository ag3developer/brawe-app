import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../data/repositories/gift_repository.dart';
import '../../../domain/models/failure.dart';

part 'send_gift_view_model.g.dart';

@riverpod
class SendGiftViewModel extends _$SendGiftViewModel {
  /// Mensagem amigável do último erro de envio (saldo insuficiente,
  /// cooldown, erro de servidor) — a UI mostra ao usuário.
  String? lastErrorMessage;

  /// `true` quando o último erro foi falta de saldo/moedas.
  bool lastErrorIsBalance = false;

  @override
  AsyncValue<void> build() {
    return const AsyncValue.data(null);
  }

  Future<bool> sendGift({
    required String roomId,
    required String giftId,
    required String receiverId,
    int quantity = 1,
    String? battleId,
  }) async {
    // 🔒 Mantém o provider vivo durante a chamada assíncrona.
    // Sem isso, o autoDispose padrão do @riverpod descarta este provider
    // no instante em que o bottom sheet (GiftsOverlay) é fechado via
    // Navigator.pop() — que acontece IMEDIATAMENTE após disparar sendGift()
    // (pop otimista, antes da resposta HTTP chegar). O request continua em
    // voo, mas o `ref` interno do provider já foi descartado, causando
    // "Cannot use the Ref of sendGiftViewModelProvider after it has been
    // disposed" ao tentar `ref.read(giftRepositoryProvider)` depois do pop.
    final keepAliveLink = ref.keepAlive();

    state = const AsyncValue.loading();
    lastErrorMessage = null;
    lastErrorIsBalance = false;

    try {
      await ref
          .read(giftRepositoryProvider)
          .sendGift(
            roomId: roomId,
            giftId: giftId,
            receiverId: receiverId,
            quantity: quantity,
            battleId: battleId,
          );
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      lastErrorMessage = e is Failure
          ? e.toDisplayMessage()
          : 'Não foi possível enviar o presente';
      final lower = lastErrorMessage!.toLowerCase();
      lastErrorIsBalance =
          lower.contains('saldo') ||
          lower.contains('insuficiente') ||
          lower.contains('insufficient');
      state = AsyncValue.error(e, st);
      return false;
    } finally {
      // ✅ Libera o keep-alive assim que a operação termina (sucesso ou
      // erro) — o provider volta ao comportamento autoDispose normal.
      keepAliveLink.close();
    }
  }
}
