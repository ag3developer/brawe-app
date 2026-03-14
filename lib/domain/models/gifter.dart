import 'package:freezed_annotation/freezed_annotation.dart';

part 'gifter.freezed.dart';
part 'gifter.g.dart';

@freezed
sealed class Gifter with _$Gifter {
  const factory Gifter({
    required String id,
    required String name,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
    @JsonKey(name: 'total_spent') required double totalSpent,
    @Default(0) int rank,
  }) = _Gifter;

  factory Gifter.fromJson(Map<String, dynamic> json) => _$GifterFromJson(json);
}
