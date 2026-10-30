import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../data/repositories/stories_repository.dart';
import '../../../domain/models/story.dart';

part 'stories_view_model.g.dart';

@riverpod
class StoriesViewModel extends _$StoriesViewModel {
  Timer? _refreshTimer;

  @override
  FutureOr<List<UserStoriesGroup>> build() async {
    // Auto-refresh a cada 30s — remove o anel "ao vivo" do avatar
    // quando o streamer encerra a live, sem precisar de ação do usuário.
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _silentRefresh();
    });
    ref.onDispose(() => _refreshTimer?.cancel());
    return ref.watch(storiesRepositoryProvider).getFeed();
  }

  Future<void> _silentRefresh() async {
    final result = await AsyncValue.guard(
      () => ref.read(storiesRepositoryProvider).getFeed(),
    );
    if (result.hasValue) state = result;
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(storiesRepositoryProvider).getFeed(),
    );
  }

  /// Marca story como visto otimisticamente + atualiza no servidor.
  Future<void> markAsViewed(String storyId) async {
    final groups = state.value;
    if (groups == null) return;

    // Atualização otimista local
    final updated = groups.map((g) {
      final hasThis = g.stories.any((s) => s.id == storyId);
      if (!hasThis) return g;
      final newStories = g.stories
          .map((s) => s.id == storyId ? s.copyWith(isSeen: true) : s)
          .toList();
      final stillUnviewed = newStories.any((s) => !s.isSeen);
      return UserStoriesGroup(
        userId: g.userId,
        displayName: g.displayName,
        username: g.username,
        avatarUrl: g.avatarUrl,
        isVerified: g.isVerified,
        hasUnviewed: stillUnviewed,
        isLive: g.isLive,
        liveRoomId: g.liveRoomId,
        stories: newStories,
      );
    }).toList();
    state = AsyncData(updated);

    // Fire-and-forget no servidor
    await ref.read(storiesRepositoryProvider).markAsViewed(storyId);
  }

  /// Exclui um story (próprio) e recarrega o feed.
  Future<void> deleteStory(String storyId) async {
    await ref.read(storiesRepositoryProvider).deleteStory(storyId);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(storiesRepositoryProvider).getFeed(),
    );
  }

  /// Cria um novo story (upload multipart) e recarrega o feed.
  /// O backend deduz o tipo (photo/video) pelo MIME — não precisa enviar mediaType.
  ///
  /// [idempotencyKey] (opcional): UUID compartilhado entre todos os
  /// retries do mesmo upload. Se chegar 2 requests com a mesma key, o
  /// backend devolve o registro existente em vez de criar duplicata.
  /// Ver `_StoryComposerScreenState._idempotencyKey`.
  Future<void> createStory({
    required String localFilePath,
    String? mediaType, // mantido para compat; ignorado
    String? caption,
    int? durationSeconds,
    String? originPostId,
    String? idempotencyKey,
    String? soundId,
    int soundTrimStartMs = 0,
    int? soundTrimEndMs,
    double soundVolume = 1.0,
    double originalAudioVolume = 1.0,
    String? overlayPath,
  }) async {
    await ref
        .read(storiesRepositoryProvider)
        .createStory(
          localFilePath: localFilePath,
          caption: caption,
          durationSeconds: durationSeconds,
          originPostId: originPostId,
          idempotencyKey: idempotencyKey,
          soundId: soundId,
          soundTrimStartMs: soundTrimStartMs,
          soundTrimEndMs: soundTrimEndMs,
          soundVolume: soundVolume,
          originalAudioVolume: originalAudioVolume,
          overlayPath: overlayPath,
        );
    // Recarrega o feed para mostrar o novo story imediatamente.
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(storiesRepositoryProvider).getFeed(),
    );
  }
}
