import 'package:dio/dio.dart';

import 'marketplace_payment_service.dart';

/// Implementação do Payment Service usando Dio
/// Integrada com backend Brawe + Wolknow gateway
class MarketplacePaymentServiceImpl implements MarketplacePaymentService {
  final Dio dio;

  MarketplacePaymentServiceImpl(this.dio);

  @override
  Future<Map<String, dynamic>> initiatePayment(
    String orderId,
    String paymentMethod,
  ) async {
    try {
      final response = await dio.post(
        '/api/v1/marketplace/orders/$orderId/initiate-payment',
        queryParameters: {'payment_method': paymentMethod},
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception(
          'Failed to initiate payment: ${response.statusCode} - ${response.data}',
        );
      }
    } on DioException catch (e) {
      throw Exception('Payment initiation error: ${e.message}');
    }
  }

  @override
  Future<Map<String, dynamic>> checkPaymentStatus(String orderId) async {
    try {
      final response = await dio.get('/api/v1/marketplace/orders/$orderId');

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;

        // Extrair campos relevantes de pagamento
        return {
          'order_id': data['id'],
          'payment_status': data['payment_status'],
          'total': data['total'],
          'method': data['payment_method'],
          'paid_at': data['paid_at'],
          'status': data['status'],
        };
      } else {
        throw Exception(
          'Failed to check payment status: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw Exception('Payment status check error: ${e.message}');
    }
  }
}
