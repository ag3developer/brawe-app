// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'live_room.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$LiveRoom {

 String get id; String get slug; String get title; String? get description; String? get category; String get liveType; bool get isPrivate; String get status; int get viewerCount; int get totalLikes; int get totalMessages; bool get isPaused; DateTime? get pausedAt; String? get playbackId; String? get streamUrl; String? get rtmpUrl; String? get streamKey; String? get thumbnailUrl; String get streamerId; String get streamerName; String? get streamerAvatarUrl; String? get streamerUsername; bool get streamerVerified;
/// Create a copy of LiveRoom
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LiveRoomCopyWith<LiveRoom> get copyWith => _$LiveRoomCopyWithImpl<LiveRoom>(this as LiveRoom, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LiveRoom&&(identical(other.id, id) || other.id == id)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.category, category) || other.category == category)&&(identical(other.liveType, liveType) || other.liveType == liveType)&&(identical(other.isPrivate, isPrivate) || other.isPrivate == isPrivate)&&(identical(other.status, status) || other.status == status)&&(identical(other.viewerCount, viewerCount) || other.viewerCount == viewerCount)&&(identical(other.totalLikes, totalLikes) || other.totalLikes == totalLikes)&&(identical(other.totalMessages, totalMessages) || other.totalMessages == totalMessages)&&(identical(other.isPaused, isPaused) || other.isPaused == isPaused)&&(identical(other.pausedAt, pausedAt) || other.pausedAt == pausedAt)&&(identical(other.playbackId, playbackId) || other.playbackId == playbackId)&&(identical(other.streamUrl, streamUrl) || other.streamUrl == streamUrl)&&(identical(other.rtmpUrl, rtmpUrl) || other.rtmpUrl == rtmpUrl)&&(identical(other.streamKey, streamKey) || other.streamKey == streamKey)&&(identical(other.thumbnailUrl, thumbnailUrl) || other.thumbnailUrl == thumbnailUrl)&&(identical(other.streamerId, streamerId) || other.streamerId == streamerId)&&(identical(other.streamerName, streamerName) || other.streamerName == streamerName)&&(identical(other.streamerAvatarUrl, streamerAvatarUrl) || other.streamerAvatarUrl == streamerAvatarUrl)&&(identical(other.streamerUsername, streamerUsername) || other.streamerUsername == streamerUsername)&&(identical(other.streamerVerified, streamerVerified) || other.streamerVerified == streamerVerified));
}


@override
int get hashCode => Object.hashAll([runtimeType,id,slug,title,description,category,liveType,isPrivate,status,viewerCount,totalLikes,totalMessages,isPaused,pausedAt,playbackId,streamUrl,rtmpUrl,streamKey,thumbnailUrl,streamerId,streamerName,streamerAvatarUrl,streamerUsername,streamerVerified]);

@override
String toString() {
  return 'LiveRoom(id: $id, slug: $slug, title: $title, description: $description, category: $category, liveType: $liveType, isPrivate: $isPrivate, status: $status, viewerCount: $viewerCount, totalLikes: $totalLikes, totalMessages: $totalMessages, isPaused: $isPaused, pausedAt: $pausedAt, playbackId: $playbackId, streamUrl: $streamUrl, rtmpUrl: $rtmpUrl, streamKey: $streamKey, thumbnailUrl: $thumbnailUrl, streamerId: $streamerId, streamerName: $streamerName, streamerAvatarUrl: $streamerAvatarUrl, streamerUsername: $streamerUsername, streamerVerified: $streamerVerified)';
}


}

