import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/network/dio_provider.dart';
import 'marketplace_address_service.dart';
import 'marketplace_address_service_impl.dart';

part 'marketplace_address_service_provider.g.dart';

/// Riverpod provider for [MarketplaceAddressService].
/// Uses [dioProvider] (main backend) for shipping address endpoints.
///
/// **MVP NOTE:** This provider is optional for Fase 0.
/// Address data can be collected directly in checkout form if needed.
@riverpod
MarketplaceAddressService marketplaceAddressService(Ref ref) {
  final dio = ref.watch(dioProvider);
  return MarketplaceAddressServiceImpl(dio);
}
