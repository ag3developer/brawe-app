import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/repositories/chat_repository.dart';
import '../../../data/services/messages_service.dart';

part 'presence_provider.g.dart';

/// Cache central de presença de usuários. Faz polling em batch a cada 30s
/// para todos os userIds atualmente "observados".
@Riverpod(keepAlive: true)
class PresenceCache extends _$PresenceCache {
  final Set<String> _watched = <String>{};
  Timer? _timer;

  @override
  Map<String, UserPresence> build() {
    ref.onDispose(() {
      _timer?.cancel();
    });
    _timer = Timer.periodic(const Duration(seconds: 30), (_) => _refresh());
    return const {};
  }

  /// Registra `userId` para atualização periódica e dispara um fetch imediato.
  void watch(String userId) {
    if (userId.isEmpty) return;
    if (_watched.add(userId)) {
      _refresh();
    }
  }

  void watchAll(Iterable<String> userIds) {
    var added = false;
    for (final id in userIds) {
      if (id.isEmpty) continue;
      if (_watched.add(id)) added = true;
    }
    if (added) _refresh();
  }

  void unwatch(String userId) {
    _watched.remove(userId);
  }

  Future<void> _refresh() async {
    if (_watched.isEmpty) return;
    try {
      final result = await ref
          .read(chatRepositoryProvider)
          .getPresence(_watched.toList());
      if (!ref.mounted) return;
      state = {...state, ...result};
    } catch (e) {
      debugPrint('PresenceCache refresh failed: $e');
    }
  }
}
