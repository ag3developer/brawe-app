import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/network/live_dio_provider.dart';
import '../../domain/models/product.dart';

part 'product_service.g.dart';

@riverpod
ProductService productService(Ref ref) {
  return ProductService(ref.watch(liveDioProvider));
}

class ProductService {
  final Dio _dio;
  ProductService(this._dio);

  /// Fetch products for a user's store (if they're a seller).
  /// Uses the marketplace API to get store products by user ID.
  ///
  /// NOTE: This endpoint assumes the backend has:
  /// GET /marketplace/users/{userId}/products or similar
  /// If this endpoint doesn't exist, remove this method or implement
  /// alternative logic (e.g., get user's store ID first, then fetch products).
  Future<Map<String, dynamic>> getUserProducts(
    String userId, {
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      // Attempt to fetch user's store products from marketplace API
      final response = await _dio.get(
        '/marketplace/users/$userId/products',
        queryParameters: {'limit': limit, 'offset': offset},
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      // Fallback: If endpoint doesn't exist, return empty result
      // In production, this should be properly handled or logged
      print('[ProductService] Error fetching user products: $e');
      return {'items': [], 'total': 0};
    }
  }
}

extension ProductDtoMapper on Map<String, dynamic> {
  Product toProduct() {
    return Product(
      id: this['id']?.toString() ?? '',
      name: this['name']?.toString() ?? '',
      imageUrl:
          this['image_url']?.toString() ?? this['imageUrl']?.toString() ?? '',
      price: (this['price'] as num?)?.toDouble() ?? 0.0,
      originalPrice:
          (this['original_price'] as num?)?.toDouble() ??
          (this['originalPrice'] as num?)?.toDouble(),
      stock: (this['stock'] as num?)?.toInt() ?? 0,
      soldCount:
          (this['sold_count'] as num?)?.toInt() ??
          (this['soldCount'] as num?)?.toInt() ??
          0,
      isFeatured: this['is_featured'] as bool? ?? false,
    );
  }
}
