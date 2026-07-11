import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/network/dio_provider.dart';
import 'marketplace_cart_service.dart';
import 'marketplace_cart_service_impl.dart';

part 'marketplace_cart_service_provider.g.dart';

/// Riverpod provider for [MarketplaceCartService].
/// Uses [dioProvider] (main backend) for marketplace cart endpoints.
///
/// ⭐ CRÍTICO: Tracks affiliate commissions through CartItem metadata.
@riverpod
MarketplaceCartService marketplaceCartService(Ref ref) {
  final dio = ref.watch(dioProvider);
  return MarketplaceCartServiceImpl(dio);
}
