import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:brawe_app/ui/auth/view_models/login_view_model.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
  });

  tearDown(() {
    container.dispose();
  });

  group('LoginViewModel', () {
    test('initial state is empty', () {
      final state = container.read(loginViewModelProvider);
      expect(state.email, '');
      expect(state.password, '');
      expect(state.status.value, null);
    });

    test('updateEmail updates state', () {
      final notifier = container.read(loginViewModelProvider.notifier);
      notifier.updateEmail('test@example.com');

      final state = container.read(loginViewModelProvider);
      expect(state.email, 'test@example.com');
    });

    test('updatePassword updates state', () {
      final notifier = container.read(loginViewModelProvider.notifier);
      notifier.updatePassword('password123');

      final state = container.read(loginViewModelProvider);
      expect(state.password, 'password123');
    });

    test('canSubmit is true only when email and password are not empty', () {
      final notifier = container.read(loginViewModelProvider.notifier);

      expect(container.read(loginViewModelProvider).canSubmit, false);

      notifier.updateEmail('test@example.com');
      expect(container.read(loginViewModelProvider).canSubmit, false);

      notifier.updatePassword('password123');
      expect(container.read(loginViewModelProvider).canSubmit, true);
    });
  });
}
