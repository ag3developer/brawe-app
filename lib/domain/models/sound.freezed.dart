// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sound.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SoundArtist {

 String get id;@JsonKey(name: 'user_id') String get userId;@JsonKey(name: 'artist_name') String get artistName; String? get bio;@JsonKey(name: 'avatar_url') String? get avatarUrl;@JsonKey(name: 'banner_url') String? get bannerUrl; List<String> get genres;@JsonKey(name: 'country_code') String? get countryCode; String? get city;@JsonKey(name: 'is_verified') bool get isVerified;@JsonKey(name: 'is_featured') bool get isFeatured;@JsonKey(name: 'spotify_url') String? get spotifyUrl;@JsonKey(name: 'apple_music_url') String? get appleMusicUrl;@JsonKey(name: 'youtube_url') String? get youtubeUrl;@JsonKey(name: 'instagram_url') String? get instagramUrl;@JsonKey(name: 'tiktok_url') String? get tiktokUrl;@JsonKey(name: 'website_url') String? get websiteUrl;@JsonKey(name: 'total_tracks') int get totalTracks;@JsonKey(name: 'total_plays') int get totalPlays;@JsonKey(name: 'total_usages') int get totalUsages;@JsonKey(name: 'created_at') DateTime? get createdAt;
/// Create a copy of SoundArtist
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SoundArtistCopyWith<SoundArtist> get copyWith => _$SoundArtistCopyWithImpl<SoundArtist>(this as SoundArtist, _$identity);

  /// Serializes this SoundArtist to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SoundArtist&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.artistName, artistName) || other.artistName == artistName)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.bannerUrl, bannerUrl) || other.bannerUrl == bannerUrl)&&const DeepCollectionEquality().equals(other.genres, genres)&&(identical(other.countryCode, countryCode) || other.countryCode == countryCode)&&(identical(other.city, city) || other.city == city)&&(identical(other.isVerified, isVerified) || other.isVerified == isVerified)&&(identical(other.isFeatured, isFeatured) || other.isFeatured == isFeatured)&&(identical(other.spotifyUrl, spotifyUrl) || other.spotifyUrl == spotifyUrl)&&(identical(other.appleMusicUrl, appleMusicUrl) || other.appleMusicUrl == appleMusicUrl)&&(identical(other.youtubeUrl, youtubeUrl) || other.youtubeUrl == youtubeUrl)&&(identical(other.instagramUrl, instagramUrl) || other.instagramUrl == instagramUrl)&&(identical(other.tiktokUrl, tiktokUrl) || other.tiktokUrl == tiktokUrl)&&(identical(other.websiteUrl, websiteUrl) || other.websiteUrl == websiteUrl)&&(identical(other.totalTracks, totalTracks) || other.totalTracks == totalTracks)&&(identical(other.totalPlays, totalPlays) || other.totalPlays == totalPlays)&&(identical(other.totalUsages, totalUsages) || other.totalUsages == totalUsages)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,userId,artistName,bio,avatarUrl,bannerUrl,const DeepCollectionEquality().hash(genres),countryCode,city,isVerified,isFeatured,spotifyUrl,appleMusicUrl,youtubeUrl,instagramUrl,tiktokUrl,websiteUrl,totalTracks,totalPlays,totalUsages,createdAt]);

