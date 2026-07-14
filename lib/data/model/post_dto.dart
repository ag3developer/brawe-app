import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/models/post.dart';
import '../../domain/models/sound_preview.dart';

part 'post_dto.freezed.dart';
part 'post_dto.g.dart';

@freezed
sealed class AuthorResponseDto with _$AuthorResponseDto {
  const factory AuthorResponseDto({
    required String id,
    required String name,
    required String username,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
    @JsonKey(name: 'is_verified') @Default(false) bool isVerified,
  }) = _AuthorResponseDto;

  factory AuthorResponseDto.fromJson(Map<String, dynamic> json) =>
      _$AuthorResponseDtoFromJson(json);
}

extension AuthorResponseDtoMapper on AuthorResponseDto {
  PostAuthor toDomain() {
    return PostAuthor(
      id: id,
      name: name,
      username: username,
      avatarUrl: avatarUrl,
      isVerified: isVerified,
    );
  }
}

@freezed
sealed class PostResponseDto with _$PostResponseDto {
  const factory PostResponseDto({
    required String id,
    required String content,
    @JsonKey(name: 'image_url') String? imageUrl,
    @JsonKey(name: 'likes_count') required int likesCount,
    @JsonKey(name: 'comments_count') required int commentsCount,
    @JsonKey(name: 'reposts_count') required int repostsCount,
    @JsonKey(name: 'views_count') required int viewsCount,
    @JsonKey(name: 'created_at') required String createdAt,
    @JsonKey(name: 'updated_at') required String updatedAt,
    required AuthorResponseDto author,
    @JsonKey(name: 'user_liked') @Default(false) bool userLiked,
    @JsonKey(name: 'user_reaction_type') String? userReactionType,
    @JsonKey(name: 'user_reposted') @Default(false) bool userReposted,
    @JsonKey(name: 'user_following_author')
    @Default(false)
    bool userFollowingAuthor,
    @JsonKey(name: 'reposted_by') AuthorResponseDto? repostedBy,
    @JsonKey(name: 'repost_created_at') String? repostCreatedAt,
    SoundPreview? sound,
    @JsonKey(name: 'sound_volume') @Default(1.0) double soundVolume,
    @JsonKey(name: 'original_audio_volume')
    @Default(1.0)
    double originalAudioVolume,
  }) = _PostResponseDto;

  factory PostResponseDto.fromJson(Map<String, dynamic> json) =>
      _$PostResponseDtoFromJson(json);
}

extension PostResponseDtoMapper on PostResponseDto {
  Post toDomain() {
    return Post(
      id: id,
      content: content,
      imageUrl: imageUrl,
      likesCount: likesCount,
      commentsCount: commentsCount,
      repostsCount: repostsCount,
      viewsCount: viewsCount,
      createdAt: DateTime.parse(createdAt),
      author: author.toDomain(),
      userLiked: userLiked,
      userReactionType: userReactionType,
      userReposted: userReposted,
      userFollowingAuthor: userFollowingAuthor,
      repostedBy: repostedBy?.toDomain(),
      repostCreatedAt: repostCreatedAt != null
          ? DateTime.tryParse(repostCreatedAt!)
          : null,
      sound: sound,
      soundVolume: soundVolume,
      originalAudioVolume: originalAudioVolume,
    );
  }
}

@freezed
sealed class PostFeedResponseDto with _$PostFeedResponseDto {
  const factory PostFeedResponseDto({
    required List<PostResponseDto> posts,
    required int total,
    required int limit,
    required int offset,
  }) = _PostFeedResponseDto;

  factory PostFeedResponseDto.fromJson(Map<String, dynamic> json) =>
      _$PostFeedResponseDtoFromJson(json);
}
