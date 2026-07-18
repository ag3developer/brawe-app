import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../domain/models/post.dart';
import '../../../data/repositories/post_repository.dart';

part 'hashtag_view_model.g.dart';

/// Posts que contêm uma #hashtag específica (tela de resultados ao tocar
/// numa hashtag no feed/comentários).
@riverpod
class HashtagPostsViewModel extends _$HashtagPostsViewModel {
  @override
  FutureOr<List<Post>> build(String tag) async {
    final repository = ref.watch(postRepositoryProvider);
    return repository.getByHashtag(tag, limit: 20);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(postRepositoryProvider).getByHashtag(tag, limit: 20),
    );
  }
}
