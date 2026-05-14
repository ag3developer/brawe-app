import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../data/repositories/stories_repository.dart';
import '../../../domain/models/story.dart';

part 'stories_view_model.g.dart';

@riverpod
class StoriesViewModel extends _$StoriesViewModel {
  @override
  FutureOr<List<UserStoriesGroup>> build() async {
    return ref.watch(storiesRepositoryProvider).getFeed();
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
      final newStories =
          g.stories.map((s) => s.id == storyId ? s.copyWith(isSeen: true) : s).toList();
      final stillUnviewed = newStories.any((s) => !s.isSeen);
      return UserStoriesGroup(
        userId: g.userId,
        displayName: g.displayName,
        username: g.username,
        avatarUrl: g.avatarUrl,
        isVerified: g.isVerified,
        hasUnviewed: stillUnviewed,
        stories: newStories,
      );
    }).toList();
    state = AsyncData(updated);

    // Fire-and-forget no servidor
    await ref.read(storiesRepositoryProvider).markAsViewed(storyId);
  }

  /// Cria um novo story (upload multipart) e recarrega o feed.
  /// O backend deduz o tipo (photo/video) pelo MIME — não precisa enviar mediaType.
  Future<void> createStory({
    required String localFilePath,
    String? mediaType, // mantido para compat; ignorado
    String? caption,
  }) async {
    await ref.read(storiesRepositoryProvider).createStory(
          localFilePath: localFilePath,
          caption: caption,
        );
    // Recarrega o feed para mostrar o novo story imediatamente.
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(storiesRepositoryProvider).getFeed(),
    );
  }
}
