// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'profile.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Profile {

 String get id;@JsonKey(name: 'display_name') String? get displayName; String? get username; String? get bio;@JsonKey(name: 'avatar_url') String? get avatarUrl;@JsonKey(name: 'banner_url') String? get bannerUrl;@JsonKey(name: 'is_verified') bool get isVerified;@JsonKey(name: 'social_links') Map<String, String>? get socialLinks;@JsonKey(name: 'account_type') AccountType get accountType;// Campos de artista — populados quando accountType == musician
@JsonKey(name: 'artist_id') String? get artistId;@JsonKey(name: 'artist_name') String? get artistName;@JsonKey(name: 'artist_genres') List<String>? get artistGenres;@JsonKey(name: 'artist_city') String? get artistCity;@JsonKey(name: 'artist_country') String? get artistCountry;@JsonKey(name: 'artist_total_tracks') int get artistTotalTracks;@JsonKey(name: 'artist_total_plays') int get artistTotalPlays;// Data de criação do perfil
@JsonKey(name: 'created_at') String? get createdAt;
/// Create a copy of Profile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProfileCopyWith<Profile> get copyWith => _$ProfileCopyWithImpl<Profile>(this as Profile, _$identity);

  /// Serializes this Profile to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Profile&&(identical(other.id, id) || other.id == id)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.username, username) || other.username == username)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.bannerUrl, bannerUrl) || other.bannerUrl == bannerUrl)&&(identical(other.isVerified, isVerified) || other.isVerified == isVerified)&&const DeepCollectionEquality().equals(other.socialLinks, socialLinks)&&(identical(other.accountType, accountType) || other.accountType == accountType)&&(identical(other.artistId, artistId) || other.artistId == artistId)&&(identical(other.artistName, artistName) || other.artistName == artistName)&&const DeepCollectionEquality().equals(other.artistGenres, artistGenres)&&(identical(other.artistCity, artistCity) || other.artistCity == artistCity)&&(identical(other.artistCountry, artistCountry) || other.artistCountry == artistCountry)&&(identical(other.artistTotalTracks, artistTotalTracks) || other.artistTotalTracks == artistTotalTracks)&&(identical(other.artistTotalPlays, artistTotalPlays) || other.artistTotalPlays == artistTotalPlays)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,displayName,username,bio,avatarUrl,bannerUrl,isVerified,const DeepCollectionEquality().hash(socialLinks),accountType,artistId,artistName,const DeepCollectionEquality().hash(artistGenres),artistCity,artistCountry,artistTotalTracks,artistTotalPlays,createdAt);