@override
String toString() {
  return 'SoundArtist(id: $id, userId: $userId, artistName: $artistName, bio: $bio, avatarUrl: $avatarUrl, bannerUrl: $bannerUrl, genres: $genres, countryCode: $countryCode, city: $city, isVerified: $isVerified, isFeatured: $isFeatured, spotifyUrl: $spotifyUrl, appleMusicUrl: $appleMusicUrl, youtubeUrl: $youtubeUrl, instagramUrl: $instagramUrl, tiktokUrl: $tiktokUrl, websiteUrl: $websiteUrl, totalTracks: $totalTracks, totalPlays: $totalPlays, totalUsages: $totalUsages, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $SoundArtistCopyWith<$Res>  {
  factory $SoundArtistCopyWith(SoundArtist value, $Res Function(SoundArtist) _then) = _$SoundArtistCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'user_id') String userId,@JsonKey(name: 'artist_name') String artistName, String? bio,@JsonKey(name: 'avatar_url') String? avatarUrl,@JsonKey(name: 'banner_url') String? bannerUrl, List<String> genres,@JsonKey(name: 'country_code') String? countryCode, String? city,@JsonKey(name: 'is_verified') bool isVerified,@JsonKey(name: 'is_featured') bool isFeatured,@JsonKey(name: 'spotify_url') String? spotifyUrl,@JsonKey(name: 'apple_music_url') String? appleMusicUrl,@JsonKey(name: 'youtube_url') String? youtubeUrl,@JsonKey(name: 'instagram_url') String? instagramUrl,@JsonKey(name: 'tiktok_url') String? tiktokUrl,@JsonKey(name: 'website_url') String? websiteUrl,@JsonKey(name: 'total_tracks') int totalTracks,@JsonKey(name: 'total_plays') int totalPlays,@JsonKey(name: 'total_usages') int totalUsages,@JsonKey(name: 'created_at') DateTime? createdAt
});




}
/// @nodoc
class _$SoundArtistCopyWithImpl<$Res>
    implements $SoundArtistCopyWith<$Res> {
  _$SoundArtistCopyWithImpl(this._self, this._then);

  final SoundArtist _self;
  final $Res Function(SoundArtist) _then;

/// Create a copy of SoundArtist
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? artistName = null,Object? bio = freezed,Object? avatarUrl = freezed,Object? bannerUrl = freezed,Object? genres = null,Object? countryCode = freezed,Object? city = freezed,Object? isVerified = null,Object? isFeatured = null,Object? spotifyUrl = freezed,Object? appleMusicUrl = freezed,Object? youtubeUrl = freezed,Object? instagramUrl = freezed,Object? tiktokUrl = freezed,Object? websiteUrl = freezed,Object? totalTracks = null,Object? totalPlays = null,Object? totalUsages = null,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,artistName: null == artistName ? _self.artistName : artistName // ignore: cast_nullable_to_non_nullable
as String,bio: freezed == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String?,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,bannerUrl: freezed == bannerUrl ? _self.bannerUrl : bannerUrl // ignore: cast_nullable_to_non_nullable
as String?,genres: null == genres ? _self.genres : genres // ignore: cast_nullable_to_non_nullable
as List<String>,countryCode: freezed == countryCode ? _self.countryCode : countryCode // ignore: cast_nullable_to_non_nullable
as String?,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,isVerified: null == isVerified ? _self.isVerified : isVerified // ignore: cast_nullable_to_non_nullable
as bool,isFeatured: null == isFeatured ? _self.isFeatured : isFeatured // ignore: cast_nullable_to_non_nullable
as bool,spotifyUrl: freezed == spotifyUrl ? _self.spotifyUrl : spotifyUrl // ignore: cast_nullable_to_non_nullable
as String?,appleMusicUrl: freezed == appleMusicUrl ? _self.appleMusicUrl : appleMusicUrl // ignore: cast_nullable_to_non_nullable
as String?,youtubeUrl: freezed == youtubeUrl ? _self.youtubeUrl : youtubeUrl // ignore: cast_nullable_to_non_nullable
as String?,instagramUrl: freezed == instagramUrl ? _self.instagramUrl : instagramUrl // ignore: cast_nullable_to_non_nullable
as String?,tiktokUrl: freezed == tiktokUrl ? _self.tiktokUrl : tiktokUrl // ignore: cast_nullable_to_non_nullable
as String?,websiteUrl: freezed == websiteUrl ? _self.websiteUrl : websiteUrl // ignore: cast_nullable_to_non_nullable
as String?,totalTracks: null == totalTracks ? _self.totalTracks : totalTracks // ignore: cast_nullable_to_non_nullable
as int,totalPlays: null == totalPlays ? _self.totalPlays : totalPlays // ignore: cast_nullable_to_non_nullable
as int,totalUsages: null == totalUsages ? _self.totalUsages : totalUsages // ignore: cast_nullable_to_non_nullable
as int,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [SoundArtist].
extension SoundArtistPatterns on SoundArtist {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SoundArtist value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SoundArtist() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SoundArtist value)  $default,){
final _that = this;
switch (_that) {
case _SoundArtist():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SoundArtist value)?  $default,){
final _that = this;
switch (_that) {
case _SoundArtist() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'user_id')  String userId, @JsonKey(name: 'artist_name')  String artistName,  String? bio, @JsonKey(name: 'avatar_url')  String? avatarUrl, @JsonKey(name: 'banner_url')  String? bannerUrl,  List<String> genres, @JsonKey(name: 'country_code')  String? countryCode,  String? city, @JsonKey(name: 'is_verified')  bool isVerified, @JsonKey(name: 'is_featured')  bool isFeatured, @JsonKey(name: 'spotify_url')  String? spotifyUrl, @JsonKey(name: 'apple_music_url')  String? appleMusicUrl, @JsonKey(name: 'youtube_url')  String? youtubeUrl, @JsonKey(name: 'instagram_url')  String? instagramUrl, @JsonKey(name: 'tiktok_url')  String? tiktokUrl, @JsonKey(name: 'website_url')  String? websiteUrl, @JsonKey(name: 'total_tracks')  int totalTracks, @JsonKey(name: 'total_plays')  int totalPlays, @JsonKey(name: 'total_usages')  int totalUsages, @JsonKey(name: 'created_at')  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SoundArtist() when $default != null:
return $default(_that.id,_that.userId,_that.artistName,_that.bio,_that.avatarUrl,_that.bannerUrl,_that.genres,_that.countryCode,_that.city,_that.isVerified,_that.isFeatured,_that.spotifyUrl,_that.appleMusicUrl,_that.youtubeUrl,_that.instagramUrl,_that.tiktokUrl,_that.websiteUrl,_that.totalTracks,_that.totalPlays,_that.totalUsages,_that.createdAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'user_id')  String userId, @JsonKey(name: 'artist_name')  String artistName,  String? bio, @JsonKey(name: 'avatar_url')  String? avatarUrl, @JsonKey(name: 'banner_url')  String? bannerUrl,  List<String> genres, @JsonKey(name: 'country_code')  String? countryCode,  String? city, @JsonKey(name: 'is_verified')  bool isVerified, @JsonKey(name: 'is_featured')  bool isFeatured, @JsonKey(name: 'spotify_url')  String? spotifyUrl, @JsonKey(name: 'apple_music_url')  String? appleMusicUrl, @JsonKey(name: 'youtube_url')  String? youtubeUrl, @JsonKey(name: 'instagram_url')  String? instagramUrl, @JsonKey(name: 'tiktok_url')  String? tiktokUrl, @JsonKey(name: 'website_url')  String? websiteUrl, @JsonKey(name: 'total_tracks')  int totalTracks, @JsonKey(name: 'total_plays')  int totalPlays, @JsonKey(name: 'total_usages')  int totalUsages, @JsonKey(name: 'created_at')  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _SoundArtist():
return $default(_that.id,_that.userId,_that.artistName,_that.bio,_that.avatarUrl,_that.bannerUrl,_that.genres,_that.countryCode,_that.city,_that.isVerified,_that.isFeatured,_that.spotifyUrl,_that.appleMusicUrl,_that.youtubeUrl,_that.instagramUrl,_that.tiktokUrl,_that.websiteUrl,_that.totalTracks,_that.totalPlays,_that.totalUsages,_that.createdAt);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'user_id')  String userId, @JsonKey(name: 'artist_name')  String artistName,  String? bio, @JsonKey(name: 'avatar_url')  String? avatarUrl, @JsonKey(name: 'banner_url')  String? bannerUrl,  List<String> genres, @JsonKey(name: 'country_code')  String? countryCode,  String? city, @JsonKey(name: 'is_verified')  bool isVerified, @JsonKey(name: 'is_featured')  bool isFeatured, @JsonKey(name: 'spotify_url')  String? spotifyUrl, @JsonKey(name: 'apple_music_url')  String? appleMusicUrl, @JsonKey(name: 'youtube_url')  String? youtubeUrl, @JsonKey(name: 'instagram_url')  String? instagramUrl, @JsonKey(name: 'tiktok_url')  String? tiktokUrl, @JsonKey(name: 'website_url')  String? websiteUrl, @JsonKey(name: 'total_tracks')  int totalTracks, @JsonKey(name: 'total_plays')  int totalPlays, @JsonKey(name: 'total_usages')  int totalUsages, @JsonKey(name: 'created_at')  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _SoundArtist() when $default != null:
return $default(_that.id,_that.userId,_that.artistName,_that.bio,_that.avatarUrl,_that.bannerUrl,_that.genres,_that.countryCode,_that.city,_that.isVerified,_that.isFeatured,_that.spotifyUrl,_that.appleMusicUrl,_that.youtubeUrl,_that.instagramUrl,_that.tiktokUrl,_that.websiteUrl,_that.totalTracks,_that.totalPlays,_that.totalUsages,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SoundArtist implements SoundArtist {
  const _SoundArtist({required this.id, @JsonKey(name: 'user_id') required this.userId, @JsonKey(name: 'artist_name') required this.artistName, this.bio, @JsonKey(name: 'avatar_url') this.avatarUrl, @JsonKey(name: 'banner_url') this.bannerUrl, final  List<String> genres = const [], @JsonKey(name: 'country_code') this.countryCode, this.city, @JsonKey(name: 'is_verified') this.isVerified = false, @JsonKey(name: 'is_featured') this.isFeatured = false, @JsonKey(name: 'spotify_url') this.spotifyUrl, @JsonKey(name: 'apple_music_url') this.appleMusicUrl, @JsonKey(name: 'youtube_url') this.youtubeUrl, @JsonKey(name: 'instagram_url') this.instagramUrl, @JsonKey(name: 'tiktok_url') this.tiktokUrl, @JsonKey(name: 'website_url') this.websiteUrl, @JsonKey(name: 'total_tracks') this.totalTracks = 0, @JsonKey(name: 'total_plays') this.totalPlays = 0, @JsonKey(name: 'total_usages') this.totalUsages = 0, @JsonKey(name: 'created_at') this.createdAt}): _genres = genres;
  factory _SoundArtist.fromJson(Map<String, dynamic> json) => _$SoundArtistFromJson(json);

@override final  String id;
@override@JsonKey(name: 'user_id') final  String userId;
@override@JsonKey(name: 'artist_name') final  String artistName;
@override final  String? bio;
@override@JsonKey(name: 'avatar_url') final  String? avatarUrl;
@override@JsonKey(name: 'banner_url') final  String? bannerUrl;
 final  List<String> _genres;
@override@JsonKey() List<String> get genres {
  if (_genres is EqualUnmodifiableListView) return _genres;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_genres);
}

@override@JsonKey(name: 'country_code') final  String? countryCode;
@override final  String? city;
@override@JsonKey(name: 'is_verified') final  bool isVerified;
@override@JsonKey(name: 'is_featured') final  bool isFeatured;
@override@JsonKey(name: 'spotify_url') final  String? spotifyUrl;
@override@JsonKey(name: 'apple_music_url') final  String? appleMusicUrl;
@override@JsonKey(name: 'youtube_url') final  String? youtubeUrl;
@override@JsonKey(name: 'instagram_url') final  String? instagramUrl;
@override@JsonKey(name: 'tiktok_url') final  String? tiktokUrl;
@override@JsonKey(name: 'website_url') final  String? websiteUrl;
@override@JsonKey(name: 'total_tracks') final  int totalTracks;
@override@JsonKey(name: 'total_plays') final  int totalPlays;
@override@JsonKey(name: 'total_usages') final  int totalUsages;
@override@JsonKey(name: 'created_at') final  DateTime? createdAt;

/// Create a copy of SoundArtist
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SoundArtistCopyWith<_SoundArtist> get copyWith => __$SoundArtistCopyWithImpl<_SoundArtist>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SoundArtistToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SoundArtist&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.artistName, artistName) || other.artistName == artistName)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.bannerUrl, bannerUrl) || other.bannerUrl == bannerUrl)&&const DeepCollectionEquality().equals(other._genres, _genres)&&(identical(other.countryCode, countryCode) || other.countryCode == countryCode)&&(identical(other.city, city) || other.city == city)&&(identical(other.isVerified, isVerified) || other.isVerified == isVerified)&&(identical(other.isFeatured, isFeatured) || other.isFeatured == isFeatured)&&(identical(other.spotifyUrl, spotifyUrl) || other.spotifyUrl == spotifyUrl)&&(identical(other.appleMusicUrl, appleMusicUrl) || other.appleMusicUrl == appleMusicUrl)&&(identical(other.youtubeUrl, youtubeUrl) || other.youtubeUrl == youtubeUrl)&&(identical(other.instagramUrl, instagramUrl) || other.instagramUrl == instagramUrl)&&(identical(other.tiktokUrl, tiktokUrl) || other.tiktokUrl == tiktokUrl)&&(identical(other.websiteUrl, websiteUrl) || other.websiteUrl == websiteUrl)&&(identical(other.totalTracks, totalTracks) || other.totalTracks == totalTracks)&&(identical(other.totalPlays, totalPlays) || other.totalPlays == totalPlays)&&(identical(other.totalUsages, totalUsages) || other.totalUsages == totalUsages)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,userId,artistName,bio,avatarUrl,bannerUrl,const DeepCollectionEquality().hash(_genres),countryCode,city,isVerified,isFeatured,spotifyUrl,appleMusicUrl,youtubeUrl,instagramUrl,tiktokUrl,websiteUrl,totalTracks,totalPlays,totalUsages,createdAt]);

