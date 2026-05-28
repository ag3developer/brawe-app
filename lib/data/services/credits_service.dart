import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/network/live_dio_provider.dart';

part 'credits_service.g.dart';

@riverpod
CreditsService creditsService(Ref ref) {
  return CreditsService(ref.watch(liveDioProvider));
}

class CreditsService {
  final Dio _dio;

  CreditsService(this._dio);

  Future<Map<String, dynamic>> getBalance() async {
    final response = await _dio.get('/credits/balance');
    return response.data['data'] ?? response.data;
  }

  Future<Map<String, dynamic>> getTransactions({int page = 1, int limit = 20}) async {
    final response = await _dio.get(
      '/credits/transactions',
      queryParameters: {'page': page, 'limit': limit},
    );
    return response.data['data'] ?? response.data;
  }

  /// Lista de pessoas agrupadas (gifters/destinatários) com totais e top
  /// gifts — usado na nova tela social de extrato (estilo TikTok).
  /// `direction` = 'received' (quem me presenteou) | 'sent' (quem presenteei).
  Future<Map<String, dynamic>> getGifters({
    String direction = 'received',
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _dio.get(
      '/credits/gifters',
      queryParameters: {
        'direction': direction,
        'page': page,
        'limit': limit,
      },
    );
    return response.data['data'] ?? response.data;
  }

  /// Breakdown completo de uma pessoa específica: header + lista de gifts
  /// acumulados.
  Future<Map<String, dynamic>> getGifterDetails({
    required String otherUserId,
    String direction = 'received',
  }) async {
    final response = await _dio.get(
      '/credits/gifters/$otherUserId',
      queryParameters: {'direction': direction},
    );
    return response.data['data'] ?? response.data;
  }

  /// Saldo consolidado convertido para a moeda de exibição (USD/BRL/EUR).
  Future<Map<String, dynamic>> getEarnings({String currency = 'USD'}) async {
    final response = await _dio.get(
      '/credits/earnings',
      queryParameters: {'currency': currency},
    );
    return response.data['data'] ?? response.data;
  }

  /// Histórico de pedidos de compra de coins (Wolknow + IAP).
  Future<Map<String, dynamic>> getPurchaseOrders({
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _dio.get(
      '/credits/purchase-orders',
      queryParameters: {'page': page, 'limit': limit},
    );
    return response.data['data'] ?? response.data;
  }

  /// Envia um recibo de IAP (Google Play / App Store) ao backend para
  /// validação e crédito das coins na conta do usuário.
  ///
  /// [platform] = "android" | "ios"
  /// [productId] = ID do produto na loja (ex: "brawe_coins_2083")
  /// [purchaseId] = ID único da transação (Google: orderId; iOS: transactionId)
  /// [verificationData] = Android: purchase token; iOS: base64 receipt
  Future<Map<String, dynamic>> verifyIapPurchase({
    required String platform,
    required String productId,
    required String purchaseId,
    required String verificationData,
  }) async {
    final response = await _dio.post(
      '/credits/iap/verify',
      data: {
        'platform': platform,
        'product_id': productId,
        'purchase_id': purchaseId,
        'verification_data': verificationData,
      },
    );
    return response.data['data'] ?? response.data;
  }
}
