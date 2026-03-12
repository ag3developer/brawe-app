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

 String get id; String get title; String? get description; String? get category; String get liveType; bool get isPrivate; String get status; int get viewerCount; String? get playbackId; String? get streamUrl; String? get rtmpUrl; String? get streamKey; String? get thumbnailUrl; String get streamerId; String get streamerName; String? get streamerAvatarUrl;
/// Create a copy of LiveRoom
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LiveRoomCopyWith<LiveRoom> get copyWith => _$LiveRoomCopyWithImpl<LiveRoom>(this as LiveRoom, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LiveRoom&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.category, category) || other.category == category)&&(identical(other.liveType, liveType) || other.liveType == liveType)&&(identical(other.isPrivate, isPrivate) || other.isPrivate == isPrivate)&&(identical(other.status, status) || other.status == status)&&(identical(other.viewerCount, viewerCount) || other.viewerCount == viewerCount)&&(identical(other.playbackId, playbackId) || other.playbackId == playbackId)&&(identical(other.streamUrl, streamUrl) || other.streamUrl == streamUrl)&&(identical(other.rtmpUrl, rtmpUrl) || other.rtmpUrl == rtmpUrl)&&(identical(other.streamKey, streamKey) || other.streamKey == streamKey)&&(identical(other.thumbnailUrl, thumbnailUrl) || other.thumbnailUrl == thumbnailUrl)&&(identical(other.streamerId, streamerId) || other.streamerId == streamerId)&&(identical(other.streamerName, streamerName) || other.streamerName == streamerName)&&(identical(other.streamerAvatarUrl, streamerAvatarUrl) || other.streamerAvatarUrl == streamerAvatarUrl));
}


@override
int get hashCode => Object.hash(runtimeType,id,title,description,category,liveType,isPrivate,status,viewerCount,playbackId,streamUrl,rtmpUrl,streamKey,thumbnailUrl,streamerId,streamerName,streamerAvatarUrl);

@override
String toString() {
  return 'LiveRoom(id: $id, title: $title, description: $description, category: $category, liveType: $liveType, isPrivate: $isPrivate, status: $status, viewerCount: $viewerCount, playbackId: $playbackId, streamUrl: $streamUrl, rtmpUrl: $rtmpUrl, streamKey: $streamKey, thumbnailUrl: $thumbnailUrl, streamerId: $streamerId, streamerName: $streamerName, streamerAvatarUrl: $streamerAvatarUrl)';
}


}