@override
String toString() {
  return 'SoundArtist(id: $id, userId: $userId, artistName: $artistName, bio: $bio, avatarUrl: $avatarUrl, bannerUrl: $bannerUrl, genres: $genres, countryCode: $countryCode, city: $city, isVerified: $isVerified, isFeatured: $isFeatured, spotifyUrl: $spotifyUrl, appleMusicUrl: $appleMusicUrl, youtubeUrl: $youtubeUrl, instagramUrl: $instagramUrl, tiktokUrl: $tiktokUrl, websiteUrl: $websiteUrl, totalTracks: $totalTracks, totalPlays: $totalPlays, totalUsages: $totalUsages, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$SoundArtistCopyWith<$Res> implements $SoundArtistCopyWith<$Res> {
  factory _$SoundArtistCopyWith(_SoundArtist value, $Res Function(_SoundArtist) _then) = __$SoundArtistCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'user_id') String userId,@JsonKey(name: 'artist_name') String artistName, String? bio,@JsonKey(name: 'avatar_url') String? avatarUrl,@JsonKey(name: 'banner_url') String? bannerUrl, List<String> genres,@JsonKey(name: 'country_code') String? countryCode, String? city,@JsonKey(name: 'is_verified') bool isVerified,@JsonKey(name: 'is_featured') bool isFeatured,@JsonKey(name: 'spotify_url') String? spotifyUrl,@JsonKey(name: 'apple_music_url') String? appleMusicUrl,@JsonKey(name: 'youtube_url') String? youtubeUrl,@JsonKey(name: 'instagram_url') String? instagramUrl,@JsonKey(name: 'tiktok_url') String? tiktokUrl,@JsonKey(name: 'website_url') String? websiteUrl,@JsonKey(name: 'total_tracks') int totalTracks,@JsonKey(name: 'total_plays') int totalPlays,@JsonKey(name: 'total_usages') int totalUsages,@JsonKey(name: 'created_at') DateTime? createdAt
});




}
/// @nodoc
class __$SoundArtistCopyWithImpl<$Res>
    implements _$SoundArtistCopyWith<$Res> {
  __$SoundArtistCopyWithImpl(this._self, this._then);

  final _SoundArtist _self;
  final $Res Function(_SoundArtist) _then;

/// Create a copy of SoundArtist
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? artistName = null,Object? bio = freezed,Object? avatarUrl = freezed,Object? bannerUrl = freezed,Object? genres = null,Object? countryCode = freezed,Object? city = freezed,Object? isVerified = null,Object? isFeatured = null,Object? spotifyUrl = freezed,Object? appleMusicUrl = freezed,Object? youtubeUrl = freezed,Object? instagramUrl = freezed,Object? tiktokUrl = freezed,Object? websiteUrl = freezed,Object? totalTracks = null,Object? totalPlays = null,Object? totalUsages = null,Object? createdAt = freezed,}) {
  return _then(_SoundArtist(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,artistName: null == artistName ? _self.artistName : artistName // ignore: cast_nullable_to_non_nullable
as String,bio: freezed == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String?,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,bannerUrl: freezed == bannerUrl ? _self.bannerUrl : bannerUrl // ignore: cast_nullable_to_non_nullable
as String?,genres: null == genres ? _self._genres : genres // ignore: cast_nullable_to_non_nullable
as List<String>,countryCode: freezed == countryCode ? _self.countryCode : countryCode // ignore: cast_nullable_to_non_nullable
as String?,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,isVerified: null == isVerified ? _self.isVerified : isVerified // ignore: cast_nullable_to_non_nullable
as bool,isFeatured: null == isFeatured ? _self.isFeatured : isFeatured // ignore: cast_nullable_to_non_nullable
as bool,spotifyUrl: freezed == spotifyUrl ? _self.spotifyUrl : spotifyUrl // ignore: cast_nullable_to_non_nullable
as String?,appleMusicUrl: freezed == appleMusicUrl ? _self.appleMusicUrl : appleMusicUrl // ignore: cast_nullable_to_non_nullable
as String?,youtubeUrl: freezed == youtubeUrl ? _self.youtubeUrl : youtubeUrl // ignore: cast_nullable_to_non_nullable
as String?,instagramUrl: freezed == instagramUrl ? _self.instagramUrl : instagramUrl // ignore: cast_nullable_to_non_nullable
as String?,tiktokUrl: freezed == tiktokUrl ? _self.tiktokUrl : tiktokUrl // ignore: cast_nullable_to_non_nullable
as String?,websiteUrl: freezed == websiteUrl ? _self.websiteUrl : websiteUrl // ignore: cast_nullable_to_non_nullable
as String?,totalTracks: null == totalTracks ? _self.totalTracks : totalTracks // ignore: cast_nullable_to_non_nullable
as int,totalPlays: null == totalPlays ? _self.totalPlays : totalPlays // ignore: cast_nullable_to_non_nullable
as int,totalUsages: null == totalUsages ? _self.totalUsages : totalUsages // ignore: cast_nullable_to_non_nullable
as int,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$Sound {

 String get id;@JsonKey(name: 'artist_id') String get artistId; String get title; String? get slug;@JsonKey(name: 'audio_url') String get audioUrl;@JsonKey(name: 'cover_url') String? get coverUrl;@JsonKey(name: 'waveform_url') String? get waveformUrl;@JsonKey(name: 'duration_ms') int get durationMs; int? get bpm; String? get genre; String? get subgenre; String? get mood; String? get language;@JsonKey(name: 'album_name') String? get albumName;@JsonKey(name: 'license_type') String get licenseType;@JsonKey(name: 'allow_trim') bool get allowTrim;@JsonKey(name: 'trim_start_ms') int get trimStartMs;@JsonKey(name: 'trim_end_ms') int? get trimEndMs;@JsonKey(name: 'play_count') int get playCount;@JsonKey(name: 'usage_count') int get usageCount;@JsonKey(name: 'save_count') int get saveCount; String get status;@JsonKey(name: 'is_saved') bool get isSaved; SoundArtist? get artist;@JsonKey(name: 'created_at') DateTime? get createdAt;// Volume de reprodução (0.0-1.0). Campo SOMENTE de UI/player — o
// catálogo do backend não retorna isso; é preenchido quando um
// `SoundPreview` (post/story) é convertido para `Sound` reproduzível
// via `toPlayableSound()`, refletindo `sound_volume` gravado no
// conteúdo. Ausente no JSON do catálogo → usa o default 1.0.
 double get volume;
/// Create a copy of Sound
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SoundCopyWith<Sound> get copyWith => _$SoundCopyWithImpl<Sound>(this as Sound, _$identity);

  /// Serializes this Sound to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Sound&&(identical(other.id, id) || other.id == id)&&(identical(other.artistId, artistId) || other.artistId == artistId)&&(identical(other.title, title) || other.title == title)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.audioUrl, audioUrl) || other.audioUrl == audioUrl)&&(identical(other.coverUrl, coverUrl) || other.coverUrl == coverUrl)&&(identical(other.waveformUrl, waveformUrl) || other.waveformUrl == waveformUrl)&&(identical(other.durationMs, durationMs) || other.durationMs == durationMs)&&(identical(other.bpm, bpm) || other.bpm == bpm)&&(identical(other.genre, genre) || other.genre == genre)&&(identical(other.subgenre, subgenre) || other.subgenre == subgenre)&&(identical(other.mood, mood) || other.mood == mood)&&(identical(other.language, language) || other.language == language)&&(identical(other.albumName, albumName) || other.albumName == albumName)&&(identical(other.licenseType, licenseType) || other.licenseType == licenseType)&&(identical(other.allowTrim, allowTrim) || other.allowTrim == allowTrim)&&(identical(other.trimStartMs, trimStartMs) || other.trimStartMs == trimStartMs)&&(identical(other.trimEndMs, trimEndMs) || other.trimEndMs == trimEndMs)&&(identical(other.playCount, playCount) || other.playCount == playCount)&&(identical(other.usageCount, usageCount) || other.usageCount == usageCount)&&(identical(other.saveCount, saveCount) || other.saveCount == saveCount)&&(identical(other.status, status) || other.status == status)&&(identical(other.isSaved, isSaved) || other.isSaved == isSaved)&&(identical(other.artist, artist) || other.artist == artist)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.volume, volume) || other.volume == volume));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,artistId,title,slug,audioUrl,coverUrl,waveformUrl,durationMs,bpm,genre,subgenre,mood,language,albumName,licenseType,allowTrim,trimStartMs,trimEndMs,playCount,usageCount,saveCount,status,isSaved,artist,createdAt,volume]);

@override
String toString() {
  return 'Sound(id: $id, artistId: $artistId, title: $title, slug: $slug, audioUrl: $audioUrl, coverUrl: $coverUrl, waveformUrl: $waveformUrl, durationMs: $durationMs, bpm: $bpm, genre: $genre, subgenre: $subgenre, mood: $mood, language: $language, albumName: $albumName, licenseType: $licenseType, allowTrim: $allowTrim, trimStartMs: $trimStartMs, trimEndMs: $trimEndMs, playCount: $playCount, usageCount: $usageCount, saveCount: $saveCount, status: $status, isSaved: $isSaved, artist: $artist, createdAt: $createdAt, volume: $volume)';
}


}

/// @nodoc
abstract mixin class $SoundCopyWith<$Res>  {
  factory $SoundCopyWith(Sound value, $Res Function(Sound) _then) = _$SoundCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'artist_id') String artistId, String title, String? slug,@JsonKey(name: 'audio_url') String audioUrl,@JsonKey(name: 'cover_url') String? coverUrl,@JsonKey(name: 'waveform_url') String? waveformUrl,@JsonKey(name: 'duration_ms') int durationMs, int? bpm, String? genre, String? subgenre, String? mood, String? language,@JsonKey(name: 'album_name') String? albumName,@JsonKey(name: 'license_type') String licenseType,@JsonKey(name: 'allow_trim') bool allowTrim,@JsonKey(name: 'trim_start_ms') int trimStartMs,@JsonKey(name: 'trim_end_ms') int? trimEndMs,@JsonKey(name: 'play_count') int playCount,@JsonKey(name: 'usage_count') int usageCount,@JsonKey(name: 'save_count') int saveCount, String status,@JsonKey(name: 'is_saved') bool isSaved, SoundArtist? artist,@JsonKey(name: 'created_at') DateTime? createdAt, double volume
});


$SoundArtistCopyWith<$Res>? get artist;

}
/// @nodoc
class _$SoundCopyWithImpl<$Res>
    implements $SoundCopyWith<$Res> {
  _$SoundCopyWithImpl(this._self, this._then);

  final Sound _self;
  final $Res Function(Sound) _then;

/// Create a copy of Sound
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? artistId = null,Object? title = null,Object? slug = freezed,Object? audioUrl = null,Object? coverUrl = freezed,Object? waveformUrl = freezed,Object? durationMs = null,Object? bpm = freezed,Object? genre = freezed,Object? subgenre = freezed,Object? mood = freezed,Object? language = freezed,Object? albumName = freezed,Object? licenseType = null,Object? allowTrim = null,Object? trimStartMs = null,Object? trimEndMs = freezed,Object? playCount = null,Object? usageCount = null,Object? saveCount = null,Object? status = null,Object? isSaved = null,Object? artist = freezed,Object? createdAt = freezed,Object? volume = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,artistId: null == artistId ? _self.artistId : artistId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,slug: freezed == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String?,audioUrl: null == audioUrl ? _self.audioUrl : audioUrl // ignore: cast_nullable_to_non_nullable
as String,coverUrl: freezed == coverUrl ? _self.coverUrl : coverUrl // ignore: cast_nullable_to_non_nullable
as String?,waveformUrl: freezed == waveformUrl ? _self.waveformUrl : waveformUrl // ignore: cast_nullable_to_non_nullable
as String?,durationMs: null == durationMs ? _self.durationMs : durationMs // ignore: cast_nullable_to_non_nullable
as int,bpm: freezed == bpm ? _self.bpm : bpm // ignore: cast_nullable_to_non_nullable
as int?,genre: freezed == genre ? _self.genre : genre // ignore: cast_nullable_to_non_nullable
as String?,subgenre: freezed == subgenre ? _self.subgenre : subgenre // ignore: cast_nullable_to_non_nullable
as String?,mood: freezed == mood ? _self.mood : mood // ignore: cast_nullable_to_non_nullable
as String?,language: freezed == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String?,albumName: freezed == albumName ? _self.albumName : albumName // ignore: cast_nullable_to_non_nullable
as String?,licenseType: null == licenseType ? _self.licenseType : licenseType // ignore: cast_nullable_to_non_nullable
as String,allowTrim: null == allowTrim ? _self.allowTrim : allowTrim // ignore: cast_nullable_to_non_nullable
as bool,trimStartMs: null == trimStartMs ? _self.trimStartMs : trimStartMs // ignore: cast_nullable_to_non_nullable
as int,trimEndMs: freezed == trimEndMs ? _self.trimEndMs : trimEndMs // ignore: cast_nullable_to_non_nullable
as int?,playCount: null == playCount ? _self.playCount : playCount // ignore: cast_nullable_to_non_nullable
as int,usageCount: null == usageCount ? _self.usageCount : usageCount // ignore: cast_nullable_to_non_nullable
as int,saveCount: null == saveCount ? _self.saveCount : saveCount // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,isSaved: null == isSaved ? _self.isSaved : isSaved // ignore: cast_nullable_to_non_nullable
as bool,artist: freezed == artist ? _self.artist : artist // ignore: cast_nullable_to_non_nullable
as SoundArtist?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,volume: null == volume ? _self.volume : volume // ignore: cast_nullable_to_non_nullable
as double,
  ));
}
/// Create a copy of Sound
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SoundArtistCopyWith<$Res>? get artist {
    if (_self.artist == null) {
    return null;
  }

  return $SoundArtistCopyWith<$Res>(_self.artist!, (value) {
    return _then(_self.copyWith(artist: value));
  });
}
}


