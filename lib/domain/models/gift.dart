import 'package:freezed_annotation/freezed_annotation.dart';

part 'gift.freezed.dart';
part 'gift.g.dart';

@freezed
sealed class Gift with _$Gift {
  const Gift._();

  const factory Gift({
    required String id,
    required String slug,
    required String name,
    String? emoji,
    @JsonKey(name: 'icon_url') String? iconUrl,
    @JsonKey(name: 'animation_url') String? animationUrl,
    @JsonKey(name: 'animation_type') @Default('video') String animationType,
    @JsonKey(name: 'price_credits') @Default(0.0) double priceCredits,
    @JsonKey(name: 'price_usdt') @Default(0.0) double priceUsdt,
    @Default('basic') String tier,
    @JsonKey(name: 'is_fullscreen') @Default(false) bool isFullscreen,
    @JsonKey(name: 'animation_duration_ms') @Default(0) int animationDurationMs,
    @JsonKey(name: 'combo_enabled') @Default(false) bool comboEnabled,
  }) = _Gift;

  factory Gift.fromJson(Map<String, dynamic> json) => _$GiftFromJson(json);

  double get price => priceCredits;
}

@freezed
sealed class GiftTier with _$GiftTier {
  const factory GiftTier({
    required String name,
    required List<Gift> gifts,
  }) = _GiftTier;

  factory GiftTier.fromJson(Map<String, dynamic> json) => _$GiftTierFromJson(json);
}