/// @nodoc
abstract mixin class $LiveRoomCopyWith<$Res>  {
  factory $LiveRoomCopyWith(LiveRoom value, $Res Function(LiveRoom) _then) = _$LiveRoomCopyWithImpl;
@useResult
$Res call({
 String id, String slug, String title, String? description, String? category, String liveType, bool isPrivate, String status, int viewerCount, int totalLikes, int totalMessages, bool isPaused, DateTime? pausedAt, String? playbackId, String? streamUrl, String? rtmpUrl, String? streamKey, String? thumbnailUrl, String streamerId, String streamerName, String? streamerAvatarUrl, String? streamerUsername, bool streamerVerified
});




}
/// @nodoc
class _$LiveRoomCopyWithImpl<$Res>
    implements $LiveRoomCopyWith<$Res> {
  _$LiveRoomCopyWithImpl(this._self, this._then);

  final LiveRoom _self;
  final $Res Function(LiveRoom) _then;

/// Create a copy of LiveRoom
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? slug = null,Object? title = null,Object? description = freezed,Object? category = freezed,Object? liveType = null,Object? isPrivate = null,Object? status = null,Object? viewerCount = null,Object? totalLikes = null,Object? totalMessages = null,Object? isPaused = null,Object? pausedAt = freezed,Object? playbackId = freezed,Object? streamUrl = freezed,Object? rtmpUrl = freezed,Object? streamKey = freezed,Object? thumbnailUrl = freezed,Object? streamerId = null,Object? streamerName = null,Object? streamerAvatarUrl = freezed,Object? streamerUsername = freezed,Object? streamerVerified = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,slug: null == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,liveType: null == liveType ? _self.liveType : liveType // ignore: cast_nullable_to_non_nullable
as String,isPrivate: null == isPrivate ? _self.isPrivate : isPrivate // ignore: cast_nullable_to_non_nullable
as bool,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,viewerCount: null == viewerCount ? _self.viewerCount : viewerCount // ignore: cast_nullable_to_non_nullable
as int,totalLikes: null == totalLikes ? _self.totalLikes : totalLikes // ignore: cast_nullable_to_non_nullable
as int,totalMessages: null == totalMessages ? _self.totalMessages : totalMessages // ignore: cast_nullable_to_non_nullable
as int,isPaused: null == isPaused ? _self.isPaused : isPaused // ignore: cast_nullable_to_non_nullable
as bool,pausedAt: freezed == pausedAt ? _self.pausedAt : pausedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,playbackId: freezed == playbackId ? _self.playbackId : playbackId // ignore: cast_nullable_to_non_nullable
as String?,streamUrl: freezed == streamUrl ? _self.streamUrl : streamUrl // ignore: cast_nullable_to_non_nullable
as String?,rtmpUrl: freezed == rtmpUrl ? _self.rtmpUrl : rtmpUrl // ignore: cast_nullable_to_non_nullable
as String?,streamKey: freezed == streamKey ? _self.streamKey : streamKey // ignore: cast_nullable_to_non_nullable
as String?,thumbnailUrl: freezed == thumbnailUrl ? _self.thumbnailUrl : thumbnailUrl // ignore: cast_nullable_to_non_nullable
as String?,streamerId: null == streamerId ? _self.streamerId : streamerId // ignore: cast_nullable_to_non_nullable
as String,streamerName: null == streamerName ? _self.streamerName : streamerName // ignore: cast_nullable_to_non_nullable
as String,streamerAvatarUrl: freezed == streamerAvatarUrl ? _self.streamerAvatarUrl : streamerAvatarUrl // ignore: cast_nullable_to_non_nullable
as String?,streamerUsername: freezed == streamerUsername ? _self.streamerUsername : streamerUsername // ignore: cast_nullable_to_non_nullable
as String?,streamerVerified: null == streamerVerified ? _self.streamerVerified : streamerVerified // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [LiveRoom].
extension LiveRoomPatterns on LiveRoom {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LiveRoom value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LiveRoom() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LiveRoom value)  $default,){
final _that = this;
switch (_that) {
case _LiveRoom():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LiveRoom value)?  $default,){
final _that = this;
switch (_that) {
case _LiveRoom() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String slug,  String title,  String? description,  String? category,  String liveType,  bool isPrivate,  String status,  int viewerCount,  int totalLikes,  int totalMessages,  bool isPaused,  DateTime? pausedAt,  String? playbackId,  String? streamUrl,  String? rtmpUrl,  String? streamKey,  String? thumbnailUrl,  String streamerId,  String streamerName,  String? streamerAvatarUrl,  String? streamerUsername,  bool streamerVerified)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LiveRoom() when $default != null:
return $default(_that.id,_that.slug,_that.title,_that.description,_that.category,_that.liveType,_that.isPrivate,_that.status,_that.viewerCount,_that.totalLikes,_that.totalMessages,_that.isPaused,_that.pausedAt,_that.playbackId,_that.streamUrl,_that.rtmpUrl,_that.streamKey,_that.thumbnailUrl,_that.streamerId,_that.streamerName,_that.streamerAvatarUrl,_that.streamerUsername,_that.streamerVerified);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String slug,  String title,  String? description,  String? category,  String liveType,  bool isPrivate,  String status,  int viewerCount,  int totalLikes,  int totalMessages,  bool isPaused,  DateTime? pausedAt,  String? playbackId,  String? streamUrl,  String? rtmpUrl,  String? streamKey,  String? thumbnailUrl,  String streamerId,  String streamerName,  String? streamerAvatarUrl,  String? streamerUsername,  bool streamerVerified)  $default,) {final _that = this;
switch (_that) {
case _LiveRoom():
return $default(_that.id,_that.slug,_that.title,_that.description,_that.category,_that.liveType,_that.isPrivate,_that.status,_that.viewerCount,_that.totalLikes,_that.totalMessages,_that.isPaused,_that.pausedAt,_that.playbackId,_that.streamUrl,_that.rtmpUrl,_that.streamKey,_that.thumbnailUrl,_that.streamerId,_that.streamerName,_that.streamerAvatarUrl,_that.streamerUsername,_that.streamerVerified);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String slug,  String title,  String? description,  String? category,  String liveType,  bool isPrivate,  String status,  int viewerCount,  int totalLikes,  int totalMessages,  bool isPaused,  DateTime? pausedAt,  String? playbackId,  String? streamUrl,  String? rtmpUrl,  String? streamKey,  String? thumbnailUrl,  String streamerId,  String streamerName,  String? streamerAvatarUrl,  String? streamerUsername,  bool streamerVerified)?  $default,) {final _that = this;
switch (_that) {
case _LiveRoom() when $default != null:
return $default(_that.id,_that.slug,_that.title,_that.description,_that.category,_that.liveType,_that.isPrivate,_that.status,_that.viewerCount,_that.totalLikes,_that.totalMessages,_that.isPaused,_that.pausedAt,_that.playbackId,_that.streamUrl,_that.rtmpUrl,_that.streamKey,_that.thumbnailUrl,_that.streamerId,_that.streamerName,_that.streamerAvatarUrl,_that.streamerUsername,_that.streamerVerified);case _:
  return null;

}
}

}

