import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../data/repositories/profile_repository.dart';
import '../../../domain/models/profile.dart';

part 'top_streamers_view_model.g.dart';

@riverpod
class TopStreamersViewModel extends _$TopStreamersViewModel {
  @override
  FutureOr<List<Profile>> build() async {
    return _fetchTopStreamers();
  }

  Future<List<Profile>> _fetchTopStreamers() async {
    return ref.read(profileRepositoryProvider).getTopStreamers();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchTopStreamers());
  }
}
