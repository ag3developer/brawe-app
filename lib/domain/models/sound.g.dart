// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sound.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SoundArtist _$SoundArtistFromJson(Map<String, dynamic> json) => _SoundArtist(
  id: json['id'] as String,
  userId: json['user_id'] as String,
  artistName: json['artist_name'] as String,
  bio: json['bio'] as String?,
  avatarUrl: json['avatar_url'] as String?,
  bannerUrl: json['banner_url'] as String?,
  genres:
      (json['genres'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  countryCode: json['country_code'] as String?,
  city: json['city'] as String?,
  isVerified: json['is_verified'] as bool? ?? false,
  isFeatured: json['is_featured'] as bool? ?? false,
  spotifyUrl: json['spotify_url'] as String?,
  appleMusicUrl: json['apple_music_url'] as String?,
  youtubeUrl: json['youtube_url'] as String?,
  instagramUrl: json['instagram_url'] as String?,
  tiktokUrl: json['tiktok_url'] as String?,
  websiteUrl: json['website_url'] as String?,
  totalTracks: (json['total_tracks'] as num?)?.toInt() ?? 0,
  totalPlays: (json['total_plays'] as num?)?.toInt() ?? 0,
  totalUsages: (json['total_usages'] as num?)?.toInt() ?? 0,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$SoundArtistToJson(_SoundArtist instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'artist_name': instance.artistName,
      'bio': instance.bio,
      'avatar_url': instance.avatarUrl,
      'banner_url': instance.bannerUrl,
      'genres': instance.genres,
      'country_code': instance.countryCode,
      'city': instance.city,
      'is_verified': instance.isVerified,
      'is_featured': instance.isFeatured,
      'spotify_url': instance.spotifyUrl,
      'apple_music_url': instance.appleMusicUrl,
      'youtube_url': instance.youtubeUrl,
      'instagram_url': instance.instagramUrl,
      'tiktok_url': instance.tiktokUrl,
      'website_url': instance.websiteUrl,
      'total_tracks': instance.totalTracks,
      'total_plays': instance.totalPlays,
      'total_usages': instance.totalUsages,
      'created_at': instance.createdAt?.toIso8601String(),
    };

_Sound _$SoundFromJson(Map<String, dynamic> json) => _Sound(
  id: json['id'] as String,
  artistId: json['artist_id'] as String,
  title: json['title'] as String,
  slug: json['slug'] as String?,
  audioUrl: json['audio_url'] as String,
  coverUrl: json['cover_url'] as String?,
  waveformUrl: json['waveform_url'] as String?,
  durationMs: (json['duration_ms'] as num?)?.toInt() ?? 0,
  bpm: (json['bpm'] as num?)?.toInt(),
  genre: json['genre'] as String?,
  subgenre: json['subgenre'] as String?,
  mood: json['mood'] as String?,
  language: json['language'] as String?,
  albumName: json['album_name'] as String?,
  licenseType: json['license_type'] as String? ?? 'brawe_standard',
  allowTrim: json['allow_trim'] as bool? ?? true,
  trimStartMs: (json['trim_start_ms'] as num?)?.toInt() ?? 0,
  trimEndMs: (json['trim_end_ms'] as num?)?.toInt(),
  playCount: (json['play_count'] as num?)?.toInt() ?? 0,
  usageCount: (json['usage_count'] as num?)?.toInt() ?? 0,
  saveCount: (json['save_count'] as num?)?.toInt() ?? 0,
  status: json['status'] as String? ?? 'pending',
  isSaved: json['is_saved'] as bool? ?? false,
  artist: json['artist'] == null
      ? null
      : SoundArtist.fromJson(json['artist'] as Map<String, dynamic>),
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$SoundToJson(_Sound instance) => <String, dynamic>{
  'id': instance.id,
  'artist_id': instance.artistId,
  'title': instance.title,
  'slug': instance.slug,
  'audio_url': instance.audioUrl,
  'cover_url': instance.coverUrl,
  'waveform_url': instance.waveformUrl,
  'duration_ms': instance.durationMs,
  'bpm': instance.bpm,
  'genre': instance.genre,
  'subgenre': instance.subgenre,
  'mood': instance.mood,
  'language': instance.language,
  'album_name': instance.albumName,
  'license_type': instance.licenseType,
  'allow_trim': instance.allowTrim,
  'trim_start_ms': instance.trimStartMs,
  'trim_end_ms': instance.trimEndMs,
  'play_count': instance.playCount,
  'usage_count': instance.usageCount,
  'save_count': instance.saveCount,
  'status': instance.status,
  'is_saved': instance.isSaved,
  'artist': instance.artist,
  'created_at': instance.createdAt?.toIso8601String(),
};
