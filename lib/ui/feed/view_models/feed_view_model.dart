import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../domain/models/post.dart';
import '../../../data/repositories/post_repository.dart';

part 'feed_view_model.g.dart';

@riverpod
class FeedViewModel extends _$FeedViewModel {
  @override
  FutureOr<List<Post>> build() async {
    return _fetchFeed();
  }

  Future<List<Post>> _fetchFeed({int offset = 0}) async {
    final repository = ref.watch(postRepositoryProvider);
    return repository.getFeed(limit: 10, offset: offset);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchFeed());
  }

  Future<void> toggleLike(String postId) async {
    final posts = state.value;
    if (posts == null) return;

    final index = posts.indexWhere((p) => p.id == postId);
    if (index == -1) return;

    final post = posts[index];
    final newPost = post.copyWith(
      userLiked: !post.userLiked,
      likesCount: post.userLiked ? post.likesCount - 1 : post.likesCount + 1,
    );

    final newPosts = List<Post>.from(posts);
    newPosts[index] = newPost;
    state = AsyncData(newPosts);

    try {
      await ref.read(postRepositoryProvider).toggleLike(postId, post.userLiked);
    } catch (_) {
      // Revert state on failure
      final revertedPosts = List<Post>.from(posts);
      state = AsyncData(revertedPosts);
    }
  }

  void onPostViewed(String postId) {
    ref.read(postRepositoryProvider).incrementView(postId);
  }

  /// Remove o post otimisticamente; em caso de falha, restaura a lista.
  Future<bool> deletePost(String postId) async {
    final posts = state.value;
    if (posts == null) return false;

    final previous = List<Post>.from(posts);
    final filtered = posts.where((p) => p.id != postId).toList();
    state = AsyncData(filtered);

    try {
      await ref.read(postRepositoryProvider).deletePost(postId);
      return true;
    } catch (_) {
      state = AsyncData(previous);
      return false;
    }
  }
}
