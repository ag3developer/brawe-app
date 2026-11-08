import 'gif_item.dart';

class PostComment {
  const PostComment({
    required this.id,
    required this.postId,
    required this.authorId,
    required this.authorName,
    required this.authorUsername,
    this.authorAvatarUrl,
    this.authorIsVerified = false,
    required this.content,
    required this.likesCount,
    this.userLiked = false,
    required this.createdAt,
    this.parentId,
    this.replies = const [],
    this.gif,
  });

  final String id;
  final String postId;
  final String authorId;
  final String authorName;
  final String authorUsername;
  final String? authorAvatarUrl;
  final bool authorIsVerified;
  final String content;
  final int likesCount;
  final bool userLiked;
  final DateTime createdAt;
  final String? parentId;
  final List<PostComment> replies;

  /// GIF (GIPHY) do comentário; `content` pode ser vazio quando há GIF.
  final GifAttachment? gif;

  PostComment copyWith({
    int? likesCount,
    bool? userLiked,
    List<PostComment>? replies,
  }) => PostComment(
    id: id,
    postId: postId,
    authorId: authorId,
    authorName: authorName,
    authorUsername: authorUsername,
    authorAvatarUrl: authorAvatarUrl,
    authorIsVerified: authorIsVerified,
    content: content,
    likesCount: likesCount ?? this.likesCount,
    userLiked: userLiked ?? this.userLiked,
    createdAt: createdAt,
    parentId: parentId,
    replies: replies ?? this.replies,
    gif: gif,
  );

  String get timeAgo {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inSeconds < 60) return '${diff.inSeconds}s';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }
}