/// @nodoc


class _LiveRoom implements LiveRoom {
  const _LiveRoom({required this.id, required this.slug, required this.title, this.description, this.category, required this.liveType, required this.isPrivate, required this.status, required this.viewerCount, this.totalLikes = 0, this.totalMessages = 0, this.isPaused = false, this.pausedAt, this.playbackId, this.streamUrl, this.rtmpUrl, this.streamKey, this.thumbnailUrl, required this.streamerId, required this.streamerName, this.streamerAvatarUrl, this.streamerUsername, this.streamerVerified = false});
  

@override final  String id;
@override final  String slug;
@override final  String title;
@override final  String? description;
@override final  String? category;
@override final  String liveType;
@override final  bool isPrivate;
@override final  String status;
@override final  int viewerCount;
@override@JsonKey() final  int totalLikes;
@override@JsonKey() final  int totalMessages;
@override@JsonKey() final  bool isPaused;
@override final  DateTime? pausedAt;
@override final  String? playbackId;
@override final  String? streamUrl;
@override final  String? rtmpUrl;
@override final  String? streamKey;
@override final  String? thumbnailUrl;
@override final  String streamerId;
@override final  String streamerName;
@override final  String? streamerAvatarUrl;
@override final  String? streamerUsername;
@override@JsonKey() final  bool streamerVerified;

/// Create a copy of LiveRoom
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LiveRoomCopyWith<_LiveRoom> get copyWith => __$LiveRoomCopyWithImpl<_LiveRoom>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LiveRoom&&(identical(other.id, id) || other.id == id)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.category, category) || other.category == category)&&(identical(other.liveType, liveType) || other.liveType == liveType)&&(identical(other.isPrivate, isPrivate) || other.isPrivate == isPrivate)&&(identical(other.status, status) || other.status == status)&&(identical(other.viewerCount, viewerCount) || other.viewerCount == viewerCount)&&(identical(other.totalLikes, totalLikes) || other.totalLikes == totalLikes)&&(identical(other.totalMessages, totalMessages) || other.totalMessages == totalMessages)&&(identical(other.isPaused, isPaused) || other.isPaused == isPaused)&&(identical(other.pausedAt, pausedAt) || other.pausedAt == pausedAt)&&(identical(other.playbackId, playbackId) || other.playbackId == playbackId)&&(identical(other.streamUrl, streamUrl) || other.streamUrl == streamUrl)&&(identical(other.rtmpUrl, rtmpUrl) || other.rtmpUrl == rtmpUrl)&&(identical(other.streamKey, streamKey) || other.streamKey == streamKey)&&(identical(other.thumbnailUrl, thumbnailUrl) || other.thumbnailUrl == thumbnailUrl)&&(identical(other.streamerId, streamerId) || other.streamerId == streamerId)&&(identical(other.streamerName, streamerName) || other.streamerName == streamerName)&&(identical(other.streamerAvatarUrl, streamerAvatarUrl) || other.streamerAvatarUrl == streamerAvatarUrl)&&(identical(other.streamerUsername, streamerUsername) || other.streamerUsername == streamerUsername)&&(identical(other.streamerVerified, streamerVerified) || other.streamerVerified == streamerVerified));
}


@override
int get hashCode => Object.hashAll([runtimeType,id,slug,title,description,category,liveType,isPrivate,status,viewerCount,totalLikes,totalMessages,isPaused,pausedAt,playbackId,streamUrl,rtmpUrl,streamKey,thumbnailUrl,streamerId,streamerName,streamerAvatarUrl,streamerUsername,streamerVerified]);

