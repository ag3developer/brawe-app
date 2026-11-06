// Providers do "Minha agência" (escritos à mão, sem codegen).
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/repositories/creator_agency_repository.dart';
import '../../../domain/models/creator_agency.dart';

/// GET /creator/agency — convites, vínculo, eventos, desempenho.
final creatorAgencyProvider = FutureProvider.autoDispose<AgencyState>(
  (ref) => ref.read(creatorAgencyRepositoryProvider).getState(),
  retry: (_, _) => null, // erro aparece na hora, com botão de tentar de novo
);

/// GET /creator/agency/invites/{id} — convite aberto pelo cartão do chat.
final agencyInviteProvider = FutureProvider.autoDispose.family<AgencyInvite, String>(
  (ref, id) => ref.read(creatorAgencyRepositoryProvider).getInvite(id),
  retry: (_, _) => null,
);

/// Selo do painel: convites pendentes (0 se já está em agência ou em erro).
final agencyPendingBadgeProvider = Provider.autoDispose<int>(
  (ref) => ref.watch(creatorAgencyProvider).value?.pendingCount ?? 0,
);

/// "YYYY-MM" de uma data (chave dos endpoints de desempenho).
String agencyMonthKey(DateTime d) => '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}';

/// Os últimos [count] meses (mais recente primeiro), a partir de [now].
List<String> agencyRecentMonths({int count = 6, DateTime? now}) {
  final n = now ?? DateTime.now();
  return [for (var i = 0; i < count; i++) agencyMonthKey(DateTime(n.year, n.month - i))];
}

/// Mês escolhido no filtro de período (compartilhado entre Resumo e Metas).
class AgencyMonthNotifier extends Notifier<String> {
  @override
  String build() => agencyMonthKey(DateTime.now());
  void select(String month) => state = month;
}

final agencyMonthProvider = NotifierProvider<AgencyMonthNotifier, String>(AgencyMonthNotifier.new);

/// GET /creator/agency/performance?month=YYYY-MM
final agencyPerformanceProvider = FutureProvider.autoDispose.family<AgencyPerformance, String>(
  (ref, month) => ref.read(creatorAgencyRepositoryProvider).getPerformance(month: month),
  retry: (_, _) => null,
);

/// GET /creator/agency/performance/history?months=6 (mais recente primeiro).
final agencyHistoryProvider = FutureProvider.autoDispose<List<AgencyPerformance>>(
  (ref) => ref.read(creatorAgencyRepositoryProvider).getPerformanceHistory(months: 6),
  retry: (_, _) => null,
);
