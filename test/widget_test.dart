// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:brawe_app/data/repositories/auth_state_provider.dart';
import 'package:brawe_app/domain/models/user.dart';
import 'package:brawe_app/main.dart';

void main() {
  testWidgets('Brawe app renders welcome screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [authStateProvider.overrideWith(() => _MockAuthState(null))],
        child: const BraweApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('A sua nova rede social'), findsOneWidget);
    expect(find.text('Entrar'), findsOneWidget);
  });
}

class _MockAuthState extends AuthState {
  _MockAuthState(this.user);

  final User? user;

  @override
  FutureOr<User?> build() => user;
}
