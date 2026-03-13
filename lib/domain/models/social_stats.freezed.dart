// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'social_stats.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SocialStats {

@JsonKey(name: 'followers_count') int get followersCount;@JsonKey(name: 'following_count') int get followingCount;@JsonKey(name: 'lives_count') int get livesCount;@JsonKey(name: 'total_likes') int get totalLikes;@JsonKey(name: 'is_following') bool get isFollowing;
/// Create a copy of SocialStats
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SocialStatsCopyWith<SocialStats> get copyWith => _$SocialStatsCopyWithImpl<SocialStats>(this as SocialStats, _$identity);

  /// Serializes this SocialStats to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SocialStats&&(identical(other.followersCount, followersCount) || other.followersCount == followersCount)&&(identical(other.followingCount, followingCount) || other.followingCount == followingCount)&&(identical(other.livesCount, livesCount) || other.livesCount == livesCount)&&(identical(other.totalLikes, totalLikes) || other.totalLikes == totalLikes)&&(identical(other.isFollowing, isFollowing) || other.isFollowing == isFollowing));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,followersCount,followingCount,livesCount,totalLikes,isFollowing);

@override
String toString() {
  return 'SocialStats(followersCount: $followersCount, followingCount: $followingCount, livesCount: $livesCount, totalLikes: $totalLikes, isFollowing: $isFollowing)';
}


}

/// @nodoc
abstract mixin class $SocialStatsCopyWith<$Res>  {
  factory $SocialStatsCopyWith(SocialStats value, $Res Function(SocialStats) _then) = _$SocialStatsCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'followers_count') int followersCount,@JsonKey(name: 'following_count') int followingCount,@JsonKey(name: 'lives_count') int livesCount,@JsonKey(name: 'total_likes') int totalLikes,@JsonKey(name: 'is_following') bool isFollowing
});




}
/// @nodoc
class _$SocialStatsCopyWithImpl<$Res>
    implements $SocialStatsCopyWith<$Res> {
  _$SocialStatsCopyWithImpl(this._self, this._then);

  final SocialStats _self;
  final $Res Function(SocialStats) _then;

/// Create a copy of SocialStats
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? followersCount = null,Object? followingCount = null,Object? livesCount = null,Object? totalLikes = null,Object? isFollowing = null,}) {
  return _then(_self.copyWith(
followersCount: null == followersCount ? _self.followersCount : followersCount // ignore: cast_nullable_to_non_nullable
as int,followingCount: null == followingCount ? _self.followingCount : followingCount // ignore: cast_nullable_to_non_nullable
as int,livesCount: null == livesCount ? _self.livesCount : livesCount // ignore: cast_nullable_to_non_nullable
as int,totalLikes: null == totalLikes ? _self.totalLikes : totalLikes // ignore: cast_nullable_to_non_nullable
as int,isFollowing: null == isFollowing ? _self.isFollowing : isFollowing // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [SocialStats].
extension SocialStatsPatterns on SocialStats {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SocialStats value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SocialStats() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SocialStats value)  $default,){
final _that = this;
switch (_that) {
case _SocialStats():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SocialStats value)?  $default,){
final _that = this;
switch (_that) {
case _SocialStats() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'followers_count')  int followersCount, @JsonKey(name: 'following_count')  int followingCount, @JsonKey(name: 'lives_count')  int livesCount, @JsonKey(name: 'total_likes')  int totalLikes, @JsonKey(name: 'is_following')  bool isFollowing)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SocialStats() when $default != null:
return $default(_that.followersCount,_that.followingCount,_that.livesCount,_that.totalLikes,_that.isFollowing);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'followers_count')  int followersCount, @JsonKey(name: 'following_count')  int followingCount, @JsonKey(name: 'lives_count')  int livesCount, @JsonKey(name: 'total_likes')  int totalLikes, @JsonKey(name: 'is_following')  bool isFollowing)  $default,) {final _that = this;
switch (_that) {
case _SocialStats():
return $default(_that.followersCount,_that.followingCount,_that.livesCount,_that.totalLikes,_that.isFollowing);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'followers_count')  int followersCount, @JsonKey(name: 'following_count')  int followingCount, @JsonKey(name: 'lives_count')  int livesCount, @JsonKey(name: 'total_likes')  int totalLikes, @JsonKey(name: 'is_following')  bool isFollowing)?  $default,) {final _that = this;
switch (_that) {
case _SocialStats() when $default != null:
return $default(_that.followersCount,_that.followingCount,_that.livesCount,_that.totalLikes,_that.isFollowing);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SocialStats implements SocialStats {
  const _SocialStats({@JsonKey(name: 'followers_count') this.followersCount = 0, @JsonKey(name: 'following_count') this.followingCount = 0, @JsonKey(name: 'lives_count') this.livesCount = 0, @JsonKey(name: 'total_likes') this.totalLikes = 0, @JsonKey(name: 'is_following') this.isFollowing = false});
  factory _SocialStats.fromJson(Map<String, dynamic> json) => _$SocialStatsFromJson(json);

@override@JsonKey(name: 'followers_count') final  int followersCount;
@override@JsonKey(name: 'following_count') final  int followingCount;
@override@JsonKey(name: 'lives_count') final  int livesCount;
@override@JsonKey(name: 'total_likes') final  int totalLikes;
@override@JsonKey(name: 'is_following') final  bool isFollowing;

/// Create a copy of SocialStats
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SocialStatsCopyWith<_SocialStats> get copyWith => __$SocialStatsCopyWithImpl<_SocialStats>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SocialStatsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SocialStats&&(identical(other.followersCount, followersCount) || other.followersCount == followersCount)&&(identical(other.followingCount, followingCount) || other.followingCount == followingCount)&&(identical(other.livesCount, livesCount) || other.livesCount == livesCount)&&(identical(other.totalLikes, totalLikes) || other.totalLikes == totalLikes)&&(identical(other.isFollowing, isFollowing) || other.isFollowing == isFollowing));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,followersCount,followingCount,livesCount,totalLikes,isFollowing);

@override
String toString() {
  return 'SocialStats(followersCount: $followersCount, followingCount: $followingCount, livesCount: $livesCount, totalLikes: $totalLikes, isFollowing: $isFollowing)';
}


}

