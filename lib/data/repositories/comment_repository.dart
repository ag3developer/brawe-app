import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/models/failure.dart';
import '../../domain/models/post_comment.dart';
import '../services/comment_service.dart';

part 'comment_repository.g.dart';

@riverpod
CommentRepository commentRepository(Ref ref) {
  return CommentRepository(ref.watch(commentServiceProvider));
}

class CommentRepository {
  final CommentService _service;
  CommentRepository(this._service);

  Future<List<PostComment>> getComments(String postId,
      {int limit = 50, int offset = 0}) async {
    try {
      final dtos = await _service.getComments(postId, limit: limit, offset: offset);
      return dtos.map(_mapDto).toList();
    } on DioException catch (_) {
      throw const Failure.network();
    } catch (_) {
      throw const Failure.unknown();
    }
  }

  Future<PostComment> addComment(String postId, String content,
      {String? parentId}) async {
    try {
      final dto = await _service.addComment(postId, content, parentId: parentId);
      return _mapDto(dto);
    } on DioException catch (_) {
      throw const Failure.network();
    } catch (_) {
      throw const Failure.unknown();
    }
  }

  Future<void> toggleLike(String commentId, bool isLiked) async {
    try {
      if (isLiked) {
        await _service.unlikeComment(commentId);
      } else {
        await _service.likeComment(commentId);
      }
    } catch (_) {
      throw const Failure.unknown();
    }
  }

  PostComment _mapDto(CommentDto dto) {
    return PostComment(
      id: dto.id,
      postId: dto.postId,
      authorId: dto.authorId,
      authorName: dto.authorName,
      authorUsername: dto.authorUsername,
      authorAvatarUrl: dto.authorAvatarUrl,
      authorIsVerified: dto.authorIsVerified,
      content: dto.content,
      likesCount: dto.likesCount,
      userLiked: dto.userLiked,
      createdAt: DateTime.tryParse(dto.createdAt) ?? DateTime.now(),
      parentId: dto.parentId,
      replies: dto.replies.map(_mapDto).toList(),
    );
  }
}
