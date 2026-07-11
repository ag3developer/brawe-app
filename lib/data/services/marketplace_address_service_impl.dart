import 'package:dio/dio.dart';
import '../../domain/models/marketplace_models.dart';
import 'marketplace_address_service.dart';
import 'marketplace_response_utils.dart';

/// Implementation of [MarketplaceAddressService].
/// Communicates with Main Backend (/marketplace/shipping-addresses endpoints).
///
/// **MVP NOTE:** This service is optional for Fase 0.
/// Addresses can be collected directly in the checkout form if needed.
class MarketplaceAddressServiceImpl implements MarketplaceAddressService {
  final Dio _dio;

  MarketplaceAddressServiceImpl(this._dio);

  @override
  Future<List<ShippingAddress>> getAddresses() async {
    try {
      print('[MarketplaceAddressService] getAddresses() called');

      final response = await _dio.get('/marketplace/shipping-addresses');

      final data = extractList(response.data);
      return data
          .map((item) => ShippingAddress.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      print('[MarketplaceAddressService] Error in getAddresses: ${e.message}');
      rethrow;
    }
  }

  @override
  Future<dynamic> createAddress(dynamic shippingAddressRequest) async {
    try {
      print('[MarketplaceAddressService] createAddress() called');

      final response = await _dio.post(
        '/marketplace/shipping-addresses',
        data: (shippingAddressRequest as ShippingAddress).toJson(),
      );

      final data = extractMap(response.data);
      return ShippingAddress.fromJson(data);
    } on DioException catch (e) {
      print('[MarketplaceAddressService] Error in createAddress: ${e.message}');
      rethrow;
    }
  }

  @override
  Future<ShippingAddress> setDefault(String addressId) async {
    try {
      print('[MarketplaceAddressService] setDefault($addressId) called');

      final response = await _dio.put(
        '/marketplace/shipping-addresses/$addressId/default',
      );

      final data = extractMap(response.data);
      return ShippingAddress.fromJson(data);
    } on DioException catch (e) {
      print('[MarketplaceAddressService] Error in setDefault: ${e.message}');
      rethrow;
    }
  }

  @override
  Future<void> deleteAddress(String addressId) async {
    try {
      print('[MarketplaceAddressService] deleteAddress($addressId) called');

      await _dio.delete('/marketplace/shipping-addresses/$addressId');
    } on DioException catch (e) {
      print('[MarketplaceAddressService] Error in deleteAddress: ${e.message}');
      rethrow;
    }
  }
}
