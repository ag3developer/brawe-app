import 'package:brawe_app/domain/models/live_gift.dart';
import 'package:brawe_app/ui/live_feed/view_models/live_room_gifts_view_model.dart';
import 'package:brawe_app/ui/live_feed/widgets/gift_animation_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'GiftAnimationOverlay renders a newest-first scrollable gift list',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            liveRoomGiftsViewModelProvider('room-1').overrideWithValue([
              LiveGift(
                id: 'gift-1',
                senderId: 'user-1',
                senderName: 'Alice',
                giftId: 'rose',
                giftName: 'Rose',
                quantity: 3,
                timestamp: DateTime.utc(2026, 3, 24, 1),
              ),
              LiveGift(
                id: 'gift-2',
                senderId: 'user-2',
                senderName: 'Bob',
                giftId: 'crown',
                giftName: 'Crown',
                quantity: 1,
                timestamp: DateTime.utc(2026, 3, 24, 1, 0, 1),
              ),
              LiveGift(
                id: 'gift-3',
                senderId: 'user-3',
                senderName: 'Carol',
                giftId: 'star',
                giftName: 'Star',
                quantity: 5,
                timestamp: DateTime.utc(2026, 3, 24, 1, 0, 2),
              ),
            ]),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: Stack(children: [GiftAnimationOverlay(roomId: 'room-1')]),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('gift-toast-list')), findsOneWidget);
      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('Bob'), findsOneWidget);
      expect(find.text('Carol'), findsOneWidget);

      final newestTop = tester.getTopLeft(
        find.byKey(const ValueKey('gift-toast-gift-3')),
      );
      final middleTop = tester.getTopLeft(
        find.byKey(const ValueKey('gift-toast-gift-2')),
      );
      final oldestTop = tester.getTopLeft(
        find.byKey(const ValueKey('gift-toast-gift-1')),
      );
      expect(newestTop.dy, lessThan(middleTop.dy));
      expect(middleTop.dy, lessThan(oldestTop.dy));

      final richTextContents = tester
          .widgetList<RichText>(find.byType(RichText))
          .map((widget) => widget.text.toPlainText())
          .toList();

      expect(
        richTextContents.any((content) => content.contains('sent Rose x3')),
        isTrue,
      );
      expect(
        richTextContents.any((content) => content.contains('sent Star x5')),
        isTrue,
      );
    },
  );
}
