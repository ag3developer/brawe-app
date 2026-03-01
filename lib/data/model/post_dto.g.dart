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

_PostResponseDto _$PostResponseDtoFromJson(Map<String, dynamic> json) =>
    _PostResponseDto(
      id: json['id'] as String,
      content: json['content'] as String,
      imageUrl: json['image_url'] as String?,
      likesCount: (json['likes_count'] as num).toInt(),
      commentsCount: (json['comments_count'] as num).toInt(),
      repostsCount: (json['reposts_count'] as num).toInt(),
      viewsCount: (json['views_count'] as num).toInt(),
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
      author: AuthorResponseDto.fromJson(
        json['author'] as Map<String, dynamic>,
      ),
      userLiked: json['user_liked'] as bool? ?? false,
      userReposted: json['user_reposted'] as bool? ?? false,
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
      'user_reposted': instance.userReposted,
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
