import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/network/dio_provider.dart';
import 'marketplace_product_service.dart';
import 'marketplace_product_service_impl.dart';

part 'marketplace_product_service_provider.g.dart';

/// Riverpod provider for [MarketplaceProductService].
/// Uses [dioProvider] (main backend) for marketplace product endpoints.
@riverpod
MarketplaceProductService marketplaceProductService(Ref ref) {
  final dio = ref.watch(dioProvider);
  return MarketplaceProductServiceImpl(dio);
}
