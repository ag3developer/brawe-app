/// Abstract interface for Marketplace Product Service.
/// Provides methods to browse and search products from affiliate stores.
///
/// Uses [dioProvider] (main backend) for all endpoints under /marketplace/*

abstract class MarketplaceProductService {
  /// Fetch products from a specific store with pagination.
  ///
  /// GET /marketplace/products/store/{storeId}
  ///
  /// - `storeId`: UUID of the store
  /// - `page`: Page number (default 1)
  /// - `limit`: Items per page (sent as `per_page`, default 20)
  /// - `search`: Optional search string within this store
  /// - `sort`: Not supported by this backend endpoint yet (ignored)
  ///
  /// Returns paginated list of [Product] objects from that store.
  /// Throws [AppException] if store not found or not approved.
  Future<List<dynamic>> getStoreProducts(
    String storeId, {
    int page = 1,
    int limit = 20,
    String? search,
    String? sort,
  });

  /// Fetch detailed product information.
  ///
  /// GET /marketplace/products/{productId}
  ///
  /// Returns full [Product] object with:
  /// - Description, images, variants
  /// - Stock information
  /// - Store details and affiliate commission
  /// - Ratings and reviews count
  /// - Related products (optional)
  ///
  /// Throws [AppException] if product not found or store not approved.
  Future<dynamic> getProductDetail(String productId);

  /// Search products across all approved stores.
  ///
  /// GET /marketplace/products/search
  ///
  /// Query params:
  /// - `query`: Search string (required, min 2 chars)
  /// - `storeId`: Optional filter by specific store
  /// - `category`: Optional category filter
  /// - `minPrice`: Optional minimum price
  /// - `maxPrice`: Optional maximum price
  /// - `sort`: Sort order (default "relevance")
  /// - `page`: Page number (default 1)
  /// - `limit`: Items per page (default 20)
  ///
  /// Returns list of [Product] objects matching search criteria.
  /// Results are ranked by relevance and store rating.
  Future<List<dynamic>> searchProducts(
    String query, {
    String? storeId,
    String? category,
    double? minPrice,
    double? maxPrice,
    String? sort,
    int page = 1,
    int limit = 20,
  });
}
