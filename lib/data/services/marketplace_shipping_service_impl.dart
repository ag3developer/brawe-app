import 'package:dio/dio.dart';
import 'marketplace_shipping_service.dart';
import 'marketplace_response_utils.dart';

/// Implementation of [MarketplaceShippingService].
/// Communicates with Main Backend (/shipping* endpoints).
class MarketplaceShippingServiceImpl implements MarketplaceShippingService {
  final Dio _dio;

  MarketplaceShippingServiceImpl(this._dio);

  @override
  Future<dynamic> calculateShipping(String storeId, String postalCode) async {
    try {
      print('[MarketplaceShippingService] calculateShipping() called');
      print('  storeId=$storeId, postalCode=$postalCode');

      final response = await _dio.post(
        '/shipping/calculate',
        data: {
          'store_id': storeId,
          'postal_code': postalCode,
        },
      );

      final data = extractMap(response.data);
      print('[MarketplaceShippingService] Shipping calculated successfully');
      return data;
    } on DioException catch (e) {
      print('[MarketplaceShippingService] Error in calculateShipping: ${e.message}');
      rethrow;
    }
  }

  @override
  Future<dynamic> getShippingEstimate(String storeId, String postalCode) async {
    try {
      print('[MarketplaceShippingService] getShippingEstimate() called');
      print('  storeId=$storeId, postalCode=$postalCode');

      final response = await _dio.get(
        '/shipping/estimate/$storeId',
        queryParameters: {'postal_code': postalCode},
      );

      final data = extractMap(response.data);
      print('[MarketplaceShippingService] Shipping estimate retrieved');
      return data;
    } on DioException catch (e) {
      print('[MarketplaceShippingService] Error in getShippingEstimate: ${e.message}');
      rethrow;
    }
  }
}
