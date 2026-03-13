// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'social_stats.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SocialStats _$SocialStatsFromJson(Map<String, dynamic> json) => _SocialStats(
  followersCount: (json['followers_count'] as num?)?.toInt() ?? 0,
  followingCount: (json['following_count'] as num?)?.toInt() ?? 0,
  livesCount: (json['lives_count'] as num?)?.toInt() ?? 0,
  totalLikes: (json['total_likes'] as num?)?.toInt() ?? 0,
  isFollowing: json['is_following'] as bool? ?? false,
);

Map<String, dynamic> _$SocialStatsToJson(_SocialStats instance) =>
    <String, dynamic>{
      'followers_count': instance.followersCount,
      'following_count': instance.followingCount,
      'lives_count': instance.livesCount,
      'total_likes': instance.totalLikes,
      'is_following': instance.isFollowing,
    };
