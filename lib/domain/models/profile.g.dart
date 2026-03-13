// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Profile _$ProfileFromJson(Map<String, dynamic> json) => _Profile(
  id: json['id'] as String,
  displayName: json['display_name'] as String?,
  username: json['username'] as String?,
  bio: json['bio'] as String?,
  avatarUrl: json['avatar_url'] as String?,
  bannerUrl: json['banner_url'] as String?,
  isVerified: json['is_verified'] as bool? ?? false,
  socialLinks: (json['social_links'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, e as String),
  ),
);

Map<String, dynamic> _$ProfileToJson(_Profile instance) => <String, dynamic>{
  'id': instance.id,
  'display_name': instance.displayName,
  'username': instance.username,
  'bio': instance.bio,
  'avatar_url': instance.avatarUrl,
  'banner_url': instance.bannerUrl,
  'is_verified': instance.isVerified,
  'social_links': instance.socialLinks,
};