/// Adds pattern-matching-related methods to [Sound].
extension SoundPatterns on Sound {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Sound value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Sound() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Sound value)  $default,){
final _that = this;
switch (_that) {
case _Sound():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Sound value)?  $default,){
final _that = this;
switch (_that) {
case _Sound() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'artist_id')  String artistId,  String title,  String? slug, @JsonKey(name: 'audio_url')  String audioUrl, @JsonKey(name: 'cover_url')  String? coverUrl, @JsonKey(name: 'waveform_url')  String? waveformUrl, @JsonKey(name: 'duration_ms')  int durationMs,  int? bpm,  String? genre,  String? subgenre,  String? mood,  String? language, @JsonKey(name: 'album_name')  String? albumName, @JsonKey(name: 'license_type')  String licenseType, @JsonKey(name: 'allow_trim')  bool allowTrim, @JsonKey(name: 'trim_start_ms')  int trimStartMs, @JsonKey(name: 'trim_end_ms')  int? trimEndMs, @JsonKey(name: 'play_count')  int playCount, @JsonKey(name: 'usage_count')  int usageCount, @JsonKey(name: 'save_count')  int saveCount,  String status, @JsonKey(name: 'is_saved')  bool isSaved,  SoundArtist? artist, @JsonKey(name: 'created_at')  DateTime? createdAt,  double volume)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Sound() when $default != null:
return $default(_that.id,_that.artistId,_that.title,_that.slug,_that.audioUrl,_that.coverUrl,_that.waveformUrl,_that.durationMs,_that.bpm,_that.genre,_that.subgenre,_that.mood,_that.language,_that.albumName,_that.licenseType,_that.allowTrim,_that.trimStartMs,_that.trimEndMs,_that.playCount,_that.usageCount,_that.saveCount,_that.status,_that.isSaved,_that.artist,_that.createdAt,_that.volume);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'artist_id')  String artistId,  String title,  String? slug, @JsonKey(name: 'audio_url')  String audioUrl, @JsonKey(name: 'cover_url')  String? coverUrl, @JsonKey(name: 'waveform_url')  String? waveformUrl, @JsonKey(name: 'duration_ms')  int durationMs,  int? bpm,  String? genre,  String? subgenre,  String? mood,  String? language, @JsonKey(name: 'album_name')  String? albumName, @JsonKey(name: 'license_type')  String licenseType, @JsonKey(name: 'allow_trim')  bool allowTrim, @JsonKey(name: 'trim_start_ms')  int trimStartMs, @JsonKey(name: 'trim_end_ms')  int? trimEndMs, @JsonKey(name: 'play_count')  int playCount, @JsonKey(name: 'usage_count')  int usageCount, @JsonKey(name: 'save_count')  int saveCount,  String status, @JsonKey(name: 'is_saved')  bool isSaved,  SoundArtist? artist, @JsonKey(name: 'created_at')  DateTime? createdAt,  double volume)  $default,) {final _that = this;
switch (_that) {
case _Sound():
return $default(_that.id,_that.artistId,_that.title,_that.slug,_that.audioUrl,_that.coverUrl,_that.waveformUrl,_that.durationMs,_that.bpm,_that.genre,_that.subgenre,_that.mood,_that.language,_that.albumName,_that.licenseType,_that.allowTrim,_that.trimStartMs,_that.trimEndMs,_that.playCount,_that.usageCount,_that.saveCount,_that.status,_that.isSaved,_that.artist,_that.createdAt,_that.volume);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'artist_id')  String artistId,  String title,  String? slug, @JsonKey(name: 'audio_url')  String audioUrl, @JsonKey(name: 'cover_url')  String? coverUrl, @JsonKey(name: 'waveform_url')  String? waveformUrl, @JsonKey(name: 'duration_ms')  int durationMs,  int? bpm,  String? genre,  String? subgenre,  String? mood,  String? language, @JsonKey(name: 'album_name')  String? albumName, @JsonKey(name: 'license_type')  String licenseType, @JsonKey(name: 'allow_trim')  bool allowTrim, @JsonKey(name: 'trim_start_ms')  int trimStartMs, @JsonKey(name: 'trim_end_ms')  int? trimEndMs, @JsonKey(name: 'play_count')  int playCount, @JsonKey(name: 'usage_count')  int usageCount, @JsonKey(name: 'save_count')  int saveCount,  String status, @JsonKey(name: 'is_saved')  bool isSaved,  SoundArtist? artist, @JsonKey(name: 'created_at')  DateTime? createdAt,  double volume)?  $default,) {final _that = this;
switch (_that) {
case _Sound() when $default != null:
return $default(_that.id,_that.artistId,_that.title,_that.slug,_that.audioUrl,_that.coverUrl,_that.waveformUrl,_that.durationMs,_that.bpm,_that.genre,_that.subgenre,_that.mood,_that.language,_that.albumName,_that.licenseType,_that.allowTrim,_that.trimStartMs,_that.trimEndMs,_that.playCount,_that.usageCount,_that.saveCount,_that.status,_that.isSaved,_that.artist,_that.createdAt,_that.volume);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Sound implements Sound {
  const _Sound({required this.id, @JsonKey(name: 'artist_id') required this.artistId, required this.title, this.slug, @JsonKey(name: 'audio_url') required this.audioUrl, @JsonKey(name: 'cover_url') this.coverUrl, @JsonKey(name: 'waveform_url') this.waveformUrl, @JsonKey(name: 'duration_ms') this.durationMs = 0, this.bpm, this.genre, this.subgenre, this.mood, this.language, @JsonKey(name: 'album_name') this.albumName, @JsonKey(name: 'license_type') this.licenseType = 'brawe_standard', @JsonKey(name: 'allow_trim') this.allowTrim = true, @JsonKey(name: 'trim_start_ms') this.trimStartMs = 0, @JsonKey(name: 'trim_end_ms') this.trimEndMs, @JsonKey(name: 'play_count') this.playCount = 0, @JsonKey(name: 'usage_count') this.usageCount = 0, @JsonKey(name: 'save_count') this.saveCount = 0, this.status = 'pending', @JsonKey(name: 'is_saved') this.isSaved = false, this.artist, @JsonKey(name: 'created_at') this.createdAt, this.volume = 1.0});
  factory _Sound.fromJson(Map<String, dynamic> json) => _$SoundFromJson(json);

@override final  String id;
@override@JsonKey(name: 'artist_id') final  String artistId;
@override final  String title;
@override final  String? slug;
@override@JsonKey(name: 'audio_url') final  String audioUrl;
@override@JsonKey(name: 'cover_url') final  String? coverUrl;
@override@JsonKey(name: 'waveform_url') final  String? waveformUrl;
@override@JsonKey(name: 'duration_ms') final  int durationMs;
@override final  int? bpm;
@override final  String? genre;
@override final  String? subgenre;
@override final  String? mood;
@override final  String? language;
@override@JsonKey(name: 'album_name') final  String? albumName;
@override@JsonKey(name: 'license_type') final  String licenseType;
@override@JsonKey(name: 'allow_trim') final  bool allowTrim;
@override@JsonKey(name: 'trim_start_ms') final  int trimStartMs;
@override@JsonKey(name: 'trim_end_ms') final  int? trimEndMs;
@override@JsonKey(name: 'play_count') final  int playCount;
@override@JsonKey(name: 'usage_count') final  int usageCount;
@override@JsonKey(name: 'save_count') final  int saveCount;
@override@JsonKey() final  String status;
@override@JsonKey(name: 'is_saved') final  bool isSaved;
@override final  SoundArtist? artist;
@override@JsonKey(name: 'created_at') final  DateTime? createdAt;
// Volume de reprodução (0.0-1.0). Campo SOMENTE de UI/player — o
// catálogo do backend não retorna isso; é preenchido quando um
// `SoundPreview` (post/story) é convertido para `Sound` reproduzível
// via `toPlayableSound()`, refletindo `sound_volume` gravado no
// conteúdo. Ausente no JSON do catálogo → usa o default 1.0.
@override@JsonKey() final  double volume;

/// Create a copy of Sound
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SoundCopyWith<_Sound> get copyWith => __$SoundCopyWithImpl<_Sound>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SoundToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Sound&&(identical(other.id, id) || other.id == id)&&(identical(other.artistId, artistId) || other.artistId == artistId)&&(identical(other.title, title) || other.title == title)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.audioUrl, audioUrl) || other.audioUrl == audioUrl)&&(identical(other.coverUrl, coverUrl) || other.coverUrl == coverUrl)&&(identical(other.waveformUrl, waveformUrl) || other.waveformUrl == waveformUrl)&&(identical(other.durationMs, durationMs) || other.durationMs == durationMs)&&(identical(other.bpm, bpm) || other.bpm == bpm)&&(identical(other.genre, genre) || other.genre == genre)&&(identical(other.subgenre, subgenre) || other.subgenre == subgenre)&&(identical(other.mood, mood) || other.mood == mood)&&(identical(other.language, language) || other.language == language)&&(identical(other.albumName, albumName) || other.albumName == albumName)&&(identical(other.licenseType, licenseType) || other.licenseType == licenseType)&&(identical(other.allowTrim, allowTrim) || other.allowTrim == allowTrim)&&(identical(other.trimStartMs, trimStartMs) || other.trimStartMs == trimStartMs)&&(identical(other.trimEndMs, trimEndMs) || other.trimEndMs == trimEndMs)&&(identical(other.playCount, playCount) || other.playCount == playCount)&&(identical(other.usageCount, usageCount) || other.usageCount == usageCount)&&(identical(other.saveCount, saveCount) || other.saveCount == saveCount)&&(identical(other.status, status) || other.status == status)&&(identical(other.isSaved, isSaved) || other.isSaved == isSaved)&&(identical(other.artist, artist) || other.artist == artist)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.volume, volume) || other.volume == volume));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,artistId,title,slug,audioUrl,coverUrl,waveformUrl,durationMs,bpm,genre,subgenre,mood,language,albumName,licenseType,allowTrim,trimStartMs,trimEndMs,playCount,usageCount,saveCount,status,isSaved,artist,createdAt,volume]);

