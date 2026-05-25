import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../data/repositories/gift_repository.dart';
import '../../../domain/models/gifter_level.dart';

part 'gifter_level_view_model.g.dart';

/// 🎖️ ViewModel do nível do gifter (espectador) logado.
///
/// Consome `GET /live/gifts/me/level` do brawe-connect. Usado no header
/// da sacola de presentes e em futuros badges no chat.
///
/// O nível é atualizado pelo backend automaticamente quando o usuário:
/// - Envia gift (+50 XP)
/// - Entra em live (+10 XP)
/// - Manda mensagem no chat (+2 XP)
/// - Assiste live (+1 XP/min, cap 3h/sessão)
///
/// Após enviar um gift, chame `refresh()` para atualizar a UI.
@riverpod
class GifterLevelViewModel extends _$GifterLevelViewModel {
  @override
  FutureOr<GifterLevel> build() async {
    return ref.read(giftRepositoryProvider).getMyGifterLevel();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(giftRepositoryProvider).getMyGifterLevel(),
    );
  }
}
