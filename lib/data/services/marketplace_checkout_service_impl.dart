import 'package:dio/dio.dart';
import '../../domain/models/marketplace_models.dart';
import 'marketplace_checkout_service.dart';
import 'marketplace_response_utils.dart';

/// Implementation of [MarketplaceCheckoutService].
/// Coordinates between:
/// - Main Backend (/marketplace/orders) via [mainDio]
/// - Connect Backend (/shopping/payments) via [connectDio]
///
/// ⭐ CRÍTICO: This service is the **transaction gateway** for Fase 0.
/// Handles affiliate commission tracking end-to-end:
/// 1. [checkout] receives affiliate_id, passes to backend
/// 2. Backend calculates affiliate_commission_amount per item
/// 3. [createPayment] finalizes transaction
/// 4. Order status tracked for commission settlement
class MarketplaceCheckoutServiceImpl implements MarketplaceCheckoutService {
  final Dio _mainDio;
  final Dio _connectDio;

  MarketplaceCheckoutServiceImpl({
    required Dio mainDio,
    required Dio connectDio,
  }) : _mainDio = mainDio,
       _connectDio = connectDio;

  @override
  Future<dynamic> checkout(
    dynamic checkoutRequest, {
    String? affiliateId,
  }) async {
    try {
      print('[MarketplaceCheckoutService] checkout() called');
      print('  affiliateId=$affiliateId');

      final requestBody = (checkoutRequest as CheckoutRequest).toJson();

      // Add affiliate_id if provided
      if (affiliateId != null) {
        requestBody['affiliate_id'] = affiliateId;
      }

      final response = await _mainDio.post(
        '/marketplace/orders',
        data: requestBody,
      );

      final data = extractMap(response.data);
      return Order.fromJson(data);
    } on DioException catch (e) {
      print('[MarketplaceCheckoutService] Error in checkout: ${e.message}');
      rethrow;
    }
  }

  @override
  Future<dynamic> createPayment(dynamic paymentRequest) async {
    try {
      print('[MarketplaceCheckoutService] createPayment() called');
      if (paymentRequest is PaymentRequest) {
        print('  orderId=${paymentRequest.orderId}');
      }

      final response = await _connectDio.post(
        '/shopping/payments/create',
        data: (paymentRequest as PaymentRequest).toJson(),
      );

      final data = extractMap(response.data);
      return PaymentIntent.fromJson(data);
    } on DioException catch (e) {
      print(
        '[MarketplaceCheckoutService] Error in createPayment: ${e.message}',
      );
      rethrow;
    }
  }

  @override
  Future<dynamic> getPaymentStatus(String paymentId) async {
    try {
      print('[MarketplaceCheckoutService] getPaymentStatus($paymentId) called');

      final response = await _connectDio.get(
        '/shopping/payments/$paymentId/status',
      );

      final data = extractMap(response.data);
      return PaymentIntent.fromJson(data);
    } on DioException catch (e) {
      print(
        '[MarketplaceCheckoutService] Error in getPaymentStatus: ${e.message}',
      );
      rethrow;
    }
  }
}
