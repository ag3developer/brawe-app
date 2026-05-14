import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/models/failure.dart';
import '../../domain/models/product.dart';
import '../services/product_service.dart';

part 'product_repository.g.dart';

@riverpod
ProductRepository productRepository(Ref ref) {
  return ProductRepository(ref.watch(productServiceProvider));
}

class ProductRepository {
  final ProductService _service;
  ProductRepository(this._service);

  /// Retorna os produtos de um usuário/vendedor.
  /// Retorna [] se o usuário não for vendedor (404) ou API vazia.
  Future<List<Product>> getUserProducts(String userId,
      {int limit = 20, int offset = 0}) async {
    try {
      final data = await _service.getUserProducts(userId, limit: limit, offset: offset);
      final List<dynamic> list = data['products'] as List<dynamic>? ?? [];
      return list
          .map((e) => (e as Map<String, dynamic>).toProduct())
          .toList();
    } on DioException catch (e) {
      // 404 = usuário não tem loja — não é erro
      if (e.response?.statusCode == 404) return [];
      throw const Failure.network();
    } catch (_) {
      throw const Failure.unknown();
    }
  }
}