@override
String toString() {
  return 'LiveRoom(id: $id, slug: $slug, title: $title, description: $description, category: $category, liveType: $liveType, isPrivate: $isPrivate, status: $status, viewerCount: $viewerCount, totalLikes: $totalLikes, totalMessages: $totalMessages, isPaused: $isPaused, pausedAt: $pausedAt, playbackId: $playbackId, streamUrl: $streamUrl, rtmpUrl: $rtmpUrl, streamKey: $streamKey, thumbnailUrl: $thumbnailUrl, streamerId: $streamerId, streamerName: $streamerName, streamerAvatarUrl: $streamerAvatarUrl, streamerUsername: $streamerUsername, streamerVerified: $streamerVerified)';
}


}

/// @nodoc
abstract mixin class _$LiveRoomCopyWith<$Res> implements $LiveRoomCopyWith<$Res> {
  factory _$LiveRoomCopyWith(_LiveRoom value, $Res Function(_LiveRoom) _then) = __$LiveRoomCopyWithImpl;
@override @useResult
$Res call({
 String id, String slug, String title, String? description, String? category, String liveType, bool isPrivate, String status, int viewerCount, int totalLikes, int totalMessages, bool isPaused, DateTime? pausedAt, String? playbackId, String? streamUrl, String? rtmpUrl, String? streamKey, String? thumbnailUrl, String streamerId, String streamerName, String? streamerAvatarUrl, String? streamerUsername, bool streamerVerified
});




}
/// @nodoc
class __$LiveRoomCopyWithImpl<$Res>
    implements _$LiveRoomCopyWith<$Res> {
  __$LiveRoomCopyWithImpl(this._self, this._then);

  final _LiveRoom _self;
  final $Res Function(_LiveRoom) _then;

/// Create a copy of LiveRoom
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? slug = null,Object? title = null,Object? description = freezed,Object? category = freezed,Object? liveType = null,Object? isPrivate = null,Object? status = null,Object? viewerCount = null,Object? totalLikes = null,Object? totalMessages = null,Object? isPaused = null,Object? pausedAt = freezed,Object? playbackId = freezed,Object? streamUrl = freezed,Object? rtmpUrl = freezed,Object? streamKey = freezed,Object? thumbnailUrl = freezed,Object? streamerId = null,Object? streamerName = null,Object? streamerAvatarUrl = freezed,Object? streamerUsername = freezed,Object? streamerVerified = null,}) {
  return _then(_LiveRoom(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,slug: null == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,liveType: null == liveType ? _self.liveType : liveType // ignore: cast_nullable_to_non_nullable
as String,isPrivate: null == isPrivate ? _self.isPrivate : isPrivate // ignore: cast_nullable_to_non_nullable
as bool,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,viewerCount: null == viewerCount ? _self.viewerCount : viewerCount // ignore: cast_nullable_to_non_nullable
as int,totalLikes: null == totalLikes ? _self.totalLikes : totalLikes // ignore: cast_nullable_to_non_nullable
as int,totalMessages: null == totalMessages ? _self.totalMessages : totalMessages // ignore: cast_nullable_to_non_nullable
as int,isPaused: null == isPaused ? _self.isPaused : isPaused // ignore: cast_nullable_to_non_nullable
as bool,pausedAt: freezed == pausedAt ? _self.pausedAt : pausedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,playbackId: freezed == playbackId ? _self.playbackId : playbackId // ignore: cast_nullable_to_non_nullable
as String?,streamUrl: freezed == streamUrl ? _self.streamUrl : streamUrl // ignore: cast_nullable_to_non_nullable
as String?,rtmpUrl: freezed == rtmpUrl ? _self.rtmpUrl : rtmpUrl // ignore: cast_nullable_to_non_nullable
as String?,streamKey: freezed == streamKey ? _self.streamKey : streamKey // ignore: cast_nullable_to_non_nullable
as String?,thumbnailUrl: freezed == thumbnailUrl ? _self.thumbnailUrl : thumbnailUrl // ignore: cast_nullable_to_non_nullable
as String?,streamerId: null == streamerId ? _self.streamerId : streamerId // ignore: cast_nullable_to_non_nullable
as String,streamerName: null == streamerName ? _self.streamerName : streamerName // ignore: cast_nullable_to_non_nullable
as String,streamerAvatarUrl: freezed == streamerAvatarUrl ? _self.streamerAvatarUrl : streamerAvatarUrl // ignore: cast_nullable_to_non_nullable
as String?,streamerUsername: freezed == streamerUsername ? _self.streamerUsername : streamerUsername // ignore: cast_nullable_to_non_nullable
as String?,streamerVerified: null == streamerVerified ? _self.streamerVerified : streamerVerified // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
