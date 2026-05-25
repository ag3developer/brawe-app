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
    String? animationUrl,
    String? animationType,
    @Default(false) bool isFullscreen,
    String? emoji,
    required int quantity,
    @Default(0) int value,
    required DateTime timestamp,
    // ─── Gifter level (chip estilo TikTok no toast) ───
    @Default(1) int gifterLevel,
    String? gifterBadge, // emoji do badge (⭐, ⚡, 🛡️, 🔥, 👑, 💎)
    String? gifterLabel, // "Fã", "Guardião", "Lenda", etc.
    String? gifterColor, // hex string ex. "#FFD700"
    String? gifterImageUrl, // PNG remoto do pin (CDN ou /static fallback)
    @Default(false) bool levelUpgraded,
  }) = _LiveGift;

  factory LiveGift.fromJson(Map<String, dynamic> json) => _$LiveGiftFromJson(json);
}
