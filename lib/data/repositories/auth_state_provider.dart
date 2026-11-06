import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/network/session_ended.dart';
import '../../domain/models/user.dart';
import 'auth_repository.dart';
import '../../ui/onboarding/onboarding_gate.dart';

part 'auth_state_provider.g.dart';

@riverpod
class AuthState extends _$AuthState {
  @override
  FutureOr<User?> build() async {
    // Sessão revogada no servidor (401) → limpa tokens e volta ao login.
    void onSessionEnded() {
      if (!SessionEnded.instance.messagePending) return;
      if (state.asData?.value == null) {
        // Já deslogado: nada a limpar; o aviso fica para o login.
        SessionEnded.instance.handled();
        return;
      }
      logout().whenComplete(SessionEnded.instance.handled);
    }

    SessionEnded.instance.addListener(onSessionEnded);
    ref.onDispose(() => SessionEnded.instance.removeListener(onSessionEnded));
    return ref.watch(authRepositoryProvider).getSession();
  }

  void updateSession(User? user) {
    state = AsyncData(user);
  }

  Future<void> logout() async {
    OnboardingGate.instance.reset();
    await ref.read(authRepositoryProvider).logout();
    state = const AsyncData(null);
  }
}
