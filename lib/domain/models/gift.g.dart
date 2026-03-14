// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gift.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Gift _$GiftFromJson(Map<String, dynamic> json) => _Gift(
  id: json['id'] as String,
  name: json['name'] as String,
  price: (json['price'] as num).toDouble(),
  iconUrl: json['icon_url'] as String?,
  animationUrl: json['animation_url'] as String?,
  tier: json['tier'] as String? ?? 'low',
);

Map<String, dynamic> _$GiftToJson(_Gift instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'price': instance.price,
  'icon_url': instance.iconUrl,
  'animation_url': instance.animationUrl,
  'tier': instance.tier,
};

_GiftTier _$GiftTierFromJson(Map<String, dynamic> json) => _GiftTier(
  name: json['name'] as String,
  gifts: (json['gifts'] as List<dynamic>)
      .map((e) => Gift.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$GiftTierToJson(_GiftTier instance) => <String, dynamic>{
  'name': instance.name,
  'gifts': instance.gifts,
};
