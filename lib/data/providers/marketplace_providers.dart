import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/auth_state_provider.dart';
import '../repositories/marketplace_repository.dart';
import '../services/marketplace_address_service_provider.dart';
import '../services/marketplace_cart_service_provider.dart';
import '../services/marketplace_checkout_service_provider.dart';
import 'marketplace_payment_providers.dart';
import '../services/marketplace_product_service_provider.dart';
import '../services/marketplace_shipping_service_provider.dart';
import '../services/store_showcase_service_provider.dart';
import '../services/viacep_service.dart';
import '../../domain/models/marketplace_models.dart';

// ============================================================================
// REPOSITORY PROVIDER
// ============================================================================

/// Central marketplace repository aggregating all services.
final marketplaceRepositoryProvider = Provider((ref) {
  return MarketplaceRepository(
    storeShowcaseService: ref.watch(storeShowcaseServiceProvider),
    productService: ref.watch(marketplaceProductServiceProvider),
    cartService: ref.watch(marketplaceCartServiceProvider),
    checkoutService: ref.watch(marketplaceCheckoutServiceProvider),
    addressService: ref.watch(marketplaceAddressServiceProvider),
    shippingService: ref.watch(marketplaceShippingServiceProvider),
    paymentService: ref.watch(marketplacePaymentServiceProvider),
  );
});

// ============================================================================
// DATA PROVIDERS (FutureProvider-based, auto-refresh)
// ============================================================================

/// Fetch all available store showcases.
final storeShowcaseProvider = FutureProvider<List<Store>>((ref) async {
  final repo = ref.watch(marketplaceRepositoryProvider);
  final result = await repo.getStoreShowcase();
  return result.cast<Store>();
});

/// Fetch a single store by slug.
final storeDetailProvider = FutureProvider.family<Store, String>((
  ref,
  slug,
) async {
  final repo = ref.watch(marketplaceRepositoryProvider);
  final result = await repo.getStoreBySlug(slug);
  return result as Store;
});

/// Fetch user's affiliate applications.
final myAffiliateApplicationsProvider =
    FutureProvider<List<AffiliateApplication>>((ref) async {
      final repo = ref.watch(marketplaceRepositoryProvider);
      final result = await repo.getMyApplications();
      return result.cast<AffiliateApplication>();
    });

/// Fetch products for a specific store.
final storeProductsProvider =
    FutureProvider.family<
      List<Product>,
      ({String storeId, int page, int limit, String? search, String? sort})
    >((ref, params) async {
      final repo = ref.watch(marketplaceRepositoryProvider);
      final result = await repo.getStoreProducts(
        params.storeId,
        page: params.page,
        limit: params.limit,
        search: params.search,
        sort: params.sort,
      );
      return result.cast<Product>();
    });

/// Fetch product details.
final productDetailProvider = FutureProvider.family<Product, String>((
  ref,
  productId,
) async {
  final repo = ref.watch(marketplaceRepositoryProvider);
  final result = await repo.getProductDetail(productId);
  return result as Product;
});

/// Search products across stores.
final searchProductsProvider =
    FutureProvider.family<
      List<Product>,
      ({
        String query,
        String? storeId,
        String? category,
        double? minPrice,
        double? maxPrice,
        String? sort,
        int page,
        int limit,
      })
    >((ref, params) async {
      final repo = ref.watch(marketplaceRepositoryProvider);
      final result = await repo.searchProducts(
        params.query,
        storeId: params.storeId,
        category: params.category,
        minPrice: params.minPrice,
        maxPrice: params.maxPrice,
        sort: params.sort,
        page: params.page,
        limit: params.limit,
      );
      return result.cast<Product>();
    });

/// Fetch user's saved addresses.
final savedAddressesProvider = FutureProvider<List<ShippingAddress>>((
  ref,
) async {
  final repo = ref.watch(marketplaceRepositoryProvider);
  final result = await repo.getAddresses();
  return result.cast<ShippingAddress>();
});

/// Fetch payment status.
final paymentStatusProvider = FutureProvider.family<PaymentIntent, String>((
  ref,
  paymentId,
) async {
  final repo = ref.watch(marketplaceRepositoryProvider);
  final result = await repo.getPaymentStatus(paymentId);
  return result as PaymentIntent;
});

/// Agrega produtos de TODAS as lojas onde o usuário informado (`userId`) tem
/// parceria/candidatura aprovada — funciona tanto para o PRÓPRIO perfil
/// quanto para o perfil de QUALQUER outro usuário, pois usa o endpoint
/// público `GET /marketplace/affiliate/{userId}/storefront`
/// (ver [StoreShowcaseService.getPublicStorefront]).
///
/// Retorna lista vazia se o usuário não tiver vitrine aprovada (sem erro).
/// Usado para decidir se o ícone/badge de loja aparece no AppBar do perfil
/// e para alimentar a página dedicada `ShopVitrinePage`.
final storefrontProductsProvider = FutureProvider.family<List<Product>, String>(
  (ref, userId) async {
    final repo = ref.watch(marketplaceRepositoryProvider);

    List<dynamic> groups;
    try {
      groups = await repo.getPublicStorefront(userId);
    } catch (_) {
      return const <Product>[];
    }

    final products = <Product>[];
    for (final group in groups) {
      if (group is! Map<String, dynamic>) continue;
      final items = group['products'];
      if (items is! List) continue;
      for (final item in items) {
        if (item is! Map<String, dynamic>) continue;
        try {
          // Backend retorna `StoreProductItem` (id, name, slug, price,
          // image_url, ...) — mapeamos para o mesmo shape esperado por
          // [Product.fromJson], preenchendo `store_id`/`store_name` a
          // partir do grupo pai já que o item individual não os repete.
          products.add(
            Product.fromJson({
              ...item,
              'store_id': group['store_id'],
              'store_name': group['store_name'],
              'store_slug': group['store_slug'],
              // StoreProductItem não tem `quantity` (não é necessário para a
              // vitrine pública) — Product.quantity é required, então damos
              // um valor neutro que não afeta a exibição do ícone/badge.
              'quantity': item['quantity'] ?? 1,
            }),
          );
        } catch (_) {
          // Ignora item malformado isoladamente; não deve quebrar a
          // vitrine inteira por causa de um produto com dado inesperado.
        }
      }
    }
    return products;
  },
);

/// Alias de conveniência para o PRÓPRIO usuário logado — mantido para não
/// forçar call sites a resolver o `userId` manualmente quando já se sabe
/// que é o próprio perfil. Internamente usa o mesmo endpoint público.
final myStorefrontProductsProvider = FutureProvider<List<Product>>((ref) async {
  final authState = ref.watch(authStateProvider);
  final userId = authState.value?.id;
  if (userId == null) return const <Product>[];
  return ref.watch(storefrontProductsProvider(userId).future);
});

/// Fetch store by ID (looks up from store showcase).
/// This allows widget to access store details like free_shipping_threshold.
final storeByIdProvider = FutureProvider.family<Store?, String>((
  ref,
  storeId,
) async {
  try {
    final repo = ref.watch(marketplaceRepositoryProvider);
    final stores = await repo.getStoreShowcase();
    final storeList = stores.cast<Store>();
    final store = storeList.firstWhereOrNull((s) => s.id == storeId);
    return store;
  } catch (_) {
    return null;
  }
});

// ============================================================================
// VIACEP SERVICE PROVIDER
// ============================================================================

/// Provider para ViaCepService (consultar endereço por CEP)
final viaCepServiceProvider = Provider<ViaCepService>((ref) {
  return ViaCepService();
});
