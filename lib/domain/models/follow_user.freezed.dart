// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'follow_user.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$FollowUser {

@JsonKey(name: 'user_id') String get userId;@JsonKey(name: 'display_name') String? get displayName; String get username;@JsonKey(name: 'avatar_url') String? get avatarUrl; String? get bio;@JsonKey(name: 'is_verified') bool get isVerified;@JsonKey(name: 'is_following') bool get isFollowing;@JsonKey(name: 'is_streamer') bool get isStreamer;@JsonKey(name: 'is_live') bool get isLive;@JsonKey(name: 'followed_at') String? get followedAt;
/// Create a copy of FollowUser
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FollowUserCopyWith<FollowUser> get copyWith => _$FollowUserCopyWithImpl<FollowUser>(this as FollowUser, _$identity);

  /// Serializes this FollowUser to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FollowUser&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.username, username) || other.username == username)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.isVerified, isVerified) || other.isVerified == isVerified)&&(identical(other.isFollowing, isFollowing) || other.isFollowing == isFollowing)&&(identical(other.isStreamer, isStreamer) || other.isStreamer == isStreamer)&&(identical(other.isLive, isLive) || other.isLive == isLive)&&(identical(other.followedAt, followedAt) || other.followedAt == followedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,displayName,username,avatarUrl,bio,isVerified,isFollowing,isStreamer,isLive,followedAt);

@override
String toString() {
  return 'FollowUser(userId: $userId, displayName: $displayName, username: $username, avatarUrl: $avatarUrl, bio: $bio, isVerified: $isVerified, isFollowing: $isFollowing, isStreamer: $isStreamer, isLive: $isLive, followedAt: $followedAt)';
}


}

/// @nodoc
abstract mixin class $FollowUserCopyWith<$Res>  {
  factory $FollowUserCopyWith(FollowUser value, $Res Function(FollowUser) _then) = _$FollowUserCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'user_id') String userId,@JsonKey(name: 'display_name') String? displayName, String username,@JsonKey(name: 'avatar_url') String? avatarUrl, String? bio,@JsonKey(name: 'is_verified') bool isVerified,@JsonKey(name: 'is_following') bool isFollowing,@JsonKey(name: 'is_streamer') bool isStreamer,@JsonKey(name: 'is_live') bool isLive,@JsonKey(name: 'followed_at') String? followedAt
});




}
/// @nodoc
class _$FollowUserCopyWithImpl<$Res>
    implements $FollowUserCopyWith<$Res> {
  _$FollowUserCopyWithImpl(this._self, this._then);

  final FollowUser _self;
  final $Res Function(FollowUser) _then;

/// Create a copy of FollowUser
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userId = null,Object? displayName = freezed,Object? username = null,Object? avatarUrl = freezed,Object? bio = freezed,Object? isVerified = null,Object? isFollowing = null,Object? isStreamer = null,Object? isLive = null,Object? followedAt = freezed,}) {
  return _then(_self.copyWith(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,bio: freezed == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String?,isVerified: null == isVerified ? _self.isVerified : isVerified // ignore: cast_nullable_to_non_nullable
as bool,isFollowing: null == isFollowing ? _self.isFollowing : isFollowing // ignore: cast_nullable_to_non_nullable
as bool,isStreamer: null == isStreamer ? _self.isStreamer : isStreamer // ignore: cast_nullable_to_non_nullable
as bool,isLive: null == isLive ? _self.isLive : isLive // ignore: cast_nullable_to_non_nullable
as bool,followedAt: freezed == followedAt ? _self.followedAt : followedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [FollowUser].
extension FollowUserPatterns on FollowUser {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FollowUser value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FollowUser() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FollowUser value)  $default,){
final _that = this;
switch (_that) {
case _FollowUser():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FollowUser value)?  $default,){
final _that = this;
switch (_that) {
case _FollowUser() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'user_id')  String userId, @JsonKey(name: 'display_name')  String? displayName,  String username, @JsonKey(name: 'avatar_url')  String? avatarUrl,  String? bio, @JsonKey(name: 'is_verified')  bool isVerified, @JsonKey(name: 'is_following')  bool isFollowing, @JsonKey(name: 'is_streamer')  bool isStreamer, @JsonKey(name: 'is_live')  bool isLive, @JsonKey(name: 'followed_at')  String? followedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FollowUser() when $default != null:
return $default(_that.userId,_that.displayName,_that.username,_that.avatarUrl,_that.bio,_that.isVerified,_that.isFollowing,_that.isStreamer,_that.isLive,_that.followedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'user_id')  String userId, @JsonKey(name: 'display_name')  String? displayName,  String username, @JsonKey(name: 'avatar_url')  String? avatarUrl,  String? bio, @JsonKey(name: 'is_verified')  bool isVerified, @JsonKey(name: 'is_following')  bool isFollowing, @JsonKey(name: 'is_streamer')  bool isStreamer, @JsonKey(name: 'is_live')  bool isLive, @JsonKey(name: 'followed_at')  String? followedAt)  $default,) {final _that = this;
switch (_that) {
case _FollowUser():
return $default(_that.userId,_that.displayName,_that.username,_that.avatarUrl,_that.bio,_that.isVerified,_that.isFollowing,_that.isStreamer,_that.isLive,_that.followedAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'user_id')  String userId, @JsonKey(name: 'display_name')  String? displayName,  String username, @JsonKey(name: 'avatar_url')  String? avatarUrl,  String? bio, @JsonKey(name: 'is_verified')  bool isVerified, @JsonKey(name: 'is_following')  bool isFollowing, @JsonKey(name: 'is_streamer')  bool isStreamer, @JsonKey(name: 'is_live')  bool isLive, @JsonKey(name: 'followed_at')  String? followedAt)?  $default,) {final _that = this;
switch (_that) {
case _FollowUser() when $default != null:
return $default(_that.userId,_that.displayName,_that.username,_that.avatarUrl,_that.bio,_that.isVerified,_that.isFollowing,_that.isStreamer,_that.isLive,_that.followedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FollowUser implements FollowUser {
  const _FollowUser({@JsonKey(name: 'user_id') required this.userId, @JsonKey(name: 'display_name') this.displayName, this.username = '', @JsonKey(name: 'avatar_url') this.avatarUrl, this.bio, @JsonKey(name: 'is_verified') this.isVerified = false, @JsonKey(name: 'is_following') this.isFollowing = false, @JsonKey(name: 'is_streamer') this.isStreamer = false, @JsonKey(name: 'is_live') this.isLive = false, @JsonKey(name: 'followed_at') this.followedAt});
  factory _FollowUser.fromJson(Map<String, dynamic> json) => _$FollowUserFromJson(json);

@override@JsonKey(name: 'user_id') final  String userId;
@override@JsonKey(name: 'display_name') final  String? displayName;
@override@JsonKey() final  String username;
@override@JsonKey(name: 'avatar_url') final  String? avatarUrl;
@override final  String? bio;
@override@JsonKey(name: 'is_verified') final  bool isVerified;
@override@JsonKey(name: 'is_following') final  bool isFollowing;
@override@JsonKey(name: 'is_streamer') final  bool isStreamer;
@override@JsonKey(name: 'is_live') final  bool isLive;
@override@JsonKey(name: 'followed_at') final  String? followedAt;

/// Create a copy of FollowUser
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FollowUserCopyWith<_FollowUser> get copyWith => __$FollowUserCopyWithImpl<_FollowUser>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FollowUserToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FollowUser&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.username, username) || other.username == username)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.isVerified, isVerified) || other.isVerified == isVerified)&&(identical(other.isFollowing, isFollowing) || other.isFollowing == isFollowing)&&(identical(other.isStreamer, isStreamer) || other.isStreamer == isStreamer)&&(identical(other.isLive, isLive) || other.isLive == isLive)&&(identical(other.followedAt, followedAt) || other.followedAt == followedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,displayName,username,avatarUrl,bio,isVerified,isFollowing,isStreamer,isLive,followedAt);

@override
String toString() {
  return 'FollowUser(userId: $userId, displayName: $displayName, username: $username, avatarUrl: $avatarUrl, bio: $bio, isVerified: $isVerified, isFollowing: $isFollowing, isStreamer: $isStreamer, isLive: $isLive, followedAt: $followedAt)';
}


}