@override
String toString() {
  return 'Sound(id: $id, artistId: $artistId, title: $title, slug: $slug, audioUrl: $audioUrl, coverUrl: $coverUrl, waveformUrl: $waveformUrl, durationMs: $durationMs, bpm: $bpm, genre: $genre, subgenre: $subgenre, mood: $mood, language: $language, albumName: $albumName, licenseType: $licenseType, allowTrim: $allowTrim, trimStartMs: $trimStartMs, trimEndMs: $trimEndMs, playCount: $playCount, usageCount: $usageCount, saveCount: $saveCount, status: $status, isSaved: $isSaved, artist: $artist, createdAt: $createdAt, volume: $volume)';
}


}

/// @nodoc
abstract mixin class _$SoundCopyWith<$Res> implements $SoundCopyWith<$Res> {
  factory _$SoundCopyWith(_Sound value, $Res Function(_Sound) _then) = __$SoundCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'artist_id') String artistId, String title, String? slug,@JsonKey(name: 'audio_url') String audioUrl,@JsonKey(name: 'cover_url') String? coverUrl,@JsonKey(name: 'waveform_url') String? waveformUrl,@JsonKey(name: 'duration_ms') int durationMs, int? bpm, String? genre, String? subgenre, String? mood, String? language,@JsonKey(name: 'album_name') String? albumName,@JsonKey(name: 'license_type') String licenseType,@JsonKey(name: 'allow_trim') bool allowTrim,@JsonKey(name: 'trim_start_ms') int trimStartMs,@JsonKey(name: 'trim_end_ms') int? trimEndMs,@JsonKey(name: 'play_count') int playCount,@JsonKey(name: 'usage_count') int usageCount,@JsonKey(name: 'save_count') int saveCount, String status,@JsonKey(name: 'is_saved') bool isSaved, SoundArtist? artist,@JsonKey(name: 'created_at') DateTime? createdAt, double volume
});


