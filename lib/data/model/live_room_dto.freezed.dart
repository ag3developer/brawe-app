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

 String? get id; String? get slug; String get title; String? get description; String? get category;@JsonKey(name: 'live_type') String get liveType;@JsonKey(name: 'is_private') bool get isPrivate; String get status;@JsonKey(name: 'viewer_count') int get viewerCount;@JsonKey(name: 'total_likes') int get totalLikes;@JsonKey(name: 'total_messages') int get totalMessages;@JsonKey(name: 'is_paused') bool get isPaused;@JsonKey(name: 'paused_at') String? get pausedAt;@JsonKey(name: 'playback_url') String? get playbackUrl;@JsonKey(name: 'thumbnail_url') String? get thumbnailUrl;@JsonKey(name: 'stream_config') StreamConfigDto? get streamConfig;@JsonKey(name: 'host') HostDto? get host;@JsonKey(name: 'streamer_id') String? get streamerId;@JsonKey(name: 'streamer_name') String? get streamerName;@JsonKey(name: 'streamer_avatar') String? get streamerAvatar;@JsonKey(name: 'streamer_username') String? get streamerUsername;@JsonKey(name: 'is_verified') bool get isVerified;@JsonKey(name: 'ingest_url') String? get ingestUrl;@JsonKey(name: 'started_at') String? get startedAt;@JsonKey(name: 'created_at') String? get createdAt;// ⚔️ Campos de batalha — presentes quando live_type = 'battle'
@JsonKey(name: 'battle_id') String? get battleId;@JsonKey(name: 'opponent_id') String? get opponentId;@JsonKey(name: 'opponent_name') String? get opponentName;@JsonKey(name: 'opponent_avatar') String? get opponentAvatar;@JsonKey(name: 'opponent_room_id') String? get opponentRoomId;@JsonKey(name: 'opponent_thumbnail_url') String? get opponentThumbnailUrl;@JsonKey(name: 'battle_duration_seconds') int? get battleDurationSeconds;
/// Create a copy of LiveRoomDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LiveRoomDtoCopyWith<LiveRoomDto> get copyWith => _$LiveRoomDtoCopyWithImpl<LiveRoomDto>(this as LiveRoomDto, _$identity);

  /// Serializes this LiveRoomDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LiveRoomDto&&(identical(other.id, id) || other.id == id)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.category, category) || other.category == category)&&(identical(other.liveType, liveType) || other.liveType == liveType)&&(identical(other.isPrivate, isPrivate) || other.isPrivate == isPrivate)&&(identical(other.status, status) || other.status == status)&&(identical(other.viewerCount, viewerCount) || other.viewerCount == viewerCount)&&(identical(other.totalLikes, totalLikes) || other.totalLikes == totalLikes)&&(identical(other.totalMessages, totalMessages) || other.totalMessages == totalMessages)&&(identical(other.isPaused, isPaused) || other.isPaused == isPaused)&&(identical(other.pausedAt, pausedAt) || other.pausedAt == pausedAt)&&(identical(other.playbackUrl, playbackUrl) || other.playbackUrl == playbackUrl)&&(identical(other.thumbnailUrl, thumbnailUrl) || other.thumbnailUrl == thumbnailUrl)&&(identical(other.streamConfig, streamConfig) || other.streamConfig == streamConfig)&&(identical(other.host, host) || other.host == host)&&(identical(other.streamerId, streamerId) || other.streamerId == streamerId)&&(identical(other.streamerName, streamerName) || other.streamerName == streamerName)&&(identical(other.streamerAvatar, streamerAvatar) || other.streamerAvatar == streamerAvatar)&&(identical(other.streamerUsername, streamerUsername) || other.streamerUsername == streamerUsername)&&(identical(other.isVerified, isVerified) || other.isVerified == isVerified)&&(identical(other.ingestUrl, ingestUrl) || other.ingestUrl == ingestUrl)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.battleId, battleId) || other.battleId == battleId)&&(identical(other.opponentId, opponentId) || other.opponentId == opponentId)&&(identical(other.opponentName, opponentName) || other.opponentName == opponentName)&&(identical(other.opponentAvatar, opponentAvatar) || other.opponentAvatar == opponentAvatar)&&(identical(other.opponentRoomId, opponentRoomId) || other.opponentRoomId == opponentRoomId)&&(identical(other.opponentThumbnailUrl, opponentThumbnailUrl) || other.opponentThumbnailUrl == opponentThumbnailUrl)&&(identical(other.battleDurationSeconds, battleDurationSeconds) || other.battleDurationSeconds == battleDurationSeconds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,slug,title,description,category,liveType,isPrivate,status,viewerCount,totalLikes,totalMessages,isPaused,pausedAt,playbackUrl,thumbnailUrl,streamConfig,host,streamerId,streamerName,streamerAvatar,streamerUsername,isVerified,ingestUrl,startedAt,createdAt,battleId,opponentId,opponentName,opponentAvatar,opponentRoomId,opponentThumbnailUrl,battleDurationSeconds]);

@override
String toString() {
  return 'LiveRoomDto(id: $id, slug: $slug, title: $title, description: $description, category: $category, liveType: $liveType, isPrivate: $isPrivate, status: $status, viewerCount: $viewerCount, totalLikes: $totalLikes, totalMessages: $totalMessages, isPaused: $isPaused, pausedAt: $pausedAt, playbackUrl: $playbackUrl, thumbnailUrl: $thumbnailUrl, streamConfig: $streamConfig, host: $host, streamerId: $streamerId, streamerName: $streamerName, streamerAvatar: $streamerAvatar, streamerUsername: $streamerUsername, isVerified: $isVerified, ingestUrl: $ingestUrl, startedAt: $startedAt, createdAt: $createdAt, battleId: $battleId, opponentId: $opponentId, opponentName: $opponentName, opponentAvatar: $opponentAvatar, opponentRoomId: $opponentRoomId, opponentThumbnailUrl: $opponentThumbnailUrl, battleDurationSeconds: $battleDurationSeconds)';
}


}

