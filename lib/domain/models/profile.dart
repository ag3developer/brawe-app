import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile.freezed.dart';
part 'profile.g.dart';

/// Tipo de conta — determina quais seções extras aparecem no perfil.
/// Mapeado para o campo `account_type` no backend.
enum AccountType {
  @JsonValue('consumer')
  consumer,
  @JsonValue('creator')
  creator,
  @JsonValue('musician')
  musician,
  @JsonValue('business')
  business,
}

@freezed
sealed class Profile with _$Profile {
  const factory Profile({
    required String id,
    @JsonKey(name: 'display_name') String? displayName,
    String? username,
    String? bio,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
    @JsonKey(name: 'banner_url') String? bannerUrl,
    @JsonKey(name: 'is_verified') @Default(false) bool isVerified,
    @JsonKey(name: 'social_links') Map<String, String>? socialLinks,
    @JsonKey(name: 'account_type')
    @Default(AccountType.consumer)
    AccountType accountType,
    // Campos de artista — populados quando accountType == musician
    @JsonKey(name: 'artist_id') String? artistId,
    @JsonKey(name: 'artist_name') String? artistName,
    @JsonKey(name: 'artist_genres') List<String>? artistGenres,
    @JsonKey(name: 'artist_city') String? artistCity,
    @JsonKey(name: 'artist_country') String? artistCountry,
    @JsonKey(name: 'artist_total_tracks') @Default(0) int artistTotalTracks,
    @JsonKey(name: 'artist_total_plays') @Default(0) int artistTotalPlays,
    // Data de criação do perfil
    @JsonKey(name: 'created_at') String? createdAt,
  }) = _Profile;

  factory Profile.fromJson(Map<String, dynamic> json) =>
      _$ProfileFromJson(json);
}
