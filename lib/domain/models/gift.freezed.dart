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

 String get id; String get slug; String get name; String? get emoji;@JsonKey(name: 'icon_url') String? get iconUrl;@JsonKey(name: 'animation_url') String? get animationUrl;@JsonKey(name: 'animation_type') String get animationType;// Som do efeito (Lottie/imagem). O vídeo VAP já traz o som dentro.
@JsonKey(name: 'sound_url') String? get soundUrl;@JsonKey(name: 'price_credits') double get priceCredits;@JsonKey(name: 'price_usdt') double get priceUsdt; String get tier;@JsonKey(name: 'is_fullscreen') bool get isFullscreen;@JsonKey(name: 'animation_duration_ms') int get animationDurationMs;@JsonKey(name: 'combo_enabled') bool get comboEnabled;// ── Economia não-monetária (FREE) ──
@JsonKey(name: 'is_monetary') bool get isMonetary;@JsonKey(name: 'price_coins') int get priceCoins;@JsonKey(name: 'cooldown_seconds') int get cooldownSeconds;
/// Create a copy of Gift
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GiftCopyWith<Gift> get copyWith => _$GiftCopyWithImpl<Gift>(this as Gift, _$identity);

  /// Serializes this Gift to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Gift&&(identical(other.id, id) || other.id == id)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.name, name) || other.name == name)&&(identical(other.emoji, emoji) || other.emoji == emoji)&&(identical(other.iconUrl, iconUrl) || other.iconUrl == iconUrl)&&(identical(other.animationUrl, animationUrl) || other.animationUrl == animationUrl)&&(identical(other.animationType, animationType) || other.animationType == animationType)&&(identical(other.soundUrl, soundUrl) || other.soundUrl == soundUrl)&&(identical(other.priceCredits, priceCredits) || other.priceCredits == priceCredits)&&(identical(other.priceUsdt, priceUsdt) || other.priceUsdt == priceUsdt)&&(identical(other.tier, tier) || other.tier == tier)&&(identical(other.isFullscreen, isFullscreen) || other.isFullscreen == isFullscreen)&&(identical(other.animationDurationMs, animationDurationMs) || other.animationDurationMs == animationDurationMs)&&(identical(other.comboEnabled, comboEnabled) || other.comboEnabled == comboEnabled)&&(identical(other.isMonetary, isMonetary) || other.isMonetary == isMonetary)&&(identical(other.priceCoins, priceCoins) || other.priceCoins == priceCoins)&&(identical(other.cooldownSeconds, cooldownSeconds) || other.cooldownSeconds == cooldownSeconds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,slug,name,emoji,iconUrl,animationUrl,animationType,soundUrl,priceCredits,priceUsdt,tier,isFullscreen,animationDurationMs,comboEnabled,isMonetary,priceCoins,cooldownSeconds);

@override
String toString() {
  return 'Gift(id: $id, slug: $slug, name: $name, emoji: $emoji, iconUrl: $iconUrl, animationUrl: $animationUrl, animationType: $animationType, soundUrl: $soundUrl, priceCredits: $priceCredits, priceUsdt: $priceUsdt, tier: $tier, isFullscreen: $isFullscreen, animationDurationMs: $animationDurationMs, comboEnabled: $comboEnabled, isMonetary: $isMonetary, priceCoins: $priceCoins, cooldownSeconds: $cooldownSeconds)';
}


}