/// @nodoc
abstract mixin class $LiveRoomDtoCopyWith<$Res>  {
  factory $LiveRoomDtoCopyWith(LiveRoomDto value, $Res Function(LiveRoomDto) _then) = _$LiveRoomDtoCopyWithImpl;
@useResult
$Res call({
 String? id, String? slug, String title, String? description, String? category,@JsonKey(name: 'live_type') String liveType,@JsonKey(name: 'is_private') bool isPrivate, String status,@JsonKey(name: 'viewer_count') int viewerCount,@JsonKey(name: 'total_likes') int totalLikes,@JsonKey(name: 'total_messages') int totalMessages,@JsonKey(name: 'is_paused') bool isPaused,@JsonKey(name: 'paused_at') String? pausedAt,@JsonKey(name: 'playback_url') String? playbackUrl,@JsonKey(name: 'thumbnail_url') String? thumbnailUrl,@JsonKey(name: 'stream_config') StreamConfigDto? streamConfig,@JsonKey(name: 'host') HostDto? host,@JsonKey(name: 'streamer_id') String? streamerId,@JsonKey(name: 'streamer_name') String? streamerName,@JsonKey(name: 'streamer_avatar') String? streamerAvatar,@JsonKey(name: 'streamer_username') String? streamerUsername,@JsonKey(name: 'is_verified') bool isVerified,@JsonKey(name: 'ingest_url') String? ingestUrl,@JsonKey(name: 'started_at') String? startedAt,@JsonKey(name: 'created_at') String? createdAt,@JsonKey(name: 'battle_id') String? battleId,@JsonKey(name: 'opponent_id') String? opponentId,@JsonKey(name: 'opponent_name') String? opponentName,@JsonKey(name: 'opponent_avatar') String? opponentAvatar,@JsonKey(name: 'opponent_room_id') String? opponentRoomId,@JsonKey(name: 'opponent_thumbnail_url') String? opponentThumbnailUrl,@JsonKey(name: 'battle_duration_seconds') int? battleDurationSeconds
});


$StreamConfigDtoCopyWith<$Res>? get streamConfig;$HostDtoCopyWith<$Res>? get host;

}
/// @nodoc
class _$LiveRoomDtoCopyWithImpl<$Res>
    implements $LiveRoomDtoCopyWith<$Res> {
  _$LiveRoomDtoCopyWithImpl(this._self, this._then);

  final LiveRoomDto _self;
  final $Res Function(LiveRoomDto) _then;

/// Create a copy of LiveRoomDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? slug = freezed,Object? title = null,Object? description = freezed,Object? category = freezed,Object? liveType = null,Object? isPrivate = null,Object? status = null,Object? viewerCount = null,Object? totalLikes = null,Object? totalMessages = null,Object? isPaused = null,Object? pausedAt = freezed,Object? playbackUrl = freezed,Object? thumbnailUrl = freezed,Object? streamConfig = freezed,Object? host = freezed,Object? streamerId = freezed,Object? streamerName = freezed,Object? streamerAvatar = freezed,Object? streamerUsername = freezed,Object? isVerified = null,Object? ingestUrl = freezed,Object? startedAt = freezed,Object? createdAt = freezed,Object? battleId = freezed,Object? opponentId = freezed,Object? opponentName = freezed,Object? opponentAvatar = freezed,Object? opponentRoomId = freezed,Object? opponentThumbnailUrl = freezed,Object? battleDurationSeconds = freezed,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,slug: freezed == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String?,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
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
as String?,playbackUrl: freezed == playbackUrl ? _self.playbackUrl : playbackUrl // ignore: cast_nullable_to_non_nullable
as String?,thumbnailUrl: freezed == thumbnailUrl ? _self.thumbnailUrl : thumbnailUrl // ignore: cast_nullable_to_non_nullable
as String?,streamConfig: freezed == streamConfig ? _self.streamConfig : streamConfig // ignore: cast_nullable_to_non_nullable
as StreamConfigDto?,host: freezed == host ? _self.host : host // ignore: cast_nullable_to_non_nullable
as HostDto?,streamerId: freezed == streamerId ? _self.streamerId : streamerId // ignore: cast_nullable_to_non_nullable
as String?,streamerName: freezed == streamerName ? _self.streamerName : streamerName // ignore: cast_nullable_to_non_nullable
as String?,streamerAvatar: freezed == streamerAvatar ? _self.streamerAvatar : streamerAvatar // ignore: cast_nullable_to_non_nullable
as String?,streamerUsername: freezed == streamerUsername ? _self.streamerUsername : streamerUsername // ignore: cast_nullable_to_non_nullable
as String?,isVerified: null == isVerified ? _self.isVerified : isVerified // ignore: cast_nullable_to_non_nullable
as bool,ingestUrl: freezed == ingestUrl ? _self.ingestUrl : ingestUrl // ignore: cast_nullable_to_non_nullable
as String?,startedAt: freezed == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,battleId: freezed == battleId ? _self.battleId : battleId // ignore: cast_nullable_to_non_nullable
as String?,opponentId: freezed == opponentId ? _self.opponentId : opponentId // ignore: cast_nullable_to_non_nullable
as String?,opponentName: freezed == opponentName ? _self.opponentName : opponentName // ignore: cast_nullable_to_non_nullable
as String?,opponentAvatar: freezed == opponentAvatar ? _self.opponentAvatar : opponentAvatar // ignore: cast_nullable_to_non_nullable
as String?,opponentRoomId: freezed == opponentRoomId ? _self.opponentRoomId : opponentRoomId // ignore: cast_nullable_to_non_nullable
as String?,opponentThumbnailUrl: freezed == opponentThumbnailUrl ? _self.opponentThumbnailUrl : opponentThumbnailUrl // ignore: cast_nullable_to_non_nullable
as String?,battleDurationSeconds: freezed == battleDurationSeconds ? _self.battleDurationSeconds : battleDurationSeconds // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}
/// Create a copy of LiveRoomDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$StreamConfigDtoCopyWith<$Res>? get streamConfig {
    if (_self.streamConfig == null) {
    return null;
  }

  return $StreamConfigDtoCopyWith<$Res>(_self.streamConfig!, (value) {
    return _then(_self.copyWith(streamConfig: value));
  });
}/// Create a copy of LiveRoomDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HostDtoCopyWith<$Res>? get host {
    if (_self.host == null) {
    return null;
  }

  return $HostDtoCopyWith<$Res>(_self.host!, (value) {
    return _then(_self.copyWith(host: value));
  });
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? id,  String? slug,  String title,  String? description,  String? category, @JsonKey(name: 'live_type')  String liveType, @JsonKey(name: 'is_private')  bool isPrivate,  String status, @JsonKey(name: 'viewer_count')  int viewerCount, @JsonKey(name: 'total_likes')  int totalLikes, @JsonKey(name: 'total_messages')  int totalMessages, @JsonKey(name: 'is_paused')  bool isPaused, @JsonKey(name: 'paused_at')  String? pausedAt, @JsonKey(name: 'playback_url')  String? playbackUrl, @JsonKey(name: 'thumbnail_url')  String? thumbnailUrl, @JsonKey(name: 'stream_config')  StreamConfigDto? streamConfig, @JsonKey(name: 'host')  HostDto? host, @JsonKey(name: 'streamer_id')  String? streamerId, @JsonKey(name: 'streamer_name')  String? streamerName, @JsonKey(name: 'streamer_avatar')  String? streamerAvatar, @JsonKey(name: 'streamer_username')  String? streamerUsername, @JsonKey(name: 'is_verified')  bool isVerified, @JsonKey(name: 'ingest_url')  String? ingestUrl, @JsonKey(name: 'started_at')  String? startedAt, @JsonKey(name: 'created_at')  String? createdAt, @JsonKey(name: 'battle_id')  String? battleId, @JsonKey(name: 'opponent_id')  String? opponentId, @JsonKey(name: 'opponent_name')  String? opponentName, @JsonKey(name: 'opponent_avatar')  String? opponentAvatar, @JsonKey(name: 'opponent_room_id')  String? opponentRoomId, @JsonKey(name: 'opponent_thumbnail_url')  String? opponentThumbnailUrl, @JsonKey(name: 'battle_duration_seconds')  int? battleDurationSeconds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LiveRoomDto() when $default != null:
return $default(_that.id,_that.slug,_that.title,_that.description,_that.category,_that.liveType,_that.isPrivate,_that.status,_that.viewerCount,_that.totalLikes,_that.totalMessages,_that.isPaused,_that.pausedAt,_that.playbackUrl,_that.thumbnailUrl,_that.streamConfig,_that.host,_that.streamerId,_that.streamerName,_that.streamerAvatar,_that.streamerUsername,_that.isVerified,_that.ingestUrl,_that.startedAt,_that.createdAt,_that.battleId,_that.opponentId,_that.opponentName,_that.opponentAvatar,_that.opponentRoomId,_that.opponentThumbnailUrl,_that.battleDurationSeconds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? id,  String? slug,  String title,  String? description,  String? category, @JsonKey(name: 'live_type')  String liveType, @JsonKey(name: 'is_private')  bool isPrivate,  String status, @JsonKey(name: 'viewer_count')  int viewerCount, @JsonKey(name: 'total_likes')  int totalLikes, @JsonKey(name: 'total_messages')  int totalMessages, @JsonKey(name: 'is_paused')  bool isPaused, @JsonKey(name: 'paused_at')  String? pausedAt, @JsonKey(name: 'playback_url')  String? playbackUrl, @JsonKey(name: 'thumbnail_url')  String? thumbnailUrl, @JsonKey(name: 'stream_config')  StreamConfigDto? streamConfig, @JsonKey(name: 'host')  HostDto? host, @JsonKey(name: 'streamer_id')  String? streamerId, @JsonKey(name: 'streamer_name')  String? streamerName, @JsonKey(name: 'streamer_avatar')  String? streamerAvatar, @JsonKey(name: 'streamer_username')  String? streamerUsername, @JsonKey(name: 'is_verified')  bool isVerified, @JsonKey(name: 'ingest_url')  String? ingestUrl, @JsonKey(name: 'started_at')  String? startedAt, @JsonKey(name: 'created_at')  String? createdAt, @JsonKey(name: 'battle_id')  String? battleId, @JsonKey(name: 'opponent_id')  String? opponentId, @JsonKey(name: 'opponent_name')  String? opponentName, @JsonKey(name: 'opponent_avatar')  String? opponentAvatar, @JsonKey(name: 'opponent_room_id')  String? opponentRoomId, @JsonKey(name: 'opponent_thumbnail_url')  String? opponentThumbnailUrl, @JsonKey(name: 'battle_duration_seconds')  int? battleDurationSeconds)  $default,) {final _that = this;
switch (_that) {
case _LiveRoomDto():
return $default(_that.id,_that.slug,_that.title,_that.description,_that.category,_that.liveType,_that.isPrivate,_that.status,_that.viewerCount,_that.totalLikes,_that.totalMessages,_that.isPaused,_that.pausedAt,_that.playbackUrl,_that.thumbnailUrl,_that.streamConfig,_that.host,_that.streamerId,_that.streamerName,_that.streamerAvatar,_that.streamerUsername,_that.isVerified,_that.ingestUrl,_that.startedAt,_that.createdAt,_that.battleId,_that.opponentId,_that.opponentName,_that.opponentAvatar,_that.opponentRoomId,_that.opponentThumbnailUrl,_that.battleDurationSeconds);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? id,  String? slug,  String title,  String? description,  String? category, @JsonKey(name: 'live_type')  String liveType, @JsonKey(name: 'is_private')  bool isPrivate,  String status, @JsonKey(name: 'viewer_count')  int viewerCount, @JsonKey(name: 'total_likes')  int totalLikes, @JsonKey(name: 'total_messages')  int totalMessages, @JsonKey(name: 'is_paused')  bool isPaused, @JsonKey(name: 'paused_at')  String? pausedAt, @JsonKey(name: 'playback_url')  String? playbackUrl, @JsonKey(name: 'thumbnail_url')  String? thumbnailUrl, @JsonKey(name: 'stream_config')  StreamConfigDto? streamConfig, @JsonKey(name: 'host')  HostDto? host, @JsonKey(name: 'streamer_id')  String? streamerId, @JsonKey(name: 'streamer_name')  String? streamerName, @JsonKey(name: 'streamer_avatar')  String? streamerAvatar, @JsonKey(name: 'streamer_username')  String? streamerUsername, @JsonKey(name: 'is_verified')  bool isVerified, @JsonKey(name: 'ingest_url')  String? ingestUrl, @JsonKey(name: 'started_at')  String? startedAt, @JsonKey(name: 'created_at')  String? createdAt, @JsonKey(name: 'battle_id')  String? battleId, @JsonKey(name: 'opponent_id')  String? opponentId, @JsonKey(name: 'opponent_name')  String? opponentName, @JsonKey(name: 'opponent_avatar')  String? opponentAvatar, @JsonKey(name: 'opponent_room_id')  String? opponentRoomId, @JsonKey(name: 'opponent_thumbnail_url')  String? opponentThumbnailUrl, @JsonKey(name: 'battle_duration_seconds')  int? battleDurationSeconds)?  $default,) {final _that = this;
switch (_that) {
case _LiveRoomDto() when $default != null:
return $default(_that.id,_that.slug,_that.title,_that.description,_that.category,_that.liveType,_that.isPrivate,_that.status,_that.viewerCount,_that.totalLikes,_that.totalMessages,_that.isPaused,_that.pausedAt,_that.playbackUrl,_that.thumbnailUrl,_that.streamConfig,_that.host,_that.streamerId,_that.streamerName,_that.streamerAvatar,_that.streamerUsername,_that.isVerified,_that.ingestUrl,_that.startedAt,_that.createdAt,_that.battleId,_that.opponentId,_that.opponentName,_that.opponentAvatar,_that.opponentRoomId,_that.opponentThumbnailUrl,_that.battleDurationSeconds);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LiveRoomDto implements LiveRoomDto {
  const _LiveRoomDto({this.id, this.slug, this.title = 'Untitled Live', this.description, this.category, @JsonKey(name: 'live_type') this.liveType = 'solo', @JsonKey(name: 'is_private') this.isPrivate = false, this.status = AppConstants.statusLive, @JsonKey(name: 'viewer_count') this.viewerCount = 0, @JsonKey(name: 'total_likes') this.totalLikes = 0, @JsonKey(name: 'total_messages') this.totalMessages = 0, @JsonKey(name: 'is_paused') this.isPaused = false, @JsonKey(name: 'paused_at') this.pausedAt, @JsonKey(name: 'playback_url') this.playbackUrl, @JsonKey(name: 'thumbnail_url') this.thumbnailUrl, @JsonKey(name: 'stream_config') this.streamConfig, @JsonKey(name: 'host') this.host, @JsonKey(name: 'streamer_id') this.streamerId, @JsonKey(name: 'streamer_name') this.streamerName, @JsonKey(name: 'streamer_avatar') this.streamerAvatar, @JsonKey(name: 'streamer_username') this.streamerUsername, @JsonKey(name: 'is_verified') this.isVerified = false, @JsonKey(name: 'ingest_url') this.ingestUrl, @JsonKey(name: 'started_at') this.startedAt, @JsonKey(name: 'created_at') this.createdAt, @JsonKey(name: 'battle_id') this.battleId, @JsonKey(name: 'opponent_id') this.opponentId, @JsonKey(name: 'opponent_name') this.opponentName, @JsonKey(name: 'opponent_avatar') this.opponentAvatar, @JsonKey(name: 'opponent_room_id') this.opponentRoomId, @JsonKey(name: 'opponent_thumbnail_url') this.opponentThumbnailUrl, @JsonKey(name: 'battle_duration_seconds') this.battleDurationSeconds});
  factory _LiveRoomDto.fromJson(Map<String, dynamic> json) => _$LiveRoomDtoFromJson(json);

@override final  String? id;
@override final  String? slug;
@override@JsonKey() final  String title;
@override final  String? description;
@override final  String? category;
@override@JsonKey(name: 'live_type') final  String liveType;
@override@JsonKey(name: 'is_private') final  bool isPrivate;
@override@JsonKey() final  String status;
@override@JsonKey(name: 'viewer_count') final  int viewerCount;
@override@JsonKey(name: 'total_likes') final  int totalLikes;
@override@JsonKey(name: 'total_messages') final  int totalMessages;
@override@JsonKey(name: 'is_paused') final  bool isPaused;
@override@JsonKey(name: 'paused_at') final  String? pausedAt;
@override@JsonKey(name: 'playback_url') final  String? playbackUrl;
@override@JsonKey(name: 'thumbnail_url') final  String? thumbnailUrl;
@override@JsonKey(name: 'stream_config') final  StreamConfigDto? streamConfig;
@override@JsonKey(name: 'host') final  HostDto? host;
@override@JsonKey(name: 'streamer_id') final  String? streamerId;
@override@JsonKey(name: 'streamer_name') final  String? streamerName;
@override@JsonKey(name: 'streamer_avatar') final  String? streamerAvatar;
@override@JsonKey(name: 'streamer_username') final  String? streamerUsername;
@override@JsonKey(name: 'is_verified') final  bool isVerified;
@override@JsonKey(name: 'ingest_url') final  String? ingestUrl;
@override@JsonKey(name: 'started_at') final  String? startedAt;
@override@JsonKey(name: 'created_at') final  String? createdAt;
// ⚔️ Campos de batalha — presentes quando live_type = 'battle'
@override@JsonKey(name: 'battle_id') final  String? battleId;
@override@JsonKey(name: 'opponent_id') final  String? opponentId;
@override@JsonKey(name: 'opponent_name') final  String? opponentName;
@override@JsonKey(name: 'opponent_avatar') final  String? opponentAvatar;
@override@JsonKey(name: 'opponent_room_id') final  String? opponentRoomId;
@override@JsonKey(name: 'opponent_thumbnail_url') final  String? opponentThumbnailUrl;
@override@JsonKey(name: 'battle_duration_seconds') final  int? battleDurationSeconds;

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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LiveRoomDto&&(identical(other.id, id) || other.id == id)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.category, category) || other.category == category)&&(identical(other.liveType, liveType) || other.liveType == liveType)&&(identical(other.isPrivate, isPrivate) || other.isPrivate == isPrivate)&&(identical(other.status, status) || other.status == status)&&(identical(other.viewerCount, viewerCount) || other.viewerCount == viewerCount)&&(identical(other.totalLikes, totalLikes) || other.totalLikes == totalLikes)&&(identical(other.totalMessages, totalMessages) || other.totalMessages == totalMessages)&&(identical(other.isPaused, isPaused) || other.isPaused == isPaused)&&(identical(other.pausedAt, pausedAt) || other.pausedAt == pausedAt)&&(identical(other.playbackUrl, playbackUrl) || other.playbackUrl == playbackUrl)&&(identical(other.thumbnailUrl, thumbnailUrl) || other.thumbnailUrl == thumbnailUrl)&&(identical(other.streamConfig, streamConfig) || other.streamConfig == streamConfig)&&(identical(other.host, host) || other.host == host)&&(identical(other.streamerId, streamerId) || other.streamerId == streamerId)&&(identical(other.streamerName, streamerName) || other.streamerName == streamerName)&&(identical(other.streamerAvatar, streamerAvatar) || other.streamerAvatar == streamerAvatar)&&(identical(other.streamerUsername, streamerUsername) || other.streamerUsername == streamerUsername)&&(identical(other.isVerified, isVerified) || other.isVerified == isVerified)&&(identical(other.ingestUrl, ingestUrl) || other.ingestUrl == ingestUrl)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.battleId, battleId) || other.battleId == battleId)&&(identical(other.opponentId, opponentId) || other.opponentId == opponentId)&&(identical(other.opponentName, opponentName) || other.opponentName == opponentName)&&(identical(other.opponentAvatar, opponentAvatar) || other.opponentAvatar == opponentAvatar)&&(identical(other.opponentRoomId, opponentRoomId) || other.opponentRoomId == opponentRoomId)&&(identical(other.opponentThumbnailUrl, opponentThumbnailUrl) || other.opponentThumbnailUrl == opponentThumbnailUrl)&&(identical(other.battleDurationSeconds, battleDurationSeconds) || other.battleDurationSeconds == battleDurationSeconds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,slug,title,description,category,liveType,isPrivate,status,viewerCount,totalLikes,totalMessages,isPaused,pausedAt,playbackUrl,thumbnailUrl,streamConfig,host,streamerId,streamerName,streamerAvatar,streamerUsername,isVerified,ingestUrl,startedAt,createdAt,battleId,opponentId,opponentName,opponentAvatar,opponentRoomId,opponentThumbnailUrl,battleDurationSeconds]);