/// @nodoc
abstract mixin class $LiveRoomCopyWith<$Res>  {
  factory $LiveRoomCopyWith(LiveRoom value, $Res Function(LiveRoom) _then) = _$LiveRoomCopyWithImpl;
@useResult
$Res call({
 String id, String title, String? description, String? category, String liveType, bool isPrivate, String status, int viewerCount, String? playbackId, String? streamUrl, String? rtmpUrl, String? streamKey, String? thumbnailUrl, String streamerId, String streamerName, String? streamerAvatarUrl
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
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? description = freezed,Object? category = freezed,Object? liveType = null,Object? isPrivate = null,Object? status = null,Object? viewerCount = null,Object? playbackId = freezed,Object? streamUrl = freezed,Object? rtmpUrl = freezed,Object? streamKey = freezed,Object? thumbnailUrl = freezed,Object? streamerId = null,Object? streamerName = null,Object? streamerAvatarUrl = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,liveType: null == liveType ? _self.liveType : liveType // ignore: cast_nullable_to_non_nullable
as String,isPrivate: null == isPrivate ? _self.isPrivate : isPrivate // ignore: cast_nullable_to_non_nullable
as bool,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,viewerCount: null == viewerCount ? _self.viewerCount : viewerCount // ignore: cast_nullable_to_non_nullable
as int,playbackId: freezed == playbackId ? _self.playbackId : playbackId // ignore: cast_nullable_to_non_nullable
as String?,streamUrl: freezed == streamUrl ? _self.streamUrl : streamUrl // ignore: cast_nullable_to_non_nullable
as String?,rtmpUrl: freezed == rtmpUrl ? _self.rtmpUrl : rtmpUrl // ignore: cast_nullable_to_non_nullable
as String?,streamKey: freezed == streamKey ? _self.streamKey : streamKey // ignore: cast_nullable_to_non_nullable
as String?,thumbnailUrl: freezed == thumbnailUrl ? _self.thumbnailUrl : thumbnailUrl // ignore: cast_nullable_to_non_nullable
as String?,streamerId: null == streamerId ? _self.streamerId : streamerId // ignore: cast_nullable_to_non_nullable
as String,streamerName: null == streamerName ? _self.streamerName : streamerName // ignore: cast_nullable_to_non_nullable
as String,streamerAvatarUrl: freezed == streamerAvatarUrl ? _self.streamerAvatarUrl : streamerAvatarUrl // ignore: cast_nullable_to_non_nullable
as String?,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String? description,  String? category,  String liveType,  bool isPrivate,  String status,  int viewerCount,  String? playbackId,  String? streamUrl,  String? rtmpUrl,  String? streamKey,  String? thumbnailUrl,  String streamerId,  String streamerName,  String? streamerAvatarUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LiveRoom() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.category,_that.liveType,_that.isPrivate,_that.status,_that.viewerCount,_that.playbackId,_that.streamUrl,_that.rtmpUrl,_that.streamKey,_that.thumbnailUrl,_that.streamerId,_that.streamerName,_that.streamerAvatarUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String? description,  String? category,  String liveType,  bool isPrivate,  String status,  int viewerCount,  String? playbackId,  String? streamUrl,  String? rtmpUrl,  String? streamKey,  String? thumbnailUrl,  String streamerId,  String streamerName,  String? streamerAvatarUrl)  $default,) {final _that = this;
switch (_that) {
case _LiveRoom():
return $default(_that.id,_that.title,_that.description,_that.category,_that.liveType,_that.isPrivate,_that.status,_that.viewerCount,_that.playbackId,_that.streamUrl,_that.rtmpUrl,_that.streamKey,_that.thumbnailUrl,_that.streamerId,_that.streamerName,_that.streamerAvatarUrl);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String? description,  String? category,  String liveType,  bool isPrivate,  String status,  int viewerCount,  String? playbackId,  String? streamUrl,  String? rtmpUrl,  String? streamKey,  String? thumbnailUrl,  String streamerId,  String streamerName,  String? streamerAvatarUrl)?  $default,) {final _that = this;
switch (_that) {
case _LiveRoom() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.category,_that.liveType,_that.isPrivate,_that.status,_that.viewerCount,_that.playbackId,_that.streamUrl,_that.rtmpUrl,_that.streamKey,_that.thumbnailUrl,_that.streamerId,_that.streamerName,_that.streamerAvatarUrl);case _:
  return null;

}
}

}

/// @nodoc


class _LiveRoom implements LiveRoom {
  const _LiveRoom({required this.id, required this.title, this.description, this.category, required this.liveType, required this.isPrivate, required this.status, required this.viewerCount, this.playbackId, this.streamUrl, this.rtmpUrl, this.streamKey, this.thumbnailUrl, required this.streamerId, required this.streamerName, this.streamerAvatarUrl});
  

@override final  String id;
@override final  String title;
@override final  String? description;
@override final  String? category;
@override final  String liveType;
@override final  bool isPrivate;
@override final  String status;
@override final  int viewerCount;
@override final  String? playbackId;
@override final  String? streamUrl;
@override final  String? rtmpUrl;
@override final  String? streamKey;
@override final  String? thumbnailUrl;
@override final  String streamerId;
@override final  String streamerName;
@override final  String? streamerAvatarUrl;

/// Create a copy of LiveRoom
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LiveRoomCopyWith<_LiveRoom> get copyWith => __$LiveRoomCopyWithImpl<_LiveRoom>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LiveRoom&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.category, category) || other.category == category)&&(identical(other.liveType, liveType) || other.liveType == liveType)&&(identical(other.isPrivate, isPrivate) || other.isPrivate == isPrivate)&&(identical(other.status, status) || other.status == status)&&(identical(other.viewerCount, viewerCount) || other.viewerCount == viewerCount)&&(identical(other.playbackId, playbackId) || other.playbackId == playbackId)&&(identical(other.streamUrl, streamUrl) || other.streamUrl == streamUrl)&&(identical(other.rtmpUrl, rtmpUrl) || other.rtmpUrl == rtmpUrl)&&(identical(other.streamKey, streamKey) || other.streamKey == streamKey)&&(identical(other.thumbnailUrl, thumbnailUrl) || other.thumbnailUrl == thumbnailUrl)&&(identical(other.streamerId, streamerId) || other.streamerId == streamerId)&&(identical(other.streamerName, streamerName) || other.streamerName == streamerName)&&(identical(other.streamerAvatarUrl, streamerAvatarUrl) || other.streamerAvatarUrl == streamerAvatarUrl));
}


