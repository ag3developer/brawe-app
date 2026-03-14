// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gifter.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Gifter _$GifterFromJson(Map<String, dynamic> json) => _Gifter(
  id: json['id'] as String,
  name: json['name'] as String,
  avatarUrl: json['avatar_url'] as String?,
  totalSpent: (json['total_spent'] as num).toDouble(),
  rank: (json['rank'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$GifterToJson(_Gifter instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'avatar_url': instance.avatarUrl,
  'total_spent': instance.totalSpent,
  'rank': instance.rank,
};
