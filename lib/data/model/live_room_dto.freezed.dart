// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'live_room_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$LiveRoomDto {

 String get id; String get title; String? get description; String? get category;@JsonKey(name: 'live_type') String get liveType;@JsonKey(name: 'is_private') bool get isPrivate; String get status;@JsonKey(name: 'viewer_count') int get viewerCount;@JsonKey(name: 'stream_url') String? get streamUrl;@JsonKey(name: 'thumbnail_url') String? get thumbnailUrl;@JsonKey(name: 'streamer_id') String get streamerId;@JsonKey(name: 'streamer_name') String get streamerName;@JsonKey(name: 'streamer_avatar_url') String? get streamerAvatarUrl;
/// Create a copy of LiveRoomDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LiveRoomDtoCopyWith<LiveRoomDto> get copyWith => _$LiveRoomDtoCopyWithImpl<LiveRoomDto>(this as LiveRoomDto, _$identity);

  /// Serializes this LiveRoomDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LiveRoomDto&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.category, category) || other.category == category)&&(identical(other.liveType, liveType) || other.liveType == liveType)&&(identical(other.isPrivate, isPrivate) || other.isPrivate == isPrivate)&&(identical(other.status, status) || other.status == status)&&(identical(other.viewerCount, viewerCount) || other.viewerCount == viewerCount)&&(identical(other.streamUrl, streamUrl) || other.streamUrl == streamUrl)&&(identical(other.thumbnailUrl, thumbnailUrl) || other.thumbnailUrl == thumbnailUrl)&&(identical(other.streamerId, streamerId) || other.streamerId == streamerId)&&(identical(other.streamerName, streamerName) || other.streamerName == streamerName)&&(identical(other.streamerAvatarUrl, streamerAvatarUrl) || other.streamerAvatarUrl == streamerAvatarUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,description,category,liveType,isPrivate,status,viewerCount,streamUrl,thumbnailUrl,streamerId,streamerName,streamerAvatarUrl);

@override
String toString() {
  return 'LiveRoomDto(id: $id, title: $title, description: $description, category: $category, liveType: $liveType, isPrivate: $isPrivate, status: $status, viewerCount: $viewerCount, streamUrl: $streamUrl, thumbnailUrl: $thumbnailUrl, streamerId: $streamerId, streamerName: $streamerName, streamerAvatarUrl: $streamerAvatarUrl)';
}


}

