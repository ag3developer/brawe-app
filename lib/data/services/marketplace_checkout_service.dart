/// Abstract interface for Marketplace Checkout Service.
/// Handles order creation (Main Backend) and payment processing (Connect Backend).
/// This is the **MAIN TRANSACTION FLOW** for Fase 0.
///
/// Uses [dioProvider] (main backend) for /marketplace/orders
/// Uses [liveDioProvider] (connect backend) for /shopping/payments

abstract class MarketplaceCheckoutService {
  /// Create and submit an order from cart.
  ///
  /// POST /marketplace/orders (MAIN BACKEND)
  ///
  /// Request body: [CheckoutRequest]
  /// - `shipping_address`: Full address (required)
  /// - `billing_address`: Optional (defaults to shipping)
  /// - `customer_name`, `customer_email`, `customer_phone`: Required
  /// - `customer_document`: Optional (CPF/CNPJ)
  /// - `shipping_method`: e.g., "standard", "express"
  /// - `payment_method`: e.g., "pix", "credit_card"
  /// - `coupon_code`: Optional discount code
  /// - `session_id`: For anonymous cart (if not authenticated)
  /// - ⭐ CRÍTICO: `affiliate_id`: UUID of affiliate who referred this user
  ///
  /// Returns [Order] with:
  /// - order.id, order.number
  /// - All items with calculated prices
  /// - ⭐ CRÍTICO: order.affiliate_id and order.affiliate_commission_amount
  /// - status = "pending" (awaiting payment)
  /// - payment_status = "pending"
  ///
  /// Throws [AppException] if:
  /// - Cart is empty
  /// - Product out of stock
  /// - Store not approved/unavailable
  /// - Invalid address or customer data
  /// - Affiliate ID invalid (if provided)
  ///
  /// **POSTCONDITION:** Order created but NOT charged yet.
  /// Next step: use [createPayment] to initiate payment.
  Future<dynamic> checkout(dynamic checkoutRequest, {String? affiliateId});

  /// Create payment intent for an order.
  ///
  /// POST /shopping/payments/create (CONNECT BACKEND)
  ///
  /// Request body: [PaymentRequest]
  /// - `order_id`: UUID of order created by [checkout]
  /// - `amount`: Total order amount (in cents or smallest unit)
  /// - `method`: "pix" | "card" | "crypto" (btc, eth, usdt_*)
  /// - `metadata`: Optional (billing cycle, product details, etc.)
  ///
  /// Returns [PaymentIntent] with:
  /// - payment.id (transaction ID)
  /// - payment.status = "pending"
  /// - payment_url or QR code (depending on method)
  /// - webhook configuration for status updates
  ///
  /// Throws [AppException] if:
  /// - Order not found or already paid
  /// - Invalid payment method
  /// - Amount mismatch
  ///
  /// **FLOW:** After payment, webhook updates order.payment_status to "paid".
  Future<dynamic> createPayment(dynamic paymentRequest);

  /// Check payment status and sync with order.
  ///
  /// GET /shopping/payments/{paymentId}/status (CONNECT BACKEND)
  ///
  /// Returns [PaymentStatus]:
  /// - status: "pending" | "awaiting_payment" | "paid" | "failed" | "refunded"
  /// - error: Optional error message if failed
  ///
  /// Can be used to poll for payment completion if webhooks unavailable.
  /// Typically not needed; webhooks handle status updates automatically.
  Future<dynamic> getPaymentStatus(String paymentId);
}
