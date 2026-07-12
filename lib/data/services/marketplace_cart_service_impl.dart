import 'package:dio/dio.dart';
import '../../domain/models/marketplace_models.dart';
import 'marketplace_cart_service.dart';
import 'marketplace_response_utils.dart';

/// Implementation of [MarketplaceCartService].
/// Communicates with Main Backend (/marketplace/cart* endpoints).
///
/// ⭐ CRÍTICO: Handles affiliate commission tracking via:
/// - CartItem.comissao_rate, CartItem.comissao_amount
/// - CartItemRequest.affiliate_ref_code, CartItemRequest.room_id
class MarketplaceCartServiceImpl implements MarketplaceCartService {
  final Dio _dio;

  MarketplaceCartServiceImpl(this._dio);

  @override
  Future<Cart> getCart({String? sessionId}) async {
    try {
      print('[MarketplaceCartService] getCart() called, sessionId=$sessionId');

      final queryParams = <String, dynamic>{};
      if (sessionId != null) queryParams['session_id'] = sessionId;

      final response = await _dio.get(
        '/marketplace/cart',
        queryParameters: queryParams,
      );

      final data = extractMap(response.data);
      return Cart.fromJson(data);
    } on DioException catch (e) {
      print('[MarketplaceCartService] Error in getCart: ${e.message}');
      rethrow;
    }
  }

  @override
  Future<dynamic> addItem(dynamic cartItemRequest, {String? sessionId}) async {
    try {
      print('[MarketplaceCartService] addItem() called');
      if (cartItemRequest is CartItemRequest) {
        print(
          '  affiliateRefCode=${cartItemRequest.affiliateRefCode}, '
          'roomId=${cartItemRequest.roomId}',
        );
      }

      final queryParams = <String, dynamic>{};
      if (sessionId != null) queryParams['session_id'] = sessionId;

      final response = await _dio.post(
        '/marketplace/cart/items',
        data: (cartItemRequest as CartItemRequest).toJson(),
        queryParameters: queryParams,
      );

      // O backend retorna o CARRINHO inteiro (CartResponse), não o item
      // isolado — mesmo formato de GET /marketplace/cart. Fazer
      // CartItem.fromJson aqui falhava com "null as String" porque o JSON
      // do carrinho não tem product_id/store_id no nível raiz.
      final data = extractMap(response.data);
      return Cart.fromJson(data);
    } on DioException catch (e) {
      print('[MarketplaceCartService] Error in addItem: ${e.message}');
      rethrow;
    }
  }

  @override
  Future<dynamic> updateItem(
    String cartItemId,
    dynamic cartItemUpdateRequest,
  ) async {
    try {
      print('[MarketplaceCartService] updateItem($cartItemId) called');

      final response = await _dio.put(
        '/marketplace/cart/items/$cartItemId',
        data: (cartItemUpdateRequest as CartItemUpdateRequest).toJson(),
      );

      // Mesmo caso de addItem: PUT /marketplace/cart/items/{id} retorna o
      // CARRINHO inteiro (CartResponse), não o item isolado.
      final data = extractMap(response.data);
      return Cart.fromJson(data);
    } on DioException catch (e) {
      print('[MarketplaceCartService] Error in updateItem: ${e.message}');
      rethrow;
    }
  }

  @override
  Future<void> removeItem(String cartItemId) async {
    try {
      print('[MarketplaceCartService] removeItem($cartItemId) called');

      await _dio.delete('/marketplace/cart/items/$cartItemId');
    } on DioException catch (e) {
      print('[MarketplaceCartService] Error in removeItem: ${e.message}');
      rethrow;
    }
  }

  @override
  Future<void> clearCart() async {
    try {
      print('[MarketplaceCartService] clearCart() called');

      await _dio.delete('/marketplace/cart');
    } on DioException catch (e) {
      print('[MarketplaceCartService] Error in clearCart: ${e.message}');
      rethrow;
    }
  }
}
