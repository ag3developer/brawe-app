import 'package:freezed_annotation/freezed_annotation.dart';

part 'post.freezed.dart';

@freezed
sealed class Post with _$Post {
  const factory Post({
    required String id,
    required String content,
    String? imageUrl,
    required int likesCount,
    required int commentsCount,
    required int repostsCount,
    required int viewsCount,
    required DateTime createdAt,
    required PostAuthor author,
    @Default(false) bool userLiked,
    @Default(false) bool userReposted,
    @Default(false) bool userFollowingAuthor,
    // Quando o item aparece no feed por causa de um repost de alguém,
    // [repostedBy] traz o autor do repost. Frontend mostra "X repostou".
    PostAuthor? repostedBy,
    DateTime? repostCreatedAt,
  }) = _Post;
}

@freezed
sealed class PostAuthor with _$PostAuthor {
  const factory PostAuthor({
    required String id,
    required String name,
    required String username,
    String? avatarUrl,
    @Default(false) bool isVerified,
  }) = _PostAuthor;
}
