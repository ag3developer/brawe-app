// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'live_gift.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$LiveGift {

 String get id; String get senderId; String get senderName; String? get senderAvatarUrl; String get giftId; String get giftName;// Slug do gift (ex: "star", "rose") — usado para localizar o asset
// Lottie local (`assets/lottie_test/<slug>.json`) antes de cair no
// fallback remoto (`animationUrl`) ou no ícone estático PNG.
 String? get giftSlug; String? get giftIconUrl; String? get animationUrl; String? get animationType; bool get isFullscreen; String? get emoji; int get quantity; int get value; DateTime get timestamp;// ─── Gifter level (chip estilo TikTok no toast) ───
 int get gifterLevel; String? get gifterBadge;// emoji do badge (⭐, ⚡, 🛡️, 🔥, 👑, 💎)
 String? get gifterLabel;// "Fã", "Guardião", "Lenda", etc.
 String? get gifterColor;// hex string ex. "#FFD700"
 String? get gifterImageUrl;// PNG remoto do pin (CDN ou /static fallback)
 bool get levelUpgraded;// 🎯 Lado da batalha que recebeu o gift (`'a'` esquerda, `'b'` direita).
// `null` em lives solo. O toast do gift comum usa pra alinhar à lateral
// certa do split-screen (lado A → bottom-left, lado B → bottom-right).
// Gifts premium ignoram (mantêm burst central fullscreen).
 String? get battleSide;// 🎬 Flag de animação: true enquanto a animação está rodando (3s),
// false quando animação terminou mas notificação ainda está visível no chat (5s).
// Garante fluxo TikTok: overlay → [3s] → chat notification.
 bool get isAnimating;// ─── 🎯 Arquitetura profissional de exibição (4 modos) ───
// Sempre vem RESOLVIDO do backend (nunca null em payloads novos —
// ver `resolve_display_type()` no backend). Mantido nullable aqui
// apenas para tolerar payloads antigos/incompletos (app antigo,
// replay de evento histórico) — use [resolvedDisplayType] em vez de
// ler este campo diretamente.
 String? get displayType;// Prioridade visual na fila (0=chat, 10=center_small, 20=center_large,
// 30=fullscreen). Usar [resolvedPriority] para ter o fallback certo.
 int? get priority; bool get showInChat; bool get showSender; bool get soundEnabled;// Duração pretendida pelo backend (já validada/clampada lá, mas o
// Flutter reclampa de novo via `resolvedDisplayType.clampDuration()`
// como defesa em profundidade — nunca confiar só na rede).
 int? get animationDurationMs;
/// Create a copy of LiveGift
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LiveGiftCopyWith<LiveGift> get copyWith => _$LiveGiftCopyWithImpl<LiveGift>(this as LiveGift, _$identity);

  /// Serializes this LiveGift to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LiveGift&&(identical(other.id, id) || other.id == id)&&(identical(other.senderId, senderId) || other.senderId == senderId)&&(identical(other.senderName, senderName) || other.senderName == senderName)&&(identical(other.senderAvatarUrl, senderAvatarUrl) || other.senderAvatarUrl == senderAvatarUrl)&&(identical(other.giftId, giftId) || other.giftId == giftId)&&(identical(other.giftName, giftName) || other.giftName == giftName)&&(identical(other.giftSlug, giftSlug) || other.giftSlug == giftSlug)&&(identical(other.giftIconUrl, giftIconUrl) || other.giftIconUrl == giftIconUrl)&&(identical(other.animationUrl, animationUrl) || other.animationUrl == animationUrl)&&(identical(other.animationType, animationType) || other.animationType == animationType)&&(identical(other.isFullscreen, isFullscreen) || other.isFullscreen == isFullscreen)&&(identical(other.emoji, emoji) || other.emoji == emoji)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.value, value) || other.value == value)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.gifterLevel, gifterLevel) || other.gifterLevel == gifterLevel)&&(identical(other.gifterBadge, gifterBadge) || other.gifterBadge == gifterBadge)&&(identical(other.gifterLabel, gifterLabel) || other.gifterLabel == gifterLabel)&&(identical(other.gifterColor, gifterColor) || other.gifterColor == gifterColor)&&(identical(other.gifterImageUrl, gifterImageUrl) || other.gifterImageUrl == gifterImageUrl)&&(identical(other.levelUpgraded, levelUpgraded) || other.levelUpgraded == levelUpgraded)&&(identical(other.battleSide, battleSide) || other.battleSide == battleSide)&&(identical(other.isAnimating, isAnimating) || other.isAnimating == isAnimating)&&(identical(other.displayType, displayType) || other.displayType == displayType)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.showInChat, showInChat) || other.showInChat == showInChat)&&(identical(other.showSender, showSender) || other.showSender == showSender)&&(identical(other.soundEnabled, soundEnabled) || other.soundEnabled == soundEnabled)&&(identical(other.animationDurationMs, animationDurationMs) || other.animationDurationMs == animationDurationMs));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,senderId,senderName,senderAvatarUrl,giftId,giftName,giftSlug,giftIconUrl,animationUrl,animationType,isFullscreen,emoji,quantity,value,timestamp,gifterLevel,gifterBadge,gifterLabel,gifterColor,gifterImageUrl,levelUpgraded,battleSide,isAnimating,displayType,priority,showInChat,showSender,soundEnabled,animationDurationMs]);

