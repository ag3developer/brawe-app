// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'gift.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Gift {

 String get id; String get name; double get price;@JsonKey(name: 'icon_url') String? get iconUrl;@JsonKey(name: 'animation_url') String? get animationUrl; String get tier;
/// Create a copy of Gift
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GiftCopyWith<Gift> get copyWith => _$GiftCopyWithImpl<Gift>(this as Gift, _$identity);

  /// Serializes this Gift to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Gift&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.price, price) || other.price == price)&&(identical(other.iconUrl, iconUrl) || other.iconUrl == iconUrl)&&(identical(other.animationUrl, animationUrl) || other.animationUrl == animationUrl)&&(identical(other.tier, tier) || other.tier == tier));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,price,iconUrl,animationUrl,tier);

@override
String toString() {
  return 'Gift(id: $id, name: $name, price: $price, iconUrl: $iconUrl, animationUrl: $animationUrl, tier: $tier)';
}


}

/// @nodoc
abstract mixin class $GiftCopyWith<$Res>  {
  factory $GiftCopyWith(Gift value, $Res Function(Gift) _then) = _$GiftCopyWithImpl;
@useResult
$Res call({
 String id, String name, double price,@JsonKey(name: 'icon_url') String? iconUrl,@JsonKey(name: 'animation_url') String? animationUrl, String tier
});




}
/// @nodoc
class _$GiftCopyWithImpl<$Res>
    implements $GiftCopyWith<$Res> {
  _$GiftCopyWithImpl(this._self, this._then);

  final Gift _self;
  final $Res Function(Gift) _then;

/// Create a copy of Gift
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? price = null,Object? iconUrl = freezed,Object? animationUrl = freezed,Object? tier = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,iconUrl: freezed == iconUrl ? _self.iconUrl : iconUrl // ignore: cast_nullable_to_non_nullable
as String?,animationUrl: freezed == animationUrl ? _self.animationUrl : animationUrl // ignore: cast_nullable_to_non_nullable
as String?,tier: null == tier ? _self.tier : tier // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [Gift].
extension GiftPatterns on Gift {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Gift value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Gift() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Gift value)  $default,){
final _that = this;
switch (_that) {
case _Gift():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Gift value)?  $default,){
final _that = this;
switch (_that) {
case _Gift() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  double price, @JsonKey(name: 'icon_url')  String? iconUrl, @JsonKey(name: 'animation_url')  String? animationUrl,  String tier)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Gift() when $default != null:
return $default(_that.id,_that.name,_that.price,_that.iconUrl,_that.animationUrl,_that.tier);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  double price, @JsonKey(name: 'icon_url')  String? iconUrl, @JsonKey(name: 'animation_url')  String? animationUrl,  String tier)  $default,) {final _that = this;
switch (_that) {
case _Gift():
return $default(_that.id,_that.name,_that.price,_that.iconUrl,_that.animationUrl,_that.tier);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  double price, @JsonKey(name: 'icon_url')  String? iconUrl, @JsonKey(name: 'animation_url')  String? animationUrl,  String tier)?  $default,) {final _that = this;
switch (_that) {
case _Gift() when $default != null:
return $default(_that.id,_that.name,_that.price,_that.iconUrl,_that.animationUrl,_that.tier);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Gift implements Gift {
  const _Gift({required this.id, required this.name, required this.price, @JsonKey(name: 'icon_url') this.iconUrl, @JsonKey(name: 'animation_url') this.animationUrl, this.tier = 'low'});
  factory _Gift.fromJson(Map<String, dynamic> json) => _$GiftFromJson(json);

@override final  String id;
@override final  String name;
@override final  double price;
@override@JsonKey(name: 'icon_url') final  String? iconUrl;
@override@JsonKey(name: 'animation_url') final  String? animationUrl;
@override@JsonKey() final  String tier;

/// Create a copy of Gift
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GiftCopyWith<_Gift> get copyWith => __$GiftCopyWithImpl<_Gift>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GiftToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Gift&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.price, price) || other.price == price)&&(identical(other.iconUrl, iconUrl) || other.iconUrl == iconUrl)&&(identical(other.animationUrl, animationUrl) || other.animationUrl == animationUrl)&&(identical(other.tier, tier) || other.tier == tier));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,price,iconUrl,animationUrl,tier);

@override
String toString() {
  return 'Gift(id: $id, name: $name, price: $price, iconUrl: $iconUrl, animationUrl: $animationUrl, tier: $tier)';
}


}

