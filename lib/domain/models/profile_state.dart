import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'profile.dart';
import 'social_stats.dart';
import 'live_room.dart';

part 'profile_state.freezed.dart';

@freezed
sealed class ProfileState with _$ProfileState {
  const factory ProfileState({
    required AsyncValue<Profile> profile,
    required AsyncValue<SocialStats> stats,
    required AsyncValue<List<LiveRoom>> lives,
  }) = _ProfileState;
}
