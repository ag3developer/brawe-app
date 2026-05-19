import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/network/live_dio_provider.dart';
part 'stories_service.g.dart';
@riverpod
StoriesService storiesService(Ref ref) {
  return StoriesService(ref.watch(liveDioProvider));
}
class StoriesService {
  final Dio _dio;
  StoriesService(this._dio);

  /// GET /stories/feed → { my_story, stories: [...] }
  Future<Map<String, dynamic>> getFeed() async {
    final response = await _dio.get('/stories/feed');
    return response.data as Map<String, dynamic>;
  }

  /// GET /stories/user/{userId}
  Future<Map<String, dynamic>> getUserStories(String userId) async {
    final response = await _dio.get('/stories/user/$userId');
    return response.data as Map<String, dynamic>;
  }

  /// POST /stories/{id}/view
  Future<void> markAsViewed(String storyId) async {
    await _dio.post('/stories/$storyId/view');
  }

  /// POST /stories/{id}/react?reaction_type=...&message=...
  /// Reação rápida (apenas emoji).
  Future<void> react(String storyId, {String reactionType = '❤️'}) async {
    await _dio.post(
      '/stories/$storyId/react',
      queryParameters: {'reaction_type': reactionType},
    );
  }

  /// Reply é uma reação com mensagem (mesmo endpoint /react).
  Future<void> reply(
    String storyId,
    String message, {
    String reactionType = '💬',
  }) async {
    await _dio.post(
      '/stories/$storyId/react',
      queryParameters: {
        'reaction_type': reactionType,
        'message': message,
      },
    );
  }

  /// GET /stories/{id}/viewers — apenas o dono.
  Future<Map<String, dynamic>> getViewers(
    String storyId, {
    int limit = 50,
    int offset = 0,
  }) async {
    final response = await _dio.get(
      '/stories/$storyId/viewers',
      queryParameters: {'limit': limit, 'offset': offset},
    );
    return response.data as Map<String, dynamic>;
  }

  /// DELETE /stories/{id}
  Future<void> deleteStory(String storyId) async {
    await _dio.delete('/stories/$storyId');
  }

  /// POST /stories/upload — multipart com `file`, `caption`, `duration_seconds`.
  /// O backend deduz `media_type` (photo/video) pelo content-type do arquivo.
  Future<Map<String, dynamic>> createStory({
    required String filePath,
    String? caption,
    int? durationSeconds,
    String? originPostId,
  }) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath),
      if (caption != null && caption.trim().isNotEmpty) 'caption': caption.trim(),
      if (durationSeconds != null) 'duration_seconds': durationSeconds,
      if (originPostId != null && originPostId.isNotEmpty)
        'origin_post_id': originPostId,
    });
    final response = await _dio.post(
      '/stories/upload',
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );
    return response.data as Map<String, dynamic>;
  }
}