@override
String toString() {
  return 'LiveGift(id: $id, senderId: $senderId, senderName: $senderName, senderAvatarUrl: $senderAvatarUrl, giftId: $giftId, giftName: $giftName, giftSlug: $giftSlug, giftIconUrl: $giftIconUrl, animationUrl: $animationUrl, animationType: $animationType, isFullscreen: $isFullscreen, emoji: $emoji, quantity: $quantity, value: $value, timestamp: $timestamp, gifterLevel: $gifterLevel, gifterBadge: $gifterBadge, gifterLabel: $gifterLabel, gifterColor: $gifterColor, gifterImageUrl: $gifterImageUrl, levelUpgraded: $levelUpgraded, battleSide: $battleSide, isAnimating: $isAnimating, displayType: $displayType, priority: $priority, showInChat: $showInChat, showSender: $showSender, soundEnabled: $soundEnabled, animationDurationMs: $animationDurationMs)';
}


}

/// @nodoc
abstract mixin class $LiveGiftCopyWith<$Res>  {
  factory $LiveGiftCopyWith(LiveGift value, $Res Function(LiveGift) _then) = _$LiveGiftCopyWithImpl;
@useResult
$Res call({
 String id, String senderId, String senderName, String? senderAvatarUrl, String giftId, String giftName, String? giftSlug, String? giftIconUrl, String? animationUrl, String? animationType, bool isFullscreen, String? emoji, int quantity, int value, DateTime timestamp, int gifterLevel, String? gifterBadge, String? gifterLabel, String? gifterColor, String? gifterImageUrl, bool levelUpgraded, String? battleSide, bool isAnimating, String? displayType, int? priority, bool showInChat, bool showSender, bool soundEnabled, int? animationDurationMs
});




}
/// @nodoc
class _$LiveGiftCopyWithImpl<$Res>
    implements $LiveGiftCopyWith<$Res> {
  _$LiveGiftCopyWithImpl(this._self, this._then);

  final LiveGift _self;
  final $Res Function(LiveGift) _then;

/// Create a copy of LiveGift
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? senderId = null,Object? senderName = null,Object? senderAvatarUrl = freezed,Object? giftId = null,Object? giftName = null,Object? giftSlug = freezed,Object? giftIconUrl = freezed,Object? animationUrl = freezed,Object? animationType = freezed,Object? isFullscreen = null,Object? emoji = freezed,Object? quantity = null,Object? value = null,Object? timestamp = null,Object? gifterLevel = null,Object? gifterBadge = freezed,Object? gifterLabel = freezed,Object? gifterColor = freezed,Object? gifterImageUrl = freezed,Object? levelUpgraded = null,Object? battleSide = freezed,Object? isAnimating = null,Object? displayType = freezed,Object? priority = freezed,Object? showInChat = null,Object? showSender = null,Object? soundEnabled = null,Object? animationDurationMs = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,senderId: null == senderId ? _self.senderId : senderId // ignore: cast_nullable_to_non_nullable
as String,senderName: null == senderName ? _self.senderName : senderName // ignore: cast_nullable_to_non_nullable
as String,senderAvatarUrl: freezed == senderAvatarUrl ? _self.senderAvatarUrl : senderAvatarUrl // ignore: cast_nullable_to_non_nullable
as String?,giftId: null == giftId ? _self.giftId : giftId // ignore: cast_nullable_to_non_nullable
as String,giftName: null == giftName ? _self.giftName : giftName // ignore: cast_nullable_to_non_nullable
as String,giftSlug: freezed == giftSlug ? _self.giftSlug : giftSlug // ignore: cast_nullable_to_non_nullable
as String?,giftIconUrl: freezed == giftIconUrl ? _self.giftIconUrl : giftIconUrl // ignore: cast_nullable_to_non_nullable
as String?,animationUrl: freezed == animationUrl ? _self.animationUrl : animationUrl // ignore: cast_nullable_to_non_nullable
as String?,animationType: freezed == animationType ? _self.animationType : animationType // ignore: cast_nullable_to_non_nullable
as String?,isFullscreen: null == isFullscreen ? _self.isFullscreen : isFullscreen // ignore: cast_nullable_to_non_nullable
as bool,emoji: freezed == emoji ? _self.emoji : emoji // ignore: cast_nullable_to_non_nullable
as String?,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as int,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,gifterLevel: null == gifterLevel ? _self.gifterLevel : gifterLevel // ignore: cast_nullable_to_non_nullable
as int,gifterBadge: freezed == gifterBadge ? _self.gifterBadge : gifterBadge // ignore: cast_nullable_to_non_nullable
as String?,gifterLabel: freezed == gifterLabel ? _self.gifterLabel : gifterLabel // ignore: cast_nullable_to_non_nullable
as String?,gifterColor: freezed == gifterColor ? _self.gifterColor : gifterColor // ignore: cast_nullable_to_non_nullable
as String?,gifterImageUrl: freezed == gifterImageUrl ? _self.gifterImageUrl : gifterImageUrl // ignore: cast_nullable_to_non_nullable
as String?,levelUpgraded: null == levelUpgraded ? _self.levelUpgraded : levelUpgraded // ignore: cast_nullable_to_non_nullable
as bool,battleSide: freezed == battleSide ? _self.battleSide : battleSide // ignore: cast_nullable_to_non_nullable
as String?,isAnimating: null == isAnimating ? _self.isAnimating : isAnimating // ignore: cast_nullable_to_non_nullable
as bool,displayType: freezed == displayType ? _self.displayType : displayType // ignore: cast_nullable_to_non_nullable
as String?,priority: freezed == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as int?,showInChat: null == showInChat ? _self.showInChat : showInChat // ignore: cast_nullable_to_non_nullable
as bool,showSender: null == showSender ? _self.showSender : showSender // ignore: cast_nullable_to_non_nullable
as bool,soundEnabled: null == soundEnabled ? _self.soundEnabled : soundEnabled // ignore: cast_nullable_to_non_nullable
as bool,animationDurationMs: freezed == animationDurationMs ? _self.animationDurationMs : animationDurationMs // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [LiveGift].
extension LiveGiftPatterns on LiveGift {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LiveGift value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LiveGift() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LiveGift value)  $default,){
final _that = this;
switch (_that) {
case _LiveGift():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LiveGift value)?  $default,){
final _that = this;
switch (_that) {
case _LiveGift() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String senderId,  String senderName,  String? senderAvatarUrl,  String giftId,  String giftName,  String? giftSlug,  String? giftIconUrl,  String? animationUrl,  String? animationType,  bool isFullscreen,  String? emoji,  int quantity,  int value,  DateTime timestamp,  int gifterLevel,  String? gifterBadge,  String? gifterLabel,  String? gifterColor,  String? gifterImageUrl,  bool levelUpgraded,  String? battleSide,  bool isAnimating,  String? displayType,  int? priority,  bool showInChat,  bool showSender,  bool soundEnabled,  int? animationDurationMs)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LiveGift() when $default != null:
return $default(_that.id,_that.senderId,_that.senderName,_that.senderAvatarUrl,_that.giftId,_that.giftName,_that.giftSlug,_that.giftIconUrl,_that.animationUrl,_that.animationType,_that.isFullscreen,_that.emoji,_that.quantity,_that.value,_that.timestamp,_that.gifterLevel,_that.gifterBadge,_that.gifterLabel,_that.gifterColor,_that.gifterImageUrl,_that.levelUpgraded,_that.battleSide,_that.isAnimating,_that.displayType,_that.priority,_that.showInChat,_that.showSender,_that.soundEnabled,_that.animationDurationMs);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String senderId,  String senderName,  String? senderAvatarUrl,  String giftId,  String giftName,  String? giftSlug,  String? giftIconUrl,  String? animationUrl,  String? animationType,  bool isFullscreen,  String? emoji,  int quantity,  int value,  DateTime timestamp,  int gifterLevel,  String? gifterBadge,  String? gifterLabel,  String? gifterColor,  String? gifterImageUrl,  bool levelUpgraded,  String? battleSide,  bool isAnimating,  String? displayType,  int? priority,  bool showInChat,  bool showSender,  bool soundEnabled,  int? animationDurationMs)  $default,) {final _that = this;
switch (_that) {
case _LiveGift():
return $default(_that.id,_that.senderId,_that.senderName,_that.senderAvatarUrl,_that.giftId,_that.giftName,_that.giftSlug,_that.giftIconUrl,_that.animationUrl,_that.animationType,_that.isFullscreen,_that.emoji,_that.quantity,_that.value,_that.timestamp,_that.gifterLevel,_that.gifterBadge,_that.gifterLabel,_that.gifterColor,_that.gifterImageUrl,_that.levelUpgraded,_that.battleSide,_that.isAnimating,_that.displayType,_that.priority,_that.showInChat,_that.showSender,_that.soundEnabled,_that.animationDurationMs);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String senderId,  String senderName,  String? senderAvatarUrl,  String giftId,  String giftName,  String? giftSlug,  String? giftIconUrl,  String? animationUrl,  String? animationType,  bool isFullscreen,  String? emoji,  int quantity,  int value,  DateTime timestamp,  int gifterLevel,  String? gifterBadge,  String? gifterLabel,  String? gifterColor,  String? gifterImageUrl,  bool levelUpgraded,  String? battleSide,  bool isAnimating,  String? displayType,  int? priority,  bool showInChat,  bool showSender,  bool soundEnabled,  int? animationDurationMs)?  $default,) {final _that = this;
switch (_that) {
case _LiveGift() when $default != null:
return $default(_that.id,_that.senderId,_that.senderName,_that.senderAvatarUrl,_that.giftId,_that.giftName,_that.giftSlug,_that.giftIconUrl,_that.animationUrl,_that.animationType,_that.isFullscreen,_that.emoji,_that.quantity,_that.value,_that.timestamp,_that.gifterLevel,_that.gifterBadge,_that.gifterLabel,_that.gifterColor,_that.gifterImageUrl,_that.levelUpgraded,_that.battleSide,_that.isAnimating,_that.displayType,_that.priority,_that.showInChat,_that.showSender,_that.soundEnabled,_that.animationDurationMs);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LiveGift extends LiveGift {
  const _LiveGift({required this.id, required this.senderId, required this.senderName, this.senderAvatarUrl, required this.giftId, required this.giftName, this.giftSlug, this.giftIconUrl, this.animationUrl, this.animationType, this.isFullscreen = false, this.emoji, required this.quantity, this.value = 0, required this.timestamp, this.gifterLevel = 1, this.gifterBadge, this.gifterLabel, this.gifterColor, this.gifterImageUrl, this.levelUpgraded = false, this.battleSide, this.isAnimating = true, this.displayType, this.priority, this.showInChat = true, this.showSender = true, this.soundEnabled = false, this.animationDurationMs}): super._();
  factory _LiveGift.fromJson(Map<String, dynamic> json) => _$LiveGiftFromJson(json);

@override final  String id;
@override final  String senderId;
@override final  String senderName;
@override final  String? senderAvatarUrl;
@override final  String giftId;
@override final  String giftName;
// Slug do gift (ex: "star", "rose") — usado para localizar o asset
// Lottie local (`assets/lottie_test/<slug>.json`) antes de cair no
// fallback remoto (`animationUrl`) ou no ícone estático PNG.
@override final  String? giftSlug;
@override final  String? giftIconUrl;
@override final  String? animationUrl;
@override final  String? animationType;
@override@JsonKey() final  bool isFullscreen;
@override final  String? emoji;
@override final  int quantity;
@override@JsonKey() final  int value;
@override final  DateTime timestamp;
// ─── Gifter level (chip estilo TikTok no toast) ───
@override@JsonKey() final  int gifterLevel;
@override final  String? gifterBadge;
// emoji do badge (⭐, ⚡, 🛡️, 🔥, 👑, 💎)
@override final  String? gifterLabel;
// "Fã", "Guardião", "Lenda", etc.
@override final  String? gifterColor;
// hex string ex. "#FFD700"
@override final  String? gifterImageUrl;
// PNG remoto do pin (CDN ou /static fallback)
@override@JsonKey() final  bool levelUpgraded;
// 🎯 Lado da batalha que recebeu o gift (`'a'` esquerda, `'b'` direita).
// `null` em lives solo. O toast do gift comum usa pra alinhar à lateral
// certa do split-screen (lado A → bottom-left, lado B → bottom-right).
// Gifts premium ignoram (mantêm burst central fullscreen).
@override final  String? battleSide;
// 🎬 Flag de animação: true enquanto a animação está rodando (3s),
// false quando animação terminou mas notificação ainda está visível no chat (5s).
// Garante fluxo TikTok: overlay → [3s] → chat notification.
@override@JsonKey() final  bool isAnimating;
// ─── 🎯 Arquitetura profissional de exibição (4 modos) ───
// Sempre vem RESOLVIDO do backend (nunca null em payloads novos —
// ver `resolve_display_type()` no backend). Mantido nullable aqui
// apenas para tolerar payloads antigos/incompletos (app antigo,
// replay de evento histórico) — use [resolvedDisplayType] em vez de
// ler este campo diretamente.
@override final  String? displayType;
// Prioridade visual na fila (0=chat, 10=center_small, 20=center_large,
// 30=fullscreen). Usar [resolvedPriority] para ter o fallback certo.
@override final  int? priority;
@override@JsonKey() final  bool showInChat;
@override@JsonKey() final  bool showSender;
@override@JsonKey() final  bool soundEnabled;
// Duração pretendida pelo backend (já validada/clampada lá, mas o
// Flutter reclampa de novo via `resolvedDisplayType.clampDuration()`
// como defesa em profundidade — nunca confiar só na rede).
@override final  int? animationDurationMs;

/// Create a copy of LiveGift
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LiveGiftCopyWith<_LiveGift> get copyWith => __$LiveGiftCopyWithImpl<_LiveGift>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LiveGiftToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LiveGift&&(identical(other.id, id) || other.id == id)&&(identical(other.senderId, senderId) || other.senderId == senderId)&&(identical(other.senderName, senderName) || other.senderName == senderName)&&(identical(other.senderAvatarUrl, senderAvatarUrl) || other.senderAvatarUrl == senderAvatarUrl)&&(identical(other.giftId, giftId) || other.giftId == giftId)&&(identical(other.giftName, giftName) || other.giftName == giftName)&&(identical(other.giftSlug, giftSlug) || other.giftSlug == giftSlug)&&(identical(other.giftIconUrl, giftIconUrl) || other.giftIconUrl == giftIconUrl)&&(identical(other.animationUrl, animationUrl) || other.animationUrl == animationUrl)&&(identical(other.animationType, animationType) || other.animationType == animationType)&&(identical(other.isFullscreen, isFullscreen) || other.isFullscreen == isFullscreen)&&(identical(other.emoji, emoji) || other.emoji == emoji)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.value, value) || other.value == value)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.gifterLevel, gifterLevel) || other.gifterLevel == gifterLevel)&&(identical(other.gifterBadge, gifterBadge) || other.gifterBadge == gifterBadge)&&(identical(other.gifterLabel, gifterLabel) || other.gifterLabel == gifterLabel)&&(identical(other.gifterColor, gifterColor) || other.gifterColor == gifterColor)&&(identical(other.gifterImageUrl, gifterImageUrl) || other.gifterImageUrl == gifterImageUrl)&&(identical(other.levelUpgraded, levelUpgraded) || other.levelUpgraded == levelUpgraded)&&(identical(other.battleSide, battleSide) || other.battleSide == battleSide)&&(identical(other.isAnimating, isAnimating) || other.isAnimating == isAnimating)&&(identical(other.displayType, displayType) || other.displayType == displayType)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.showInChat, showInChat) || other.showInChat == showInChat)&&(identical(other.showSender, showSender) || other.showSender == showSender)&&(identical(other.soundEnabled, soundEnabled) || other.soundEnabled == soundEnabled)&&(identical(other.animationDurationMs, animationDurationMs) || other.animationDurationMs == animationDurationMs));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,senderId,senderName,senderAvatarUrl,giftId,giftName,giftSlug,giftIconUrl,animationUrl,animationType,isFullscreen,emoji,quantity,value,timestamp,gifterLevel,gifterBadge,gifterLabel,gifterColor,gifterImageUrl,levelUpgraded,battleSide,isAnimating,displayType,priority,showInChat,showSender,soundEnabled,animationDurationMs]);