/// @nodoc
abstract mixin class _$SocialStatsCopyWith<$Res> implements $SocialStatsCopyWith<$Res> {
  factory _$SocialStatsCopyWith(_SocialStats value, $Res Function(_SocialStats) _then) = __$SocialStatsCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'followers_count') int followersCount,@JsonKey(name: 'following_count') int followingCount,@JsonKey(name: 'lives_count') int livesCount,@JsonKey(name: 'total_likes') int totalLikes,@JsonKey(name: 'is_following') bool isFollowing
});




}
/// @nodoc
class __$SocialStatsCopyWithImpl<$Res>
    implements _$SocialStatsCopyWith<$Res> {
  __$SocialStatsCopyWithImpl(this._self, this._then);

  final _SocialStats _self;
  final $Res Function(_SocialStats) _then;

/// Create a copy of SocialStats
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? followersCount = null,Object? followingCount = null,Object? livesCount = null,Object? totalLikes = null,Object? isFollowing = null,}) {
  return _then(_SocialStats(
followersCount: null == followersCount ? _self.followersCount : followersCount // ignore: cast_nullable_to_non_nullable
as int,followingCount: null == followingCount ? _self.followingCount : followingCount // ignore: cast_nullable_to_non_nullable
as int,livesCount: null == livesCount ? _self.livesCount : livesCount // ignore: cast_nullable_to_non_nullable
as int,totalLikes: null == totalLikes ? _self.totalLikes : totalLikes // ignore: cast_nullable_to_non_nullable
as int,isFollowing: null == isFollowing ? _self.isFollowing : isFollowing // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
