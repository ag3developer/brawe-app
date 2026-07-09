// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'creator_analytics_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// KPIs do Dashboard — carregados uma vez ao abrir a tela.

@ProviderFor(creatorDashboardKpis)
final creatorDashboardKpisProvider = CreatorDashboardKpisProvider._();

/// KPIs do Dashboard — carregados uma vez ao abrir a tela.

final class CreatorDashboardKpisProvider
    extends
        $FunctionalProvider<
          AsyncValue<CreatorDashboardKpis>,
          CreatorDashboardKpis,
          FutureOr<CreatorDashboardKpis>
        >
    with
        $FutureModifier<CreatorDashboardKpis>,
        $FutureProvider<CreatorDashboardKpis> {
  /// KPIs do Dashboard — carregados uma vez ao abrir a tela.
  CreatorDashboardKpisProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'creatorDashboardKpisProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$creatorDashboardKpisHash();

  @$internal
  @override
  $FutureProviderElement<CreatorDashboardKpis> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<CreatorDashboardKpis> create(Ref ref) {
    return creatorDashboardKpis(ref);
  }
}

String _$creatorDashboardKpisHash() =>
    r'3bdde554ab931cb9a79a6931aa04ca3716a4c2cb';

/// Seguidores totais via social stats (para o card de Crescimento).

@ProviderFor(creatorSocialStats)
final creatorSocialStatsProvider = CreatorSocialStatsProvider._();

/// Seguidores totais via social stats (para o card de Crescimento).

final class CreatorSocialStatsProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<String, dynamic>>,
          Map<String, dynamic>,
          FutureOr<Map<String, dynamic>>
        >
    with
        $FutureModifier<Map<String, dynamic>>,
        $FutureProvider<Map<String, dynamic>> {
  /// Seguidores totais via social stats (para o card de Crescimento).
  CreatorSocialStatsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'creatorSocialStatsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$creatorSocialStatsHash();

  @$internal
  @override
  $FutureProviderElement<Map<String, dynamic>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Map<String, dynamic>> create(Ref ref) {
    return creatorSocialStats(ref);
  }
}

String _$creatorSocialStatsHash() =>
    r'3a84dc030fe48d56075584f0b2ae61bccde1309f';

/// Série histórica de viewers por período.

@ProviderFor(viewersHistory)
final viewersHistoryProvider = ViewersHistoryFamily._();

/// Série histórica de viewers por período.

final class ViewersHistoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<AnalyticsDataPoint>>,
          List<AnalyticsDataPoint>,
          FutureOr<List<AnalyticsDataPoint>>
        >
    with
        $FutureModifier<List<AnalyticsDataPoint>>,
        $FutureProvider<List<AnalyticsDataPoint>> {
  /// Série histórica de viewers por período.
  ViewersHistoryProvider._({
    required ViewersHistoryFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'viewersHistoryProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$viewersHistoryHash();

  @override
  String toString() {
    return r'viewersHistoryProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<AnalyticsDataPoint>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<AnalyticsDataPoint>> create(Ref ref) {
    final argument = this.argument as String;
    return viewersHistory(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ViewersHistoryProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$viewersHistoryHash() => r'676fbe28d4d2e4d2415f1a2455ee540fba66a067';

/// Série histórica de viewers por período.

final class ViewersHistoryFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<AnalyticsDataPoint>>, String> {
  ViewersHistoryFamily._()
    : super(
        retry: null,
        name: r'viewersHistoryProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Série histórica de viewers por período.

  ViewersHistoryProvider call(String period) =>
      ViewersHistoryProvider._(argument: period, from: this);

  @override
  String toString() => r'viewersHistoryProvider';
}

/// Histórico de lives paginado.

@ProviderFor(liveHistoryPage)
final liveHistoryPageProvider = LiveHistoryPageFamily._();

/// Histórico de lives paginado.

final class LiveHistoryPageProvider
    extends
        $FunctionalProvider<
          AsyncValue<({List<LiveHistoryItem> items, int total})>,
          ({List<LiveHistoryItem> items, int total}),
          FutureOr<({List<LiveHistoryItem> items, int total})>
        >
    with
        $FutureModifier<({List<LiveHistoryItem> items, int total})>,
        $FutureProvider<({List<LiveHistoryItem> items, int total})> {
  /// Histórico de lives paginado.
  LiveHistoryPageProvider._({
    required LiveHistoryPageFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'liveHistoryPageProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$liveHistoryPageHash();

  @override
  String toString() {
    return r'liveHistoryPageProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<({List<LiveHistoryItem> items, int total})>
  $createElement($ProviderPointer pointer) => $FutureProviderElement(pointer);

  @override
  FutureOr<({List<LiveHistoryItem> items, int total})> create(Ref ref) {
    final argument = this.argument as int;
    return liveHistoryPage(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is LiveHistoryPageProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$liveHistoryPageHash() => r'9828616b53219708a8efb311136b4a93dea65ca8';

/// Histórico de lives paginado.

final class LiveHistoryPageFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<({List<LiveHistoryItem> items, int total})>,
          int
        > {
  LiveHistoryPageFamily._()
    : super(
        retry: null,
        name: r'liveHistoryPageProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Histórico de lives paginado.

  LiveHistoryPageProvider call(int page) =>
      LiveHistoryPageProvider._(argument: page, from: this);

  @override
  String toString() => r'liveHistoryPageProvider';
}

/// Período selecionado para os gráficos (estado local da UI).

@ProviderFor(AnalyticsPeriod)
final analyticsPeriodProvider = AnalyticsPeriodProvider._();

/// Período selecionado para os gráficos (estado local da UI).
final class AnalyticsPeriodProvider
    extends $NotifierProvider<AnalyticsPeriod, String> {
  /// Período selecionado para os gráficos (estado local da UI).
  AnalyticsPeriodProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'analyticsPeriodProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$analyticsPeriodHash();

  @$internal
  @override
  AnalyticsPeriod create() => AnalyticsPeriod();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$analyticsPeriodHash() => r'03acc361d2f932958370504bdf2fcfcf32d29664';

/// Período selecionado para os gráficos (estado local da UI).

abstract class _$AnalyticsPeriod extends $Notifier<String> {
  String build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<String, String>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String, String>,
              String,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
