// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_User _$UserFromJson(Map<String, dynamic> json) => _User(
  id: json['id'] as String,
  email: json['email'] as String,
  name: json['name'] as String,
  userType: json['user_type'] as String,
  displayId: json['display_id'] as String,
  firstName: json['first_name'] as String,
  lastName: json['last_name'] as String,
  avatarUrl: json['avatar_url'] as String?,
  isActive: json['is_active'] as bool? ?? true,
  isAffiliate: json['is_affiliate'] as bool? ?? false,
  isAdvertiser: json['is_advertiser'] as bool? ?? false,
  isSeller: json['is_seller'] as bool? ?? false,
  isCreator: json['is_creator'] as bool? ?? false,
  createdAt: json['created_at'] as String,
);

Map<String, dynamic> _$UserToJson(_User instance) => <String, dynamic>{
  'id': instance.id,
  'email': instance.email,
  'name': instance.name,
  'user_type': instance.userType,
  'display_id': instance.displayId,
  'first_name': instance.firstName,
  'last_name': instance.lastName,
  'avatar_url': instance.avatarUrl,
  'is_active': instance.isActive,
  'is_affiliate': instance.isAffiliate,
  'is_advertiser': instance.isAdvertiser,
  'is_seller': instance.isSeller,
  'is_creator': instance.isCreator,
  'created_at': instance.createdAt,
};
