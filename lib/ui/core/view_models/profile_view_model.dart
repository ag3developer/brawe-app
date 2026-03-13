import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../data/repositories/profile_repository.dart';
import '../../../data/repositories/social_repository.dart';
import '../../../domain/models/profile_state.dart';

part 'profile_view_model.g.dart';

@riverpod
class ProfileViewModel extends _$ProfileViewModel {
  @override
  ProfileState build(String userId) {
    _loadProfile();
    _loadStats();
    _loadLives();
    return ProfileState(
      profile: const AsyncValue.loading(),
      stats: const AsyncValue.loading(),
      lives: const AsyncValue.loading(),
    );
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await ref.read(profileRepositoryProvider).getUserProfile(userId);
      state = state.copyWith(profile: AsyncValue.data(profile));
    } catch (e, st) {
      state = state.copyWith(profile: AsyncValue.error(e, st));
    }
  }

  Future<void> _loadStats() async {
    try {
      final stats = await ref.read(socialRepositoryProvider).getSocialStats(userId);
      state = state.copyWith(stats: AsyncValue.data(stats));
    } catch (e, st) {
      state = state.copyWith(stats: AsyncValue.error(e, st));
    }
  }

  Future<void> _loadLives() async {
    try {
      final lives = await ref.read(profileRepositoryProvider).getUserLives(userId);
      state = state.copyWith(lives: AsyncValue.data(lives));
    } catch (e, st) {
      state = state.copyWith(lives: AsyncValue.error(e, st));
    }
  }

  Future<void> refresh() async {
    await Future.wait([_loadProfile(), _loadStats(), _loadLives()]);
  }
}
