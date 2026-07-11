import '../services/marketplace_address_service.dart';
import '../services/marketplace_cart_service.dart';
import '../services/marketplace_checkout_service.dart';
import '../services/marketplace_product_service.dart';
import '../services/store_showcase_service.dart';

/// Repository that aggregates all marketplace services.
/// Provides a single entry point for marketplace operations.
///
/// Pattern: Repository aggregates services and exposes business logic.
class MarketplaceRepository {
  final StoreShowcaseService storeShowcaseService;
  final MarketplaceProductService productService;
  final MarketplaceCartService cartService;
  final MarketplaceCheckoutService checkoutService;
  final MarketplaceAddressService addressService;

  MarketplaceRepository({
    required this.storeShowcaseService,
    required this.productService,
    required this.cartService,
    required this.checkoutService,
    required this.addressService,
  });

  // =========================================================================
  // SHOWCASE OPERATIONS
  // =========================================================================

  Future<dynamic> getStoreShowcase({
    int page = 1,
    int perPage = 12,
    String? search,
    String? category,
    double? minCommission,
    String? sortBy,
  }) => storeShowcaseService.getShowcase(
    page: page,
    perPage: perPage,
    search: search,
    category: category,
    minCommission: minCommission,
    sortBy: sortBy,
  );

  Future<dynamic> getStoreBySlug(String slug) =>
      storeShowcaseService.getStore(slug);

  Future<dynamic> applyForPartnership(
    String storeSlug, {
    required String message,
    bool sampleRequested = false,
    List<String> sampleProductIds = const [],
    String? customCommission,
  }) => storeShowcaseService.applyForPartnership(
    storeSlug,
    message: message,
    sampleRequested: sampleRequested,
    sampleProductIds: sampleProductIds,
    customCommission: customCommission,
  );

  Future<List<dynamic>> getMyApplications({String? status}) =>
      storeShowcaseService.getMyApplications(status: status);

  Future<void> deleteApplication(String applicationId) =>
      storeShowcaseService.deleteApplication(applicationId);

  Future<dynamic> reviewApplication(
    String applicationId, {
    required bool approved,
    String? message,
    String? customCommission,
  }) => storeShowcaseService.submitApplicationReview(
    applicationId,
    approved: approved,
    message: message,
    customCommission: customCommission,
  );

  // =========================================================================
  // PRODUCT OPERATIONS
  // =========================================================================

  Future<List<dynamic>> getStoreProducts(
    String storeId, {
    int page = 1,
    int limit = 20,
    String? search,
    String? sort,
  }) => productService.getStoreProducts(
    storeId,
    page: page,
    limit: limit,
    search: search,
    sort: sort,
  );

  Future<dynamic> getProductDetail(String productId) =>
      productService.getProductDetail(productId);

  Future<List<dynamic>> searchProducts(
    String query, {
    String? storeId,
    String? category,
    double? minPrice,
    double? maxPrice,
    String? sort,
    int page = 1,
    int limit = 20,
  }) => productService.searchProducts(
    query,
    storeId: storeId,
    category: category,
    minPrice: minPrice,
    maxPrice: maxPrice,
    sort: sort,
    page: page,
    limit: limit,
  );

  // =========================================================================
  // CART OPERATIONS
  // =========================================================================

  Future<dynamic> getCart({String? sessionId}) =>
      cartService.getCart(sessionId: sessionId);

  Future<dynamic> addToCart(dynamic cartItemRequest, {String? sessionId}) =>
      cartService.addItem(cartItemRequest, sessionId: sessionId);

  Future<dynamic> updateCartItem(
    String cartItemId,
    dynamic cartItemUpdateRequest,
  ) => cartService.updateItem(cartItemId, cartItemUpdateRequest);

  Future<void> removeFromCart(String cartItemId) =>
      cartService.removeItem(cartItemId);

  Future<void> clearCart() => cartService.clearCart();

  // =========================================================================
  // CHECKOUT & PAYMENT OPERATIONS
  // =========================================================================

  Future<dynamic> checkout(dynamic checkoutRequest, {String? affiliateId}) =>
      checkoutService.checkout(checkoutRequest, affiliateId: affiliateId);

  Future<dynamic> createPayment(dynamic paymentRequest) =>
      checkoutService.createPayment(paymentRequest);

  Future<dynamic> getPaymentStatus(String paymentId) =>
      checkoutService.getPaymentStatus(paymentId);

  // =========================================================================
  // ADDRESS OPERATIONS
  // =========================================================================

  Future<List<dynamic>> getAddresses() => addressService.getAddresses();

  Future<dynamic> createAddress(dynamic shippingAddressRequest) =>
      addressService.createAddress(shippingAddressRequest);

  Future<dynamic> setDefaultAddress(String addressId) =>
      addressService.setDefault(addressId);

  Future<void> deleteAddress(String addressId) =>
      addressService.deleteAddress(addressId);
}