@override
String toString() {
  return 'LiveGift(id: $id, senderId: $senderId, senderName: $senderName, senderAvatarUrl: $senderAvatarUrl, giftId: $giftId, giftName: $giftName, giftSlug: $giftSlug, giftIconUrl: $giftIconUrl, animationUrl: $animationUrl, animationType: $animationType, isFullscreen: $isFullscreen, emoji: $emoji, quantity: $quantity, value: $value, timestamp: $timestamp, gifterLevel: $gifterLevel, gifterBadge: $gifterBadge, gifterLabel: $gifterLabel, gifterColor: $gifterColor, gifterImageUrl: $gifterImageUrl, levelUpgraded: $levelUpgraded, battleSide: $battleSide, isAnimating: $isAnimating, displayType: $displayType, priority: $priority, showInChat: $showInChat, showSender: $showSender, soundEnabled: $soundEnabled, animationDurationMs: $animationDurationMs)';
}


}

/// @nodoc
abstract mixin class _$LiveGiftCopyWith<$Res> implements $LiveGiftCopyWith<$Res> {
  factory _$LiveGiftCopyWith(_LiveGift value, $Res Function(_LiveGift) _then) = __$LiveGiftCopyWithImpl;
@override @useResult
$Res call({
 String id, String senderId, String senderName, String? senderAvatarUrl, String giftId, String giftName, String? giftSlug, String? giftIconUrl, String? animationUrl, String? animationType, bool isFullscreen, String? emoji, int quantity, int value, DateTime timestamp, int gifterLevel, String? gifterBadge, String? gifterLabel, String? gifterColor, String? gifterImageUrl, bool levelUpgraded, String? battleSide, bool isAnimating, String? displayType, int? priority, bool showInChat, bool showSender, bool soundEnabled, int? animationDurationMs
});




}
/// @nodoc
class __$LiveGiftCopyWithImpl<$Res>
    implements _$LiveGiftCopyWith<$Res> {
  __$LiveGiftCopyWithImpl(this._self, this._then);

  final _LiveGift _self;
  final $Res Function(_LiveGift) _then;

/// Create a copy of LiveGift
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? senderId = null,Object? senderName = null,Object? senderAvatarUrl = freezed,Object? giftId = null,Object? giftName = null,Object? giftSlug = freezed,Object? giftIconUrl = freezed,Object? animationUrl = freezed,Object? animationType = freezed,Object? isFullscreen = null,Object? emoji = freezed,Object? quantity = null,Object? value = null,Object? timestamp = null,Object? gifterLevel = null,Object? gifterBadge = freezed,Object? gifterLabel = freezed,Object? gifterColor = freezed,Object? gifterImageUrl = freezed,Object? levelUpgraded = null,Object? battleSide = freezed,Object? isAnimating = null,Object? displayType = freezed,Object? priority = freezed,Object? showInChat = null,Object? showSender = null,Object? soundEnabled = null,Object? animationDurationMs = freezed,}) {
  return _then(_LiveGift(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,senderId: null == senderId ? _self.senderId : senderId // ignore: cast_nullable_to_non_nullable
as String,senderName: null == senderName ? _self.senderName : senderName // ignore: cast_nullable_to_non_nullable
as String,senderAvatarUrl: freezed == senderAvatarUrl ? _self.senderAvatarUrl : senderAvatarUrl // ignore: cast_nullable_to_non_nullable
as String?,giftId: null == giftId ? _self.giftId : giftId // ignore: cast_nullable_to_non_nullable
as String,giftName: null == giftName ? _self.giftName : giftName // ignore: cast_nullable_to_non_nullable
as String,giftSlug: freezed == giftSlug ? _self.giftSlug : giftSlug // ignore: cast_nullable_to_non_nullable
as String?,giftIconUrl: freezed == giftIconUrl ? _self.giftIconUrl : giftIconUrl // ignore: cast_nullable_to_non_nullable
as String?,animationUrl: freezed == animationUrl ? _self.animationUrl : animationUrl // ignore: cast_nullable_to_non_nullable
as String?,animationType: freezed == animationType ? _self.animationType : animationType // ignore: cast_nullable_to_non_nullable
as String?,isFullscreen: null == isFullscreen ? _self.isFullscreen : isFullscreen // ignore: cast_nullable_to_non_nullable
as bool,emoji: freezed == emoji ? _self.emoji : emoji // ignore: cast_nullable_to_non_nullable
as String?,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as int,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,gifterLevel: null == gifterLevel ? _self.gifterLevel : gifterLevel // ignore: cast_nullable_to_non_nullable
as int,gifterBadge: freezed == gifterBadge ? _self.gifterBadge : gifterBadge // ignore: cast_nullable_to_non_nullable
as String?,gifterLabel: freezed == gifterLabel ? _self.gifterLabel : gifterLabel // ignore: cast_nullable_to_non_nullable
as String?,gifterColor: freezed == gifterColor ? _self.gifterColor : gifterColor // ignore: cast_nullable_to_non_nullable
as String?,gifterImageUrl: freezed == gifterImageUrl ? _self.gifterImageUrl : gifterImageUrl // ignore: cast_nullable_to_non_nullable
as String?,levelUpgraded: null == levelUpgraded ? _self.levelUpgraded : levelUpgraded // ignore: cast_nullable_to_non_nullable
as bool,battleSide: freezed == battleSide ? _self.battleSide : battleSide // ignore: cast_nullable_to_non_nullable
as String?,isAnimating: null == isAnimating ? _self.isAnimating : isAnimating // ignore: cast_nullable_to_non_nullable
as bool,displayType: freezed == displayType ? _self.displayType : displayType // ignore: cast_nullable_to_non_nullable
as String?,priority: freezed == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as int?,showInChat: null == showInChat ? _self.showInChat : showInChat // ignore: cast_nullable_to_non_nullable
as bool,showSender: null == showSender ? _self.showSender : showSender // ignore: cast_nullable_to_non_nullable
as bool,soundEnabled: null == soundEnabled ? _self.soundEnabled : soundEnabled // ignore: cast_nullable_to_non_nullable
as bool,animationDurationMs: freezed == animationDurationMs ? _self.animationDurationMs : animationDurationMs // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
