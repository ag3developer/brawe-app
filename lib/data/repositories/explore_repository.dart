import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/models/explore_models.dart';
import '../../domain/models/failure.dart';
import '../services/explore_service.dart';
part 'explore_repository.g.dart';

@riverpod
ExploreRepository exploreRepository(Ref ref) {
  return ExploreRepository(ref.watch(exploreServiceProvider));
}

class ExploreRepository {
  final ExploreService _service;
  ExploreRepository(this._service);

  Future<TrendingData> getTrending({int limit = 20}) async {
    try {
      final raw = await _service.getTrending(limit: limit);
      return TrendingData.fromJson(raw);
    } on DioException catch (_) {
      throw const Failure.network();
    } catch (_) {
      throw const Failure.unknown();
    }
  }

  Future<TrendingData> getRecommended({int limit = 10}) async {
    try {
      final raw = await _service.getRecommended(limit: limit);
      return TrendingData.fromJson(raw);
    } on DioException catch (_) {
      throw const Failure.network();
    } catch (_) {
      throw const Failure.unknown();
    }
  }

  Future<List<ExploreCategory>> getCategories() async {
    try {
      final raw = await _service.getCategories();
      return raw.map(ExploreCategory.fromJson).toList();
    } on DioException catch (_) {
      throw const Failure.network();
    } catch (_) {
      throw const Failure.unknown();
    }
  }

  Future<List<SearchResult>> search(String q, {int limit = 20}) async {
    if (q.trim().isEmpty) return const [];
    try {
      final raw = await _service.search(q.trim(), limit: limit);
      return raw.map(SearchResult.fromJson).toList();
    } on DioException catch (_) {
      throw const Failure.network();
    } catch (_) {
      throw const Failure.unknown();
    }
  }
}
