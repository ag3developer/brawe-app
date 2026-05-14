// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'explore_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(trendingExplore)
final trendingExploreProvider = TrendingExploreProvider._();

final class TrendingExploreProvider
    extends
        $FunctionalProvider<
          AsyncValue<TrendingData>,
          TrendingData,
          FutureOr<TrendingData>
        >
    with $FutureModifier<TrendingData>, $FutureProvider<TrendingData> {
  TrendingExploreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'trendingExploreProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$trendingExploreHash();

  @$internal
  @override
  $FutureProviderElement<TrendingData> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<TrendingData> create(Ref ref) {
    return trendingExplore(ref);
  }
}

String _$trendingExploreHash() => r'e6b50eaffcdf1d750fd628b60f993ca7f0ae5e0b';

@ProviderFor(recommendedExplore)
final recommendedExploreProvider = RecommendedExploreProvider._();

final class RecommendedExploreProvider
    extends
        $FunctionalProvider<
          AsyncValue<TrendingData>,
          TrendingData,
          FutureOr<TrendingData>
        >
    with $FutureModifier<TrendingData>, $FutureProvider<TrendingData> {
  RecommendedExploreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recommendedExploreProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recommendedExploreHash();

  @$internal
  @override
  $FutureProviderElement<TrendingData> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<TrendingData> create(Ref ref) {
    return recommendedExplore(ref);
  }
}

String _$recommendedExploreHash() =>
    r'76ecb0c2d458644ad4f1c382a203ba70044db4d6';

@ProviderFor(exploreCategories)
final exploreCategoriesProvider = ExploreCategoriesProvider._();

final class ExploreCategoriesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ExploreCategory>>,
          List<ExploreCategory>,
          FutureOr<List<ExploreCategory>>
        >
    with
        $FutureModifier<List<ExploreCategory>>,
        $FutureProvider<List<ExploreCategory>> {
  ExploreCategoriesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'exploreCategoriesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$exploreCategoriesHash();

  @$internal
  @override
  $FutureProviderElement<List<ExploreCategory>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<ExploreCategory>> create(Ref ref) {
    return exploreCategories(ref);
  }
}

String _$exploreCategoriesHash() => r'ec4fb95b624dfa5e93bf2e6a2d9ff9416e1b9ed9';

/// Estado da busca: query + resultados.

@ProviderFor(SearchController)
final searchControllerProvider = SearchControllerProvider._();

/// Estado da busca: query + resultados.
final class SearchControllerProvider
    extends
        $NotifierProvider<SearchController, AsyncValue<List<SearchResult>>> {
  /// Estado da busca: query + resultados.
  SearchControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'searchControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$searchControllerHash();

  @$internal
  @override
  SearchController create() => SearchController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<List<SearchResult>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<List<SearchResult>>>(
        value,
      ),
    );
  }
}

String _$searchControllerHash() => r'50f717fb9a773e6ac28f0ceeaa175541579136e6';

/// Estado da busca: query + resultados.

abstract class _$SearchController
    extends $Notifier<AsyncValue<List<SearchResult>>> {
  AsyncValue<List<SearchResult>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<List<SearchResult>>,
              AsyncValue<List<SearchResult>>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<SearchResult>>,
                AsyncValue<List<SearchResult>>
              >,
              AsyncValue<List<SearchResult>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
