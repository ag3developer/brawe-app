import 'package:freezed_annotation/freezed_annotation.dart';

part 'social_stats.freezed.dart';
part 'social_stats.g.dart';

@freezed
sealed class SocialStats with _$SocialStats {
  const factory SocialStats({
    @JsonKey(name: 'followers_count') @Default(0) int followersCount,
    @JsonKey(name: 'following_count') @Default(0) int followingCount,
    @JsonKey(name: 'lives_count') @Default(0) int livesCount,
    @JsonKey(name: 'total_likes') @Default(0) int totalLikes,
    @JsonKey(name: 'is_following') @Default(false) bool isFollowing,
  }) = _SocialStats;

  factory SocialStats.fromJson(Map<String, dynamic> json) => _$SocialStatsFromJson(json);
}
