import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/repositories/for_you_feed_repository.dart';
import '../../../domain/models/feed_item.dart';

part 'for_you_feed_view_model.g.dart';

@riverpod
class ForYouFeedViewModel extends _$ForYouFeedViewModel {
  Timer? _refreshTimer;

  @override
  FutureOr<List<FeedItem>> build() async {
    // Auto-refresh a cada 30s — lives encerradas saem do feed automaticamente
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      refresh(silent: true);
    });
    ref.onDispose(() => _refreshTimer?.cancel());
    return ref.watch(forYouFeedRepositoryProvider).getFeed();
  }

  Future<void> refresh({bool silent = false}) async {
    if (!silent) state = const AsyncValue.loading();
    final result = await AsyncValue.guard(
      () => ref.read(forYouFeedRepositoryProvider).getFeed(),
    );
    // Em refresh silencioso só atualiza se houve mudança — evita flicker
    if (!silent || result.hasValue) state = result;
  }
}

@riverpod
class FollowingForYouFeedViewModel extends _$FollowingForYouFeedViewModel {
  Timer? _refreshTimer;

  @override
  FutureOr<List<FeedItem>> build() async {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      refresh(silent: true);
    });
    ref.onDispose(() => _refreshTimer?.cancel());
    return ref.watch(forYouFeedRepositoryProvider).getFollowingFeed();
  }

  Future<void> refresh({bool silent = false}) async {
    if (!silent) state = const AsyncValue.loading();
    final result = await AsyncValue.guard(
      () => ref.read(forYouFeedRepositoryProvider).getFollowingFeed(),
    );
    if (!silent || result.hasValue) state = result;
  }
}