@override
String toString() {
  return 'Profile(id: $id, displayName: $displayName, username: $username, bio: $bio, avatarUrl: $avatarUrl, bannerUrl: $bannerUrl, isVerified: $isVerified, socialLinks: $socialLinks, accountType: $accountType, artistId: $artistId, artistName: $artistName, artistGenres: $artistGenres, artistCity: $artistCity, artistCountry: $artistCountry, artistTotalTracks: $artistTotalTracks, artistTotalPlays: $artistTotalPlays, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $ProfileCopyWith<$Res>  {
  factory $ProfileCopyWith(Profile value, $Res Function(Profile) _then) = _$ProfileCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'display_name') String? displayName, String? username, String? bio,@JsonKey(name: 'avatar_url') String? avatarUrl,@JsonKey(name: 'banner_url') String? bannerUrl,@JsonKey(name: 'is_verified') bool isVerified,@JsonKey(name: 'social_links') Map<String, String>? socialLinks,@JsonKey(name: 'account_type') AccountType accountType,@JsonKey(name: 'artist_id') String? artistId,@JsonKey(name: 'artist_name') String? artistName,@JsonKey(name: 'artist_genres') List<String>? artistGenres,@JsonKey(name: 'artist_city') String? artistCity,@JsonKey(name: 'artist_country') String? artistCountry,@JsonKey(name: 'artist_total_tracks') int artistTotalTracks,@JsonKey(name: 'artist_total_plays') int artistTotalPlays,@JsonKey(name: 'created_at') String? createdAt
});




}
/// @nodoc
class _$ProfileCopyWithImpl<$Res>
    implements $ProfileCopyWith<$Res> {
  _$ProfileCopyWithImpl(this._self, this._then);

  final Profile _self;
  final $Res Function(Profile) _then;

/// Create a copy of Profile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? displayName = freezed,Object? username = freezed,Object? bio = freezed,Object? avatarUrl = freezed,Object? bannerUrl = freezed,Object? isVerified = null,Object? socialLinks = freezed,Object? accountType = null,Object? artistId = freezed,Object? artistName = freezed,Object? artistGenres = freezed,Object? artistCity = freezed,Object? artistCountry = freezed,Object? artistTotalTracks = null,Object? artistTotalPlays = null,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,username: freezed == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String?,bio: freezed == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String?,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,bannerUrl: freezed == bannerUrl ? _self.bannerUrl : bannerUrl // ignore: cast_nullable_to_non_nullable
as String?,isVerified: null == isVerified ? _self.isVerified : isVerified // ignore: cast_nullable_to_non_nullable
as bool,socialLinks: freezed == socialLinks ? _self.socialLinks : socialLinks // ignore: cast_nullable_to_non_nullable
as Map<String, String>?,accountType: null == accountType ? _self.accountType : accountType // ignore: cast_nullable_to_non_nullable
as AccountType,artistId: freezed == artistId ? _self.artistId : artistId // ignore: cast_nullable_to_non_nullable
as String?,artistName: freezed == artistName ? _self.artistName : artistName // ignore: cast_nullable_to_non_nullable
as String?,artistGenres: freezed == artistGenres ? _self.artistGenres : artistGenres // ignore: cast_nullable_to_non_nullable
as List<String>?,artistCity: freezed == artistCity ? _self.artistCity : artistCity // ignore: cast_nullable_to_non_nullable
as String?,artistCountry: freezed == artistCountry ? _self.artistCountry : artistCountry // ignore: cast_nullable_to_non_nullable
as String?,artistTotalTracks: null == artistTotalTracks ? _self.artistTotalTracks : artistTotalTracks // ignore: cast_nullable_to_non_nullable
as int,artistTotalPlays: null == artistTotalPlays ? _self.artistTotalPlays : artistTotalPlays // ignore: cast_nullable_to_non_nullable
as int,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Profile].
extension ProfilePatterns on Profile {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Profile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Profile() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Profile value)  $default,){
final _that = this;
switch (_that) {
case _Profile():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Profile value)?  $default,){
final _that = this;
switch (_that) {
case _Profile() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'display_name')  String? displayName,  String? username,  String? bio, @JsonKey(name: 'avatar_url')  String? avatarUrl, @JsonKey(name: 'banner_url')  String? bannerUrl, @JsonKey(name: 'is_verified')  bool isVerified, @JsonKey(name: 'social_links')  Map<String, String>? socialLinks, @JsonKey(name: 'account_type')  AccountType accountType, @JsonKey(name: 'artist_id')  String? artistId, @JsonKey(name: 'artist_name')  String? artistName, @JsonKey(name: 'artist_genres')  List<String>? artistGenres, @JsonKey(name: 'artist_city')  String? artistCity, @JsonKey(name: 'artist_country')  String? artistCountry, @JsonKey(name: 'artist_total_tracks')  int artistTotalTracks, @JsonKey(name: 'artist_total_plays')  int artistTotalPlays, @JsonKey(name: 'created_at')  String? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Profile() when $default != null:
return $default(_that.id,_that.displayName,_that.username,_that.bio,_that.avatarUrl,_that.bannerUrl,_that.isVerified,_that.socialLinks,_that.accountType,_that.artistId,_that.artistName,_that.artistGenres,_that.artistCity,_that.artistCountry,_that.artistTotalTracks,_that.artistTotalPlays,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'display_name')  String? displayName,  String? username,  String? bio, @JsonKey(name: 'avatar_url')  String? avatarUrl, @JsonKey(name: 'banner_url')  String? bannerUrl, @JsonKey(name: 'is_verified')  bool isVerified, @JsonKey(name: 'social_links')  Map<String, String>? socialLinks, @JsonKey(name: 'account_type')  AccountType accountType, @JsonKey(name: 'artist_id')  String? artistId, @JsonKey(name: 'artist_name')  String? artistName, @JsonKey(name: 'artist_genres')  List<String>? artistGenres, @JsonKey(name: 'artist_city')  String? artistCity, @JsonKey(name: 'artist_country')  String? artistCountry, @JsonKey(name: 'artist_total_tracks')  int artistTotalTracks, @JsonKey(name: 'artist_total_plays')  int artistTotalPlays, @JsonKey(name: 'created_at')  String? createdAt)  $default,) {final _that = this;
switch (_that) {
case _Profile():
return $default(_that.id,_that.displayName,_that.username,_that.bio,_that.avatarUrl,_that.bannerUrl,_that.isVerified,_that.socialLinks,_that.accountType,_that.artistId,_that.artistName,_that.artistGenres,_that.artistCity,_that.artistCountry,_that.artistTotalTracks,_that.artistTotalPlays,_that.createdAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'display_name')  String? displayName,  String? username,  String? bio, @JsonKey(name: 'avatar_url')  String? avatarUrl, @JsonKey(name: 'banner_url')  String? bannerUrl, @JsonKey(name: 'is_verified')  bool isVerified, @JsonKey(name: 'social_links')  Map<String, String>? socialLinks, @JsonKey(name: 'account_type')  AccountType accountType, @JsonKey(name: 'artist_id')  String? artistId, @JsonKey(name: 'artist_name')  String? artistName, @JsonKey(name: 'artist_genres')  List<String>? artistGenres, @JsonKey(name: 'artist_city')  String? artistCity, @JsonKey(name: 'artist_country')  String? artistCountry, @JsonKey(name: 'artist_total_tracks')  int artistTotalTracks, @JsonKey(name: 'artist_total_plays')  int artistTotalPlays, @JsonKey(name: 'created_at')  String? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _Profile() when $default != null:
return $default(_that.id,_that.displayName,_that.username,_that.bio,_that.avatarUrl,_that.bannerUrl,_that.isVerified,_that.socialLinks,_that.accountType,_that.artistId,_that.artistName,_that.artistGenres,_that.artistCity,_that.artistCountry,_that.artistTotalTracks,_that.artistTotalPlays,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Profile implements Profile {
  const _Profile({required this.id, @JsonKey(name: 'display_name') this.displayName, this.username, this.bio, @JsonKey(name: 'avatar_url') this.avatarUrl, @JsonKey(name: 'banner_url') this.bannerUrl, @JsonKey(name: 'is_verified') this.isVerified = false, @JsonKey(name: 'social_links') final  Map<String, String>? socialLinks, @JsonKey(name: 'account_type') this.accountType = AccountType.consumer, @JsonKey(name: 'artist_id') this.artistId, @JsonKey(name: 'artist_name') this.artistName, @JsonKey(name: 'artist_genres') final  List<String>? artistGenres, @JsonKey(name: 'artist_city') this.artistCity, @JsonKey(name: 'artist_country') this.artistCountry, @JsonKey(name: 'artist_total_tracks') this.artistTotalTracks = 0, @JsonKey(name: 'artist_total_plays') this.artistTotalPlays = 0, @JsonKey(name: 'created_at') this.createdAt}): _socialLinks = socialLinks,_artistGenres = artistGenres;
  factory _Profile.fromJson(Map<String, dynamic> json) => _$ProfileFromJson(json);

@override final  String id;
@override@JsonKey(name: 'display_name') final  String? displayName;
@override final  String? username;
@override final  String? bio;
@override@JsonKey(name: 'avatar_url') final  String? avatarUrl;
@override@JsonKey(name: 'banner_url') final  String? bannerUrl;
@override@JsonKey(name: 'is_verified') final  bool isVerified;
 final  Map<String, String>? _socialLinks;
@override@JsonKey(name: 'social_links') Map<String, String>? get socialLinks {
  final value = _socialLinks;
  if (value == null) return null;
  if (_socialLinks is EqualUnmodifiableMapView) return _socialLinks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override@JsonKey(name: 'account_type') final  AccountType accountType;
// Campos de artista — populados quando accountType == musician
@override@JsonKey(name: 'artist_id') final  String? artistId;
@override@JsonKey(name: 'artist_name') final  String? artistName;
 final  List<String>? _artistGenres;
@override@JsonKey(name: 'artist_genres') List<String>? get artistGenres {
  final value = _artistGenres;
  if (value == null) return null;
  if (_artistGenres is EqualUnmodifiableListView) return _artistGenres;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override@JsonKey(name: 'artist_city') final  String? artistCity;
@override@JsonKey(name: 'artist_country') final  String? artistCountry;
@override@JsonKey(name: 'artist_total_tracks') final  int artistTotalTracks;
@override@JsonKey(name: 'artist_total_plays') final  int artistTotalPlays;
// Data de criação do perfil
@override@JsonKey(name: 'created_at') final  String? createdAt;

/// Create a copy of Profile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProfileCopyWith<_Profile> get copyWith => __$ProfileCopyWithImpl<_Profile>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProfileToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Profile&&(identical(other.id, id) || other.id == id)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.username, username) || other.username == username)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.bannerUrl, bannerUrl) || other.bannerUrl == bannerUrl)&&(identical(other.isVerified, isVerified) || other.isVerified == isVerified)&&const DeepCollectionEquality().equals(other._socialLinks, _socialLinks)&&(identical(other.accountType, accountType) || other.accountType == accountType)&&(identical(other.artistId, artistId) || other.artistId == artistId)&&(identical(other.artistName, artistName) || other.artistName == artistName)&&const DeepCollectionEquality().equals(other._artistGenres, _artistGenres)&&(identical(other.artistCity, artistCity) || other.artistCity == artistCity)&&(identical(other.artistCountry, artistCountry) || other.artistCountry == artistCountry)&&(identical(other.artistTotalTracks, artistTotalTracks) || other.artistTotalTracks == artistTotalTracks)&&(identical(other.artistTotalPlays, artistTotalPlays) || other.artistTotalPlays == artistTotalPlays)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,displayName,username,bio,avatarUrl,bannerUrl,isVerified,const DeepCollectionEquality().hash(_socialLinks),accountType,artistId,artistName,const DeepCollectionEquality().hash(_artistGenres),artistCity,artistCountry,artistTotalTracks,artistTotalPlays,createdAt);

@override
String toString() {
  return 'Profile(id: $id, displayName: $displayName, username: $username, bio: $bio, avatarUrl: $avatarUrl, bannerUrl: $bannerUrl, isVerified: $isVerified, socialLinks: $socialLinks, accountType: $accountType, artistId: $artistId, artistName: $artistName, artistGenres: $artistGenres, artistCity: $artistCity, artistCountry: $artistCountry, artistTotalTracks: $artistTotalTracks, artistTotalPlays: $artistTotalPlays, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$ProfileCopyWith<$Res> implements $ProfileCopyWith<$Res> {
  factory _$ProfileCopyWith(_Profile value, $Res Function(_Profile) _then) = __$ProfileCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'display_name') String? displayName, String? username, String? bio,@JsonKey(name: 'avatar_url') String? avatarUrl,@JsonKey(name: 'banner_url') String? bannerUrl,@JsonKey(name: 'is_verified') bool isVerified,@JsonKey(name: 'social_links') Map<String, String>? socialLinks,@JsonKey(name: 'account_type') AccountType accountType,@JsonKey(name: 'artist_id') String? artistId,@JsonKey(name: 'artist_name') String? artistName,@JsonKey(name: 'artist_genres') List<String>? artistGenres,@JsonKey(name: 'artist_city') String? artistCity,@JsonKey(name: 'artist_country') String? artistCountry,@JsonKey(name: 'artist_total_tracks') int artistTotalTracks,@JsonKey(name: 'artist_total_plays') int artistTotalPlays,@JsonKey(name: 'created_at') String? createdAt
});




}
/// @nodoc
class __$ProfileCopyWithImpl<$Res>
    implements _$ProfileCopyWith<$Res> {
  __$ProfileCopyWithImpl(this._self, this._then);

  final _Profile _self;
  final $Res Function(_Profile) _then;

/// Create a copy of Profile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? displayName = freezed,Object? username = freezed,Object? bio = freezed,Object? avatarUrl = freezed,Object? bannerUrl = freezed,Object? isVerified = null,Object? socialLinks = freezed,Object? accountType = null,Object? artistId = freezed,Object? artistName = freezed,Object? artistGenres = freezed,Object? artistCity = freezed,Object? artistCountry = freezed,Object? artistTotalTracks = null,Object? artistTotalPlays = null,Object? createdAt = freezed,}) {
  return _then(_Profile(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,username: freezed == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String?,bio: freezed == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String?,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,bannerUrl: freezed == bannerUrl ? _self.bannerUrl : bannerUrl // ignore: cast_nullable_to_non_nullable
as String?,isVerified: null == isVerified ? _self.isVerified : isVerified // ignore: cast_nullable_to_non_nullable
as bool,socialLinks: freezed == socialLinks ? _self._socialLinks : socialLinks // ignore: cast_nullable_to_non_nullable
as Map<String, String>?,accountType: null == accountType ? _self.accountType : accountType // ignore: cast_nullable_to_non_nullable
as AccountType,artistId: freezed == artistId ? _self.artistId : artistId // ignore: cast_nullable_to_non_nullable
as String?,artistName: freezed == artistName ? _self.artistName : artistName // ignore: cast_nullable_to_non_nullable
as String?,artistGenres: freezed == artistGenres ? _self._artistGenres : artistGenres // ignore: cast_nullable_to_non_nullable
as List<String>?,artistCity: freezed == artistCity ? _self.artistCity : artistCity // ignore: cast_nullable_to_non_nullable
as String?,artistCountry: freezed == artistCountry ? _self.artistCountry : artistCountry // ignore: cast_nullable_to_non_nullable
as String?,artistTotalTracks: null == artistTotalTracks ? _self.artistTotalTracks : artistTotalTracks // ignore: cast_nullable_to_non_nullable
as int,artistTotalPlays: null == artistTotalPlays ? _self.artistTotalPlays : artistTotalPlays // ignore: cast_nullable_to_non_nullable
as int,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
