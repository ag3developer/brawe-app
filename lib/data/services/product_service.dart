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

  Future<Map<String, dynamic>> getUserProducts(String userId,
      {int limit = 20, int offset = 0}) async {
    final response = await _dio.get(
      '/users/$userId/products',
      queryParameters: {'limit': limit, 'offset': offset},
    );
    return response.data as Map<String, dynamic>;
  }
}

extension ProductDtoMapper on Map<String, dynamic> {
  Product toProduct() {
    return Product(
      id: this['id']?.toString() ?? '',
      name: this['name']?.toString() ?? '',
      imageUrl: this['image_url']?.toString() ?? this['imageUrl']?.toString() ?? '',
      price: (this['price'] as num?)?.toDouble() ?? 0.0,
      originalPrice: (this['original_price'] as num?)?.toDouble() ??
          (this['originalPrice'] as num?)?.toDouble(),
      stock: (this['stock'] as num?)?.toInt() ?? 0,
      soldCount: (this['sold_count'] as num?)?.toInt() ??
          (this['soldCount'] as num?)?.toInt() ??
          0,
      isFeatured: this['is_featured'] as bool? ?? false,
    );
  }
}
