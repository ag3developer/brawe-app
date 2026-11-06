import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/network/live_dio_provider.dart';
import '../../domain/models/post_liker.dart';
import '../../domain/models/post_poll.dart';
import '../model/post_dto.dart';

part 'post_service.g.dart';

@riverpod
PostService postService(Ref ref) {
  return PostService(ref.watch(liveDioProvider));
}

class PostService {
  final Dio _dio;

  PostService(this._dio);

  Future<PostFeedResponseDto> getFeed({int limit = 20, int offset = 0}) async {
    final response = await _dio.get(
      '/posts/feed',
      queryParameters: {'limit': limit, 'offset': offset},
    );
    return PostFeedResponseDto.fromJson(response.data as Map<String, dynamic>);
  }

  Future<PostFeedResponseDto> getFollowingFeed({
    int limit = 20,
    int offset = 0,
  }) async {
    final response = await _dio.get(
      '/posts/following',
      queryParameters: {'limit': limit, 'offset': offset},
    );
    return PostFeedResponseDto.fromJson(response.data as Map<String, dynamic>);
  }

  /// Backend: GET /posts/:id  → retorna PostResponseDto plano.
  Future<PostResponseDto> getById(String postId) async {
    final response = await _dio.get('/posts/$postId');
    return PostResponseDto.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> likePost(String postId, {String reactionType = 'like'}) async {
    await _dio.post(
      '/posts/$postId/like',
      data: {'reaction_type': reactionType},
    );
  }

  Future<void> unlikePost(String postId) async {
    await _dio.delete('/posts/$postId/like');
  }

  Future<void> incrementView(String postId) async {
    await _dio.post('/posts/$postId/view');
  }

  /// Repost (idempotente no backend).
  Future<void> repost(String postId) async {
    await _dio.post('/posts/$postId/repost');
  }

  Future<void> unrepost(String postId) async {
    await _dio.delete('/posts/$postId/repost');
  }

  /// Marca um compartilhamento (DM/link externo) para progresso de quest.
  /// Best-effort: não bloqueia o fluxo se falhar.
  Future<void> trackShare(String postId) async {
    try {
      await _dio.post('/posts/$postId/share');
    } catch (_) {
      // silencioso: não atrapalhar share se o tracking falhar
    }
  }

  /// Lista quem curtiu um post com breakdown por reação.
  /// Backend: GET /posts/{post_id}/likes
  Future<PostLikesPage> getLikers(
    String postId, {
    int limit = 50,
    int offset = 0,
  }) async {
    final response = await _dio.get(
      '/posts/$postId/likes',
      queryParameters: {'limit': limit, 'offset': offset},
    );
    return PostLikesPage.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> deletePost(String postId) async {
    await _dio.delete('/posts/$postId');
  }

  Future<PostFeedResponseDto> getUserPosts(
    String userId, {
    int limit = 20,
    int offset = 0,
  }) async {
    final response = await _dio.get(
      '/posts/user/$userId',
      queryParameters: {'limit': limit, 'offset': offset},
    );
    return PostFeedResponseDto.fromJson(response.data as Map<String, dynamic>);
  }

  /// Posts de outras pessoas que [userId] repostou (aba Reposts do perfil).
  Future<PostFeedResponseDto> getUserReposts(
    String userId, {
    int limit = 20,
    int offset = 0,
  }) async {
    final response = await _dio.get(
      '/posts/user/$userId/reposts',
      queryParameters: {'limit': limit, 'offset': offset},
    );
    return PostFeedResponseDto.fromJson(response.data as Map<String, dynamic>);
  }

  Future<PostFeedResponseDto> getByHashtag(
    String tag, {
    int limit = 20,
    int offset = 0,
  }) async {
    final response = await _dio.get(
      '/posts/hashtag/$tag',
      queryParameters: {'limit': limit, 'offset': offset},
    );
    return PostFeedResponseDto.fromJson(response.data as Map<String, dynamic>);
  }

  /// Devolve o id do post criado quando o backend o informa (senão `null`).
  /// [idempotencyKey] vai no header `Idempotency-Key`: o backend de posts
  /// ainda NÃO garante deduplicação por ele (best effort) — a proteção
  /// contra post duplicado no retry é feita no cliente (o `createPost` só
  /// roda uma vez por job; reenvios reaproveitam as URLs já enviadas).
  Future<String?> createPost({
    required String content,
    String? idempotencyKey,
    String? imageUrl,
    String? audience, // mantido por compat — ignorado pelo backend atual
    String? soundId,
    int soundTrimStartMs = 0,
    int? soundTrimEndMs,
    double soundVolume = 1.0,
    double originalAudioVolume = 1.0,
    String? mediaType, // 'video' | 'image'
    int? width,
    int? height,
    double? durationSec,
    String? thumbnailUrl,
    Map<String, dynamic>? poll,
    Map<String, dynamic>? location,
  }) async {
    final res = await _dio.post(
      '/posts',
      options: idempotencyKey == null
          ? null
          : Options(headers: {'Idempotency-Key': idempotencyKey}),
      data: {
        'content': content,
        'image_url': ?imageUrl,
        'sound_id': ?soundId,
        'sound_trim_start_ms': soundTrimStartMs,
        'sound_trim_end_ms': ?soundTrimEndMs,
        if (soundId != null) 'sound_volume': soundVolume,
        if (soundId != null) 'original_audio_volume': originalAudioVolume,
        'media_type': ?mediaType,
        'width': ?width,
        'height': ?height,
        'duration_sec': ?durationSec,
        'thumbnail_url': ?thumbnailUrl,
        'poll': ?poll,
        'location': ?location,
      },
    );
    final d = res.data;
    if (d is Map) {
      final id = d['id'] ?? (d['post'] is Map ? (d['post'] as Map)['id'] : null);
      return id?.toString();
    }
    return null;
  }

  /// Vota na enquete do post. Backend: POST /posts/{id}/poll/vote
  /// (409 já votou/encerrada, 404 sem enquete). Devolve a enquete atualizada.
  Future<PostPoll> votePoll(String postId, String optionId) async {
    final res = await _dio.post(
      '/posts/$postId/poll/vote',
      data: {'option_id': optionId},
    );
    return PostPoll.fromJson(Map<String, dynamic>.from(res.data as Map));
  }

  /// Upload de imagem para post.
  /// Backend: POST /posts/upload-image (multipart, field "file")
  /// Retorno: { success, url, mime_type, size }
  Future<String> uploadMedia(String filePath) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath),
    });
    final response = await _dio.post('/posts/upload-image', data: formData);
    final data = response.data as Map<String, dynamic>;
    return data['url']?.toString() ?? '';
  }

  /// Upload de vídeo curto para post (Reels/Shorts).
  /// Backend: POST /posts/upload-video (multipart, field "file")
  /// Retorno: { url, width?, height?, duration_sec?, thumbnail_url? }
  /// Campos extras são opcionais (servidor antigo não os devolve).
  Future<VideoUploadResult> uploadVideo(
    String filePath, {
    void Function(int sent, int total)? onSendProgress,
    CancelToken? cancelToken,
  }) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        filePath,
        filename: _safeName(filePath, 'mp4'),
      ),
    });
    final response = await _dio.post(
      '/posts/upload-video',
      data: formData,
      onSendProgress: onSendProgress,
      cancelToken: cancelToken,
      options: Options(
        sendTimeout: const Duration(minutes: 10),
        receiveTimeout: const Duration(minutes: 5),
      ),
    );
    final d = response.data as Map<String, dynamic>;
    return VideoUploadResult(
      url: d['url']?.toString() ?? '',
      width: _asInt(d['width']),
      height: _asInt(d['height']),
      durationSec: _asDouble(d['duration_sec']),
      thumbnailUrl: d['thumbnail_url']?.toString(),
    );
  }

  /// Upload de capa personalizada. Backend: POST /posts/upload-cover.
  /// Retorno: { url, width, height }. Devolve a URL.
  Future<String> uploadCover(
    String filePath, {
    void Function(int sent, int total)? onSendProgress,
    CancelToken? cancelToken,
  }) async {
    final ext = filePath.toLowerCase().endsWith('.png') ? 'png' : 'jpg';
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        filePath,
        filename: _safeName(filePath, ext),
      ),
    });
    final response = await _dio.post(
      '/posts/upload-cover',
      data: formData,
      onSendProgress: onSendProgress,
      cancelToken: cancelToken,
    );
    final d = response.data as Map<String, dynamic>;
    return d['url']?.toString() ?? '';
  }

  static String _safeName(String path, String ext) {
    final base = path.split('/').last.split('.').first;
    final clean = base.replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '_');
    return '${clean.isEmpty ? 'file' : clean}.$ext';
  }

  static int? _asInt(dynamic v) =>
      v is num ? v.round() : int.tryParse('${v ?? ''}');
  static double? _asDouble(dynamic v) =>
      v is num ? v.toDouble() : double.tryParse('${v ?? ''}');
}

/// Resultado do upload de vídeo (campos além de [url] são opcionais).
class VideoUploadResult {
  const VideoUploadResult({
    required this.url,
    this.width,
    this.height,
    this.durationSec,
    this.thumbnailUrl,
  });

  final String url;
  final int? width;
  final int? height;
  final double? durationSec;
  final String? thumbnailUrl;
}
