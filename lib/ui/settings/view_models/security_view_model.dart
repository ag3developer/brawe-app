import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/services/security_service.dart';
import '../../../domain/models/account_security.dart';

/// Aparelhos conectados (`GET /auth/sessions`).
final sessionsProvider = FutureProvider.autoDispose<SessionsData>(
  (ref) => ref.watch(securityServiceProvider).sessions(),
);

/// Histórico de acessos paginado.
class SecurityEventsState {
  const SecurityEventsState({
    this.items = const [],
    this.total = 0,
    this.page = 0,
    this.pageSize = 20,
    this.geoAttribution,
    this.loadingMore = false,
    this.loadMoreFailed = false,
  });

  final List<SecurityEvent> items;
  final int total;
  final int page;
  final int pageSize;
  final String? geoAttribution;
  final bool loadingMore;
  final bool loadMoreFailed;

  bool get hasMore => items.length < total;

  SecurityEventsState copyWith({
    List<SecurityEvent>? items,
    int? total,
    int? page,
    bool? loadingMore,
    bool? loadMoreFailed,
  }) => SecurityEventsState(
    items: items ?? this.items,
    total: total ?? this.total,
    page: page ?? this.page,
    pageSize: pageSize,
    geoAttribution: geoAttribution,
    loadingMore: loadingMore ?? this.loadingMore,
    loadMoreFailed: loadMoreFailed ?? this.loadMoreFailed,
  );
}

class SecurityEventsNotifier extends AsyncNotifier<SecurityEventsState> {
  @override
  Future<SecurityEventsState> build() async {
    final p = await ref.read(securityServiceProvider).events(page: 1);
    return SecurityEventsState(
      items: p.items,
      total: p.total,
      page: p.page,
      pageSize: p.pageSize,
      geoAttribution: p.geoAttribution,
    );
  }

  Future<void> loadMore() async {
    final cur = state.value;
    if (cur == null || cur.loadingMore || !cur.hasMore) return;
    state = AsyncData(cur.copyWith(loadingMore: true, loadMoreFailed: false));
    try {
      final p = await ref
          .read(securityServiceProvider)
          .events(page: cur.page + 1, pageSize: cur.pageSize);
      state = AsyncData(
        cur.copyWith(
          items: [...cur.items, ...p.items],
          total: p.total,
          page: p.page,
          loadingMore: false,
        ),
      );
    } catch (_) {
      state = AsyncData(cur.copyWith(loadingMore: false, loadMoreFailed: true));
    }
  }
}

final securityEventsProvider =
    AsyncNotifierProvider.autoDispose<
      SecurityEventsNotifier,
      SecurityEventsState
    >(SecurityEventsNotifier.new);
