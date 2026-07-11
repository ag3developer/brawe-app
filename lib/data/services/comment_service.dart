import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/network/live_dio_provider.dart';

part 'comment_service.g.dart';

class CommentDto {
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
  final String createdAt;
  final String? parentId;
  final List<CommentDto> replies;

  CommentDto({
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
  });

  factory CommentDto.fromJson(Map<String, dynamic> json) {
    final rawReplies = json['replies'] as List<dynamic>? ?? [];
    return CommentDto(
      id: json['id']?.toString() ?? '',
      postId: json['post_id']?.toString() ?? json['postId']?.toString() ?? '',
      authorId:
          (json['author'] as Map?)?['id']?.toString() ??
          json['author_id']?.toString() ??
          '',
      authorName:
          (json['author'] as Map?)?['name']?.toString() ??
          json['author_name']?.toString() ??
          '',
      authorUsername:
          (json['author'] as Map?)?['username']?.toString() ??
          json['author_username']?.toString() ??
          '',
      authorAvatarUrl:
          (json['author'] as Map?)?['avatar_url']?.toString() ??
          json['author_avatar_url']?.toString(),
      authorIsVerified:
          (json['author'] as Map?)?['is_verified'] as bool? ?? false,
      content: json['content']?.toString() ?? '',
      likesCount: (json['likes_count'] as num?)?.toInt() ?? 0,
      userLiked: json['user_liked'] as bool? ?? false,
      createdAt:
          json['created_at']?.toString() ?? DateTime.now().toIso8601String(),
      parentId: json['parent_id']?.toString(),
      replies: rawReplies
          .map((r) => CommentDto.fromJson(r as Map<String, dynamic>))
          .toList(),
    );
  }
}

@riverpod
CommentService commentService(Ref ref) {
  return CommentService(ref.watch(liveDioProvider));
}

class CommentService {
  final Dio _dio;
  CommentService(this._dio);

  Future<List<CommentDto>> getComments(
    String postId, {
    int limit = 50,
    int offset = 0,
  }) async {
    final response = await _dio.get(
      '/posts/$postId/comments',
      queryParameters: {'limit': limit, 'offset': offset},
    );
    final data = response.data;
    final List<dynamic> list = data is List
        ? data
        : (data as Map<String, dynamic>)['comments'] as List<dynamic>? ?? [];
    return list
        K
        K
        K
        K
        K
        K
        K
        K
        K
        .map((e) => CommentDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<CommentDto> addComment(
    String postId,
    String content, {
    String? parentId,
  }) async {
    final body = <String, dynamic>{'content': content, 'parent_id': ?parentId};
    final response = await _dio.post('/posts/$postId/comments', data: body);
    final data = response.data as Map<String, dynamic>;
    return CommentDto.fromJson(
      data['comment'] as Map<String, dynamic>? ?? data,
    );
  }

  Future<void> likeComment(String commentId) async {
    await _dio.post('/comments/$commentId/like');
  }

  Future<void> unlikeComment(String commentId) async {
    await _dio.delete('/comments/$commentId/like');
  }
}
