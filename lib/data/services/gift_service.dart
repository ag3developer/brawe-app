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

  Future<Map<String, dynamic>> getGiftCatalog() async {
    final response = await _dio.get('/live/gifts/catalog');
    return response.data['data'] ?? response.data;
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
}
