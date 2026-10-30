import 'package:freezed_annotation/freezed_annotation.dart';

part 'gallery_media.freezed.dart';
part 'gallery_media.g.dart';

@freezed
sealed class GalleryMedia with _$GalleryMedia {
  const factory GalleryMedia({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'media_type') required String mediaType, // 'photo' | 'video'
    @Default(0) int position,
    required String url,
    @JsonKey(name: 'thumbnail_url') String? thumbnailUrl,
    /// Versão leve do vídeo (HLS do Bunny), quando já foi convertido.
    @JsonKey(name: 'hls_url') String? hlsUrl,
    String? caption,
    int? width,
    int? height,
    @JsonKey(name: 'duration_seconds') int? durationSeconds,
    @JsonKey(name: 'file_size') int? fileSize,
    @JsonKey(name: 'mime_type') String? mimeType,
    @JsonKey(name: 'views_count') @Default(0) int viewsCount,
    @JsonKey(name: 'likes_count') @Default(0) int likesCount,
    @JsonKey(name: 'is_liked') @Default(false) bool isLiked,
    @JsonKey(name: 'created_at') String? createdAt,
  }) = _GalleryMedia;

  factory GalleryMedia.fromJson(Map<String, dynamic> json) =>
      _$GalleryMediaFromJson(json);
}

@freezed
sealed class GalleryLimits with _$GalleryLimits {
  const factory GalleryLimits({
    @JsonKey(name: 'max_photos') @Default(6) int maxPhotos,
    @JsonKey(name: 'max_videos') @Default(3) int maxVideos,
    @JsonKey(name: 'photos_remaining') @Default(6) int photosRemaining,
    @JsonKey(name: 'videos_remaining') @Default(3) int videosRemaining,
  }) = _GalleryLimits;

  factory GalleryLimits.fromJson(Map<String, dynamic> json) =>
      _$GalleryLimitsFromJson(json);
}

@freezed
sealed class GalleryData with _$GalleryData {
  const factory GalleryData({
    @Default(<GalleryMedia>[]) List<GalleryMedia> photos,
    @Default(<GalleryMedia>[]) List<GalleryMedia> videos,
    GalleryLimits? limits,
  }) = _GalleryData;

  factory GalleryData.fromJson(Map<String, dynamic> json) =>
      _$GalleryDataFromJson(json);
}
