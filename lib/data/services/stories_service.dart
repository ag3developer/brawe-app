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

  /// POST /stories/active-status
  /// Body: { "user_ids": [...] }
  /// Resposta: { "users": { "<id>": { has_stories, has_unviewed }, ... } }
  ///
  /// Limite recomendado: 200 ids por chamada (o backend valida).
  Future<Map<String, dynamic>> getActiveStatusBatch(
    List<String> userIds,
  ) async {
    final response = await _dio.post(
      '/stories/active-status',
      data: {'user_ids': userIds},
      options: Options(
        contentType: 'application/json',
        sendTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );
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
  ///
  /// Obs: o `LiveDio` define `Content-Type: application/json` no header do
  /// BaseOptions. Em requisições sem corpo (DELETE), o Dio compara esse header
  /// com o campo interno `contentType` e — mesmo sendo o mesmo valor — lança
  /// `Invalid argument (contentType): Unable to set different values...`.
  /// Setar `contentType` explicitamente aqui resolve o conflito.
  Future<void> deleteStory(String storyId) async {
    await _dio.delete<dynamic>(
      '/stories/$storyId',
      options: Options(
        contentType: 'application/json',
        sendTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
        validateStatus: (status) => status != null && status < 500,
      ),
    );
  }

  /// POST /stories/upload — multipart com `file`, `caption`, `duration_seconds`.
  /// O backend deduz `media_type` (photo/video) pelo content-type do arquivo.
  ///
  /// [idempotencyKey]: UUID v4 compartilhado entre todos os retries do
  /// mesmo upload. Vai como header HTTP `Idempotency-Key`. O backend
  /// guarda em `stories.idempotency_key` (UNIQUE) — se a mesma key
  /// chegar 2x, devolve o story já criado sem duplicar (idempotência
  /// padrão Stripe). Resolve o bug de stories duplicados em uploads
  /// lentos.
  Future<Map<String, dynamic>> createStory({
    required String filePath,
    String? caption,
    int? durationSeconds,
    String? originPostId,
    String? idempotencyKey,
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
      options: Options(
        contentType: 'multipart/form-data',
        headers: {
          if (idempotencyKey != null && idempotencyKey.isNotEmpty)
            'Idempotency-Key': idempotencyKey,
        },
        // Upload de PNG flatten (3-5MB) em 4G/Wi-Fi instável pode demorar
        // mais que o timeout padrão (30s). Sem isso o cliente cai no catch
        // mesmo após o backend ter persistido o story → usuário vê "falha"
        // e ao recarregar o feed o story está lá.
        sendTimeout: const Duration(minutes: 2),
        receiveTimeout: const Duration(minutes: 2),
      ),
    );
    return response.data as Map<String, dynamic>;
  }
}
