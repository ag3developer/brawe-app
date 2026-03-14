import 'package:freezed_annotation/freezed_annotation.dart';

part 'gift.freezed.dart';
part 'gift.g.dart';

@freezed
sealed class Gift with _$Gift {
  const factory Gift({
    required String id,
    required String name,
    required double price,
    @JsonKey(name: 'icon_url') String? iconUrl,
    @JsonKey(name: 'animation_url') String? animationUrl,
    @Default('low') String tier,
  }) = _Gift;

  factory Gift.fromJson(Map<String, dynamic> json) => _$GiftFromJson(json);
}

@freezed
sealed class GiftTier with _$GiftTier {
  const factory GiftTier({
    required String name,
    required List<Gift> gifts,
  }) = _GiftTier;

  factory GiftTier.fromJson(Map<String, dynamic> json) => _$GiftTierFromJson(json);
}
