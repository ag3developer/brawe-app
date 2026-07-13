import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/marketplace_repository.dart';
import '../services/marketplace_address_service_provider.dart';
import '../services/marketplace_cart_service_provider.dart';
import '../services/marketplace_checkout_service_provider.dart';
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

/// Agrega produtos de TODAS as lojas onde o usuário logado tem parceria
/// aprovada. Usado na Vitrine do Perfil (aba "Vitrine") quando isMe == true.
/// Retorna lista vazia se não houver parcerias aprovadas (sem erro).
final myStorefrontProductsProvider = FutureProvider<List<Product>>((ref) async {
  final repo = ref.watch(marketplaceRepositoryProvider);

  List<AffiliateApplication> applications;
  try {
    final result = await repo.getMyApplications();
    applications = result.cast<AffiliateApplication>();
  } catch (_) {
    return const <Product>[];
  }

  final approvedStoreIds = applications
      .where((app) => app.status == ApplicationStatus.approved)
      .map((app) => app.storeId)
      .toSet()
      .toList();

  if (approvedStoreIds.isEmpty) return const <Product>[];

  // Buscar produtos de todas as lojas aprovadas em paralelo.
  final futures = approvedStoreIds.map((storeId) async {
    try {
      final products = await repo.getStoreProducts(storeId, page: 1, limit: 50);
      return products.cast<Product>();
    } catch (_) {
      return const <Product>[];
    }
  });

  final results = await Future.wait(futures);
  return results.expand((list) => list).toList();
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
