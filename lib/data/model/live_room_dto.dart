import 'package:freezed_annotation/freezed_annotation.dart';
import '../../core/constants/app_constants.dart';
import '../../domain/models/live_room.dart';

part 'live_room_dto.freezed.dart';
part 'live_room_dto.g.dart';

@freezed
sealed class LiveRoomDto with _$LiveRoomDto {
  const factory LiveRoomDto({
    String? id,
    String? slug,
    @Default('Untitled Live') String title,
    String? description,
    String? category,
    @JsonKey(name: 'live_type') @Default('solo') String liveType,
    @JsonKey(name: 'is_private') @Default(false) bool isPrivate,
    @Default(AppConstants.statusLive) String status,
    @JsonKey(name: 'viewer_count') @Default(0) int viewerCount,
    @JsonKey(name: 'total_likes') @Default(0) int totalLikes,
    @JsonKey(name: 'is_paused') @Default(false) bool isPaused,
    @JsonKey(name: 'paused_at') String? pausedAt,
    @JsonKey(name: 'playback_url') String? playbackUrl,
    @JsonKey(name: 'thumbnail_url') String? thumbnailUrl,
    @JsonKey(name: 'stream_config') StreamConfigDto? streamConfig,
    @JsonKey(name: 'host') HostDto? host,
    @JsonKey(name: 'streamer_id') String? streamerId,
    @JsonKey(name: 'streamer_name') String? streamerName,
    @JsonKey(name: 'streamer_avatar') String? streamerAvatar,
    @JsonKey(name: 'streamer_username') String? streamerUsername,
    @JsonKey(name: 'is_verified') @Default(false) bool isVerified,
    @JsonKey(name: 'ingest_url') String? ingestUrl,
    @JsonKey(name: 'started_at') String? startedAt,
    @JsonKey(name: 'created_at') String? createdAt,
  }) = _LiveRoomDto;

  factory LiveRoomDto.fromJson(Map<String, dynamic> json) =>
      _$LiveRoomDtoFromJson(json);
}

@freezed
sealed class StreamConfigDto with _$StreamConfigDto {
  const factory StreamConfigDto({
    @JsonKey(name: 'rtmp_url') String? rtmpUrl,
    @JsonKey(name: 'ingest_url') String? ingestUrl,
    @JsonKey(name: 'stream_key') String? streamKey,
    @JsonKey(name: 'playback_id') String? playbackId,
    @JsonKey(name: 'playback_url') String? playbackUrl,
  }) = _StreamConfigDto;

  factory StreamConfigDto.fromJson(Map<String, dynamic> json) =>
      _$StreamConfigDtoFromJson(json);
}

@freezed
sealed class HostDto with _$HostDto {
  const factory HostDto({
    String? id,
    String? name,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
  }) = _HostDto;

  factory HostDto.fromJson(Map<String, dynamic> json) =>
      _$HostDtoFromJson(json);
}

extension LiveRoomDtoMapper on LiveRoomDto {
  LiveRoom toDomain() {
    final effectivePlaybackId = streamConfig?.playbackId;
    final fallbackStreamUrl = effectivePlaybackId != null
        ? 'https://stream.mux.com/$effectivePlaybackId.m3u8'
        : null;

    return LiveRoom(
      id: id ?? 'missing_id',
      slug: slug ?? id ?? 'missing-id',
      title: title,
      description: description,
      category: category,
      liveType: liveType,
      isPrivate: isPrivate,
      status: status,
      viewerCount: viewerCount,
      totalLikes: totalLikes,
      isPaused: isPaused,
      pausedAt: pausedAt == null ? null : DateTime.tryParse(pausedAt!)?.toLocal(),
      playbackId: effectivePlaybackId,
      streamUrl: playbackUrl ?? streamConfig?.playbackUrl ?? fallbackStreamUrl,
      rtmpUrl: streamConfig?.rtmpUrl ?? streamConfig?.ingestUrl ?? ingestUrl,
      streamKey: streamConfig?.streamKey,
      thumbnailUrl: thumbnailUrl,
      streamerId: host?.id ?? streamerId ?? 'unknown',
      streamerName: host?.name ?? streamerName ?? 'Unknown Streamer',
      streamerAvatarUrl: host?.avatarUrl ?? streamerAvatar,
      streamerUsername: streamerUsername,
      streamerVerified: isVerified,
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
