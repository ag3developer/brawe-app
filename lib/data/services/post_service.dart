import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/network/live_dio_provider.dart';
import '../../domain/models/post_liker.dart';
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

  Future<void> createPost({
    required String content,
    String? imageUrl,
    String? audience, // mantido por compat — ignorado pelo backend atual
    String? soundId,
    int soundTrimStartMs = 0,
    int? soundTrimEndMs,
    double soundVolume = 1.0,
    double originalAudioVolume = 1.0,
  }) async {
    await _dio.post(
      '/posts',
      data: {
        'content': content,
        'image_url': ?imageUrl,
        'sound_id': ?soundId,
        'sound_trim_start_ms': soundTrimStartMs,
        'sound_trim_end_ms': ?soundTrimEndMs,
        if (soundId != null) 'sound_volume': soundVolume,
        if (soundId != null) 'original_audio_volume': originalAudioVolume,
      },
    );
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
  /// Aceita MP4/MOV/WebM, máx 100MB (definido no backend).
  /// Retorno: { success, url, mime_type, size, duration? }
  Future<String> uploadVideo(String filePath) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath),
    });
    final response = await _dio.post(
      '/posts/upload-video',
      data: formData,
      options: Options(
        // Vídeos podem demorar mais — sobe o timeout p/ 2 min.
        sendTimeout: const Duration(minutes: 2),
        receiveTimeout: const Duration(minutes: 2),
      ),
    );
    final data = response.data as Map<String, dynamic>;
    return data['url']?.toString() ?? '';
  }
}
