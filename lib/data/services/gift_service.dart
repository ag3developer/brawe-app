import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/network/live_dio_provider.dart';

part 'gift_service.g.dart';

@riverpod
GiftService giftService(Ref ref) {
  return GiftService(ref.watch(liveDioProvider));
}

class GiftService {
  final Dio _dio;

  GiftService(this._dio);

  /// Resposta completa: `data` (abas → presentes) e `collections` (nomes
  /// das categorias temáticas por idioma).
  Future<Map<String, dynamic>> getGiftCatalog() async {
    final response = await _dio.get('/live/gifts/catalog');
    final body = response.data;
    return body is Map<String, dynamic> ? body : <String, dynamic>{};
  }

  /// Envia um gift no contexto de um story (não de uma live).
  ///
  /// Endpoint: `POST /stories/{storyId}/gift`
  /// Retorna o payload de sucesso (transaction_id, animation_url, etc.).
  Future<Map<String, dynamic>> sendStoryGift({
    required String storyId,
    required String giftId,
    int quantity = 1,
  }) async {
    final response = await _dio.post(
      '/stories/$storyId/gift',
      data: {
        'gift_id': giftId,
        'quantity': quantity,
      },
    );
    final raw = response.data;
    if (raw is Map<String, dynamic>) {
      final data = raw['data'];
      if (data is Map<String, dynamic>) return data;
      return raw;
    }
    return <String, dynamic>{};
  }

  Future<List<Map<String, dynamic>>> getTopGifters(
    String roomId, {
    int limit = 10,
  }) async {
    final response = await _dio.get(
      '/live/gifts/top-gifters/$roomId',
      queryParameters: {'limit': limit},
    );
    final data = response.data['data'] ?? response.data;
    if (data is List) {
      return List<Map<String, dynamic>>.from(data);
    }
    return [];
  }

  /// Retorna o nível atual do gifter (espectador) — usado no header da
  /// sacola de presentes para exibir avatar + chip de nível + barra de XP.
  ///
  /// Endpoint: `GET /live/gifts/me/level`
  /// Payload:
  /// ```json
  /// { "level": 12, "xp": 4500, "badge": {...}, "next_level": {...} }
  /// ```
  Future<Map<String, dynamic>> getMyGifterLevel() async {
    final response = await _dio.get('/live/gifts/me/level');
    final raw = response.data;
    if (raw is Map<String, dynamic>) {
      final data = raw['data'];
      if (data is Map<String, dynamic>) return data;
      return raw;
    }
    return <String, dynamic>{};
  }

  /// Jornada de nível: faixas, status e regras de XP.
  /// Backend: `GET /live/gifts/me/level/journey`.
  Future<Map<String, dynamic>> getMyGifterLevelJourney() async {
    final response = await _dio.get('/live/gifts/me/level/journey');
    final raw = response.data;
    if (raw is Map<String, dynamic>) {
      final data = raw['data'];
      if (data is Map<String, dynamic>) return data;
      return raw;
    }
    return <String, dynamic>{};
  }
}
