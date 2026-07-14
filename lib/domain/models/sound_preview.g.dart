// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sound_preview.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SoundPreview _$SoundPreviewFromJson(Map<String, dynamic> json) =>
    _SoundPreview(
      id: json['id'] as String,
      title: json['title'] as String,
      artistName: json['artist_name'] as String,
      artistAvatarUrl: json['artist_avatar_url'] as String?,
      coverUrl: json['cover_url'] as String?,
      audioUrl: json['audio_url'] as String,
      durationMs: (json['duration_ms'] as num?)?.toInt() ?? 0,
      trimStartMs: (json['trim_start_ms'] as num?)?.toInt() ?? 0,
      trimEndMs: (json['trim_end_ms'] as num?)?.toInt(),
    );

Map<String, dynamic> _$SoundPreviewToJson(_SoundPreview instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'artist_name': instance.artistName,
      'artist_avatar_url': instance.artistAvatarUrl,
      'cover_url': instance.coverUrl,
      'audio_url': instance.audioUrl,
      'duration_ms': instance.durationMs,
      'trim_start_ms': instance.trimStartMs,
      'trim_end_ms': instance.trimEndMs,
    };
