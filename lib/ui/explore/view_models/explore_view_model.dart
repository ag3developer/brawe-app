import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../data/repositories/explore_repository.dart';
import '../../../domain/models/explore_models.dart';
part 'explore_view_model.g.dart';

@riverpod
Future<TrendingData> trendingExplore(Ref ref) async {
  return ref.watch(exploreRepositoryProvider).getTrending();
}

@riverpod
Future<TrendingData> recommendedExplore(Ref ref) async {
  return ref.watch(exploreRepositoryProvider).getRecommended();
}

@riverpod
Future<List<ExploreCategory>> exploreCategories(Ref ref) async {
  return ref.watch(exploreRepositoryProvider).getCategories();
}

/// Estado da busca: query + resultados.
@riverpod
class SearchController extends _$SearchController {
  @override
  AsyncValue<List<SearchResult>> build() {
    return const AsyncValue.data([]);
  }

  String _lastQuery = '';

  Future<void> search(String q) async {
    _lastQuery = q.trim();
    if (_lastQuery.isEmpty) {
      state = const AsyncValue.data([]);
      return;
    }
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(exploreRepositoryProvider).search(_lastQuery),
    );
  }

  void clear() {
    _lastQuery = '';
    state = const AsyncValue.data([]);
  }
}
