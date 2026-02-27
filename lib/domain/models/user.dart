import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
sealed class User with _$User {
  factory User({
    required String id,
    required String email,
    required String name,
    @JsonKey(name: 'user_type') required String userType,
    @JsonKey(name: 'display_id') required String displayId,
    @JsonKey(name: 'first_name') required String firstName,
    @JsonKey(name: 'last_name') required String lastName,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
    @JsonKey(name: 'is_affiliate') @Default(false) bool isAffiliate,
    @JsonKey(name: 'is_advertiser') @Default(false) bool isAdvertiser,
    @JsonKey(name: 'is_seller') @Default(false) bool isSeller,
    @JsonKey(name: 'is_creator') @Default(false) bool isCreator,
    @JsonKey(name: 'created_at') required String createdAt,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
