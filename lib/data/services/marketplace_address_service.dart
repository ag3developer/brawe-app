/// Abstract interface for Marketplace Address Service.
/// Manages user's saved shipping addresses for faster checkout.
/// **MVP NOTE:** Can be skipped in Fase 0 — addresses can be entered directly in checkout form.
///
/// Uses [dioProvider] (main backend) for all endpoints under /marketplace/shipping-addresses

abstract class MarketplaceAddressService {
  /// Fetch all saved shipping addresses for current user.
  ///
  /// GET /marketplace/shipping-addresses
  ///
  /// Returns list of [ShippingAddress] objects with metadata:
  /// - id (UUID)
  /// - is_default (bool)
  /// - created_at
  /// - label (e.g., "Home", "Work")
  ///
  /// Throws [AppException] if user not authenticated.
  Future<List<dynamic>> getAddresses();

  /// Create a new shipping address.
  ///
  /// POST /marketplace/shipping-addresses
  ///
  /// Request body: [ShippingAddress]
  /// - All fields required except: complement, lat, lng
  ///
  /// Returns [ShippingAddress] with assigned UUID and timestamps.
  /// First address is automatically set as default.
  ///
  /// Throws [AppException] if invalid address or duplicate found.
  Future<dynamic> createAddress(dynamic shippingAddressRequest);

  /// Set an address as default for future checkouts.
  ///
  /// PUT /marketplace/shipping-addresses/{addressId}/default
  ///
  /// Returns updated [ShippingAddress] with is_default = true.
  /// All other addresses for this user are set to is_default = false.
  ///
  /// Throws [AppException] if address not found or not owned by user.
  Future<dynamic> setDefault(String addressId);

  /// Delete a saved address.
  ///
  /// DELETE /marketplace/shipping-addresses/{addressId}
  ///
  /// Throws [AppException] if:
  /// - Address not found
  /// - Is the only address (must keep at least one)
  /// - Is currently default (must set another as default first)
  Future<void> deleteAddress(String addressId);
}