@override
String toString() {
  return 'LiveRoomDto(id: $id, slug: $slug, title: $title, description: $description, category: $category, liveType: $liveType, isPrivate: $isPrivate, status: $status, viewerCount: $viewerCount, totalLikes: $totalLikes, totalMessages: $totalMessages, isPaused: $isPaused, pausedAt: $pausedAt, playbackUrl: $playbackUrl, thumbnailUrl: $thumbnailUrl, streamConfig: $streamConfig, host: $host, streamerId: $streamerId, streamerName: $streamerName, streamerAvatar: $streamerAvatar, streamerUsername: $streamerUsername, isVerified: $isVerified, ingestUrl: $ingestUrl, startedAt: $startedAt, createdAt: $createdAt, battleId: $battleId, opponentId: $opponentId, opponentName: $opponentName, opponentAvatar: $opponentAvatar, opponentRoomId: $opponentRoomId, opponentThumbnailUrl: $opponentThumbnailUrl, battleDurationSeconds: $battleDurationSeconds)';
}


}

/// @nodoc
abstract mixin class _$LiveRoomDtoCopyWith<$Res> implements $LiveRoomDtoCopyWith<$Res> {
  factory _$LiveRoomDtoCopyWith(_LiveRoomDto value, $Res Function(_LiveRoomDto) _then) = __$LiveRoomDtoCopyWithImpl;
@override @useResult
$Res call({
 String? id, String? slug, String title, String? description, String? category,@JsonKey(name: 'live_type') String liveType,@JsonKey(name: 'is_private') bool isPrivate, String status,@JsonKey(name: 'viewer_count') int viewerCount,@JsonKey(name: 'total_likes') int totalLikes,@JsonKey(name: 'total_messages') int totalMessages,@JsonKey(name: 'is_paused') bool isPaused,@JsonKey(name: 'paused_at') String? pausedAt,@JsonKey(name: 'playback_url') String? playbackUrl,@JsonKey(name: 'thumbnail_url') String? thumbnailUrl,@JsonKey(name: 'stream_config') StreamConfigDto? streamConfig,@JsonKey(name: 'host') HostDto? host,@JsonKey(name: 'streamer_id') String? streamerId,@JsonKey(name: 'streamer_name') String? streamerName,@JsonKey(name: 'streamer_avatar') String? streamerAvatar,@JsonKey(name: 'streamer_username') String? streamerUsername,@JsonKey(name: 'is_verified') bool isVerified,@JsonKey(name: 'ingest_url') String? ingestUrl,@JsonKey(name: 'started_at') String? startedAt,@JsonKey(name: 'created_at') String? createdAt,@JsonKey(name: 'battle_id') String? battleId,@JsonKey(name: 'opponent_id') String? opponentId,@JsonKey(name: 'opponent_name') String? opponentName,@JsonKey(name: 'opponent_avatar') String? opponentAvatar,@JsonKey(name: 'opponent_room_id') String? opponentRoomId,@JsonKey(name: 'opponent_thumbnail_url') String? opponentThumbnailUrl,@JsonKey(name: 'battle_duration_seconds') int? battleDurationSeconds
});


@override $StreamConfigDtoCopyWith<$Res>? get streamConfig;@override $HostDtoCopyWith<$Res>? get host;

}
/// @nodoc
class __$LiveRoomDtoCopyWithImpl<$Res>
    implements _$LiveRoomDtoCopyWith<$Res> {
  __$LiveRoomDtoCopyWithImpl(this._self, this._then);

  final _LiveRoomDto _self;
  final $Res Function(_LiveRoomDto) _then;

/// Create a copy of LiveRoomDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? slug = freezed,Object? title = null,Object? description = freezed,Object? category = freezed,Object? liveType = null,Object? isPrivate = null,Object? status = null,Object? viewerCount = null,Object? totalLikes = null,Object? totalMessages = null,Object? isPaused = null,Object? pausedAt = freezed,Object? playbackUrl = freezed,Object? thumbnailUrl = freezed,Object? streamConfig = freezed,Object? host = freezed,Object? streamerId = freezed,Object? streamerName = freezed,Object? streamerAvatar = freezed,Object? streamerUsername = freezed,Object? isVerified = null,Object? ingestUrl = freezed,Object? startedAt = freezed,Object? createdAt = freezed,Object? battleId = freezed,Object? opponentId = freezed,Object? opponentName = freezed,Object? opponentAvatar = freezed,Object? opponentRoomId = freezed,Object? opponentThumbnailUrl = freezed,Object? battleDurationSeconds = freezed,}) {
  return _then(_LiveRoomDto(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,slug: freezed == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String?,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
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
as String?,playbackUrl: freezed == playbackUrl ? _self.playbackUrl : playbackUrl // ignore: cast_nullable_to_non_nullable
as String?,thumbnailUrl: freezed == thumbnailUrl ? _self.thumbnailUrl : thumbnailUrl // ignore: cast_nullable_to_non_nullable
as String?,streamConfig: freezed == streamConfig ? _self.streamConfig : streamConfig // ignore: cast_nullable_to_non_nullable
as StreamConfigDto?,host: freezed == host ? _self.host : host // ignore: cast_nullable_to_non_nullable
as HostDto?,streamerId: freezed == streamerId ? _self.streamerId : streamerId // ignore: cast_nullable_to_non_nullable
as String?,streamerName: freezed == streamerName ? _self.streamerName : streamerName // ignore: cast_nullable_to_non_nullable
as String?,streamerAvatar: freezed == streamerAvatar ? _self.streamerAvatar : streamerAvatar // ignore: cast_nullable_to_non_nullable
as String?,streamerUsername: freezed == streamerUsername ? _self.streamerUsername : streamerUsername // ignore: cast_nullable_to_non_nullable
as String?,isVerified: null == isVerified ? _self.isVerified : isVerified // ignore: cast_nullable_to_non_nullable
as bool,ingestUrl: freezed == ingestUrl ? _self.ingestUrl : ingestUrl // ignore: cast_nullable_to_non_nullable
as String?,startedAt: freezed == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,battleId: freezed == battleId ? _self.battleId : battleId // ignore: cast_nullable_to_non_nullable
as String?,opponentId: freezed == opponentId ? _self.opponentId : opponentId // ignore: cast_nullable_to_non_nullable
as String?,opponentName: freezed == opponentName ? _self.opponentName : opponentName // ignore: cast_nullable_to_non_nullable
as String?,opponentAvatar: freezed == opponentAvatar ? _self.opponentAvatar : opponentAvatar // ignore: cast_nullable_to_non_nullable
as String?,opponentRoomId: freezed == opponentRoomId ? _self.opponentRoomId : opponentRoomId // ignore: cast_nullable_to_non_nullable
as String?,opponentThumbnailUrl: freezed == opponentThumbnailUrl ? _self.opponentThumbnailUrl : opponentThumbnailUrl // ignore: cast_nullable_to_non_nullable
as String?,battleDurationSeconds: freezed == battleDurationSeconds ? _self.battleDurationSeconds : battleDurationSeconds // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

/// Create a copy of LiveRoomDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$StreamConfigDtoCopyWith<$Res>? get streamConfig {
    if (_self.streamConfig == null) {
    return null;
  }

  return $StreamConfigDtoCopyWith<$Res>(_self.streamConfig!, (value) {
    return _then(_self.copyWith(streamConfig: value));
  });
}/// Create a copy of LiveRoomDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HostDtoCopyWith<$Res>? get host {
    if (_self.host == null) {
    return null;
  }

  return $HostDtoCopyWith<$Res>(_self.host!, (value) {
    return _then(_self.copyWith(host: value));
  });
}
}


