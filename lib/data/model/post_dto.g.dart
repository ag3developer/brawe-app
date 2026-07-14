// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AuthorResponseDto _$AuthorResponseDtoFromJson(Map<String, dynamic> json) =>
    _AuthorResponseDto(
      id: json['id'] as String,
      name: json['name'] as String,
      username: json['username'] as String,
      avatarUrl: json['avatar_url'] as String?,
      isVerified: json['is_verified'] as bool? ?? false,
    );

Map<String, dynamic> _$AuthorResponseDtoToJson(_AuthorResponseDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'username': instance.username,
      'avatar_url': instance.avatarUrl,
      'is_verified': instance.isVerified,
    };

_PostResponseDto _$PostResponseDtoFromJson(
  Map<String, dynamic> json,
) => _PostResponseDto(
  id: json['id'] as String,
  content: json['content'] as String,
  imageUrl: json['image_url'] as String?,
  likesCount: (json['likes_count'] as num).toInt(),
  commentsCount: (json['comments_count'] as num).toInt(),
  repostsCount: (json['reposts_count'] as num).toInt(),
  viewsCount: (json['views_count'] as num).toInt(),
  createdAt: json['created_at'] as String,
  updatedAt: json['updated_at'] as String,
  author: AuthorResponseDto.fromJson(json['author'] as Map<String, dynamic>),
  userLiked: json['user_liked'] as bool? ?? false,
  userReactionType: json['user_reaction_type'] as String?,
  userReposted: json['user_reposted'] as bool? ?? false,
  userFollowingAuthor: json['user_following_author'] as bool? ?? false,
  repostedBy: json['reposted_by'] == null
      ? null
      : AuthorResponseDto.fromJson(json['reposted_by'] as Map<String, dynamic>),
  repostCreatedAt: json['repost_created_at'] as String?,
  sound: json['sound'] == null
      ? null
      : SoundPreview.fromJson(json['sound'] as Map<String, dynamic>),
  soundVolume: (json['sound_volume'] as num?)?.toDouble() ?? 1.0,
  originalAudioVolume:
      (json['original_audio_volume'] as num?)?.toDouble() ?? 1.0,
);

Map<String, dynamic> _$PostResponseDtoToJson(_PostResponseDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'content': instance.content,
      'image_url': instance.imageUrl,
      'likes_count': instance.likesCount,
      'comments_count': instance.commentsCount,
      'reposts_count': instance.repostsCount,
      'views_count': instance.viewsCount,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
      'author': instance.author,
      'user_liked': instance.userLiked,
      'user_reaction_type': instance.userReactionType,
      'user_reposted': instance.userReposted,
      'user_following_author': instance.userFollowingAuthor,
      'reposted_by': instance.repostedBy,
      'repost_created_at': instance.repostCreatedAt,
      'sound': instance.sound,
      'sound_volume': instance.soundVolume,
      'original_audio_volume': instance.originalAudioVolume,
    };

_PostFeedResponseDto _$PostFeedResponseDtoFromJson(Map<String, dynamic> json) =>
    _PostFeedResponseDto(
      posts: (json['posts'] as List<dynamic>)
          .map((e) => PostResponseDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: (json['total'] as num).toInt(),
      limit: (json['limit'] as num).toInt(),
      offset: (json['offset'] as num).toInt(),
    );

Map<String, dynamic> _$PostFeedResponseDtoToJson(
  _PostFeedResponseDto instance,
) => <String, dynamic>{
  'posts': instance.posts,
  'total': instance.total,
  'limit': instance.limit,
  'offset': instance.offset,
};
