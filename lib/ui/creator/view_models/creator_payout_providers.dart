// Providers da Monetização (escritos à mão, sem codegen).
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/repositories/creator_payout_repository.dart';
import '../../../domain/models/creator_payout.dart';

/// GET /creator/payouts — saldo de diamantes, regras, conta e pedidos.
final creatorPayoutOverviewProvider = FutureProvider.autoDispose<PayoutOverview>(
  (ref) => ref.read(creatorPayoutRepositoryProvider).overview(),
  retry: (_, _) => null, // erro aparece na hora, com botão de tentar de novo
);
