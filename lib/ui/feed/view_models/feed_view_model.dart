import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../domain/models/post.dart';
import '../../../data/repositories/post_repository.dart';

part 'feed_view_model.g.dart';

// ── Para Você (algoritmo / descoberta) ────────────────────────────────────
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
      final revertedPosts = List<Post>.from(posts);
      state = AsyncData(revertedPosts);
    }
  }

  /// Aplica uma reação tipada (love/fire/etc.). Se o post ainda não foi
  /// curtido, marca como curtido + incrementa contador (otimista).
  Future<void> reactToPost(String postId, String reactionType) async {
    final posts = state.value;
    if (posts == null) return;
    final index = posts.indexWhere((p) => p.id == postId);
    if (index == -1) return;
    final post = posts[index];
    if (!post.userLiked) {
      final updated = List<Post>.from(posts);
      updated[index] = post.copyWith(
        userLiked: true,
        userReactionType: reactionType,
        likesCount: post.likesCount + 1,
      );
      state = AsyncData(updated);
    } else {
      // Já curtido — apenas atualiza o tipo de reação
      final updated = List<Post>.from(posts);
      updated[index] = post.copyWith(userReactionType: reactionType);
      state = AsyncData(updated);
    }
    try {
      await ref.read(postRepositoryProvider).react(postId, reactionType);
    } catch (_) {
      state = AsyncData(List<Post>.from(posts));
      rethrow;
    }
  }

  void onPostViewed(String postId) {
    ref.read(postRepositoryProvider).incrementView(postId);
  }

  Future<void> toggleRepost(String postId) async {
    final posts = state.value;
    if (posts == null) return;
    final index = posts.indexWhere((p) => p.id == postId);
    if (index == -1) return;
    final post = posts[index];
    final wasReposted = post.userReposted;
    final updated = List<Post>.from(posts);
    updated[index] = post.copyWith(
      userReposted: !wasReposted,
      repostsCount: wasReposted
          ? (post.repostsCount - 1).clamp(0, 1 << 30)
          : post.repostsCount + 1,
    );
    state = AsyncData(updated);
    try {
      await ref.read(postRepositoryProvider).toggleRepost(postId, wasReposted);
    } catch (_) {
      state = AsyncData(List<Post>.from(posts));
      rethrow;
    }
  }

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

// ── Seguindo (só posts de quem você segue) ────────────────────────────────
@riverpod
class FollowingFeedViewModel extends _$FollowingFeedViewModel {
  @override
  FutureOr<List<Post>> build() async {
    return ref.read(postRepositoryProvider).getFollowingFeed(limit: 20);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(postRepositoryProvider).getFollowingFeed(limit: 20),
    );
  }

  Future<void> toggleLike(String postId) async {
    final posts = state.value;
    if (posts == null) return;
    final index = posts.indexWhere((p) => p.id == postId);
    if (index == -1) return;
    final post = posts[index];
    final updated = List<Post>.from(posts);
    updated[index] = post.copyWith(
      userLiked: !post.userLiked,
      likesCount: post.userLiked ? post.likesCount - 1 : post.likesCount + 1,
    );
    state = AsyncData(updated);
    try {
      await ref.read(postRepositoryProvider).toggleLike(postId, post.userLiked);
    } catch (_) {
      state = AsyncData(List<Post>.from(posts));
    }
  }
}