/// @nodoc
abstract mixin class _$GiftCopyWith<$Res> implements $GiftCopyWith<$Res> {
  factory _$GiftCopyWith(_Gift value, $Res Function(_Gift) _then) = __$GiftCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, double price,@JsonKey(name: 'icon_url') String? iconUrl,@JsonKey(name: 'animation_url') String? animationUrl, String tier
});




}
/// @nodoc
class __$GiftCopyWithImpl<$Res>
    implements _$GiftCopyWith<$Res> {
  __$GiftCopyWithImpl(this._self, this._then);

  final _Gift _self;
  final $Res Function(_Gift) _then;

/// Create a copy of Gift
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? price = null,Object? iconUrl = freezed,Object? animationUrl = freezed,Object? tier = null,}) {
  return _then(_Gift(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,iconUrl: freezed == iconUrl ? _self.iconUrl : iconUrl // ignore: cast_nullable_to_non_nullable
as String?,animationUrl: freezed == animationUrl ? _self.animationUrl : animationUrl // ignore: cast_nullable_to_non_nullable
as String?,tier: null == tier ? _self.tier : tier // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$GiftTier {

 String get name; List<Gift> get gifts;
/// Create a copy of GiftTier
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GiftTierCopyWith<GiftTier> get copyWith => _$GiftTierCopyWithImpl<GiftTier>(this as GiftTier, _$identity);

  /// Serializes this GiftTier to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GiftTier&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other.gifts, gifts));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,const DeepCollectionEquality().hash(gifts));

@override
String toString() {
  return 'GiftTier(name: $name, gifts: $gifts)';
}


}

/// @nodoc
abstract mixin class $GiftTierCopyWith<$Res>  {
  factory $GiftTierCopyWith(GiftTier value, $Res Function(GiftTier) _then) = _$GiftTierCopyWithImpl;
@useResult
$Res call({
 String name, List<Gift> gifts
});




}
/// @nodoc
class _$GiftTierCopyWithImpl<$Res>
    implements $GiftTierCopyWith<$Res> {
  _$GiftTierCopyWithImpl(this._self, this._then);

  final GiftTier _self;
  final $Res Function(GiftTier) _then;

/// Create a copy of GiftTier
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? gifts = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,gifts: null == gifts ? _self.gifts : gifts // ignore: cast_nullable_to_non_nullable
as List<Gift>,
  ));
}

}


/// Adds pattern-matching-related methods to [GiftTier].
extension GiftTierPatterns on GiftTier {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GiftTier value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GiftTier() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GiftTier value)  $default,){
final _that = this;
switch (_that) {
case _GiftTier():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GiftTier value)?  $default,){
final _that = this;
switch (_that) {
case _GiftTier() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  List<Gift> gifts)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GiftTier() when $default != null:
return $default(_that.name,_that.gifts);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  List<Gift> gifts)  $default,) {final _that = this;
switch (_that) {
case _GiftTier():
return $default(_that.name,_that.gifts);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  List<Gift> gifts)?  $default,) {final _that = this;
switch (_that) {
case _GiftTier() when $default != null:
return $default(_that.name,_that.gifts);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GiftTier implements GiftTier {
  const _GiftTier({required this.name, required final  List<Gift> gifts}): _gifts = gifts;
  factory _GiftTier.fromJson(Map<String, dynamic> json) => _$GiftTierFromJson(json);

@override final  String name;
 final  List<Gift> _gifts;
@override List<Gift> get gifts {
  if (_gifts is EqualUnmodifiableListView) return _gifts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_gifts);
}


/// Create a copy of GiftTier
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GiftTierCopyWith<_GiftTier> get copyWith => __$GiftTierCopyWithImpl<_GiftTier>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GiftTierToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GiftTier&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other._gifts, _gifts));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,const DeepCollectionEquality().hash(_gifts));

@override
String toString() {
  return 'GiftTier(name: $name, gifts: $gifts)';
}


}

/// @nodoc
abstract mixin class _$GiftTierCopyWith<$Res> implements $GiftTierCopyWith<$Res> {
  factory _$GiftTierCopyWith(_GiftTier value, $Res Function(_GiftTier) _then) = __$GiftTierCopyWithImpl;
@override @useResult
$Res call({
 String name, List<Gift> gifts
});




}
/// @nodoc
class __$GiftTierCopyWithImpl<$Res>
    implements _$GiftTierCopyWith<$Res> {
  __$GiftTierCopyWithImpl(this._self, this._then);

  final _GiftTier _self;
  final $Res Function(_GiftTier) _then;

/// Create a copy of GiftTier
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? gifts = null,}) {
  return _then(_GiftTier(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,gifts: null == gifts ? _self._gifts : gifts // ignore: cast_nullable_to_non_nullable
as List<Gift>,
  ));
}


}

// dart format on
