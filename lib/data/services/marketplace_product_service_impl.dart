import 'package:dio/dio.dart';
import '../../domain/models/marketplace_models.dart';
import 'marketplace_product_service.dart';
import 'marketplace_response_utils.dart';

/// Implementation of [MarketplaceProductService].
/// Communicates with Main Backend (/marketplace/products* endpoints).
class MarketplaceProductServiceImpl implements MarketplaceProductService {
  final Dio _dio;

  MarketplaceProductServiceImpl(this._dio);

  @override
  Future<List<Product>> getStoreProducts(
    String storeId, {
    int page = 1,
    int limit = 20,
    String? search,
    String? sort,
  }) async {
    try {
      print('[MarketplaceProductService] getStoreProducts($storeId) called');

      // Backend usa `per_page` (não `limit`) e não tem parâmetro `sort`
      // neste endpoint — mantemos `sort` fora por ora (gap conhecido).
      final queryParams = <String, dynamic>{'page': page, 'per_page': limit};

      if (search != null) queryParams['search'] = search;

      final response = await _dio.get(
        '/marketplace/products/store/$storeId',
        queryParameters: queryParams,
      );

      // Backend retorna resposta paginada: {items, total, page, per_page, pages}
      final body = response.data;
      final data = body is Map ? (body['items'] ?? body['data'] ?? body) : body;
      if (data is List) {
        return data
            .map((item) => Product.fromJson(item as Map<String, dynamic>))
            .toList();
      }

      return [];
    } on DioException catch (e) {
      print(
        '[MarketplaceProductService] Error in getStoreProducts: ${e.message}',
      );
      rethrow;
    }
  }

  @override
  Future<Product> getProductDetail(String productId) async {
    try {
      print('[MarketplaceProductService] getProductDetail($productId) called');

      final response = await _dio.get('/marketplace/products/$productId');

      final data = extractMap(response.data);
      return Product.fromJson(data);
    } on DioException catch (e) {
      print(
        '[MarketplaceProductService] Error in getProductDetail: ${e.message}',
      );
      rethrow;
    }
  }

  @override
  Future<List<Product>> searchProducts(
    String query, {
    String? storeId,
    String? category,
    double? minPrice,
    double? maxPrice,
    String? sort,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      print('[MarketplaceProductService] searchProducts($query) called');

      final queryParams = <String, dynamic>{
        'query': query,
        'page': page,
        'limit': limit,
      };

      if (storeId != null) queryParams['store_id'] = storeId;
      if (category != null) queryParams['category'] = category;
      if (minPrice != null) queryParams['min_price'] = minPrice;
      if (maxPrice != null) queryParams['max_price'] = maxPrice;
      if (sort != null) queryParams['sort'] = sort;

      final response = await _dio.get(
        '/marketplace/products/search',
        queryParameters: queryParams,
      );

      final data = extractList(response.data);
      return data
          .map((item) => Product.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      print(
        '[MarketplaceProductService] Error in searchProducts: ${e.message}',
      );
      rethrow;
    }
  }
}
