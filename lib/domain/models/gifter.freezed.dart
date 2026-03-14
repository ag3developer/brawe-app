// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'gifter.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Gifter {

 String get id; String get name;@JsonKey(name: 'avatar_url') String? get avatarUrl;@JsonKey(name: 'total_spent') double get totalSpent; int get rank;
/// Create a copy of Gifter
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GifterCopyWith<Gifter> get copyWith => _$GifterCopyWithImpl<Gifter>(this as Gifter, _$identity);

  /// Serializes this Gifter to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Gifter&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.totalSpent, totalSpent) || other.totalSpent == totalSpent)&&(identical(other.rank, rank) || other.rank == rank));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,avatarUrl,totalSpent,rank);

@override
String toString() {
  return 'Gifter(id: $id, name: $name, avatarUrl: $avatarUrl, totalSpent: $totalSpent, rank: $rank)';
}


}

/// @nodoc
abstract mixin class $GifterCopyWith<$Res>  {
  factory $GifterCopyWith(Gifter value, $Res Function(Gifter) _then) = _$GifterCopyWithImpl;
@useResult
$Res call({
 String id, String name,@JsonKey(name: 'avatar_url') String? avatarUrl,@JsonKey(name: 'total_spent') double totalSpent, int rank
});




}
/// @nodoc
class _$GifterCopyWithImpl<$Res>
    implements $GifterCopyWith<$Res> {
  _$GifterCopyWithImpl(this._self, this._then);

  final Gifter _self;
  final $Res Function(Gifter) _then;

/// Create a copy of Gifter
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? avatarUrl = freezed,Object? totalSpent = null,Object? rank = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,totalSpent: null == totalSpent ? _self.totalSpent : totalSpent // ignore: cast_nullable_to_non_nullable
as double,rank: null == rank ? _self.rank : rank // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [Gifter].
extension GifterPatterns on Gifter {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Gifter value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Gifter() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Gifter value)  $default,){
final _that = this;
switch (_that) {
case _Gifter():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Gifter value)?  $default,){
final _that = this;
switch (_that) {
case _Gifter() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name, @JsonKey(name: 'avatar_url')  String? avatarUrl, @JsonKey(name: 'total_spent')  double totalSpent,  int rank)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Gifter() when $default != null:
return $default(_that.id,_that.name,_that.avatarUrl,_that.totalSpent,_that.rank);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name, @JsonKey(name: 'avatar_url')  String? avatarUrl, @JsonKey(name: 'total_spent')  double totalSpent,  int rank)  $default,) {final _that = this;
switch (_that) {
case _Gifter():
return $default(_that.id,_that.name,_that.avatarUrl,_that.totalSpent,_that.rank);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name, @JsonKey(name: 'avatar_url')  String? avatarUrl, @JsonKey(name: 'total_spent')  double totalSpent,  int rank)?  $default,) {final _that = this;
switch (_that) {
case _Gifter() when $default != null:
return $default(_that.id,_that.name,_that.avatarUrl,_that.totalSpent,_that.rank);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Gifter implements Gifter {
  const _Gifter({required this.id, required this.name, @JsonKey(name: 'avatar_url') this.avatarUrl, @JsonKey(name: 'total_spent') required this.totalSpent, this.rank = 0});
  factory _Gifter.fromJson(Map<String, dynamic> json) => _$GifterFromJson(json);

@override final  String id;
@override final  String name;
@override@JsonKey(name: 'avatar_url') final  String? avatarUrl;
@override@JsonKey(name: 'total_spent') final  double totalSpent;
@override@JsonKey() final  int rank;

/// Create a copy of Gifter
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GifterCopyWith<_Gifter> get copyWith => __$GifterCopyWithImpl<_Gifter>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GifterToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Gifter&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.totalSpent, totalSpent) || other.totalSpent == totalSpent)&&(identical(other.rank, rank) || other.rank == rank));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,avatarUrl,totalSpent,rank);

@override
String toString() {
  return 'Gifter(id: $id, name: $name, avatarUrl: $avatarUrl, totalSpent: $totalSpent, rank: $rank)';
}


}

/// @nodoc
abstract mixin class _$GifterCopyWith<$Res> implements $GifterCopyWith<$Res> {
  factory _$GifterCopyWith(_Gifter value, $Res Function(_Gifter) _then) = __$GifterCopyWithImpl;
@override @useResult
$Res call({
 String id, String name,@JsonKey(name: 'avatar_url') String? avatarUrl,@JsonKey(name: 'total_spent') double totalSpent, int rank
});




}
/// @nodoc
class __$GifterCopyWithImpl<$Res>
    implements _$GifterCopyWith<$Res> {
  __$GifterCopyWithImpl(this._self, this._then);

  final _Gifter _self;
  final $Res Function(_Gifter) _then;

/// Create a copy of Gifter
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? avatarUrl = freezed,Object? totalSpent = null,Object? rank = null,}) {
  return _then(_Gifter(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,totalSpent: null == totalSpent ? _self.totalSpent : totalSpent // ignore: cast_nullable_to_non_nullable
as double,rank: null == rank ? _self.rank : rank // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
