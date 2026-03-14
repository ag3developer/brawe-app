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

  Future<void> sendGift({
    required String roomId,
    required String giftId,
    required String receiverId,
    int quantity = 1,
    String? battleId,
  }) async {
    await _dio.post(
      '/live/gifts/send-gift',
      data: {
        'room_id': roomId,
        'gift_id': giftId,
        'receiver_id': receiverId,
        'quantity': quantity,
        'battle_id': battleId,
      },
    );
  }

  Future<List<Map<String, dynamic>>> getTopGifters(String roomId, {int limit = 10}) async {
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
