// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gallery_media.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GalleryMedia _$GalleryMediaFromJson(Map<String, dynamic> json) =>
    _GalleryMedia(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      mediaType: json['media_type'] as String,
      position: (json['position'] as num?)?.toInt() ?? 0,
      url: json['url'] as String,
      thumbnailUrl: json['thumbnail_url'] as String?,
      caption: json['caption'] as String?,
      width: (json['width'] as num?)?.toInt(),
      height: (json['height'] as num?)?.toInt(),
      durationSeconds: (json['duration_seconds'] as num?)?.toInt(),
      fileSize: (json['file_size'] as num?)?.toInt(),
      mimeType: json['mime_type'] as String?,
      viewsCount: (json['views_count'] as num?)?.toInt() ?? 0,
      likesCount: (json['likes_count'] as num?)?.toInt() ?? 0,
      isLiked: json['is_liked'] as bool? ?? false,
      createdAt: json['created_at'] as String?,
    );

Map<String, dynamic> _$GalleryMediaToJson(_GalleryMedia instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'media_type': instance.mediaType,
      'position': instance.position,
      'url': instance.url,
      'thumbnail_url': instance.thumbnailUrl,
      'caption': instance.caption,
      'width': instance.width,
      'height': instance.height,
      'duration_seconds': instance.durationSeconds,
      'file_size': instance.fileSize,
      'mime_type': instance.mimeType,
      'views_count': instance.viewsCount,
      'likes_count': instance.likesCount,
      'is_liked': instance.isLiked,
      'created_at': instance.createdAt,
    };

_GalleryLimits _$GalleryLimitsFromJson(Map<String, dynamic> json) =>
    _GalleryLimits(
      maxPhotos: (json['max_photos'] as num?)?.toInt() ?? 6,
      maxVideos: (json['max_videos'] as num?)?.toInt() ?? 3,
      photosRemaining: (json['photos_remaining'] as num?)?.toInt() ?? 6,
      videosRemaining: (json['videos_remaining'] as num?)?.toInt() ?? 3,
    );

Map<String, dynamic> _$GalleryLimitsToJson(_GalleryLimits instance) =>
    <String, dynamic>{
      'max_photos': instance.maxPhotos,
      'max_videos': instance.maxVideos,
      'photos_remaining': instance.photosRemaining,
      'videos_remaining': instance.videosRemaining,
    };

_GalleryData _$GalleryDataFromJson(Map<String, dynamic> json) => _GalleryData(
  photos:
      (json['photos'] as List<dynamic>?)
          ?.map((e) => GalleryMedia.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <GalleryMedia>[],
  videos:
      (json['videos'] as List<dynamic>?)
          ?.map((e) => GalleryMedia.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <GalleryMedia>[],
  limits: json['limits'] == null
      ? null
      : GalleryLimits.fromJson(json['limits'] as Map<String, dynamic>),
);

Map<String, dynamic> _$GalleryDataToJson(_GalleryData instance) =>
    <String, dynamic>{
      'photos': instance.photos,
      'videos': instance.videos,
      'limits': instance.limits,
    };
