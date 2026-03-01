import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/auth_state_provider.dart';
import '../../../domain/models/failure.dart';
import '../../../domain/models/user.dart';

part 'signup_view_model.freezed.dart';
part 'signup_view_model.g.dart';

@freezed
sealed class SignupState with _$SignupState {
  const factory SignupState({
    @Default('') String name,
    @Default('') String email,
    @Default('') String password,
    @Default('') String sponsorCode,
    @Default(AsyncValue<User?>.data(null)) AsyncValue<User?> status,
  }) = _SignupState;

  const SignupState._();

  bool get canSubmit =>
      name.isNotEmpty &&
      email.isNotEmpty &&
      password.isNotEmpty &&
      !status.isLoading;

  String? get errorMessage =>
      status.whenOrNull(error: (e, _) => (e as Failure).toDisplayMessage());
}

@riverpod
class SignupViewModel extends _$SignupViewModel {
  @override
  SignupState build() => const SignupState();

  void updateName(String value) {
    state = state.copyWith(
      name: value.trim(),
      status: const AsyncValue.data(null),
    );
  }

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

  void updateSponsorCode(String value) {
    state = state.copyWith(
      sponsorCode: value.trim(),
      status: const AsyncValue.data(null),
    );
  }

  Future<bool> submit() async {
    if (state.status.isLoading) return false;

    if (state.name.length < 2) {
      _setError('Name is too short.');
      return false;
    }

    if (!state.email.contains('@')) {
      _setError('Enter a valid email address.');
      return false;
    }

    if (state.password.length < 8) {
      _setError('Password must be at least 8 characters.');
      return false;
    }

    state = state.copyWith(status: const AsyncValue.loading());

    try {
      final user = await ref
          .read(authRepositoryProvider)
          .registerAffiliate(
            email: state.email,
            password: state.password,
            name: state.name,
            sponsorCode: state.sponsorCode,
          );
      state = state.copyWith(status: AsyncValue.data(user));
      ref.read(authStateProvider.notifier).updateSession(user);
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

  void _setError(String message) {
    state = state.copyWith(
      status: AsyncValue.error(Failure.validation(message), StackTrace.current),
    );
  }
}
