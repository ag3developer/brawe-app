// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gift.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Gift _$GiftFromJson(Map<String, dynamic> json) => _Gift(
  id: json['id'] as String,
  slug: json['slug'] as String,
  name: json['name'] as String,
  emoji: json['emoji'] as String?,
  iconUrl: json['icon_url'] as String?,
  animationUrl: json['animation_url'] as String?,
  animationType: json['animation_type'] as String? ?? 'video',
  priceCredits: (json['price_credits'] as num?)?.toDouble() ?? 0.0,
  priceUsdt: (json['price_usdt'] as num?)?.toDouble() ?? 0.0,
  tier: json['tier'] as String? ?? 'basic',
  isFullscreen: json['is_fullscreen'] as bool? ?? false,
  animationDurationMs: (json['animation_duration_ms'] as num?)?.toInt() ?? 0,
  comboEnabled: json['combo_enabled'] as bool? ?? false,
);

Map<String, dynamic> _$GiftToJson(_Gift instance) => <String, dynamic>{
  'id': instance.id,
  'slug': instance.slug,
  'name': instance.name,
  'emoji': instance.emoji,
  'icon_url': instance.iconUrl,
  'animation_url': instance.animationUrl,
  'animation_type': instance.animationType,
  'price_credits': instance.priceCredits,
  'price_usdt': instance.priceUsdt,
  'tier': instance.tier,
  'is_fullscreen': instance.isFullscreen,
  'animation_duration_ms': instance.animationDurationMs,
  'combo_enabled': instance.comboEnabled,
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
