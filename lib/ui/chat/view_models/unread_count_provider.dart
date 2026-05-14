import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/repositories/chat_repository.dart';

part 'unread_count_provider.g.dart';

/// Total global de DMs não lidas. Faz polling a cada 60s e atualiza
/// sempre que chega uma `message_notification` via socket.
@Riverpod(keepAlive: true)
class UnreadCount extends _$UnreadCount {
  Timer? _timer;
  StreamSubscription? _notificationsSubscription;

  @override
  int build() {
    ref.onDispose(() {
      _timer?.cancel();
      _notificationsSubscription?.cancel();
    });

    final repo = ref.read(chatRepositoryProvider);

    // Conectar socket + listener de notificações (fire-and-forget).
    () async {
      try {
        await repo.connect();
      } catch (_) {}
      _notificationsSubscription =
          repo.watchNotifications().listen((_) => refresh());
    }();

    refresh();
    _timer = Timer.periodic(const Duration(seconds: 60), (_) => refresh());

    return 0;
  }

  Future<void> refresh() async {
    try {
      final count = await ref.read(chatRepositoryProvider).getUnreadCount();
      if (ref.mounted) state = count;
    } catch (e) {
      debugPrint('UnreadCount refresh failed: $e');
    }
  }
}
