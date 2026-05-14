// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'follow_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FollowUser _$FollowUserFromJson(Map<String, dynamic> json) => _FollowUser(
  userId: json['user_id'] as String,
  displayName: json['display_name'] as String?,
  username: json['username'] as String? ?? '',
  avatarUrl: json['avatar_url'] as String?,
  bio: json['bio'] as String?,
  isVerified: json['is_verified'] as bool? ?? false,
  isFollowing: json['is_following'] as bool? ?? false,
  isStreamer: json['is_streamer'] as bool? ?? false,
  isLive: json['is_live'] as bool? ?? false,
  followedAt: json['followed_at'] as String?,
);

Map<String, dynamic> _$FollowUserToJson(_FollowUser instance) =>
    <String, dynamic>{
      'user_id': instance.userId,
      'display_name': instance.displayName,
      'username': instance.username,
      'avatar_url': instance.avatarUrl,
      'bio': instance.bio,
      'is_verified': instance.isVerified,
      'is_following': instance.isFollowing,
      'is_streamer': instance.isStreamer,
      'is_live': instance.isLive,
      'followed_at': instance.followedAt,
    };