/// @nodoc
abstract mixin class $LiveRoomDtoCopyWith<$Res>  {
  factory $LiveRoomDtoCopyWith(LiveRoomDto value, $Res Function(LiveRoomDto) _then) = _$LiveRoomDtoCopyWithImpl;
@useResult
$Res call({
 String id, String title, String? description, String? category,@JsonKey(name: 'live_type') String liveType,@JsonKey(name: 'is_private') bool isPrivate, String status,@JsonKey(name: 'viewer_count') int viewerCount,@JsonKey(name: 'stream_url') String? streamUrl,@JsonKey(name: 'thumbnail_url') String? thumbnailUrl,@JsonKey(name: 'streamer_id') String streamerId,@JsonKey(name: 'streamer_name') String streamerName,@JsonKey(name: 'streamer_avatar_url') String? streamerAvatarUrl
});




}
/// @nodoc
class _$LiveRoomDtoCopyWithImpl<$Res>
    implements $LiveRoomDtoCopyWith<$Res> {
  _$LiveRoomDtoCopyWithImpl(this._self, this._then);

  final LiveRoomDto _self;
  final $Res Function(LiveRoomDto) _then;

/// Create a copy of LiveRoomDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? description = freezed,Object? category = freezed,Object? liveType = null,Object? isPrivate = null,Object? status = null,Object? viewerCount = null,Object? streamUrl = freezed,Object? thumbnailUrl = freezed,Object? streamerId = null,Object? streamerName = null,Object? streamerAvatarUrl = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,liveType: null == liveType ? _self.liveType : liveType // ignore: cast_nullable_to_non_nullable
as String,isPrivate: null == isPrivate ? _self.isPrivate : isPrivate // ignore: cast_nullable_to_non_nullable
as bool,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,viewerCount: null == viewerCount ? _self.viewerCount : viewerCount // ignore: cast_nullable_to_non_nullable
as int,streamUrl: freezed == streamUrl ? _self.streamUrl : streamUrl // ignore: cast_nullable_to_non_nullable
as String?,thumbnailUrl: freezed == thumbnailUrl ? _self.thumbnailUrl : thumbnailUrl // ignore: cast_nullable_to_non_nullable
as String?,streamerId: null == streamerId ? _self.streamerId : streamerId // ignore: cast_nullable_to_non_nullable
as String,streamerName: null == streamerName ? _self.streamerName : streamerName // ignore: cast_nullable_to_non_nullable
as String,streamerAvatarUrl: freezed == streamerAvatarUrl ? _self.streamerAvatarUrl : streamerAvatarUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [LiveRoomDto].
extension LiveRoomDtoPatterns on LiveRoomDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LiveRoomDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LiveRoomDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LiveRoomDto value)  $default,){
final _that = this;
switch (_that) {
case _LiveRoomDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LiveRoomDto value)?  $default,){
final _that = this;
switch (_that) {
case _LiveRoomDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String? description,  String? category, @JsonKey(name: 'live_type')  String liveType, @JsonKey(name: 'is_private')  bool isPrivate,  String status, @JsonKey(name: 'viewer_count')  int viewerCount, @JsonKey(name: 'stream_url')  String? streamUrl, @JsonKey(name: 'thumbnail_url')  String? thumbnailUrl, @JsonKey(name: 'streamer_id')  String streamerId, @JsonKey(name: 'streamer_name')  String streamerName, @JsonKey(name: 'streamer_avatar_url')  String? streamerAvatarUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LiveRoomDto() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.category,_that.liveType,_that.isPrivate,_that.status,_that.viewerCount,_that.streamUrl,_that.thumbnailUrl,_that.streamerId,_that.streamerName,_that.streamerAvatarUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String? description,  String? category, @JsonKey(name: 'live_type')  String liveType, @JsonKey(name: 'is_private')  bool isPrivate,  String status, @JsonKey(name: 'viewer_count')  int viewerCount, @JsonKey(name: 'stream_url')  String? streamUrl, @JsonKey(name: 'thumbnail_url')  String? thumbnailUrl, @JsonKey(name: 'streamer_id')  String streamerId, @JsonKey(name: 'streamer_name')  String streamerName, @JsonKey(name: 'streamer_avatar_url')  String? streamerAvatarUrl)  $default,) {final _that = this;
switch (_that) {
case _LiveRoomDto():
return $default(_that.id,_that.title,_that.description,_that.category,_that.liveType,_that.isPrivate,_that.status,_that.viewerCount,_that.streamUrl,_that.thumbnailUrl,_that.streamerId,_that.streamerName,_that.streamerAvatarUrl);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String? description,  String? category, @JsonKey(name: 'live_type')  String liveType, @JsonKey(name: 'is_private')  bool isPrivate,  String status, @JsonKey(name: 'viewer_count')  int viewerCount, @JsonKey(name: 'stream_url')  String? streamUrl, @JsonKey(name: 'thumbnail_url')  String? thumbnailUrl, @JsonKey(name: 'streamer_id')  String streamerId, @JsonKey(name: 'streamer_name')  String streamerName, @JsonKey(name: 'streamer_avatar_url')  String? streamerAvatarUrl)?  $default,) {final _that = this;
switch (_that) {
case _LiveRoomDto() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.category,_that.liveType,_that.isPrivate,_that.status,_that.viewerCount,_that.streamUrl,_that.thumbnailUrl,_that.streamerId,_that.streamerName,_that.streamerAvatarUrl);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LiveRoomDto implements LiveRoomDto {
  const _LiveRoomDto({required this.id, required this.title, this.description, this.category, @JsonKey(name: 'live_type') this.liveType = 'solo', @JsonKey(name: 'is_private') this.isPrivate = false, required this.status, @JsonKey(name: 'viewer_count') this.viewerCount = 0, @JsonKey(name: 'stream_url') this.streamUrl, @JsonKey(name: 'thumbnail_url') this.thumbnailUrl, @JsonKey(name: 'streamer_id') required this.streamerId, @JsonKey(name: 'streamer_name') this.streamerName = 'Unknown Streamer', @JsonKey(name: 'streamer_avatar_url') this.streamerAvatarUrl});
  factory _LiveRoomDto.fromJson(Map<String, dynamic> json) => _$LiveRoomDtoFromJson(json);

@override final  String id;
@override final  String title;
@override final  String? description;
@override final  String? category;
@override@JsonKey(name: 'live_type') final  String liveType;
@override@JsonKey(name: 'is_private') final  bool isPrivate;
@override final  String status;
@override@JsonKey(name: 'viewer_count') final  int viewerCount;
@override@JsonKey(name: 'stream_url') final  String? streamUrl;
@override@JsonKey(name: 'thumbnail_url') final  String? thumbnailUrl;
@override@JsonKey(name: 'streamer_id') final  String streamerId;
@override@JsonKey(name: 'streamer_name') final  String streamerName;
@override@JsonKey(name: 'streamer_avatar_url') final  String? streamerAvatarUrl;

/// Create a copy of LiveRoomDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LiveRoomDtoCopyWith<_LiveRoomDto> get copyWith => __$LiveRoomDtoCopyWithImpl<_LiveRoomDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LiveRoomDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LiveRoomDto&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.category, category) || other.category == category)&&(identical(other.liveType, liveType) || other.liveType == liveType)&&(identical(other.isPrivate, isPrivate) || other.isPrivate == isPrivate)&&(identical(other.status, status) || other.status == status)&&(identical(other.viewerCount, viewerCount) || other.viewerCount == viewerCount)&&(identical(other.streamUrl, streamUrl) || other.streamUrl == streamUrl)&&(identical(other.thumbnailUrl, thumbnailUrl) || other.thumbnailUrl == thumbnailUrl)&&(identical(other.streamerId, streamerId) || other.streamerId == streamerId)&&(identical(other.streamerName, streamerName) || other.streamerName == streamerName)&&(identical(other.streamerAvatarUrl, streamerAvatarUrl) || other.streamerAvatarUrl == streamerAvatarUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,description,category,liveType,isPrivate,status,viewerCount,streamUrl,thumbnailUrl,streamerId,streamerName,streamerAvatarUrl);

@override
String toString() {
  return 'LiveRoomDto(id: $id, title: $title, description: $description, category: $category, liveType: $liveType, isPrivate: $isPrivate, status: $status, viewerCount: $viewerCount, streamUrl: $streamUrl, thumbnailUrl: $thumbnailUrl, streamerId: $streamerId, streamerName: $streamerName, streamerAvatarUrl: $streamerAvatarUrl)';
}


}

/// @nodoc
abstract mixin class _$LiveRoomDtoCopyWith<$Res> implements $LiveRoomDtoCopyWith<$Res> {
  factory _$LiveRoomDtoCopyWith(_LiveRoomDto value, $Res Function(_LiveRoomDto) _then) = __$LiveRoomDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String? description, String? category,@JsonKey(name: 'live_type') String liveType,@JsonKey(name: 'is_private') bool isPrivate, String status,@JsonKey(name: 'viewer_count') int viewerCount,@JsonKey(name: 'stream_url') String? streamUrl,@JsonKey(name: 'thumbnail_url') String? thumbnailUrl,@JsonKey(name: 'streamer_id') String streamerId,@JsonKey(name: 'streamer_name') String streamerName,@JsonKey(name: 'streamer_avatar_url') String? streamerAvatarUrl
});




}
/// @nodoc
class __$LiveRoomDtoCopyWithImpl<$Res>
    implements _$LiveRoomDtoCopyWith<$Res> {
  __$LiveRoomDtoCopyWithImpl(this._self, this._then);

  final _LiveRoomDto _self;
  final $Res Function(_LiveRoomDto) _then;

/// Create a copy of LiveRoomDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? description = freezed,Object? category = freezed,Object? liveType = null,Object? isPrivate = null,Object? status = null,Object? viewerCount = null,Object? streamUrl = freezed,Object? thumbnailUrl = freezed,Object? streamerId = null,Object? streamerName = null,Object? streamerAvatarUrl = freezed,}) {
  return _then(_LiveRoomDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,liveType: null == liveType ? _self.liveType : liveType // ignore: cast_nullable_to_non_nullable
as String,isPrivate: null == isPrivate ? _self.isPrivate : isPrivate // ignore: cast_nullable_to_non_nullable
as bool,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,viewerCount: null == viewerCount ? _self.viewerCount : viewerCount // ignore: cast_nullable_to_non_nullable
as int,streamUrl: freezed == streamUrl ? _self.streamUrl : streamUrl // ignore: cast_nullable_to_non_nullable
as String?,thumbnailUrl: freezed == thumbnailUrl ? _self.thumbnailUrl : thumbnailUrl // ignore: cast_nullable_to_non_nullable
as String?,streamerId: null == streamerId ? _self.streamerId : streamerId // ignore: cast_nullable_to_non_nullable
as String,streamerName: null == streamerName ? _self.streamerName : streamerName // ignore: cast_nullable_to_non_nullable
as String,streamerAvatarUrl: freezed == streamerAvatarUrl ? _self.streamerAvatarUrl : streamerAvatarUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$LiveFeedResponseDto {

 List<LiveRoomDto> get rooms; String? get cursor; int get limit;
/// Create a copy of LiveFeedResponseDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LiveFeedResponseDtoCopyWith<LiveFeedResponseDto> get copyWith => _$LiveFeedResponseDtoCopyWithImpl<LiveFeedResponseDto>(this as LiveFeedResponseDto, _$identity);

  /// Serializes this LiveFeedResponseDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LiveFeedResponseDto&&const DeepCollectionEquality().equals(other.rooms, rooms)&&(identical(other.cursor, cursor) || other.cursor == cursor)&&(identical(other.limit, limit) || other.limit == limit));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(rooms),cursor,limit);

@override
String toString() {
  return 'LiveFeedResponseDto(rooms: $rooms, cursor: $cursor, limit: $limit)';
}


}

/// @nodoc
abstract mixin class $LiveFeedResponseDtoCopyWith<$Res>  {
  factory $LiveFeedResponseDtoCopyWith(LiveFeedResponseDto value, $Res Function(LiveFeedResponseDto) _then) = _$LiveFeedResponseDtoCopyWithImpl;
@useResult
$Res call({
 List<LiveRoomDto> rooms, String? cursor, int limit
});




}
/// @nodoc
class _$LiveFeedResponseDtoCopyWithImpl<$Res>
    implements $LiveFeedResponseDtoCopyWith<$Res> {
  _$LiveFeedResponseDtoCopyWithImpl(this._self, this._then);

  final LiveFeedResponseDto _self;
  final $Res Function(LiveFeedResponseDto) _then;

/// Create a copy of LiveFeedResponseDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? rooms = null,Object? cursor = freezed,Object? limit = null,}) {
  return _then(_self.copyWith(
rooms: null == rooms ? _self.rooms : rooms // ignore: cast_nullable_to_non_nullable
as List<LiveRoomDto>,cursor: freezed == cursor ? _self.cursor : cursor // ignore: cast_nullable_to_non_nullable
as String?,limit: null == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [LiveFeedResponseDto].
extension LiveFeedResponseDtoPatterns on LiveFeedResponseDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LiveFeedResponseDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LiveFeedResponseDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LiveFeedResponseDto value)  $default,){
final _that = this;
switch (_that) {
case _LiveFeedResponseDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LiveFeedResponseDto value)?  $default,){
final _that = this;
switch (_that) {
case _LiveFeedResponseDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<LiveRoomDto> rooms,  String? cursor,  int limit)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LiveFeedResponseDto() when $default != null:
return $default(_that.rooms,_that.cursor,_that.limit);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<LiveRoomDto> rooms,  String? cursor,  int limit)  $default,) {final _that = this;
switch (_that) {
case _LiveFeedResponseDto():
return $default(_that.rooms,_that.cursor,_that.limit);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<LiveRoomDto> rooms,  String? cursor,  int limit)?  $default,) {final _that = this;
switch (_that) {
case _LiveFeedResponseDto() when $default != null:
return $default(_that.rooms,_that.cursor,_that.limit);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LiveFeedResponseDto implements LiveFeedResponseDto {
  const _LiveFeedResponseDto({final  List<LiveRoomDto> rooms = const [], this.cursor, this.limit = 10}): _rooms = rooms;
  factory _LiveFeedResponseDto.fromJson(Map<String, dynamic> json) => _$LiveFeedResponseDtoFromJson(json);

 final  List<LiveRoomDto> _rooms;
@override@JsonKey() List<LiveRoomDto> get rooms {
  if (_rooms is EqualUnmodifiableListView) return _rooms;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_rooms);
}

@override final  String? cursor;
@override@JsonKey() final  int limit;

/// Create a copy of LiveFeedResponseDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LiveFeedResponseDtoCopyWith<_LiveFeedResponseDto> get copyWith => __$LiveFeedResponseDtoCopyWithImpl<_LiveFeedResponseDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LiveFeedResponseDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LiveFeedResponseDto&&const DeepCollectionEquality().equals(other._rooms, _rooms)&&(identical(other.cursor, cursor) || other.cursor == cursor)&&(identical(other.limit, limit) || other.limit == limit));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_rooms),cursor,limit);

@override
String toString() {
  return 'LiveFeedResponseDto(rooms: $rooms, cursor: $cursor, limit: $limit)';
}


}

/// @nodoc
abstract mixin class _$LiveFeedResponseDtoCopyWith<$Res> implements $LiveFeedResponseDtoCopyWith<$Res> {
  factory _$LiveFeedResponseDtoCopyWith(_LiveFeedResponseDto value, $Res Function(_LiveFeedResponseDto) _then) = __$LiveFeedResponseDtoCopyWithImpl;
@override @useResult
$Res call({
 List<LiveRoomDto> rooms, String? cursor, int limit
});




}
/// @nodoc
class __$LiveFeedResponseDtoCopyWithImpl<$Res>
    implements _$LiveFeedResponseDtoCopyWith<$Res> {
  __$LiveFeedResponseDtoCopyWithImpl(this._self, this._then);

  final _LiveFeedResponseDto _self;
  final $Res Function(_LiveFeedResponseDto) _then;

/// Create a copy of LiveFeedResponseDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? rooms = null,Object? cursor = freezed,Object? limit = null,}) {
  return _then(_LiveFeedResponseDto(
rooms: null == rooms ? _self._rooms : rooms // ignore: cast_nullable_to_non_nullable
as List<LiveRoomDto>,cursor: freezed == cursor ? _self.cursor : cursor // ignore: cast_nullable_to_non_nullable
as String?,limit: null == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
