import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/dio_provider.dart';
import 'marketplace_shipping_service.dart';
import 'marketplace_shipping_service_impl.dart';

/// Provider para [MarketplaceShippingService] (acesso ao Dio singleton).
///
/// Oferece a interface [MarketplaceShippingService] com a implementação
/// [MarketplaceShippingServiceImpl] — ambas usam o mesmo [dioProvider]
/// configurado com autenticação (token bearer) e URLs base corretas.
final marketplaceShippingServiceProvider = Provider<MarketplaceShippingService>(
  (ref) {
    final dio = ref.watch(dioProvider);
    return MarketplaceShippingServiceImpl(dio);
  },
);
