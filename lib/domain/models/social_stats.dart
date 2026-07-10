import 'package:freezed_annotation/freezed_annotation.dart';

part 'social_stats.freezed.dart';
part 'social_stats.g.dart';

@freezed
sealed class SocialStats with _$SocialStats {
  const factory SocialStats({
    @JsonKey(name: 'followers_count') @Default(0) int followersCount,
    @JsonKey(name: 'following_count') @Default(0) int followingCount,
    // Backend retorna `total_lives` (contagem de lives do usuário).
    @JsonKey(name: 'total_lives') @Default(0) int livesCount,
    // Alcance total: soma de views de posts + mídia + stories + lives.
    @JsonKey(name: 'total_views') @Default(0) int totalViews,
    @JsonKey(name: 'is_following') @Default(false) bool isFollowing,
  }) = _SocialStats;

  factory SocialStats.fromJson(Map<String, dynamic> json) =>
      _$SocialStatsFromJson(json);
}
