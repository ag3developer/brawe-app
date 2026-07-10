// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'social_stats.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SocialStats _$SocialStatsFromJson(Map<String, dynamic> json) => _SocialStats(
  followersCount: (json['followers_count'] as num?)?.toInt() ?? 0,
  followingCount: (json['following_count'] as num?)?.toInt() ?? 0,
  livesCount: (json['total_lives'] as num?)?.toInt() ?? 0,
  totalViews: (json['total_views'] as num?)?.toInt() ?? 0,
  isFollowing: json['is_following'] as bool? ?? false,
);

Map<String, dynamic> _$SocialStatsToJson(_SocialStats instance) =>
    <String, dynamic>{
      'followers_count': instance.followersCount,
      'following_count': instance.followingCount,
      'total_lives': instance.livesCount,
      'total_views': instance.totalViews,
      'is_following': instance.isFollowing,
    };
