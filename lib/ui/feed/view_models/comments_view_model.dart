import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../data/repositories/comment_repository.dart';
import '../../../domain/models/post_comment.dart';

part 'comments_view_model.g.dart';

@riverpod
class CommentsViewModel extends _$CommentsViewModel {
  @override
  Future<List<PostComment>> build(String postId) async {
    return ref.read(commentRepositoryProvider).getComments(postId);
  }

  Future<void> addComment(String content, {String? parentId}) async {
    final repo = ref.read(commentRepositoryProvider);
    final newComment =
        await repo.addComment(postId, content, parentId: parentId);
    final current = state.value ?? [];
    if (parentId == null) {
      state = AsyncData([newComment, ...current]);
    } else {
      state = AsyncData(current.map((c) {
        if (c.id == parentId) {
          return PostComment(
            id: c.id,
            postId: c.postId,
            authorId: c.authorId,
            authorName: c.authorName,
            authorUsername: c.authorUsername,
            authorAvatarUrl: c.authorAvatarUrl,
            authorIsVerified: c.authorIsVerified,
            content: c.content,
            likesCount: c.likesCount,
            userLiked: c.userLiked,
            createdAt: c.createdAt,
            replies: [...c.replies, newComment],
          );
        }
        return c;
      }).toList());
    }
  }

  Future<void> toggleLike(PostComment comment) async {
    final repo = ref.read(commentRepositoryProvider);
    await repo.toggleLike(comment.id, comment.userLiked);
    state = AsyncData(state.value!.map((c) {
      if (c.id == comment.id) {
        return PostComment(
          id: c.id,
          postId: c.postId,
          authorId: c.authorId,
          authorName: c.authorName,
          authorUsername: c.authorUsername,
          authorAvatarUrl: c.authorAvatarUrl,
          authorIsVerified: c.authorIsVerified,
          content: c.content,
          likesCount: comment.userLiked ? c.likesCount - 1 : c.likesCount + 1,
          userLiked: !comment.userLiked,
          createdAt: c.createdAt,
          replies: c.replies,
        );
      }
      return c;
    }).toList());
  }
}
