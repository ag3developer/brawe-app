// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'live_room_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LiveRoomDto _$LiveRoomDtoFromJson(Map<String, dynamic> json) => _LiveRoomDto(
  id: json['id'] as String?,
  title: json['title'] as String? ?? 'Untitled Live',
  description: json['description'] as String?,
  category: json['category'] as String?,
  liveType: json['live_type'] as String? ?? 'solo',
  isPrivate: json['is_private'] as bool? ?? false,
  status: json['status'] as String? ?? AppConstants.statusLive,
  viewerCount: (json['viewer_count'] as num?)?.toInt() ?? 0,
  playbackUrl: json['playback_url'] as String?,
  thumbnailUrl: json['thumbnail_url'] as String?,
  streamConfig: json['stream_config'] == null
      ? null
      : StreamConfigDto.fromJson(json['stream_config'] as Map<String, dynamic>),
  host: json['host'] == null
      ? null
      : HostDto.fromJson(json['host'] as Map<String, dynamic>),
  streamerId: json['streamer_id'] as String?,
  streamerName: json['streamer_name'] as String?,
  streamerAvatar: json['streamer_avatar'] as String?,
  ingestUrl: json['ingest_url'] as String?,
  startedAt: json['started_at'] as String?,
  createdAt: json['created_at'] as String?,
);

Map<String, dynamic> _$LiveRoomDtoToJson(_LiveRoomDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'category': instance.category,
      'live_type': instance.liveType,
      'is_private': instance.isPrivate,
      'status': instance.status,
      'viewer_count': instance.viewerCount,
      'playback_url': instance.playbackUrl,
      'thumbnail_url': instance.thumbnailUrl,
      'stream_config': instance.streamConfig,
      'host': instance.host,
      'streamer_id': instance.streamerId,
      'streamer_name': instance.streamerName,
      'streamer_avatar': instance.streamerAvatar,
      'ingest_url': instance.ingestUrl,
      'started_at': instance.startedAt,
      'created_at': instance.createdAt,
    };

_StreamConfigDto _$StreamConfigDtoFromJson(Map<String, dynamic> json) =>
    _StreamConfigDto(
      rtmpUrl: json['rtmp_url'] as String?,
      ingestUrl: json['ingest_url'] as String?,
      streamKey: json['stream_key'] as String?,
      playbackId: json['playback_id'] as String?,
      playbackUrl: json['playback_url'] as String?,
    );

Map<String, dynamic> _$StreamConfigDtoToJson(_StreamConfigDto instance) =>
    <String, dynamic>{
      'rtmp_url': instance.rtmpUrl,
      'ingest_url': instance.ingestUrl,
      'stream_key': instance.streamKey,
      'playback_id': instance.playbackId,
      'playback_url': instance.playbackUrl,
    };

_HostDto _$HostDtoFromJson(Map<String, dynamic> json) => _HostDto(
  id: json['id'] as String?,
  name: json['name'] as String?,
  avatarUrl: json['avatar_url'] as String?,
);

Map<String, dynamic> _$HostDtoToJson(_HostDto instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'avatar_url': instance.avatarUrl,
};

_LiveFeedResponseDto _$LiveFeedResponseDtoFromJson(Map<String, dynamic> json) =>
    _LiveFeedResponseDto(
      rooms:
          (json['rooms'] as List<dynamic>?)
              ?.map((e) => LiveRoomDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      cursor: json['cursor'] as String?,
      limit: (json['limit'] as num?)?.toInt() ?? 10,
    );

Map<String, dynamic> _$LiveFeedResponseDtoToJson(
  _LiveFeedResponseDto instance,
) => <String, dynamic>{
  'rooms': instance.rooms,
  'cursor': instance.cursor,
  'limit': instance.limit,
};
