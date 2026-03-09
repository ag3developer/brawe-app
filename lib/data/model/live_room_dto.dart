import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/models/live_room.dart';

part 'live_room_dto.freezed.dart';
part 'live_room_dto.g.dart';

@freezed
sealed class LiveRoomDto with _$LiveRoomDto {
  const factory LiveRoomDto({
    required String id,
    @Default('Untitled Live') String title,
    String? description,
    String? category,
    @JsonKey(name: 'live_type') @Default('solo') String liveType,
    @JsonKey(name: 'is_private') @Default(false) bool isPrivate,
    @Default('live') String status,
    @JsonKey(name: 'viewer_count') @Default(0) int viewerCount,
    @JsonKey(name: 'stream_url') String? streamUrl,
    @JsonKey(name: 'thumbnail_url') String? thumbnailUrl,
    @JsonKey(name: 'streamer_id') String? streamerId,
    @JsonKey(name: 'streamer_name')
    @Default('Unknown Streamer')
    String streamerName,
    @JsonKey(name: 'streamer_avatar_url') String? streamerAvatarUrl,
  }) = _LiveRoomDto;

  factory LiveRoomDto.fromJson(Map<String, dynamic> json) =>
      _$LiveRoomDtoFromJson(json);
}

extension LiveRoomDtoMapper on LiveRoomDto {
  LiveRoom toDomain() {
    return LiveRoom(
      id: id,
      title: title,
      description: description,
      category: category,
      liveType: liveType,
      isPrivate: isPrivate,
      status: status,
      viewerCount: viewerCount,
      streamUrl: streamUrl,
      thumbnailUrl: thumbnailUrl,
      streamerId: streamerId ?? 'unknown',
      streamerName: streamerName,
      streamerAvatarUrl: streamerAvatarUrl,
    );
  }
}

@freezed
sealed class LiveFeedResponseDto with _$LiveFeedResponseDto {
  const factory LiveFeedResponseDto({
    @Default([]) List<LiveRoomDto> rooms,
    String? cursor,
    @Default(10) int limit,
  }) = _LiveFeedResponseDto;

  factory LiveFeedResponseDto.fromJson(Map<String, dynamic> json) =>
      _$LiveFeedResponseDtoFromJson(json);
}
