import 'dart:async';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' show Notifier, NotifierProvider;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/services/push_notification_service.dart';
import '../../../data/repositories/auth_state_provider.dart';
import '../../../domain/models/failure.dart';
import '../../../domain/models/user.dart';

part 'login_view_model.freezed.dart';
part 'login_view_model.g.dart';

@freezed
sealed class LoginState with _$LoginState {
  const factory LoginState({
    @Default('') String email,
    @Default('') String password,
    @Default(AsyncValue<User?>.data(null)) AsyncValue<User?> status,
  }) = _LoginState;

  const LoginState._();

  bool get canSubmit =>
      email.isNotEmpty && password.isNotEmpty && !status.isLoading;

  String? get errorMessage =>
      status.whenOrNull(error: (e, _) => (e as Failure).toDisplayMessage());
}

/// Verificação pedida pelo servidor (login arriscado).
class StepUpChallenge {
  const StepUpChallenge({
    required this.challengeId,
    required this.emailMasked,
    this.resendIn = 60,
  });
  final String challengeId;
  final String emailMasked;

  /// Segundos até liberar "Reenviar" (`resend_in` do 403 do servidor).
  final int resendIn;
}

/// Desafio pendente: a tela de login observa e abre a tela do código.
class StepUpChallengeNotifier extends Notifier<StepUpChallenge?> {
  @override
  StepUpChallenge? build() => null;
  void set(StepUpChallenge? v) => state = v;
}

final stepUpChallengeProvider =
    NotifierProvider<StepUpChallengeNotifier, StepUpChallenge?>(
      StepUpChallengeNotifier.new,
    );

@riverpod
class LoginViewModel extends _$LoginViewModel {
  @override
  LoginState build() => const LoginState();

  void updateEmail(String value) {
    state = state.copyWith(
      email: value.trim(),
      status: const AsyncValue.data(null),
    );
  }

  void updatePassword(String value) {
    state = state.copyWith(
      password: value,
      status: const AsyncValue.data(null),
    );
  }

  /// Conclui o login (direto ou depois do código de verificação).
  void finishLogin(User user) {
    state = state.copyWith(status: AsyncValue.data(user));
    ref.read(stepUpChallengeProvider.notifier).set(null);
    ref.read(authStateProvider.notifier).updateSession(user);
    // Register FCM device token (best-effort, fails silently).
    unawaited(ref.read(pushNotificationServiceProvider).registerWithBackend());
  }

  Future<bool> submit() async {
    if (state.status.isLoading) return false;

    if (!state.email.contains('@')) {
      state = state.copyWith(
        status: AsyncValue.error(
          const Failure.validation('Enter a valid email address.'),
          StackTrace.current,
        ),
      );
      return false;
    }

    if (state.password.length < 6) {
      state = state.copyWith(
        status: AsyncValue.error(
          const Failure.validation('Password must be at least 6 characters.'),
          StackTrace.current,
        ),
      );
      return false;
    }

    state = state.copyWith(status: const AsyncValue.loading());

    try {
      final user = await ref
          .read(authRepositoryProvider)
          .login(state.email, state.password);
      finishLogin(user);
      return true;
    } on StepUpRequiredException catch (e) {
      // Aparelho novo/risco: o servidor mandou um código por e-mail.
      state = state.copyWith(status: const AsyncValue.data(null));
      ref
          .read(stepUpChallengeProvider.notifier)
          .set(
            StepUpChallenge(
              challengeId: e.challengeId,
              emailMasked: e.emailMasked,
              resendIn: e.resendIn,
            ),
          );
      return false;
    } on Failure catch (e, st) {
      state = state.copyWith(status: AsyncValue.error(e, st));
      return false;
    } catch (e, st) {
      state = state.copyWith(
        status: AsyncValue.error(const Failure.unknown(), st),
      );
      return false;
    }
  }
}
