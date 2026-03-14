import 'package:freezed_annotation/freezed_annotation.dart';

part 'live_gift.freezed.dart';
part 'live_gift.g.dart';

@freezed
sealed class LiveGift with _$LiveGift {
  const factory LiveGift({
    required String id,
    required String senderId,
    required String senderName,
    String? senderAvatarUrl,
    required String giftId,
    required String giftName,
    String? giftIconUrl,
    required int quantity,
    required DateTime timestamp,
  }) = _LiveGift;

  factory LiveGift.fromJson(Map<String, dynamic> json) => _$LiveGiftFromJson(json);
}