/// @nodoc
abstract mixin class $GiftCopyWith<$Res>  {
  factory $GiftCopyWith(Gift value, $Res Function(Gift) _then) = _$GiftCopyWithImpl;
@useResult
$Res call({
 String id, String slug, String name, String? emoji,@JsonKey(name: 'icon_url') String? iconUrl,@JsonKey(name: 'animation_url') String? animationUrl,@JsonKey(name: 'animation_type') String animationType,@JsonKey(name: 'sound_url') String? soundUrl,@JsonKey(name: 'price_credits') double priceCredits,@JsonKey(name: 'price_usdt') double priceUsdt, String tier,@JsonKey(name: 'is_fullscreen') bool isFullscreen,@JsonKey(name: 'animation_duration_ms') int animationDurationMs,@JsonKey(name: 'combo_enabled') bool comboEnabled,@JsonKey(name: 'is_monetary') bool isMonetary,@JsonKey(name: 'price_coins') int priceCoins,@JsonKey(name: 'cooldown_seconds') int cooldownSeconds
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
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? slug = null,Object? name = null,Object? emoji = freezed,Object? iconUrl = freezed,Object? animationUrl = freezed,Object? animationType = null,Object? soundUrl = freezed,Object? priceCredits = null,Object? priceUsdt = null,Object? tier = null,Object? isFullscreen = null,Object? animationDurationMs = null,Object? comboEnabled = null,Object? isMonetary = null,Object? priceCoins = null,Object? cooldownSeconds = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,slug: null == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,emoji: freezed == emoji ? _self.emoji : emoji // ignore: cast_nullable_to_non_nullable
as String?,iconUrl: freezed == iconUrl ? _self.iconUrl : iconUrl // ignore: cast_nullable_to_non_nullable
as String?,animationUrl: freezed == animationUrl ? _self.animationUrl : animationUrl // ignore: cast_nullable_to_non_nullable
as String?,animationType: null == animationType ? _self.animationType : animationType // ignore: cast_nullable_to_non_nullable
as String,soundUrl: freezed == soundUrl ? _self.soundUrl : soundUrl // ignore: cast_nullable_to_non_nullable
as String?,priceCredits: null == priceCredits ? _self.priceCredits : priceCredits // ignore: cast_nullable_to_non_nullable
as double,priceUsdt: null == priceUsdt ? _self.priceUsdt : priceUsdt // ignore: cast_nullable_to_non_nullable
as double,tier: null == tier ? _self.tier : tier // ignore: cast_nullable_to_non_nullable
as String,isFullscreen: null == isFullscreen ? _self.isFullscreen : isFullscreen // ignore: cast_nullable_to_non_nullable
as bool,animationDurationMs: null == animationDurationMs ? _self.animationDurationMs : animationDurationMs // ignore: cast_nullable_to_non_nullable
as int,comboEnabled: null == comboEnabled ? _self.comboEnabled : comboEnabled // ignore: cast_nullable_to_non_nullable
as bool,isMonetary: null == isMonetary ? _self.isMonetary : isMonetary // ignore: cast_nullable_to_non_nullable
as bool,priceCoins: null == priceCoins ? _self.priceCoins : priceCoins // ignore: cast_nullable_to_non_nullable
as int,cooldownSeconds: null == cooldownSeconds ? _self.cooldownSeconds : cooldownSeconds // ignore: cast_nullable_to_non_nullable
as int,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String slug,  String name,  String? emoji, @JsonKey(name: 'icon_url')  String? iconUrl, @JsonKey(name: 'animation_url')  String? animationUrl, @JsonKey(name: 'animation_type')  String animationType, @JsonKey(name: 'sound_url')  String? soundUrl, @JsonKey(name: 'price_credits')  double priceCredits, @JsonKey(name: 'price_usdt')  double priceUsdt,  String tier, @JsonKey(name: 'is_fullscreen')  bool isFullscreen, @JsonKey(name: 'animation_duration_ms')  int animationDurationMs, @JsonKey(name: 'combo_enabled')  bool comboEnabled, @JsonKey(name: 'is_monetary')  bool isMonetary, @JsonKey(name: 'price_coins')  int priceCoins, @JsonKey(name: 'cooldown_seconds')  int cooldownSeconds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Gift() when $default != null:
return $default(_that.id,_that.slug,_that.name,_that.emoji,_that.iconUrl,_that.animationUrl,_that.animationType,_that.soundUrl,_that.priceCredits,_that.priceUsdt,_that.tier,_that.isFullscreen,_that.animationDurationMs,_that.comboEnabled,_that.isMonetary,_that.priceCoins,_that.cooldownSeconds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String slug,  String name,  String? emoji, @JsonKey(name: 'icon_url')  String? iconUrl, @JsonKey(name: 'animation_url')  String? animationUrl, @JsonKey(name: 'animation_type')  String animationType, @JsonKey(name: 'sound_url')  String? soundUrl, @JsonKey(name: 'price_credits')  double priceCredits, @JsonKey(name: 'price_usdt')  double priceUsdt,  String tier, @JsonKey(name: 'is_fullscreen')  bool isFullscreen, @JsonKey(name: 'animation_duration_ms')  int animationDurationMs, @JsonKey(name: 'combo_enabled')  bool comboEnabled, @JsonKey(name: 'is_monetary')  bool isMonetary, @JsonKey(name: 'price_coins')  int priceCoins, @JsonKey(name: 'cooldown_seconds')  int cooldownSeconds)  $default,) {final _that = this;
switch (_that) {
case _Gift():
return $default(_that.id,_that.slug,_that.name,_that.emoji,_that.iconUrl,_that.animationUrl,_that.animationType,_that.soundUrl,_that.priceCredits,_that.priceUsdt,_that.tier,_that.isFullscreen,_that.animationDurationMs,_that.comboEnabled,_that.isMonetary,_that.priceCoins,_that.cooldownSeconds);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String slug,  String name,  String? emoji, @JsonKey(name: 'icon_url')  String? iconUrl, @JsonKey(name: 'animation_url')  String? animationUrl, @JsonKey(name: 'animation_type')  String animationType, @JsonKey(name: 'sound_url')  String? soundUrl, @JsonKey(name: 'price_credits')  double priceCredits, @JsonKey(name: 'price_usdt')  double priceUsdt,  String tier, @JsonKey(name: 'is_fullscreen')  bool isFullscreen, @JsonKey(name: 'animation_duration_ms')  int animationDurationMs, @JsonKey(name: 'combo_enabled')  bool comboEnabled, @JsonKey(name: 'is_monetary')  bool isMonetary, @JsonKey(name: 'price_coins')  int priceCoins, @JsonKey(name: 'cooldown_seconds')  int cooldownSeconds)?  $default,) {final _that = this;
switch (_that) {
case _Gift() when $default != null:
return $default(_that.id,_that.slug,_that.name,_that.emoji,_that.iconUrl,_that.animationUrl,_that.animationType,_that.soundUrl,_that.priceCredits,_that.priceUsdt,_that.tier,_that.isFullscreen,_that.animationDurationMs,_that.comboEnabled,_that.isMonetary,_that.priceCoins,_that.cooldownSeconds);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Gift extends Gift {
  const _Gift({required this.id, required this.slug, required this.name, this.emoji, @JsonKey(name: 'icon_url') this.iconUrl, @JsonKey(name: 'animation_url') this.animationUrl, @JsonKey(name: 'animation_type') this.animationType = 'video', @JsonKey(name: 'sound_url') this.soundUrl, @JsonKey(name: 'price_credits') this.priceCredits = 0.0, @JsonKey(name: 'price_usdt') this.priceUsdt = 0.0, this.tier = 'basic', @JsonKey(name: 'is_fullscreen') this.isFullscreen = false, @JsonKey(name: 'animation_duration_ms') this.animationDurationMs = 0, @JsonKey(name: 'combo_enabled') this.comboEnabled = false, @JsonKey(name: 'is_monetary') this.isMonetary = true, @JsonKey(name: 'price_coins') this.priceCoins = 0, @JsonKey(name: 'cooldown_seconds') this.cooldownSeconds = 0}): super._();
  factory _Gift.fromJson(Map<String, dynamic> json) => _$GiftFromJson(json);

@override final  String id;
@override final  String slug;
@override final  String name;
@override final  String? emoji;
@override@JsonKey(name: 'icon_url') final  String? iconUrl;
@override@JsonKey(name: 'animation_url') final  String? animationUrl;
@override@JsonKey(name: 'animation_type') final  String animationType;
// Som do efeito (Lottie/imagem). O vídeo VAP já traz o som dentro.
@override@JsonKey(name: 'sound_url') final  String? soundUrl;
@override@JsonKey(name: 'price_credits') final  double priceCredits;
@override@JsonKey(name: 'price_usdt') final  double priceUsdt;
@override@JsonKey() final  String tier;
@override@JsonKey(name: 'is_fullscreen') final  bool isFullscreen;
@override@JsonKey(name: 'animation_duration_ms') final  int animationDurationMs;
@override@JsonKey(name: 'combo_enabled') final  bool comboEnabled;
// ── Economia não-monetária (FREE) ──
@override@JsonKey(name: 'is_monetary') final  bool isMonetary;
@override@JsonKey(name: 'price_coins') final  int priceCoins;
@override@JsonKey(name: 'cooldown_seconds') final  int cooldownSeconds;

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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Gift&&(identical(other.id, id) || other.id == id)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.name, name) || other.name == name)&&(identical(other.emoji, emoji) || other.emoji == emoji)&&(identical(other.iconUrl, iconUrl) || other.iconUrl == iconUrl)&&(identical(other.animationUrl, animationUrl) || other.animationUrl == animationUrl)&&(identical(other.animationType, animationType) || other.animationType == animationType)&&(identical(other.soundUrl, soundUrl) || other.soundUrl == soundUrl)&&(identical(other.priceCredits, priceCredits) || other.priceCredits == priceCredits)&&(identical(other.priceUsdt, priceUsdt) || other.priceUsdt == priceUsdt)&&(identical(other.tier, tier) || other.tier == tier)&&(identical(other.isFullscreen, isFullscreen) || other.isFullscreen == isFullscreen)&&(identical(other.animationDurationMs, animationDurationMs) || other.animationDurationMs == animationDurationMs)&&(identical(other.comboEnabled, comboEnabled) || other.comboEnabled == comboEnabled)&&(identical(other.isMonetary, isMonetary) || other.isMonetary == isMonetary)&&(identical(other.priceCoins, priceCoins) || other.priceCoins == priceCoins)&&(identical(other.cooldownSeconds, cooldownSeconds) || other.cooldownSeconds == cooldownSeconds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,slug,name,emoji,iconUrl,animationUrl,animationType,soundUrl,priceCredits,priceUsdt,tier,isFullscreen,animationDurationMs,comboEnabled,isMonetary,priceCoins,cooldownSeconds);

@override
String toString() {
  return 'Gift(id: $id, slug: $slug, name: $name, emoji: $emoji, iconUrl: $iconUrl, animationUrl: $animationUrl, animationType: $animationType, soundUrl: $soundUrl, priceCredits: $priceCredits, priceUsdt: $priceUsdt, tier: $tier, isFullscreen: $isFullscreen, animationDurationMs: $animationDurationMs, comboEnabled: $comboEnabled, isMonetary: $isMonetary, priceCoins: $priceCoins, cooldownSeconds: $cooldownSeconds)';
}


}

/// @nodoc
abstract mixin class _$GiftCopyWith<$Res> implements $GiftCopyWith<$Res> {
  factory _$GiftCopyWith(_Gift value, $Res Function(_Gift) _then) = __$GiftCopyWithImpl;
@override @useResult
$Res call({
 String id, String slug, String name, String? emoji,@JsonKey(name: 'icon_url') String? iconUrl,@JsonKey(name: 'animation_url') String? animationUrl,@JsonKey(name: 'animation_type') String animationType,@JsonKey(name: 'sound_url') String? soundUrl,@JsonKey(name: 'price_credits') double priceCredits,@JsonKey(name: 'price_usdt') double priceUsdt, String tier,@JsonKey(name: 'is_fullscreen') bool isFullscreen,@JsonKey(name: 'animation_duration_ms') int animationDurationMs,@JsonKey(name: 'combo_enabled') bool comboEnabled,@JsonKey(name: 'is_monetary') bool isMonetary,@JsonKey(name: 'price_coins') int priceCoins,@JsonKey(name: 'cooldown_seconds') int cooldownSeconds
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
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? slug = null,Object? name = null,Object? emoji = freezed,Object? iconUrl = freezed,Object? animationUrl = freezed,Object? animationType = null,Object? soundUrl = freezed,Object? priceCredits = null,Object? priceUsdt = null,Object? tier = null,Object? isFullscreen = null,Object? animationDurationMs = null,Object? comboEnabled = null,Object? isMonetary = null,Object? priceCoins = null,Object? cooldownSeconds = null,}) {
  return _then(_Gift(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,slug: null == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,emoji: freezed == emoji ? _self.emoji : emoji // ignore: cast_nullable_to_non_nullable
as String?,iconUrl: freezed == iconUrl ? _self.iconUrl : iconUrl // ignore: cast_nullable_to_non_nullable
as String?,animationUrl: freezed == animationUrl ? _self.animationUrl : animationUrl // ignore: cast_nullable_to_non_nullable
as String?,animationType: null == animationType ? _self.animationType : animationType // ignore: cast_nullable_to_non_nullable
as String,soundUrl: freezed == soundUrl ? _self.soundUrl : soundUrl // ignore: cast_nullable_to_non_nullable
as String?,priceCredits: null == priceCredits ? _self.priceCredits : priceCredits // ignore: cast_nullable_to_non_nullable
as double,priceUsdt: null == priceUsdt ? _self.priceUsdt : priceUsdt // ignore: cast_nullable_to_non_nullable
as double,tier: null == tier ? _self.tier : tier // ignore: cast_nullable_to_non_nullable
as String,isFullscreen: null == isFullscreen ? _self.isFullscreen : isFullscreen // ignore: cast_nullable_to_non_nullable
as bool,animationDurationMs: null == animationDurationMs ? _self.animationDurationMs : animationDurationMs // ignore: cast_nullable_to_non_nullable
as int,comboEnabled: null == comboEnabled ? _self.comboEnabled : comboEnabled // ignore: cast_nullable_to_non_nullable
as bool,isMonetary: null == isMonetary ? _self.isMonetary : isMonetary // ignore: cast_nullable_to_non_nullable
as bool,priceCoins: null == priceCoins ? _self.priceCoins : priceCoins // ignore: cast_nullable_to_non_nullable
as int,cooldownSeconds: null == cooldownSeconds ? _self.cooldownSeconds : cooldownSeconds // ignore: cast_nullable_to_non_nullable
as int,
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
