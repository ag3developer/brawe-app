import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../data/repositories/auth_repository.dart';
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
      state = state.copyWith(status: AsyncValue.data(user));
      return true;
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