@override $SoundArtistCopyWith<$Res>? get artist;

}
/// @nodoc
class __$SoundCopyWithImpl<$Res>
    implements _$SoundCopyWith<$Res> {
  __$SoundCopyWithImpl(this._self, this._then);

  final _Sound _self;
  final $Res Function(_Sound) _then;

/// Create a copy of Sound
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? artistId = null,Object? title = null,Object? slug = freezed,Object? audioUrl = null,Object? coverUrl = freezed,Object? waveformUrl = freezed,Object? durationMs = null,Object? bpm = freezed,Object? genre = freezed,Object? subgenre = freezed,Object? mood = freezed,Object? language = freezed,Object? albumName = freezed,Object? licenseType = null,Object? allowTrim = null,Object? trimStartMs = null,Object? trimEndMs = freezed,Object? playCount = null,Object? usageCount = null,Object? saveCount = null,Object? status = null,Object? isSaved = null,Object? artist = freezed,Object? createdAt = freezed,Object? volume = null,}) {
  return _then(_Sound(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,artistId: null == artistId ? _self.artistId : artistId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,slug: freezed == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String?,audioUrl: null == audioUrl ? _self.audioUrl : audioUrl // ignore: cast_nullable_to_non_nullable
as String,coverUrl: freezed == coverUrl ? _self.coverUrl : coverUrl // ignore: cast_nullable_to_non_nullable
as String?,waveformUrl: freezed == waveformUrl ? _self.waveformUrl : waveformUrl // ignore: cast_nullable_to_non_nullable
as String?,durationMs: null == durationMs ? _self.durationMs : durationMs // ignore: cast_nullable_to_non_nullable
as int,bpm: freezed == bpm ? _self.bpm : bpm // ignore: cast_nullable_to_non_nullable
as int?,genre: freezed == genre ? _self.genre : genre // ignore: cast_nullable_to_non_nullable
as String?,subgenre: freezed == subgenre ? _self.subgenre : subgenre // ignore: cast_nullable_to_non_nullable
as String?,mood: freezed == mood ? _self.mood : mood // ignore: cast_nullable_to_non_nullable
as String?,language: freezed == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String?,albumName: freezed == albumName ? _self.albumName : albumName // ignore: cast_nullable_to_non_nullable
as String?,licenseType: null == licenseType ? _self.licenseType : licenseType // ignore: cast_nullable_to_non_nullable
as String,allowTrim: null == allowTrim ? _self.allowTrim : allowTrim // ignore: cast_nullable_to_non_nullable
as bool,trimStartMs: null == trimStartMs ? _self.trimStartMs : trimStartMs // ignore: cast_nullable_to_non_nullable
as int,trimEndMs: freezed == trimEndMs ? _self.trimEndMs : trimEndMs // ignore: cast_nullable_to_non_nullable
as int?,playCount: null == playCount ? _self.playCount : playCount // ignore: cast_nullable_to_non_nullable
as int,usageCount: null == usageCount ? _self.usageCount : usageCount // ignore: cast_nullable_to_non_nullable
as int,saveCount: null == saveCount ? _self.saveCount : saveCount // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,isSaved: null == isSaved ? _self.isSaved : isSaved // ignore: cast_nullable_to_non_nullable
as bool,artist: freezed == artist ? _self.artist : artist // ignore: cast_nullable_to_non_nullable
as SoundArtist?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,volume: null == volume ? _self.volume : volume // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

/// Create a copy of Sound
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SoundArtistCopyWith<$Res>? get artist {
    if (_self.artist == null) {
    return null;
  }

  return $SoundArtistCopyWith<$Res>(_self.artist!, (value) {
    return _then(_self.copyWith(artist: value));
  });
}
}

// dart format on
