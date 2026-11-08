import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/models/post.dart';
import '../../domain/models/post_liker.dart';
import '../../domain/models/post_poll.dart';
import '../services/post_service.dart';
import '../model/post_dto.dart';
import '../../domain/models/failure.dart';
import 'package:dio/dio.dart';

part 'post_repository.g.dart';

@riverpod
PostRepository postRepository(Ref ref) {
  return PostRepository(ref.watch(postServiceProvider));
}

/// Voto recusado pelo servidor (409/404). [code]: `already_voted`,
/// `poll_ended`, `poll_not_found`, `option_not_found`.
class PollVoteException implements Exception {
  const PollVoteException(this.code);
  final String code;
  @override
  String toString() => 'PollVoteException($code)';
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
    Map<String, dynamic>? poll,
    PostLocation? location,
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
        poll: poll,
        location: location?.toRequestJson(),
      );
    } on DioException catch (_) {
      throw const Failure.network();
    } catch (_) {
      throw const Failure.unknown();
    }
  }

  /// Vota na enquete. Lança [PollVoteException] com o código do servidor
  /// (`already_voted`, `poll_ended`, ...) em 404/409.
  Future<PostPoll> votePoll(String postId, String optionId) async {
    try {
      return await _postService.votePoll(postId, optionId);
    } on DioException catch (e) {
      final code = e.response?.statusCode;
      if (code == 404 || code == 409) {
        final d = e.response?.data;
        final detail = d is Map ? d['detail']?.toString() : null;
        throw PollVoteException(detail ?? (code == 404 ? 'poll_not_found' : 'already_voted'));
      }
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
  Future<String?> createVideoPost({
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
    // Progresso geral 0..1 (vídeo 0–90%, capa 90–97%) + `processing` quando
    // os bytes já subiram e o servidor ainda responde.
    void Function(double progress, bool processing)? onProgress,
    CancelToken? cancelToken,
    VideoPublishCheckpoint? checkpoint,
    // Envio direto ao storage (sem o teto de corpo da Cloudflare/Nginx).
    bool directUpload = false,
  }) async {
    final cp = checkpoint ?? VideoPublishCheckpoint();
    try {
      var up = cp.video;
      if (up == null) {
        onStep?.call(VideoPublishStep.uploadingVideo);
        void sendProgress(int sent, int total) {
          if (total <= 0) return;
          final f = sent / total;
          onProgress?.call(0.9 * f, f >= 1);
        }

        up = directUpload
            ? await _postService.uploadVideoDirect(
                videoLocalPath,
                cancelToken: cancelToken,
                onSendProgress: sendProgress,
              )
            : await _postService.uploadVideo(
                videoLocalPath,
                cancelToken: cancelToken,
                onSendProgress: sendProgress,
              );
        if (up.url.isEmpty) {
          throw const Failure.unknown();
        }
        cp.video = up;
      }
      onProgress?.call(0.9, false);
      var thumbUrl = up.thumbnailUrl;
      if (coverLocalPath != null) {
        if (cp.coverUrl == null) {
          onStep?.call(VideoPublishStep.uploadingCover);
          try {
            final c = await _postService.uploadCover(
              coverLocalPath,
              cancelToken: cancelToken,
              onSendProgress: (sent, total) {
                if (total <= 0) return;
                final f = sent / total;
                onProgress?.call(0.9 + 0.07 * f, f >= 1);
              },
            );
            if (c.isNotEmpty) cp.coverUrl = c;
          } on DioException catch (e) {
            if (CancelToken.isCancel(e)) rethrow;
            throw const VideoCoverUploadFailure();
          }
        }
        thumbUrl = cp.coverUrl ?? thumbUrl;
      }
      onStep?.call(VideoPublishStep.publishing);
      onProgress?.call(0.97, true);
      final id = await _postService.createPost(
        content: content,
        idempotencyKey: cp.idempotencyKey,
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
      onProgress?.call(1, false);
      return id;
    } on VideoCoverUploadFailure {
      rethrow;
    } on VideoProcessingFailure {
      rethrow;
    } on DioException {
      // Mantém o DioException (status/detalhe do servidor): quem publica
      // (VideoUploadManager) traduz para uma mensagem clara.
      rethrow;
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

/// Estado já concluído de uma publicação de vídeo: no retry, etapas prontas
/// (vídeo/capa enviados) não são refeitas e o post nunca é criado 2 vezes.
class VideoPublishCheckpoint {
  VideoPublishCheckpoint({String? key})
    : idempotencyKey = key ?? DateTime.now().microsecondsSinceEpoch.toRadixString(36);
  final String idempotencyKey;
  VideoUploadResult? video;
  String? coverUrl;
}

/// Falha específica do envio da capa (para mensagem dedicada).
class VideoCoverUploadFailure implements Exception {
  const VideoCoverUploadFailure();
}
