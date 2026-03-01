import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:brawe_app/ui/home/widgets/home_screen.dart';
import 'package:brawe_app/data/repositories/auth_state_provider.dart';
import 'package:brawe_app/domain/models/user.dart';

void main() {
  testWidgets(
    'HomeScreen should render user info in bottom sheet when profile icon is tapped',
    (WidgetTester tester) async {
      final mockUser = User(
        id: '1',
        email: 'test@brawe.io',
        name: 'John Doe',
        userType: 'affiliate',
        displayId: 'john123',
        firstName: 'John',
        lastName: 'Doe',
        createdAt: '2024-01-01',
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authStateProvider.overrideWith(() => _MockAuthState(mockUser)),
          ],
          child: const MaterialApp(home: HomeScreen()),
        ),
      );

      await tester.pump();

      // The name should NOT be visible initially
      expect(find.text('John Doe'), findsNothing);

      // Find and tap the profile icon (it's the only CircleAvatar in the top bar)
      final profileIcon = find.byType(CircleAvatar).first;
      await tester.tap(profileIcon);
      await tester.pumpAndSettle();

      // Now the name and user type should be visible in the bottom sheet
      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('AFFILIATE'), findsOneWidget);
      expect(find.text('BRAWE'), findsOneWidget);
    },
  );
}

class _MockAuthState extends AuthState {
  final User? user;
  _MockAuthState(this.user);

  @override
  FutureOr<User?> build() => user;
}