/// @nodoc
abstract mixin class _$FollowUserCopyWith<$Res> implements $FollowUserCopyWith<$Res> {
  factory _$FollowUserCopyWith(_FollowUser value, $Res Function(_FollowUser) _then) = __$FollowUserCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'user_id') String userId,@JsonKey(name: 'display_name') String? displayName, String username,@JsonKey(name: 'avatar_url') String? avatarUrl, String? bio,@JsonKey(name: 'is_verified') bool isVerified,@JsonKey(name: 'is_following') bool isFollowing,@JsonKey(name: 'is_streamer') bool isStreamer,@JsonKey(name: 'is_live') bool isLive,@JsonKey(name: 'followed_at') String? followedAt
});




}
/// @nodoc
class __$FollowUserCopyWithImpl<$Res>
    implements _$FollowUserCopyWith<$Res> {
  __$FollowUserCopyWithImpl(this._self, this._then);

  final _FollowUser _self;
  final $Res Function(_FollowUser) _then;

/// Create a copy of FollowUser
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userId = null,Object? displayName = freezed,Object? username = null,Object? avatarUrl = freezed,Object? bio = freezed,Object? isVerified = null,Object? isFollowing = null,Object? isStreamer = null,Object? isLive = null,Object? followedAt = freezed,}) {
  return _then(_FollowUser(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,bio: freezed == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String?,isVerified: null == isVerified ? _self.isVerified : isVerified // ignore: cast_nullable_to_non_nullable
as bool,isFollowing: null == isFollowing ? _self.isFollowing : isFollowing // ignore: cast_nullable_to_non_nullable
as bool,isStreamer: null == isStreamer ? _self.isStreamer : isStreamer // ignore: cast_nullable_to_non_nullable
as bool,isLive: null == isLive ? _self.isLive : isLive // ignore: cast_nullable_to_non_nullable
as bool,followedAt: freezed == followedAt ? _self.followedAt : followedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