/// @nodoc
mixin _$StreamConfigDto {

@JsonKey(name: 'rtmp_url') String? get rtmpUrl;@JsonKey(name: 'ingest_url') String? get ingestUrl;@JsonKey(name: 'stream_key') String? get streamKey;@JsonKey(name: 'playback_id') String? get playbackId;@JsonKey(name: 'playback_url') String? get playbackUrl;
/// Create a copy of StreamConfigDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StreamConfigDtoCopyWith<StreamConfigDto> get copyWith => _$StreamConfigDtoCopyWithImpl<StreamConfigDto>(this as StreamConfigDto, _$identity);

  /// Serializes this StreamConfigDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StreamConfigDto&&(identical(other.rtmpUrl, rtmpUrl) || other.rtmpUrl == rtmpUrl)&&(identical(other.ingestUrl, ingestUrl) || other.ingestUrl == ingestUrl)&&(identical(other.streamKey, streamKey) || other.streamKey == streamKey)&&(identical(other.playbackId, playbackId) || other.playbackId == playbackId)&&(identical(other.playbackUrl, playbackUrl) || other.playbackUrl == playbackUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,rtmpUrl,ingestUrl,streamKey,playbackId,playbackUrl);

@override
String toString() {
  return 'StreamConfigDto(rtmpUrl: $rtmpUrl, ingestUrl: $ingestUrl, streamKey: $streamKey, playbackId: $playbackId, playbackUrl: $playbackUrl)';
}


}

