import 'package:freezed_annotation/freezed_annotation.dart';

part 'follow_user.freezed.dart';
part 'follow_user.g.dart';

@freezed
sealed class FollowUser with _$FollowUser {
  const factory FollowUser({
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'display_name') String? displayName,
    @Default('') String username,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
    String? bio,
    @JsonKey(name: 'is_verified') @Default(false) bool isVerified,
    @JsonKey(name: 'is_following') @Default(false) bool isFollowing,
    @JsonKey(name: 'is_streamer') @Default(false) bool isStreamer,
    @JsonKey(name: 'is_live') @Default(false) bool isLive,
    @JsonKey(name: 'followed_at') String? followedAt,
  }) = _FollowUser;

  factory FollowUser.fromJson(Map<String, dynamic> json) =>
      _$FollowUserFromJson(json);
}
