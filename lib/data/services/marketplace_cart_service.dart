/// Abstract interface for Marketplace Cart Service.
/// Manages shopping cart operations (CRUD items, get cart, clear).
/// Supports both authenticated users and anonymous sessions.
///
/// Uses [dioProvider] (main backend) for all endpoints under /marketplace/cart*

abstract class MarketplaceCartService {
  /// Fetch current cart for user or session.
  ///
  /// GET /marketplace/cart
  ///
  /// - `sessionId`: Optional session ID for anonymous visitors
  ///   If not provided, uses authenticated user's cart.
  ///
  /// Returns [Cart] object containing all items with prices calculated.
  /// Throws [AppException] if cart not found.
  ///
  /// **NOTE:** Cart may be empty (items = []) but cart ID always returned.
  Future<dynamic> getCart({String? sessionId});

  /// Add item to cart.
  ///
  /// POST /marketplace/cart/items
  ///
  /// Request body: [CartItemRequest]
  /// - `product_id`: UUID of product (required)
  /// - `quantity`: Qty ≥ 1 (required)
  /// - `affiliate_ref_code`: Optional referral code of affiliate
  /// - `room_id`: Optional room ID if purchase is from live stream
  ///
  /// Returns [CartItem] with:
  /// - Calculated prices (unit_price, total_price)
  /// - ⭐ CRÍTICO: comissao_rate, comissao_amount if affiliate_ref_code provided
  /// - Store and product details
  ///
  /// Throws [AppException] if product not found, out of stock, or store not approved.
  Future<dynamic> addItem(dynamic cartItemRequest, {String? sessionId});

  /// Update item quantity in cart.
  ///
  /// PUT /marketplace/cart/items/{cartItemId}
  ///
  /// Request body: [CartItemUpdateRequest]
  /// - `quantity`: New quantity (≥ 1)
  ///
  /// Returns updated [CartItem] with recalculated prices.
  /// If quantity = 0, equivalent to DELETE (item removed).
  ///
  /// Throws [AppException] if item not found or insufficient stock.
  Future<dynamic> updateItem(String cartItemId, dynamic cartItemUpdateRequest);

  /// Remove item from cart.
  ///
  /// DELETE /marketplace/cart/items/{cartItemId}
  ///
  /// Throws [AppException] if item not found.
  /// Response: empty or { "success": true }
  Future<void> removeItem(String cartItemId);

  /// Clear all items from cart.
  ///
  /// DELETE /marketplace/cart
  ///
  /// Removes all items but keeps cart object (for session tracking).
  /// Throws [AppException] if cart not found.
  /// Response: empty or { "success": true }
  Future<void> clearCart();
}
