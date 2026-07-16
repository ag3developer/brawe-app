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
  accountType:
      $enumDecodeNullable(_$AccountTypeEnumMap, json['account_type']) ??
      AccountType.consumer,
  artistId: json['artist_id'] as String?,
  artistName: json['artist_name'] as String?,
  artistGenres: (json['artist_genres'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  artistCity: json['artist_city'] as String?,
  artistCountry: json['artist_country'] as String?,
  artistTotalTracks: (json['artist_total_tracks'] as num?)?.toInt() ?? 0,
  artistTotalPlays: (json['artist_total_plays'] as num?)?.toInt() ?? 0,
  createdAt: json['created_at'] as String?,
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
  'account_type': _$AccountTypeEnumMap[instance.accountType]!,
  'artist_id': instance.artistId,
  'artist_name': instance.artistName,
  'artist_genres': instance.artistGenres,
  'artist_city': instance.artistCity,
  'artist_country': instance.artistCountry,
  'artist_total_tracks': instance.artistTotalTracks,
  'artist_total_plays': instance.artistTotalPlays,
  'created_at': instance.createdAt,
};

const _$AccountTypeEnumMap = {
  AccountType.consumer: 'consumer',
  AccountType.creator: 'creator',
  AccountType.musician: 'musician',
  AccountType.business: 'business',
};
