import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/network/live_dio_provider.dart';
part 'explore_service.g.dart';

@riverpod
ExploreService exploreService(Ref ref) {
  return ExploreService(ref.watch(liveDioProvider));
}

class ExploreService {
  final Dio _dio;
  ExploreService(this._dio);

  /// GET /explore/trending → { lives: [...], streamers: [...] }
  Future<Map<String, dynamic>> getTrending({int limit = 20}) async {
    final r = await _dio.get('/explore/trending',
        queryParameters: {'limit': limit});
    return (r.data['data'] as Map<String, dynamic>?) ?? const {};
  }

  /// GET /explore/search?q=...
  Future<List<Map<String, dynamic>>> search(String q, {int limit = 20}) async {
    final r = await _dio.get('/explore/search',
        queryParameters: {'q': q, 'limit': limit});
    final data = r.data['data'];
    if (data is List) {
      return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }
    return const [];
  }

  /// GET /explore/categories
  Future<List<Map<String, dynamic>>> getCategories() async {
    final r = await _dio.get('/explore/categories');
    final data = r.data['data'];
    if (data is List) {
      return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }
    return const [];
  }

  /// GET /explore/recommended
  /// Mesmo shape do trending quando não há recomendações personalizadas.
  Future<Map<String, dynamic>> getRecommended({int limit = 10}) async {
    final r = await _dio.get('/explore/recommended',
        queryParameters: {'limit': limit});
    final data = r.data['data'];
    if (data is Map) return Map<String, dynamic>.from(data);
    return const {};
  }
}
