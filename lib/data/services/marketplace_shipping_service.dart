/// Abstract interface for Marketplace Shipping Service.
/// Manages shipping calculations and estimates for checkout.
///
/// Uses [dioProvider] (main backend) for all endpoints under /shipping*

abstract class MarketplaceShippingService {
  /// Calculate shipping options for a given store and postal code.
  ///
  /// POST /marketplace/shipping/calculate
  ///
  /// - `store_id`: UUID of the store (required)
  /// - `postal_code`: CEP of delivery address (required)
  ///
  /// Returns list of shipping options with prices and delivery estimates.
  /// Throws [AppException] if store not found or shipping unavailable.
  Future<dynamic> calculateShipping(String storeId, String postalCode);

  /// Get quick shipping estimate for a store.
  ///
  /// GET /marketplace/shipping/estimate/{store_id}
  ///
  /// - `store_id`: UUID of the store (required)
  /// - `postal_code`: CEP query param (required)
  ///
  /// Returns default/recommended shipping option.
  /// Throws [AppException] if store not found.
  Future<dynamic> getShippingEstimate(String storeId, String postalCode);
}
