import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/models/failure.dart';
import '../../domain/models/gift.dart';
import '../../domain/models/gifter.dart';
import '../services/gift_service.dart';
import '../services/live_service.dart';

part 'gift_repository.g.dart';

@riverpod
GiftRepository giftRepository(Ref ref) {
  return GiftRepository(
    ref.watch(giftServiceProvider),
    ref.watch(liveServiceProvider),
  );
}

class GiftRepository {
  final GiftService _giftService;
  final LiveService _liveService;

  GiftRepository(this._giftService, this._liveService);

  Future<List<GiftTier>> getGiftCatalog() async {
    try {
      final data = await _giftService.getGiftCatalog();
      // Expecting { "basic": [...], "premium": [...], "exclusive": [...] }
      final List<GiftTier> tiers = [];
      
      data.forEach((key, value) {
        if (value is List) {
          tiers.add(GiftTier(
            name: key,
            gifts: value.map((g) => Gift.fromJson(g as Map<String, dynamic>)).toList(),
          ));
        }
      });
      
      // Sort by some order if needed, but for now just return as is
      return tiers;
    } on DioException catch (e) {
      throw _mapFailure(e);
    } catch (e) {
      throw const Failure.unknown();
    }
  }

  Future<void> sendGift({
    required String roomId,
    required String giftId,
    int quantity = 1,
    String? battleId,
  }) async {
    try {
      await _liveService.sendGift(
        roomId: roomId,
        giftId: giftId,
        quantity: quantity,
        battleId: battleId,
      );
    } on DioException catch (e) {
      throw _mapFailure(e);
    } catch (e) {
      throw const Failure.unknown();
    }
  }

  Future<List<Gifter>> getTopGifters(String roomId, {int limit = 10}) async {
    try {
      final list = await _giftService.getTopGifters(roomId, limit: limit);
      return list.map((json) => Gifter.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _mapFailure(e);
    } catch (e) {
      throw const Failure.unknown();
    }
  }

  Failure _mapFailure(DioException exception) {
    final statusCode = exception.response?.statusCode;
    if (statusCode == 401 || statusCode == 403) {
      return const Failure.unauthorized();
    }
    if (statusCode == 400 && exception.response?.data?['detail'] != null) {
      // Could be insufficient balance
      return Failure.validation(exception.response?.data?['detail'].toString() ?? 'Validation error');
    }
    if (statusCode != null && statusCode >= 500) {
      return const Failure.server();
    }
    return const Failure.network();
  }
}
