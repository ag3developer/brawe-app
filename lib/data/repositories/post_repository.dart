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

  Future<List<Post>> getFollowingFeed({int limit = 20, int offset = 0}) async {
    try {
      final responseDto = await _postService.getFollowingFeed(
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

  Future<void> deletePost(String postId) async {
    try {
      await _postService.deletePost(postId);
    } on DioException catch (_) {
      throw const Failure.network();
    } catch (_) {
      throw const Failure.unknown();
    }
  }

  /// Busca um único post por ID (usado para preview em chat).
  Future<Post> getById(String postId) async {
    try {
      final dto = await _postService.getById(postId);
      return dto.toDomain();
    } on DioException catch (_) {
      throw const Failure.network();
    } catch (_) {
      throw const Failure.unknown();
    }
  }

  Future<void> createPost({
    required String content,
    String? imageLocalPath,
    String? audience,
  }) async {
    try {
      String? imageUrl;
      if (imageLocalPath != null) {
        imageUrl = await _postService.uploadMedia(imageLocalPath);
      }
      await _postService.createPost(
        content: content,
        imageUrl: imageUrl,
        audience: audience,
      );
    } on DioException catch (_) {
      throw const Failure.network();
    } catch (_) {
      throw const Failure.unknown();
    }
  }

  /// Cria um post de vídeo (Reels/Shorts).
  /// 1. Faz upload via /posts/upload-video → recebe URL
  /// 2. Cria post via POST /posts com image_url apontando pro vídeo
  /// O feed "Para Você" detecta vídeo pela extensão da URL (.mp4/.mov/.webm).
  Future<void> createVideoPost({
    required String videoLocalPath,
    String content = '',
    String? audience,
  }) async {
    try {
      final videoUrl = await _postService.uploadVideo(videoLocalPath);
      if (videoUrl.isEmpty) {
        throw const Failure.unknown();
      }
      await _postService.createPost(
        content: content,
        imageUrl: videoUrl,
        audience: audience,
      );
    } on DioException catch (_) {
      throw const Failure.network();
    } catch (_) {
      throw const Failure.unknown();
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
