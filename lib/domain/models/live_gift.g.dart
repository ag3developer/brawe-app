// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'live_gift.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LiveGift _$LiveGiftFromJson(Map<String, dynamic> json) => _LiveGift(
  id: json['id'] as String,
  senderId: json['senderId'] as String,
  senderName: json['senderName'] as String,
  senderAvatarUrl: json['senderAvatarUrl'] as String?,
  giftId: json['giftId'] as String,
  giftName: json['giftName'] as String,
  giftIconUrl: json['giftIconUrl'] as String?,
  quantity: (json['quantity'] as num).toInt(),
  timestamp: DateTime.parse(json['timestamp'] as String),
);

Map<String, dynamic> _$LiveGiftToJson(_LiveGift instance) => <String, dynamic>{
  'id': instance.id,
  'senderId': instance.senderId,
  'senderName': instance.senderName,
  'senderAvatarUrl': instance.senderAvatarUrl,
  'giftId': instance.giftId,
  'giftName': instance.giftName,
  'giftIconUrl': instance.giftIconUrl,
  'quantity': instance.quantity,
  'timestamp': instance.timestamp.toIso8601String(),
};
