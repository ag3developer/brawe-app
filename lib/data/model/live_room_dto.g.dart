// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'live_room_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LiveRoomDto _$LiveRoomDtoFromJson(Map<String, dynamic> json) => _LiveRoomDto(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String?,
  category: json['category'] as String?,
  liveType: json['live_type'] as String? ?? 'solo',
  isPrivate: json['is_private'] as bool? ?? false,
  status: json['status'] as String,
  viewerCount: (json['viewer_count'] as num?)?.toInt() ?? 0,
  streamUrl: json['stream_url'] as String?,
  thumbnailUrl: json['thumbnail_url'] as String?,
  streamerId: json['streamer_id'] as String,
  streamerName: json['streamer_name'] as String? ?? 'Unknown Streamer',
  streamerAvatarUrl: json['streamer_avatar_url'] as String?,
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
      'stream_url': instance.streamUrl,
      'thumbnail_url': instance.thumbnailUrl,
      'streamer_id': instance.streamerId,
      'streamer_name': instance.streamerName,
      'streamer_avatar_url': instance.streamerAvatarUrl,
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
