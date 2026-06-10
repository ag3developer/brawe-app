import 'package:freezed_annotation/freezed_annotation.dart';

part 'live_room.freezed.dart';

@freezed
sealed class LiveRoom with _$LiveRoom {
  const factory LiveRoom({
    required String id,
    required String slug,
    required String title,
    String? description,
    String? category,
    required String liveType,
    required bool isPrivate,
    required String status,
    required int viewerCount,
    @Default(0) int totalLikes,
    @Default(0) int totalMessages,
    @Default(false) bool isPaused,
    DateTime? pausedAt,
    String? playbackId,
    String? streamUrl,
    String? rtmpUrl,
    String? streamKey,
    String? thumbnailUrl,
    required String streamerId,
    required String streamerName,
    String? streamerAvatarUrl,
    String? streamerUsername,
    @Default(false) bool streamerVerified,
    // ⚔️ Campos opcionais de batalha — preenchidos quando live_type = 'battle'
    String? battleId,
    String? opponentId,
    String? opponentName,
    String? opponentAvatarUrl,
    String? opponentRoomId,
    String? opponentThumbnailUrl,
    @Default(300) int battleDurationSeconds,
  }) = _LiveRoom;
}
