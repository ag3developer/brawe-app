import 'package:freezed_annotation/freezed_annotation.dart';

part 'sound.freezed.dart';
part 'sound.g.dart';

/// Perfil de artista no Brawe Sounds.
@freezed
sealed class SoundArtist with _$SoundArtist {
  const factory SoundArtist({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'artist_name') required String artistName,
    String? bio,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
    @JsonKey(name: 'banner_url') String? bannerUrl,
    @Default([]) List<String> genres,
    @JsonKey(name: 'country_code') String? countryCode,
    String? city,
    @JsonKey(name: 'is_verified') @Default(false) bool isVerified,
    @JsonKey(name: 'is_featured') @Default(false) bool isFeatured,
    @JsonKey(name: 'spotify_url') String? spotifyUrl,
    @JsonKey(name: 'apple_music_url') String? appleMusicUrl,
    @JsonKey(name: 'youtube_url') String? youtubeUrl,
    @JsonKey(name: 'instagram_url') String? instagramUrl,
    @JsonKey(name: 'tiktok_url') String? tiktokUrl,
    @JsonKey(name: 'website_url') String? websiteUrl,
    @JsonKey(name: 'total_tracks') @Default(0) int totalTracks,
    @JsonKey(name: 'total_plays') @Default(0) int totalPlays,
    @JsonKey(name: 'total_usages') @Default(0) int totalUsages,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _SoundArtist;

  factory SoundArtist.fromJson(Map<String, dynamic> json) =>
      _$SoundArtistFromJson(json);
}

/// Música individual de Brawe Sounds.
@freezed
sealed class Sound with _$Sound {
  const factory Sound({
    required String id,
    @JsonKey(name: 'artist_id') required String artistId,
    required String title,
    String? slug,
    @JsonKey(name: 'audio_url') required String audioUrl,
    @JsonKey(name: 'cover_url') String? coverUrl,
    @JsonKey(name: 'waveform_url') String? waveformUrl,
    @JsonKey(name: 'duration_ms') @Default(0) int durationMs,
    int? bpm,
    String? genre,
    String? subgenre,
    String? mood,
    String? language,
    @JsonKey(name: 'album_name') String? albumName,
    @JsonKey(name: 'license_type') @Default('brawe_standard') String licenseType,
    @JsonKey(name: 'allow_trim') @Default(true) bool allowTrim,
    @JsonKey(name: 'trim_start_ms') @Default(0) int trimStartMs,
    @JsonKey(name: 'trim_end_ms') int? trimEndMs,
    @JsonKey(name: 'play_count') @Default(0) int playCount,
    @JsonKey(name: 'usage_count') @Default(0) int usageCount,
    @JsonKey(name: 'save_count') @Default(0) int saveCount,
    @Default('pending') String status,
    @JsonKey(name: 'is_saved') @Default(false) bool isSaved,
    SoundArtist? artist,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _Sound;

  factory Sound.fromJson(Map<String, dynamic> json) => _$SoundFromJson(json);
}

/// Wrapper para respostas paginadas do catálogo.
class SoundCatalog {
  final List<Sound> items;
  final int total;
  final int page;
  final bool hasMore;

  const SoundCatalog({
    required this.items,
    required this.total,
    required this.page,
    required this.hasMore,
  });

  factory SoundCatalog.fromJson(Map<String, dynamic> json) => SoundCatalog(
        items: (json['items'] as List?)
                ?.map((e) => Sound.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const [],
        total: json['total'] as int? ?? 0,
        page: json['page'] as int? ?? 1,
        hasMore: json['has_more'] as bool? ?? false,
      );
}