@override
int get hashCode => Object.hash(runtimeType,id,title,description,category,liveType,isPrivate,status,viewerCount,playbackId,streamUrl,rtmpUrl,streamKey,thumbnailUrl,streamerId,streamerName,streamerAvatarUrl);

@override
String toString() {
  return 'LiveRoom(id: $id, title: $title, description: $description, category: $category, liveType: $liveType, isPrivate: $isPrivate, status: $status, viewerCount: $viewerCount, playbackId: $playbackId, streamUrl: $streamUrl, rtmpUrl: $rtmpUrl, streamKey: $streamKey, thumbnailUrl: $thumbnailUrl, streamerId: $streamerId, streamerName: $streamerName, streamerAvatarUrl: $streamerAvatarUrl)';
}


}

/// @nodoc
abstract mixin class _$LiveRoomCopyWith<$Res> implements $LiveRoomCopyWith<$Res> {
  factory _$LiveRoomCopyWith(_LiveRoom value, $Res Function(_LiveRoom) _then) = __$LiveRoomCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String? description, String? category, String liveType, bool isPrivate, String status, int viewerCount, String? playbackId, String? streamUrl, String? rtmpUrl, String? streamKey, String? thumbnailUrl, String streamerId, String streamerName, String? streamerAvatarUrl
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
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? description = freezed,Object? category = freezed,Object? liveType = null,Object? isPrivate = null,Object? status = null,Object? viewerCount = null,Object? playbackId = freezed,Object? streamUrl = freezed,Object? rtmpUrl = freezed,Object? streamKey = freezed,Object? thumbnailUrl = freezed,Object? streamerId = null,Object? streamerName = null,Object? streamerAvatarUrl = freezed,}) {
  return _then(_LiveRoom(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,liveType: null == liveType ? _self.liveType : liveType // ignore: cast_nullable_to_non_nullable
as String,isPrivate: null == isPrivate ? _self.isPrivate : isPrivate // ignore: cast_nullable_to_non_nullable
as bool,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,viewerCount: null == viewerCount ? _self.viewerCount : viewerCount // ignore: cast_nullable_to_non_nullable
as int,playbackId: freezed == playbackId ? _self.playbackId : playbackId // ignore: cast_nullable_to_non_nullable
as String?,streamUrl: freezed == streamUrl ? _self.streamUrl : streamUrl // ignore: cast_nullable_to_non_nullable
as String?,rtmpUrl: freezed == rtmpUrl ? _self.rtmpUrl : rtmpUrl // ignore: cast_nullable_to_non_nullable
as String?,streamKey: freezed == streamKey ? _self.streamKey : streamKey // ignore: cast_nullable_to_non_nullable
as String?,thumbnailUrl: freezed == thumbnailUrl ? _self.thumbnailUrl : thumbnailUrl // ignore: cast_nullable_to_non_nullable
as String?,streamerId: null == streamerId ? _self.streamerId : streamerId // ignore: cast_nullable_to_non_nullable
as String,streamerName: null == streamerName ? _self.streamerName : streamerName // ignore: cast_nullable_to_non_nullable
as String,streamerAvatarUrl: freezed == streamerAvatarUrl ? _self.streamerAvatarUrl : streamerAvatarUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
