import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/models/user.dart';
import 'auth_repository.dart';

part 'auth_state_provider.g.dart';

@riverpod
class AuthState extends _$AuthState {
  @override
  FutureOr<User?> build() async {
    return ref.watch(authRepositoryProvider).getSession();
  }

  void updateSession(User? user) {
    state = AsyncData(user);
  }

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    state = const AsyncData(null);
  }
}
