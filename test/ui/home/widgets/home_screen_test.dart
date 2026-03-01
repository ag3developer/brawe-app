import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:brawe_app/ui/home/widgets/home_screen.dart';

void main() {
  testWidgets('HomeScreen should render all sections', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: HomeScreen(),
      ),
    );

    expect(find.text('Alex R.'), findsOneWidget);
    expect(find.text('BRAWE'), findsOneWidget);
    expect(find.text('LIVE STREAM BATTLES'), findsOneWidget);
    expect(find.text('TOP STREAMERS'), findsOneWidget);
    expect(find.text('CATEGORIES'), findsOneWidget);
    expect(find.text('STREAM CARD'), findsOneWidget);
    expect(find.text('LIVE COMMERCE SHOW'), findsOneWidget);
    expect(find.byType(BottomNavigationBarItem), findsNothing); // Custom bottom nav
    expect(find.byIcon(Icons.home_filled), findsOneWidget);
  });
}
