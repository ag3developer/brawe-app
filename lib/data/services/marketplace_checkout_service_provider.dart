import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/network/dio_provider.dart';
import '../../core/network/live_dio_provider.dart';
import 'marketplace_checkout_service.dart';
import 'marketplace_checkout_service_impl.dart';

part 'marketplace_checkout_service_provider.g.dart';

/// Riverpod provider for [MarketplaceCheckoutService].
/// Coordinates between Main Backend and Connect Backend.
///
/// - **Main Backend** ([dioProvider]): POST /marketplace/orders (checkout)
/// - **Connect Backend** ([liveDioProvider]): POST /shopping/payments (payment)
///
/// ⭐ CRÍTICO: This is the primary transaction flow for Fase 0.
/// Handles affiliate commission tracking and order fulfillment.
@riverpod
MarketplaceCheckoutService marketplaceCheckoutService(Ref ref) {
  final mainDio = ref.watch(dioProvider);
  final connectDio = ref.watch(liveDioProvider);
  return MarketplaceCheckoutServiceImpl(
    mainDio: mainDio,
    connectDio: connectDio,
  );
}
