// Dados do cabeçalho do painel do criador (nome, avatar, ganhos do mês).
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/repositories/auth_state_provider.dart';
import 'creator_analytics_view_model.dart';

class CreatorHeaderData {
  const CreatorHeaderData({required this.name, this.avatarUrl});
  final String name;
  final String? avatarUrl;
}

final creatorHeaderProvider = FutureProvider.autoDispose<CreatorHeaderData?>((ref) async {
  final user = await ref.watch(authStateProvider.future);
  if (user == null) return null;
  return CreatorHeaderData(name: user.name, avatarUrl: user.avatarUrl);
});

/// Ganhos dos últimos 30 dias (soma da série diária). Null se indisponível.
final creatorMonthEarningsProvider = FutureProvider.autoDispose<double?>((ref) async {
  try {
    final pts = await ref.watch(earningsHistoryProvider('30d').future);
    return pts.fold<double>(0, (a, p) => a + p.value);
  } catch (_) {
    return null;
  }
});