/// @nodoc
abstract mixin class $StreamConfigDtoCopyWith<$Res>  {
  factory $StreamConfigDtoCopyWith(StreamConfigDto value, $Res Function(StreamConfigDto) _then) = _$StreamConfigDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'rtmp_url') String? rtmpUrl,@JsonKey(name: 'ingest_url') String? ingestUrl,@JsonKey(name: 'stream_key') String? streamKey,@JsonKey(name: 'playback_id') String? playbackId,@JsonKey(name: 'playback_url') String? playbackUrl
});




}
/// @nodoc
class _$StreamConfigDtoCopyWithImpl<$Res>
    implements $StreamConfigDtoCopyWith<$Res> {
  _$StreamConfigDtoCopyWithImpl(this._self, this._then);

  final StreamConfigDto _self;
  final $Res Function(StreamConfigDto) _then;

/// Create a copy of StreamConfigDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? rtmpUrl = freezed,Object? ingestUrl = freezed,Object? streamKey = freezed,Object? playbackId = freezed,Object? playbackUrl = freezed,}) {
  return _then(_self.copyWith(
rtmpUrl: freezed == rtmpUrl ? _self.rtmpUrl : rtmpUrl // ignore: cast_nullable_to_non_nullable
as String?,ingestUrl: freezed == ingestUrl ? _self.ingestUrl : ingestUrl // ignore: cast_nullable_to_non_nullable
as String?,streamKey: freezed == streamKey ? _self.streamKey : streamKey // ignore: cast_nullable_to_non_nullable
as String?,playbackId: freezed == playbackId ? _self.playbackId : playbackId // ignore: cast_nullable_to_non_nullable
as String?,playbackUrl: freezed == playbackUrl ? _self.playbackUrl : playbackUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [StreamConfigDto].
extension StreamConfigDtoPatterns on StreamConfigDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StreamConfigDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StreamConfigDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StreamConfigDto value)  $default,){
final _that = this;
switch (_that) {
case _StreamConfigDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StreamConfigDto value)?  $default,){
final _that = this;
switch (_that) {
case _StreamConfigDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'rtmp_url')  String? rtmpUrl, @JsonKey(name: 'ingest_url')  String? ingestUrl, @JsonKey(name: 'stream_key')  String? streamKey, @JsonKey(name: 'playback_id')  String? playbackId, @JsonKey(name: 'playback_url')  String? playbackUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StreamConfigDto() when $default != null:
return $default(_that.rtmpUrl,_that.ingestUrl,_that.streamKey,_that.playbackId,_that.playbackUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'rtmp_url')  String? rtmpUrl, @JsonKey(name: 'ingest_url')  String? ingestUrl, @JsonKey(name: 'stream_key')  String? streamKey, @JsonKey(name: 'playback_id')  String? playbackId, @JsonKey(name: 'playback_url')  String? playbackUrl)  $default,) {final _that = this;
switch (_that) {
case _StreamConfigDto():
return $default(_that.rtmpUrl,_that.ingestUrl,_that.streamKey,_that.playbackId,_that.playbackUrl);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'rtmp_url')  String? rtmpUrl, @JsonKey(name: 'ingest_url')  String? ingestUrl, @JsonKey(name: 'stream_key')  String? streamKey, @JsonKey(name: 'playback_id')  String? playbackId, @JsonKey(name: 'playback_url')  String? playbackUrl)?  $default,) {final _that = this;
switch (_that) {
case _StreamConfigDto() when $default != null:
return $default(_that.rtmpUrl,_that.ingestUrl,_that.streamKey,_that.playbackId,_that.playbackUrl);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StreamConfigDto implements StreamConfigDto {
  const _StreamConfigDto({@JsonKey(name: 'rtmp_url') this.rtmpUrl, @JsonKey(name: 'ingest_url') this.ingestUrl, @JsonKey(name: 'stream_key') this.streamKey, @JsonKey(name: 'playback_id') this.playbackId, @JsonKey(name: 'playback_url') this.playbackUrl});
  factory _StreamConfigDto.fromJson(Map<String, dynamic> json) => _$StreamConfigDtoFromJson(json);

@override@JsonKey(name: 'rtmp_url') final  String? rtmpUrl;
@override@JsonKey(name: 'ingest_url') final  String? ingestUrl;
@override@JsonKey(name: 'stream_key') final  String? streamKey;
@override@JsonKey(name: 'playback_id') final  String? playbackId;
@override@JsonKey(name: 'playback_url') final  String? playbackUrl;

/// Create a copy of StreamConfigDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StreamConfigDtoCopyWith<_StreamConfigDto> get copyWith => __$StreamConfigDtoCopyWithImpl<_StreamConfigDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StreamConfigDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StreamConfigDto&&(identical(other.rtmpUrl, rtmpUrl) || other.rtmpUrl == rtmpUrl)&&(identical(other.ingestUrl, ingestUrl) || other.ingestUrl == ingestUrl)&&(identical(other.streamKey, streamKey) || other.streamKey == streamKey)&&(identical(other.playbackId, playbackId) || other.playbackId == playbackId)&&(identical(other.playbackUrl, playbackUrl) || other.playbackUrl == playbackUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,rtmpUrl,ingestUrl,streamKey,playbackId,playbackUrl);

@override
String toString() {
  return 'StreamConfigDto(rtmpUrl: $rtmpUrl, ingestUrl: $ingestUrl, streamKey: $streamKey, playbackId: $playbackId, playbackUrl: $playbackUrl)';
}


}

/// @nodoc
abstract mixin class _$StreamConfigDtoCopyWith<$Res> implements $StreamConfigDtoCopyWith<$Res> {
  factory _$StreamConfigDtoCopyWith(_StreamConfigDto value, $Res Function(_StreamConfigDto) _then) = __$StreamConfigDtoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'rtmp_url') String? rtmpUrl,@JsonKey(name: 'ingest_url') String? ingestUrl,@JsonKey(name: 'stream_key') String? streamKey,@JsonKey(name: 'playback_id') String? playbackId,@JsonKey(name: 'playback_url') String? playbackUrl
});




}
/// @nodoc
class __$StreamConfigDtoCopyWithImpl<$Res>
    implements _$StreamConfigDtoCopyWith<$Res> {
  __$StreamConfigDtoCopyWithImpl(this._self, this._then);

  final _StreamConfigDto _self;
  final $Res Function(_StreamConfigDto) _then;

/// Create a copy of StreamConfigDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? rtmpUrl = freezed,Object? ingestUrl = freezed,Object? streamKey = freezed,Object? playbackId = freezed,Object? playbackUrl = freezed,}) {
  return _then(_StreamConfigDto(
rtmpUrl: freezed == rtmpUrl ? _self.rtmpUrl : rtmpUrl // ignore: cast_nullable_to_non_nullable
as String?,ingestUrl: freezed == ingestUrl ? _self.ingestUrl : ingestUrl // ignore: cast_nullable_to_non_nullable
as String?,streamKey: freezed == streamKey ? _self.streamKey : streamKey // ignore: cast_nullable_to_non_nullable
as String?,playbackId: freezed == playbackId ? _self.playbackId : playbackId // ignore: cast_nullable_to_non_nullable
as String?,playbackUrl: freezed == playbackUrl ? _self.playbackUrl : playbackUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$HostDto {

 String? get id; String? get name;@JsonKey(name: 'avatar_url') String? get avatarUrl;
/// Create a copy of HostDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HostDtoCopyWith<HostDto> get copyWith => _$HostDtoCopyWithImpl<HostDto>(this as HostDto, _$identity);

  /// Serializes this HostDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HostDto&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,avatarUrl);

@override
String toString() {
  return 'HostDto(id: $id, name: $name, avatarUrl: $avatarUrl)';
}


}

/// @nodoc
abstract mixin class $HostDtoCopyWith<$Res>  {
  factory $HostDtoCopyWith(HostDto value, $Res Function(HostDto) _then) = _$HostDtoCopyWithImpl;
@useResult
$Res call({
 String? id, String? name,@JsonKey(name: 'avatar_url') String? avatarUrl
});




}
/// @nodoc
class _$HostDtoCopyWithImpl<$Res>
    implements $HostDtoCopyWith<$Res> {
  _$HostDtoCopyWithImpl(this._self, this._then);

  final HostDto _self;
  final $Res Function(HostDto) _then;

/// Create a copy of HostDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? name = freezed,Object? avatarUrl = freezed,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [HostDto].
extension HostDtoPatterns on HostDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HostDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HostDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HostDto value)  $default,){
final _that = this;
switch (_that) {
case _HostDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HostDto value)?  $default,){
final _that = this;
switch (_that) {
case _HostDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? id,  String? name, @JsonKey(name: 'avatar_url')  String? avatarUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HostDto() when $default != null:
return $default(_that.id,_that.name,_that.avatarUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? id,  String? name, @JsonKey(name: 'avatar_url')  String? avatarUrl)  $default,) {final _that = this;
switch (_that) {
case _HostDto():
return $default(_that.id,_that.name,_that.avatarUrl);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? id,  String? name, @JsonKey(name: 'avatar_url')  String? avatarUrl)?  $default,) {final _that = this;
switch (_that) {
case _HostDto() when $default != null:
return $default(_that.id,_that.name,_that.avatarUrl);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _HostDto implements HostDto {
  const _HostDto({this.id, this.name, @JsonKey(name: 'avatar_url') this.avatarUrl});
  factory _HostDto.fromJson(Map<String, dynamic> json) => _$HostDtoFromJson(json);

@override final  String? id;
@override final  String? name;
@override@JsonKey(name: 'avatar_url') final  String? avatarUrl;

/// Create a copy of HostDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HostDtoCopyWith<_HostDto> get copyWith => __$HostDtoCopyWithImpl<_HostDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HostDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HostDto&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,avatarUrl);

@override
String toString() {
  return 'HostDto(id: $id, name: $name, avatarUrl: $avatarUrl)';
}


}

/// @nodoc
abstract mixin class _$HostDtoCopyWith<$Res> implements $HostDtoCopyWith<$Res> {
  factory _$HostDtoCopyWith(_HostDto value, $Res Function(_HostDto) _then) = __$HostDtoCopyWithImpl;
@override @useResult
$Res call({
 String? id, String? name,@JsonKey(name: 'avatar_url') String? avatarUrl
});




}
/// @nodoc
class __$HostDtoCopyWithImpl<$Res>
    implements _$HostDtoCopyWith<$Res> {
  __$HostDtoCopyWithImpl(this._self, this._then);

  final _HostDto _self;
  final $Res Function(_HostDto) _then;

/// Create a copy of HostDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? name = freezed,Object? avatarUrl = freezed,}) {
  return _then(_HostDto(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
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
