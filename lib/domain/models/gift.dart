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
    // ── Economia não-monetária (FREE) ──
    @JsonKey(name: 'is_monetary') @Default(true) bool isMonetary,
    @JsonKey(name: 'price_coins') @Default(0) int priceCoins,
    @JsonKey(name: 'cooldown_seconds') @Default(0) int cooldownSeconds,
  }) = _Gift;

  factory Gift.fromJson(Map<String, dynamic> json) => _$GiftFromJson(json);

  /// Preço exibido na UI: créditos (USDT) para gifts monetários, coins para FREE.
  double get price => isMonetary ? priceCredits : priceCoins.toDouble();

  /// True se este gift é pago com coins de quests (FREE tier).
  bool get isFreeTier => !isMonetary;
}

@freezed
sealed class GiftTier with _$GiftTier {
  const factory GiftTier({
    required String name,
    required List<Gift> gifts,
  }) = _GiftTier;

  factory GiftTier.fromJson(Map<String, dynamic> json) => _$GiftTierFromJson(json);
}
