import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/models/post.dart';
import '../services/post_service.dart';
import '../model/post_dto.dart';
import '../../domain/models/failure.dart';
import 'package:dio/dio.dart';

part 'post_repository.g.dart';

@riverpod
PostRepository postRepository(Ref ref) {
  return PostRepository(ref.watch(postServiceProvider));
}

class PostRepository {
  final PostService _postService;

  PostRepository(this._postService);

  Future<List<Post>> getFeed({int limit = 20, int offset = 0}) async {
    try {
      final responseDto = await _postService.getFeed(
        limit: limit,
        offset: offset,
      );
      return responseDto.posts.map((dto) => dto.toDomain()).toList();
    } on DioException catch (_) {
      throw const Failure.network();
    } catch (_) {
      throw const Failure.unknown();
    }
  }

  Future<void> toggleLike(String postId, bool isLiked) async {
    try {
      if (isLiked) {
        await _postService.unlikePost(postId);
      } else {
        await _postService.likePost(postId);
      }
    } catch (_) {
      throw const Failure.unknown();
    }
  }

  Future<void> incrementView(String postId) async {
    try {
      await _postService.incrementView(postId);
    } catch (_) {
      // Silently fail view increments or log it
    }
  }

  Future<List<Post>> getUserPosts(
    String userId, {
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final responseDto = await _postService.getUserPosts(
        userId,
        limit: limit,
        offset: offset,
      );
      return responseDto.posts.map((dto) => dto.toDomain()).toList();
    } on DioException catch (_) {
      throw const Failure.network();
    } catch (_) {
      throw const Failure.unknown();
    }
  }
}
