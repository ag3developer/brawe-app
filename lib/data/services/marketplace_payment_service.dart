/// Marketplace Payment Service Interface
///
/// Abstração para serviços de pagamento (PIX, Cartão, Crypto).
/// Implementa padrão de integração com Wolknow gateway.

abstract class MarketplacePaymentService {
  /// Inicia um pagamento para um pedido marketplace.
  ///
  /// Args:
  ///   - orderId: ID do pedido marketplace
  ///   - paymentMethod: Método de pagamento ('pix', 'btc', 'eth', 'usdt_trc20')
  ///
  /// Returns:
  ///   {
  ///     "order_id": "abc123",
  ///     "order_number": "BRW20260712001",
  ///     "status": "pending",
  ///     "payment_status": "awaiting_payment",
  ///     "total": 250.00,
  ///     "currency": "BRL",
  ///     "method": "pix",
  ///     "pix_qr_code": "<base64>",
  ///     "pix_copy_paste": "00020126...",
  ///     "payment_url": "https://...",
  ///     "expires_at": "2026-07-12T21:30:00Z",
  ///     "wolknow_payment_id": "pay_abc123"
  ///   }
  Future<Map<String, dynamic>> initiatePayment(
    String orderId,
    String paymentMethod,
  );

  /// Verifica o status de pagamento de um pedido.
  ///
  /// Returns:
  ///   {
  ///     "order_id": "abc123",
  ///     "payment_status": "pending|paid|failed|expired",
  ///     "total": 250.00,
  ///     "method": "pix",
  ///     "paid_at": "2026-07-12T21:15:30Z" (se paid)
  ///   }
  Future<Map<String, dynamic>> checkPaymentStatus(String orderId);
}
