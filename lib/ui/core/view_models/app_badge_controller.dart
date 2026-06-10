import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/services/app_badge_service.dart';
import '../../chat/view_models/unread_count_provider.dart';
import '../../notifications/view_models/notifications_view_model.dart';

part 'app_badge_controller.g.dart';

/// Mantém o badge do ícone do app sincronizado com as fontes de "não lidos"
/// que **já existem** no projeto — sem criar contadores paralelos:
///
///  • [notificationsUnreadCountProvider] → notificações (likes, follows, …)
///  • [unreadCountProvider]              → mensagens diretas (DMs)
///
/// Sempre que qualquer um dos dois muda, o total é recalculado e empurrado para
/// o badge do SO via [AppBadgeService]. Como é `keepAlive`, basta instanciá-lo
/// uma vez no boot (ver `main.dart`) e ele permanece reativo durante todo o
/// ciclo de vida do app.
///
/// Segue o mesmo padrão de Notifier do [UnreadCount] (chat) para consistência.
@Riverpod(keepAlive: true)
class AppBadgeController extends _$AppBadgeController {
  @override
  int build() {
    // Observa as duas fontes. Para notificações usamos `asData?.value` (0
    // durante loading/erro) — o badge nunca deve "piscar" um valor incorreto.
    final notifications =
        ref.watch(notificationsUnreadCountProvider).asData?.value ?? 0;
    final messages = ref.watch(unreadCountProvider);

    final total = notifications + messages;
    // Fire-and-forget: o service trata plataforma e falhas internamente.
    ref.read(appBadgeServiceProvider).setCount(total);
    return total;
  }

  /// Reavalia as fontes de não-lidos e deixa o `build` recalcular o badge.
  /// Use após eventos externos que mudam a contagem sem passar pelos providers
  /// reativos (push recebido em foreground, app retomado do background, ou logo
  /// após marcar notificações como lidas).
  ///
  /// Centraliza num só lugar QUAIS são as fontes de "não lidos", evitando que
  /// outras camadas precisem importar múltiplos view models.
  void refresh() {
    ref.invalidate(notificationsUnreadCountProvider);
    ref.read(unreadCountProvider.notifier).refresh();
  }
}

