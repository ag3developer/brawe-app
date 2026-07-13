import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/dio_provider.dart';
import '../services/marketplace_payment_service.dart';
import '../services/marketplace_payment_service_impl.dart';

/// Provider para [MarketplacePaymentService] (acesso ao Dio singleton).
///
/// Oferece a interface [MarketplacePaymentService] com a implementação
/// [MarketplacePaymentServiceImpl] — usa o mesmo [dioProvider] configurado
/// com autenticação (token bearer) e URLs base corretas.
final marketplacePaymentServiceProvider = Provider<MarketplacePaymentService>((
  ref,
) {
  final dio = ref.watch(dioProvider);
  return MarketplacePaymentServiceImpl(dio);
});

/// FutureProvider para iniciar um pagamento
///
/// Uso:
/// ```dart
/// final paymentResult = ref.watch(
///   initiatePaymentProvider((orderId: 'order_123', method: 'pix'))
/// );
/// ```
final initiatePaymentProvider =
    FutureProvider.family<
      Map<String, dynamic>,
      ({String orderId, String method})
    >((ref, params) async {
      final service = ref.watch(marketplacePaymentServiceProvider);
      return service.initiatePayment(params.orderId, params.method);
    });

/// FutureProvider para verificar status de pagamento
///
/// Uso:
/// ```dart
/// final status = ref.watch(checkPaymentStatusProvider('order_123'));
/// ```
final checkPaymentStatusProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, orderId) async {
      final service = ref.watch(marketplacePaymentServiceProvider);
      return service.checkPaymentStatus(orderId);
    });
