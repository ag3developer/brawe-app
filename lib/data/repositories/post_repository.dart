import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/models/post.dart';
import '../../domain/models/post_liker.dart';
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

  /// Reage a um post (ou troca a reação existente).
  /// Tipos válidos: like, love, fire, laugh, wow, sad.
  Future<void> react(String postId, String reactionType) async {
    try {
      await _postService.likePost(postId, reactionType: reactionType);
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

  /// Toggle repost (idempotente). [isReposted] = estado atual.
  Future<void> toggleRepost(String postId, bool isReposted) async {
    try {
      if (isReposted) {
        await _postService.unrepost(postId);
      } else {
        await _postService.repost(postId);
      }
    } catch (_) {
      throw const Failure.unknown();
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

  /// Cria um post. [soundId] (opcional) anexa uma música do Brawe Sounds
  /// escolhida no `create_post_sheet.dart`; [soundTrimStartMs]/
  /// [soundTrimEndMs] definem o trecho específico para ESTE post (não o
  /// trecho padrão sugerido pelo artista).
  Future<void> createPost({
    required String content,
    String? imageLocalPath,
    String? audience,
    String? soundId,
    int soundTrimStartMs = 0,
    int? soundTrimEndMs,
    double soundVolume = 1.0,
    double originalAudioVolume = 1.0,
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
        soundId: soundId,
        soundTrimStartMs: soundTrimStartMs,
        soundTrimEndMs: soundTrimEndMs,
        soundVolume: soundVolume,
        originalAudioVolume: originalAudioVolume,
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
  /// [soundId] (opcional) anexa uma música do Brawe Sounds ao Reel.
  Future<void> createVideoPost({
    required String videoLocalPath,
    String content = '',
    String? audience,
    String? soundId,
    int soundTrimStartMs = 0,
    int? soundTrimEndMs,
    double soundVolume = 1.0,
    double originalAudioVolume = 1.0,
    String? coverLocalPath,
    int? fallbackWidth,
    int? fallbackHeight,
    double? fallbackDurationSec,
    void Function(VideoPublishStep step)? onStep,
  }) async {
    try {
      onStep?.call(VideoPublishStep.uploadingVideo);
      final up = await _postService.uploadVideo(videoLocalPath);
      if (up.url.isEmpty) {
        throw const Failure.unknown();
      }
      var thumbUrl = up.thumbnailUrl;
      if (coverLocalPath != null) {
        onStep?.call(VideoPublishStep.uploadingCover);
        try {
          final c = await _postService.uploadCover(coverLocalPath);
          if (c.isNotEmpty) thumbUrl = c;
        } on DioException catch (_) {
          throw const VideoCoverUploadFailure();
        }
      }
      onStep?.call(VideoPublishStep.publishing);
      await _postService.createPost(
        content: content,
        imageUrl: up.url,
        mediaType: 'video',
        width: up.width ?? fallbackWidth,
        height: up.height ?? fallbackHeight,
        durationSec: up.durationSec ?? fallbackDurationSec,
        thumbnailUrl: thumbUrl,
        audience: audience,
        soundId: soundId,
        soundTrimStartMs: soundTrimStartMs,
        soundTrimEndMs: soundTrimEndMs,
        soundVolume: soundVolume,
        originalAudioVolume: originalAudioVolume,
      );
    } on VideoCoverUploadFailure {
      rethrow;
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

  Future<List<Post>> getUserReposts(
    String userId, {
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final responseDto = await _postService.getUserReposts(
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

  Future<List<Post>> getByHashtag(
    String tag, {
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final responseDto = await _postService.getByHashtag(
        tag,
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

  /// Lista quem curtiu um post (com breakdown por reação).
  /// Tela: PostLikersScreen.
  Future<PostLikesPage> getLikers(
    String postId, {
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      return await _postService.getLikers(postId, limit: limit, offset: offset);
    } on DioException catch (_) {
      throw const Failure.network();
    } catch (_) {
      throw const Failure.unknown();
    }
  }
}

/// Etapas da publicação de vídeo (para mostrar progresso na UI).
enum VideoPublishStep { uploadingVideo, uploadingCover, publishing }

/// Falha específica do envio da capa (para mensagem dedicada).
class VideoCoverUploadFailure implements Exception {
  const VideoCoverUploadFailure();
}
